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
# Types

**Goal: Write _complete_, _expressive_, and _efficient_ types**
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "fragment"} -->
> A _type_ is a pattern for storing and modifying objects.

- In C++, `struct` and `class` are mechanisms for implementing types but can also be used for other purposes
    - Example: as a mechanism to execute a function at the end of a scope
- I use _type_ to mean _type_ as well as the mechanisms for implementing types in C++ interchangeably
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
> An _object_ is a representation of an entity as a value in memory.

- An object is a _physical_ entity, and as such, is imbued with a set of properties
  - memory footprint
  - location
  - lifetime
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "fragment"} -->
- To understand any type you must consider these fundamental operations, which are components of what we call a _regular_ type.
  - construction
  - destruction
  - copy
  - equality
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} tags=[] -->
In addition, for a given type there are other essential operations
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "fragment"} tags=[] -->
> The _computational basis_ for a type is a finite set of procedures that enable the construction of any other procedure on the type

- A type that implements a _computational basis_ is _computationally complete_
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} tags=[] -->
## Regular

> There is a set of procedures whose inclusion in the computational basis of a type lets us place objects in data structures and use algorithms to _copy objects_ from one data structure to another. We call types having such a basis _regular_ since their use guarantees regularity of behavior and, therefore, interoperability. <br>
<p style='text-align:right;'><small>&mdash; <em>(Stepanov & McJones)</em></small></p>
<!-- #endregion -->



<!-- #region slideshow={"slide_type": "slide"} -->
- The copy operation creates a new object, equal to, and logically disjoint from the original

$$
\begin{align}
b & \to a \implies a = b. && \text{(copies are equal)}
\end{align}
$$
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

For all $op$, which modifies its operand, and given $b = c$:

\begin{align}
b & \to a, op(a) \implies a \neq b \wedge b = c.  && \text{(copies are disjoint)}
\end{align}

- An _algebraic structure_ is a set of connected axioms
    - as with copy and assignment
- Algebraic structures define the semantics of operations
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
### Implementing Copy and Assignment

- A copy-constructor implements the copy operation
    - **The compiler is free to assume the semantics of the copy constructor and may elide the copy**
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "notes"} tags=[] -->
**Note:** True story, a colleague walked into my office and asked, "I'm writing a class, and need to be able to copy it. Should I call the member function that copies 'copy' or 'clone'?"
Me: You should use a copy constructor.
Colleague: "I can't, I'm already using the copy-constructor for something else."
<!-- #endregion -->

```c++ slideshow={"slide_type": "slide"} tags=[]
namespace v0 {

instrumented f() {
    instrumented r;
    return r;
}

} // namespace v0
```

<!-- #region slideshow={"slide_type": "fragment"} tags=[] -->
**Question:** How many copies? How many moves?
```cpp
instrumented a = f();
```
<!-- #endregion -->

```c++ slideshow={"slide_type": "slide"}
{
    using namespace v0;

    instrumented a = f();
}
```

<!-- #region slideshow={"slide_type": "slide"} -->
- To copy an object, copy all the _parts_
- If not defined, the compiler will provide a member-wise copy-constructor
- The copy-constructor can be declared `= default` to ensure it is present
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
namespace v0 {

class my_type {
    // members
public:
    my_type(const my_type&) = default;
};

} // namespace v0
```

<!-- #region slideshow={"slide_type": "slide"} -->
- Similarly, the compiler will provide a member-wise copy-assignment operator
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
namespace v1 {

class my_type {
    // members
public:
    my_type(const my_type&) = default;
    my_type& operator=(const my_type&) = default;
};

} // namespace v1
```

- A type which is both copy-constructible and copy-assignable is _copyable_

<!-- #region slideshow={"slide_type": "slide"} -->
### Implementing Equality
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "fragment"} -->
- If the representation of an object is unique, then equality can be implemented as part-wise equality
- C++20 provides member-wise equality (and inequality) by explicitly defaulting `operator==()`

- For C++11 until C++20
    - Use `std::tie()` as a simple mechanism to implement equality
    - Declare `operator==()` as a non-member operator
        - Otherwise implicit conversions will apply different for the left and right argument
    - A `friend` declaration may be used to implement directly in the class definition
        - `inline` is implied
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
```cpp
namespace v2 {

// C++20

class my_type {
    int _a = 0;
    int _b = 42;

public:
    my_type(const my_type&) = default;
    my_type& operator=(const my_type&) = default;

    bool operator==(const my_type&) const = default;
};

} // namespace v2
```
<!-- #endregion -->

