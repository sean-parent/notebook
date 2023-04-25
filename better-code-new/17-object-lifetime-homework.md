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
#include <algorithm>
#include <deque>
#include <future>
#include <iostream>
#include <memory>
#include <mutex>
#include <thread>
#include <utility>
#include <vector>

using namespace std;
```

```c++ slideshow={"slide_type": "skip"}
namespace bcc {

class task {
    struct concept {
        virtual ~concept() {}
        virtual void invoke() = 0;
    };

    template <class F>
    struct model final : concept {
        F _f;
        model(F f) : _f(move(f)) {}
        void invoke() override { _f(); }
    };
    unique_ptr<concept> _self;

public:
    task() = default;

    template <class F> // F model void()
    task(F f) : _self(make_unique<model<F>>(move(f))) {}

    void operator()() { _self->invoke(); }
    explicit operator bool() const { return static_cast<bool>(_self); }
};

class notification_queue {
    using lock_t = unique_lock<mutex>;

    deque<task> _q;
    bool _done{false};
    mutex _mutex;
    condition_variable _ready;

public:
    bool try_pop(task& x) {
        lock_t lock{_mutex, try_to_lock};
        if (!lock || _q.empty()) return false;
        x = move(_q.front());
        _q.pop_front();
        return true;
    }

    template <typename F>
    bool try_push(F&& f) {
        {
            lock_t lock{_mutex, try_to_lock};
            if (!lock) return false;
            _q.emplace_back(forward<F>(f));
        }
        _ready.notify_one();
        return true;
    }

    void done() {
        {
            unique_lock<mutex> lock{_mutex};
            _done = true;
        }
        _ready.notify_all();
    }

    bool pop(task& x) {
        lock_t lock{_mutex};
        while (_q.empty() && !_done)
            _ready.wait(lock);
        if (_q.empty()) return false;
        x = move(_q.front());
        _q.pop_front();
        return true;
    }

    template <typename F>
    void push(F&& f) {
        {
            lock_t lock{_mutex};
            _q.emplace_back(forward<F>(f));
        }
        _ready.notify_one();
    }
};

/**************************************************************************************************/

class task_system {
    const unsigned _count{thread::hardware_concurrency()};
    vector<thread> _threads;
    vector<notification_queue> _q{_count};
    atomic<unsigned> _index{0};

    void run(unsigned i) {
        while (true) {
            task f;

            for (unsigned n = 0; n != _count; ++n) {
                if (_q[(i + n) % _count].try_pop(f)) break;
            }
            if (!f && !_q[i].pop(f)) break;

            f();
        }
    }

public:
    task_system() {
        for (unsigned n = 0; n != _count; ++n) {
            _threads.emplace_back([&, n] { run(n); });
        }
    }

    ~task_system() {
        for (auto& e : _q)
            e.done();
        for (auto& e : _threads)
            e.join();
    }

    template <typename F>
    void async(F&& f) {
        auto i = _index++;

        for (unsigned n = 0; n != _count; ++n) {
            if (_q[(i + n) % _count].try_push(forward<F>(f))) return;
        }

        _q[i % _count].push(forward<F>(f));
    }
};

template <class F>
void pool_async(F&& f) {
    static task_system pool;
    pool.async(forward<F>(f));
}

}
```

```c++ slideshow={"slide_type": "skip"}
using namespace bcc;
```

<!-- #region slideshow={"slide_type": "slide"} -->
# Object Lifetime Homework
<!-- #endregion -->

```c++ slideshow={"slide_type": "skip"}
namespace bcc {

class sequential_process {
    mutex _mutex;
    bool _running = false;
    deque<task> _queue;

    void resume() {
        task work;
        while (true) {
            {
                unique_lock<mutex> lock(_mutex);

                if (_queue.empty()) {
                    _running = false;
                    return;
                }
                work = move(_queue.front());
                _queue.pop_front();
            }
            move(work)();
        }
    }

public:
    void async(task f);
};

} // namespace
```

<!-- #region slideshow={"slide_type": "fragment"} -->
- **Problem:** The transformation to call `resume()` on a thread pool causes on object life time problem.
    - The `sequential_process` may destruct before `resume()` is invoked.
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
namespace bcc {

void sequential_process::async(task f) {
    bool running = true;
    {
        lock_guard<mutex> lock(_mutex);
        _queue.push_back(move(f));
        swap(running, _running);
    }
    if (!running) pool_async([this] { resume(); }); // <--- FIX ME !!!
}

} // namespace
```

