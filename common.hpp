#include <algorithm>
#include <chrono>
#include <cstdlib>
#include <iostream>
#include <iterator>
#include <memory>
#include <new>
#include <numeric>
#include <string>
#include <typeinfo>
#include <utility>
#include <vector>

#undef NDEBUG
#include <cassert>

#include <cxxabi.h>
#include <xcpp/xdisplay.hpp>

using namespace std;
using namespace xcpp;

string find_replace_all(string s, const char* sub, const char* replace) {
    const auto replace_len = strlen(replace);
    for (string::size_type n = 0; true; n += replace_len) {
        n = s.find(sub, n);
        if (n == std::string::npos) break;
        s.replace(n, strlen(sub), replace, replace_len);
    }
    return s;
}

template <class T>
string type_name() {
    typedef typename std::remove_reference<T>::type TR;
    int status;
    struct free_ {
        void operator()(void* p) const { free(p); }
    };
    std::unique_ptr<char[], free_> own(
        abi::__cxa_demangle(typeid(TR).name(), nullptr, nullptr, &status));
    std::string r = own ? own.get() : typeid(TR).name();
    
    r = find_replace_all(move(r), "__cxx11::", "");
    r = find_replace_all(move(r), "std::basic_string<char, std::char_traits<char>, std::allocator<char> >", "std::string");
    
    if (std::is_const<TR>::value) r += " const";
    if (std::is_volatile<TR>::value) r += " volatile";
    if (std::is_lvalue_reference<T>::value)
        r += "&";
    else if (std::is_rvalue_reference<T>::value)
        r += "&&";

    return r;
}

template <class T>
void print_type_name() {
    cout << type_name<T>() << "\n";
}

struct instrumented {
    instrumented() { std::cout << "instrumented ctor" << std::endl; }
    instrumented(const instrumented&) { std::cout << "instrumented copy-ctor" << std::endl; }
    instrumented(instrumented&&) noexcept {
        std::cout << "instrumented move-ctor" << std::endl;
    }
    instrumented& operator=(const instrumented&) {
        std::cout << "instrumented assign" << std::endl;
        return *this;
    }
    instrumented& operator=(instrumented&&) noexcept {
        std::cout << "instrumented move-assign" << std::endl;
        return *this;
    }
    ~instrumented() { std::cout << "instrumented dtor" << std::endl; }
    friend inline void swap(instrumented&, instrumented&) {
        std::cout << "instrumented swap" << std::endl;
    }
    friend inline bool operator==(const instrumented&, const instrumented&) { return true; }
    friend inline bool operator!=(const instrumented&, const instrumented&) {
        return false;
    }
};

#define REQUIRE(p)                                \
    if (!(p))                                     \
        std::cerr << "FAILED: REQUIRE(" #p ")\n"; \
    else

template <class T, class F>
void require_throw_as(const F& f, const char* expr) {
    try {
        f();
    } catch (const T&) {
        return;
    } catch (...) {
    }
    std::cerr << "FAILED: REQUIRE_THROWS_AS(" << expr << ")\n";
}

#define REQUIRE_THROWS_AS(expr, type) require_throw_as<type>([&] { (expr); }, #expr)

template <class BidirIt, class UnaryPredicate>
BidirIt find_last_if(BidirIt first, BidirIt last, UnaryPredicate p) {
    auto l = last;
    while (first != l) {
        --l;
        if (p(*l)) return l;
    }
    return last;
}

template <class InputIt, class UnaryPredicate>
InputIt find_if_unbounded(InputIt first, UnaryPredicate p) {
    while (!p(*first))
        ++first;
    return first;
}

template <class BidirIt, class Compare>
bool next_combination(BidirIt first, BidirIt k, BidirIt last, Compare comp) {
    if ((first == last) || (first == k) || (last == k)) return false;

    // find last element in [first, k) which is less than the last element
    auto itr1 =
        find_last_if(first, k, [&comp, &_l = *std::prev(last)](const auto& e) {
            return comp(e, _l);
        });

    // if there isn't one, do one last rotate and we are back to sorted order
    if (itr1 == k) {
        std::rotate(first, k, last);
        return false;
    }

    // find first element in [k, last) which is greater than the found element
    auto j = find_if_unbounded(k, [&](const auto& e) { return comp(*itr1, e); });

    std::iter_swap(itr1, j);
    ++j;
    std::rotate(std::next(itr1), j, last);
    std::rotate(k, std::next(k, std::distance(j, last)), last);
    return true;
}

/*
    REVISIT (sean.parent) - There may be a more efficient way to write this
   algorithm.
*/

template <std::size_t... I, class RandomIt, class F>
void invoke_helper(F f,
                   std::index_sequence<I...>,
                   const std::vector<std::size_t>& i,
                   RandomIt first) {
    f(*(first + i[I])...);
}

template <std::size_t K, class RandomIt, class F>
void for_each_k_combination(RandomIt first, RandomIt last, F f) {
    assert(!(std::distance(first, last) < K) &&
           "FATAL: k must be less than distance(first, last)");

    std::vector<std::size_t> i(std::distance(first, last));
    std::iota(begin(i), end(i), std::size_t(0));

    do {
        invoke_helper(f, std::make_index_sequence<K>{}, i, first);
    } while (next_combination(begin(i), begin(i) + K, end(i), std::less<>()));
}

template <std::size_t K, class RandomRange, class F>
void for_each_k_combination(const RandomRange& a, F f) {
    for_each_k_combination<K>(std::begin(a), std::end(a), std::move(f));
}

template <class T, class U>
std::size_t erase(std::vector<T>& c, const U& value) {
    std::size_t r = size(c);
    c.erase(std::remove(begin(c), end(c), value), end(c));
    return r - size(c);
}

template <class T, class P>
std::size_t erase_if(std::vector<T>& c, P p) {
    std::size_t r = size(c);
    c.erase(std::remove_if(begin(c), end(c), p), end(c));
    return r - size(c);
}

template <class T>
T copy(const T& a) { return T{a}; }