```c++ slideshow={"slide_type": "slide"}
namespace v2 {

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

} // namespace v2
```

<!-- #region slideshow={"slide_type": "slide"} -->
- If the value representation of an object is unique, then representational equality _is_ value equality
    - Otherwise representational equality _implies_ value equality, but not the converse
- Representational equality satisfies the axioms for equality as well as copy
- If value equality is not implementable in time proportional to the area of the object then implement `operator==()` as representational equality
    - This usually means in terms of _identity_ of the remote parts
    - Examples include functions and some graph structures
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "fragment"} -->
- Functions can be compared by identity
- Lambda objects are not equality comparable
    - When stored in an object they usually represent a _relationship_ and will be discussed later
<!-- #endregion -->

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
- A type that is both equationally and computationally complete can be copied without the use of the copy-constructor or assignment operator
  - Equationally complete implies all the parts are readable
  - Computationally complete implies all the values are obtainable
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "notes"} -->
**Note:** Give the example of std::size() for expected complexity.
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
### Whole-Part Relationship

- A common and useful relationship is the _whole-part_ relationship
- An object is a whole, composed of its parts
- A part is _local_ if it is stored directly in the object
    - i.e. a data member
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
namespace v3 {

class my_type {
    int _val; // local part
    //...
};

} // namespace v3
```

<!-- #region slideshow={"slide_type": "slide"} -->
- A part is remote if it is stored elsewhere (such as on the heap)
  - Variable size data (polymorphic or collections)
  - Trade-off in performance of copy vs. _move_
  - Sharing of immutable data
  - Separation of interface from implementation dependencies (PImpl)
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "fragment"} -->
- Remote parts are expensive
    - Allocation + deallocation costs is over 200-500x more expensive than copying a word
    - Each access is a potential cache miss
    - Most objects are never or rarely copied
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "notes"} -->
**Note:** I can copy 1.5K - 4K of data in the time it takes for one allocation+ deallocation
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "skip"} tags=[] -->
_\[The following cell is an iframe for an [ithare infographic](http://ithare.com/infographics-operation-costs-in-cpu-clock-cycles/)\]_
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} tags=[] -->
<section>
<iframe data-src='http://ithare.com/infographics-operation-costs-in-cpu-clock-cycles/'></iframe>
</section>
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
- Prefer local parts when appropriate
- But also be aware that techniques like PImpl can greatly improve build time and reduce header file pollution
    - In C++20, modules may make this less necessary
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
**Exercise**: Implement a type with a remote part holding a pair of integers.
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
// 02-types.hpp

namespace v4 {

class my_type {
    struct implementation;     // forward declaration
    /* <some_type> _remote; */ // remote part
public:
    my_type(int x, int y);
    ~my_type();
    my_type(const my_type&);
    my_type& operator=(const my_type&);
};

} // namespace v4
```

```c++ slideshow={"slide_type": "slide"}
// 02-types.cpp

// #include "02-types.hpp" // first include

// other includes

namespace v4 {

struct my_type::implementation {
    int _x;
    int _y;
};

/*
    Fill in the rest...
*/

} // namespace v4
```

<!-- #region slideshow={"slide_type": "fragment"} -->
- A major downside of using the PImpl pattern is the amount of forwarding boiler plate that must be written.
<!-- #endregion -->

```c++ slideshow={"slide_type": "slide"}
// 02-types.hpp
#include <memory>

namespace v41 {

class my_type {
    struct implementation;              // forward declaration
    struct deleter {
        void operator()(implementation*) const;
    };
    std::unique_ptr<implementation, deleter> _remote; // remote part
public:
    my_type(int x, int y);
    ~my_type() = default;
    my_type(const my_type&);
    my_type& operator=(const my_type&);
};

} // namespace v4
```

```c++ slideshow={"slide_type": "slide"}
// 02-types.cpp

// #include "02-types.hpp" // first include

// other includes

namespace v41 {

struct my_type::implementation {
    int _x;
    int _y;
};

my_type::my_type(int x, int y) : _remote{new implementation{x, y}} {}
my_type::my_type(const my_type& a) : _remote{new implementation{*a._remote}} {}
my_type& my_type::operator=(const my_type& a) {
    *_remote = *a._remote;
    return *this;
}

void my_type::deleter::operator()(implementation* p) const { delete p; }

} // namespace v41
```