<!-- #region slideshow={"slide_type": "slide"} -->
- As is, this code has _undefined behavior_ because `process` may destruct before the lambda executes, causing a data race

```cpp
{
    sequential_process process;

    process.async([] {
        this_thread::sleep_for(1s);
        cout << "Made it!" << endl;
    });
}
```
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "fragment"} -->
```
==================
WARNING: ThreadSanitizer: data race (pid=7699)
  Read of size 8 at 0x7ffeefbff498 by main thread:
    #0 std::__1::__deque_base<(anonymous namespace)::task, std::__1::allocator<(anonymous namespace)::task> >::begin() deque:1061 (scratch:x86_64+0x1000154e5)
    #1 std::__1::__deque_base<(anonymous namespace)::task, std::__1::allocator<(anonymous namespace)::task> >::clear() deque:1167 (scratch:x86_64+0x100014ce0)
    #2 std::__1::__deque_base<(anonymous namespace)::task, std::__1::allocator<(anonymous namespace)::task> >::~__deque_base() deque:1105 (scratch:x86_64+0x100014a3a)
    #3 std::__1::deque<(anonymous namespace)::task, std::__1::allocator<(anonymous namespace)::task> >::~deque() deque:1187 (scratch:x86_64+0x1000149d8)
    #4 std::__1::deque<(anonymous namespace)::task, std::__1::allocator<(anonymous namespace)::task> >::~deque() deque:1187 (scratch:x86_64+0x100014998)
    #5 (anonymous namespace)::sequential_process::~sequential_process() main.cpp:182 (scratch:x86_64+0x100024956)
    #6 (anonymous namespace)::sequential_process::~sequential_process() main.cpp:182 (scratch:x86_64+0x100005878)
    #7 main main.cpp:290 (scratch:x86_64+0x1000045d6)

  Previous write of size 8 at 0x7ffeefbff498 by thread T4 (mutexes: write M272):
    #0 std::__1::deque<(anonymous namespace)::task, std::__1::allocator<(anonymous namespace)::task> >::pop_front() deque:2568 (scratch:x86_64+0x10001ac75)
    #1 (anonymous namespace)::sequential_process::resume() main.cpp:214 (scratch:x86_64+0x1000244e1)
    #2 (anonymous namespace)::sequential_process::async((anonymous namespace)::task)::'lambda'()::operator()() const main.cpp:247 (scratch:x86_64+0x100024149)
    #3 (anonymous namespace)::task::model<(anonymous namespace)::sequential_process::async((anonymous namespace)::task)::'lambda'()>::invoke() main.cpp:36 (scratch:x86_64+0x100023fed)
    #4 (anonymous namespace)::task::operator()() main.cpp:46 (scratch:x86_64+0x10001a3ce)
    #5 (anonymous namespace)::task_system::run(unsigned int) main.cpp:123 (scratch:x86_64+0x1000196b0)
    #6 (anonymous namespace)::task_system::task_system()::'lambda'()::operator()() const main.cpp:130 (scratch:x86_64+0x10001940a)
    #7 std::__1::__thread_proxy<std::__1::tuple<std::__1::unique_ptr<std::__1::__thread_struct, std::__1::default_delete<std::__1::__thread_struct> >, (anonymous namespace)::task_system::task_system()::'lambda'()> >(void*, void*) type_traits:4323 (scratch:x86_64+0x100017d54)

  As if synchronized via sleep:
    #0 nanosleep <null> (libclang_rt.tsan_osx_dynamic.dylib:x86_64h+0x270e3)
    #1 std::__1::this_thread::sleep_for(std::__1::chrono::duration<long long, std::__1::ratio<1l, 1000000000l> > const&) <null> (libc++.1.dylib:x86_64+0x47933)
    #2 main main.cpp:288 (scratch:x86_64+0x1000045c5)

  Location is stack of main thread.

  Mutex M272 (0x7ffeefbff430) created at:
    #0 pthread_mutex_lock <null> (libclang_rt.tsan_osx_dynamic.dylib:x86_64h+0x37aae)
    #1 std::__1::mutex::lock() <null> (libc++.1.dylib:x86_64+0x39c7e)
    #2 main main.cpp:283 (scratch:x86_64+0x100004582)

  Thread T4 (tid=440231, running) created by main thread at:
    #0 pthread_create <null> (libclang_rt.tsan_osx_dynamic.dylib:x86_64h+0x283ed)
    #1 std::__1::thread::thread<(anonymous namespace)::task_system::task_system()::'lambda'(), void>((anonymous namespace)::task_system::task_system()::'lambda'()&&) __threading_support:327 (scratch:x86_64+0x100016e18)
    #2 std::__1::thread::thread<(anonymous namespace)::task_system::task_system()::'lambda'(), void>((anonymous namespace)::task_system::task_system()::'lambda'()&&) thread:360 (scratch:x86_64+0x100016318)
    #3 _ZNSt3__16vectorINS_6threadENS_9allocatorIS1_EEE24__emplace_back_slow_pathIJZN12_GLOBAL__N_111task_systemC1EvEUlvE_EEEvDpOT_ memory:1759 (scratch:x86_64+0x100016087)
    #4 (anonymous namespace)::task_system::task_system() vector:1644 (scratch:x86_64+0x100012499)
    #5 (anonymous namespace)::task_system::task_system() main.cpp:128 (scratch:x86_64+0x100011938)
    #6 void (anonymous namespace)::pool_async<(anonymous namespace)::sequential_process::async((anonymous namespace)::task)::'lambda'()>((anonymous namespace)::sequential_process::async((anonymous namespace)::task)::'lambda'()&&) main.cpp:157 (scratch:x86_64+0x100006b93)
    #7 (anonymous namespace)::sequential_process::async((anonymous namespace)::task) main.cpp:247 (scratch:x86_64+0x100004986)
    #8 main main.cpp:283 (scratch:x86_64+0x100004582)

SUMMARY: ThreadSanitizer: data race deque:1061 in std::__1::__deque_base<(anonymous namespace)::task, std::__1::allocator<(anonymous namespace)::task> >::begin()
==================
ThreadSanitizer report breakpoint hit. Use 'thread info -s' to get extended information about the report.
```
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
## A <strike>Ch</strike>easy Fix
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "fragment"} -->
- Extend the lifetime of `process` to _fix_ the invocation
<!-- #endregion -->

