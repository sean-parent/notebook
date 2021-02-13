---
jupyter:
  jupytext:
    formats: ipynb,md
    text_representation:
      extension: .md
      format_name: markdown
      format_version: '1.3'
      jupytext_version: 1.10.0
  kernelspec:
    display_name: C++17
    language: C++17
    name: xcpp17
---

```c++ slideshow={"slide_type": "skip"}
#include "../common.hpp"
```

<!-- #region slideshow={"slide_type": "slide"} -->
# Types

**Goal: Write _complete_, _expressive_, and _efficient_ types**
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "fragment"} -->
> A _type_ is a pattern for storing and modifying objects.

- In C++, `struct` and`class` are mechanisms for implementing types, but can also be used for other purposes
    - Example: as a mechanism to execute a function at the end of a scope
- I use _type_ to mean _type_ as well as the mechanisms for implementing types in C++ interchangeably
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
> An _object_ is a representation of an entity as a value in memory.

- An object is a _physical_ entity, and as such is imbued with a set of properties
    - size
    - address
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "fragment"} -->
- All type have common, _basis_, operations
    - constructible
    - destructible
    - copyable<sup>1</sup>
    - equality comparable<sup>1</sup>

- <sup>1</sup>Well defined, but may be problematic to implement
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
> The _computational basis_ for a type is a finite set of procedures that enable the construction of any other procedure on the type

- A type which implements a _computational basis_ is _computationally complete_
<!-- #endregion -->

\[ Make sure in this chapter I cover other operations such as hash, representational equality, representational ordering, serialization. \]

<!-- #region slideshow={"slide_type": "slide"} -->
## Regular

> There is a set of procedures whose inclusion in the computational basis of a type lets us place objects in data structures and use algorithms to _copy objects_ from one data structure to another. We call types having such a basis _regular_ since their use guarantees regularity of behavior and, therefore, interoperability.<sup>2</sup>

- The copy operation creates a new object, equal to, and logically disjoint from the original

\begin{align}
b & \to a \implies a = b. && \text{(copies are equal)}
\end{align}

<sup>2</sup>_Elements of Programming_
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
> Two objects are _equal_ iff they represent the same entity

- From this definition we can derive the following axioms for equality:

\begin{align}
(\forall a) a & = a. && \text{(Reflexivity)} \\
(\forall a, b) a & = b \implies b = a. && \text{(Symmetry)} \\
(\forall a, b, c) a & = b \wedge b = c \implies a = c. && \text {(Transitivity)} \\
\end{align}
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
- Copies are logically disjoint

For all $op$, which modifies its operand, and $b = c$:
\begin{align}
b & \to a, op(a) \implies a \neq b \wedge b = c.  && \text{(copies are disjoint)}
\end{align}

- An _algebraic structure_ is a set of connected axioms
    - as with copy and assignment
- Algebraic structures define the semantics of operations
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
### Implementing Copy, Assignment, and Equality

- Copy-constructor is used to implement the copy operation
    - **The compiler is free to assume the semantics of the copy constructor and may elide the copy**
- To copy an object, simply copy all the _members_ or _parts_
- If not defined, the compiler will provide a member-wise copy-constructor
- The copy-constructor can be declared `= default` to ensure it is present
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
namespace v1 {

class my_type {
    // members
public:
    my_type(const my_type&) = default;
};

} // namespace v1
```

<!-- #region slideshow={"slide_type": "slide"} -->
- Similarly, the compiler will provide a member-wise copy-assignment operator
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
namespace v2 {

class my_type {
    // members
public:
    my_type(const my_type&) = default;
    my_type& operator=(const my_type&) = default;
};

} // namespace v2
```

- A type which is both copy-constructible and copy-assignable is _copyable_

<!-- #region slideshow={"slide_type": "slide"} -->
- If the representation of an object is unique, then equality can be implemented as member-wise equality
- C++20 provides member-wise equality (and inequality) by explicitly defaulting `operator==()`

- For C++17
    - Use `std::tie()` as a simple mechanism to implement equality
    - Declare `operator==()` as a non-member operator
        - Otherwise implicit conversions will apply different for the left and right argument
    - A `friend` declaration may be used to implement directly in the class definition
        - `inline` is implied
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
```cpp
namespace v3 {

// C++20

class my_type {
    int _a = 0;
    int _b = 42;

public:
    my_type(const my_type&) = default;
    my_type& operator=(const my_type&) = default;

    bool operator==(const my_type&) const = default;
};

} // namespace v3
```
<!-- #endregion -->

