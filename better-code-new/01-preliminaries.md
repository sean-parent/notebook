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

<!-- #region slideshow={"slide_type": "skip"} toc=true -->
<h1>Table of Contents<span class="tocSkip"></span></h1>
<div class="toc" style="margin-top: 1em;"><ul class="toc-item"><li><span><a href="#Preliminaries" data-toc-modified-id="Preliminaries-1"><span class="toc-item-num">1&nbsp;&nbsp;</span>Preliminaries</a></span><ul class="toc-item"><li><span><a href="#Class-Information" data-toc-modified-id="Class-Information-1.1"><span class="toc-item-num">1.1&nbsp;&nbsp;</span>Class Information</a></span></li><li><span><a href="#Brief-History-of-C++" data-toc-modified-id="Brief-History-of-C++-1.2"><span class="toc-item-num">1.2&nbsp;&nbsp;</span>Brief History of C++</a></span></li><li><span><a href="#C++11,-C++14,-C++17...-C++20,-TSs..." data-toc-modified-id="C++11,-C++14,-C++17...-C++20,-TSs...-1.3"><span class="toc-item-num">1.3&nbsp;&nbsp;</span>C++11, C++14, C++17... C++20, TSs...</a></span><ul class="toc-item"><li><span><a href="#Clang" data-toc-modified-id="Clang-1.3.1"><span class="toc-item-num">1.3.1&nbsp;&nbsp;</span>Clang</a></span></li><li><span><a href="#Boost" data-toc-modified-id="Boost-1.3.2"><span class="toc-item-num">1.3.2&nbsp;&nbsp;</span>Boost</a></span></li><li><span><a href="#The-Free-Lunch-Is-Over" data-toc-modified-id="The-Free-Lunch-Is-Over-1.3.3"><span class="toc-item-num">1.3.3&nbsp;&nbsp;</span>The Free Lunch Is Over</a></span></li><li><span><a href="#Language-Evolution" data-toc-modified-id="Language-Evolution-1.3.4"><span class="toc-item-num">1.3.4&nbsp;&nbsp;</span>Language Evolution</a></span></li></ul></li><li><span><a href="#Online-Resources" data-toc-modified-id="Online-Resources-1.4"><span class="toc-item-num">1.4&nbsp;&nbsp;</span>Online Resources</a></span><ul class="toc-item"><li><span><a href="#Information:" data-toc-modified-id="Information:-1.4.1"><span class="toc-item-num">1.4.1&nbsp;&nbsp;</span>Information:</a></span></li><li><span><a href="#Reference:" data-toc-modified-id="Reference:-1.4.2"><span class="toc-item-num">1.4.2&nbsp;&nbsp;</span>Reference:</a></span></li><li><span><a href="#Tools:" data-toc-modified-id="Tools:-1.4.3"><span class="toc-item-num">1.4.3&nbsp;&nbsp;</span>Tools:</a></span></li></ul></li><li><span><a href="#Other-Tools" data-toc-modified-id="Other-Tools-1.5"><span class="toc-item-num">1.5&nbsp;&nbsp;</span>Other Tools</a></span></li></ul></li><li><span><a href="#Demo" data-toc-modified-id="Demo-2"><span class="toc-item-num">2&nbsp;&nbsp;</span>Demo</a></span></li></ul></div>
<!-- #endregion -->

```c++ slideshow={"slide_type": "skip"}
#include <iostream>

using namespace std;
```

<!-- #region slideshow={"slide_type": "slide"} -->
# Preliminaries

- If you are using connect locally, mute your speaker and mic
- If you are remote, mute your mic
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
## Class Information

- https://git.corp.adobe.com/better-code/class/wiki
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
## Brief History of C++

