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
#include <iostream>
#include <string>
#include <tuple>
#include <future>

#include "../common.hpp"

using namespace std;
```

<!-- #region slideshow={"slide_type": "slide"} toc-hr-collapsed=false -->
# Tuples, Parameter Packs, & Initializer Lists
- `tuples`, parameter packs (variadic templates), and initializer lists are closely related
    - IMO, they should be the same thing
    - They each provide a distinct set of capabilities
    - Learn to use them in conjunction
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
## `tuple`
- `std::tuple` is a generalization of `std::pair`
    - `tuple` is a standard library component, implemented using parameter packs
    - `tuple` holds an arbitrary number of elements of arbitrary type (including none)
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
{
    tuple<> a; // empty
    tuple<int> b = 5;
    tuple<int, string> c = {5, "Hello World!"s};
    tuple<int, string, double> d = {5, "Hello World!"s, 42.5};
}
```

<!-- #region slideshow={"slide_type": "slide"} -->
- A tuple can be constructed from a set of arguments using `make_tuple`
    - Or using deduction guides (C++17)
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
{
    auto x = make_tuple(10, 3.0, "Hello World!"s);
}
```

```c++ slideshow={"slide_type": "fragment"}
{
    tuple x = {10, 3.0, "Hello World!"s}; // since C++17
}
```

<!-- #region slideshow={"slide_type": "slide"} -->
- `get<>()` is used to retrieve an element from a tuple
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
{
    tuple x = {10, 3.2, "Hello World!"s};
    cout << get<1>(x) << endl;
}
```

<!-- #region slideshow={"slide_type": "slide"} -->
- `tuple_element_t<>` is used to retrieve an element type from a tuple
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
{
    tuple x = { 10, 3.2, "Hello World!"s };
    cout << typeid(tuple_element_t<1, decltype(x)>).name() << endl;
}
```

<!-- #region slideshow={"slide_type": "slide"} -->
- `tuple_size_v<>` is used to get the number of elements in a tuple
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
{
    tuple x = { 10, 3.0, "Hello World!"s };
    cout << tuple_size_v<decltype(x)> << endl;
}
```

<!-- #region slideshow={"slide_type": "slide"} -->
- The `tie()` function creates a `tuple` of l-value references
    - A common use is to us `tie()` to extract the elements of a `tuple`
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
{
    int a;
    string b;

    tie(a, b) = tuple{10, "Hello World!"s};
    cout << a << ", " << b << endl;
}
```

<!-- #region slideshow={"slide_type": "slide"} -->
- You can use `ignore` with `tie()` to skip any elements
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
{
    string a;

    tie(ignore, a) = tuple{10, "Hello World!"s};
    cout << a << endl;
}
```

<!-- #region slideshow={"slide_type": "slide"} -->
- With C++17 you can use structured bindings to extract the elements
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
{
    auto [a, b] = tuple{10, "Hello World!"s};
    cout << a << ", " << b << endl;
}
```

<!-- #region slideshow={"slide_type": "fragment"} -->
- However, there is no `ignore` equivalent
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
- `tie()` is also useful for class reflection
    - `tuple` provides lexicographical comparisons
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
class example1 {
    int _a;
    string _b;
    bool _c;

    auto as_tuple() const { return tie(_a, _b, _c); }
public:
    example1(int a, string b, bool c) : _a(move(a)), _b(move(b)), _c(move(c)) { }

    friend inline bool operator==(const example1& x, const example1& y) {
        return x.as_tuple() == y.as_tuple();
    }
    friend inline bool operator<(const example1& x, const example1& y) {
        return x.as_tuple() < y.as_tuple();
    }
    //...
};
```

```c++ slideshow={"slide_type": "slide"}
{
    example1 x(10, "Hello", false);
    example1 y(10, "World", false);

    cout << boolalpha;
    cout << "x == x: " << (x == x) << endl;
    cout << "x == y: " << (x == y) << endl;
    cout << "x < y: " << (x < y) << endl;
    cout << "y < x: " << (y < x) << endl;
    cout << "x < x: " << (x < x) << endl;
}
```

