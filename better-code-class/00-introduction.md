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
```

<!-- #region slideshow={"slide_type": "slide"} -->
# Introduction

> Engineering is making informed trade-offs to find the best solution given a set of constraints.


> My hope is that this workshop is generally applicable, but the choices I've made are colored by my experience.
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
## Career Background
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
## Demo
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
## Philosophy

- _Correct_
- _Performant_
    - On a wide variety of consumer and enterprise hardware
    - Balance CPU/GPU/ML/Memory/Storage/Power resources
- _Scalable_
    - With large data sets, but primarily on a single machine
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
## Course Outline

- Introduction
- Preface
- Types
    - Goal: Write _complete_, _expressive_, and _efficient_ types
- Algorithms
    - Goal: No _raw_ loops
- Data Structures
    - Goal: No _incidental_ data structures
- Concurrency
    - Goal: No _raw_ synchronization
- Relationships
    - Goal: No contradictions
- Epilogue
<!-- #endregion -->

Find a place:
Requirements vs. Guarantees (Algorithms)
Physical nature of machine - transistors (Preface)
Keep philosophy - redundant with preface?

Story Arc -
- Types - task
- Algorithms - heaps
- Data structure - priority queue, queue
- Concurrency - timer tasks, sequential process
- Relationship (rename architecture?) - declarative flow graph?
