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
# Better Code Workshop : Sean Parent
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
# Introduction

> _Engineering_ is making informed trade-offs to find the best solution given a set of constraints.
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "fragment"} tags=[] -->
My hope is that this workshop is generally applicable, but my experience colors the choices I've made.
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
## Career Background
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
## Demo
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
## Course Outline

- Introduction
- Preface
- Types - Goal: Write _complete_, _expressive_, and _efficient_ types
- Algorithms - Goal: No _raw loops_
- Data Structures - Goal: No _incidental data structures_
- Runtime Polymorphism - Goal: No _raw pointers_
- Concurrency - Goal: No _raw synchronization primitives_
- Relationships - Goal: No contradictions
- Epilogue
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
## Materials

- Slides: https://sean-parent.stlab.cc/notebook
- Exercises: https://github.com/sean-parent/better-code-class
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} tags=[] -->
## Use of Jupyter w/Xeus-Cling
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} tags=[] -->
- Currently limited to C++17
    - I will provide some C++20 examples
- `using std;` is implied
- Definitions wrapped in a `namespace`
- Namespaces are often versions so I can refine implementations
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"} tags=[]
namespace v0 {

int f() { return 42; }

} // namespace v0
```


<!-- #region slideshow={"slide_type": "slide"} tags=[] -->
- Often code is wrapped in a scope so it doesn't interfere with other code
- If the last line doesn't have a semi-colon it is displayed
    - calling `display(value);` has the same effect
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"} tags=[]
v0::f()
```

```c++ slideshow={"slide_type": "fragment"} tags=[]
{
    using namespace v0;

    display(f());
}
```

<!-- #region slideshow={"slide_type": "slide"} tags=[] -->
- Operations can be timed with `%%timeit`
    - This is not a substitute for benchmarks but gives some information to compare
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"} tags=[]
%%timeit
{
    int a[] = { 9, 8, 7, 6, 5, 4, 3, 2, 1, 0 };
    sort(begin(a), end(a));
}
```

<!-- #region slideshow={"slide_type": "slide"} -->
- I use an `instrumented` class which prints common operations
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
{
    instrumented a;
    instrumented b;
    a = b;
    a = move(b);
}
```

<!-- #region slideshow={"slide_type": "skip"} -->
Story Arc -
- Types - task
- Algorithms - heaps
- Data structure - priority queue, queue
- Concurrency - timer tasks, sequential process
- Relationship (rename architecture?) - declarative flow graph?
<!-- #endregion -->
