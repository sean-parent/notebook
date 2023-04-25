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

```c++ tags=[] slideshow={"slide_type": "skip"}
#include <future>
#include <iostream>
#include <deque>
#include <memory>
#include <string>

using namespace std;

{ cout << boolalpha; }
```

```c++ tags=[] run_control={"marked": true} slideshow={"slide_type": "skip"}
namespace bcc {

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

    std::unique_ptr<concept> _self;

public:
    task() = default;

    template <class F>
    task(F f) : _self(make_unique<model<F>>(move(f))) {}

    void operator()() { _self->invoke(); }
};

} // namespace bcc
```

```c++ slideshow={"slide_type": "skip"}
namespace bcc {

class sequential_process {
    mutex _mutex;
    condition_variable _condition;
    deque<task> _queue;
    bool _done = false;

    void run_loop() {
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

    thread _thread{[this] { run_loop(); }};

public:
    ~sequential_process() {
        {
            lock_guard<mutex> lock(_mutex);
            _done = true;
        }
        _condition.notify_one();
        _thread.join();
    }
    void async(task f) {
        {
            lock_guard<mutex> lock(_mutex);
            _queue.push_back(move(f));
        }
        _condition.notify_one();
    }
};

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
# Concurrent Code & Object Lifetimes
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "fragment"} -->
- Mutable, _conditionally thread safe_, objects may only be accessed from one execution context at a time
    - Such objects can be safely moved, or copied, between execution contexts
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "fragment"} -->
```cpp
{
    int x = 42;
    auto r = async([_x = x]() mutable { // copy object to new context
        _x += 5;
        return _x;
    });

    cout << x << endl;
    cout << r.get() << endl;
}
```
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
```cpp
{
    auto p = make_unique<int>(42);
    auto r = async([_p = move(p)]() mutable { // move object to new context
        *_p += 5;
        return move(_p);
    });

    cout << static_cast<bool>(p) << endl;
    cout << *r.get() << endl;
}
```
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
- `const` objects are assumed to be thread safe, and can safely be shared by more than one context
    - Care must be taken if you have _mutable_ members
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "fragment"} -->
```cpp
{
    auto p = make_shared<const string>("Hello World!");
    auto r = async([_p = p] { return _p; }); // share object between contexts

    cout << *p << endl;
    cout << *r.get() << endl;
}
```
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
- Futures allow us to associate a result with a particular task
    - Sometimes it is useful to have the result still owned by another context
    - `std::weak_ptr<>` is one way to track the lifetime without taking ownership
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
```cpp
{
    struct photoshop {
        shared_ptr<string> _document = make_shared<string>("best.jpg");

        sequential_process _process;
    } ps;

    weak_ptr<string> doc_token =
        async_packaged(ps._process, [&] { return weak_ptr<string>(ps._document); })
            .get();

    // ps._process.async([&]{ ps._document = make_shared<string>("better.png"); });

    ps._process.async([&] {
        if (auto p = doc_token.lock()) *p = "renamed.jpg";
    });

    ps._process.async([&] { cout << *ps._document << endl; });
}
```
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
```cpp
{
    struct photoshop {
        shared_ptr<string> _document = make_shared<string>("best.jpg");

        sequential_process _process;
    } ps;

    weak_ptr<string> doc_token =
        async_packaged(ps._process, [&] { return weak_ptr<string>(ps._document); })
            .get();

    ps._process.async([&] { ps._document = make_shared<string>("better.png"); });

    ps._process.async([&] {
        if (auto p = doc_token.lock()) *p = "renamed.jpg";
    });

    ps._process.async([&] { cout << *ps._document << endl; });
}
```
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
- `std::weak_ptr<>` also has the advantage that it will not create a retain loop
- Makes it more clear that the operation doesn't own the object
- `apollo` has a `track` library that can be used to track object lifetimes which are not owned by `std::shared_ptr<>`
- `apollo::track(T)` will return a weak pointer type when T is
    - `std::shared_ptr<>`
    - A pointer to an object derived from `std::enabled_shared_from_this<>`
    - An Objective C/C++ `__strong` pointer
    - A pointer to an object derived from `apollo::enable_track<>`
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "fragment"} -->
- Weak pointer type are also useful to avoid retain loops with delegates
<!-- #endregion -->

```c++

```
