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

<!-- #region slideshow={"slide_type": "skip"} toc=true -->
<h1>Table of Contents<span class="tocSkip"></span></h1>
<div class="toc" style="margin-top: 1em;"><ul class="toc-item"><li><span><a href="#Futures-(pt2)" data-toc-modified-id="Futures-(pt2)-1"><span class="toc-item-num">1&nbsp;&nbsp;</span>Futures (pt2)</a></span><ul class="toc-item"><li><span><a href="#Homework" data-toc-modified-id="Homework-1.1"><span class="toc-item-num">1.1&nbsp;&nbsp;</span>Homework</a></span></li></ul></li></ul></div>
<!-- #endregion -->

# Futures (pt2)

```c++ slideshow={"slide_type": "skip"}
#include <mutex>
#include <string>
#include <unordered_set>
#include <functional>
#include <future>
#include <condition_variable>
#include <deque>
#include <thread>
#include <iostream>

using namespace std;
```

```c++ slideshow={"slide_type": "slide"}
namespace bcc0 {

class task {
    // Need implementation here
public:
    task() = default;

    task(const task&) = delete;
    task(task&&) noexcept = default;

    task& operator=(const task&) = delete;
    task& operator=(task&&) noexcept = default;

    template <class F> // F model void()
    task(F f); // Need to implement

    void operator()(); // Need to implement
};

} // namespace bcc0
```

```c++ run_control={"marked": true} slideshow={"slide_type": "slide"}
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

```c++ slideshow={"slide_type": "slide"}
struct task::concept {
    virtual ~concept() {}
    virtual void invoke() = 0;
};
```

```c++ slideshow={"slide_type": "fragment"}
template <class F>
struct task::model final : concept {
    F _f;
    model(F f) : _f(move(f)) {}
    void invoke() override { _f(); }
};
```

```c++ slideshow={"slide_type": "slide"}
template <class F>
task::task(F f) : _self(make_unique<model<F>>(move(f))) { }
```

```c++ run_control={"marked": true} slideshow={"slide_type": "fragment"}
namespace bcc {

void task::operator()() { _self->invoke(); }

} // namespace bcc
```

<!-- #region slideshow={"slide_type": "fragment"} -->
```cpp
class sequential_process {
    // using task = function<void()>;

```
<!-- #endregion -->

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

template <class F> // F models R()
auto async_packaged(sequential_process& process, F&& f) {
    using result_t = std::result_of_t<std::decay_t<F>()>;

    packaged_task<result_t()> task{std::forward<F>(f)};
    auto result = task.get_future();

    process.async(move(task));

    return result;
}

} // namespace bcc

using namespace bcc;
```

<!-- #region slideshow={"slide_type": "slide"} -->
```cpp
{
sequential_process process;

auto future = async_packaged(process, []{ return "Hello World!"s; });

cout << future.get() << endl;
}
```
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
- You can only invoke `get()` on a future once
    - subsequent invocations will throw an exception!

```cpp
{
sequential_process process;

auto future = async_packaged(process, []{ return "Hello World!"s; });

cout << future.get() << endl;
cout << future.get() << endl; // Will throw!
}
```
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "fragment"} -->
- If you need to check the value multiple times
    - use `std::shared_future<>`
    - store the result in `std::optional<>` _(C++17)_
<!-- #endregion -->

```c++ slideshow={"slide_type": "slide"}
namespace v0 {

class interned_string {
    struct shared_pool {
        mutex _mutex;
        unordered_set<string> _pool;

        const string* insert(const string& a) {
            lock_guard<mutex> lock(_mutex);
            return &*_pool.insert(a).first;
        }
    };

    static auto pool() -> shared_pool& {
        static shared_pool result;
        return result;
    }

    const std::string* _string;

public:
    interned_string(const string& a) : _string(pool().insert(a)) {}
    const string& str() const { return *_string; }
};

} // namespace v0
```

```c++ slideshow={"slide_type": "slide"}
struct shared_pool {
    unordered_set<string> _pool;
    sequential_process _process;

    auto insert(string a) -> future<const string*> {
        return async_packaged(_process, [this, _a = move(a)]() mutable {
            return &*_pool.insert(move(_a)).first;
        });
    }
};
```

```c++ run_control={"marked": true} slideshow={"slide_type": "slide"}
namespace v1 {

class interned_string {
    // struct shared_pool

    static auto pool() -> shared_pool& {
        static shared_pool result;
        return result;
    }

    shared_future<const std::string*> _string;
public:
    interned_string(string a) : _string(pool().insert(move(a))) {}
    const string& str() const { return *_string.get(); }
};

} // namespace v1
```

<!-- #region slideshow={"slide_type": "slide"} -->
- `std::future<>` in C++11-17 is very limited
    - with no continuations they do not compose
        - there is no good way to extend `interned_string::str()` to return a future
    - the blocking behavior of `get()` means
        - we lose performance (Amdahl!)
        - inappropriate to use in a pooled scheduler
    - the _only call get once_ behavior makes them cumbersome and error prone
        - converting to a `shared_future` imposes additional costs

- Pros:
    - replace some common uses of condition variables
    - transformation from synchronous code to asynchronous code is simple
    - some parallelism is better than none
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
## Homework
- Read [Future Ruminations](http://sean-parent.stlab.cc/2017/07/10/future-ruminations.html)
<!-- #endregion -->
