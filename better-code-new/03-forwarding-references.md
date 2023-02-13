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

using namespace std;
using namespace std::string_literals;
```

<!-- #region slideshow={"slide_type": "slide"} -->
# [Forwarding References](http://en.cppreference.com/w/cpp/language/reference)

- Pass by value for sink arguments can incur an unnecessary move
- Pass by value for a sink argument stored with assignment can incur extra overhead
- Pass by `const&` and `&&` can cause a combinatoric problem
- What if you don't know if the argument is a sink argument or not?
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
## Unnecessary Move
<!-- #endregion -->

```c++ slideshow={"slide_type": "-"}
class c_2 {
    instrumented _a;
    instrumented _b;
public:
    c_2(instrumented a, instrumented b) : _a(move(a)), _b(move(b)) { }
};

instrumented v_2;
c_2 v_3{v_2, instrumented()};
```

```c++ slideshow={"slide_type": "slide"}
namespace example_03 {

class type {
    instrumented _a;
    instrumented _b;
public:
    template <class T, class U>
    type(T&& a, U&& b) : _a(forward<T>(a)), _b(forward<U>(b)) { }
};

instrumented value;
type instance(value, instrumented());


} // namespace
```

<!-- #region slideshow={"slide_type": "slide"} -->
## Extra overhead

Copy followed by move assignment can be more expensive than copy assignment.
<!-- #endregion -->

```c++ slideshow={"slide_type": "slide"}
class c_4 {
    instrumented _a;
public:
    void set(instrumented a) {
        _a = move(a);
    }
};

instrumented v_5;
c_4 v_6;
v_6.set(v_5);
```

```c++ slideshow={"slide_type": "slide"}
class c_7 {
    instrumented _a;
public:
    template <class T>
    void set(T&& a) {
        _a = forward<T>(a);
    }
};

instrumented v_11;
c_7 v_12;
v_12.set(v_11);
```

<!-- #region slideshow={"slide_type": "slide"} -->
## Combinatorial Explosion
<!-- #endregion -->

```c++ slideshow={"slide_type": "-"}
class c_3 {
    instrumented _a;
    instrumented _b;
public:
    c_3(const instrumented& a, const instrumented& b) : _a(a), _b(b) { }
    c_3(instrumented&& a, const instrumented& b) : _a(move(a)), _b(b) { }
    c_3(const instrumented& a, instrumented&& b) : _a(a), _b(move(b)) { }
    c_3(instrumented&& a, instrumented&& b) : _a(move(a)), _b(move(b)) { }
};

c_3 v_4{v_2, instrumented()};
```

<!-- #region slideshow={"slide_type": "slide"} -->
## Unknown Sink
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "skip"} -->
_**Note:** The interactive C++ tool, cling, used to generate these notes, has a bug with declaring functions returning void. As a workaround I will use a lambda notation._

_Instead of:_
```cpp
void f(int x) { }
```

_I use:_
```cpp
auto f = [](int x){ };
```

_for the purpose of this section, these are equivalent._
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
template <class F, class T>
void wrapper_01(F f, T arg) {
    f(arg);
}
```

<!-- #region slideshow={"slide_type": "fragment"} -->
- If argument of `f` is not a sink and passed an lvalue, this will cause an unnecessary copy
- If argument of `f` is by reference, this will modify the temporary argument

---
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
template <class F, class T>
void wrapper_02(F f, const T& arg) {
    f(arg);
}
```

<!-- #region slideshow={"slide_type": "fragment"} -->
- If argument of `f` is a sink and passed an rvalue, this will cause an unnecessary copy
- If argument of `f` is by reference, this is an error

---
<!-- #endregion -->

```c++ slideshow={"slide_type": "slide"}
template <class F, class T>
void wrapper_03(F f, T& arg) {
    f(arg);
}
```

<!-- #region slideshow={"slide_type": "fragment"} -->
- Cannot be called with an rvalue

---
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
A [_forwarding reference_](http://en.cppreference.com/w/cpp/language/reference) is:

- function parameter of a function template declared as an rvalue reference to a cv-unqualified type template parameter of the same function template
- `auto&&` except when deduced from a brace-enclosed initializer list
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "fragment"} -->
- The syntax is the same as rvalue references, but they are not rvalue references
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "skip"} -->
```cpp
// T&& is a forwarding reference, not an rvalue reference
template <class F, class T>
void wrapper_04(F f, T&& arg) {
    f(forward<T>(arg)); // forward does the right thing
}

void f_01(instrumented){ }         // pass by value
void f_02(const instrumented&) { } // pass by const lvalue reference
void f_03(instrumented&) { }       // pass by lvalue reference
void f_04(instrumented&&) { }      // pass by rvalue reference
```
<!-- #endregion -->

```c++ slideshow={"slide_type": "slide"}
namespace {

// auto&& is a forwarding reference, not an rvalue reference
template <class F, class Arg>
void wrapper_04(F f, Arg&& arg) {
    f(std::forward<Arg>(arg));
};

void f_01(instrumented){ };         // pass by value
void f_02(const instrumented&) { }; // pass by const lvalue reference
void f_03(instrumented&) { };       // pass by lvalue reference
void f_04(instrumented&&) { };      // pass by rvalue reference

} // namespace
```

```c++ slideshow={"slide_type": "slide"}
instrumented v_03; // lvalue

