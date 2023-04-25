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

<!-- #region slideshow={"slide_type": "skip"} toc=true -->
<h1>Table of Contents<span class="tocSkip"></span></h1>
<div class="toc" style="margin-top: 1em;"><ul class="toc-item"><li><span><a href="#Contracts" data-toc-modified-id="Contracts-1"><span class="toc-item-num">1&nbsp;&nbsp;</span>Contracts</a></span><ul class="toc-item"><li><span><a href="#History" data-toc-modified-id="History-1.1"><span class="toc-item-num">1.1&nbsp;&nbsp;</span>History</a></span></li><li><span><a href="#Preconditions" data-toc-modified-id="Preconditions-1.2"><span class="toc-item-num">1.2&nbsp;&nbsp;</span>Preconditions</a></span><ul class="toc-item"><li><span><a href="#Example--operator[]-and-at()" data-toc-modified-id="Example--operator[]-and-at()-1.2.1"><span class="toc-item-num">1.2.1&nbsp;&nbsp;</span>Example  <code>operator[]</code> and <code>at()</code></a></span></li><li><span><a href="#Basic-Interface-Preconditions" data-toc-modified-id="Basic-Interface-Preconditions-1.2.2"><span class="toc-item-num">1.2.2&nbsp;&nbsp;</span>Basic Interface Preconditions</a></span></li></ul></li><li><span><a href="#Postconditions" data-toc-modified-id="Postconditions-1.3"><span class="toc-item-num">1.3&nbsp;&nbsp;</span>Postconditions</a></span><ul class="toc-item"><li><span><a href="#Example-clear()" data-toc-modified-id="Example-clear()-1.3.1"><span class="toc-item-num">1.3.1&nbsp;&nbsp;</span>Example <code>clear()</code></a></span></li><li><span><a href="#Basic-Interface-Postconditions" data-toc-modified-id="Basic-Interface-Postconditions-1.3.2"><span class="toc-item-num">1.3.2&nbsp;&nbsp;</span>Basic Interface Postconditions</a></span><ul class="toc-item"><li><span><a href="#Lifetime-of-reference-results" data-toc-modified-id="Lifetime-of-reference-results-1.3.2.1"><span class="toc-item-num">1.3.2.1&nbsp;&nbsp;</span>Lifetime of reference results</a></span></li><li><span><a href="#Unsequenced-modification-and-conflicting-postconditions" data-toc-modified-id="Unsequenced-modification-and-conflicting-postconditions-1.3.2.2"><span class="toc-item-num">1.3.2.2&nbsp;&nbsp;</span>Unsequenced modification and conflicting postconditions</a></span></li><li><span><a href="#Exception-Guarantees" data-toc-modified-id="Exception-Guarantees-1.3.2.3"><span class="toc-item-num">1.3.2.3&nbsp;&nbsp;</span>Exception Guarantees</a></span></li></ul></li></ul></li><li><span><a href="#Invariants" data-toc-modified-id="Invariants-1.4"><span class="toc-item-num">1.4&nbsp;&nbsp;</span>Invariants</a></span></li><li><span><a href="#Security" data-toc-modified-id="Security-1.5"><span class="toc-item-num">1.5&nbsp;&nbsp;</span>Security</a></span></li></ul></li></ul></div>
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
# Contracts
## History

- _Design by contract_ comes from Bertrand Meyer's work on Eiffel
- Described in his book [Object-Oriented Software Construction](https://en.wikipedia.org/wiki/Object-Oriented_Software_Construction)
- The work builds on _Hoare logic_ and Dijkstra's _predicate transformer semantics_
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "fragment"} -->
- Hoare logic is also known as _Floyd-Hoare logic_, Floyd being Robert Floyd who was Jim&nbsp;King's advisor
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
- A contract describes:
    - Operation pre- and postconditions
    - Class invariants
        - Class invariants are postconditions common to all class operations
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "fragment"} -->
- A contract is a _Hoare triple_
    - Expectation (precondition)
    - Guarantee (postcondition)
    - Maintains (invariants)
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
## Preconditions
- The preconditions of a function are what the function expects
    - Violation of a precondition is undefined behavior
    - A precondition can not be tested
        - Instead we test within the domain of the precondition
    - _Some_ preconditions may be _asserted_ by the function
