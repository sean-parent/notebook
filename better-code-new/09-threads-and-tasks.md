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
#include <unordered_set>
#include <string>
#include <iostream>
#include <mutex>
#include <thread>
#include <condition_variable>
#include <deque>

using namespace std;
```

<!-- #region slideshow={"slide_type": "skip"} toc=true -->
<h1>Table of Contents<span class="tocSkip"></span></h1>
<div class="toc" style="margin-top: 1em;"><ul class="toc-item"><li><span><a href="#Threads" data-toc-modified-id="Threads-1"><span class="toc-item-num">1&nbsp;&nbsp;</span>Threads</a></span><ul class="toc-item"><li><span><a href="#Why-Threads?" data-toc-modified-id="Why-Threads?-1.1"><span class="toc-item-num">1.1&nbsp;&nbsp;</span>Why Threads?</a></span></li><li><span><a href="#Amdahl's-Law" data-toc-modified-id="Amdahl's-Law-1.2"><span class="toc-item-num">1.2&nbsp;&nbsp;</span>Amdahl's Law</a></span></li><li><span><a href="#Serialization-&amp;-Thread-Safety" data-toc-modified-id="Serialization-&amp;-Thread-Safety-1.3"><span class="toc-item-num">1.3&nbsp;&nbsp;</span>Serialization &amp; Thread Safety</a></span></li><li><span><a href="#Mutex-Model-of-Serialization" data-toc-modified-id="Mutex-Model-of-Serialization-1.4"><span class="toc-item-num">1.4&nbsp;&nbsp;</span>Mutex Model of Serialization</a></span></li><li><span><a href="#Sequential-Processes" data-toc-modified-id="Sequential-Processes-1.5"><span class="toc-item-num">1.5&nbsp;&nbsp;</span>Sequential Processes</a></span><ul class="toc-item"><li><span><a href="#Advantages-of-Sequential-Processes-Model" data-toc-modified-id="Advantages-of-Sequential-Processes-Model-1.5.1"><span class="toc-item-num">1.5.1&nbsp;&nbsp;</span>Advantages of Sequential Processes Model</a></span></li></ul></li><li><span><a href="#Homework" data-toc-modified-id="Homework-1.6"><span class="toc-item-num">1.6&nbsp;&nbsp;</span>Homework</a></span></li></ul></li></ul></div>
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
# Threads

- Execution context consisting of a stack and processor state running in parallel, or concurrent, to other threads
    - When referring to threads we are referring to _preemptive threads_ which can be scheduled at the instruction level by the OS
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
## Why Threads?

- Interactivity and Responsiveness: _Concurrency_, doing multiple things at once
    - save in the background
- Performance: _Parallelism_, fully utilizing the hardware to perform tasks faster
    - Photoshop _bottlenecks_, image processing routines
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
- Threads are one foundational mechanism
- Other mechanisms:
    - concurrency and parallelism
        - OS processes
    - parallelism
        - vectorization (SIMD)
        - GPU and coprocessors
    - concurrency
        - fibers (cooperative threads, _stack-full_ coroutines)
        - coroutines (_stack-less_)
        - callbacks
        - continuations
        - channels
        - task schedulers (thread pools)

- concurrency mechanisms can be combined with parallel mechanisms, especially threads, to reduce cost of concurrency through threads alone
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
![Unlocking Performance](img/machine-mips.png)
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "skip"} -->
## Amdahl's Law
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
![Amdahl's Law](img/2017-01-18-concurrency/2017-01-18-concurrency.001.png)
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
![Amdahl's Law](img/2017-01-18-concurrency/2017-01-18-concurrency.002.png)
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
 - Some amount of serialization is unavoidable
     - The memory bus is a shared resource
     - Heap allocations require some serialization
     - Lock free constructs such as atomics are serialized
     - Screen resources, main event queue, are serialized
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
## Serialization & Thread Safety

- Serialization is required when one thread is modifying memory while another thread is reading or modifying the same memory location
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "fragment"} -->
- _thread safe_ object instances can be safely shared between threads
    - thread safety may apply to a subset of the operations on an object
    - `const` objects, including a reference to a `const` object, is assumed to not be mutable for the duration of use and so can be safely shared
        - A `mutable` data member _requires_ synchronization
            - i.e. a cache
    - The standard library assumes that `const` implies thread safe

<!-- #endregion -->

```c++ slideshow={"slide_type": "slide"}
class table {
    const string _names[4]{
        "Able",
        "Bill",
        "Colin",
        "Zack"
    };
    mutable string* _cache = nullptr; // Not thread safe!
public:
    size_t lookup(const string& x) const {
        if (_cache && *_cache == x) return _cache - begin(_names);
        return lower_bound(begin(_names), end(_names), x) - begin(_names);
    }
};
```

<!-- #region slideshow={"slide_type": "slide"} -->
- _conditionally thread safe_ object instances can be safely used by a single thread per instance
    - This is the default behavior unless otherwise specified
    - _As thread safe as an `int`_

<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
- _not thread safe_ object instances must all be used by the same, or a specific, thread
    - This implies unsynchronized shared state between instance
        - shared pointers to unsynchronized mutable objects
        - shared access to unsynchronized global variables
        - unsynchronized mutable members
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "fragment"} -->
- All current standard containers are _conditionally_ thread safe
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
## Mutex Model of Serialization

- To make a _not thread safe_ class _conditionally thread safe_ we can use a `mutex`
<!-- #endregion -->

```c++ slideshow={"slide_type": "slide"}
{
    class interned_string {
        static auto pool() -> unordered_set<string>& {
            static unordered_set<std::string> result;
            return result;
        }

        const std::string* _string;
    public:
        interned_string(const string& a) : _string(&*pool().insert(a).first) {}
        const string& string() const { return *_string; }
    };

    interned_string str("Hello"s);
    cout << str.string() << endl;
}
```

<!-- #region slideshow={"slide_type": "slide"} -->
```cpp
thread t([]{
    interned_string str("Hello"s);
});

