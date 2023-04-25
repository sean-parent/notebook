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
<div class="toc"><ul class="toc-item"><li><span><a href="#Futures" data-toc-modified-id="Futures-1"><span class="toc-item-num">1&nbsp;&nbsp;</span>Futures</a></span><ul class="toc-item"><li><span><a href="#Callbacks" data-toc-modified-id="Callbacks-1.1"><span class="toc-item-num">1.1&nbsp;&nbsp;</span>Callbacks</a></span></li><li><span><a href="#std::future&lt;&gt;" data-toc-modified-id="std::future<>-1.2"><span class="toc-item-num">1.2&nbsp;&nbsp;</span><code>std::future&lt;&gt;</code></a></span></li></ul></li></ul></div>
<!-- #endregion -->

```c++ slideshow={"slide_type": "skip"}
#include <condition_variable>
#include <deque>
#include <functional>
#include <future>
#include <iostream>
#include <mutex>
#include <string>
#include <thread>
#include <unordered_set>

using namespace std;
```

```c++ slideshow={"slide_type": "skip"}
namespace bcc {

class sequential_process {
    using task = function<void()>;

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

void sequential_process::async(task f) {
    {
        lock_guard<mutex> lock(_mutex);
        _queue.push_back(move(f));
    }
    _condition.notify_one();
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

} // namespace bcc

using namespace bcc;
```

<!-- #region slideshow={"slide_type": "notes"} -->
- Everything about parallelism and concurrency boils down to:
    - How to handle function results
    - How to decrease overhead of context switch
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
# Futures

- Homework from last class, rewrite `interned_string` as a sequential process
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

<!-- #region slideshow={"slide_type": "slide"} -->
- How do we return a value from a sequential process?
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "fragment"} -->
```cpp
struct shared_pool {
    unordered_set<string> _pool;
    sequential_process _process;

    const string* insert(const string& a) {
        _process.async([&, _a = a]{
            _pool.insert(a).first;
        });

        return ???;
    }
};
```
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
## Callbacks

- One common method is to pass a callback which is called with the result instead of returning it
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
struct shared_pool {
    unordered_set<string> _pool;
    sequential_process _process;

    template <class F> // F models void(const string*)
    void insert(string a, F&& f) {
        _process.async([this, _a = move(a), _f = forward<F>(f)]{
            _f(&*_pool.insert(_a).first);
        });
    }
};
```

<!-- #region slideshow={"slide_type": "slide"} -->
- But what do we pass to the callback when constructing our `interned_string`?
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "fragment"} -->
```cpp
class interned_string {
    // struct shared_pool

    static auto pool() -> shared_pool& {
        static shared_pool result;
        return result;
    }

    const std::string* _string;
public:
    interned_string(const string& a) : _string(pool().insert(a, ???)) {}
    const string& str() const { return *_string; }
};
```
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
- The construction of the `interned_string` becomes asynchronous...
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
namespace v1 {

class interned_string {
    // struct shared_pool

    static auto pool() -> shared_pool& {
        static shared_pool result;
        return result;
    }

    const std::string* _string;

    interned_string(const string* s) : _string(s) {}

public:
    template <class F> // F models void(interned_string)
    static void make(string a, F&& f) {
        pool().insert(move(a), [_f = forward<F>(f)](const string* s) {
            _f(interned_string(s));
        });
    }
    const string& str() const { return *_string; }
};

} // namespace v1
```

