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
<div class="toc"><ul class="toc-item"><li><span><a href="#lambdas" data-toc-modified-id="lambdas-1"><span class="toc-item-num">1&nbsp;&nbsp;</span>lambdas</a></span><ul class="toc-item"><li><span><a href="#review---function-objects" data-toc-modified-id="review---function-objects-1.1"><span class="toc-item-num">1.1&nbsp;&nbsp;</span>review - function objects</a></span><ul class="toc-item"><li><span><a href="#anatomy-of-a-function-object" data-toc-modified-id="anatomy-of-a-function-object-1.1.1"><span class="toc-item-num">1.1.1&nbsp;&nbsp;</span>anatomy of a function object</a></span></li></ul></li><li><span><a href="#lambda-expression" data-toc-modified-id="lambda-expression-1.2"><span class="toc-item-num">1.2&nbsp;&nbsp;</span>lambda expression</a></span><ul class="toc-item"><li><span><a href="#anatomy-of-a-lambda-expression" data-toc-modified-id="anatomy-of-a-lambda-expression-1.2.1"><span class="toc-item-num">1.2.1&nbsp;&nbsp;</span>anatomy of a lambda expression</a></span></li><li><span><a href="#captures" data-toc-modified-id="captures-1.2.2"><span class="toc-item-num">1.2.2&nbsp;&nbsp;</span>captures</a></span></li><li><span><a href="#function-call-operator" data-toc-modified-id="function-call-operator-1.2.3"><span class="toc-item-num">1.2.3&nbsp;&nbsp;</span>function call operator</a></span></li><li><span><a href="#storing-lambdas" data-toc-modified-id="storing-lambdas-1.2.4"><span class="toc-item-num">1.2.4&nbsp;&nbsp;</span>storing lambdas</a></span><ul class="toc-item"><li><span><a href="#limitations-of-std::function" data-toc-modified-id="limitations-of-std::function-1.2.4.1"><span class="toc-item-num">1.2.4.1&nbsp;&nbsp;</span>limitations of std::function</a></span></li><li><span><a href="#limitations-of-lambdas" data-toc-modified-id="limitations-of-lambdas-1.2.4.2"><span class="toc-item-num">1.2.4.2&nbsp;&nbsp;</span>limitations of lambdas</a></span></li></ul></li></ul></li><li><span><a href="#recommendations" data-toc-modified-id="recommendations-1.3"><span class="toc-item-num">1.3&nbsp;&nbsp;</span>recommendations</a></span></li><li><span><a href="#homework" data-toc-modified-id="homework-1.4"><span class="toc-item-num">1.4&nbsp;&nbsp;</span>homework</a></span></li></ul></li></ul></div>
<!-- #endregion -->

```c++ slideshow={"slide_type": "skip"}
#include <iostream>

using namespace std;
```

<!-- #region slideshow={"slide_type": "slide"} -->
# lambdas

Lambda are a syntax to construct a _function object_.

## review - function objects

- Consider a simple `struct` or `class` with an `invoke` member function
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
struct add_n_simple {
    int _n;

    int invoke(int x) const { return _n + x; }
};
```

<!-- #region slideshow={"slide_type": "slide"} -->
- `add_n_simple` can be used as a function which adds `n` to any value passed to invoke
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
add_n_simple add_s{5};
cout << add_s.invoke(10) << "\n";
```

<!-- #region slideshow={"slide_type": "slide"} -->
- We can make invocation more natural by providing a user-defined function call operator, `operator()`, instead of `invoke`
- This is known as a _function object type_
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
struct add_n_function {
    int _n;

    int operator()(int x) const { return _n + x; }
};
```

<!-- #region slideshow={"slide_type": "fragment"} -->
- Invocation now uses function calling syntax
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
add_n_function add_f{5};
cout << add_f(10) << "\n";
```

<!-- #region slideshow={"slide_type": "slide"} -->
### anatomy of a function object

- _closure type_
```cpp
struct add_n_function {
```
- _captures_
```cpp
    int _n;
```
- _function call operator_
```cpp
    int operator()(int x) const { return _n + x; }
```
- _closure_
```cpp
add_n_function add_f{5};
```
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
## lambda expression

- A lambda expression is a prvalue, _closure_, of a unique unnamed class type, the _closure type_
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
{

auto add_n_lambda = [_n = 5](int x) -> int { return _n + x; };
cout << add_n_lambda(10) << "\n";

}
```

<!-- #region slideshow={"slide_type": "slide"} -->
### anatomy of a lambda expression

- _closure type_
```cpp
    decltype(add_n_lambda)
```
- _captures_
```cpp
    [_n = 5]
```
- _function call operator_
```cpp
    (int x) -> int { return _n + x; }
```
- _closure_
```cpp
    add_n_lambda
```
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
- The argument list and result type are optional
    - missing return type is `auto` (not `void`)
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
{

int n = 42;
auto return_n = [n]{ return n; };
cout << return_n() << '\n';

}
```

<!-- #region slideshow={"slide_type": "slide"} -->
### captures

- capture types are deduced
- `[]` no capture, convertible to function pointer
- `[=]` capture-default any referenced local variable by value (copy)
- `[&]` capture-default any referenced local variable by reference
- `[x]` captures x by value
- `[&x]` captures x by reference
- `[_x = expression]` capture `_x` as the value of expression
- `[=, &x, _x = expression]` defaults can be mixed with other captures


- captured values are fixed when lambda is created, not at invocation
<!-- #endregion -->

