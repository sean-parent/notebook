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
#include <pthread.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

/* Default is not to use posix_memalign, so systems like Android
 * can use thread local data without heavier POSIX memory allocators.
 */
#ifndef EMUTLS_USE_POSIX_MEMALIGN
#define EMUTLS_USE_POSIX_MEMALIGN 0
#endif

namespace {
/* For every TLS variable xyz,
 * there is one __emutls_control variable named __emutls_v.xyz.
 * If xyz has non-zero initial value, __emutls_v.xyz's "value"
 * will point to __emutls_t.xyz, which has the initial value.
 */
typedef struct __emutls_control {
    size_t size;  /* size of the object in bytes */
    size_t align; /* alignment of the object in bytes */
    union {
        uintptr_t index; /* data[index-1] is the object address */
        void* address;   /* object address, when in single thread env */
    } object;
    void* value; /* null or non-zero initial value for the object */
} __emutls_control;

static inline void* emutls_memalign_alloc(size_t align, size_t size) {
    void* base;
#if EMUTLS_USE_POSIX_MEMALIGN
    if (posix_memalign(&base, align, size) != 0) abort();
#else
#define EXTRA_ALIGN_PTR_BYTES (align - 1 + sizeof(void*))
    char* object;
    if ((object = (char*)malloc(EXTRA_ALIGN_PTR_BYTES + size)) == NULL) abort();
    base = (void*)(((uintptr_t)(object + EXTRA_ALIGN_PTR_BYTES)) &
                   ~(uintptr_t)(align - 1));

    ((void**)base)[-1] = object;
#endif
    return base;
}

static inline void emutls_memalign_free(void* base) {
#if EMUTLS_USE_POSIX_MEMALIGN
    free(base);
#else
    /* The mallocated address is in ((void**)base)[-1] */
    free(((void**)base)[-1]);
#endif
}

/* Emulated TLS objects are always allocated at run-time. */
static inline void* emutls_allocate_object(__emutls_control* control) {
    /* Use standard C types, check with gcc's emutls.o. */
    typedef unsigned int gcc_word __attribute__((mode(word)));
    typedef unsigned int gcc_pointer __attribute__((mode(pointer)));
    static_assert(sizeof(size_t) == sizeof(gcc_word), "fail");
    static_assert(sizeof(uintptr_t) == sizeof(gcc_pointer), "fail");
    static_assert(sizeof(uintptr_t) == sizeof(void*), "fail");

    size_t size = control->size;
    size_t align = control->align;
    if (align < sizeof(void*)) align = sizeof(void*);
    /* Make sure that align is power of 2. */
    if ((align & (align - 1)) != 0) abort();

    void* base = emutls_memalign_alloc(align, size);
    if (control->value)
        memcpy(base, control->value, size);
    else
        memset(base, 0, size);
    return base;
}

static pthread_mutex_t emutls_mutex = PTHREAD_MUTEX_INITIALIZER;

static size_t emutls_num_object = 0; /* number of allocated TLS objects */

typedef struct emutls_address_array {
    uintptr_t size; /* number of elements in the 'data' array */
    void* data[];
} emutls_address_array;

static pthread_key_t emutls_pthread_key;

static void emutls_key_destructor(void* ptr) {
    emutls_address_array* array = (emutls_address_array*)ptr;
    uintptr_t i;
    for (i = 0; i < array->size; ++i) {
        if (array->data[i]) emutls_memalign_free(array->data[i]);
    }
    free(ptr);
}

static void emutls_init(void) {
    if (pthread_key_create(&emutls_pthread_key, emutls_key_destructor) != 0)
        abort();
}

/* Returns control->object.index; set index if not allocated yet. */
static inline uintptr_t emutls_get_index(__emutls_control* control) {
    uintptr_t index = __atomic_load_n(&control->object.index, __ATOMIC_ACQUIRE);
    if (!index) {
        static pthread_once_t once = PTHREAD_ONCE_INIT;
        pthread_once(&once, emutls_init);
        pthread_mutex_lock(&emutls_mutex);
        index = control->object.index;
        if (!index) {
            index = ++emutls_num_object;
            __atomic_store_n(&control->object.index, index, __ATOMIC_RELEASE);
        }
        pthread_mutex_unlock(&emutls_mutex);
    }
    return index;
}

/* Updates newly allocated thread local emutls_address_array. */
static inline void emutls_check_array_set_size(emutls_address_array* array,
                                               uintptr_t size) {
    if (array == NULL) abort();
    array->size = size;
    pthread_setspecific(emutls_pthread_key, (void*)array);
}

/* Returns the new 'data' array size, number of elements,
 * which must be no smaller than the given index.
 */
static inline uintptr_t emutls_new_data_array_size(uintptr_t index) {
    /* Need to allocate emutls_address_array with one extra slot
     * to store the data array size.
     * Round up the emutls_address_array size to multiple of 16.
     */
    return ((index + 1 + 15) & ~((uintptr_t)15)) - 1;
}

/* Returns the thread local emutls_address_array.
 * Extends its size if necessary to hold address at index.
 */
static inline emutls_address_array* emutls_get_address_array(uintptr_t index) {
    emutls_address_array* array =
        (emutls_address_array*)pthread_getspecific(emutls_pthread_key);
    if (array == NULL) {
        uintptr_t new_size = emutls_new_data_array_size(index);
        array = (emutls_address_array*)calloc(new_size + 1, sizeof(void*));
        emutls_check_array_set_size(array, new_size);
    } else if (index > array->size) {
        uintptr_t orig_size = array->size;
        uintptr_t new_size = emutls_new_data_array_size(index);
        array =
            (emutls_address_array*)realloc(array, (new_size + 1) * sizeof(void*));
        if (array)
            memset(array->data + orig_size, 0,
                   (new_size - orig_size) * sizeof(void*));
        emutls_check_array_set_size(array, new_size);
    }
    return array;
}
} // namespace