```c++ slideshow={"slide_type": "slide"}
namespace v3 {

// C++17

class my_type {
    int _a = 0;
    int _b = 42;

    auto underlying() const { return std::tie(_a, _b); }

public:
    my_type(const my_type&) = default;
    my_type& operator=(const my_type&) = default;

    friend bool operator==(const my_type& a, const my_type& b) {
        return a.underlying() == b.underlying();
    }
    friend bool operator!=(const my_type& a, const my_type& b) { return !(a == b); }
};

} // namespace v3
```

<!-- #region slideshow={"slide_type": "slide"} -->
### Semantics and Complexity

- We associate semantics with operation names to ascribe meaning to software
    - Operations with the same semantics should have the same name
- The complexity of an operation is another important part of the operation semantics
    - By associating complexity with names we make code easier to reason about
- The _expected_ complexity of copy, assignment, and equality<sup>2</sup> is proportional to the area of the object
    - If these operations cannot be implemented with the expected complexity, they should be given different names


<sup>2</sup> worst case, if equal.
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
- Naming is language
    - Often semantics are expected from patterns of common use
    - When naming functions consider expectations and that few will read any specification
        - But beware, our expectations may be incorrect
        - Trying to always meet expectations does not lead to logically consistent systems
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
### Equationally Complete

- A type for which equality can be implemented as a non-friend (non-member) function is said to be _equationally complete_
- A type which is both equationally and computationally complete can be copied without the use of the copy-constructor or assignment operator
    - Equationally complete implies all the parts are readable
    - Computationally complete implies all the values are obtainable
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
### Whole-Part Relationship

- A common and useful relationship is the _whole-part_ relationship
- An object is a whole, composed of its parts
- A part is _local_ if it is stored directly in the object
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
namespace v4 {

class my_type {
    int _val; // local part
    //...
};

} // namespace v4
```

<!-- #region slideshow={"slide_type": "slide"} -->
- A part is remote if it is stored elsewhere (such as on the heap)
    - Variable size data (polymorphic or dynamic arrays)
    - Trade-off in performance of copy vs. _move_
    - Sharing of immutable data
    - Separation of interface from implementation dependencies (PImpl)
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "fragment"} -->
- Remote parts are expensive
    - You can copy roughly 10K of data in the time it takes to make a small heap allocation (< 1K)
    - And 5K of data in the time it takes to make a large heap allocation
    - Each access is a potential cache miss
    - Most objects are never or rarely copied
        - We'll see why soon

\[ Double-check numbers in this section. These may currently be too high - reference IT Hare. \]
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
- Prefer local parts when appropriate
- But also be aware that techniques like PImpl can greatly improve build time and reduce header file pollution
    - In C++20, modules may make this less necessary
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
- Here is a common implementation of PImpl
    - We'll look at this more later
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
// my_type.hpp

namespace library_v1 {

class my_type {
    struct implementation;             // forward declaration
    implementation* _remote = nullptr; // remote part
public:
    // declare the basis operations - implementation is in a .cpp file
    my_type(int x, int y);
    ~my_type();
    my_type(const my_type&);
    my_type& operator=(const my_type&);
};

} // namespace library_v1
```

```c++ slideshow={"slide_type": "slide"}
// my_type.cpp

// #include "my_type.hpp" // first include

// other includes

namespace library_v1 {

struct my_type::implementation {
    int _x;
    int _y;
    //...
};

my_type::my_type(int x, int y) : _remote{new implementation{x, y}} {}
my_type::~my_type() { delete _remote; }
my_type::my_type(const my_type& a) : _remote{new implementation{*a._remote}} {}
my_type& my_type::operator=(const my_type& a) {
    *_remote = *a._remote;
    return *this;
}

} // namespace library_v1
```

<!-- #region slideshow={"slide_type": "slide"} -->
- A major downside of using the PImpl pattern is the amount of forwarding boiler plate that must be written.
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
### `std::regular<T>`

The C++20 standard defines the _concept_ std::regular<T> to be a type which is copyable, equality comparable, and default constructible. The latter is an odd choice. Default constructible is covered later in this section, and concepts are discussed more in Chapter 3, Algorithms.
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} toc-hr-collapsed=false slideshow={"slide_type": "slide"} -->
## Efficient Basis and Safety
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} toc-hr-collapsed=false slideshow={"slide_type": "slide"} -->
### Efficient Basis

- An operation is _efficient_ if there is no way to implement it to use fewer resources:
    - time
    - space
    - energy

- Unless otherwise specified, we will use efficiency to mean _time efficiency_
    - But in practice, where not all three can be achieved the trade-offs should be considered

- A type has an _efficient basis_ if any additional operations can be implemented efficiently in terms of the basis operations
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} toc-hr-collapsed=false slideshow={"slide_type": "slide"} -->
- Making all data members public ensures an efficient basis, but may be _unsafe_
- In fact, we can prove that some operations cannot be implemented both efficiently and safely
- The canonical example is in-situ sort, although it is true of any in-situ permutation
    - This is why functional languages do not allow direct in-situ permutations