```c++ slideshow={"slide_type": "slide"}
{
    using namespace v41;

    my_type a{10, 20};
    my_type b = a;
    a = b;
}
```

<!-- #region slideshow={"slide_type": "slide"} -->
- It compiles and runs, what else do we need to make a valid unit test?
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "fragment"} -->
**Exercise:** Implement `operator==()` on my_type.
<!-- #endregion -->

```c++ slideshow={"slide_type": "slide"}
// 02-types.hpp
#include <memory>

namespace v42 {

class my_type {
    struct implementation; // forward declaration
    struct deleter {
        void operator()(implementation*) const;
    };
    std::unique_ptr<implementation, deleter> _remote; // remote part
public:
    my_type(int x, int y);
    ~my_type() = default;
    my_type(const my_type&);
    my_type& operator=(const my_type&);

    friend bool operator==(const my_type&, const my_type&);
    friend bool operator!=(const my_type& a, const my_type& b) { return !(a == b); }
};

} // namespace v42
```

<!-- #region slideshow={"slide_type": "notes"} -->
**Note:** A bit esoteric, but declaring a free function in a class is not callable either qualified or unqualified, and can only be found by ADL. The advantage of doing this is we improve compile speed by keeping overloads out of the potential overload set for other types.
<!-- #endregion -->

```c++ slideshow={"slide_type": "slide"}
#include <tuple>

namespace v42 {

struct my_type::implementation {
    int _x;
    int _y;

    auto underlying() const { return std::tie(_x, _y); }
};

my_type::my_type(int x, int y) : _remote{new implementation{x, y}} {}
my_type::my_type(const my_type& a) : _remote{new implementation{*a._remote}} {}
my_type& my_type::operator=(const my_type& a) {
    *_remote = *a._remote;
    return *this;
}

void my_type::deleter::operator()(implementation* p) const { delete p; }

bool operator==(const my_type& a, const my_type& b) {
    return a._remote->underlying() == b._remote->underlying();
}

} // namespace v42
```

```c++ slideshow={"slide_type": "slide"}
{
    using namespace v42;

    my_type a{10, 20};
    my_type b = a;
    assert(a == b);
    b = my_type{5, 30};
    assert(a != b);
    a = b;
    assert(a == b);
}
```

<!-- #region slideshow={"slide_type": "fragment"} -->
- Equality is important to testing
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
- Being able to reason about a subject in terms of equivalence is known as _equational reasoning_
    - The notion of equality is critical, not just for testing, but for reasoning about a piece of code
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
### `std::regular<T>`

The C++20 standard defines the _concept_ std::regular<T> to be copyable, equality-comparable, and default-constructible. Default-constructible is covered later in this section, and concepts are discussed more in Chapter 3, Algorithms.
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} toc-hr-collapsed=false slideshow={"slide_type": "slide"} -->
## Safety and Efficient Basis
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
### Safety

- An object which represents an entity is _fully-formed_, or _well-formed_
- An object which does not represent an entity, but may be modified (i.e. through assignment) to establish a correspondence with an entity, or destroyed, is _partially-formed_.
- An object which does not represent an entity and cannot be safely modified to represent an entity, or destroyed, is _ill-formed_.
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "fragment"} -->
- Any operation which preserves the correspondence between an object and an entity it represents is _safe_
- An operation which loses the correspondence is _unsafe_
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} tags=[] -->
- There are different categories of safety:

- _memory safety_
  - A memory safe operation preserves the correspondence of unrelated objects to their respective entities. For example, writing through a deleted pointer is a not a memory safe operation as it may leave an unrelated object ill-formed.

- _thread safety_
 - A thread safe operation may be executed concurrently with other operations on the same object(s) without the possibility of a race condition (data or logical race) resulting an an object which is not full-formed.

- _exception safety_
 - An exception safe operation is one which after an exception any objects being operated on are in a _fully-formed_ state. C++ refers to this as the _strong exception guarantee_.
 - An operation satisfying the _basic exception guarantee_ ensures that after an exception any objects being operated on are partially-formed.
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
- _operational safety_
  - An operation is operationally safe if, when the operation preconditions are satisfied, the operation results in objects which are fully-formed
  - An operation is operationally unsafe if, when the operation preconditions are satisfied, the operation may result in an object which is partially-formed
  - From here on, when referring to a _safe_ operation we mean _operationally safe_
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
- As a general rule
  - Only safe operations should be public
  - Unsafe operations should be private
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} toc-hr-collapsed=false slideshow={"slide_type": "slide"} -->
### Efficient Basis