<!-- #region slideshow={"slide_type": "slide"} -->
## Parameter Packs
- A type parameter pack is a template argument representing a sequence of types
- A function parameter pack is a set of function arguments matching a type parameter pack
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
template <class... Args> // Args is a type parameter pack
void example_fn1(Args... args); // Args... is a pack expansion
                                // args is a function parameter pack
```

<!-- #region slideshow={"slide_type": "slide"} -->
- Although one might think that `Args` would be a tuple type and `args` a tuple instance that is not the case
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "fragment"} -->
```cpp
template <class... Args>
void example_fn1(Args... args) {
    auto x = args;
}
```
---
```
input_line_26:3:14: error: initializer contains unexpanded parameter pack 'args'
    auto x = args;
             ^~~~
```
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
- In order to use a parameter pack, it must be _expanded_ with `...`
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
template <class... Args>
void example_fn2(Args... args) {
    tuple x = { args... }; // expand parameter pack into a tuple
}
```

<!-- #region slideshow={"slide_type": "slide"} -->
- The pack expansion is the equivalent of replacing it with a comma separated list `arg1, arg2, arg3, ...`
    - and can be used almost anyplace a comma separated list is allowed
- The expansion can also occur after a valid subexpression containing the parameter pack
    - In which case the subexpression is repeated
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
// A C++14 implementation of make_tuple()

template <class... Args>
auto make_tuple1(
    Args&&... args) { // type parameter pack expansion to forward references
    return tuple<decay_t<Args>...>(
        forward<Args>(args)...); // type and function parameter pack expansions
}
```

```c++ slideshow={"slide_type": "slide"}
{
auto [a, b, c] = make_tuple1(10, "Hello", false);
cout << a << ", " << b << ", " << c << endl;
}
```

<!-- #region slideshow={"slide_type": "slide"} -->
- C++17 adds _fold expressions_, this allows parameter packs to be expanded with an arbitrary binary function
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
template <class T, class... Args>
auto sum(T&& initial, Args&&... args) {
    return (forward<T>(initial) + ... + forward<Args>(args));
}
```

```c++ slideshow={"slide_type": "fragment"}
{
    cout << sum(1, 3, 5) << endl;
    cout << sum("Hello"s, " ", "Class!") << endl;
}
```

<!-- #region slideshow={"slide_type": "slide"} -->
- Non-type template parameter packs also work
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
template <int... Ns>
constexpr int sum() {
    return (... + Ns);
}
```

```c++ slideshow={"slide_type": "fragment"}
{
    cout << sum<1, 2, 3, 4>() << endl;
}
```

<!-- #region slideshow={"slide_type": "slide"} -->
- `auto...` can be used to create a function parameter pack in a lambda
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
{
    auto product = [](auto... args) { return (args * ...); };

    cout << product(1, 3, 5) << endl;
}
```

<!-- #region slideshow={"slide_type": "slide"} -->
- But you can't use _`type...`_ to get a non-type parameter pack
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "fragment"} -->
```cpp
{
    auto product = [](int... args){ return (args * ...); };
}
```
```
input_line_52:3:26: error: type 'int' of function parameter pack does not contain any unexpanded parameter
      packs
    auto product = [](int... args){ return (args * ...); };
```
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
- `sizeof...()` will tell you the number of elements in a parameter pack
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
template <class... Args>
size_t arg_count(const Args&... args) {
    return sizeof...(args);
}
```

```c++ slideshow={"slide_type": "fragment"}
{
    cout << arg_count(1, 32.5, "Hello") << endl;
}
```

<!-- #region slideshow={"slide_type": "slide"} -->
- `std::apply()` converts a tuple into arguments to a function
    - _C++17 but easily implemented in C++14_
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
{
    tuple x = { "Hello!"s, 3 };

    apply([](const string& str, int n){
        while (n-- != 0) cout << str << endl;
    }, x);
}
```

