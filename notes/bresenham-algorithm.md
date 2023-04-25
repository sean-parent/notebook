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

Bresenham Algorithm

```c++
#include <cassert>
#include <cstdint>
#include <iostream>
#include <climits>

using namespace std;
```

```c++
// dx - 1 <= INT_MAX - dy
// dx <= INT_MAX - dy + 1
```

```c++ tags=[]
template <class F>
void bresenham_line(int dx, int dy, F out) {
    assert((0 <= dy) && (dy <= dx) && (dx <= (INT_MAX - dy)));

    for (int x = 0, y = 0, a = dy / 2; x != dx; ++x) {
        out(x, y);
        a += dy;
        if (dx <= a) {
            ++y;
            a -= dx;
        }
    }
}
```

```c++ tags=[]
template <class F>
void fast_bresenham_line(unsigned dx, unsigned dy, F out) {
    assert(dy < dx);

    dy = (UINT_MAX + 1.0) * dy / dx;

    for (unsigned x = 0, y = 0, a = dy / 2; x != dx; ++x) {
        out(x, y);
        a += dy;     // add ebx, r12d
        y += a < dy; // addc r15d, 0
    }
}
```

```c++
UINT_MAX
```

```c++
unsigned((UINT_MAX + 1.0) * (UINT_MAX - 1.0) / UINT_MAX) == UINT_MAX
```

```c++
bresenham_line(10, 6, [](auto, auto y){ cout << string(y, ' ') << "*\n"; });
```

```c++
fast_bresenham_line(10, 6, [](auto, auto y){ cout << string(y, ' ') << "*\n"; });
```