- In C++, explicit `move` is both unsafe and inefficient
    - It is less safe than copy
    - But more efficient than copy

- Strive to make operations safe _and_ efficient
- Only sacrifice safety for efficiency with good (measurable) reason
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
### Safety

- An object which represents an entity is _fully formed_.
- An object which does not represent an entity is _partially formed_.
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "fragment"} -->
- Any operation which maintains the correspondence between an object and an entity it represents is _safe_
- An operation which loses the correspondence is _unsafe_
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "fragment"} -->
- There are different categories of safety
    - i.e. _memory safety_
        - Destroying the correspondence of unrelated objects to an entity ultimately causes the bug
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
- An operation is _operationally safe_ if, when the operation pre-conditions are satisfied, the operation results in objects which are fully formed
- An operation is _operationally unsafe_ if, when the operation pre-conditions are satisfied, the operation may result in an object which is not fully formed
    - From here on, when referring to a _safe_ operation we mean _operationally safe_
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
- As a general rule
    - Only safe operations should be public
    - Unsafe operations should be private

- Moving from an object _may_ leave the object in a "valid but **unspecified**" state
    - _Unspecified_ is without correspondence to an entity
    - move is a public unsafe operation, it may leave the moved-from object in a partially formed state

- There is a trade-off between safety, and efficiency
    - Not every operation can be implemented to be both safe, and efficient (provably)
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
- There are many examples of unsafe operations with the built in types:
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
{
    double x = 0.0/0.0; // explicitly undefined
    cout << x << endl;
}
```

```c++ slideshow={"slide_type": "fragment"}
{
    int x; // unspecified
    cout << x << endl;
}
```

```c++ slideshow={"slide_type": "slide"}
{
    string x = "hello world";
    string y = move(x); // unspecified
    cout << x << endl;
}
```

```c++ slideshow={"slide_type": "fragment"}
{
    unique_ptr<int> x = make_unique<int>(42);
    unique_ptr<int> y = move(x); // safe! x is guaranteed to be == nullptr
}
```

<!-- #region slideshow={"slide_type": "slide"} -->
- After an unsafe operation where an object is left partially formed
    - Subsequent operations are required to restore the fully formed state prior to use
        - If the partially formed state is _explicit_ it may by used in subsequent operation but those operations must yield explicitly undefined values for later detection and handling
        - i.e. NaN, expected, maybe-monad pattern
    - Or the object must be destroyed
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
- An _implicit move_, one generated by the compiler, always occurs on an expiring value
    - This means the combined operation of `op(rv); rv.~T();` is safe
- `std::move()` is equivalent to `static_cast<T&&>()`
    - Explicit move is unsafe
    - Circumventing the type system requires additional care
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
### Move
- The _move_ operation transfers the value of one object to a new or existing object

\begin{align}
a = b, a & \rightharpoonup c \implies c = b. && \text{(move is value preserving)}
\end{align}
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "fragment"} -->
- This says nothing about the moved from value
    - In this way, move is a _weaker_ form of copy
- The expectation is that moving a value does not require additional resources, beyond the local storage, for an object
    - In this way, move is a _stronger_ form of copy
- Move is a distinct operation as part of an _efficient_ basis
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
> A basis is _efficient_ if and only if any procedure implemented using it is as efficient as an equivalent procedure written in terms of an alternative basis.
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "fragment"} -->
- In C++ we implement the move operation in terms of rvalue references.
    - An rvalue is a temporary value
    - Any witnesses to remote parts can be maintained without copying the remote part
<!-- #endregion -->

```c++ slideshow={"slide_type": "slide"}
namespace library2 {

class my_type {
    struct implementation;             // forward declaration
    implementation* _remote = nullptr; // remote part
public:
    // declare the basis operations - implementation is in a .cpp file
    my_type(int x, int y);
    ~my_type();
    my_type(const my_type&);
    my_type& operator=(const my_type&);

