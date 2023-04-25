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
```

<!-- #region slideshow={"slide_type": "slide"} -->
# Review

- How to construct a test case
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
## Do your homework

- Identify _preconditions_ (what is expected)
     - Including implicit preconditions in the basic interface
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "fragment"} -->
- Example from documentation for `vector::back`
> Calling `back` on an empty container is undefined.
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
- If the API is a template, what are the requirements for the type arguments?
    - Including the axioms of any operations on the type
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "fragment"} -->
- Example from documentation for `vector`

> The requirements that are imposed on the elements depend on the actual operations performed on the container. Generally, it is required that element type meets the requirements of `Erasable`, but many member functions impose stricter requirements. This container (but not its members) can be instantiated with an incomplete element type if the allocator satisfies the allocator completeness requirements.
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "fragment"} -->
- From the general library requirements

> `X(a)` [copy construction], _Requires:_ `T` is `CopyInsertable` into `X`
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
- Identify _postconditions_ (what is guaranteed)
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "fragment"} -->
- From documentation for `vector`

> `a.back()`; _Operational semantics:_
```cpp
{ auto tmp = a.end(); --tmp; return *tmp; }
```
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "fragment"} -->
- From definition of _`CopyInsertable`_

> The value of `v` is unchanged and is equivalent to `*p`
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "fragment"} -->
- Note that postconditions can extend to affiliated objects

> After container move construction, references, pointers, and iterators (other than the end iterator) to `other` remain valid, but refer to elements that are now in `*this`.
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
- Identify _invariants_ (what always holds)
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "fragment"} -->
- Some may be implicit and follow from definition
    - `!(capacity() < size())`
    - `distance(begin(), end()) == size()`
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
- Have a basic mental model of the implementation
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
![](./img/vector-anatomy.svg)
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
## Design your tests
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "fragment"} -->
- Determine a representative set of values (and types)
    - Values must satisfy preconditions
    - Different operations may require different values
    - Include values that trigger an inflection in preconditions, postconditions, and implementation
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "fragment"} -->
- Tagging values is useful to identify known properties
    - Equality
    - Orderings
    - Concepts (Copyable vs. Movable)
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
- Execute with all meaningful combinations of representative values
    - include aliased values where allowed
    - and duplicate values

- Check postconditions, axioms, and invariants after API execution
- Use counters to test complexity and external failure points
- Use a model type with `static_assert` to test type requirements
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
## Anatomy of a test case for a template
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "fragment"} -->
- Create a `model` type which counts operations to measure complexity
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
struct {
    size_t _equality;
    size_t _ctor;
    size_t _move_ctor;
    size_t _copy_ctor;
    size_t _copy_assignment;
    size_t _move_assignment;
    size_t _dtor;
} _counters;
```

<!-- #region slideshow={"slide_type": "slide"} -->
- The `model` type is parameterized for the required operations
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
enum operations {
    moveable = 1 << 0,
    copyable = 1 << 1,
    equality_comparable = 1 << 2
};
```

<!-- #region slideshow={"slide_type": "slide"} -->
- The model tests for valid operation use
<!-- #endregion -->

```c++ run_control={"marked": false} slideshow={"slide_type": "slide"}
template <operations Ops>
struct model {
    int _value = 0; // 0 flags partially formed

    explicit model(int x) : _value(x) { ++_counters._ctor; }
    model(model&& x) noexcept : _value(x._value) {
        static_assert(Ops & moveable);
        x._value = 0;
        ++_counters._move_ctor;
    }
    model& operator=(model&& x) {
        static_assert(Ops & moveable);
        REQUIRE(x._value || !(x._value || _value));
        _value = x._value;
        x._value = 0;
        ++_counters._move_assignment;
        return *this;
    }
    //...
    static constexpr auto equality = [](const auto& a, const auto& b) {
        return a._value == b._value;
    };
};
```

<!-- #region slideshow={"slide_type": "slide"} -->
- Write a test for the class invariants
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
template <class C>
void test_invariants(const C& a) {
    REQUIRE(a.empty() == (a.begin() == a.end()));
    REQUIRE(distance(a.begin(), a.end()) == a.size());
    REQUIRE(!(a.capacity() < a.size()));
}
```

