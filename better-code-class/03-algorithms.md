---
jupyter:
  jupytext:
    formats: ipynb,md
    text_representation:
      extension: .md
      format_name: markdown
      format_version: '1.3'
      jupytext_version: 1.10.2
  kernelspec:
    display_name: C++17
    language: C++17
    name: xcpp17
---

```c++ slideshow={"slide_type": "skip"}
#include "../common.hpp"
```

# Algorithms

**Goal: No raw loops**


> An _Algorithm_ is a process or set of rules to be followed in calculations or other problem-solving operations, especially by a computer.


## Trivial vs Non-Trivial Algorithms

The term _algorithm_ covers all code. If an algorithm does not require iteration or recursion, it is a _trivial_ algorithm. Otherwise it is a non-trivial algorithm. The standard includes trivial algorithms such as `std::swap()` and `std::exchange()`, but for this section the focus is on non-trivial algorithms.

<!-- #region slideshow={"slide_type": "slide"} -->
## Sequences

- For a sequence of _n_ elements their are _n + 1_ positions
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "fragment"} -->
- How to represent a range of elements?
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "fragment"} -->
- Problem with closed interval `[f, l]`?
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "fragment"} -->
- Problem with open interval `(f, l)`?
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "fragment"} -->
- Half-open intervals have significant advantages `[f, l)`
    - By strong convention we are open on the right
<!-- #endregion -->

- `[p, p)` represents an empty range, at position `p`
    - All empty ranges are not equal


- Think of the positions as the lines between the elements

<!-- #region slideshow={"slide_type": "slide"} -->
<center>
    <img src='img/sequence-1.svg' alt='Sequence 1'>
    <br>
    <em>Sequence With Pointers To Objects</em>
</center>
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
<center>
    <img src='img/sequence-2.svg' alt='Sequence 2'>
    <br>
    <em>Sequence With Pointers Between Objects</em>
</center>
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
- Limitations of half-open intevals
    - If there is not _next element_ then a half open interval cannot express a single element
    - If there is a finite number of elements, the last (or first) cannot be included
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
- There are different common ways to represent a sequence
<!-- #endregion -->

- A position `f` in a sequence can be denoted with an index, pointer, or iterator
    - The only requirement is that `f` be _incrementable_ to obtain the next element in the sequence

<!-- #region slideshow={"slide_type": "fragment"} -->
- `[f, l)`
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "fragment"} -->
- `[f, f + n) _n`
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "fragment"} -->
- `[f, predicate()) _until`
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "fragment"} -->
- `[f, is_sentinel())` NTBS
    - `const char*`
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "fragment"} -->
- `[f, ...)` unbounded (dependent on something else)
    - i.e. range is required to be same or greater length than another range
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "fragment"} -->
- For a variable `a` in C and C++, it is guaranteed that `&a + 1` yields a valid, but not dereferenceable, pointer
    - `[&a, &a + 1)` is a valid range
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "skip"} -->
**_Next two cells are algorithm-slide keynote_**
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
<section>
    <iframe data-src="./img/algorithm-slide/index.html"></iframe>
</section>
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
<section>
    <iframe data-src="./img/algorithm-gather/index.html"></iframe>
</section>
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
## Common algorithms and their uses

- A great resource for finding standard algorithms:
  - https://en.cppreference.com/w/cpp/algorithm
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
## Non-modifying sequence operations

- `find`
- `find_if`
- `find_if_not`
<!-- #endregion -->

- `find` returns the position of the first element in the range `[f, l)` that satisfies the specified criteria.

```c++
{
    int a[]{0, 1, 2, 3, 4, 5, 6, 7, 8, 9};
    display(*find(begin(a), end(a), 5));
}
```

**Question:** How do we know `find()` will _find_ a value?