```c++
{
    auto process = make_shared<sequential_process>();

    process->async([process] {
        this_thread::sleep_for(1s);
        cout << "Made it!" << endl;
    });

    this_thread::sleep_for(2s); // This line is here for my slides
}
```

<!-- #region slideshow={"slide_type": "slide"} -->
- We can no longer rely on when all tasks in our `sequential_process` are done
    - Our tasks must be constructed to be independent of process destruction
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
## Blocking
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "fragment"} -->
- To keep the original semantics we could block on destruction of `sequential_process`
- To do this we again need:
    - A `_done` flag
    - A `_condition` variable
    - A destructor that signals done
<!-- #endregion -->

```c++ slideshow={"slide_type": "slide"}
namespace bcc2 {

class sequential_process {
    function<void(task)> _executor;

    mutex _mutex;
    bool _running = false;
    deque<task> _queue;

    condition_variable _condition; // <---
    bool _done = false;            // <---

    void resume();

public:
    ~sequential_process(); // <---
    void async(task f);
};

} // namespace bcc2
```

```c++ slideshow={"slide_type": "skip"}
// SKIP CELL

namespace bcc2 {

void sequential_process::async(task f) {
    bool running = true;
    {
        lock_guard<mutex> lock(_mutex);
        _queue.push_back(move(f));
        swap(running, _running);
    }
    if (!running) pool_async([this] { resume(); }); // <--- FIX ME !!!
}

} // namespace bcc
```

<!-- #region slideshow={"slide_type": "slide"} -->
- In the destructor if we are are still running
    - signal that we are done and want a notification
    - wait until we are no longer running
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
namespace bcc2 {

sequential_process::~sequential_process() {
    unique_lock<mutex> lock(_mutex);
    if (!_running) return;
    _done = true;
    while (_running)
        _condition.wait(lock);
}

} // namespace bcc
```

<!-- #region slideshow={"slide_type": "slide"} -->
- Finally in `resume()` if we are done then notify when we stop running
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
namespace bcc2 {

void sequential_process::resume() {
    task work;
    while (true) {
        {
            unique_lock<mutex> lock(_mutex);

            if (_queue.empty()) {
                _running = false;
                if (_done) _condition.notify_one(); // <---
                return;
            }
            work = move(_queue.front());
            _queue.pop_front();
        }
        move(work)();
    }
}

} // namespace bcc
```

<!-- #region slideshow={"slide_type": "slide"} -->
- It works in our example
    - But only so long as we have _enough_ threads
