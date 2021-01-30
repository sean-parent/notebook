---
jupyter:
  jupytext:
    formats: ipynb,md
    text_representation:
      extension: .md
      format_name: markdown
      format_version: '1.2'
      jupytext_version: 1.9.1
  kernelspec:
    display_name: C++17
    language: C++17
    name: xcpp17
---

```c++ jupyter={"source_hidden": true} slideshow={"slide_type": "skip"}
#include "../common.hpp"
```

<!-- #region jupyter={"source_hidden": true} slideshow={"slide_type": "skip"} -->
## Prior Homework

**Exercise:** Look at the API and implementation for ZString (or a commonly used class in your own project). What does a ZString represent? What would be a good set of basis operations? What operations would be better implemented externally? Are there operations that should be removed?
<!-- #endregion -->

<!-- #region jupyter={"source_hidden": true} slideshow={"slide_type": "skip"} -->
```cpp

class ZString {
public:
    static ZString RomanizationOf(int32 num, int16_t minWidth = 0);
    static ZString FixedRomanizationOf(int32 value,
                                       int16_t places,
                                       bool trim,
                                       bool isSigned = false);

    [[ deprecated ]] int32 AsInteger() const; // Use HasInteger
    bool AsBool() const;

    typedef enum _t_Base { any = 0, decimal = 10, hex = 16, octal = 8 } Base;

    bool HasInteger(int32& value,
                    Base base = decimal,
                    ZString* rest = NULL,
                    bool skip_whitespace_for_rest = true) const;
    bool HasFloat(nativeFloat& value,
                  ZString* rest = NULL,
                  bool skip_whitespace_for_rest = true,
                  bool from_user_interface = true) const;

    void TrimEllipsis();
    void TrimBlanks();
    void TrimWhiteSpace();

    bool TruncateToLength(uint32_t maxLength);
    ZString MakeSubString(uint32 startPos, uint32_t exactLength) const;

#if INSIDE_PHOTOSHOP
    enum TrimFromLocation { tflBeginning, tflMiddle, tflEnd };

    bool TrimToWidth(const PSFont& font,
                     nativeFloat maxWidth,
                     TrimFromLocation trimFromLoc = tflEnd);

    bool TrimToWidth(ZStringWidthProc& inWidthProc,
                     nativeFloat maxWidth,
                     TrimFromLocation trimFromLoc = tflEnd);

    bool TrimLongNameToWidthFromMiddle(const PSFont& font, nativeFloat maxWidth);
#endif
    bool TruncateFilename(uint32_t maxLength = 31);

    void RemoveAccelerators(bool removeParentheticalHotkeysOnWindows = false,
                            bool removeDoubleAmpersandOnWindows = false);

    void DoubleAmpersand();
    bool StripAmpersand(void);

    unsigned short GetAccelerator() const;

    bool SplitZStringAtAmpersand(ZString& preZstr,
                                 ZString& accelZstr,
                                 ZString& postZstr) const;

    unsigned short GetFirstCharacterForShortcut() const;

    void ReplaceCharacters(const unsigned short* matchChars,
                           const unsigned short* replacementChars,
                           uint32 numChars);

    void EscapeCharacters(const unsigned short* charsToEscape,
                          const unsigned short* escapeChars,
                          uint32 numChars);

#if MSWindows
    void RemoveDirectionalityMarkers();
#endif
    void SplitZString(ZString& prePart,
                      ZString& postPart,
                      const ZString& splitter) const;

    void ReverseSplitZString(ZString& prePart,
                             ZString& postPart,
                             const ZString& splitter) const;

    bool IsAllWhiteSpace() const;
    bool ContainsWhiteSpace() const;
    uint32 CountWhiteSpaceCharacters() const;
    bool IsEmpty() const;

    bool InitialMatch(const ZString& substring, const uint32 count) const;

    bool StartsWith(const ZString& subString, bool caseSensitive = true) const;
    bool EndsWith(const ZString& subString, bool caseSensitive = true) const;

    bool Contains(const ZString& subString, bool caseSensitive = true) const;

    bool ContainsNonRomanCharacters(CharsDistribution* charsDist = NULL) const;

    void operator=(const ZString& x);
    ZString& operator=(ZString&& x) noexcept;

    ZString operator+(const ZString& x) const;
    ZString& operator+=(const ZString& x);

    bool operator==(const ZString& x) const;
    bool operator!=(const ZString& x) const { return !(*this == x); }

    bool operator<(const ZString&) const;

    int32 CompareAgainst(const ZString& other,
                         bool forEquivalence,
                         bool localizedCompare,
                         bool caseSensitive,
                         bool diacriticalSensitive,
                         bool digitsAsNumber = false) const;

    void RemoveBadFileNameCharacters();

    void PathToSegments(ZString& server,
                        ZString& volume,
                        ZString& driveLetter,
                        std::vector<ZString>& segments,
                        ZString& fileName) const;

    static void SegmentsToPath(const ZString& server,
                               const ZString& volume,
                               const ZString& driveLetter,
                               const std::vector<ZString>& segments,
                               const ZString& fileName,
                               ZString& fullPath);

    void PathGetLastSegment(ZString& file) const;

    void PathGetLastSegmentMacOrWin(ZString& file) const;

    void FileNameExtension(ZString& base, ZString& extension) const;

    void EnsureTrailingSeparator();
    void RemoveTrailingSeparator();

    void RemoveFileOrPathSegment();

    ZString GetProperPathSplitter(void) const;

    bool SearchString(const photoshop::utf16_t* wSubStr,
                      uint32 startPos,
                      uint32& foundPostion) const;

    void Delete(uint32 position, uint32 length);

    void InsertUnicodeCString(const photoshop::utf16_t* wInsStr, uint32 position);

    void AppendPathSegment(const ZString&);

    void SplitPostScriptFontName(ZString& familyPart, ZString& stylePart) const;

    void MapCommonSymbolsToLowASCIIEquivalents();

    ZString();
    ZString(const ZString& x);
    ZString(ZString&& x);

    ZString(const char cKey[],
            const int32 maxBufferSize = -1,
            ZStringDictionary* dictionary = TheOneTrueDefaultDictionary());

#if Macintosh
#if INSIDE_PHOTOSHOP
    ZString(ConstHFSUniStr255Param key,
            ZStringDictionary* dictionary = TheOneTrueDefaultDictionary());
#endif // INSIDE_PHOTOSHOP
#endif // Macintosh

    ZString(const unsigned short* ucKey,
            const int32 maxBufferSize = -1,
            ZStringDictionary* dictionary = TheOneTrueDefaultDictionary());

    explicit ZString(const unsigned char pKey[],
                     const uint32 maxLength = 255,
                     ZStringDictionary* dictionary = TheOneTrueDefaultDictionary());

    explicit ZString(const wchar_t* utf32Key,
                     const int32 maxBufferSize = -1,
                     ZStringDictionary* dictionary = TheOneTrueDefaultDictionary());

#if INSIDE_PHOTOSHOP
    explicit ZString(const std::string& asl_string);
    explicit ZString(const adobe::name_t& asl_name);
#endif // INSIDE_PHOTOSHOP

#if INSIDE_PHOTOSHOP
    explicit ZString(const CStr31& key,
                     ZStringDictionary* dictionary = TheOneTrueDefaultDictionary());
    explicit ZString(const CStr32& key,
                     ZStringDictionary* dictionary = TheOneTrueDefaultDictionary());
    explicit ZString(const CStr63& key,
                     ZStringDictionary* dictionary = TheOneTrueDefaultDictionary());
    explicit ZString(const CStr255& key,
                     ZStringDictionary* dictionary = TheOneTrueDefaultDictionary());
#endif

    ~ZString();

    static ZString Make(
        const char cKey[],
        const int32 maxBufferSize = -1,
        ZStringDictionary* dictionary = TheOneTrueDefaultDictionary());

    void InitPathSeparators();

    void Clear(); // Set to the empty string.

    bool WillReplace(const uint32 index) const;

    void Replace(const uint32 index,
                 const ZString& replacement,
                 const bool useAlternativeDelimiter = false);

    void ReplaceWithAlternatives(const uint32 index,
                                 const ZString& replacement,
                                 const bool useAlternativeDelimiter = false);

#if Macintosh
protected:
    friend class ACFStringRef;
    operator CFStringRef() const;

public:
    NSString* AsAutoreleasedNSString() const;
#endif

public:
    bool AllCharactersInLocalCodePage() const;

    uint32 LengthAsUnicodeCString() const;
    void AsUnicodeCString(unsigned short ucstr[],
                          int32 ucstrBufferSize,
                          bool warnAboutBufferOverflow = true) const;

#if INSIDE_PHOTOSHOP
    uint32 LengthAsUniStr255() const;

    void AsUniStr255(HFSUniStr255* uniStr,
                     bool warnAboutBufferOverflow = true) const;
#endif

    uint32 LengthAsWideCharCString() const;

    void AsWideCharCString(photoshop::utf16_t wccstr[],
                           int32 wccstrBufferSize,
                           bool warnAboutBufferOverflow = true) const;

    uint32 LengthAsCString() const;
    
    void AsCString(char cstr[],
                   int32 cstrBufferSize,
                   bool warnAboutBufferOverflow = true) const;

    uint32 LengthAsUTF8String() const;
    void AsUTF8String(unsigned char utf8_cstr[],
                      int32 utf8BufferSize,
                      bool warnAboutBufferOverflow = true) const;

    photoshop::utf16_string as_wstring() const;

#if INSIDE_PHOTOSHOP
    std::string as_utf8_string() const;

    operator std::string() const { return as_utf8_string(); }
#endif
    bool HasEnglishPartOfKey(std::string* englishPart = nullptr) const;

    uint32 LengthAsLowAsciiCString() const;

    void AsLowAsciiCString(char cstr[],
                           int32 cstrBufferSize,
                           bool warnAboutBufferOverflow = true) const;

    uint32 LengthAsCStringForMacScriptCodePage(const short macScript) const;

    void AsCStringForMacScriptCodePage(const short macScript,
                                       char cstr[],
                                       int32 cstrBufferSize,
                                       bool warnAboutBufferOverflow = true) const;

#if MSWindows
    uint32 LengthAsCStringForWindowsCodePage(
        const short windowsCodePage,
        bool retryWithDefaultCodePage = false,
        bool useSpecialFunkySubstitutions = false) const;

    void AsCStringForWindowsCodePage(
        const short windowsCodePage,
        char cstr[],
        int32 cstrBufferSize,
        bool warnAboutBufferOverflow = true,
        bool retryWithDefaultCodePage = false,
        bool useSpecialFunkySubstitutions = false) const;

#endif

    uint32 LengthAsPascalString() const; // NOTE:  may return greater than 255

    void AsPascalString(unsigned char pstr[],
                        unsigned char maxLength,
                        bool warnAboutBufferOverflow = true) const;

#if INSIDE_PHOTOSHOP
    void AsPascalString(CStr31& pstr, bool warnAboutBufferOverflow = true) const;
    void AsPascalString(CStr32& pstr, bool warnAboutBufferOverflow = true) const;
    void AsPascalString(CStr63& pstr, bool warnAboutBufferOverflow = true) const;
    void AsPascalString(CStr255& pstr, bool warnAboutBufferOverflow = true) const;
#endif

    uint32 LengthAsPascalStringForMacScriptCodePage(const short macScript) const;

    void AsPascalStringForMacScriptCodePage(
        const short macScript,
        unsigned char pstr[],
        unsigned char maxLength,
        bool warnAboutBufferOverflow = true) const;

#if INSIDE_PHOTOSHOP
    void AsPascalStringForMacScriptCodePage(
        const short macScript,
        CStr31& pstr,
        bool warnAboutBufferOverflow = true) const;
    void AsPascalStringForMacScriptCodePage(
        const short macScript,
        CStr32& pstr,
        bool warnAboutBufferOverflow = true) const;
    void AsPascalStringForMacScriptCodePage(
        const short macScript,
        CStr63& pstr,
        bool warnAboutBufferOverflow = true) const;
    void AsPascalStringForMacScriptCodePage(
        const short macScript,
        CStr255& pstr,
        bool warnAboutBufferOverflow = true) const;

#if MSWindows

    uint32 LengthAsPascalStringForWindowsCodePage(
        const short windowsCodePage) const;

    void AsPascalStringForWindowsCodePage(
        const short windowsCodePage,
        unsigned char pstr[],
        unsigned char maxLength,
        bool warnAboutBufferOverflow = true) const;

    void AsPascalStringForWindowsCodePage(
        const short windowsCodePage,
        CStr31& pstr,
        bool warnAboutBufferOverflow = true) const;
    void AsPascalStringForWindowsCodePage(
        const short windowsCodePage,
        CStr32& pstr,
        bool warnAboutBufferOverflow = true) const;
    void AsPascalStringForWindowsCodePage(
        const short windowsCodePage,
        CStr63& pstr,
        bool warnAboutBufferOverflow = true) const;
    void AsPascalStringForWindowsCodePage(
        const short windowsCodePage,
        CStr255& pstr,
        bool warnAboutBufferOverflow = true) const;

#endif
#endif

    void GetSegments(std::vector<ZString>& segments,
                     const unsigned short delimiter) const;

    void GetSegments(std::vector<ZString>& segments,
                     const unsigned short* delimiters,
                     uint32 numDelimiters) const;

    void SetFromSegments(const std::vector<ZString>& segments,
                         const unsigned short delimiter);

    uint32 CountLines() const;

#if qZStringLogging
    static void DumpHashProfiles(void);
#endif

#if qAssertions
    bool IsPrivate() const { return fIsPrivate; }
    void SetPrivate(bool isPrivate) { fIsPrivate = isPrivate; }
#endif
    enum FindFromLocation { tflFromBeginning, tflFromEnd };

    bool FindFirstNonMatchingCharacterPosition(
        const unsigned short* matchChars,
        uint32 numChars,
        uint32& position,
        FindFromLocation findFromLoc = tflFromBeginning) const;

    ZString RemoveCharactersFromBeginningAndEnd(const unsigned short* charsToRemove,
                                                uint32 numChars) const;

#if qAssertions && INSIDE_PHOTOSHOP
protected:
    friend class TShowAnyZStringDialog;
    ZString ZStringFromZStringKey();
    static ZString ZStringFromDictionaryEntryKey(ZStringDictionaryEntry* entry);
#endif // qAssertions && INSIDE_PHOTOSHOP
};
```
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
## Sequences

