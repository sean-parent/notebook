#include <iostream>

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
