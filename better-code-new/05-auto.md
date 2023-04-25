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
#include "../common.hpp"
#include <initializer_list>

using namespace std;
```

<!-- #region slideshow={"slide_type": "slide"} -->
# auto

- Prior to C++11, the keyword `auto` was a storage class specifier
    - But rarely used
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
void f() {
    auto int i = 42;
}
```

<!-- #region slideshow={"slide_type": "slide"} -->
## auto variable declarations

`auto` can be used in a variable declaration.

- `auto` alone will always deduce to an object type (not a reference, or const type)
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
const int& a = 42;
auto b = a;

print_type_name<decltype(a)>();
print_type_name<decltype(b)>();
```

<!-- #region slideshow={"slide_type": "slide"} -->
- cv-qualifiers and reference modifiers can be combined with auto
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
const auto c = b;
const auto& d = b;

print_type_name<decltype(c)>();
print_type_name<decltype(d)>();
```

<!-- #region slideshow={"slide_type": "slide"} -->
- `decltype(auto)` can be used to declare a variable which matches the expression type
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
decltype(auto) e = a;

print_type_name<decltype(e)>();
```

<!-- #region slideshow={"slide_type": "slide"} -->
- `auto&&` is a forwarding reference
- `decltype` is used with the `std::forward` template argument
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
namespace {

instrumented some_function() { return instrumented(); }
void some_sink(instrumented) { }

} // namespace
```

```c++ slideshow={"slide_type": "fragment"}
auto&& q = some_function();
some_sink(forward<decltype(q)>(q));
```

<!-- #region slideshow={"slide_type": "slide"} -->
## auto function results

C++11 added trailing return types. This allows a return type which is dependent on an argument type.
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
namespace {

int function_a();
auto function_b() -> int; // same signature as function_a

template <class T, class U>
auto add(T a, U b) -> decltype(a + b) {
    return a + b;
}

} // namespace
```

<!-- #region slideshow={"slide_type": "slide"} -->
- C++14 allows the return type to be omitted for `template` and `inline` functions.
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
inline auto mixed_add(unsigned a, signed b) {
    return a + b;
}

auto r = mixed_add(42, -1);
```

```c++ slideshow={"slide_type": "fragment"}
print_type_name<decltype(r)>();
cout << r << "\n";
```

<!-- #region slideshow={"slide_type": "slide"} -->
- Using `decltype(auto)` for the return type preserves references and cv-qualifiers
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
namespace {

vector<int> v = { 0, 1, 2, 3 };

inline decltype(auto) back() {
    return v.back();
}

} // namespace
```

```c++ slideshow={"slide_type": "fragment"}
type_name<decltype(back())>();
```

<!-- #region slideshow={"slide_type": "slide"} -->
## auto template parameters (C++17)

- C++17 adds auto template parameters.
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
namespace cpp14 {

template <class T, T N>
struct integral_constant {
      static constexpr T value = N;
};

using true_type = integral_constant<bool, true>;

}
```

<!-- #region slideshow={"slide_type": "slide"} -->
- In C++17 this can be implemented without specifying the type.

```cpp
template <auto N>
struct integral_constant {
      static constexpr decltype(N) value = N;
};

using true_type = integral_constant<true>;
```
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
## structured bindings (C++17)

- _structured bindings_ allow you to construct a set of objects from an array, tuple, _type like_, or class/struct public members

```cpp
auto [first_name, last_name] = make_pair("Jane"s, "Smith"s);
cout << last_name << ", " << first_name << '\n';
```
---
```
Smith, Jane
```
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
- simple handling of functions returning structures

```cpp
int a[] = { 0, 3, 4, 5, 5, 5, 6, 6, 7 };

for(auto [f, l] = equal_range(begin(a), end(a), 5); f != l; ++f) {
    cout << *f << '\n';
}
```
---
```
5
5
5
```
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
- deduction rules are different from other uses of `auto`
    - each element is deduced to `decltype(e)` where is the corresponding member

```cpp
int a = 1, b = 2;
auto [x, y] = tie(a, b);

x = 42;
cout << a << endl;
```
---
```
42
```
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "fragment"} -->
```cpp
print_type_name<decltype(x)>();
```
---
```
int&
```
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
- can use const and reference qualifiers with structured bindings

```cpp
int a = 1, b = 2;
const auto& [x, y] = tie(a, b);

a = 42;
cout << x << endl;
```
---
```
42
```
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
### limitations of structured bindings

- no way to ignore an element
- no way to reorder, or bind by name
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
## auto lambda arguments (covered in lambda section)
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
## Issue

### Qualify with references appropriately
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
vector<instrumented> w(5);
```

```c++ slideshow={"slide_type": "slide"}
for (auto e : w) {
    // do something
}
```

```c++ slideshow={"slide_type": "slide"}
for (const auto& e : w) {
    // do something
}
```

<!-- #region slideshow={"slide_type": "slide"} -->
## recommendations for auto variables

- Use auto where required
- Use auto where complex names do not add clarity
```cpp
for (typename vector<my_class>::const_iterator f = v.begin(), l = v.end;
     f != l; ++f) {
```
```cpp
for (auto f = v.begin(), l = v.end(); f != l; ++f) {
```
- `auto` can make code less brittle to small changes (like size of integral result)
- Use for structured binding (better than any alternative)


- Otherwise it becomes a matter of taste. Some people recommend using `auto` almost never, some people recommend using `auto` always. If it makes your code more clear, use it, otherwise do not, but avoid bikeshedding.
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
## recommendations for auto function results

- Use trailing result types except for `bool` and `void`
```cpp
auto some_function() -> some_type;
bool is_something();
void got_nothin();
```
    - code aligns better, and it is easier to read
    - avoids having trailing result types breaking the style when required
- Don't use auto results unless required, or naming the type adds nothing
```cpp
auto some_function() {
    //...
    return f(g(a + y)); // don't make me figure out this type!
}
```
    - Nearly every time I've omitted the result, I've regretted it
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
## homework

- Experiment with `auto` variables and trailing return types in your project
- Find some cases where you think it improves the code readability
- Find some cases where you think it hinders the code readability
- Write up examples of both on the [wiki](git.corp.adobe.com/better-code/class/wiki)
<!-- #endregion -->