- For a sequence of _n_ elements their are _n + 1_ positions
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "fragment"} -->
- How to represent a range of elements?
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "fragment"} -->
- Problem with closed interval `[f, l]`?
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "fragment"} -->
- Problem with open interval `(f, l)`?
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "fragment"} -->
- Half-open intervals have significant advantages `[f, l)`
    - By strong convention we are open on the right
<!-- #endregion -->

- Think of the positions as the lines between the elements

<!-- #region slideshow={"slide_type": "slide"} -->
- Limitations of half-open intevals
    - If there is not _next element_ then a half open interval cannot express a single element
    - If there is a finite number of elements, the last (or first) cannot be included
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
- There are different common ways to represent a sequence
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "fragment"} -->
- `[f, l)`
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "fragment"} -->
- `[f, f + n) _n`
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "fragment"} -->
- `[f, predicate()) _until`
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "fragment"} -->
- `[f, is_sentinel())` NTBS
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "fragment"} -->
- `[f, ...)` unbounded (dependent on something else)
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "fragment"} -->
- For a variable `a` in C and C++, it is guaranteed that `&a + 1` yields a valid, but not dereferenceable, pointer
    - `[&a, &a + 1)` is a valid range
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
<center>
    <img src='img/sequence-1.svg' alt='Sequence 1'>
    <br>
    <em>Sequence With Pointers To Objects</em>