    my_type(my_type&& a) noexcept : _remote{a._remote} { a._remote = nullptr; }
    my_type& operator=(my_type&& a) noexcept;
};

} // namespace library
```

```c++ slideshow={"slide_type": "slide"}
namespace library2 {

struct my_type::implementation {
    int _x;
    int _y;
    //...
};

my_type::my_type(int x, int y) : _remote{new implementation{x, y}} {}
my_type::~my_type() { delete _remote; }
my_type::my_type(const my_type& a) : _remote{new implementation{*a._remote}} {}
my_type& my_type::operator=(const my_type& a) {
    *_remote = *a._remote;
    return *this;
}
my_type& my_type::operator=(my_type&& a) noexcept {
    delete _remote;
    _remote = a._remote;
    a._remote = nullptr;
    return *this;
}

} // namespace library
```

<!-- #region slideshow={"slide_type": "slide"} -->
- The requirements in the C++ standard are that we must leave the moved from object _"valid but unspecified"_ state
    - This is a contradiction
    - Because the value is _unspecified_ the object no longer has _meaning_ and not all operations are valid
- Some operations _must_ be valid on the otherwise unspecified state
    - destruction
    - copy and move assigning to the object (to establish a new value)
    - self move assignment (for self-swap)
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} tags=["exercise"] -->
**Exercise:** `my_type` contains a bug. Find the bug. Fix it using at least two different approaches. What are the trade-offs?
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
## Exercises
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} tags=["exercise"] -->
**Exercise:** `my_type` contains a bug. Find the bug. Fix it using at least two different
approaches. What are the trade-offs?
<!-- #endregion -->

```c++ slideshow={"slide_type": "slide"}
namespace library3 {

class my_type {
    struct implementation;             // forward declaration
    implementation* _remote = nullptr; // remote part
public:
    // declare the basis operations - implementation is in a .cpp file
    my_type(int x, int y);
    ~my_type();
    my_type(const my_type&);
    my_type& operator=(const my_type&);

    my_type(my_type&& a) noexcept : _remote{a._remote} { a._remote = nullptr; }
    my_type& operator=(my_type&& a) noexcept;
};

} // namespace library
```

```c++ slideshow={"slide_type": "slide"}
namespace library3 {

struct my_type::implementation {
    int _x;
    int _y;
    //...
};

my_type::my_type(int x, int y) : _remote{new implementation{x, y}} {}
my_type::~my_type() { delete _remote; }
my_type::my_type(const my_type& a) : _remote{new implementation{*a._remote}} {}
my_type& my_type::operator=(const my_type& a) {
    *_remote = *a._remote;
    return *this;
}
my_type& my_type::operator=(my_type&& a) noexcept {
    delete _remote;
    _remote = a._remote;
    a._remote = nullptr;
    return *this;
}

} // namespace library
```

<!-- #region slideshow={"slide_type": "slide"} -->
- What bug?
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "fragment"} -->
```cpp
{
    using namespace library;

    my_type a{10, 20};
    my_type b{12, 30};

    b = move(a);
    a = b;
}
```
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "fragment"} -->
```
input_line_9:11:6: warning: null passed to a callee that requires a non-null argument [-Wnonnull]
    *_remote = *a._remote;
     ^~~~~~~
Interpreter Exception:
```
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
```cpp
// b = move(a);

my_type& my_type::operator=(my_type&& a) noexcept {
    delete _remote;
    _remote = a._remote;
    a._remote = nullptr; // <--
    return *this;
}
```
<!-- #endregion -->

```cpp
// a = b;

my_type& my_type::operator=(const my_type& a) {
    *_remote = *a._remote;
//   ^~~~~~~ nullptr dereference
    return *this;
}
```


- Some operations _must_ be valid on the otherwise unspecified state
    - destruction
    - copy and move assigning to the object (to establish a new value)
    - self-move assignment (for self-swap)

<!-- #region slideshow={"slide_type": "slide"} -->
### Fixes to copy-assignment crash

- We need to be able to assign to our partially formed value
    - Two possible options
        - Change assignment
        - Change move
<!-- #endregion -->

```c++ slideshow={"slide_type": "skip"}
namespace lib3 {

class my_type {
    struct implementation;             // forward declaration
    implementation* _remote = nullptr; // remote part
public:
    // declare the basis operations - implementation is in a .cpp file
    my_type(int x, int y);
    ~my_type();
    my_type(const my_type&);
    my_type& operator=(const my_type&);

    my_type(my_type&& a) noexcept : _remote{a._remote} { a._remote = nullptr; }
    my_type& operator=(my_type&& a) noexcept;
};

} // namespace lib3
```

```c++ slideshow={"slide_type": "slide"}
namespace lib3 {

struct my_type::implementation {
    int _x;
    int _y;
    //...
};

my_type::my_type(int x, int y) : _remote{new implementation{x, y}} {}
my_type::~my_type() { delete _remote; }
my_type::my_type(const my_type& a) : _remote{new implementation{*a._remote}} {}
my_type& my_type::operator=(const my_type& a) {
    if (_remote) *_remote = *a._remote;
    else _remote = new implementation{*a._remote}; // <---
    return *this;
}
my_type& my_type::operator=(my_type&& a) noexcept {
    delete _remote;
    _remote = a._remote;
    a._remote = nullptr;
    return *this;
}

} // namespace lib3
```

```c++ slideshow={"slide_type": "slide"}
{
    using namespace lib3;

    my_type a{10, 20};
    my_type b{12, 30};

    b = move(a);
    a = b;
}
```

```c++ slideshow={"slide_type": "skip"}
namespace lib4 {

class my_type {
    struct implementation;             // forward declaration
    implementation* _remote = nullptr; // remote part
public:
    // declare the basis operations - implementation is in a .cpp file
    my_type(int x, int y);
    ~my_type();
    my_type(const my_type&);
    my_type& operator=(const my_type&);

