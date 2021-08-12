---
jupyter:
  jupytext:
    formats: ipynb,md
    text_representation:
      extension: .md
      format_name: markdown
      format_version: '1.3'
      jupytext_version: 1.11.3
  kernelspec:
    display_name: C++17
    language: C++17
    name: xcpp17
---

<!-- #region tags=[] slideshow={"slide_type": "slide"} -->
# Relaxing Requirements of Moved-From Objects

P2345

Sean Parent, sean.parent@stlab.cc
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} tags=[] -->
## Motivation and Scope

Given an object, `rv`, which has been moved from, the C++20 Standard specifies the required postconditions of a moved-from object:

`rv`’s state is unspecified
\[_Note:_ `rv` must still meet the requirements of the library component that is using it. The operations listed in those requirements must work as specified whether `rv` has been moved from or not. — end note\] — Table 28, p. 488 C++20 Standard.

Wording applies to both _Cpp17MoveConstructible_ and _Cpp17MoveAssignable_.
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "notes"} tags=[] -->
Discuss why this is:

- Doesn't actually specify what operations are required in absense of the non-normative note.
- In practice not achievable per a strong reading of the non-normative note.

- Does not compose

Side note: I've been discussing this with Dave Abrahams - He believe he wrote the wording "`rv`'s state is unspecified" but the non-normative note was added later and does not reflect the intended meaning.
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} tags=[] -->
## Requirements of a Moved-From Object

All known standard library implementations only require the following operations on a moved from object, `mf`.

- `mf.~()` (The language also requires this for implicitly moved objects)
- `mf = a`
- `mf = move(a)`
- `mf = move(mf)` (Required for swap)
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} tags=[] -->
## Non-Requirements
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} tags=[] -->
```cpp
T a[]{ v0, v1, v1, v2 };
(void)remove(begin(a), end(a), v1);
sort(begin(a), end(a));
```

Not required to be valid.
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "notes"} tags=[] -->
Not required to be valid (removed elements are unspecified and may not satisfy the requirements of sort).
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} tags=[] -->
```cpp
for (std::string line; std::getline(std::cin, line);) {
  v.push_back(std::move(line));
}
```

Not effected by the change, call to `line.erase()` invoked in `getline()` remains guaranteed to be valid for `std::string`.
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} tags=[] -->
## Standard Wording
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} tags=[] -->
### _Domain of the operation_

> Unless otherwise specified, there is a general precondition for all operations that the requirements hold for values within the _domain of the operation_.

> The term _domain of the operation_ is used in the ordinary mathematical sense to denote the set of values over which an operation is (required to be) defined. This set can change over time. Each component may place additional requirements on the domain of an operation. These requirements can be inferred from the uses that a component makes of the operation and is generally constrained to those values accessible through the operation’s arguments.
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} tags=[] -->
### Options

Two options are presented that differ in how they handle the requirement for self-move-assignment imposed by `swap()` implementations.
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} tags=[] -->
### Opton 1

Requires that a moved-from object can be used as an rhs argument to move-assignment only in the case that the object has been moved from and it is a self-move-assignment.

This is the weakest requirement, but making it weak adds some complexity.
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} tags=[] -->
### Option 2

Requires that a moved-from object can be used as an rhs argument to move-assignment always and the result of self-move-assignment is unspecified.

Broader and most similar to current requirements. In practice, it does impose additional complexity for implementations (with a possible performance hit) as well as carving out exceptions in documentation.
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} tags=[] -->
### Discussion
<!-- #endregion -->