- An operation is _efficient_ if there is no way to implement it to use fewer resources:
  - time
  - space
  - energy

- Unless otherwise specified, we will use efficiency to mean _time efficiency_
    - But in practice, where not all three can be achieved the trade-offs should be considered
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
> A basis is _efficient_ if and only if any procedure can be implemented as efficiently using it as an equivalent procedure written in terms of an alternative basis.
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} toc-hr-collapsed=false slideshow={"slide_type": "slide"} -->
- Making all data members public ensures an efficient basis, but may be _unsafe_
- In fact, we can prove that some operations cannot be implemented both efficiently and safely
- The canonical example is in-situ sort, although it is true of any in-situ permutation
  - This is why functional languages do not allow direct in-situ operations

- In C++, explicit `move` is both unsafe and inefficient
  - It is less safe than copy
  - But more efficient than copy

- Strive to make operations safe _and_ efficient
- Only sacrifice safety for efficiency with good (measurable) reason
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

<!-- #region slideshow={"slide_type": "notes"} -->
**Note:** The C++ standard does not require that _move_ is `noexcept`, and so doesn't require efficiency
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "fragment"} -->
- In C++ we implement the move operation in terms of rvalue references.
    - An rvalue is a temporary value
    - Any references to remote parts can be maintained without copying the remote part
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
**Exercise:** Implement move-construction and move-assignment operators on `my_type`.
<!-- #endregion -->

```c++ slideshow={"slide_type": "slide"}
namespace v43 {

class my_type {
    struct implementation; // forward declaration
    struct deleter {
        void operator()(implementation*) const;
    };
    std::unique_ptr<implementation, deleter> _remote; // remote part
public:
    my_type(int x, int y);
    ~my_type() = default;
    my_type(const my_type&);
    my_type& operator=(const my_type&);

    my_type(my_type&&) noexcept = default;   // <--
    my_type& operator=(my_type&&) = default; // <--

    friend bool operator==(const my_type&, const my_type&);
    friend bool operator!=(const my_type& a, const my_type& b) { return !(a == b); }
};

} // namespace v43
```

<!-- #region slideshow={"slide_type": "slide"} -->
- Recall our implementation of assignment:
```cpp
my_type& my_type::operator=(const my_type& a) {
    *_remote = *a._remote;
    return *this;
}
```
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "fragment"} -->
**Question:** What happens if we assign-to a moved from object?
<!-- #endregion -->

```c++ slideshow={"slide_type": "slide"}
namespace v43 {

struct my_type::implementation {
    int _x;
    int _y;

    auto underlying() const { return std::tie(_x, _y); }
};

my_type::my_type(int x, int y) : _remote{new implementation{x, y}} {}
my_type::my_type(const my_type& a) : _remote{new implementation{*a._remote}} {}

my_type& my_type::operator=(const my_type& a) { // <--
    if (!_remote) *this = my_type{a};
    *_remote = *a._remote;
    return *this;
}

void my_type::deleter::operator()(implementation* p) const { delete p; }

bool operator==(const my_type& a, const my_type& b) {
    return a._remote->underlying() == b._remote->underlying();
}

} // namespace v43
```

```c++ slideshow={"slide_type": "slide"}
{
    using namespace v43;

    my_type a{10, 20};
    my_type b{move(a)};
    a = my_type{5, 30};
    assert((b == my_type{10, 20}));
    assert((a == my_type{5, 30}));
}
```

<!-- #region slideshow={"slide_type": "slide"} -->
- The requirements in the C++ standard are that we must leave the moved from object in a _"unspecified"_ state
  - _Unspecified_ is without correspondence to an entity
  - explicit move is a public unsafe operation, it may leave the moved-from object in a partially formed state