    my_type(my_type&& a) noexcept : _remote{a._remote} { a._remote = nullptr; }
    my_type& operator=(my_type&& a) noexcept;
};

} // namespace lib4
```

```c++ slideshow={"slide_type": "slide"}
namespace lib4 {

struct my_type::implementation {
    int _x;
    int _y;
    //...
};

my_type::my_type(int x, int y) : _remote{new implementation{x, y}} {}
my_type::~my_type() { delete _remote; }
my_type::my_type(const my_type& a) : _remote{new implementation{*a._remote}} {}
my_type& my_type::operator=(const my_type& a) {
    *_remote = *a._remote;
    return *this;
}
my_type& my_type::operator=(my_type&& a) noexcept {
    swap(_remote, a._remote); // <----
    return *this;
}

} // namespace lib4
```

```c++
{
    using namespace lib4;

    my_type a{10, 20};
    my_type b{12, 30};

    b = move(a);
    a = b;
}
```

<!-- #region slideshow={"slide_type": "slide"} -->
```cpp
{
    using namespace lib4;

    my_type a{10, 20};
    my_type b = move(a);
    a = b;
}
```
```
input_line_17:11:6: warning: null passed to a callee that requires a non-null argument [-Wnonnull]
    *_remote = *a._remote;
     ^~~~~~~
Interpreter Exception:
```
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
### Idiomatic Approach
<!-- #endregion -->

```c++ slideshow={"slide_type": "skip"}
namespace lib5 {

class my_type {
    struct implementation;             // forward declaration
    implementation* _remote = nullptr; // remote part
public:
    // declare the basis operations - implementation is in a .cpp file
    my_type(int x, int y);
    ~my_type();
    my_type(const my_type&);
    my_type& operator=(const my_type&);

    my_type(my_type&& a) noexcept : _remote{a._remote} { a._remote = nullptr; }
    my_type& operator=(my_type&& a) noexcept;
};

} // namespace lib5
```

```c++ slideshow={"slide_type": "slide"}
namespace lib5 {

struct my_type::implementation {
    int _x;
    int _y;
    //...
};

my_type::my_type(int x, int y) : _remote{new implementation{x, y}} {}
my_type::~my_type() { delete _remote; }
my_type::my_type(const my_type& a) : _remote{new implementation{*a._remote}} {}
my_type& my_type::operator=(const my_type& a) {
    return *this = my_type(a); // <--- copy and move
}
my_type& my_type::operator=(my_type&& a) noexcept {
    delete _remote;
    _remote = a._remote;
    a._remote = nullptr;
    return *this;
}

} // namespace lib5
```

```c++ slideshow={"slide_type": "slide"}
{
    using namespace lib5;

    my_type a{10, 20};
    my_type b{12, 30};

    b = move(a);
    a = b;
}

{
    using namespace lib5;

    my_type a{10, 20};
    my_type b = move(a);
    a = b;
}
```

<!-- #region slideshow={"slide_type": "slide"} -->
- The idomatic solution can work with unique_ptr
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
namespace lib6 {

class my_type {
    struct implementation;
    struct deleter {
        void operator()(implementation*) const noexcept; // <---
    };
    unique_ptr<implementation, deleter> _remote;
public:
    // declare the basis operations - implementation is in a .cpp file
    my_type(int x, int y); // <---
    ~my_type() = default;
    my_type(const my_type&); // <---
    my_type& operator=(const my_type& a) { return *this = my_type(a); }

    my_type(my_type&& a) noexcept = default;
    my_type& operator=(my_type&& a) noexcept = default;
};

} // namespace lib6

```

```c++ slideshow={"slide_type": "slide"}
namespace lib6 {

struct my_type::implementation {
    int _x;
    int _y;
    //...
};

my_type::my_type(int x, int y) : _remote{new implementation{x, y}} {}
my_type::my_type(const my_type& a) : _remote{new implementation{*a._remote}} {}
void my_type::deleter::operator()(implementation* p) const noexcept { delete p; }

} // namespace lib6
```

```c++ slideshow={"slide_type": "slide"}
{
    using namespace lib6;

    my_type a{10, 20};
    my_type b{12, 30};

    b = move(a);
    a = b;
}

{
    using namespace lib6;

    my_type a{10, 20};
    my_type b = move(a);
    a = b;
}

```

<!-- #region slideshow={"slide_type": "slide"} -->
### Tradeoffs