</center>
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
<center>
    <img src='img/sequence-2.svg' alt='Sequence 2'>
    <br>
    <em>Sequence With Pointers Between Objects</em>
</center>
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "skip"} -->
**_Next cell is algorithm-slide keynote_**
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
<section>
    <iframe data-src="../keynote-player/KeynoteDHTMLPlayer.html?showUrl=../better-code-class/img/algorithm-slide/assets/" data-preload></iframe>
</section>
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
## Common algorithms and their uses

- A great resource for finding standard algorithms:

https://en.cppreference.com/w/cpp/algorithm
https://en.cppreference.com/w/cpp/numeric
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
### Non-modifying sequence operations

- `for_each`
- `find`
<!-- #endregion -->

```c++ slideshow={"slide_type": "slide"}
int a[]{1, 2, 3};
```

```c++ slideshow={"slide_type": "fragment"}
for_each(begin(a), end(a), [](const auto& e){ cout << e; });
```

```c++ slideshow={"slide_type": "fragment"}
for(const auto& e : a) cout << e;
```

```c++
template <class I>
struct subrange {
    I _f;
    I _l;
};

template <class I>
I begin(subrange<I>& x) { return x._f; }

template <class I>
I end(subrange<I>& x) { return x._l; }
```

```c++
namespace library {
template <class I, // I models InputIterator
          class T> // value_type(I) is convertible to T
subrange<I> find(I f, I l, const T& x) {
    auto p = std::find(f, l, x);
    return {p, (p == l) ? p : std::next(p)};
}
}
```