- Some operations are required on the otherwise unspecified state
    - destruction
    - copy and move assigning to the object (to establish a new value)
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
- There is a trade-off between safety, and efficiency
  - Not every operation can be implemented to be both safe, and efficient (provably)
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
- There are many examples of unsafe operations with the built-in types:
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
double x = 0.0 / 0.0; // explicitly undefined
x
```

```c++ slideshow={"slide_type": "fragment"}
{
    int x; // unspecified
    display(x); // undefined behavior!
}
```

```c++ slideshow={"slide_type": "slide"}
string x = "hello world";
string y = move(x); // unspecified
x
```

```c++ slideshow={"slide_type": "fragment"}
unique_ptr<int> x = make_unique<int>(42);
unique_ptr<int> y = move(x); // safe. x is guaranteed to be == nullptr
(x == nullptr)
```

<!-- #region slideshow={"slide_type": "slide"} -->
- After an unsafe operation where an object is left partially formed
  - Subsequent operations are required to restore the fully formed state prior to use
    - If the partially formed state is _explicit_ it may by used in subsequent operation but those operations must yield explicitly undefined values for later detection and handling
    - i.e. NaN, [expected](https://wg21.link/P0323), maybe-monad pattern
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
### Explicit Move
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "fragment"} -->
- A _sink_ argument is an argument that will be stored or returned from a function.
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "fragment"} -->
- Pass sink arguments by universal reference or value and `forward<>` or `move()` them into place.
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "fragment"} -->
- This is the most common usage where an explicit move is required for efficiency. Try to avoid other uses by transforming the code into a functional form.
<!-- #endregion -->

```c++ slideshow={"slide_type": "slide"}
namespace v5 {

class example {
    string _str;

public:
    template <class T>
    example(T&& a) : _str{std::forward<T>(a)} {}
    // or
    example(string a) : _str{std::move(a)} {}
};

} // namespace v5
```

```c++ slideshow={"slide_type": "fragment"}
{
    using namespace v5;
    // Don't
    string str{"Hello World!"};
    example item1{move(str)};

    // Do
    example item2{"Hello World!"};
}
```

<!-- #region slideshow={"slide_type": "notes"} -->
**Note:** I once had a colleague who went through my code and split out every sub-expression and assigned it to a variable, with no moves, and then complained my code was slow.
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
## Default Construction

- What should the state be of a default constructed object?
    - Should it always be fully-formed?

- A common use case of a default constructed object is to create the object before we have a value to give to it:
<!-- #endregion -->

```c++ slideshow={"slide_type": "skip"}
namespace v11 {

bool predicate() { return true; }

std::pair<std::string, std::string> get_pair() {
    return std::make_pair<string, string>("Hello", "World");
}

} // namespace v11
```

```c++ slideshow={"slide_type": "slide"}
{
    using namespace v11;

    string s;
    if (predicate()) s = "Hello";
    else s = "World";
}
```

```c++ slideshow={"slide_type": "fragment"}
{
    using namespace v11;

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
    using namespace v11;

    string s = predicate() ? "Hello" : "World";
}
```

```c++ slideshow={"slide_type": "fragment"}
{
    using namespace v11;

    auto [s1, s2] = get_pair();
}
```

<!-- #region slideshow={"slide_type": "slide"} -->
- This makes having a default constructor optional
    - But not having one can be inconvenient
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "fragment"} -->
- A default constructed value is often overwritten before use
    - It is inefficient to allocate memory, or acquire resources, in the default constructor
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
- A default constructor should:
    - Be noexcept (one way to do this is to initialize to point to a const (or constexpr) singleton)
    - Be `constexpr`
    - Execute in time no worse than the time proportional to the `sizeof()` the object
    - If the object has a meaningful _zero_ or _empty_ state it should initialize to that state
        - Otherwise it may be partially-formed
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
- Recommendation
    - Provide a default-ctor
    - Avoid using it unless it has a meaningful zero or empty value
    - A similar effect can always be achieved using `std::optional<>`
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "fragment"} -->
- Default-construction is only included in `std::regular<>` for historical reasons
    - The classical definition of regular predates `move` as a basis operation
        - Instead, `move` was done with default-construction and swap
    - Default construction is not required by any standard algorithm
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "skip"} -->
**Exercise:** Implement a default constructor for `my_type`.
<!-- #endregion -->

```c++ slideshow={"slide_type": "slide"}
namespace v44 {

class my_type {
    struct implementation; // forward declaration
    struct deleter {
        void operator()(implementation*) const;
    };
    std::unique_ptr<implementation, deleter> _remote; // remote part
public:
    constexpr my_type() noexcept = default; // <--

    my_type(int x, int y);
    ~my_type() = default;
    my_type(const my_type&);
    my_type& operator=(const my_type&);

    my_type(my_type&&) noexcept = default;
    my_type& operator=(my_type&&) = default;