- It is not practical to assert all preconditions
    - Examples of preconditions which are impractical to test
        - A pair of pointers specify a valid range
        - A comparison function defines a strict-weak-ordering
- When writing test cases, consider the inflection cases for representative values
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
### Example  `operator[]` and `at()`
- `vector::operator[]` has _strong_ preconditions
    - If the index is out of range, behavior is undefined
    - You cannot test behavior for an out-of-range index
- `vector::at()` has _weaker_ preconditions
    - If the index is out of range it will throw `std::out_of_range`
    - The boundary between an index within the range and one outside is an inflection point

<!-- #endregion -->

```c++ slideshow={"slide_type": "slide"}
{
    vector<int> x{0, 1, 2};
    REQUIRE_THROWS_AS(x.at(2), std::out_of_range);
}
```

```c++ slideshow={"slide_type": "fragment"}
{
    vector<int> x{0, 1, 2};
    REQUIRE_THROWS_AS(x.at(3), std::out_of_range);
}
```

<!-- #region slideshow={"slide_type": "slide"} -->
> **Exercise 3.1**  Write a table with representative values and expected results and a test for indexing.
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
### Basic Interface Preconditions
- The _basic interface_ is the implicit contract which goes without saying
    - So much so that the standard doesn't fully specify the basic interface
- There are the obvious basic preconditions
    - You can't pass arbitrary memory cast to a particular type to a function
    - The heap can't be corrupt
    - There is sufficient stack space
- There are also aspects that are more subtle
<!-- #endregion -->

```c++ slideshow={"slide_type": "slide"}
{
    vector<int> x = { 0, 1, 2, 3 };
    cout << "size: " << x.size() << ", capacity: " << x.capacity() << endl;;
    x.push_back(x.back()); // OK?
    for (const auto& e : x) cout << e << " ";
}
```

<!-- #region slideshow={"slide_type": "fragment"} -->
- The signature for `vector::back()` is:
```cpp
T& back();
```
- The signature for `vector::push_back()` is:
```cpp
void push_back(const T&);
```
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
![](./img/vector-anatomy.svg)
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
The expected preconditions of a `const T&` argument to a function, which may alias a value being modified by the function, is:
- The argument is valid at the invocation
- It is the called functions responsibility to copy, if necessary, to avoid problems from aliasing
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "fragment"} -->
- This is a _weak_ precondition
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "fragment"} -->
- This is the same situation as _self assignment_
```cpp
a = a; // must be a no-op
```
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
> **Exercise 3.2**  Extend the assignment test to validate self assignment for representative values.
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
A `T&&` argument is more complex:
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
{
    vector<string> x = { "Hello", "World" };
    cout << "size: " << x.size() << ", capacity: " << x.capacity() << endl;;
    x.push_back(move(x.front())); // OK?
    for (const auto& e : x) cout << e << " ";
}
```

<!-- #region slideshow={"slide_type": "fragment"} -->
- The signature for the `vector::push_back()` overload in this case is:
```cpp
void push_back(T&&);
```
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "fragment"} -->
Should this work?
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
## Postconditions
- The postconditions of a function guarantees properties of the result
    - Postconditions can be tested
    - But you cannot test what is _not_ guaranteed
- When testing a function try to be sure you cover all of the post conditions
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
### Example `clear()`
- `vector::clear()` has the following postconditions:
    - removes all elements from the container
    - leaves `capacity()` unchanged
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
{
    vector<int> x = {0, 1, 2, 3};
    auto n = x.capacity();
    x.clear();
    REQUIRE(x.empty());
    REQUIRE(x.capacity() == n);
}
```

<!-- #region slideshow={"slide_type": "slide"} -->
> **Exercise 3.3**  Review the postconditions for your existing tests and make sure your tests are complete.
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
### Basic Interface Postconditions
- The _basic interface_ also includes post conditions

#### Lifetime of reference results
- A member function returning a reference to a _part_ of the object is valid until:
    - a mutating (non-const) member function call
        - Note, that a non-mutating call might not be declared `const`
        - i.e. `vector::begin()`
    - or, the end of the objects lifetime