```c++
for(const auto& e : library::find(begin(a), end(a), 2)) cout << e;
```

```c++
for(const auto& e : library::find(begin(a), end(a), 0)) cout << e;
```

<!-- #region slideshow={"slide_type": "slide"} -->
### Modifying sequence operations

- `copy`
- `move`
- `fill`
- `transform`
- `generate`
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
### Sorting operations

- `sort`
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "fragment"} -->
- Comparison function must be a strict-weak ordering:

> Two object, $a$ and $b$, are _equivalent_, $\equiv$, iff $(a \nprec b) \wedge (b \nprec a)$.

\begin{align}
(a & \nprec a). && \text{(Irreflexivity)} \\
(a & \prec b) \wedge (b \prec c) \implies a \prec c. && \text {(Transitivity)} \\
(a & \equiv b) \wedge (b \equiv c) \implies a \equiv c. && \text {(Equivalence Transitivity)}\\
\end{align}
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
### Binary search operation

- `lower_bound`
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "slide"} -->
**Exercise:** Review list of standard algorithms.
<!-- #endregion -->

<!-- #region slideshow={"slide_type": "skip"} -->
**Exercise:** Find a _raw loop_ in the ZString implementation. Claim it on the wiki https://git.corp.adobe.com/better-code/class/wiki/class-04-registration. Improve the code, create a pull-request, and assign me as the reviewer. The PR should include a http://quick-bench.com/ benchmark of the relevant code for comparison.
<!-- #endregion -->

<!-- #region jupyter={"source_hidden": true} slideshow={"slide_type": "skip"} -->
<!--- stopped here --->

## More advanced algorithms

## New Algorithms (C++11 - 20)

## Position Based Algorithms
  - All non-modifying sequence operations taking a predicate
  
## Strict Weak Order

## Iterator hierarchy (and why you probably shouldn't care)

## Writing a custom algorithm
- what to return

## Composition vs. multi-pass

## Generators vs input iterator

## Output iterators vs sink functions
<!-- #endregion -->