<!-- #region slideshow={"slide_type": "slide"} -->
- Write a test for each operation
    - Test invariants after a mutable operation
    - Test postconditions
    - Test complexity
<!-- #endregion -->

```c++ slideshow={"slide_type": "slide"}
template <class C, class I, class T>
void test_move_insert(
    const C& initial, const T& initial_value, C& container, I position, T value) {
    auto counters = _counters;
    bool has_capacity = container.size() < container.capacity();
    auto ip = begin(initial) + distance(begin(container), position);

    auto p = container.insert(position, move(value));
    // Test invariants
    test_invariants(container);
    // Test postconditions
    REQUIRE(equal(begin(initial), ip, begin(container), p, T::equality));
    REQUIRE(equal(ip, end(initial), next(p), end(container), T::equality));
    REQUIRE(T::equality(*p, initial_value));
    if (has_capacity) {
        REQUIRE(p == position);
    }
    // Test complexity
    auto move_count =
        (has_capacity ? distance(ip, end(initial)) : initial.size()) + 1;
    REQUIRE((_counters._move_ctor - counters._move_ctor) <= move_count);
}
```

<!-- #region slideshow={"slide_type": "slide"} -->
- Write a driver to construct cases which exercise inflection points
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "fragment"} -->
- A helper function to generate vectors from an array with a given capacity
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
template <class C, class T>
auto build_vector(const T& a, size_t capacity) {
    C r;
    r.reserve(capacity);
    for (auto& e : a)
        r.emplace_back(e);
    return r;
}
```

<!-- #region slideshow={"slide_type": "slide"} -->
- A driver to generate test cases and execute the test
<!-- #endregion -->

```c++ slideshow={"slide_type": "slide"}
void test_move_insert_driver() {
    using value_t = model<moveable>;
    constexpr int a[] = {1, 2, 3};

    auto v1 = build_vector<vector<value_t>>(a, size(a));
    size_t positions[] = {0, size(a) / 2, size(a)}; // begin, middle, end
    // insert each position without sufficient capacity
    for (const auto& e : positions) {
        auto v2 = build_vector<vector<value_t>>(a, size(a));
        test_move_insert(v1, value_t{4}, v2, begin(v2) + e, value_t{4});
    }
    // insert each position with sufficient capacity
    for (const auto& e : positions) {
        auto v2 = build_vector<vector<value_t>>(a, size(a) + 1);
        test_move_insert(v1, value_t{4}, v2, begin(v2) + e, value_t{4});
    }
    // insert into an empty vector
    {
        vector<value_t> v2;
        test_move_insert(vector<value_t>(), value_t{4}, v2, begin(v2), value_t{4});
    }
}
```

<!-- #region slideshow={"slide_type": "slide"} -->
- Execute the tests
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
test_move_insert_driver();
```

<!-- #region slideshow={"slide_type": "slide"} -->
## Creating general test cases

- For many operations and types you can write generic test case
    - copy, move, equality, comparisons
    - iterators, containers
    - numerics

- Refine how you manage tables of representative values so you can reuse the structure with different tables for different tests

- For a given type, you can write a single test for invariants and use it after each operation
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
## Designing a testable interface

- Write complete and _regular_ types
- When the semantics are the same, use the same name
- Keep class interfaces thin
    - Seek a minimal _efficient basis_
- Minimize dependencies
    - Try to write each piece of code as a stand alone library
    - Use template arguments, callbacks, and delegates to factor out dependencies
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
## Upcoming

- September 19th, Jared Wyles will guest lecture on clang-format and clang-tidy tools
- October 3rd, Lecture on Generic Programming
- October 17th, No class (I'll be at Pacific++ in Sydney)
- October 31st, Start Better Code section (finally!)
<!-- #endregion -->