<!-- #region slideshow={"slide_type": "slide"} -->
- We can use `apply()` to convert a tuple into an argument pack
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
{
    tuple x = {1, 3, 5, 7, 9};

    cout << apply([](auto... args) { return (... + args); }, x) << endl;
}
```

<!-- #region slideshow={"slide_type": "slide"} -->
## `initializer_list<>`
- When a function takes an argument of type `std::initializer_list<>` it may be passed a list of elements of the same type
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
{
    auto product = [](initializer_list<int> args) {
        // should use reduce but not implemented in libstdc++
        // return (args * ...);
        return accumulate(begin(args), end(args), 1, multiplies());
    };

    cout << product({1, 3, 5}) << endl;
}
```

<!-- #region slideshow={"slide_type": "slide"} -->
- The intended use is to allow constructors for containers to behave as constructors for built in arrays
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
{
    vector v = {0, 10, 20, 30};

    for (const auto& e : v) cout << e << endl;
}
```

<!-- #region slideshow={"slide_type": "slide"} -->
- An `initializer_list<>` differs from a parameter pack in a few ways
    - The elements in an `initializer_list<>` can only be a single type
    - Even though the `initializer_list<>` is a temporary object, access to it is always via `const &`
        - It is not possible to move or forward from an `initializer_list<>`
    - Elements of an `initializer_list<>` are allowed to be stored in read-only memory
    - **The order the element expressions are evaluated in an `initializer_list<>` is defined to be left-to-right**
    - An `initializer_list<>` does not require a template interface
        - Can be used in a function prototype in a header
    - An `initializer_list<>` can be used with a range based for loop

- An `initializer_list` is not a library only feature, it is a language feature exposed through a library interface
<!-- #endregion -->

```c++ slideshow={"slide_type": "slide"}
{
    auto a = { "Hello"s, "World!"s }; // a is initializer_list<string>
    for (const auto& e : a) cout << e << endl;
}
```

<!-- #region slideshow={"slide_type": "fragment"} -->
```cpp
{
    auto a = { "Hello"s, 10 };
}
```
```
input_line_47:3:10: error: cannot deduce actual type for variable 'a' with type
'auto' from initializer list
    auto a = { "Hello"s, 10 };
         ^   ~~~~~~~~~~~~~~~~
```
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
## Combining the three building blocks
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
- By exploiting the fact that an initializer list evaluates in order we can iterate over a function parameter pack
    - Thanks to Eric Niebler for the suggestion
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
template <class F, class... Args>
constexpr F for_each_argument(F f, Args&&... args) {
    (void)std::initializer_list<int>{(f(std::forward<Args>(args)), 0)...};
    return f;
}
```

```c++ slideshow={"slide_type": "fragment"}
{
    for_each_argument([](const auto& e){
        cout << e << endl;
    }, 10, "Hello!", 35.2);
}
```

<!-- #region slideshow={"slide_type": "slide"} -->
- We can use `apply()` to convert a tuple to an argument list
    - Combined with `for_each_argument()` we can iterate over a tuple
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
namespace {

template <class F, class Tuple>
constexpr F for_each_element(F f, Tuple&& t) {
    return std::apply(
        [_f = std::move(f)](auto&&... args) {
            return for_each_argument(std::move(_f),
                                     std::forward<decltype(args)>(args)...);
        },
        std::forward<Tuple>(t));
}

} // namespace
```

```c++ slideshow={"slide_type": "slide"}
{
    for_each_element([](const auto& e){
        cout << e << endl;
    }, tuple(10, "Hello!"s, 35.2));
}
```

<!-- #region slideshow={"slide_type": "slide"} -->
- By using `tie()` to reflect a object members into a tuple, we can iterate the members of the object
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
namespace {

class example2 {
    int _a;
    string _b;
    bool _c;

    auto as_tuple() const { return tie(_a, _b, _c); }
public:
    example2(int a, string b, bool c) : _a(move(a)), _b(move(b)), _c(move(c)) { }

    friend inline ostream& operator<<(ostream& out, const example2& x) {
        for_each_element([&](const auto& e){
            out << boolalpha << e << endl;
        }, x.as_tuple());
        return out;
    }
};

} // namespace
```

```c++ slideshow={"slide_type": "slide"}
{
    example2 x(42, "Hello World", true);
    cout << x;
}
```