interned_string str("Hello"s);
cout << str.string() << endl;

t.join();
```
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "fragment"} -->
```
==================
WARNING: ThreadSanitizer: data race (pid=16636)
  Write of size 8 at 0x0001000688c8 by main thread:
  * #0 std::__1::__hash_table<std::__1::basic_string<char, std::__1::char_traits<char>, std::__1::allocator<char> >, std::__1::hash<std::__1::basic_string<char, std::__1::char_traits<char>, std::__1::allocator<char> > >, std::__1::equal_to<std::__1::basic_string<char, std::__1::char_traits<char>, std::__1::allocator<char> > >, std::__1::allocator<std::__1::basic_string<char, std::__1::char_traits<char>, std::__1::allocator<char> > > >::__rehash(unsigned long) __hash_table:2122 (scratch:x86_64+0x1000232a8)
    #1 std::__1::__hash_table<std::__1::basic_string<char, std::__1::char_traits<char>, std::__1::allocator<char> >, std::__1::hash<std::__1::basic_string<char, std::__1::char_traits<char>, std::__1::allocator<char> > >, std::__1::equal_to<std::__1::basic_string<char, std::__1::char_traits<char>, std::__1::allocator<char> > >, std::__1::allocator<std::__1::basic_string<char, std::__1::char_traits<char>, std::__1::allocator<char> > > >::rehash(unsigned long) __hash_table:2098 (scratch:x86_64+0x10001cb4a)
    #2 interned_string::interned_string(std::__1::basic_string<char, std::__1::char_traits<char>, std::__1::allocator<char> > const&) __hash_table:1980 (scratch:x86_64+0x10000ee20)
    #3 interned_string::interned_string(std::__1::basic_string<char, std::__1::char_traits<char>, std::__1::allocator<char> > const&) main.cpp:174 (scratch:x86_64+0x1000026a1)
    #4 main main.cpp:184 (scratch:x86_64+0x1000018cd)

  Previous read of size 8 at 0x0001000688c8 by thread T4:
  * #0 interned_string::interned_string(std::__1::basic_string<char, std::__1::char_traits<char>, std::__1::allocator<char> > const&) __hash_table:806 (scratch:x86_64+0x10000a137)
    #1 interned_string::interned_string(std::__1::basic_string<char, std::__1::char_traits<char>, std::__1::allocator<char> > const&) main.cpp:174 (scratch:x86_64+0x1000026a1)
    #2 main::$_0::operator()() const main.cpp:181 (scratch:x86_64+0x10003ed72)
    #3 void* std::__1::__thread_proxy<std::__1::tuple<std::__1::unique_ptr<std::__1::__thread_struct, std::__1::default_delete<std::__1::__thread_struct> >, main::$_0> >(void*) type_traits:4291 (scratch:x86_64+0x10003db4b)

  Issue is caused by frames marked with "*".

  Location is global 'interned_string::pool()::result' at 0x0001000688c0 (scratch+0x0001000688c8)

  Thread T4 (tid=14404692, running) created by main thread at:
    #0 pthread_create <null> (libclang_rt.tsan_osx_dynamic.dylib:x86_64h+0x2a34d)
    #1 std::__1::thread::thread<main::$_0, void>(main::$_0&&) __threading_support:310 (scratch:x86_64+0x10003a63e)
    #2 std::__1::thread::thread<main::$_0, void>(main::$_0&&) thread:354 (scratch:x86_64+0x1000025c1)
    #3 main main.cpp:180 (scratch:x86_64+0x1000014fe)

