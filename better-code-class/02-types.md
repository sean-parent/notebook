---
jupyter:
  jupytext:
    formats: ipynb,md
    text_representation:
      extension: .md
      format_name: markdown
      format_version: '1.2'
      jupytext_version: 1.8.0
  kernelspec:
    display_name: C++17
    language: C++17
    name: xcpp17
---

```c++ slideshow={"slide_type": "skip"}
#include "../common.hpp"

namespace bcc { }
using namespace bcc;
```

<!-- #region slideshow={"slide_type": "slide"} -->
# Types

**Goal: Write _complete_, _expressive_, and _efficient_ types**
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "fragment"} -->
> A _type_ is a pattern for storing and modifying objects.

- In C++, `struct`, `class`, and `enum` are mechanisms for implementing types, but can also be used for other purposes
- We use _type_ to mean _type_ as well as the mechanisms for implementing types in C++ interchangeably
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
> An _object_ is a representation of an entity as a value in memory.

- An object is a _physical_ entity, and as such is imbued with a set of properties
    - size
    - address
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "fragment"} -->
- All objects have of common, _basis_, operations
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

<!-- #region slideshow={"slide_type": "slide"} -->
## Regular

> There is a set of procedures whose inclusion in the computational basis of a type lets us place objects in data structures and use algorithms to _copy objects_ from one data structure to another. We call types having such a basis _regular_, since their use guarantees regularity of behavior and, therefore, interoperability.

- The copy operation creates a new object, equal to, and logically disjoint from the original

\begin{align}
b & \to a \implies a = b. && \text{(copies are equal)}
\end{align}
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
- Algebraic structures define the basic semantics of operations
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
class my_type {
    // members
public:
    my_type(const my_type&) = default;
};
```

```c++ slideshow={"slide_type": "skip"}
.undo
```

<!-- #region slideshow={"slide_type": "slide"} -->
- Similarly, the compiler will provide a member-wise copy-assignment operator
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
class my_type {
    // members
public:
    my_type(const my_type&) = default;
    my_type& operator=(const my_type&) = default;
};
```

```c++ slideshow={"slide_type": "skip"}
.undo
```

<!-- #region slideshow={"slide_type": "slide"} -->
- If the representation of an object is unique, then equality can be implemented as member-wise equality
- Unfortunately, the compiler does not implement member-wise equality (until C++20)
- Use `std::tie()` as a simple mechanism to implement equality

- Do not declare `operator==()` as a member operator
- A `friend` declaration may be used to implement directly in the class definition.
    - `inline` is implied.
<!-- #endregion -->

```c++ slideshow={"slide_type": "slide"}
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
    friend bool operator!=(const my_type& a, const my_type& b) {
        return !(a == b);
    }
};
```

```c++ slideshow={"slide_type": "skip"}
.undo
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
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
### Equationally Complete

- A type for which equality can be implemented as a non-friend (non-member) function is said to be _equationally complete_
- A type which is both equationally and computationally complete can be copied without the use of the copy-constructor or assignment operator
    - Equationally complete implies all the parts are readable
    - Computationally complete implies all the values are obtainable
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "notes"} -->
**SKIP** Next cell is skipped for workshop
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "skip"} tags=["exercise"] -->
**Exercise:** Find a type in your project which is not equationally complete and make it so.
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
## Relationships

- Relationships are unavoidable with objects in a space
    - The address of an object is the relationship between the object and the space within which it resides
    
- For any relationship there is a predicate form
    - Dick and Jane are married (relationship)
    - Are Dick and Jane married? (predicate)

- We normally think of objects as representing _things_ or _nouns_
    - An object may also represent a _relationship_
    - The `next` pointer in a linked list represents the relationship between one element and its successor
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
- An object which represents a relationship is a _witness_ to the relationship
- When copying a witness there are three possible outcomes
    - The relationship is maintained
    - The relationship is severed
    - The witness is invalidated 
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "fragment"} -->
- Other mutating operations on any object in the relationship have the same possible outcomes
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "notes"} -->
Give two example - the wedding band example
An offset into an array example
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
### Whole-Part Relationship

- A common and useful relationship is the _whole-part_ relationship
- An object is a whole, composed of its parts
- A part is _local_ if it is stored directly in the object
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
class my_type {
    std::string _str; // local part
    int _val; // local part
    //...
};
```

```c++ slideshow={"slide_type": "skip"}
.undo
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
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
- Prefer local parts when appropriate
    - There are _many_ unnecessary heap allocations in Photoshop (and most products) 
- But also be aware that techniques like PImpl can greatly improve build time and reduce header file pollution
    - In C++20, modules may make this less necessary
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
- Here is a common implementation of PImpl
    - We'll look at this more later
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
// my_type.hpp

namespace library {

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

} // namespace library
```

```c++ slideshow={"slide_type": "slide"}
// my_type.cpp

// #include "my_type.hpp" // first include

// other includes

namespace library {

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
    
} // namespace library
```

```c++
.undo 2
```

<!-- #region slideshow={"slide_type": "slide"} -->
- A major downside of using the PImpl pattern is the amount of forwarding boiler plate that must be written.
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
namespace library {

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
namespace library {

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
# Types

**Goal: Write _complete_, _expressive_, and _efficient_ types**
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
## Exercises
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "skip"} -->
**SKIP** Following cells are skipped for workshop
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "skip"} tags=["exercise"] -->
**Exercise:** Find a type in your project which is not equationally complete and make it so.
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "skip"} -->
- Why?
    - An equationally complete type is easier to test
        - If you cannot read a property, how do you validate it?
    - Considering how to make a type equationally complete forces you to think through the properties of the type
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "skip"} -->
- Considerations
    - Only properties with associated constraints (invariants) and relationships require accessors member functions
    - Providing direct data access is preferred to boiler plate _getters and setters_
    - The Objective-C naming conventions can make an API more clear
        - Reading a property is simply the name of the property, i.e. `property()`
        - Writing a property is done with `set_property()`
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "skip"} -->
```cpp
v.resize(10);
auto s = v.size();

v.reserve(10);
auto s = v.capacity();
```
vs.
```cpp
v.set_size(10);
auto s = v.size();

v.set_capacity(10);
auto s = v.capacity();
```
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} tags=["exercise"] -->
**Exercise:** `my_type` contains a bug. Find the bug. Fix it using at least two different
approaches. What are the trade-offs?
<!-- #endregion -->

