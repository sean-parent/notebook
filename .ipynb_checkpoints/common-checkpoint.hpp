#include <cstdlib>
#include <iostream>
#include <string>
#include <typeinfo>

#include <cxxabi.h>

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