- If the task is scheduled on the same as the one destructing `process`
    - And there is no thread available to steal the task
    - Deadlock!
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "fragment"} -->
- But how many threads are enough?
    - On a system with `N` processes we need `N+1` threads available in the pool to guarantee no deadlocks
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "fragment"} -->
- In a single threaded environment, like wasm, this will deadlock _often_
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "fragment"} -->
- Probability of failure is a function of number of threads, number of processes, frequency of dispatched tasks, and frequency of joins
    - I have no idea how to calculate it...
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
## Handle / Body
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "fragment"} -->
- Same as the easy approach, but we push the `shared_ptr` into the implementation
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
namespace bcc3 {

class sequential_process {
    struct implementation;

    shared_ptr<implementation> _self;

public:
    sequential_process();

    void async(task);
};

} // namespace bcc3
```

<!-- #region slideshow={"slide_type": "slide"} -->
- Our prior `sequential_process` class becomes the implementation
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
namespace bcc3 {

struct sequential_process::implementation
    : enable_shared_from_this<implementation> { // <---
    mutex _mutex;
    deque<task> _queue;
    bool _running = false;

    void resume();
    void async(task);
};

} // namespace bcc3
```

<!-- #region slideshow={"slide_type": "slide"} -->
- `implementation::async()` can then attach a shared pointer from this to `resume()`
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
namespace bcc3 {

void sequential_process::implementation::async(task f) {
    bool running = true;
    {
        lock_guard<mutex> lock(_mutex);
        _queue.push_back(move(f));
        swap(running, _running);
    }
    if (!running)
        pool_async([_self = shared_from_this()] { _self->resume(); }); // <---
}

} // namespace bcc3
```

<!-- #region slideshow={"slide_type": "slide"} -->
- The approach suffers the same problem as the easy approach
- We can no longer rely on when all tasks in our sequential_process are done
    - Our tasks must be constructed to be independent of process destruction
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "fragment"} -->
- A similar approach, capturing `weak_from_this()` in the lambda has the effect of canceling any operations that haven't started before destruction
    - But does not provide any stronger guarantees
    - And may result in unexpected task cancellation
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
## Completion Task
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "fragment"} -->
- To solve the handle/body issue of not knowing when the process completes we can add a completion task
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
namespace bcc4 {

class sequential_process {
    struct implementation;

    shared_ptr<implementation> _self;

public:
    explicit sequential_process(task); // <---

    void async(task);
};

} // namespace bcc4
```

<!-- #region slideshow={"slide_type": "slide"} -->
- The task is stored in the implementation
    - And invoked on destruction
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
namespace bcc4 {

struct sequential_process::implementation
    : enable_shared_from_this<implementation> {
    mutex _mutex;
    deque<task> _queue;
    bool _running = false;
    task _completion; // <---

    void resume();

    implementation(task completion) : _completion(move(completion)) {} // <---
    ~implementation() { move(_completion)(); }                         // <---

    void async(task);
};

} // namespace bcc4
```

```c++ slideshow={"slide_type": "skip"}
// SKIP CELL
namespace bcc4 {

inline sequential_process::sequential_process(task completion)
    : _self(make_shared<implementation>(move(completion))) {}

inline void sequential_process::async(task f) { _self->async(move(f)); }

void sequential_process::implementation::resume() {
    task work;
    while (true) {
        {
            unique_lock<mutex> lock(_mutex);

            if (_queue.empty()) {
                _running = false;

                return;
            }
            work = move(_queue.front());
            _queue.pop_front();
        }
        move(work)();
    }
}

void sequential_process::implementation::async(task f) {
    bool running = true;
    {
        lock_guard<mutex> lock(_mutex);
        _queue.push_back(move(f));
        swap(running, _running);
    }
    if (!running)
        pool_async([_self = shared_from_this()] { _self->resume(); }); // <---
}

} // namespace bcc4
```

```c++ slideshow={"slide_type": "slide"}
{
    bcc4::sequential_process process([] { cout << "End" << endl; });

    process.async([] {
        this_thread::sleep_for(1s);
        cout << "Made it!" << endl;
    });
}
this_thread::sleep_for(2s);
```

<!-- #region slideshow={"slide_type": "fragment"} -->
- A completion handler can also be adapted to a future with continuations
- This is likely the approach I would take in a library
    - Make it the clients problem
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
## Safe Blocking
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "fragment"} -->
- To safely block on destruction
    - If the process is already running (not just queued) then wait
    - Otherwise run the process in the current context
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
- Because we could be in a queued state
    - The queued task may end up running after destruction we need a shared implementation
- Our sequential process is movable, but not copyable, so we have a single point of destruction
<!-- #endregion -->

```c++ slideshow={"slide_type": "slide"}
namespace bcc5 {

class sequential_process {
    struct implementation;
    shared_ptr<implementation> _self;

public:
    sequential_process();