```c++ slideshow={"slide_type": "slide"}
namespace library {

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
namespace library {

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
    - self move assignment (for self-swap)

<!-- #region slideshow={"slide_type": "slide"} -->
## Safety

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
    - _Unspecified_ is without a correspondence to an entity
    - move is a public unsafe operation, it may leave the moved from object in a partially formed state
    
- There is a trade-off between safety, and efficiency
    - Not every operation can be implemented to be both safe, and efficient (provably)
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
- There are many examples of unsafe operations with the built in types:
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
{
    int x; // unspecified
    cout << x << endl;
}
```

```c++ slideshow={"slide_type": "fragment"}
{
    double x = 0.0/0.0; // explicitly undefined
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
    - Should it always be fully formed?
    
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

> There is a set of procedures whose inclusion in the computational basis of a type lets us place objects in data structures and use algorithms to _copy objects_ from one data structure to another. We call types having such a basis _regular_, since their use guarantees regularity of behavior and, therefore, interoperability.
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

<!-- #region jupyter={"source_hidden": true} slideshow={"slide_type": "skip"} toc-hr-collapsed=false -->
`ZString` operations:
- default-ctor: Should be declared `noexcept` but will not throw
```cpp
    ZString();
```
- copy-ctor: Logical copy by incrementing reference count to immutable string, should be declared `noexcept`.
```cpp
    ZString(const ZString &x);
```
- copy-assign: Handles self assignment, requires locking (spin-lock). Complex logic. Benchmark against a copy/move implementation? Returns void?
```cpp
    void operator=(const ZString &x);
```
- move-ctor: Should be declared `noexcept` but will not throw, expensive operation to atomic increment a reference count on `TheOneTrueEmptyZByteRun`, guarantees moved from `ZString` is empty string.
```cpp
    ZString(ZString&& x);
```
<!-- #endregion -->

<!-- #region jupyter={"source_hidden": true} slideshow={"slide_type": "skip"} toc-hr-collapsed=false -->
- move-assign: Implemented as swap(). Does not guarantee moved from `ZString` is empty.
```cpp
    ZString& operator=(ZString&& x) noexcept;
```
- equality: Representational (not value) equality. Should be declared as non-member function.
```cpp
    bool operator == (const ZString &x) const;
```

Observation: `fDefaultRun` is hardly used except for test cases and to propagate `fCharacterRun`. Is it needed?

Discussion: How can we incrementally improve ZString?
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
    friend unsigned int operator-(const number& a, const number& b) {
        return a._data - b._data;
    }
};

} // namespace bcc
```

<!-- #region slideshow={"slide_type": "slide"} -->
- `number` is computationally and equationally complete
<!-- #endregion -->

```c++ slideshow={"slide_type": "-"}
namespace bcc {

bool operator==(const number& a, const number& b) {
    return (a - b) == 0;
}

} // namespace bcc
```

<!-- #region slideshow={"slide_type": "slide"} -->
- Being correct and complete is not enough:
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
{
// construct the value 3
number a; ++a; ++a; ++a;

// print it
cout << (a - number()) << endl;
}
```

<!-- #region slideshow={"slide_type": "slide"} toc-hr-collapsed=false -->
## Efficient Basis

- An operation is _efficient_ if there is no way to implement it to use fewer resources:
    - time
    - space
    - energy
    
- Unless otherwise specified, we will use efficiency to mean _time efficiency_
    - But in practice, where not all three can be achieved the trade-offs should be considered

- A type has an _efficient basis_ if any additional operations can be implemented efficiently in terms of the basis operations
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} toc-hr-collapsed=false -->
- Making all data members public ensures an efficient basis, but may be unsafe
- In fact, we can prove that some operations cannot be implemented both efficiently and safely
- The canonical example is in-situ sort, although it is true of any in-situ permutation
    - This is why functional languages do not allow direct in-situ permutations

- In C++, explicit `move` is both unsafe and inefficient
    - It is less safe than copy
    - But more efficient than copy
    
- Strive to make operations safe _and_ efficient
- Only sacrifice safety for efficiency with good (measurable) reason
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} toc-hr-collapsed=false -->
## Expressive Basis

> A basis is _expressive_ iff it allows compact and convenient definitions of procedures on the type.

For example:
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
{
// construct the value 3
number a; ++a; ++a; ++a;
}
```

<!-- #region slideshow={"slide_type": "slide"} -->
is not as expressive as:
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
{
int a = 3;
}
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
    - Operations required to be part of the class interface by the language (i.e., you cannot implement a stand alone assignment operator)
    
- Other operations, including operations that are part of the expressive basis, should be implemented in terms of those operations
- This still leaves a fair amount up to the designer to choose how to balance safety and efficiency and what _expressive_ means in the context of the type
<!-- #endregion -->

<!-- #region jupyter={"source_hidden": true} slideshow={"slide_type": "skip"} -->
**Exercise:** Look at the API and implementation for ZString (or a commonly used class in your own project). What does a ZString represent? What would be a good set of basis operations? What operations would be better implemented externally? Are there operations that should be removed?
<!-- #endregion -->
