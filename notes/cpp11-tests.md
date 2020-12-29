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

```c++
#define BCC_HAS_OPTIONAL() 0
#if __cplusplus >= 201703L
#  ifdef __has_include
#    if __has_include(<optional>)
#      include <optional>
#      undef BCC_HAS_OPTIONAL
#      define BCC_HAS_OPTIONAL() 1
#    endif
#  endif
#endif
```

```c++
#if BCC_HAS_OPTIONAL()
#warning "optional"
#else
#warning "no optional"
#endif
```

```c++
#include <type_traits>

#if !BCC_HAS_OPTIONAL()

namespace std {
inline namespace adobe_dcx {
    
template <class T>
class optional {
    std::aligned_storage_t<sizeof(T)> _storage;
    bool _has_value = false;
    
public:
    using value_type = T;
    
    constexpr optional() noexcept = default;
    
    constexpr optional(const optional& other) {
        if (!other.has_value()) {
        } else if (has_value()) {
            **this = *other;
        } else {
            new (&_storage) T(*other);
            _has_value = true;
        }
    }
    
    optional(optional&& other) noexcept(std::is_nothrow_move_constructible<T>::value && std::is_nothrow_move_assignable<T>::value) {
        if (!other.has_value()) {
            reset();
        } else if (has_value()) {
            **this = std::move(*other);
        } else {
            new (&_storage) T(std::move(*other));
            _has_value = true;
        }
    }
    
    template <class U = value_type>
    constexpr optional(U&& value) {
        new (&_storage) T(std::forward<U>(value));
        _has_value = true;
    }
    
    ~optional() {
        if (has_value()) (**this).T::~T();
    }
    
    void reset() noexcept {
        if (!has_value()) return;
        (**this).T::~T();
        _has_value = false;
    }
    
    [[deprecated("Only available with C++17")]] constexpr T& value() & = delete;
    [[deprecated("Only available with C++17")]] constexpr const T & value() const & = delete;
    [[deprecated("Only available with C++17")]] constexpr T&& value() && = delete;
    [[deprecated("Only available with C++17")]] constexpr const T&& value() const && = delete;
    
    T& operator*() { return reinterpret_cast<T&>(_storage); }
    const T& operator*() const { return reinterpret_cast<const T&>(_storage); }
    
    constexpr bool has_value() const noexcept {
        return _has_value;
    }
    
    constexpr explicit operator bool() const noexcept {
        return _has_value;
    }
    
    template <class U>
    constexpr T value_or(U&& default_value) const& {
        return has_value() ? (**this) : static_cast<T>(std::forward<U>(default_value));
    }
    template <class U>
    constexpr T value_or(U&& default_value) && {
        return has_value() ? std::move(**this) : static_cast<T>(std::forward<U>(default_value));
    }
};
    
struct nullopt_t {
    explicit constexpr nullopt_t(int) {}
};
    
}
}

#endif


```

```c++
using namespace std;
std::optional<int> x = 10;
```

```c++
*x
```

```c++
x.has_value()
```

```c++
x.value_or(42)
```

```c++
x.reset();
```

```c++
x.has_value()
```

```c++
x.value_or(42)
```

```c++
x.value()
```

Thought on tracked values -

A tracked value should be bound to an execution context. You want to be able to write:
```cpp
tracked | [](auto& x){
    x.stuff();
};
```
vs.
```cpp
async(executor, [] {
    if (auto p = tracked.lock()) {
        p->stuff();
    }
});
```

Should work with optional (and futures?) as well. Also, this would be when/if_all - requiring the same executor (how can you test that? - no equality on lambdas!)

```cpp
(track1, track2) | core | [](auto& x1, auto& x2){
       // use x1 an x2
} | surface ;
```

```c++

```
