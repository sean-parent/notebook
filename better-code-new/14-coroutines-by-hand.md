---
jupyter:
  jupytext:
    text_representation:
      extension: .md
      format_name: markdown
      format_version: '1.3'
      jupytext_version: 1.14.4
  kernelspec:
    display_name: C++17
    language: C++17
    name: xcpp17
---

```c++ slideshow={"slide_type": "skip"}
#pragma cling add_include_path("../stlab/libraries")
```

<!-- #region slideshow={"slide_type": "slide"} -->
# Coroutines By Hand

* Implement sequential process as a coroutine
<!-- #endregion -->

```c++ slideshow={"slide_type": "skip"}
#include <mutex>
#include <string>
#include <unordered_set>
#include <functional>
#include <condition_variable>
#include <deque>
#include <thread>
#include <iostream>

#define STLAB_DISABLE_FUTURE_COROUTINES 1
#include <stlab/concurrency/future.hpp>
#include <stlab/concurrency/immediate_executor.hpp>
#include <stlab/concurrency/default_executor.hpp>
#include <stlab/concurrency/utility.hpp>
```

```c++ slideshow={"slide_type": "skip"}
using namespace std;
```

```c++ run_control={"marked": true} slideshow={"slide_type": "skip"}
class task {
    struct concept {
        virtual ~concept() {}
        virtual void invoke() = 0;
    };

    template <class F>
    struct model final : concept {
        F _f;
        model(F f) : _f(move(f)) {}
        void invoke() override { _f(); }
    };
    unique_ptr<concept> _self;

public:
    task() = default;

    template <class F> // F model void()
    task(F f) : _self(make_unique<model<F>>(move(f))) {}

    void operator()() { _self->invoke(); }
};
```

<!-- #region slideshow={"slide_type": "slide"} -->
## Recall `sequential_process` implementation
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
namespace bcc {

class sequential_process {
    mutex _mutex;
    condition_variable _condition;
    deque<task> _queue;
    bool _done = false;

    void run_loop();

    thread _thread{[this] { run_loop(); }};

public:
    ~sequential_process();
    void async(task);
};

} // namespace bcc
```

<!-- #region slideshow={"slide_type": "slide"} -->
- The logical structure of our coroutine will be:

```cpp
class sequential_process {
    awaitable_queue<task> _queue;
    co_task<void> _running;

public:
    sequential_process() {
        _running = [&]() {
            while (true) {
                (co_await _queue.pop())();
            }
        }
    }
    void async(task f) { _queue.push(move(f)); }
};
```
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
- **Tip: When desinging code, sketch the code in an ideal form**
- Without building the infrustructure for `awaitable_queue<>` and `co_task<>`
    - We can build the same logical structure directly in `seqential_process`
- Build concrete solutions before complex abstractions
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
- As a coroutine we no longer need:
    - `_thread`
    - `_condition`
    - `_done` flag
    - `run_loop()`
    - `join()` on destuction
- We will need
    - `_running` flag
    - `resume()`
<!-- #endregion -->

```c++ slideshow={"slide_type": "slide"}
namespace bcc2 {

class sequential_process {
    mutex _mutex;
    bool _running = false;
    deque<task> _queue;

    void resume();

public:
    void async(task);
};

} // namespace bcc2
```

```c++ slideshow={"slide_type": "skip"}
namespace bcc {

sequential_process::~sequential_process() {
    {
        lock_guard<mutex> lock(_mutex);
        _done = true;
    }
    _condition.notify_one();
    _thread.join();
}

void sequential_process::run_loop() {
    while (true) {
        task work;
        {
            unique_lock<mutex> lock(_mutex);

            while (_queue.empty() && !_done) {
                _condition.wait(lock);
            }

            if (_queue.empty()) return;

            work = move(_queue.front());
            _queue.pop_front();
        }
        work();
    }
}

void sequential_process::async(task f) {
    {
        lock_guard<mutex> lock(_mutex);
        _queue.push_back(move(f));
    }
    _condition.notify_one();
}

} // namespace bcc
```

<!-- #region slideshow={"slide_type": "slide"} -->
- `resume()` is the body of our coroutine:
```cpp
while (true) {
    (co_await _queue.pop())();
}
```
<!-- #endregion -->

```c++ slideshow={"slide_type": "slide"}
namespace bcc2 {

void sequential_process::resume() {
    task work;
    while (true) {
        {
            unique_lock<mutex> lock(_mutex);

            if (_queue.empty()) {
                _running = false;
                return;
            }
            work = move(_queue.front());
            _queue.pop_front();
        }
        work();
    }
}

} // namespace bcc2
```

<!-- #region slideshow={"slide_type": "slide"} -->
- `async()` does a push and `resume()` if not running
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
namespace bcc2 {

void sequential_process::async(task f) {
    bool running = true;
    {
        lock_guard<mutex> lock(_mutex);
        _queue.push_back(move(f));
        swap(running, _running);
    }
    if (!running) resume();
}

} // namespace bcc2
```

```c++ slideshow={"slide_type": "skip"}
using namespace bcc2;
```

<!-- #region slideshow={"slide_type": "slide"} -->
- `async_packaged()`, `shared_pool`, and `interned_string` are unmodified
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
namespace {

template <class F> // F models R()
auto async_packaged(sequential_process& process, F&& f) {
    using result_t = std::result_of_t<std::decay_t<F>()>;

    auto task_future = stlab::package<result_t()>(stlab::immediate_executor,
                                                  std::forward<F>(f));

    process.async(move(task_future.first));

    return move(task_future.second);
}

} // namespace
```

```c++ slideshow={"slide_type": "slide"}
namespace {

struct shared_pool {
    unordered_set<string> _pool;
    sequential_process _process;

    auto insert(string a) -> stlab::future<const string*> {
        return async_packaged(
            _process, [this, _a = move(a)]() mutable {
                return &*_pool.insert(move(_a)).first;
            });
    }
};

} // namespace
```

```c++ slideshow={"slide_type": "slide"}
namespace {

class interned_string {
    static auto pool() -> shared_pool& {
        static shared_pool result;
        return result;
    }

    stlab::future<const string*> _string;

public:
    interned_string(string a) : _string(pool().insert(move(a))) {}

    auto str() const -> stlab::future<reference_wrapper<const string>> {
        return _string.then([](const string* p) { return cref(*p); });
    }
};

} // namespace
```

<!-- #region slideshow={"slide_type": "slide"} -->
- And is used exactly the same way
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
{
    interned_string s("Hello World!"s);

    auto done = s.str().then([](const string& s) { cout << s << '\n'; });

    blocking_get(done);
}
```

<!-- #region slideshow={"slide_type": "slide"} -->
- Advantages to the coroutine implementation
    - No seperate thread overhead
    - No overhead for waiting on condition variable
    - No blocking
    - Possible to implement with lock-free queue
    - `resume()` need not be executed _inline_
        - It could be queued to a _thread pool_
        - Requires some managment of _object liftimes_
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "fragment"} -->
- Disadvantages
    - _inline_ execution may _live lock_
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
```cpp
void sequential_process::async(task f) {
    bool running = true;
    {
        lock_guard<mutex> lock(_mutex);
        _queue.push_back(move(f));
        swap(running, _running);
    }
    if (!running) async([this]{ resume(); }); // WHAAATTT this???
}
```
<!-- #endregion -->

```c++

```
