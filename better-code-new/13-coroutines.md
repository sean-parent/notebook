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
#include <memory>
#include <iostream>

using namespace std;
```

<!-- #region slideshow={"slide_type": "slide"} -->
# Coroutines
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "fragment"} -->
- A _coroutine_ in C++ refers to a stackless coroutine
    - Sometimes called a _resumable function_
    - Defined in the [_C++ Extensions for Coroutines_](http://www.open-std.org/jtc1/sc22/wg21/docs/papers/2018/n4736.pdf) Technical Specification
    - Approved for C++20
- Coroutines can halt execution
    - _yielding_ a value (or void)
    - or _awaiting_ a value (or event)
- Once halted, a coroutine can be resumed, or destructed
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
- Coroutine is any function which
    - is not `main()`
    - is not a constructor
    - is not destructor
    - result type is not `auto`
    - contains a `co_return` statement
    - a `co_await` expression
    - a range based for loop with `co_await`
    - a `co_yield` expression
    - does not contain variable arguments (parameter packs are allowed)
        - i.e. `printf(const char*, ...);` // not allowed
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
## Anatomy of a Coroutine
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
- A simple example

```cpp
generator my_coroutine() {
    int n = 0;
    while (true) {
        co_yield n++;
    }
}

int main() {
    generator x = my_coroutine();
    cout << x.get() << endl;
    cout << x.get() << endl;
    cout << x.get() << endl;
}
```
```
0
1
2
Program ended with exit code: 0
```
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
- A coroutine is a function object with multiple entry points
    - Manually written:
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
namespace v0 {

struct my_coroutine_t {
    // ...
};

} // namespace v0
```

<!-- #region slideshow={"slide_type": "slide"} -->
- Local variables and arguments are captured within the coroutine
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
namespace v1 {

struct my_coroutine_t {
    int n = 0;
    // ...
};

} // namespace v1
```

<!-- #region slideshow={"slide_type": "slide"} -->
- On construction, a coroutine may either be suspended or start executing
    - suspension is handled by setting a resume point and returning
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
namespace v2 {

struct my_coroutine_t {
    int n = 0;

    void (my_coroutine_t::*_resume)();

    my_coroutine_t() : _resume{&my_coroutine_t::state_01} {}

    void resume() { (this->*_resume)(); }

    void state_01(); //...
};

} // namespace v2
```

<!-- #region slideshow={"slide_type": "slide"} -->
- The resume location will execute to the first yield or await and then return
    - yielding is handled by setting a _promise_
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
namespace {

struct my_coroutine_t {
    int n = 0;

    void (my_coroutine_t::*_resume)();
    int _promise;

    my_coroutine_t() : _resume{&my_coroutine_t::state_01} {}

    void resume() { (this->*_resume)(); }

    void state_01() {
        _promise = n++;                      // co_yield n++
        _resume = &my_coroutine_t::state_01; // on resume, loop
    }
};

} // namespace v3
```

<!-- #region slideshow={"slide_type": "slide"} -->
- Calling a coroutine allocates and constructs the coroutine and returns an object constructed with the _coroutine handle_
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
namespace v3 {

using coroutine_handle = unique_ptr<my_coroutine_t>;

struct generator {
    coroutine_handle _handle;
    generator(coroutine_handle h) : _handle(move(h)) {}
    // ...
};

generator my_coroutine() { return generator(make_unique<my_coroutine_t>()); }

} // namespace v3
```

```c++ slideshow={"slide_type": "skip"}
namespace v4 {

using coroutine_handle = unique_ptr<my_coroutine_t>;

} // namespace v3
```

<!-- #region slideshow={"slide_type": "slide"} -->
- The coroutine result type can be used to drive the coroutine
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
namespace v4 {

struct generator {
    coroutine_handle _handle;
    generator(coroutine_handle h) : _handle(move(h)) {}

    int get() {
        _handle->resume();
        return _handle->_promise;
    }
};

} // namespace v3
```

```c++ slideshow={"slide_type": "skip"}
namespace v4 {

generator my_coroutine() { return generator(make_unique<my_coroutine_t>()); }

} // namespace v3
```

```c++ slideshow={"slide_type": "skip"}
using namespace v4;
```

<!-- #region slideshow={"slide_type": "slide"} -->
- Now we can use our coroutine
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
generator x = my_coroutine();
cout << x.get() << endl;
cout << x.get() << endl;
cout << x.get() << endl;
```

<!-- #region slideshow={"slide_type": "slide"} -->
- The `generator` type used for the C++TS version is declared as:
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "fragment"} -->
```
struct generator {
    struct promise_type;
    using handle = coroutine_handle<promise_type>;

    struct promise_type {
        int current_value;

        auto initial_suspend() { return suspend_always{}; }
        auto final_suspend() { return suspend_always{}; }

        void unhandled_exception() { terminate(); }
        void return_void() {}
        auto yield_value(int value) {
            current_value = value;
            return suspend_always{};
        }
        generator get_return_object() {
            return generator{handle::from_promise(*this)};
        }
    };
    handle _coro;

    generator(handle h) : _coro(h) {}
    generator(generator const&) = delete;
    generator(generator&& rhs) : _coro(rhs._coro) { rhs._coro = nullptr; }
    ~generator() {
        if (_coro) _coro.destroy();
    }

    int get() {
        _coro.resume();
        return _coro.promise().current_value;
    }
};
```
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
## Await
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "fragment"} -->
- Besides _yielding_ values a coroutine can also _await_ a value
    - a `co_await` expression will suspend the coroutine until resume is called after a value is available
    - phrased another way, an awaiting coroutine is a _continuation_
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
```cpp
future<void> do_it(future<int> x) {
    int result = co_await move(x);
    cout << result << endl;
    co_return;
}

auto done = do_it(async(default_executor, []{ return 42; }));
done.then([]{ cout << "done" << endl; });
```
```
42
done
```
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
- Using C++ coroutines without a library is cumbersome
    - They provide a tremendous amount of power for library writers
    - Coroutines have many applications
        - range algorithms
        - concurrency and tasking
        - generators and consumers
        - state machines
    - Lambdas can also be coroutines
    - The hope is that we have some good, basic, library constructs for C++20

<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
## Homework
- Rewrite _sequential_process_ as a coroutine
    - You may use C++TS coroutines
    - But it is probably simpler to code the coroutine by hand
    - Assume a single threaded system
        - Don't worry about syncronization
        - Bonus points for trying
    - Use std::future<> for task results
<!-- #endregion -->

```c++

```
