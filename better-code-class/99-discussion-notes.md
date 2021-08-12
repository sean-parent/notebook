# Better Code Discussion Notes

Distilled from discussions between Sean and Dave

# Introduction
  * This is a course/book on engineering
  
## Definition of Engineering:

> The creative application of scientific principles to design or develop
> structures, machines, apparatus, or manufacturing processes, or works
> utilizing them singly or in combination; or to construct or operate the same
> with full cognizance of their design; or to forecast their behavior under
> specific operating conditions; all as respects an intended function, economics
> of operation and safety to life and property.

—American Engineers' Council for Professional Development, according to
https://en.wikipedia.org/wiki/Engineering.

But that's a bit wordy and vague. Boiling it down to its essence,
1. It's designing and building stuff
2. It's subject to real-world constraints, e.g.
    * Shipping dates
    * Available tooling
    * Hardware available for deployment
    * Laws of physics

And as engineers we have to juggle all of this and make a set of informed
tradeoffs to find the best solution.  Real-world constraints mean engineers will
always confront trade-offs, so much so that making these trade-offs could be
said to be the essence of the activity.

> Engineering is making informed tradeoffs to produce the best design or
> artifact possible given a set of constraints.

## Instructor/Author Bias

We come from a set of experiences that will color what we think is important.
However we've attempted to be responsible for 

# Miscellaneous

## Computational and efficient bases

- Must be measured relative to an intended abstraction.  A type with just
  zero, increment, and is_odd is a computationally complete boolean but not a
  computationally complete integer.
- Raises the questions:
  - What *is* this thing you're building (to its clients)?
  - What are its observable parts?
  - What is its value?

-
## Necessary ingredients for Scalable/Sustainable Software

If we can make this list long enough, it could be a theme threaded through the
book.

- Local reasoning
- Preconditions, postconditions, and invariants (techniques for local reasoning)

## Definition of “safe”

We agreed that to define a “safe” operation as one that, when used according to
contract, cannot result in undefined behavior, either immediately or after any
arbitrary sequence of other safe operations used according to contract.

- DWA: For C++ we might need to exempt things due to “implementation limits,”
  e.g., running out of stack space.
- An “safe” operation can have an unspecified (a.k.a. meaningless) result.
- This definition is on a continuum with type-safety.
- DWA: Perhaps we need some qualifier analogous to “type-” to go with this kind
  of safety?

Some examples:

- All built-in casts are potentially-unsafe.
- An object upcast is safe.  A pointer or reference upcast is unsafe because,
  e.g., it allows the base part of an object to be subsequently modified or
  destroyed.
- `std::move` is unsafe because it allows an otherwise-safe operation like
  move-assignment to leave its argument in a condition that does not satisfy
  invariants. See [Move semantics and invariants](#move-semantics-and-invariants).

## Move Semantics and Invariants

C++ has non-destructive move semantics.  That was a mistake, but that's how it
is. Unfortunately, there are some types (or some type invariants) for which no
safe + efficient non-destructive move operation exists—patching up an object
that's been emptied of its resources is not always easy/efficient, and weakening
invariants to accomodate the empty state is bad for reasoning about the rest of
the program.

One possible conclusion is that move operations (move assignment and move
construction) should be regarded as unsafe, because they may leave the object
with broken invariants. That would weaken the whole concept of class invariants,
which are supposed to hold unconditionally, after any public operation.
Invariants are powerful tools for creating simple abstractions precisely because
they *do not need to be stated as preconditions*, which would be necessary if
they could be left unsatisfied.

Instead, we can observe that move operations in code without `std::move` (or
some equivalent cast) are only applied to rvalues: the language prevents the
moved-from state from being observed except by the destructor that is about to
run, and once the object is destroyed, the temporary breakage of invariants is
irrelevant. Therefore, as long as the destructor is written to deal with 
moved-from states, we can view the fused move+destroy as being safe.

That leaves only moves from lvalues, which occur only after calls to `std::move`
or equivalent casts. The language does *not* prevent a moved-from lvalue from
being passed to, and observed by, a function whose correctness depends on the
class invariants. As noted above, the invariant is not stated as a precondition,
so such a call must be regarded as “usage according to contract.”  Because the
behavior of such a call could be undefined, `std::move` must be regarded as an
unsafe operation (conveniently, just like any other cast).

Many use cases for moving from lvalues demand replacing unsafe, moved-from,
lvalues with safe values. In-place destruction + construction creates problems
for exception safety (the construction might throw, leaving a destroyed object),
so a single operation is required, and for better or worse, C++ chose to spell
this operation the same way as an ordinary assignment.  Thus, in addition to the
destructor, copy- and move-assignment operators must be written to deal with
moved-from states.  Every other public operation can depend on invariants being
satisfied, but not these three.
