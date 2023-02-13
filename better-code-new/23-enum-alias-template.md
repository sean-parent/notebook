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

using namespace std;
```

<!-- #region slideshow={"slide_type": "slide"} -->
## Recap - Parameter Pack Fold Expressions
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "fragment"} -->
- Jared Wyles posted in slack that he was starting to use structs with bools instead of bit flags
    - One reason is to allow the use of structured bindings
    - However, this quickly runs into a scaling issue
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
struct merge_layer_flags_t {
    bool use_interior_opacity = false;
    bool use_master_opacity = false;
    bool use_sheet_mask = false;
    bool use_user_mask = false;
    bool use_vector_mask = false;
    bool use_content_mask = false;
    bool use_source_ranges = false;
    bool use_destination_ranges = false;
    bool use_filter_mask = false;
};
```

```c++ slideshow={"slide_type": "slide"}
{
    merge_layer_flags_t flags;

    flags.use_user_mask = true;
    flags.use_content_mask = true;

    auto [io, mo, sm, um, vm, cm, sr, dr, fm] = flags;

    cout << io << ", " << mo << ", " << sm << ", " << um << ", " << vm << ", " << cm
         << ", " << sr << ", " << dr << ", " << fm << endl;
}
```

<!-- #region slideshow={"slide_type": "slide"} -->
- Could we use an `enum` and use structured bindings to unpack into `bool`s?
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
enum merge_layer_flags {
    use_interior_opacity = 1 << 0,
    use_master_opacity = 1 << 1,
    use_sheet_mask = 1 << 2,
    use_user_mask = 1 << 3,
    use_vector_mask = 1 << 4,
    use_content_mask = 1 << 5,
    use_source_ranges = 1 << 6,
    use_destination_ranges = 1 << 7,
    use_filter_mask = 1 << 8
};
```

```c++ slideshow={"slide_type": "slide"}
template <auto... I, class T>
constexpr auto extract_bits_a(T x) {
    return tuple{static_cast<bool>(x & I)...};
}
```

```c++ slideshow={"slide_type": "skip"}
// skip
cout << boolalpha;
```

```c++ slideshow={"slide_type": "fragment"}
{
    merge_layer_flags flags =
        static_cast<merge_layer_flags>(use_user_mask | use_content_mask);

    auto [vm, um, cm] =
        extract_bits_a<use_vector_mask, use_user_mask, use_content_mask>(flags);

    cout << vm << ", " << um << ", " << cm << endl;
}
```

<!-- #region slideshow={"slide_type": "slide"} -->
- This is potentially error prone
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
{
    auto [x] = extract_bits_a<3>(7);
    cout << x << endl;
}
```

<!-- #region slideshow={"slide_type": "slide"} -->
- Was the intent to extract the third bit?
    - Lower two bits?
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
- `ispow2()` is a C++20 function but we can implement it
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
template <class T>
constexpr bool ispow2(T x) {
    return (x != 0) && !(x & (x - 1));
}
```

```c++ slideshow={"slide_type": "fragment"}
ispow2(3)
```

```c++ slideshow={"slide_type": "fragment"}
ispow2(4)
```

<!-- #region slideshow={"slide_type": "slide"} -->
- Using a fold expression in a static assert, we can check for valid mask bits
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
template <auto... I, class T>
constexpr auto extract_bits(T x) {
    static_assert((ispow2(I) && ...));
    return tuple{static_cast<bool>(x & I)...};
}
```

<!-- #region slideshow={"slide_type": "slide"} -->
```cpp
{
    auto [x] = extract_bits<3>(7);
    cout << x << endl;
}
```
```
input_line_22:3:5: error: static_assert failed
    static_assert((ispow2(I) && ...));
    ^              ~~~~~~~~~~~~~~~~
input_line_25:3:16: note: in instantiation of function template specialization 'extract_bits<3, int>'
      requested here
    auto [x] = extract_bits<3>(7);
               ^
```
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
{
    auto [x] = extract_bits<4>(7);
    cout << x << endl;
}
```

<!-- #region slideshow={"slide_type": "slide"} -->
## Scoped enumerations and underlying types

- A scoped enumeration, `enum class` or `enum struct`, provides a strongly typed enumeration
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
enum class choice { none, some, all };
enum bad_choice { none, some, all };
```