- **Copy Assignment: In situ assignment (if available) or copy construct**
- **Move Assignment: Swap**
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "fragment"} -->
- Performance: Faster for in situ case (saves heap allocations)
- Object Lifetime: Not precise
- Exception Safety: Basic Guarantee (not transactional)
- Implementation: Complex
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "fragment"} -->
- **Copy Assignment: Copy construct and move assign**
- **Move Assignment: Consume**
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "fragment"} -->
- Performance: Slower
- Object Lifetime: Precise
- Exception Safety: Strong Guarantee (transactional)
- Implementation: Simple
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
- Recommendation
    - I prefer the idiomatic, simpler approach
        - unless I have evidence of a performance issue
        - or the type is heavily used
    - Write it correct and simple first
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
## Default Construction

- What should the state be of a default constructed object?
    - Should it always be fully-formed?

- A common use case of a default constructed object is to create the object before we have a value to give to it:
<!-- #endregion -->

```c++ slideshow={"slide_type": "skip"}
namespace {
bool predicate() { return true; }
std::pair<std::string, std::string> get_pair() { return std::make_pair<string, string>("Hello", "World"); }
}
```

```c++ slideshow={"slide_type": "slide"}
{
    string s;
    if (predicate()) s = "Hello";
    else s = "World";
}
```

```c++ slideshow={"slide_type": "fragment"}
{
    string s1;
    string s2;
    tie(s1, s2) = get_pair();
}
```

<!-- #region slideshow={"slide_type": "slide"} -->
- The language has facilities that make it rarely necessary to construct an object before providing a value:
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
{
    string s = predicate() ? "Hello" : "World";
}
```

```c++ slideshow={"slide_type": "fragment"}
{
    auto [s1, s2] = get_pair();
}
```

<!-- #region slideshow={"slide_type": "slide"} -->
- This makes having a default constructor optional
    - But not having one can be inconvenient
<!-- #endregion -->

- A default constructor value is often overwritten before use
    - As such it is inefficient to allocate memory, or acquire resources, in the default constructor

<!-- #region slideshow={"slide_type": "slide"} -->
- A default constructor should:
    - Be noexcept (one way to do this is to initialize to point to a const (or constexpr) singleton)
    - Be `constexpr`
    - Execute in time no worse than the time proportional to the `sizeof()` the object
    - If the object has a meaningful _zero_ or _empty_ state it should initialize to that state
        - Otherwise it may be partially-formed
<!-- #endregion -->

```c++ slideshow={"slide_type": "slide"}
namespace lib7 {

class my_type {
    struct implementation;
    struct deleter {
        void operator()(implementation*) const noexcept; // <---
    };
    unique_ptr<implementation, deleter> _remote;
public:
    // declare the basis operations - implementation is in a .cpp file
    constexpr my_type() noexcept = default; // partially formed
    my_type(int x, int y); // <---
    ~my_type() = default;
    my_type(const my_type&); // <---
    my_type& operator=(const my_type& a) { return *this = my_type(a); }

    my_type(my_type&& a) noexcept = default;
    my_type& operator=(my_type&& a) noexcept = default;
};

} // namespace lib7
```

<!-- #region slideshow={"slide_type": "slide"} -->
- Recommendation
    - Provide a default-ctor
    - Avoid using it unless it has a meaningful zero or empty value
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "skip"} -->
**Exercise:** Look at the regular operations (copy, assignment, equality, default construction) for a type in the standard library, or a commonly used type within your project. Is the implementation correct? Complete? Efficient?
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "skip"} -->
### What is _mutable_?

### Polymorphism will be covered later

## Efficiency

- An operation is _efficient_ if there is no way to implement it to use fewer resources
    - time
    - space
    - energy

- Unless otherwise specified, we will use efficiency to mean _time efficiency_
    - But in practice, where not all three can be achieved the trade-offs should be consider
<!-- #endregion -->

<!-- #region toc-hr-collapsed=false -->
# Efficiency & Expressiveness
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} toc-hr-collapsed=false -->
## Recap
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} toc-hr-collapsed=false -->
### Definition of _Type_ and _Regular_

> A _type_ is a pattern for storing and modifying objects.

<div></div>

> There is a set of procedures whose inclusion in the computational basis of a type lets us place objects in data structures and use algorithms to _copy objects_ from one data structure to another. We call types having such a basis _regular_ since their use guarantees regularity of behavior and, therefore, interoperability.
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} toc-hr-collapsed=false -->
### Semantics and Complexity

- Semantics of an operation are defined with axioms derived from the definition. i.e. we can define the semantics of equality as:

\begin{align}
(\forall a) a & = a. && \text{(Reflexivity)} \\
(\forall a, b) a & = b \implies b = a. && \text{(Symmetry)} \\
(\forall a, b, c) a & = b \wedge b = c \implies a = c. && \text {(Transitivity)} \\
\end{align}

- This covers any equivalence relation
- Two objects are _equal_ iff their two values represent the same entity

- The expected complexity of an operation is an important attribute of the operation
- i.e. The only thing that separates the concept of `ForwardIterator` and `RandomAccessIterator` is the complexity of advancing `n` steps
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} toc-hr-collapsed=false -->
### Computational Basis and Computationally Complete
> The _computational basis_ for a type is a finite set of procedures that enable the construction of any other procedure on the type

- A type which does not implement a _computational basis_ is _incomplete_
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} toc-hr-collapsed=false -->
### Equationally Complete
- A type for which equality can be implemented as a non-friend (non-member) function is said to be _equationally complete_
- A type which is both equationally and computationally complete can be copied without the use of the copy-constructor or assignment operator
    - Equationally complete implies all the parts are readable
    - Computationally complete implies all the values are obtainable

<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} toc-hr-collapsed=false -->
### Whole/Part Relationship
- An object is a _whole_, composed of its _parts_
- A part is _local_ if it is stored directly in the object
- A part is _remote_ if it is stored elsewhere (such as on the heap)
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} toc-hr-collapsed=false -->
### Safety
- Any operation which maintains the correspondence between an object and an entity it represents is _safe_
- An operation which loses the correspondence is _unsafe_
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} toc-hr-collapsed=false -->
### Canonical Type with and without Remote Parts
<!-- #endregion -->

```c++ slideshow={"slide_type": "slide"}
namespace bcc {

class simple_type {
    int _members = 0;

public:
    simple_type() noexcept = default;                         // default-ctor