SUMMARY: ThreadSanitizer: data race __hash_table:2122 in std::__1::__hash_table<std::__1::basic_string<char, std::__1::char_traits<char>, std::__1::allocator<char> >, std::__1::hash<std::__1::basic_string<char, std::__1::char_traits<char>, std::__1::allocator<char> > >, std::__1::equal_to<std::__1::basic_string<char, std::__1::char_traits<char>, std::__1::allocator<char> > >, std::__1::allocator<std::__1::basic_string<char, std::__1::char_traits<char>, std::__1::allocator<char> > > >::__rehash(unsigned long)
==================
ThreadSanitizer report breakpoint hit. Use 'thread info -s' to get extended information about the report.
(lldb)
```
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
```cpp
bool global = false;
thread t([&] { global = true; });

cout << global << endl;

t.join();
```
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "fragment"} -->
```
==================
WARNING: ThreadSanitizer: data race (pid=16772)
  Read of size 1 at 0x7ffeefbff45b by main thread:
  * #0 main main.cpp:181 (scratch:x86_64+0x100000cff)

  Previous write of size 1 at 0x7ffeefbff45b by thread T4:
  * #0 main::$_0::operator()() const main.cpp:180 (scratch:x86_64+0x10001d515)
    #1 void* std::__1::__thread_proxy<std::__1::tuple<std::__1::unique_ptr<std::__1::__thread_struct, std::__1::default_delete<std::__1::__thread_struct> >, main::$_0> >(void*) type_traits:4291 (scratch:x86_64+0x10001c64f)

  Issue is caused by frames marked with "*".

  Location is stack of main thread.

  Thread T4 (tid=14425077, finished) created by main thread at:
    #0 pthread_create <null> (libclang_rt.tsan_osx_dynamic.dylib:x86_64h+0x2a34d)
    #1 std::__1::thread::thread<main::$_0, void>(main::$_0&&) __threading_support:310 (scratch:x86_64+0x10001906b)
    #2 std::__1::thread::thread<main::$_0, void>(main::$_0&&) thread:354 (scratch:x86_64+0x100001991)
    #3 main main.cpp:180 (scratch:x86_64+0x100000c09)

SUMMARY: ThreadSanitizer: data race main.cpp:181 in main
==================
ThreadSanitizer report breakpoint hit. Use 'thread info -s' to get extended information about the report.
(lldb)
```
<!-- #endregion -->

```c++ slideshow={"slide_type": "slide"}
class interned_string {
    struct shared_pool {
        mutex _mutex;
        unordered_set<string> _pool;

        const string* insert(const string& a) {
            lock_guard<mutex> lock(_mutex);
            return &*_pool.insert(a).first;
        }
    };

    static auto pool() -> shared_pool& {
        static shared_pool result;
        return result;
    }

    const std::string* _string;
public:
    interned_string(const string& a) : _string(pool().insert(a)) {}
    const string& string() const { return *_string; }
};
```

```c++ slideshow={"slide_type": "slide"}
thread t([]{
    interned_string str("Hello"s);
});

interned_string str("Hello"s);
cout << str.string() << '\n';