<!-- #region slideshow={"slide_type": "slide"} -->
- An scoped enumeration defines it's own scope for names (similar to an `enum` declared within a class)
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
{
    auto pick = choice::some;
    auto bad_pick = some;
}
```

<!-- #region slideshow={"slide_type": "slide"} -->
- A scoped enumeration is not implicitly convertible to an integer
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "fragment"} -->
```cpp
{
    int bad_pick = some;
    int pick = choice::some;
}
```
```
input_line_30:4:9: error: cannot initialize a variable of type 'int' with an rvalue of type 'choice'
    int pick = choice::some;
        ^      ~~~~~~~~~~~~
```
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
- However, lack of implicit conversion can make bit fields difficult to use
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
enum class merge_layer {
    use_interior_opacity = 1 << 0,
    use_master_opacity = 1 << 1,
    use_sheet_mask = 1 << 2,
    use_user_mask = 1 << 3,
    use_vector_mask = 1 << 4,
    use_content_mask = 1 << 5,
    use_source_ranges = 1 << 6,
    use_destination_ranges = 1 << 7,
    use_filter_mask = 1 << 8
};
```

<!-- #region slideshow={"slide_type": "slide"} -->
```cpp
{
    auto flags = merge_layer::use_sheet_mask | merge_layer::use_vector_mask;
}
```
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "fragment"} -->
```
input_line_27:3:46: error: invalid operands to binary expression ('merge_layer' and 'merge_layer')
    auto flags = merge_layer::use_sheet_mask | merge_layer::use_vector_mask;
                 ~~~~~~~~~~~~~~~~~~~~~~~~~~~ ^ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/Users/sean-parent/miniconda3/envs/notebook/include/c++/v1/bitset:1059:1: note: candidate template ignored: could not match 'bitset<_Size>' against 'merge_layer'
operator|(const bitset<_Size>& __x, const bitset<_Size>& __y) _NOEXCEPT
^
/Users/sean-parent/miniconda3/envs/notebook/include/c++/v1/valarray:4049:1: note: candidate template ignored: substitution failure [with _Expr1 = merge_layer, _Expr2
      = merge_layer]: no type named 'value_type' in 'merge_layer'
operator|(const _Expr1& __x, const _Expr2& __y)
^
/Users/sean-parent/miniconda3/envs/notebook/include/c++/v1/valarray:4064:1: note: candidate template ignored: substitution failure [with _Expr = merge_layer]: no type
      named 'value_type' in 'merge_layer'
operator|(const _Expr& __x, const typename _Expr::value_type& __y)
^
/Users/sean-parent/miniconda3/envs/notebook/include/c++/v1/valarray:4080:1: note: candidate template ignored: substitution failure [with _Expr = merge_layer]: no type
      named 'value_type' in 'merge_layer'
operator|(const typename _Expr::value_type& __x, const _Expr& __y)
^
```
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
- `std::underlying_type_t<>` can be used to determine the type underlying any `enum` type
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
{
    using underlying = underlying_type_t<merge_layer>;

    auto flags = static_cast<merge_layer>(
        static_cast<underlying>(merge_layer::use_sheet_mask) |
        static_cast<underlying>(merge_layer::use_vector_mask));
}
```

<!-- #region slideshow={"slide_type": "slide"} -->
- Adobe source libraries contains `<adobe/enum_ops.hpp>` which allows you to enable bitwise ops
<!-- #endregion -->

```c++ slideshow={"slide_type": "skip"}
// skip
namespace {
merge_layer operator|(merge_layer a, merge_layer b) {
    using underlying = underlying_type_t<merge_layer>;

    return static_cast<merge_layer>(static_cast<underlying>(a) |
                                    static_cast<underlying>(b));
}

template <merge_layer... I>
constexpr auto extract_bits(merge_layer x) {
    using underlying = underlying_type_t<merge_layer>;
    return tuple{static_cast<bool>(static_cast<underlying>(x) & static_cast<underlying>(I))...};
}


} // namespace
```

```c++ slideshow={"slide_type": "fragment"}
auto stlab_enable_bitmask_enum(merge_layer) -> std::true_type;