    simple_type(const simple_type&) = default;                // copy-ctor
    simple_type& operator=(const simple_type&) = default;     // copy-assign

    simple_type(simple_type&&) noexcept = default;            // move-ctor
    simple_type& operator=(simple_type&&) noexcept = default; // move_assign

    friend bool operator==(const simple_type& a, const simple_type& b) {
        return tie(a._members /*, ...*/) == tie(b._members /*, ...*/);
    }
    friend bool operator!=(const simple_type& a, const simple_type& b) {
        return !(a == b);
    }
};

} // namespace bcc
```

```c++ slideshow={"slide_type": "slide"}
namespace bcc {

class pimpl_type {
    class implementation;
    struct deleter {
        void operator()(implementation*) const;
    };
    unique_ptr<implementation, deleter> _remote;

public:
    pimpl_type() noexcept = default;                        // default-ctor
    pimpl_type(const pimpl_type&);                          // copy-ctor
    pimpl_type& operator=(const pimpl_type& a) {            // copy-assign
        return *this = pimpl_type(a);
    }
    pimpl_type(pimpl_type&&) noexcept = default;            // move-ctor
    pimpl_type& operator=(pimpl_type&&) noexcept = default; // move_assign
    friend bool operator==(const pimpl_type&, const pimpl_type&);
    friend bool operator!=(const pimpl_type& a, const pimpl_type& b) {
        return !(a == b);
    }
};

} // namespace bcc
```

```c++ slideshow={"slide_type": "slide"}
// cpp file
namespace bcc {

struct pimpl_type::implementation {
    // a simple type...
    int _members = 0;

    friend bool operator==(const implementation& a, const implementation& b) {
        return tie(a._members /*, ...*/) == tie(b._members /*, ...*/);
    }
};

void pimpl_type::deleter::operator()(implementation* a) const { delete a; }

pimpl_type::pimpl_type(const pimpl_type& a)
    : _remote(new implementation(*a._remote)) {}

bool operator==(const pimpl_type& a, const pimpl_type& b) {
    return *a._remote == *b._remote;
}

} // namespace bcc
```

<!-- #region slideshow={"slide_type": "slide"} -->
- In both cases the default-dtor is used (not specified)
- We will be covering polymorphic types and containers later in the course
<!-- #endregion -->

<!-- #region jupyter={"source_hidden": true} slideshow={"slide_type": "skip"} toc-hr-collapsed=false -->
## Prior Homework

**Exercise** Look at the regular operations (copy, assignment, equality, default construction) for a type in the standard library, or a commonly used type within your project. Is the implementation correct? Complete? Efficient?
<!-- #endregion -->

<!-- #region jupyter={"source_hidden": true} slideshow={"slide_type": "skip"} toc-hr-collapsed=false -->
## Prior Homework

**Exercise:** Look at the regular operations (copy, assignment, equality, default construction) for ZString (or a commonly used type within your project). Is the implementation correct? Complete? Efficient?
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} toc-hr-collapsed=false -->
## What Should Be Part of The Public Interface On A Type?

- In general we want the minimum number of public calls with private access to provide a type which is:
    - Computationally Complete
    - Equationally Complete

- Other operations should be implemented in terms of those
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} toc-hr-collapsed=false -->
Example:
<!-- #endregion -->

```c++ slideshow={"slide_type": "-"}
namespace bcc {

class number {
    unsigned int _data = 0;

public:
    // default standard operations
    number& operator++() {
        ++_data;
        return *this;
    }
    friend unsigned int operator-(const number& a, const number& b) { return a._data - b._data; }
};

} // namespace bcc
```

<!-- #region slideshow={"slide_type": "slide"} -->
- `number` is computationally and equationally complete
<!-- #endregion -->

```c++ slideshow={"slide_type": "-"}
namespace bcc {

bool operator==(const number& a, const number& b) { return (a - b) == 0; }

} // namespace bcc
```

<!-- #region slideshow={"slide_type": "slide"} -->
- Being correct and complete is not enough:
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
{
    using namespace bcc;
    // construct the value 3
    number a;
    ++a;
    ++a;
    ++a;

    // print it
    cout << (a - number()) << endl;
}
```

