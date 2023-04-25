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
#include <set>
#include <atomic>

using namespace std;
```

<!-- #region slideshow={"slide_type": "slide"} -->
# Lambda Expression Follow-up
- Homework to use a lambda expression with a standard algorithm or container
```cpp
set<int, ???> s; // How do you use a lambda for a comparison type?
```
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "fragment"} -->
- You cannot
    - Best you can do is use a pointer to function or std::function and pass the lambda to the constructor as comparison
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
{
    set<int, bool (*)(int a, int b)> s{[](int a, int b) { return a > b; }};
}
```

<!-- #region slideshow={"slide_type": "slide"} -->
- Disadvantage is the expression cannot be inlined
- Recommendation - continue to use function objects
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
{
    set<int, greater<>> s;
}
```

<!-- #region slideshow={"slide_type": "slide"} -->
# Memory Order Follow-up

- It wasn't clear in my slides that C++11 allows you to specify the memory order on many operations
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
atomic<int> x;
x.store(10, memory_order_relaxed);
```

<!-- #region slideshow={"slide_type": "fragment"} -->
- You can specify the memory order for
    - operations on atomics
    - explicitly with `std::atomic_thread_fence`, `std::atomic_signal_fence`
    - and can explicitly control dependencies with `std::kill_dependency`
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
- The memory order controls
    - How the compiler can reorder operations on possibly shared memory around the atomic operations
    - Which instructions the compiler emits to control processor memory ordering around the atomic operations
<!-- #endregion -->

```c++

```