{
    auto flags = merge_layer::use_sheet_mask | merge_layer::use_vector_mask;

    auto [x] = extract_bits<merge_layer::use_sheet_mask>(flags);
    cout << x << endl;
}
```

<!-- #region slideshow={"slide_type": "slide"} -->
- You can specify the underlying type for any `enum` type
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
enum class small_choice : std::int16_t {
    none, some, all
};
```

```c++ slideshow={"slide_type": "fragment"}
{
    cout << sizeof(small_choice) << endl;
}
```

```c++ slideshow={"slide_type": "slide"}
enum very_small : std::uint8_t {
    success, error
};
```

```c++ slideshow={"slide_type": "fragment"}
{
    cout << sizeof(very_small) << endl;
}
```

<!-- #region slideshow={"slide_type": "slide"} -->
- The underlying type of a scoped enumeration if not specified is `int`
- The underlying type of a unscoped enumeration if not specified is implementation defined
    - Large enough to hold all enumerator values
    - Not larger than `int` unless an enumerator value cannot fit into an `int`
    - If empty, treated as if it had a single enumerator with value `0`
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
### Recommendations
- Replace unscoped enumerations with scoped enumerations
    - Don't specify the underlying type without cause

- Use the `<adobe/enum_ops.hpp>` (which may become `<stlab/enum_ops.hpp>` soon) for
    - Types that represent a arithmetic type
    - Types that represent bit fields
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
### Homework
- Replace an unscoped enumeration with a scoped enumeration in your project
    - Did it improve the appearance of the code or clutter it?
    - Did it catch any errors?
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
## Type Aliases
- A _type alias_ is a new syntax for `typedef` declarations
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
namespace cpp98 {

typedef int some_type;

}
```

```c++ slideshow={"slide_type": "fragment"}
using some_type = int;
```

<!-- #region slideshow={"slide_type": "slide"} -->
- The new syntax makes complex aliases easier to read and write
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
namespace cpp98 {

typedef int (*some_func)(int);

}
```

```c++ slideshow={"slide_type": "fragment"}
using some_func = int (*)(int);
```

<!-- #region slideshow={"slide_type": "slide"} -->
- Unlike `typedef`, a type alias can be declared as a template
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
template <class T>
using func_ptr = T (*)(T);
```

```c++ slideshow={"slide_type": "fragment"}
{
    func_ptr<double> f = [](double x){ return x * x; };

    cout << f(10);
}
```

<!-- #region slideshow={"slide_type": "slide"} -->
- A template type alias is useful to define an alias to a dependent type
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
namespace cpp98 {

template <class I>
auto distance(I f, I l) -> typename iterator_traits<I>::difference_type;

}
```

```c++ slideshow={"slide_type": "fragment"}
template <class I>
using difference_t = typename iterator_traits<I>::difference_type;
```

```c++ slideshow={"slide_type": "fragment"}
template <class I>
auto distance(I f, I l) -> difference_t<I>;
```

<!-- #region slideshow={"slide_type": "slide"} -->
### Recommendations
- Prefer type aliases to typedefs
- Use template type aliases as type functions to simplify complex type expressions
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
### Homework
- Replace some typedefs in your project with type aliases
- Find an instance of `typename` used for a dependent type and replace it with template type alias
    - **Hint** use the regular expression `[^,<] typename` to find an instance
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
## Templates Variables
- C++14 added template variables
    - A non-const template variable will only have one instance across translation units
        - i.e. implicitly `inline`
    - However, a `const` (or `constexpr`) template variable is implicitly `static`, one instance per translation unit
        - But can be declared `inline`
