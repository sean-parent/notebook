#include <algorithm>
#include <cstdlib>
#include <iostream>
#include <iterator>
#include <string>
#include <typeinfo>
#include <vector>
#include <numeric>

#include <cxxabi.h>

using namespace std;

template <class T>
void type_name() {
    typedef typename std::remove_reference<T>::type TR;
    std::unique_ptr<char, void (*)(void*)> own(
        abi::__cxa_demangle(typeid(TR).name(), nullptr, nullptr, nullptr), std::free);
    std::string r = own != nullptr ? own.get() : typeid(TR).name();
    if (std::is_const<TR>::value) r += " const";
    if (std::is_volatile<TR>::value) r += " volatile";
    if (std::is_lvalue_reference<T>::value)
        r += "&";
    else if (std::is_rvalue_reference<T>::value)
        r += "&&";

    std::cout << r << '\n';
}

struct annotate {
    annotate() { std::cout << "annotate ctor" << std::endl; }
    annotate(const annotate&) { std::cout << "annotate copy-ctor" << std::endl; }
    annotate(annotate&&) noexcept { std::cout << "annotate move-ctor" << std::endl; }
    annotate& operator=(const annotate&) {
        std::cout << "annotate assign" << std::endl;
        return *this;
    }
    annotate& operator=(annotate&&) noexcept {
        std::cout << "annotate move-assign" << std::endl;
        return *this;
    }
    ~annotate() { std::cout << "annotate dtor" << std::endl; }
    friend inline void swap(annotate&, annotate&) { std::cout << "annotate swap" << std::endl; }
    friend inline bool operator==(const annotate&, const annotate&) { return true; }
    friend inline bool operator!=(const annotate&, const annotate&) { return false; }
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

#define REQUIRE_THROWS_AS(expr, type) \
    require_throw_as<type>([&] { (expr); }, #expr)

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
    while (!p(*first)) ++first;
    return first;
}

template <class BidirIt, class Compare>
bool next_combination(BidirIt first, BidirIt k, BidirIt last, Compare comp) {
    if ((first == last) || (first == k) || (last == k)) return false;

    // find last element in [first, k) which is less than the last element
    auto itr1 = find_last_if(
        first, k, [&comp, &_l = *std::prev(last)](const auto& e) { return comp(e, _l); });

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
    REVISIT (sean.parent) - There may be a more efficient way to write this algorithm.
*/

template <std::size_t... I, class RandomIt, class F>
void invoke_helper(F f, std::index_sequence<I...>, const std::vector<std::size_t>& i, RandomIt first) {
    f(*(first + i[I])...);
}

template <std::size_t K, class RandomIt, class F>
void for_each_k_combination(RandomIt first, RandomIt last, F f) {
    assert(!(std::distance(first, last) < K) && "FATAL: k must be less than distance(first, last)");

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