<!-- #region slideshow={"slide_type": "slide"} -->
- Recall our implementation of a polymorphic task
    - Using parameter packs we can write a task that takes any number of arguments and returns a value
<!-- #endregion -->

```c++ slideshow={"slide_type": "slide"}
namespace {

template <class>
class task;

template <class R, class... Args>
class task<R(Args...)> {
    struct concept;

    template <class F>
    struct model;

    unique_ptr<concept> _p;

public:
    constexpr task() noexcept = default;
    template <class F>
    task(F&& f) : _p(make_unique<model<decay_t<F>>>(forward<F>(f))) {}
    task(task&&) noexcept = default;
    task& operator=(task&&) noexcept = default;

    R operator()(Args... args) { return _p->invoke(forward<Args>(args)...); }
};

} // namespace
```

```c++ slideshow={"slide_type": "slide"}
namespace {

template <class R, class... Args>
struct task<R(Args...)>::concept {
    virtual ~concept() = default;
    virtual R invoke(Args&&...) = 0;
};

template <class R, class... Args>
template <class F>
struct task<R(Args...)>::model final : concept {
    template <class G>
    explicit model(G&& f) : _f(forward<G>(f)) {}
    R invoke(Args&&... args) override { return move(_f)(forward<Args>(args)...); }

    F _f;
};

} // namespace
```

```c++ slideshow={"slide_type": "slide"}
{
    task<string(int)> f;

    f = [_prefix = "Hello "s](int suffix) mutable {
        return move(_prefix) + to_string(suffix);
    };

    cout << f(5) << endl;
}
```

<!-- #region slideshow={"slide_type": "slide"} -->
- A function parameter pack can be captured in a lambda
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
template <class F, class... Args>
auto bind_all_1(F f, Args&&... args) {
    return [_f = move(f), args...] { _f(args...); };
}
```

```c++ slideshow={"slide_type": "fragment"}
{
    auto print =
        bind_all_1([](const string& a, const string& b) { cout << a << ", " << b; },
                   "Hello", "World!");

    print();
}
```

<!-- #region slideshow={"slide_type": "slide"} -->
- However, there is no way to _move_ or _forward_ a function parameter pack directly into a lambda capture
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
{
    auto print = bind_all_1([](const instrumented& a, const instrumented& b) {}, instrumented(),
                            instrumented());

    print();
}
```

<!-- #region slideshow={"slide_type": "slide"} -->
- but you can forward a function parameter pack using a tuple
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
template <class F, class... Args>
auto bind_all_2(F f, Args&&... args) {
    return
        [_f = move(f), _args = tuple{forward<Args>(args)...}] { apply(_f, _args); };
}
```

```c++ slideshow={"slide_type": "slide"}
{
    auto print = bind_all_2([](const instrumented& a, const instrumented& b) {}, instrumented(),
                            instrumented());

    print();
}
```

<!-- #region slideshow={"slide_type": "slide"} -->
## Recommendations
- Tuples, parameter packs, and initializer lists are powerful tools for generative code
- The ability to capture argument lists in tuples and expand back is useful for marshaling arguments
- `tie()` is a useful tool for compile time reflection
- Many use cases of function parameter packs are just to provide simple bindings
    - Because of the complexity of specifying the callable object in C++, a lambda is a better solution
    - e.g. `std::async(&f, a, b);` vs `std::async([=]{ f(a, b); });`
- Generally `initializer_list<>` is troublesome because it doesn't support move, only use when the type is known to be trivial
    - In practice, initialization with an `initializer_list<>` is rarely useful outside of a test case
- Don't use a `tuple` where a `struct` would be more clear
    - Especially true with C++17 structured bindings
- Proceed with caution...
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} toc-hr-collapsed=false -->
## Homework
- See if you can find a place in your project code that could be improved at the call site by using any of the above tools
    - How significant is the improvement?
    - How much complexity is required in the implementation to support it?
- Report on the homework wiki https://git.corp.adobe.com/better-code/class/wiki/Homework
<!-- #endregion -->
