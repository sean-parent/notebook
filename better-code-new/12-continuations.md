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

```c++ slideshow={"slide_type": "skip"}
#include <mutex>
#include <string>
#include <unordered_set>
#include <functional>
#include <condition_variable>
#include <deque>
#include <thread>
#include <iostream>
#include <type_traits>

#define STLAB_DISABLE_FUTURE_COROUTINES 1
#include <stlab/concurrency/future.hpp>
#include <stlab/concurrency/immediate_executor.hpp>
#include <stlab/concurrency/default_executor.hpp>
#include <stlab/concurrency/utility.hpp>
```

```c++ slideshow={"slide_type": "skip"}
using namespace stlab;
```

```c++ slideshow={"slide_type": "skip"}
using namespace std;
```

```c++ run_control={"marked": true} slideshow={"slide_type": "skip"}
namespace bcc {

class task {
    struct concept;

    template <class F>
    struct model;

    std::unique_ptr<concept> _self;

public:
    task() = default;
    //...

    template <class F> // F model void()
    task(F f);         // Need to implement

    void operator()(); // Need to implement
};

} // namespace bcc
```

```c++ slideshow={"slide_type": "skip"}
using namespace bcc;
```

```c++ slideshow={"slide_type": "skip"}
struct bcc::task::concept {
    virtual ~concept() {}
    virtual void invoke() = 0;
};
```

```c++ slideshow={"slide_type": "skip"}
template <class F>
struct bcc::task::model final : concept {
    F _f;
    model(F f) : _f(move(f)) {}
    void invoke() override { _f(); }
};
```

```c++ slideshow={"slide_type": "skip"}
template <class F>
bcc::task::task(F f) : _self(make_unique<model<F>>(move(f))) { }
```

```c++ run_control={"marked": true} slideshow={"slide_type": "skip"}
namespace bcc {

void task::operator()() { _self->invoke(); }

} // namespace bcc
```

```c++ slideshow={"slide_type": "skip"}
namespace bcc {

class sequential_process {
    // using task = function<void()>;

    mutex _mutex;
    condition_variable _condition;
    deque<task> _queue;
    bool _done = false;

    void run_loop();

    thread _thread{[this] { run_loop(); }};

public:
    ~sequential_process();
    void async(task f);
};

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

template <class F> // F models R()
inline auto async_packaged(sequential_process& process, F&& f) {
    using result_t = std::result_of_t<std::decay_t<F>()>;

    auto task_future = stlab::package<result_t()>(stlab::immediate_executor, std::forward<F>(f));

    process.async(move(task_future.first));

    return move(task_future.second);
}

using namespace bcc;
```

# Continuations

- Recap
    - Callbacks
        - Must be known in advance
        - Require functional form transformations
    - C++11 futures
        - Do not compose
        - Block on `get()`

<!-- #region slideshow={"slide_type": "slide"} -->
- Continuations combine the best features<sup>*</sup> of these two approaches for returning a value from a task
    - Do not need to be known in advance
    - Do not require functional transformations
    - Compose
    - Do not block
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
- Continuations are part of futures in the [concurrency TS](http://en.cppreference.com/w/cpp/experimental/concurrency) in `<experimental/future>`
    - For this class I'm using [`stlab::future<>`](http://stlab.cc/libraries/concurrency/future/future/) which has additional capabilities and minor differences in syntax
    - I'm participating in a standard committee workshop on April 26th to discuss the future of futures in C++20
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
- A continuation is a callback attached to a `future`, using [`.then()`](http://stlab.cc/libraries/concurrency/future/future/then.html)
    - `.then()` returns a new future that can be used for more continuations
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
{
auto p = async(default_executor, []{ return 42; });

auto q = p.then([](int x){ cout << x << endl; });

auto r = q.then([]{ cout << "done!" << endl; });

blocking_get(r); // <-- DON'T DO THIS IN REAL CODE!!!
}
```

<!-- #region slideshow={"slide_type": "slide"} -->
- Recall our interned string implementation with futures
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
namespace bcc {

struct shared_pool {
    unordered_set<string> _pool;
    sequential_process _process;

    auto insert(string) -> stlab::future<const string*>;
};

auto shared_pool::insert(string a) -> stlab::future<const string*> {
    return async_packaged(_process, [this, _a = move(a)]() mutable {
        return &*_pool.insert(move(_a)).first;
    });
}

}
```

<!-- #region run_control={"marked": true} slideshow={"slide_type": "slide"} -->
```cpp
class interned_string {
    // struct shared_pool

    static auto pool() -> shared_pool& {
        static shared_pool result;
        return result;
    }

    shared_future<const std::string*> _string;
public:
    interned_string(string a) : _string(pool().insert(move(a))) {}

    auto str() const {
        return *_string.get(); // <---- BLOCKING!!!
    }
};
```
<!-- #endregion -->

```c++ slideshow={"slide_type": "slide"}
namespace {

class interned_string {
    // struct shared_pool

    static auto pool() -> shared_pool& {
        static shared_pool result;
        return result;
    }

    stlab::future<const string*> _string; // or std::experimental::shared_future
public:
    interned_string(string a) : _string(pool().insert(move(a))) {}

    auto str() const -> stlab::future<reference_wrapper<const string>> {
        return _string.then([](const string* p) { return cref(*p); });
    }
};

} // namespace
```

```c++ slideshow={"slide_type": "slide"}
{
interned_string s("Hello World!"s);

auto done = s.str().then([](const string& s){
    cout << s << '\n';
});

blocking_get(done);
}
```

<!-- #region slideshow={"slide_type": "slide"} -->
- Pros for continuations
    - Do not need to be known in advance
    - Do not require functional transformations
        - Straight forward transformation from synchronous to asynchronous code
    - Compose
    - Do not block
- Cons
    - Require more synchronization than callbacks
    - Execution context is ambiguous
        - _Immediate execution_ may happen either in the calling context or resolving context
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
- Multiple continuation can be attached to a single `future` (or `shared_future`)
    - This _splits_ execution
    - i.e.
        - "blur the document"
            - "then save the document"
            - "then rotate the document"
- A _join_ is accomplished using `when_all()`
<!-- #endregion -->

```c++ slideshow={"slide_type": "slide"}
{
auto p = async(default_executor, []{ return 42; });
auto q = async(default_executor, []{ return 5; });

auto done = when_all(default_executor, [](int x, int y){ cout << x + y << endl; }, p, q);

blocking_get(done);
}
```

<!-- #region slideshow={"slide_type": "slide"} -->
- Joins are non-blocking
    - Attach continuations to the arguments
    - Keep an atomic count of how many arguments are resolved
    - Execute continuation on last resolve
- Splits and Joins allow us to construct arbitrary dependency DAGs
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "fragment"} -->
- Continuations are a form of a sequential process
<!-- #endregion -->

```c++

```