t.join();
```

<!-- #region slideshow={"slide_type": "slide"} -->
![mutex](img/mutex.png)
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
> “It can be shown that programs that correctly use mutexes and `memory_order_seq_cst` operations to prevent all data races and use no other synchronization operations behave as if the operations executed by their constituent threads were simply interleaved, with each value computation of an object being taken from the last side effect on that object in that interleaving. This is normally referred to as ‘sequential consistency.’”
– C++11 Standard 1.10.21
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
## Sequential Processes

- In a concurrent system a _task_ is a unit of work
    - i.e. the single execution of a function object
- A _sequential process_ is a sequence of tasks
- The correct use of mutexes can be replaced with a sequential process
<!-- #endregion -->

```c++ slideshow={"slide_type": "slide"}
namespace bcc {

class sequential_process {
    using task = function<void()>;

    mutex _mutex;
    condition_variable _condition;
    deque<task> _queue;
    bool _done = false;

    void run_loop();

    thread _thread{[this] { run_loop(); }};

public:
    ~sequential_process();
    void async(task f);
};

} // namespace bcc
```

```c++ slideshow={"slide_type": "slide"}
namespace bcc {

sequential_process::~sequential_process() {
    {
        lock_guard<mutex> lock(_mutex);
        _done = true;
    }
    _condition.notify_one();
    _thread.join();
}

} // namespace bcc
```

```c++ slideshow={"slide_type": "slide"}
namespace bcc {

void sequential_process::async(task f) {
    {
        lock_guard<mutex> lock(_mutex);
        _queue.push_back(move(f));
    }
    _condition.notify_one();
}

} // namespace bcc
```

```c++ slideshow={"slide_type": "slide"}
namespace bcc {

void sequential_process::run_loop() {
    while (true) {
        task work;
        {
            unique_lock<mutex> lock(_mutex);

            while (_queue.empty() && !_done) {
                _condition.wait(lock);
            }

            if (_queue.empty()) return;

            work = move(_queue.front());
            _queue.pop_front();
        }
        work();
    }
}

} // namespace bcc
```

```c++ slideshow={"slide_type": "skip"}
using namespace bcc;
```

```c++ slideshow={"slide_type": "slide"}
{
sequential_process printer;
sequential_process p1;
sequential_process p2;
p1.async([&] { printer.async([] { cout << "p1-begin\n"; });});
p1.async([&] { printer.async([] { cout << "p1-step_1\n"; });});
p1.async([&] { printer.async([] { cout << "p1-step_2\n"; });});
p1.async([&] { printer.async([] { cout << "p1-end\n"; });});

p2.async([&] { printer.async([] { cout << "  p2-begin\n"; });});
p2.async([&] { printer.async([] { cout << "  p2-step_1\n"; });});
p2.async([&] { printer.async([] { cout << "  p2-step_2\n"; });});
p2.async([&] { printer.async([] { cout << "  p2-end\n"; });});
}
```

<!-- #region slideshow={"slide_type": "notes"} -->
Comment that it is important for printer to be destructed last.
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
### Advantages of Sequential Processes Model

- Significant body of research into writing correct Communicating Sequential Processes
    - C. A. R. Hoare's work on CSP is a major reason Hoare is Turing Award winner
    - [http://www.usingcsp.com/cspbook.pdf](http://www.usingcsp.com/cspbook.pdf)
- No explicit synchronization primitives or associated errors
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
- Serialization time is fixed to operations under the lock

```cpp
{
    lock_guard<mutex> lock(_mutex);
    _queue.push_back(move(f));
}
```
---
```cpp
{
    unique_lock<mutex> lock(_mutex);

    while (_queue.empty() && !_done) {
        _condition.wait(lock);
    }

    if (_queue.empty()) return;

    work = move(_queue.front());
    _queue.pop_front();
}
```
- Reducing overhead and time under lock improves performance
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
- With a mutex, more work done in a task under a lock decreases performance dramatically
- With a sequential process, more done in the task increases performance by reducing amortized overhead
    - apollo is written as a pair of communicating sequential processes
        - the core is _all_ of Photoshop
        - the surface is the UI thread
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
## Homework

- Rewrite intern_string::shared_pool as a sequential process
    - Include a paragraph about the pros/cons of doing so
- Bonus: identify as many areas for improvement in the sequential process implementation
    - Include prose on the wiki or send a pull request

[https://git.corp.adobe.com/better-code/class/blob/master/09-threads-and-tasks.cpp](https://git.corp.adobe.com/better-code/class/blob/master/09-threads-and-tasks.cpp)
<!-- #endregion -->