    friend bool operator==(const my_type&, const my_type&);
    friend bool operator!=(const my_type& a, const my_type& b) { return !(a == b); }
};

} // namespace v44
```

<!-- #region toc-hr-collapsed=false slideshow={"slide_type": "slide"} -->
## Expressiveness
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} toc-hr-collapsed=false slideshow={"slide_type": "slide"} -->
### Public calls with private access

- In general we want the minimum number of public calls with private access to provide a type which is:
    - Computationally Complete
    - Equationally Complete
    - Efficient
    - Safe (except as _required_ for efficiency)
    - Operations required to be part of the class interface by the language (i.e., you cannot implement a stand-alone assignment operator)

- Other operations should be implemented in terms of those
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "fragment"} -->
- What other operations should be provide?
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} toc-hr-collapsed=false slideshow={"slide_type": "slide"} -->
### Expressive Basis

> A basis is _expressive_ if it allows compact and convenient definitions of procedures on the type.
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "fragment"} -->
- As an example, consider the standard operators, given `operator<()` we don't need the other comparisons:
    - `(a > b) == (b < a)`
    - `(a <= b) == !(b < a)`
    - `(a >= b) == !(a < b)`
    - `(a == b) == !(a < b || b < a)`
    - `(a != b) == (a < b || b < a)`
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
- Writing:
```cpp
if (!(a < b || b < a)) some_operation();
```
is not as expressive as:
```cpp
if (a == b) some_operation();
```
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
- Where we have standard operators or other strong conventions, supply those operations
- Supply any other operations that are likely to be common
    - Unless they can be provided in a generic fashion across types

- This still leaves a fair amount up to the designer to choose how to balance safety and efficiency and what _expressive_ means in the context of the type
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
## Other Operations
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
### Address-of
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "fragment"} -->
- Because every object exists in memory, every object has an address.
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "fragment"} -->
- Even though you can overload `operator&()`, don't.
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "fragment"} -->
- For the paranoid library writeer, the standard supplies `std::addressof()`.
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
### Hash
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "fragment"} -->
- Because every object exists in memory, it's representation can be hashed
- Representationally equal objects imply equal hashes, not the converse
- The standard allows you to specialize `std::hash<>` for your type
- The standard does not provide a `hash_combine()` function or a tuple hash
- [Boost provides both](https://www.boost.org/doc/libs/1_75_0/doc/html/hash.html) which can be used with `std::tie()` to easily provide a hash function
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
### Serialization
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "fragment"} -->
- Although any equationally complete type can be serialized, the standard doesn't provide a standard serialization format
- Still, supporting `operator<<()` for ostream is useful for debugging
<!-- #endregion -->

```c++ slideshow={"slide_type": "slide"}
namespace v45 {

class my_type {
    struct implementation; // forward declaration
    struct deleter {
        void operator()(implementation*) const;
    };
    std::unique_ptr<implementation, deleter> _remote; // remote part
public:
    constexpr my_type() noexcept = default;

    my_type(int x, int y);
    ~my_type() = default;
    my_type(const my_type&);
    my_type& operator=(const my_type&);

    my_type(my_type&&) noexcept = default;
    my_type& operator=(my_type&&) = default;

    friend bool operator==(const my_type&, const my_type&);
    friend bool operator!=(const my_type& a, const my_type& b) { return !(a == b); }

    friend std::ostream& operator<<(std::ostream&, const my_type&);
};

} // namespace v44
```

```c++ slideshow={"slide_type": "skip"}
namespace v45 {

struct my_type::implementation {
    int _x;
    int _y;

    auto underlying() const { return std::tie(_x, _y); }
};

my_type::my_type(int x, int y) : _remote{new implementation{x, y}} {}
my_type::my_type(const my_type& a) : _remote{new implementation{*a._remote}} {}

my_type& my_type::operator=(const my_type& a) {
    if (!_remote) *this = my_type{a};
    *_remote = *a._remote;
    return *this;
}

void my_type::deleter::operator()(implementation* p) const { delete p; }

bool operator==(const my_type& a, const my_type& b) {
    return a._remote->underlying() == b._remote->underlying();
}

} // namespace v43
```

```c++ slideshow={"slide_type": "slide"}
namespace v45 {

ostream& operator<<(ostream& out, const my_type& a) {
    const auto& self{*a._remote};
    return out << "{ \"x\": " << self._x << ", \"y\": " << self._y << " }";
}

} // namespace v45
```

```c++ slideshow={"slide_type": "fragment"}
{
    using namespace v45;

    my_type a{10, 42};
    cout << a << "\n";
}
```

<!-- #region slideshow={"slide_type": "slide"} -->
### Ordering
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "fragment"} -->
- Covered in the next section
<!-- #endregion -->