extern "C" void* __emutls_get_address(__emutls_control* control) {
    uintptr_t index = emutls_get_index(control);
    emutls_address_array* array = emutls_get_address_array(index);
    if (array->data[index - 1] == NULL)
        array->data[index - 1] = emutls_allocate_object(control);
    return array->data[index - 1];
}
```

```c++ slideshow={"slide_type": "skip"}
#include <vector>
#include <typeinfo>
#include <typeindex>
#include <string>
#include <iostream>

using namespace std;
```

<!-- #region slideshow={"slide_type": "slide"} -->
# `static` & `thread_local` variables
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
## `static` & non-local variables
- initialization of `static` and non-local variables with dynamic initialization is thread-safe
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
namespace bcc1 {

const auto& get_table() {
    static const vector<type_index> result = {typeid(int), typeid(long), typeid(short)};
    return result;
}

} // namespace bcc1
```

<!-- #region slideshow={"slide_type": "slide"} -->
- Thread safety only applies to object initialization
    - If there is writeable access, additional thread safety measures must be used
    - Thread-safety only applies to objects individually, not collectively
- Immediately invoked lambda expressions provide a nice way to perform complex initialization
    - Known as 'IIFE' (pronounced "iffy") for Immediately Invoked Function Expression, from JavaScript.
<!-- #endregion -->

```c++ slideshow={"slide_type": "fragment"}
namespace bcc2 {

const auto& get_table() {
    static const auto result = [] {
        vector<type_index> r{typeid(int), typeid(long), typeid(short)};
        sort(begin(r), end(r));
        return r;
    }();
    return result;
}

} // namespace bcc2
```

<!-- #region slideshow={"slide_type": "slide"} -->
- The thread safety construct imposes a negligligable performance impact (difficult to measure) on each access
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
## `thread_local` variables
- `thread_local` implies static storage duration
- non-local `thread_local` variables with dynamic initialization are initialized at the start of every thread start
    - local `thread_local` variables are initialized on first execution in a given thread
- access to a `thread_local` imposes about a 15% performance penalty (at least on Apple platforms) compared to accessing a `static` variable
<!-- #endregion -->

```c++ slideshow={"slide_type": "slide"}
namespace {

auto& context() {
    thread_local vector<string> result;
    return result;
}

} // namespace bcc3
```

<!-- #region slideshow={"slide_type": "fragment"} -->
- Access to a `thread_local` variable doesn't require synchronization
    - Unless it is otherwise shared to a differnt thread
<!-- #endregion -->

```c++ slideshow={"slide_type": "slide"}
namespace {

void do_stuff() { cout << "context: " << context().back() << endl; }

} // namespace
```

```c++ slideshow={"slide_type": "fragment"}
context().push_back("selecting");
do_stuff();
context().push_back("painting");
do_stuff();
context().pop_back();
do_stuff();
context().pop_back();
```

<!-- #region slideshow={"slide_type": "slide"} -->
## Recommendations
- Avoid non-local variables except for `constexpr` variables
    - Dynamic initialization of non-local variables impacts startup
    - Non-local `thread_local` variables impact the startup of every thread
- When you must use a dynamically initialized singleton make it a `static` local variable
    - Prefer `const` to ensure thread safety
    - If mutable, consider making it a sequential process
- `thread-local` local variables can be a useful tool for establishing auxiliary scope information
    - Drawing contexts
    - Transactions
    - Memory allocators
    - Caches
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
## Homework
- Find and fix one of:
    - A non-local with dynamic initialization
    - A local `static` which does not have thead-safe initialization
    - A use of `pthread_once()`, `boost::call_once()` or similar (simplify)
    - A use of `pthread_getspecific()`, `boost::thread_specific_ptr()` or similar (simplify)
    - A local `static` with dynamic initialization which could be `constexpr`
<!-- #endregion -->

```c++

```
