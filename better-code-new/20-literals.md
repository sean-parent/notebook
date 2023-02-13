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
#include <algorithm>
#include <cctype>
#include <iomanip>
#include <iostream>
#include <string>
#include <string_view>

using namespace std;
```

<!-- #region slideshow={"slide_type": "slide"} -->
# Literals
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
## Review of C++ Literals
- integer literals
    - decimal (`1..9` prefix)
    - octal (`0` prefix)
    - hexadecimal (`0x` or `0X` prefix)
    - maybe unsigned or long (`u` or `U` and/or `l` or `L` suffix respectively)
- floating point literals
    - digits with decimal (`.`) and/or exponent (`e` or `E`)
    - maybe double (no suffix), float (`f` or `F` suffix), or long double (`l` or `L` suffix)
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
- character literals
    - `'c'` with `\` [escape sequences](http://en.cppreference.com/w/cpp/language/escape)
    - `L` prefix for `wchar_t`
    - `'many'` type int, implementation defined
    - Encoding is implementation defined
- string literals
    - `"string"` with `\` [escape sequences](http://en.cppreference.com/w/cpp/language/escape)
    - `L` prefix for `const wchar_t[]` (otherwise `const char[]`)
    - Encoding is implementation defined
    - `\0` terminated (but may contain `\0` characters)
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
## Recent Additions
- integer literals
    - binary (`0b` prefix)
    - long long ('ll' or 'LL' suffix)
    - digit separator (`'` inserted between any digits; i.e. `1'000'000`)
- floating point literals
    - hexadecimal (`0x` or `0X` prefix, requires exponent after `p` or `P`)
    - digit separator (`'` inserted between any digits; i.e. `1'000'000`)
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
- character literals
    - UTF-8 code point (`u8` prefix, must be Basic Latin code point)
    - UCS-2 character (`u` prefix, `char16_t`)
    - UCS-4 character (`U` prefix, `char32_t`)
    - `char16_t` and `char32_t` are keywords (not typedefs) and name unique types
- string literals
    - UTF-8, UCS-2, and UCS-4 string literals
    - Raw string literals (`R"<delimiter>(` `<anything>` `)<delimiter>"`)
- escape sequences
    - `\u` arbitrary Unicode 4 digit hex value
    - `\U` arbitrary Unicode 8 digit hex value
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
cout << u8"\U0001F680" << endl;
```

```c++ slideshow={"slide_type": "slide"}
ostream out(cout.rdbuf());
out << setfill('0') << hex;

for (auto c : u8"\U0001F680") {
    out << setw(2) <<  static_cast<int>(static_cast<uint8_t>(c)) << ' ';
}
```

```c++ slideshow={"slide_type": "slide"}
cout << u8R"json(

{
    "menu": {
        "id": 1,
        "value": "🚀"
    }
}

)json";
```

<!-- #region slideshow={"slide_type": "slide"} -->
## User-defined Literals
- Define a literal suffix operator (which must begin with `_` (others reserved by the standard library).
- Supports integer, floating point, character, and string literals
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
namespace bcc {

struct zstring {
    string_view _path;
    string_view _value;
};

// Workaround for non-cost string_view::find in libstdc++
constexpr size_t find(const string_view& view, char c) {
    size_t result = 0;
    for (auto f = begin(view), l = end(view); f != l; ++f, ++result) {
        if (*f == c) break;
    }
    return result;
}

constexpr zstring operator""_z(const char* p, size_t n) {
    string_view view(p, n);
    auto pos = find(view, '=');
    return { view.substr(0, pos), view.substr(pos + 1) };
}

} // namespace bcc
```

```c++ slideshow={"slide_type": "slide"}
{
    using namespace bcc;

    constexpr auto zstr = "bcc/greeting=Hello World!"_z;

    cout << zstr._path << endl;
    cout << zstr._value << endl;
}
```

```c++ slideshow={"slide_type": "slide"}
namespace bcc {

enum class layer_index: size_t {};

constexpr layer_index operator""_li(unsigned long long int n) {
    return static_cast<layer_index>(n);
}

} // namespace bcc
```

```c++ slideshow={"slide_type": "fragment"}
{
    using namespace bcc;

    constexpr auto id = 4_li;
}
```

<!-- #region slideshow={"slide_type": "slide"} -->
- The following argument lists are allowed:
    - `(unsigned long long int)` - integer literal (can be in any integer format)
    - `(long double)` - floating point literal
    - `(char)`, `(wchar_t)`, `(char16_t)`, or `(char32_t)` - character literals
    - `(const char*, size_t)` - string literal (`char` can be any character type)
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "fragment"} -->
- Plus one odd signature
    - `(const char*)` - NTBS for source integer or floating point literal
    - Useful for values exceeding the limits of the floating point or integer types
<!-- #endregion -->

```c++ slideshow={"slide_type": "slide"}
namespace bcc {
    void operator""_print(const char* p) {
        cout << p << endl;
    }
}
```

```c++ slideshow={"slide_type": "fragment"}
{
    using namespace bcc;

    3.14159265358979323846264338327950288419716939937510582097494459230781640628620899862803482534211706798214808651328230664709384460955058223172535940812848111745028410270193852110555964462294895493038196_print;
}

```

<!-- #region slideshow={"slide_type": "slide"} -->
- A user-defined literal does not need to be `constexpr`
    - But the arguments are guaranteed to be core constant expressions
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
- The following literals are defined by the standard:
<table>
    <tr>
        <td><p align="left">
            <code>if</code><br>
            <code>i</code><br>
            <code>il</code>
        </p></td>
        <td><p align="left">
            A <code>std::complex</code> literal representing pure imaginary number
        </p></td>
    </tr>
    <tr>
        <td><p align="left">
            <code>h</code><br>
            <code>min</code><br>
            <code>s</code><br>
            <code>ms</code><br>
            <code>us</code><br>
            <code>ns</code>
        </p></td>
        <td><p align="left">
            A <code>std::chrono::duration</code> literal
        </p></td>
    </tr>
    <tr>
        <td><p align="left">
            <code>s</code>
        </p></td>
        <td><p align="left">
            Converts a character array literal to <code>basic_string</code>
        </p></td>
    </tr>
    <tr>
        <td><p align="left">
            <code>sv</code>
        </p></td>
        <td><p align="left">
            Creates a string view of a character array literal (C++17)
        </p></td>
    </tr>
</table>
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
## Recommendations
- When using strings, get in the habit of specifying `u8` encoding
    - To interface with platform APIs and legacy code use `char16_t` or `char32_t` as approriate
- Use raw strings for data with caution
    - There is a severe penalty on iOS in terms of space for code binaries
        - code is encrypted (for copy protection) then compressed
        - data files are simply compressed

> The app binary listed below was 120.4 MB when you submitted it, but will be 166.7 MB once processed for the App Store. This exceeds the cellular network download size limit and would require your app to be downloaded over Wi-Fi:

> App Name: Adobe Photoshop Express
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
- Use user defined literals for _unit_ types ("of" types)
- Make user defined literals `constexpr` where possible
    - Exploit the fact that you _know_ the arguments to the literal operator are compile-time literals
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
## Homework
- Find a place to apply one of the recommendations in your code base
    - Discuss with your team to avoid overlapping work
- These are useful tools be relatively limited in their scope
<!-- #endregion -->

```c++

```
