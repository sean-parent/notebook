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
# The Cost of Copy

![performance-move](img/performance-move.png)

<div style="text-align:center">
    <a style="text-align:center" href="http://quick-bench.com/0wIVJCnNL8z7oRGL7SpR24d2ytQ">Cost of Copy</a>
</div>

<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
- To find the places where copy-ctor and copy-assignment are called, mark them deprecated
    - Along with setting breakpoints
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
class example {
public:
    example() = default;
    [[deprecated]] example(const example&) = default;
    example(example&&) noexcept = default;
    [[deprecated]] example& operator=(const example&) = default;
    example& operator=(example&&) noexcept = default;
};
```

```c++ slideshow={"slide_type": "slide"}
example x;
example y = x;
```

<!-- #region slideshow={"slide_type": "slide"} -->
## Copy Location and Pass By Value

- When passing an lvalue as a by value argument, the copy occurs at the call site
- For non-inline functions this may cause binary bloat
    - Can use pass-by rvalue and lvalue reference for such cases
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
class sink {
    example _m;
public:
    void set(example e) { _m = std::move(e); }
};
```

```c++ slideshow={"slide_type": "slide"}
sink s;
s.set(x);
```

```c++ slideshow={"slide_type": "slide"}
class sink2 {
    example _m;
public:
    void set(const example& e) { _m = e; }
    void set(example&& e) { _m = std::move(e); }
};
```

```c++ slideshow={"slide_type": "fragment"}
sink2 s;
s.set(x);
```