```c++ slideshow={"slide_type": "slide"}
{
int x = 10;
int y = 20;
auto ex1 = [=]{ return x + y; };
auto ex2 = [&]{ x *= y; };
auto ex3 = [x, y]{ return x + y; };
auto ex4 = [x, &y]{ y += x; };
auto ex5 = [_x = ex1()]{ return _x; };

cout << ex1() << '\n';
ex2();
cout << ex3() << '\n';
ex4();
cout << ex5() << '\n';
cout << "x:" << x << '\n';
cout << "y:" << y << '\n';
}
```

<!-- #region slideshow={"slide_type": "slide"} -->
- `[this]` captures current object by reference
- `[*this]` captures current object by-value (C++17)
- `[args...]` capture pack expansion by value
- `[&args...]` capture pack expansion by reference
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
### function call operator

- Arguments can be declared `auto` to create a _generic lambda_
- Function can be declared mutable (default is const)
- Functions can be _variadic_ using `auto...`
- Function can be declared noexcept
<!-- #endregion -->

<!-- #raw slideshow={"slide_type": "slide"} -->
- Generic function object
<!-- #endraw -->

```c++
struct add_t {
    template <class T, class U>
    auto operator()(T x, U y) const {
        return x + y;
    }
};
```

```c++ slideshow={"slide_type": "fragment"}
{
    add_t add;

    cout << add(5, 10.3) << '\n';
}
```

<!-- #region slideshow={"slide_type": "slide"} -->
- Generic lambda
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
{
    auto add = [](auto x, auto y) { return x + y; };

    cout << add(5, 10.3) << '\n';
}
```

<!-- #region slideshow={"slide_type": "fragment"} -->
- `auto&&` is a forwarding-reference
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
- mutable function object
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
struct accumulate_t {
    int _value;

    int operator()(int x) {
        _value += x;
        return _value;
    }
};
```

```c++ slideshow={"slide_type": "fragment"}
{
accumulate_t accumulate{5};

cout << accumulate(10) << '\n';
cout << accumulate(3) << '\n';
}
```

<!-- #region slideshow={"slide_type": "slide"} -->
- mutable lambda
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
{

auto accumulate = [_value = 5](int x) mutable {
    _value += x;
    return _value;
};

cout << accumulate(10) << '\n';
cout << accumulate(3) << '\n';

}
```

<!-- #region slideshow={"slide_type": "slide"} -->
- variadic function object
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
struct print_all_t {
    template <class... Args>
    void operator()(const Args&... args) const {
        (void)initializer_list<int>{((cout << args << '\n'),0)...};
    }
};
```

```c++ slideshow={"slide_type": "fragment"}
{
    print_all_t print_all;

    print_all(1, 10.5, "Hello!");
}
```

<!-- #region slideshow={"slide_type": "slide"} -->
- variadic lambda
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
{
    auto print_all = [](const auto&... args) {
        (void)initializer_list<int>{((cout << args << '\n'), 0)...};
    };

    print_all(1, 10.5, "Hello!");
}
```

<!-- #region slideshow={"slide_type": "slide"} -->
### storing lambdas

- `std::function<>` can hold any callable object with a matching signature
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
struct lambda_member {
    size_t _count = 0;

    function<void(const string&)> _lambda = [_n = _count](const auto& x) {
        for(auto n = _n; n != 0; --n) cout << x << '\n';
    };
};
```

```c++ slideshow={"slide_type": "fragment"}
lambda_member object{4};

object._lambda("Hello");
```

<!-- #region slideshow={"slide_type": "slide"} -->
- you can assign a new lambda to a `function`
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
object._lambda = [](const auto& x) {
    cout << "I heard you the first time, " << x << '\n';
};

object._lambda("World!");
```

<!-- #region slideshow={"slide_type": "slide"} -->
#### limitations of std::function

- incurs virtual function call overhead and heap allocation for larger objects
- does not maintain generic or variatic lambdas
- does not support mutable lambdas
    - we will develop a solution for this later in the course
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
#### limitations of lambdas

- lambdas in C++14 can replace all use cases of std::bind(), except moving or forwarding a pack expansion
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
template <class F, class... Args>
auto bind_once(F&& f, Args&& ...args) {
    return bind([_f = forward<F>(f)](auto& ...args) mutable {
        return move(_f)(move(args)...);
    }, forward<Args>(args)...);
}

unique_ptr<int> sink(unique_ptr<int>&& x) { return move(x); }
```

```c++ slideshow={"slide_type": "fragment"}
auto bound = bind_once(sink, make_unique<int>(42));

cout << *bound() << '\n';
```

<!-- #region slideshow={"slide_type": "slide"} -->
- There is a proposal to [allow pack expansion in lambda init-capture](http://www.open-std.org/jtc1/sc22/wg21/docs/papers/2017/p0780r1.html)
- This would allow `bind_once()` to be expressed as:
```cpp
template <class F, class... Args>
auto bind_once(F&& f, Args&& ...args) {
    return [_f = forward<F>(f), _args = forward<Args>(args)...] () mutable {
        return move(_f)(move(_args)...);
    };
}
```
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
## recommendations

- Lambda expressions are syntactic sugar - don't let them frighten you
- Naming things, in general, is good. Don't start turning everything into an unnamed type
- Lambdas are useful when
    - the function object would not be reused elsewhere
    - the lambda expression is short
    - the lambda expression is bound to, and executed within, the current context (reference captures)
    - the lambda expression represents a _continuation_ of the current function in a different execution context

<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
## homework

- Find a place in your current project for a function is passed to and standard algorithm or container
    - If your current project doesn't use standard algorithms, find a place to use one!
- Replace it with a lambda expression
- Report the example and your thoughts on the [wiki](git.corp.adobe.com/better-code/class/wiki)

- An example...
```cpp
// Find first position, p, in v, where *p < x
auto p = find_if(begin(v), end(v), [&](const auto& a){ return a < x; });
```


<!-- #endregion -->