<!-- #region slideshow={"slide_type": "slide"} toc-hr-collapsed=false -->
## Expressive Basis

> A basis is _expressive_ iff it allows compact and convenient definitions of procedures on the type.

For example:
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
{
    using namespace bcc;

    // construct the value 3
    number a;
    ++a;
    ++a;
    ++a;
}
```

<!-- #region slideshow={"slide_type": "slide"} -->
is not as expressive as:
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
{ int a = 3; }
```

<!-- #region slideshow={"slide_type": "slide"} -->
- Especially for common operators you should provide operations in meaningful groups:
- If your provide `operator==()` (and you should), also provide `!=`
- If you provide `operator<()`, _natural total order_, you should provide all comparison operators
- Negation and addition implies subtraction
- etc.
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} toc-hr-collapsed=false -->
## (Revisited) What Should Be Part of The Public Interface On A Type?

- In general we want the **minimum** number of public calls with private access to provide a type which is:
    - Computationally Complete
    - Equationally Complete
    - Efficient
    - Safe
    - Operations required to be part of the class interface by the language (i.e., you cannot implement a stand-alone assignment operator)

- Other operations, including operations that are part of the expressive basis, should be implemented in terms of those operations
- This still leaves a fair amount up to the designer to choose how to balance safety and efficiency and what _expressive_ means in the context of the type
<!-- #endregion -->

# Runtime-Polymorphism


- The requirement of runtime-polymorphism within a system comes from the need to use objects of different but _related_ types
- _Inheritance_ is a mechanism to implement runtime-polymorphism where one class is _derived_ from another class, but overriding all or part of the implementation.

```c++
namespace v5 {
using circle = int;

void draw(const circle& a, ostream& out, size_t position) {
    out << string(position, ' ') << a << endl;
}

using document = vector<circle>;

void draw(const document& a, ostream& out, size_t position) {
    out << string(position, ' ') << "<document>\n";
    for (const auto& e : a)
        draw(e, out, position + 2);
    out << string(position, ' ') << "</document>\n";
}
} // namespace v5
```

```c++
namespace v4 {

class shape {
public:
    virtual ~shape() = default;
    virtual void draw(ostream&, size_t) const = 0;
};

using document = vector<shared_ptr<shape>>;

void draw(const document& a, ostream& out, size_t position) {
    out << string(position, ' ') << "<document>\n";
    for (const auto& e : a)
        e->draw(out, position + 2);
    out << string(position, ' ') << "</document>\n";
}

} // namespace v4
```

```c++
namespace v4 {

class circle final : public shape {
    int _radius;

public:
    explicit circle(int radius) : _radius{radius} {}
    void draw(ostream& out, size_t position) const override {
        out << string(position, ' ') << "circle: " << _radius << "\n";
    }
};

} // namespace v4
```

```c++
namespace v4 {

class rectangle final : public shape {
    int _width, _height;
public:
    explicit rectangle(int width, int height) : _width{width}, _height{height} {}
    void draw(ostream& out, size_t position) const override {
        out << string(position, ' ') << "rectangle: " << _width << ", " << _height << "\n";
    }
};

} // namespace 4
```

```c++
{
    using namespace v4;

    document d;

    d.emplace_back(new circle{5});
    d.emplace_back(new rectangle{10, 42});
    draw(d, cout, 0);
}
```

- This line contains a defect:
```cpp
    d.emplace_back(new circle{5});
```
    - An instance of `circle` will be allocated first
    - Then the document will grow to make room
    - If growing the document throws an exception, the memory from `circle` is leaked

```c++
{
    using namespace v4;

    document d;

    d.push_back(make_shared<circle>(5));
    d.push_back(make_shared<rectangle>(10, 42));
    draw(d, cout, 0);
}
```

```c++

```
