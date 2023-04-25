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
# Three Tools for C++ Presenters
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "fragment"} -->
Sean Parent | Sr. Principal Scientist, Adobe Photoshop
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
## reveal.js

_A framework for easily creating beautiful presentations using HTML._

https://github.com/hakimel/reveal.js/
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "fragment"} -->
Type `?` for help.
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "notes"} -->
show speaker notes.
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
## cling

_Cling is an interactive C++ interpreter, built on the top of LLVM and Clang libraries._

https://root.cern.ch/cling
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "notes"} -->
show cling
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
## Jupyter Lab

_Project Jupyter exists to develop open-source software, open-standards, and services for interactive computing across dozens of programming languages._

https://jupyter.org
<!-- #endregion -->

```c++ slideshow={"slide_type": "skip"}
#pragma cling add_include_path("../stlab/libraries")
```

```c++ slideshow={"slide_type": "skip"}
#include <iostream>

#define STLAB_DISABLE_FUTURE_COROUTINES 1
#include <stlab/concurrency/default_executor.hpp>
#include <stlab/concurrency/future.hpp>
#include <stlab/concurrency/utility.hpp>
```

```c++ slideshow={"slide_type": "skip"}
using namespace std;
```

```c++ slideshow={"slide_type": "skip"}
using namespace stlab;
```

```c++ slideshow={"slide_type": "slide"}
{
    auto p = async(default_executor, [] { return 42; });

    auto q = p.then([](int x) { cout << x << endl; });

    auto r = q.then([] { cout << "done!" << endl; });

    blocking_get(r); // <-- DON'T DO THIS IN REAL CODE!!!
}
```

<!-- #region slideshow={"slide_type": "slide"} -->
## Xeus Cling

_xeus-cling is a Jupyter kernel for C++ based on the C++ interpreter cling and the native implementation of the Jupyter protocol xeus._

https://github.com/QuantStack/xeus-cling
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
## More...

### Binder

_Have a repository full of Jupyter notebooks? With Binder, open those notebooks in an executable environment, making your code immediately reproducible by anyone, anywhere._

https://mybinder.org/

### GitHub

_When you add Jupyter Notebook or IPython Notebook files with a .ipynb extension on GitHub, they will render as static HTML files in your repository._

https://help.github.com/en/articles/working-with-jupyter-notebook-files-on-github
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
### JupyterHub

_Multi-user deployment infrastructure_

https://github.com/jupyterhub/jupyterhub

### Libraries

- Xwidgets: widgets enable interactive data visualization
- Xplot: 2D plotting
- Xtensor: Numerical analysis with multi-dimensional arrays
<!-- #endregion -->