    sequential_process(const sequential_process&) = delete;
    sequential_process(sequential_process&&) noexcept = default;

    sequential_process& operator=(const sequential_process&) = delete;
    sequential_process& operator=(sequential_process&&) noexcept = default;

    ~sequential_process();

    void async(task f);
};

} // namespace bcc5
```

<!-- #region slideshow={"slide_type": "slide"} -->
- In our blocking case we had `_running` and `_done` flags
    - Instead of adding more flags, we replace the flags with an `enum` for the state

<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
namespace bcc5 {

struct sequential_process::implementation : enable_shared_from_this<implementation> {
    function<void(task)> _executor;

    mutex _mutex;
    deque<task> _queue;

    condition_variable _condition;
    enum { idle, queued, running, done } _state = idle; // <---

    void resume();
    void wait(); // <---
    void async(task f);
};

} // namespace bcc5
```

<!-- #region slideshow={"slide_type": "slide"} -->
- When we enqueue the task, we change the state to `queued` if we were `idle`
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
namespace bcc5 {

void sequential_process::implementation::async(task f) {
    bool was_idle = false;
    {
        lock_guard<mutex> lock(_mutex);
        _queue.push_back(move(f));
        was_idle = _state == idle;     // <---
        if (was_idle) _state = queued; // <---
    }
    if (was_idle) pool_async([_self = shared_from_this()] { _self->resume(); });
}

} // namespace bcc5
```

<!-- #region slideshow={"slide_type": "slide"} -->
- `resume()` handles the various states
    - `idle` -> `idle` (canceled)
    - `queued` -> `running`
    - `_queue.empty()` -> idle (notify if was `done`)
- Because the shared state won't fall out from under `resume()` we can safely call `notify_one()` outside the lock
<!-- #endregion -->

```c++ slideshow={"slide_type": "slide"}
void bcc5::sequential_process::implementation::resume() {
    task work;
    while (true) {
        {
            unique_lock<mutex> lock(_mutex);

            if (_state == idle) return;             // <---
            if (_state == queued) _state = running; // <---

            if (_queue.empty()) {
                auto last_state = _state;
                _state = idle;
                if (last_state == done) break; // <---
                return;
            }

            work = move(_queue.front());
            _queue.pop_front();
        }
        move(work)();
    }
    _condition.notify_one(); // <---
}
```

<!-- #region slideshow={"slide_type": "slide"} -->
- Finally, we provide the `wait()` operation, called from `~sequential_process()`
    - If `idle` we are done and destruct
    - If work is `queued` we take ownership of execution
    - If `running` we signal `done`
<!-- #endregion -->

```c++ slideshow={"slide_type": "slide"}
void bcc5::sequential_process::implementation::wait() {
    bool was_queued = false;
    {
        unique_lock<mutex> lock(_mutex);

        if (_state == idle) return;

        if (_state == queued) {
            _state = idle;
            was_queued = true;
        } else {
            _state = done;
            while (_state == done)
                _condition.wait(lock);
        }
    }
    if (!was_queued) return;

    while (!_queue.empty()) {
        move(_queue.front())();
        _queue.pop_front();
    }
}
```

```c++ slideshow={"slide_type": "skip"}
// SKIP
namespace bcc5 {

sequential_process::sequential_process() : _self(make_shared<implementation>()) { }

sequential_process::~sequential_process() { _self->wait(); }

void sequential_process::async(task f) { _self->async(move(f)); }

}
```

<!-- #region slideshow={"slide_type": "slide"} -->
- Our process will now join cleanly without risk of a dead lock
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
{
    bcc5::sequential_process process;

    process.async([] {
        this_thread::sleep_for(1s);
        cout << "Made it!" << endl;
    });
}
cout << "process destructed" << endl;
```

<!-- #region slideshow={"slide_type": "slide"} -->
## Concluding remarks
- One of the more challenging problems in an async environment is to shut things down
    - Supply a completion handler and make it the client problem
        - Either blocking if client _knows_ they have _enough_ concurrency
        - Not blocking, usually by queuing the completion signal to the main queue until everything is complete
    - Blocking join, but take care not to dead-lock
    - Cancellation, but this is challenging as it may also require a block to ensure currently executing item is complete
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "fragment"} -->
- Apple's GCD uses completion handlers to solve this problem
    - Which is to say, they don't solve it
<!-- #endregion -->

```c++

```
