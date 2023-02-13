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
## RValue References

- [_rvalue_](http://en.cppreference.com/w/cpp/language/value_category) (right hand value) is an unnamed temporary
- `T&&` is used to denote an [_rvalue reference_](http://en.cppreference.com/w/cpp/language/reference) a reference that can only bind to a temporary
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "fragment"} -->
```cpp
string str = "Hello"s;
string&& ref = str;
```
---
```cpp
input_line_10:3:10: error: rvalue reference to type 'basic_string<...>' cannot bind to lvalue of type 'basic_string<...>'
string&& ref = str;
         ^     ~~~
```
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
string&& ref = "Hello"s;
```

<!-- #region slideshow={"slide_type": "slide"} -->
- A temporary value is safe to _consume_
- Useful to avoid copies
- A constructor taking the class type by rvalue reference is known as a _move constructor_
    - Similar to a copy constructor but it consumes it's argument
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
class movable {
    int* _some_data;
public:
    movable(movable&& x) noexcept : _some_data{x._some_data} // consume x
    { x._some_data = nullptr; } // leave x destructible

    //...
};
```

<!-- #region slideshow={"slide_type": "slide"} -->
### Return Value Optimization
- _Return value optimization_ (RVO) or [_copy elision_](http://en.cppreference.com/w/cpp/language/copy_elision) avoids a copy (or move) on return by constructing the result in place
- RVO applies to _local named values_ and rvalue results
- Allowed optimziation since C++03, required by C++17
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
instrumented f() {
    instrumented x;
    return x;
}

instrumented y = f();
```

<!-- #region slideshow={"slide_type": "slide"} -->
- Arguments to functions are in the caller scope
- RVO applies to passing an argument by value
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
void g(instrumented x) { }
g(f());
```

<!-- #region slideshow={"slide_type": "slide"} -->
- RVO does not apply to returning value argument
- C++11 defines returning a value argument as a _move_ operation
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
instrumented h(instrumented x) {
    return x;
}

instrumented z = h(f());
```

<!-- #region slideshow={"slide_type": "slide"} -->
### Using RValue Refs and RVO to Avoid Copies
#### Make Classes Movable
- Provide a move constructor and move assignment operator
    - Compiler will provide them implicitely if
        - there are no user declared copy constructors, copy assignment operators, or destructors
        - all non-static data members and base classes are movable
    - To ensure you have them, declare them `= default`
    - Move constructor and move assignment should be declared `noexcept`
    - Post-condition of moved from object is _partially formed_ & can alias rhs for move assignment
    - Otherwise can assume no aliasing
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
Example:
<!-- #endregion -->

```c++ slideshow={"slide_type": "-"}
class example_01 {
    int* _data;
public:
    explicit example_01(int x) : _data(new int(x)) { }
    ~example_01() { delete _data; }

    example_01(const example_01&) = delete;
    example_01& operator=(const example_01&) = delete;

    example_01(example_01&& x) noexcept : _data(x._data) { x._data = nullptr; }
    example_01& operator=(example_01&& x) noexcept {
        delete _data;
        _data = x._data;
        x._data = nullptr;
        return *this;
    }

    explicit operator int () { return *_data; }
};
```

```c++ slideshow={"slide_type": "slide"}
class example_02 {
    unique_ptr<int> _data;
public:
    explicit example_02(int x) : _data(make_unique<int>(x)) { }
    // implicit dtor

    // implicit deleted copy-ctor and copy-assignment

    /*
        move-ctor and move-assignment would be provided by default, but declaring
        them ensures they are provided and correct.
    */
    example_02(example_02&&) noexcept = default;
    example_02& operator=(example_02&&) noexcept = default;

    explicit operator int () { return *_data; }
};
```

<!-- #region slideshow={"slide_type": "slide"} -->
#### The Self Swap Problem
What is the post condition of:
<!-- #endregion -->

```c++ slideshow={"slide_type": "-"}
string s = "Hello World!";
swap(s, s);
```

```c++ slideshow={"slide_type": "fragment"}
cout << s << endl;
```

<!-- #region slideshow={"slide_type": "slide"} -->
`std::swap()` is defined as:
```cpp
template <class T>
void swap(T& a, T& b) {
    T tmp = move(a);
    a = move(b); // if a and b alias, then b has been moved from
    b = move(tmp);
}
```
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
```cpp
    example_01& operator=(example_01&& x) noexcept {
        delete _data;
        _data = x._data;
        x._data = nullptr;
        return *this;
    }
```

Is this okay?
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
example_01 e1(42);
swap(e1, e1);
```

```c++ slideshow={"slide_type": "fragment"}
cout << static_cast<int>(e1) << endl;
```

<!-- #region slideshow={"slide_type": "notes"} -->
Class Break - resume here 2018-02-07
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
#### Use Return Values, Not Out Arguments

- Out-arguments defeat RVO
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
void output_01(instrumented& out) {
    instrumented tmp;
    // fill in tmp
    out = tmp;
}

instrumented a1;
output_01(a1);
```

```c++ slideshow={"slide_type": "slide"}
instrumented output_02() {
    instrumented tmp;
    // fill in tmp
    return tmp;
}

instrumented a2 = output_02();
```

<!-- #region slideshow={"slide_type": "slide"} -->
##### Further Reading

[Stop Using _Out_ Arguments](http://stlab.cc/tips/stop-using-out-arguments.html)
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
#### Pass _sink_ arguments by value and return, or swap or move into place

- A _sink argument_ is an argument whose value is returned or stored
- Most constructor arguments are sink arguments
- The argument to assignment is a sink argument
<!-- #endregion -->

```c++ slideshow={"slide_type": "slide"}
string append(string str, const char* suffix) {
    str += suffix;
    return str;
}
```

```c++ slideshow={"slide_type": "fragment"}
instrumented append(instrumented str) {
    // modify str
    return str;
}

auto str = append(instrumented());
```

```c++ slideshow={"slide_type": "slide"}
class example_03 {
    instrumented _member;
public:
    explicit example_03(instrumented data) : _member(move(data)) { }
};

example_03 e_03{instrumented()};
```

<!-- #region slideshow={"slide_type": "fragment"} -->
`std::move()` is a cast to an rvalue reference.
<!-- #endregion -->

```c++ slideshow={"slide_type": "slide"}
class example_04 {
    instrumented* _member;
public:
    example_04() : _member(new instrumented()) { }
    ~example_04() { delete _member; }

    example_04(const example_04& x) : _member(new instrumented(*x._member)) { }
    example_04(example_04&& x) : _member(x._member) { x._member = nullptr; }

    // this assignment handles both move and copy
    example_04& operator=(example_04 x) noexcept {
        delete _member;
        _member = x._member;
        x._member = nullptr;
        return *this; }
};
```

```c++ slideshow={"slide_type": "slide"}
example_04 e41;
example_04 e42;
```

```c++ slideshow={"slide_type": "fragment"}
e41 = e42; // copy
```

```c++ slideshow={"slide_type": "fragment"}
e41 = move(e42);
```

<!-- #region slideshow={"slide_type": "slide"} -->
##### Advantages to by-value assignment

- Single implementation for copy and move assignment
- Transactional (strong exception guarantee) for copy assignment
- Handles self-copy (and usually self-move in moved from case)

##### Disadvantages

- Potential, significant, performance loss on copy assignment
    - [Howard Hinnant - _Everything You Ever Wanted To Know About Move Semantics_](https://www.youtube.com/watch?v=vLinb2fgkHk)
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
#### Rvalue Member Functions

- `this` is a hidden argument to a member function
- `*this` may be an rvalue
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
class example_05 {
    instrumented _name;
public:
    const instrumented& name() const { return _name; }
};

auto name_01 = example_05().name();
```

```c++ slideshow={"slide_type": "slide"}
class example_06 {
    instrumented _name;
public:
    const instrumented& name() const& { return _name; }
    instrumented name() && { return move(_name); }
};

auto name_02 = example_06().name();
```

<!-- #region slideshow={"slide_type": "slide"} -->
#### Forward Declare Argument and Result Type

- You can use pointer or reference to an incomplete type in an interface
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "fragment"} -->
- You can also use an incomplete type as a value argument and result type
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
class example_07; // forward declaration

const example_07& function_01(const example_07&); // You know this works
```

```c++ slideshow={"slide_type": "fragment"}
example_07 function_02(example_07); // This works also!
```

<!-- #region slideshow={"slide_type": "slide"} -->
### Issue

- Assigning an expression to a temporary can impose a performance penalty
<!-- #endregion -->

```c++ slideshow={"slide_type": "skip"}
instrumented g1(instrumented x) { return x; }
instrumented x;
```

```c++ slideshow={"slide_type": "fragment"}
auto v1 = g1(f());
```

```c++ slideshow={"slide_type": "fragment"}
auto tmp2 = f();
auto v2 = g1(tmp2);
```

```c++ slideshow={"slide_type": "slide"}
auto tmp3 = f();
auto v3 = g1(move(tmp3));
```

<!-- #region slideshow={"slide_type": "slide"} -->
### Summary Recommendations

- Make classes movable
- Use return values, not out arguments
- Pass sink arguments by value and move into place or return
- Forward declare argument and result types
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
### Homework

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