- Iterator must meet the requirements of [_LegacyInputIterator_](https://en.cppreference.com/w/cpp/named_req/InputIterator)
- `[f, l)` must form a _valid range_
- the value type must be [_EqualityComparable_](https://en.cppreference.com/w/cpp/named_req/EqualityComparable) to the iterator `value_type`

<!-- #region slideshow={"slide_type": "slide"} -->
## Requirements and Guarantees
<!-- #endregion -->
- A generic algorithm is specified in terms of a set of _requirements_ on it's arguments. The requirements are a set of _concepts_ and _preconditions_ which, if satisfied, guarantee the algorithm performs as specified
- The C++ standard contains tables of [_named requirements_](https://en.cppreference.com/w/cpp/named_req) and [_concepts_](https://en.cppreference.com/w/cpp/header/concepts)


- Concepts and Preconditions are closely related and both ideas are rooted in [_Hoare Logic_](https://en.wikipedia.org/wiki/Hoare_logic)





<!-- #region slideshow={"slide_type": "slide"} -->
### Concept

The term _concept_ was coined by

> We call the set of axioms satisfied by a data type and a set of operations on it a _concept_.
<br> &emsp;&mdash; _Fundementals of Generic Programming_, James C. Dehnert and Alexander Stepanov

In C++20, a language _concept_ is a set of syntactic requirements with a set of specified, in documentation, semantic and complexity requirements.

- As with spoken language, we associate meaning with words
- Even this is controversial 

> Names should not be associated with semantics because
everybody has their own hidden assumptions about what semantics are,
and they clash, causing comprehension problems without knowing why.
This is why it's valuable to write code to reflect what code is
actually doing, rather than what code "means": it's hard to have
conceptual clashes about what code actually does.
<br> &emsp;&mdash; Craig Silverstein, personal correspondence

- _LegacyInputIterator_ and _EqualityComparable_ are concepts

#### Model

> We say that a concept is _modeled by_ specific types, or that the type _models_ the concept, if the requirements are satisfied for these types.

### Contracts

_Contracts_, or _Design by Contract_, is a systematic approach to ensuring the values passed to, and returned by an operation satisfy specific assertions.

> If the execution of a certain task relies on a routine call to handle one of its subtasks, it is necessary to specify the relationship between the client (the call- er) and the supplier (the called routine) as precisely as possible. The mechanisms for expressing such conditions are called assertions. Some assertions. called preconditions and postconditions. apply to individual routines. Others, the class invariants, constrain all the routines of a given class...
<br> &emsp;&mdash; _Applying "Design by Contract"_, Bertrand Meyer

#### Precondition
#### Invariant
#### Postcondition

- `[f, l)` must form a valid range is a precondition

- Concept semantics usually are specified in terms of existential quantifiers ($\forall$, $\exists$)
- Not all preconditions can be asserted in code
    - i.e. `f(int* p)` with the precondition that `p` is dereferenceable
    
- We must still validate, prove, our code by hand
<!-- #endregion -->

- A generic type or operation has a set of requirements on its arguments
- A given type guarantees it satisfies some requirements
- By matching requirements with guarantees we create software which works

<!-- #region slideshow={"slide_type": "slide"} -->
### Concepts, Partial Functions, and Domain
<!-- #endregion -->

Compare the description for the old [SGI STL LessThanComparable concept](http://www.martinbroadhurst.com/stl/LessThanComparable.html):

> Expression semantics
>
>| Name | Expression | Precondition                         | Semantics | Postcondition |
 | -    | -          | -                                    | -         | -             |
 | Less | `x < y`    | `x` and `y` are in the domain of `<` |           |               |
 
versus the [C++17 concept](https://eel.is/c++draft/utility.arg.requirements#tab:cpp17.lessthancomparable).

> Table 28: _CppLessThanComparable_ requirements
>
> | Expression | Return type           | Requirement                            |
> | -          | -                     | -                                      |
> | `a < b`    | convertible to `bool` | `<` is a strict weak ordering relation |

_In the SGI STL the requirement of [strict-weak-ordering](http://www.martinbroadhurst.com/stl/StrictWeakOrdering.html) was a separate concept._

<!-- #region slideshow={"slide_type": "slide"} -->
Domain is defined in the C++ standard, but in the [context of _iterators_](https://eel.is/c++draft/iterator.cpp17#input.iterators-2). This passage used to refer to the _domain of operations_, but that has been narrowed to the _domain of_ `==`:
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
> The term _the domain of_ `==` is used in the ordinary mathematical sense to denote the set of values over which `==` is (required to be) defined. This set can change over time. Each algorithm places additional requirements on the domain of `==` for the iterator values it uses. These requirements can be inferred from the uses that algorithm makes of `==` and `!=`.
>
> | Expression | Return type | Operational Semantics | Assertion/note<br>pre-/post-condition |
> | - | - | - | - |
> | `a != b` | contextually convertible to `bool` | `!(a == b)` | _Preconditions:_ (`a, b`) is in the domain of `==` |

<!-- #endregion -->

What was part of the definition of concepts in general has been weakened to a requirement for a single operation on iterators.

<!-- #region slideshow={"slide_type": "slide"} -->
## Modifying sequence operations

- `copy`
- `move`
- `fill`
- `transform`
- `generate`
- `iota`
<!-- #endregion -->

### OutputIterators


- OutputIterators are isomorphic with a function object
    - Function objects are simpler to write with lambda expressions


- `std::iota()` and `std::generate` would be better expressed with functions

```c++
namespace bcc {

template <class T, class F>
constexpr void iota(T first, T last, F out) {
    for (; first != last; ++first) {
        out(first);
    }
}

} // namespace bcc
```

```c++
{
    using namespace bcc;

    vector<int> v;
    bcc::iota(0, 10, [&](int n) { v.push_back(n); });
    display(v);
}
```

## Permutations

<!-- #region slideshow={"slide_type": "slide"} -->
### Sorting operations

- `sort`
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "fragment"} -->
- Comparison function is required to be a _strict-weak ordering_:

> An ordering relation, $\prec$, is a _strict-weak_ ordering iff

\begin{align}
(a & \nprec a). && \text{(Irreflexivity)} \\
(a & \prec b) \wedge (b \prec c) \implies a \prec c. && \text {(Transitivity)} \\
(a & \equiv b) \wedge (b \equiv c) \implies a \equiv c. && \text {(Equivalence Transitivity)}\\
\end{align}

> Where $a$ and $b$, are _equivalent_, $\equiv$, iff $(a \nprec b) \wedge (b \nprec a)$.
<!-- #endregion -->

- The default is to user `operator<()`
- On a type, the expectation is that `operator<()` is a _total ordering_
    - Which is consistent with other operations on the type

> A _total ordering_ is a strict-weak ordering where the defined equivalence is equality


- `operator<()` is not defined on `std::complex<>` because there is no definition consistent with multiplication
    - For example, both $i > 0$ and $i < 0$ imply that $0 < i^2$, however, $i^2 = -1$


- Despite `nan` values, both `float` and `double` are totally-ordered because `nan` is explicitly outside the value domain for floating point types. `nan` is _not a number_
- A floating point object containing `nan` is partially formed
- Don't try and sort a sequence containing `nan` values with `operator<()`
    - The result is UB and will likely crash
    
> _C++20 defines the ordering on floating-point types as a `std::partial_ordering` because of `nan` values. I find this complicates matters unnecessarily, and means the requirements of the comparison operator cannot be defined with a _concept_ but require a precondition._

<!-- #region slideshow={"slide_type": "slide"} -->
### Binary search operation

- `lower_bound`
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
**Exercise:** Review list of standard algorithms.
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "skip"} -->
**Exercise:** Find a _raw loop_ in the ZString implementation. Claim it on the wiki https://git.corp.adobe.com/better-code/class/wiki/class-04-registration. Improve the code, create a pull-request, and assign me as the reviewer. The PR should include a http://quick-bench.com/ benchmark of the relevant code for comparison.
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "skip"} -->
<!--- stopped here --->

## More advanced algorithms

## New Algorithms (C++11 - 20)

## Position Based Algorithms
  - All non-modifying sequence operations taking a predicate
  
## Strict Weak Order

## Iterator hierarchy (and why you probably shouldn't care)

## Writing a custom algorithm
- what to return

## Composition vs. multi-pass

## Generators vs input iterator

## Output iterators vs sink functions
<!-- #endregion -->

```c++
{
    int a[]{0, 1, 2, 3, 4, 5, 6, 7, 8, 9};

    auto p = remove_if(begin(a), end(a), [_n = 0](const int&) mutable {
        bool r = (2 <= _n) && (_n < 4);
        ++_n;
        return r;
    });

    display(a);
}
```

```cpp
template <class F, class P>
F remove_if(F first, F last, P pred) {
    first = find_if(first, last, pred);
    if (first == last) return first;

    F p = first;
    while (++p != last) {
        if (!pred(*p)) {
            *first = move(*p);
            ++first;
        }
    }
    return first;
}
```

```c++
{
    int a[]{0, 1, 2, 3, 4, 5, 6, 7, 8, 9};

    int n{0};
    auto p = remove_if(begin(a), end(a), [&](const int&) {
        bool r = (2 <= n) && (n < 4);
        ++n;
        return r;
    });

    display(a);
}
```

**Question:** Does the above code fix the issue?


- The requirement is that `pred` is a regular function although the standard wording is a [obtuse](https://eel.is/c++draft/algorithms#requirements-7):

> Given a glvalue `u` of type (possibly `const`) `T` that designates the same object as `*first`, `pred(u)` shall be a valid expression that is equal to `pred(*first)`.


[
- discuss (show graph) of O(1), O(log(N)), O(N), O(N log(N)
- where does the below code go?
]

```c++ tags=[]
{
    double a = numeric_limits<double>::quiet_NaN();
    display(a == a);
}
```