wrapper_04(f_01, v_03);          // call with lvalue - copy
wrapper_04(f_01, instrumented());    // call with rvalue - move
wrapper_04(f_02, v_03);          // call with lvalue
wrapper_04(f_02, instrumented());    // call with rvalue
wrapper_04(f_03, v_03);          // call with lvalue
// wrapper_04(f_03, instrumented()); // call with rvalue - error
// wrapper_04(f_04, v_03);       // call with lvalue - error
wrapper_04(f_04, instrumented());    // call with rvalue
```

<!-- #region slideshow={"slide_type": "slide"} -->
## Confusing Syntax
These are rvalue references:
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
namespace {

void f_0(string&&); //rvalue reference

template <class T>
class c_0 {
public:
    c_0(T&&); // rvalue reference
};

} // namespace
```

<!-- #region slideshow={"slide_type": "slide"} -->
These are forwarding references:
<!-- #endregion -->

```c++ slideshow={"slide_type": "-"}
namespace {

template <class T>
void f_1(T&&); // forwarding reference

class c_1 {
public:
    template <class T>
    c_1(T&&); // forwarding reference
};

} // namespace
```

<!-- #region slideshow={"slide_type": "slide"} -->
The difference is one special deduction rule:
- If the function parameter, P, is a forwarding reference
- And the corresponding function call argument, A, is an lvalue
- Then lvalue reference to A is used in place of A for deduction
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
string v_0 = "Hello World!";
auto&& v_1 = v_0;
```

```c++ slideshow={"slide_type": "fragment"}
if (is_lvalue_reference<decltype(v_1)>::value) {
    cout << "v_1 is an lvalue reference!" << endl;
}
```

<!-- #region slideshow={"slide_type": "slide"} -->
## Should you use forwarding references for all sink arguments?

- Pros:
    - Eliminates one additional move operation in the copy case
    - Replace copy/move-assignment with copy-assignment

- Cons:
    - Copy-assignment is not always transactional
    - Requires template interface
        - Error messages reported from internal failures, not at API
    - Can push implementation into a header
    - Can capture unexpected types
        - Workaround be slower to compile (by an order of magnitude)
            - From [Eric Niebler](https://twitter.com/ericniebler/status/958490446107361280)
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
### Capturing too much
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
class c_5 {
    instrumented _a;
public:
    template <class T>
    c_5(T&& a) : _a(forward<T>(a)) { }
};

c_5 v_7{instrumented()};
```

<!-- #region slideshow={"slide_type": "slide"} -->
```cpp
c_5 v_8{v_7};
```
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "fragment"} -->
```
input_line_21:5:18: error: no matching constructor for initialization of 'annotate'
    c_5(T&& a) : _a(forward<T>(a)) { }
                 ^  ~~~~~~~~~~~~~
input_line_22:2:6: note: in instantiation of function template specialization 'c_5::c_5<c_5 &>' requested
      here
 c_5 v_8{v_7};
     ^
./../common.hpp:5:5: note: candidate constructor not viable: no known conversion from 'c_5' to
      'const annotate' for 1st argument
    instrumented(const instrumented&) { std::cout << "instrumented copy-ctor" << std...
    ^
./../common.hpp:6:5: note: candidate constructor not viable: no known conversion from 'c_5' to 'annotate'
      for 1st argument
    instrumented(instrumented&&) noexcept { std::cout << "instrumented move-ctor" <...
    ^
./../common.hpp:4:5: note: candidate constructor not viable: requires 0 arguments, but 1 was provided
    instrumented() { std::cout << "instrumented ctor" << std::endl; }
```
<!-- #endregion -->

```c++ slideshow={"slide_type": "slide"}
class c_6 {
    instrumented _a;
public:
    template <class T, class = enable_if_t<is_convertible<T, instrumented>::value>>
    c_6(T&& a) : _a(forward<T>(a)) { }
};

c_6 v_9{instrumented()};
c_6 v_10{v_9};
```

<!-- #region slideshow={"slide_type": "slide"} -->
## Summary Recommendations

- Use forwarding reference when you don't know the signature of the destination
- Prefer pass by value for sink arguments
    - Unless you know you need the additional performance
- Be aware of the difference between a forwarding reference and an rvalue reference
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
## Homework

- Apply one or more of the recommendations to code in your product
- Measure the results:
    - Runtime performance of an optimized build
    - (and/or) Binary size of an optimized build
    - (and/or) Compile time of a debug build
    - (and/or) Resulting source line count delta (indicator of readability)
- Report the results on the class wiki: [git.corp.adobe.com/better-code/class/wiki](git.corp.adobe.com/better-code/class/wiki)
<!-- #endregion -->

```c++

```
