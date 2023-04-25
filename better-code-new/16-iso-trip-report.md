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
# Trip Report

- On April 26th, 2018, I attended the ISO C++ Futures Design Meeting at Nvidia
- Goal of meeting; reach closure on a design for _futures_ in C++20
    - Must support the [_Executors_](http://www.open-std.org/jtc1/sc22/wg21/docs/papers/2018/p0761r2.pdf) proposal which is on track for C++20
        - Executors support heterogenous computation contexts, including GPGPU, and grid computing
    - [Coroutine TS](http://www.open-std.org/jtc1/sc22/wg21/docs/papers/2018/n4736.pdf) support which is planned to be included in C++20
    - The current futures defined in the [_Concurrency TS_](http://www.open-std.org/jtc1/sc22/wg21/docs/papers/2015/p0159r0.html) are not sufficient
    - Plan is for a  _Concurrency TS part 2_ which can be incorporated into C++20
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
- Notable progress
    - Refinement of future concepts
        - _SharedFuture_ is _Regular_
    - Allow rvalue optimizations
        - _SharedFuture_ concept does not unnessarily penalize Copyable futures
    - Support for optional task _cancelation_
        - Including cancelation across heterogenous contexts
    - Error handling no longer requires exceptions
        - Agreement reached on the capability, but o design consensus reached
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "fragment"} -->
- [`stlab::future<>`](http://stlab.cc/libraries/concurrency/future/future/) should be able to model SharedFuture with minor modifications
<!-- #endregion -->

```c++

```