<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
#### Unsequenced modification and conflicting postconditions
- A classic interview test:
    - What does this print:
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
{
    int i = 0;
    i += i++ + ++i;
    cout << i << endl;
}
```

<!-- #region slideshow={"slide_type": "slide"} -->
- The postconditions of move assignment for `vector` are:
    - The lhs is equal to the prior value of the rhs
    - references, pointers, and iterators to elements in the rhs remain valid
        - but refer to elements that are in lhs
    - The state of the rhs is "valid but unspecified"
        - but because of the above requirements, this _usually_ means "empty"
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
{
    vector<int> x = {0, 1, 2, 3};
    x = move(x);
    cout << x.size() << endl;
}
```

<!-- #region slideshow={"slide_type": "fragment"} -->
- The only state that could satisfy the documented postconditions for move assignment with self move are a no-op
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
- Compare to `unique_ptr`
    - move assignment is as if by calling `reset(r.release())`
    - this implies that a self move is `x.reset(x.release())`
        - which is a no-op
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
{
    auto x = make_unique<int>(42);
    x = move(x);
    cout << *x << endl;
}
```

<!-- #region slideshow={"slide_type": "slide"} -->
- The postconditions on moving a string are:
    - lhs contains the prior rhs value
    - rhs value is "valid but unspecified"
- Until C++17 the postcondition of self-move on a string was:
    - "the function has no effect"
- But this language was removed in C++17
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
{
    string x = "Hello";
    x = move(x);
    cout << x.size() << endl;
}
```

<!-- #region slideshow={"slide_type": "slide"} -->
- So should this case work from 1.2.2?
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
{
    vector<string> x = { "Hello", "World" };
    cout << "size: " << x.size() << ", capacity: " << x.capacity() << endl;;
    x.push_back(move(x.front())); // OK?
    for (const auto& e : x) cout << e << " ";
}
```

<!-- #region slideshow={"slide_type": "slide"} -->
- It is debatable
    - If it works, x.front() is "valid but unspecified"
    - For it to work may require moving a moved from object when `vector` is resized
    - It requires an additional move to hold the value during reallocation
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
- The _basic interface_ is only partially specified
    - aliased references are only discussed with regard to race conditions
    - unless otherwise specified, treat modifying the same object as an unsequenced modification
        - even if specified, be cautious, this is an area of change
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "fragment"} -->
- The issues of aliasing can often be side-stepped by passing sink arguments by value
- i.e. if the signature f `push_back()` was:

```cpp
void push_back(T);
```
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "fragment"} -->
One argument is that for the basic interface, passing arguments by rvalue and lvalue references should be viewed as an optimization of passing by value and should not change behavior.
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "fragment"} -->
But that has performance implications.
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
#### Exception Guarantees

- The exception guarantees are part of the basic interface
- They describe the postconditions of a function in the event of an exception
    - There are 4 levels, from strong to weak
    - `noexcept`: Will not throw an exception
    - strong: Any modified state is returned to its prior, logical state
    - basic: All modified objects are left in a "valid but unspecified" state
    - weak: Result is undefined
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
- Unless otherwise specified, the basic guarantee is assumed
- In the absence of a modification, the _basic_ and _strong_ exception guarantees are the same.
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "fragment"} -->
- For example:
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
{
    vector<int> x{0, 1, 2};
    auto copy = x;
    REQUIRE_THROWS_AS(x.at(3), std::out_of_range);
    REQUIRE(copy == x); // per basic exception guarantee
}
```

<!-- #region slideshow={"slide_type": "slide"} -->
## Invariants

- An invariant is a relationship which must hold irrespective of the operation performed
    - They are a generalized collection of postconditions and as such are testable
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
template <class T>
void test_vector_invariants(const T& x) {
    REQUIRE(!(x.capacity() < x.size()));
    REQUIRE((x.size() == 0) == x.empty());
    REQUIRE(x.empty() == (x.begin() == x.end()));
    //...
}
```

<!-- #region slideshow={"slide_type": "slide"} -->
> **Exercise 3.4** Complete the invariant test for a vector and extend your tests to check the invariants after each mutating operation.
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
## Security
- A secure interface has no preconditions
- A secure system has no bugs
    - To exploit a system:
        - Identify interfaces which cannot be verified
        - Boundary conditions that may not have been anticipated
<!-- #endregion -->

```c++

```
