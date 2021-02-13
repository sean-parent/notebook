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

<!-- #region slideshow={"slide_type": "slide"} -->
# Data Structures and Structured Data
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
## Definitions
> *Classic:* A _data structure_ is a format for organizing and storing data.

- Doesn't define _structure_, replaces it with the related word, _format_
- In mathematics, _structure_ is defined as:

> A _structure_ on a set consists of additional entities that, in some manner, relate to the set, endowing the collection with meaning or significance.
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
- A type is a pattern for storing and modifying objects
- A type is a structure that relates a set of objects to a set of values
    - This is a _representational_ relationship
- A representational relationship creates a _trivial data structure_ consisting of a single value

- Values are related to other values, i.e. $3 \neq 4$
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
- Because objects exist in memory, they have a _physical_ relationship

> A _data structure_ is a structure utilizing value, representational, and physical relationships to encode semantic relationships on a collection of objects

- The choice of encoding can make a dramatic difference on the performance of operations
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
<center>
    <img src='img/memory-hierarchy.svg' alt='Memory Hierarchy'>
    <br>
    <em>Data from <a href='http://ithare.com/infographics-operation-costs-in-cpu-clock-cycles/'>IT Hare</a></em>
</center>
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
- A data structure is created anytime a relationship is established between objects
- To avoid confusion we will reserve the term _data structure_ to refer to types with a set of invariants which insure a set of relationship are maintained. i.e. standard containers
- More transient data structures will be referred to as _structured data_
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
## Problem
<!-- #endregion -->

```c++ slideshow={"slide_type": "slide"}
template <class I> // I models RandomAccessIterator
void sort_subrange_0(I f, I l, I sf, I sl) {
    std::sort(f, l);
}

template <class I> // I models RandomAccessIterator
void sort_subrange(I f, I l, I sf, I sl) {
    if (f != sf && sf != l) {
        std::nth_element(f, sf, l); // partition [f, l) at sf
        ++sf;
    }
    std::partial_sort(sf, sl, l);
}
```

<!-- #region slideshow={"slide_type": "slide"} -->
<center>
    <img src='img/sort-v-sort-subrange.png' alt='Sort v Sort Subrange'>
    <br>
    <em><a href='http://quick-bench.com/C0fww_d39OVBvCnoNrXUN5XU0nE'>Benchmark Code</a></em>
</center>
<!-- #endregion -->

```c++

```
