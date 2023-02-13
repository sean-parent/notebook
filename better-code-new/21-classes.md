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
#include <string>
#include <iostream>
#include <tuple>

using namespace std;
```

<!-- #region slideshow={"slide_type": "slide"} -->
# Classes
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
## `final`
- `final` specifier can be used on a class to disallow derived classes
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
class base {
public:
    virtual void member() = 0;
};

class derived final : public base {
public:
    void member() override;
};
```

<!-- #region slideshow={"slide_type": "slide"} -->
```cpp
class error : public derived { };
```
---
```
input_line_9:1:15: error: base 'derived' is marked 'final'
class error : derived { };
              ^
input_line_8:6:8: note: 'derived' declared here
 class derived final : base {
       ^       ~~~~~
Interpreter Error:
```
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
- `final` specifier can also be used on a `virtual` function to specify further overrides are not permitted
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
class derived2 : public base {
    void member() final;
};
```

<!-- #region slideshow={"slide_type": "fragment"} -->
```cpp
class error : public derived2 {
    void member() override;
};
```
---
```
input_line_13:3:10: error: declaration of 'method' overrides a 'final' function
    void method() override;
         ^
input_line_11:2:10: note: overridden virtual function is here
    void method() final;
         ^
```
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
- `final` makes it clear to the reader that there are no derived classes or methods
- More importantly, `final` makes it clear to the compiler, allowing devirtualization optimizations
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
## `override`
- `override` ensures that the function overrides a virtual member function
    - Avoids potential mistakes and clarifies intent
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
class derived3 : public base {
    void member() const; // no error or warning
}
```

```c++ slideshow={"slide_type": "fragment"}
class derived4 : public base {
    virtual void member() const; // no error or warning
}
```

<!-- #region slideshow={"slide_type": "slide"} -->
```cpp
class derived5 : public base {
    void member() const override;
}
```
---
```
input_line_16:2:25: error: only virtual member functions can be marked 'override'
    void member() const override;
                        ^~~~~~~~
```
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
## Construction
- You can specify a default initializer for data members directly in the class definition
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
class example {
    int _a = 42;
    bool _b = false;
    string _c = "Hello World!";

public:
    friend inline ostream& operator<<(ostream& out, const example& x) {
       return out << "(" << x._a << ", " << x._b << ", " << x._c << ")";
    }
};
```

```c++ slideshow={"slide_type": "slide"}
{
example x;
cout << x << endl;
}
```

<!-- #region slideshow={"slide_type": "slide"} -->
- Any constructor can override a default initializer
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
class example2 {
    int _a = 42;
    bool _b = false;
    string _c = "Hello World!";

public:
    example2() = default;
    example2(int a) : _a(a) { }

    friend inline ostream& operator<<(ostream& out, const example2& x) {
       return out << "(" << x._a << ", " << x._b << ", " << x._c << ")";
    }
};
```

```c++ slideshow={"slide_type": "slide"}
{
    example2 x;
    cout << x << endl;
    example2 y(10);
    cout << y << endl;
}
```

<!-- #region slideshow={"slide_type": "slide"} -->
- Constructors can now delegate to other constructors
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
class example3 {
    int _a = 42;
    bool _b = false;
    string _c = "Hello World!";

public:
    example3(int a) : _a(a) { }
    example3(double a) : example3(static_cast<int>(round(a))) { }

    friend inline ostream& operator<<(ostream& out, const example3& x) {
       return out << "(" << x._a << ", " << x._b << ", " << x._c << ")";
    }
};
```

```c++ slideshow={"slide_type": "slide"}
{
    example3 x(42.8);
    cout << x << endl;
}
```

<!-- #region slideshow={"slide_type": "slide"} -->
- Constructors can now be inherited
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
class example4 : public example3 {
public:
    string _d = "New Member";

    using example3::example3;
};
```

```c++ slideshow={"slide_type": "fragment"}
{
    example4 x(42.8);
    cout << x << endl;
    cout << x._d << endl;
}
```

<!-- #region slideshow={"slide_type": "slide"} -->
- Inheriting constructors is "all or nothing"
    - However, you can replace an inherited constructor
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
class example5 : public example3 {
public:
    using example3::example3;
    example5(int a) : example3(a + 1) { }
};
```

```c++ slideshow={"slide_type": "fragment"}
{
    example5 x(10);
    cout << x << endl;
}
```

<!-- #region slideshow={"slide_type": "slide"} -->
- Or delete an inherited constructor
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
class example6 : public example3 {
public:
    using example3::example3;
    example6(int a) = delete;
};
```

<!-- #region slideshow={"slide_type": "fragment"} -->
```cpp
{
    example6 x(10);
    cout << x << endl;
}
```
---
```
input_line_27:3:14: error: call to deleted constructor of 'example6'
    example6 x(10);
             ^ ~~
input_line_26:4:5: note: 'example6' has been explicitly marked deleted here
    example6(int a) = delete;
    ^
```
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
## `static` member variables
### Review
- non-const static members must be defined at namespace scope
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
namespace bcc {

struct example7 {
    static int x; // declaration
};

int example7::x = 5; // definition (don't put in a header!)

}
```

<!-- #region slideshow={"slide_type": "slide"} -->
- `const static` members may be initialized directly in the class
    - No definition is required unless [odr-used](http://en.cppreference.com/w/cpp/language/definition#ODR-use)
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
struct example8 {
    const static int x = 42;
};

(void)(cout << example8::x << endl); // not an odr-use
```

<!-- #region slideshow={"slide_type": "slide"} -->
### New
- `static` members may be declared `inline` _(C++17)_ and `constexpr`
    - `inline static` members do not require a definition at namespace scope
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
struct example9 {
    inline static int x = 42;
};

example9::x = 56;
```

<!-- #region slideshow={"slide_type": "slide"} -->
- `constexpr static` members, like const static members, only require a namespace scope definition if odr-used _(until C++17)_
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
struct example10 {
    constexpr static int x = 42;
};

(void)(cout << example10::x << endl); // not an odr-use
```

<!-- #region slideshow={"slide_type": "slide"} -->
- Since C++17, `constexpr` implies `inline` for `static` member variables
    - No definition is required even for an ODR use
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
(void)(cout << &example10::x << endl); // an odr-use
```

<!-- #region slideshow={"slide_type": "slide"} -->
## Recommendations
- If you must use public inheritance
    - Use `final` and `override` as appropriate
- Use member initialization, delegating, and inheriting constructors to simplify class definitions
- Follow the recommendations for `static` variables for `static` member variables
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
## Homework
- Find code which does a cast to a derived class then makes virtual function calls
    - Mark the derived class as `final`
    - Inspect assembly before and after to see if the compiler is able to devirtualize the calls
<!-- #endregion -->

```c++

```
