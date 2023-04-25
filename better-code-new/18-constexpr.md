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
#include <array>

using namespace std;
```

<!-- #region slideshow={"slide_type": "slide"} -->
# `constexpr`
`constexpr` specifier declares that it is possible to evaluate a function or variable at compile time. Such variables and functions can then be used inside a [constant expression](http://en.cppreference.com/w/cpp/language/constant_expression).
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
## `constexpr` variables
A variable declared `constexpr` is `const` (implied) and must be evaluated at compile time.
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
const int r = rand();
```

<!-- #region slideshow={"slide_type": "fragment"} -->
```cpp
constexpr int r = rand();
```
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "fragment"} -->
```
input_line_9:2:16: error: constexpr variable 'r' must be initialized by a constant expression
 constexpr int r = rand();
               ^   ~~~~~~
input_line_9:2:20: note: non-constexpr function 'rand' cannot be used in a constant expression
 constexpr int r = rand();
                   ^
```
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
**Review:** `const` variables defined at `namespace` scope have [internal linkage](http://en.cppreference.com/w/cpp/language/language_linkage) by default. This allows them to be safely used in header files without an [ODR](http://en.cppreference.com/w/cpp/language/definition) violation. However, each compilation unit will have its own logical copy.
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->

```cpp
// header.hpp
constexpr int variable = 42;
```
---
```cpp
// code.cpp
#include "header.hpp"

const void* local_address() {
    return &variable;
}
```
---
```cpp
// main.cpp
#include "header.hpp"

const void* local_address();

int main() {
    cout << &variable << endl;
    cout << local_address() << endl;
};
```
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "fragment"} -->
```
0x10004b6c8
0x10004bd7c
```
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
C++17 adds [inline variables](http://en.cppreference.com/w/cpp/language/inline) which, at namespace scope, default to external linkage. This is what you likely want in your header files (_finally!_).
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->

```cpp
// header.hpp
inline constexpr int variable = 42;
```
---
```cpp
// code.cpp
#include "header.hpp"

const void* local_address() {
    return &variable;
}
```
---
```cpp
// main.cpp
#include "header.hpp"

const void* local_address();

int main() {
    cout << &variable << endl;
    cout << local_address() << endl;
};
```
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "fragment"} -->
```
0x10004b6c8
0x10004b6c8
```
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
## `constexpr` functions
A `constexpr` function is a function for which it is _possible_ to evaluate it at compile time provided appropriate function argument are provided.