<!-- #region slideshow={"slide_type": "slide"} -->
- And so on...
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
{
    using namespace v1;

    interned_string::make(
        "Hello World"s, [](const interned_string& s) { cout << s.str() << endl; });

    this_thread::sleep_for(1s);
}
```

<!-- #region slideshow={"slide_type": "fragment"} -->
- To properly rejoin another serial context we need
    - A block call
    - Queue the result back to the serial context
    - A continuation
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
- Pros of callbacks:
    - Fast, no synchronization required
    - Easy to understand
- Cons
    - Requires code be transformed into functional form
    - You must know where a value is going before invocation
    - Challenging to make exception safe
    - Code is executed as part of the server context, slowing the server
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
## `std::future<>`

- `std::future<>` is a mechanism to separate a task result, from a task
    - After the task is executed, the task result is available from the `future`
    - If the task throws an exception, the exception is available from the `future`
- Most other languages call these "promises"
    - C++ uses `promise` for the sending side of a `future` which is associated with some task
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
```
{
packaged_task<int()> task([]{
    cout << "executing...\n";
    return 42;
});

future<int> result = task.get_future();

cout << "begin\n";

task(); // execute the task

cout << "answer: " << result.get() << '\n';
}
```
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
```cpp
{
packaged_task<int()> task([]{
    cout << "executing...\n";
    throw "failure"s;
    return 42;
});

future<int> result = task.get_future();

cout << "begin\n";

task(); // execute the task

try {
   cout << "answer: " << result.get() << '\n';
} catch (const string& error) {
    cout << "error: " << error << '\n';
}
}
```
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
- In C++14 there are 3 ways to optain a `future`
    - from `std::promise`
    - from `std::packaged_task`
    - from `std::async`
- `std::async` allows for a _launch policy_ which can be async, deferred, or either
    - `future` from `std::async` with `std::launch::async`
        - _wait_ on destruction until the future is ready
    - `future` from `std::async` with `std::launch::deferred`
        - _execute_ the task on a call to `future::get()`
        - _cancel_ the associated task, and free the resources on destruction
- Otherwise futures will
    - _wait_ on get
    - _detach_ on destruction
- There is no way to achieve the behaviors of a `future` returned from `async()` using a `promise`
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
- Recall the `sequential_process::async()`
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "fragment"} -->
```cpp
void sequential_process::async(task f);
```
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
- We can wrap the invocation of `async()` and pass a `packaged_task`
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
template <class F> // F models R()
auto async_packaged(sequential_process& process, F&& f) {
    using result_t = std::result_of_t<std::decay_t<F>()>;

    packaged_task<result_t()> task{std::forward<F>(f)};
    auto result = task.get_future();

    process.async(move(task));

    return result;
}
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

<!-- #region slideshow={"slide_type": "fragment"} -->
```
In file included from input_line_5:1:
In file included from /Users/sean-parent/miniconda3/envs/sean-parent-notebook/include/xeus/xinterpreter.hpp:12:
In file included from /Users/sean-parent/miniconda3/envs/sean-parent-notebook/include/c++/v1/functional:487:
/Users/sean-parent/miniconda3/envs/sean-parent-notebook/include/c++/v1/memory:2056:9: error: call to deleted constructor of 'std::__1::packaged_task<std::__1::basic_string<char> ()>'
      : __value_(_VSTD::forward<_Args>(_VSTD::get<_Indexes>(__args))...) {}
        ^        ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/Users/sean-parent/miniconda3/envs/sean-parent-notebook/include/c++/v1/memory:2151:9: note: in instantiation of function template specialization 'std::__1::__compressed_pair_elem<std::__1::packaged_task<std::__1::basic_string<char>
      ()>, 0, false>::__compressed_pair_elem<const std::__1::packaged_task<std::__1::basic_string<char> ()> &, 0>' requested here
      : _Base1(__pc, _VSTD::move(__first_args),
        ^
/Users/sean-parent/miniconda3/envs/sean-parent-notebook/include/c++/v1/functional:1501:11: note: in instantiation of function template specialization 'std::__1::__compressed_pair<std::__1::packaged_task<std::__1::basic_string<char> ()>,
      std::__1::allocator<std::__1::packaged_task<std::__1::basic_string<char> ()> > >::__compressed_pair<const
      std::__1::packaged_task<std::__1::basic_string<char> ()> &, std::__1::allocator<std::__1::packaged_task<std::__1::basic_string<char> ()>
      > &&>' requested here
        : __f_(piecewise_construct, _VSTD::forward_as_tuple(__f),
          ^
/Users/sean-parent/miniconda3/envs/sean-parent-notebook/include/c++/v1/functional:1528:26: note: in instantiation of member function 'std::__1::__function::__func<std::__1::packaged_task<std::__1::basic_string<char> ()>,
      std::__1::allocator<std::__1::packaged_task<std::__1::basic_string<char> ()> >, void ()>::__func' requested here
    ::new (__hold.get()) __func(__f_.first(), _Alloc(__a));
                         ^
/Users/sean-parent/miniconda3/envs/sean-parent-notebook/include/c++/v1/functional:1491:14: note: in instantiation of member function 'std::__1::__function::__func<std::__1::packaged_task<std::__1::basic_string<char> ()>,
      std::__1::allocator<std::__1::packaged_task<std::__1::basic_string<char> ()> >, void ()>::__clone' requested here
    explicit __func(_Fp&& __f)
             ^
/Users/sean-parent/miniconda3/envs/sean-parent-notebook/include/c++/v1/functional:1770:42: note: in instantiation of member function 'std::__1::__function::__func<std::__1::packaged_task<std::__1::basic_string<char> ()>,
      std::__1::allocator<std::__1::packaged_task<std::__1::basic_string<char> ()> >, void ()>::__func' requested here
            __f_ = ::new((void*)&__buf_) _FF(_VSTD::move(__f));
                                         ^
input_line_13:8:19: note: in instantiation of function template specialization 'std::__1::function<void
      ()>::function<std::__1::packaged_task<std::__1::basic_string<char> ()>, void>' requested here
    process.async(move(task));
                  ^
/Users/sean-parent/miniconda3/envs/sean-parent-notebook/include/c++/v1/future:2047:5: note: 'packaged_task' has been explicitly marked deleted here
    packaged_task(const packaged_task&) = delete;
    ^
In file included from input_line_5:1:
In file included from /Users/sean-parent/miniconda3/envs/sean-parent-notebook/include/xeus/xinterpreter.hpp:12:
In file included from /Users/sean-parent/miniconda3/envs/sean-parent-notebook/include/c++/v1/functional:487:
/Users/sean-parent/miniconda3/envs/sean-parent-notebook/include/c++/v1/memory:2151:9: error: no matching constructor for initialization of '__compressed_pair_elem<std::__1::packaged_task<std::__1::basic_string<char> ()>, 0>'
      : _Base1(__pc, _VSTD::move(__first_args),
        ^      ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/Users/sean-parent/miniconda3/envs/sean-parent-notebook/include/c++/v1/functional:1496:11: note: in instantiation of function template specialization 'std::__1::__compressed_pair<std::__1::packaged_task<std::__1::basic_string<char> ()>,
      std::__1::allocator<std::__1::packaged_task<std::__1::basic_string<char> ()> > >::__compressed_pair<const
      std::__1::packaged_task<std::__1::basic_string<char> ()> &, const
      std::__1::allocator<std::__1::packaged_task<std::__1::basic_string<char> ()> > &>' requested here
        : __f_(piecewise_construct, _VSTD::forward_as_tuple(__f),
          ^
/Users/sean-parent/miniconda3/envs/sean-parent-notebook/include/c++/v1/functional:1536:17: note: in instantiation of member function 'std::__1::__function::__func<std::__1::packaged_task<std::__1::basic_string<char> ()>,
      std::__1::allocator<std::__1::packaged_task<std::__1::basic_string<char> ()> >, void ()>::__func' requested here
    ::new (__p) __func(__f_.first(), __f_.second());
                ^
/Users/sean-parent/miniconda3/envs/sean-parent-notebook/include/c++/v1/functional:1491:14: note: in instantiation of member function 'std::__1::__function::__func<std::__1::packaged_task<std::__1::basic_string<char> ()>,
      std::__1::allocator<std::__1::packaged_task<std::__1::basic_string<char> ()> >, void ()>::__clone' requested here
    explicit __func(_Fp&& __f)
             ^
/Users/sean-parent/miniconda3/envs/sean-parent-notebook/include/c++/v1/functional:1770:42: note: in instantiation of member function 'std::__1::__function::__func<std::__1::packaged_task<std::__1::basic_string<char> ()>,
      std::__1::allocator<std::__1::packaged_task<std::__1::basic_string<char> ()> >, void ()>::__func' requested here
            __f_ = ::new((void*)&__buf_) _FF(_VSTD::move(__f));
                                         ^
input_line_13:8:19: note: in instantiation of function template specialization 'std::__1::function<void
      ()>::function<std::__1::packaged_task<std::__1::basic_string<char> ()>, void>' requested here
    process.async(move(task));
                  ^
/Users/sean-parent/miniconda3/envs/sean-parent-notebook/include/c++/v1/memory:2054:3: note: candidate template ignored: substitution failure [with _Args = <const std::__1::packaged_task<std::__1::basic_string<char> ()> &>, _Indexes =
      <0>]
  __compressed_pair_elem(piecewise_construct_t, tuple<_Args...> __args,
  ^
/Users/sean-parent/miniconda3/envs/sean-parent-notebook/include/c++/v1/memory:2049:3: note: candidate constructor template not viable: requires single argument '__u', but 3 arguments were provided
  __compressed_pair_elem(_Up&& __u)
  ^
/Users/sean-parent/miniconda3/envs/sean-parent-notebook/include/c++/v1/memory:2037:8: note: candidate constructor (the implicit copy constructor) not viable: requires 1 argument, but 3 were provided
struct __compressed_pair_elem {
       ^
/Users/sean-parent/miniconda3/envs/sean-parent-notebook/include/c++/v1/memory:2037:8: note: candidate constructor (the implicit move constructor) not viable: requires 1 argument, but 3 were provided
/Users/sean-parent/miniconda3/envs/sean-parent-notebook/include/c++/v1/memory:2043:13: note: candidate constructor not viable: requires 0 arguments, but 3 were provided
  constexpr __compressed_pair_elem() : __value_() {}
            ^
```
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
- The underlying issue is `function<>` (our task type) requires:
    - A _Copyable_ type
    - With a `const` function call operator

- `packaged_task<>` is
    - Not _Copyable_, only _Movable_
    - Has a mutable function call operator
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "fragment"} -->
- We need a type similar `std::function<>` but for movable types with a mutable call operator
    - For now we only need the signature `void()`
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "skip"} -->
[Part 2 - notebook](./11-futures-pt2.ipynb)
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
[Part 2](./11-futures-pt2.slides.html)
<!-- #endregion -->