<!-- #endregion -->

```c++ slideshow={"slide_type": "slide"}
namespace {

template <class T>
inline constexpr T max_value = std::numeric_limits<T>::max();

} // namespace
```

```c++ slideshow={"slide_type": "fragment"}
{
    auto x = max_value<int>;

    cout << x << endl;
}
```

<!-- #region slideshow={"slide_type": "slide"} -->
### Recommendations
- There are minor advantages to template variables over template static members and template functions
    - Use as needed (rarely)
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
### Homework
- None
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
## Extern Templates
- An explicit instantiation declaration of a template tell the compiler that an explicit instantiation definition exists in exactly one compilation unit
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
// header.hpp

namespace library {

template <class T>
class my_wizzy_type {
    void member_function();
    // ...
};

extern template class my_wizzy_type<int>;

} // namespace library
```

<!-- #region slideshow={"slide_type": "slide"} -->
```cpp
// code.cpp

#include "header.hpp"
```
<!-- #endregion -->

```c++ slideshow={"slide_type": "-"}
namespace library {

template <class T>
void my_wizzy_type<T>::member_function() {
    //...
}

template class my_wizzy_type<int>;

} // namespace library
```

<!-- #region slideshow={"slide_type": "slide"} -->
### Recommendations
- If you currently rely on hacks to force instantiation in a translation unit, at least use this as a supported mechanism
- Potentially useful for controlling instantiation for DLLs
    - But still prefer DLLs be avoided
- May speed compilation times and allow more separation of interface from implementation
    - Measure
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
### Homework
- None (unless you are currently doing this with a hack, in which case, fix it!)
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
## Variadic Macros
- C99 added variadic macros, picked up by C++ in C++11
    - `__VA_ARGS__` holds argument list
    - `__VA_OPT__(`<em>`content`</em>`)` can be used in the replacement (_C++20_)
        - If `__VA_ARGS__` is not empty `__VA_OPT__(`<em>`content`</em>`)` is replaced with _`content`_
        - Otherwise `__VA_OPT__(`<em>`content`</em>`)` expands to nothing
<!-- #endregion -->

```c++ slideshow={"slide_type": "slide"}
#define ARRAY(...) \
    int array[] = { __VA_ARGS__ }
```

```c++ slideshow={"slide_type": "fragment"}
{
    ARRAY(5, 3);
    for (const auto& e : array) cout << e << endl;
}
```

<!-- #region slideshow={"slide_type": "slide"} -->
- Stringizing `__VA_ARGS__` quotes the entire replacement
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
#define SHOW(...) \
    #__VA_ARGS__
```

```c++ slideshow={"slide_type": "fragment"}
SHOW(10, 42.5, x)
```

<!-- #region slideshow={"slide_type": "slide"} -->
### Recommendations
- Macros are still best avoided
    - File this in your bag of tricks...
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
### Homework
- None
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
## Another Detour
- After break we are going to spend a few (4?) courses on testing theory and writing unit tests
    - All white-box QE are invited and encouraged to attend
        - Black-box QE may also find it interesting
    - Very valuable for devs as well
- This section came about after reviewing several candidates results of a take-home project to write a unit test for `std::vector<>`
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
### Section Outline
- Why test?
- How is meaning ascribed to software?
    - Axioms and Equational Reasoning
- Design by Contract
- Concepts and models
- Quantifying, measuring, and testing performance
- Requirements of the Basic Interface
- What is not testable, and why
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "fragment"} -->
- My goal is everyone who attends (and does the homework) should be able to write an _A+_ unit test for `std::vector<>`
<!-- #endregion -->