- 1979 Bjarne Stroustrup begins work on C with Classes
- 1983 "C with Classes" renamed C++
- 1985 _The C++ Programming Language_ is published along with first commercial compiler, Cfront
- 1989 C++ 2.0 released with Cfront 2.0
- 1998 C++ published as ISO standard (C++98) with the STL from Alex Stepanov and Meng Lee
- 2003 C++03 ISO standard, minor revisions to C++98
- 2011 C++11 Major language update
- 2014 C++14 Revisions, minor additions, corrections to C++11
- 2017 C++17 Significant (not quite major) update
- 2020 ...
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
With C++11 there were significant process changes to encourage working groups to publish Technical Specifications (TS's) for experimental features, language and library, in advance of them being incorporated into the language. The process replaced the prior Technical Report (TR1) process which was used to vet library extensions prior to C++11.
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
## C++11, C++14, C++17... C++20, TSs...

### Clang

- 2000 LLVM project is started at University of Illinois at Urbana-Champaign by Vikram Adve and Chris Lattner
    - later adding ObjC and C support
- 2005 Apple hires Lattner, initially working on Clang OpenGL compiler
- 2009 GCC runtime library moves to GPLv3 license, Apple (and others) move to add C++ support to Clang
- 2010 Clang++ able to build Boost libraries and passes nearly all tests
- Clang now actively developed by Apple, Microsoft, Google, ARM, Sony, Intel, AMD and others
- LLVM has spawned numerous other languages, including Swift
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
### Boost

- 1998 Beman Dawes and Robert Klarer propose the idea for creating a web based library repository
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "fragment"} -->
### The Free Lunch Is Over

- 2005 Herb Sutter publishes [_The Free Lunch Is Over: A Fundamental Turn Toward Concurrency in Software_](http://www.gotw.ca/publications/concurrency-ddj.htm)
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "fragment"} -->
### Language Evolution

- 1987 Need for common functional language identified and work on [Haskell begins](http://haskell.cs.yale.edu/wp-content/uploads/2011/02/history.pdf)
- 2005 Joel Spolsky publishes [_The Perils of JavaSchools_](https://www.joelonsoftware.com/2005/12/29/the-perils-of-javaschools-2/)
- JavaScript Transpilers: Babel, CoffeeScript, TypeScript, Dart, GWT, [Elm](http://elm-lang.org/), ...
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
## Online Resources

### Information:
- [r/cpp](https://www.reddit.com/r/cpp/): Reddit forum to find news and blogs
- [Cpplang Slack](https://cpplang.now.sh/): Get your questions answered fast
- [CppCast](http://cppcast.com/): The only podcast dedicated to C++
- [isocpp](https://isocpp.org/): The standard committee and recent news
- [stackoverflow](https://stackoverflow.com/questions/tagged/c%2B%2B): Get your questions answered well

### Reference:
- [cppreference](http://en.cppreference.com/w/): The best online reference for C++
- [working draft](http://www.open-std.org/jtc1/sc22/wg21/docs/papers/2017/n4700.pdf): The definitive answer
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
### Tools:
- [Compiler Explorer (godbolt)](https://godbolt.org/): See what the code generates
- [Coliru](http://coliru.stacked-crooked.com/): Just run some code
- [Clang in Browser](https://tbfleming.github.io/cib/): Demo of Clang to wasm in the browser
- [Quick C++ Benchmarks](http://quick-bench.com/): Handy way to run small benchmarks and generate graphs
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
## Other Tools

- [clang-tidy](http://clang.llvm.org/extra/clang-tidy/): Diagnose and fix your code
- [include-what-you-use](https://include-what-you-use.org/): Help to prune the include lists and add direct dependencies
- [cling](https://root.cern.ch/cling): Interpreted C++
- [jupyter](https://jupyter.org/): Data science notebook, can work with cling
- Xcode includes clang static analyzer and sanitizers
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "fragment"} -->
Moving to `cmake` would simplify the process of using many tools.
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
# Demo
<!-- #endregion -->

```c++ slideshow={"slide_type": "slide"}
vector<int> a = {30, 20, 40, 10};
sort(begin(a), end(a));
```

```c++ slideshow={"slide_type": "-"}
for(const auto& e : a) cout << e << endl;
```

```c++

```