A `constexpr` function must satisfy the following requirements:
* Not virtual
* [Literal](http://en.cppreference.com/w/cpp/concept/LiteralType) return type
* All arguments are literal types
* $\exists$ a set of arguments such that the function can be evaluated as a [core constant expression](http://en.cppreference.com/w/cpp/language/constant_expression#Core_constant_expressions).
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
* Function body contains **any statement except**
    * `asm`
    * `goto`
    * label (other than `case` and `default`)
    * `try` block
    * variable definition of non-literal type
    * static or thread-local variable
    * uninitialized variable
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
Example:
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
constexpr uint64_t fnv64_hash_str(const char* p) {
    uint64_t hash = UINT64_C(14695981039346656037);
    while (*p) {
        hash *= UINT64_C(1099511628211);
        hash ^= *p;
        ++p;
    }
    return hash;
}
```

```c++ slideshow={"slide_type": "fragment"}
constexpr auto str_hash = fnv64_hash_str("Hello World!");
```

```c++ slideshow={"slide_type": "fragment"}
cout << hex << str_hash << endl;
```

<!-- #region slideshow={"slide_type": "slide"} -->
## `constexpr` constructor
The definition of a literal type has been extended to include types with a `constexpr` constructor (though not all classes with a constexpr constructor are a literal type).

A `constexpr` constructor must satisfy the requirements of a `constexpr` function and:
* No virtual base classes
* Every base class subobject and every non-static data member must be initialized
* Every non-static member and base class initializer must be done with a `constexpr` constructor
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
Example:
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
struct point {
    int _width;
    int _height;

    constexpr point(int w, int h) : _width(w), _height(h) { }

    friend constexpr bool operator==(const point& a, const point& b) {
        return (a._width == b._width) && (a._height == b._height);
    }
};
```

```c++ slideshow={"slide_type": "fragment"}
constexpr point origin = { 10, 10 };
```

```c++ slideshow={"slide_type": "fragment"}
static_assert(origin == point(10, 10), "mismatch");
```

<!-- #region slideshow={"slide_type": "slide"} -->
`std::pair`, `std::tuple`, and `std::array` may all be used as literal types. With `constexpr` functions, you can create and manipulate complex data structures at compile time. These classes have been extended in C++17 to allow more operations, including non-const operations.
<!-- #endregion -->

```c++ slideshow={"slide_type": "skip"}
template <class T, size_t N>
struct carray {
    T _data[N];

    constexpr const T& operator[](size_t n) const { return _data[n]; }
    constexpr T& operator[](size_t n) { return _data[n]; }
};

template <class T, size_t N>
constexpr auto begin(const carray<T, N>& x) {
    return &x._data[0];
}

template <class T, size_t N>
constexpr auto end(const carray<T, N>& x) {
    return &x._data[0] + N;
}
```

```c++ slideshow={"slide_type": "slide"}
template <class T, size_t N, size_t M, class Comp>
constexpr auto merge(const array<T, N>& a, const array<T, M>& b, Comp comp) {
    array<T, N + M> result{0};
    size_t i = 0, j = 0, k = 0;
    while (j != N && k != M) {
        if (comp(a[j], b[k])) {
            result[i++] = a[j++];
        } else {
            result[i++] = b[k++];
        }
    }
    while (j != N) {
        result[i++] = a[j++];
    }
    while (k != M) {
        result[i++] = b[k++];
    }
    return result;
}
```

```c++ slideshow={"slide_type": "slide"}
constexpr bool strless(const char* a, const char* b) {
    while (*a && (*a == *b)) {
        ++a;
        ++b;
    }
    return static_cast<unsigned char>(*a) < static_cast<unsigned char>(*b);
}
```

```c++ slideshow={"slide_type": "slide"}
constexpr array<const char*, 3> a1 = {
    "Dave",
    "Nick",
    "Sean"
};

constexpr array<const char*, 4> a2 = {
    "Emily",
    "Olivia",
    "Ryan",
    "Seetha"
};
```

```c++ slideshow={"slide_type": "slide"}
constexpr auto result = merge(a1, a2, &strless);
```

```c++ slideshow={"slide_type": "fragment"}
for (const auto& e : result)
    cout << e << endl;
```

<!-- #region slideshow={"slide_type": "slide"} -->
## `if constexpr` (C++17)
A conditional of the form `if constexpr` is known as a _constexpr if_ statement. The predicate must be a constant expression. An unexecuted statement is discarded. If used in a template, the discarded path is not instanciated and _constexpr if_ is an alternative to [SFINAE](http://en.cppreference.com/w/cpp/language/sfinae) for some use cases.
<!-- #endregion -->

```c++ slideshow={"slide_type": "skip"}
template <class I, size_t N>
struct span {
    I _f;
};

template <class T, size_t N>
constexpr auto make_span(const T (&x)[N]) {
    return span<const T*, N>{begin(x)};
}

template <class I, size_t N>
constexpr auto begin(const span<I, N>& x) {
    return x._f;
}

template <class I, size_t N>
constexpr auto end(const span<I, N>& x) {
    return begin(x) + N;
}
```

```c++ slideshow={"slide_type": "slide"}
// C++14 example
namespace cpp14 {

template <class I, class Comp>
constexpr auto merge_sort(const span<I, 1>& a, Comp comp) {
    return array<typename iterator_traits<decltype(begin(a))>::value_type, 1>{*begin(a)};
}

template <class I, size_t N, class Comp>
constexpr auto merge_sort(const span<I, N>& a, Comp comp) {
    return merge(merge_sort(span<I, N / 2>{begin(a)}, comp),
                 merge_sort(span<I, N - N / 2>{begin(a) + N / 2}, comp), comp);
}

} // namespace cpp14
```

```c++ slideshow={"slide_type": "slide"}
// C++17 example

template <class I, size_t N, class Comp>
constexpr auto merge_sort(const span<I, N>& a, Comp comp) {
    if constexpr (N == 1)
        return array<typename iterator_traits<decltype(begin(a))>::value_type, 1>{
            *begin(a)
        };
    else
        return merge(merge_sort(span<I, N / 2>{begin(a)}, comp),
                     merge_sort(span<I, N - N / 2>{begin(a) + N / 2}, comp), comp);
}
```

```c++ slideshow={"slide_type": "slide"}
constexpr const char* names[]{
    "Carole",  "Cherelle", "Elene",   "Ahmad",    "Janae", "Stephenie", "Bill",
    "Joannie", "Taylor",   "Sharice", "Myrtle",   "Dara",  "Manuel",    "Hayley",
    "Odis",    "Otto",     "Goldie",  "Stepanie", "Nicky", "Ashley"};

constexpr auto sorted = merge_sort(make_span(names), strless);
```

```c++ slideshow={"slide_type": "fragment"}
for (const auto& e : sorted) cout << e << " ";
```

<!-- #region slideshow={"slide_type": "slide"} -->
## `constexpr` lambda expressions (C++17)
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
constexpr auto rsorted =
    merge_sort(make_span(names), [](auto a, auto b) { return strless(b, a); });
```

```c++ slideshow={"slide_type": "fragment"}
for (const auto& e : rsorted) cout << e << " ";
```

<!-- #region slideshow={"slide_type": "slide"} -->
## What should be declared `constexpr`?
The short answer is "[all the things](https://www.youtube.com/watch?v=PJwd4JLYJJY)."
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "fragment"} -->
If a function can be made constexpr, without adding a performance penalty then make it constexpr.
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "fragment"} -->
Be cautious about declaring variables that require complex calculations as `constexpr`.
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "fragment"} -->
Constructs like ZStrings and ExpressViews explicitly made a trade-off of runtime performance to improve developer productivity. Such gains are easily wiped out by doing too much at compile time.
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
### Exercise
Find something in your product that would be improved using `constexpr`, either by simplifying the code or by directly improving performance. Measure the results, including compile time impact, and write a summary of what you found.
<!-- #endregion -->
