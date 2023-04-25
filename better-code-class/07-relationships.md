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

<!-- #region slideshow={"slide_type": "slide"} -->
# Architecture

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
