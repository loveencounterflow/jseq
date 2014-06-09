

- [jsEq](#jseq)
- [Language Choice and Motivation](#language-choice-and-motivation)
- [Test Module Setup](#test-module-setup)
- [Implementations Module Setup](#implementations-module-setup)
- [Equality, Identity, and Equivalence](#equality-identity-and-equivalence)
- [First Axiom: Value Equality Entails Type Equality](#first-axiom-value-equality-entails-type-equality)
- [Equality of Sub-Types](#equality-of-sub-types)
- [Equality of Numerical Values in Python](#equality-of-numerical-values-in-python)
- [Second Axiom: Equality of Program Behavior](#second-axiom-equality-of-program-behavior)
- [Infinity, Positive and Negative Zero](#infinity-positive-and-negative-zero)
- [Not-A-Number](#not-a-number)
- [Object Property Ordering](#object-property-ordering)
- [Properties on 'Non-Objects'](#properties-on-'non-objects')
- [Primitive Values vs Objects](#primitive-values-vs-objects)
- [Undefined Properties](#undefined-properties)
- [Functions (and Regular Expressions)](#functions-and-regular-expressions)
- [How Many Methods for Equality Testing?](#how-many-methods-for-equality-testing)
- [Plus and Minus Points](#plus-and-minus-points)
- [Benchmarks](#benchmarks)
- [Libraries Tested](#libraries-tested)
- [Caveats and Rants](#caveats-and-rants)

> **Table of Contents**  *generated with [DocToc](http://doctoc.herokuapp.com/)*


### jsEq

There are a couple of related, recurrent and, well, relatively 'deep' problems that vex many people who
program in JavaScript on a daily basis, and those are sane **(deep) equality testing**, sane **deep
copying**, and sane **type checking**.

jsEq attempts to answer the first of these questions—how to do sane testing for deep equality in JavaScript
(specifically in NodeJS)—by providing an easy to use test bed that compares a number of libraries that
purport to deliver solutions for deep equality. It turns out that there are surprising differences in detail
between the libraries tested, as the screen shot below readily shows (don't take the `qunitjs` test
seriously, those are currently broken due to the (to me at least) strange API of that library).
Here is a sample output of jsEq running `node jseq/lib/main.js`:

![Output of `node jseq/lib/main.js`](https://github.com/loveencounterflow/jseq/raw/master/._art/Screen%20Shot%202014-06-04%20at%2000.31.24.png)

> Implementations whose key starts with a `*` are 'hobbyists solutions' that i have gleaned
> from blogs and answers on StackOverflow.com; they're included mainly to show how well one can expect
> an ad-hoc solution can be expected to work (quite well in some cases, it turns out). See the
> [list of tested libraries](#libraries-tested) and the [caveats section](#caveats).

The `lodash` and `underscore` results are probably identical because `lodash` strives to be a 'better
`underscore`'.

> At first it may be hard to see what `ne +0, -0` could be useful for as in JavaScript, `+0 == -0` holds,
> but see below for
> [Infinity, Positive and Negative Zero](#infinity-positive-and-negative-zero)

The `jkroso equals` and `CoffeeNode Bits'N'Pieces` results are identical since the former is really the
implementation of the latter; based on the results shown i'll try to devise a solution that combines
different libraries and passes all tests.

It has to be said that while—as it stands—jsEq will run no less than `12 * 212 == 2544` tests, most tests
are between primitive values, which explains why bot JS `==` and `===` turn in with around 9 out of 10 tests
passed.

### Language Choice and Motivation

The present module has been implemented in [CoffeeScript](http://coffeescript.org), my favorite language
these days. Most of the examples in the present ReadMe are in CoffeeScript, too, so whenever you see
a construct like `f x, y`, you'll have to
mentally translate that into `f( x, y )`. What's more, CoffeeScript's `==` operator translates to
JavaScript's `===`, while JS `==` has (rightly) no equivalent in CS. I agree that this can be
confusing, especially in a text like this where different concepts of equality play a crucial role. I
strive for clarity in this point by making sure that whenever an isolated `==` or `===` appears, it is
annotated from which language it has been taken.

> I for one prefer to use `:` for assignment
> (as it is already done inside object literals) and `=` for equality testing, which is one of the reasons
> i started [Arabika](https://github.com/loveencounterflow/arabika/), an as yet incipient and experimental
> language where i try out parametrized, modular grammars (so that if you like the language but can't live
> with my particular choice for the equals operator, you can instantiate your own grammar with your
> own choice for that one).

Incidentally, I'm writing lots of tests for Arabika, and one day I was struck
by a false positive when a parsing result à la `[ 3 ]` passed the comparison to `[ '3' ]`.
Research quickly showed NodeJS' `assert.deepEqual` to be the culprit, so i chimed in to the
[discussion on bug #7161](https://github.com/joyent/node/issues/7161). I felt i was not completely alone
in my quest for sound equality testing in JavaScript, and the subject being too complex to grasp with
haphazard, isolated ad-hoc tests issued via the NodeJS REPL, i came up with jsEq: it is not a new
implementation of JS (deep) equality, but rather an extensible framework to test available software that
purports to have an answer to the vexing problem whether two given values are or are not equal.

### Test Module Setup

Test cases are set up in the `src/implementations.coffee` modules, inside a function that accepts two
functions `eq`, `ne` and returns an object of test cases. Test case names are short descriptions of what
they test for and are used to produce a legible output.

Tests that run a single test should return the result of applying the provided `eq` or `ne` to test for the
current implementation's concept of equality with `eq` or inequality with `ne` aginst a pair of values.

Tests that run multiple subtests should return a pair `[ n, errors, ]` where `n` is the subtest count and
`errors` is a list with a meaningful message for each failed subtest (the individual messages from such
'mass testing facilities' are currently not shown, as they produce a *lot* of output, but that will probably
be made a matter of configuration). Here's what `src/implementations.coffee` currently looks like:

```coffeescript
#-----------------------------------------------------------------------------------------------------------
module.exports = ( eq, ne ) ->
  R = {}

  ### 1. simple tests ###

  #---------------------------------------------------------------------------------------------------------
  ### 1.1. positive ###

  R[ "NaN equals NaN"                                           ] = -> eq NaN, NaN
  R[ "finite integer n equals n"                                ] = -> eq 1234, 1234
  R[ "emtpy array equals empty array"                           ] = -> eq [], []
  R[ "emtpy object equals empty object"                         ] = -> eq {}, {}

  #---------------------------------------------------------------------------------------------------------
  ### 1.2. negative ###

  R[ "object doesn't equal array"                               ] = -> ne {}, []
  R[ "object in a list doesn't equal array in array"            ] = -> ne [{}], [[]]
  R[ "integer n doesn't equal rpr n"                            ] = -> ne 1234, '1234'
  R[ "empty array doesn't equal false"                          ] = -> ne [], false
  R[ "array with an integer doesnt equal one with rpr n"        ] = -> ne [ 3 ], [ '3' ]

  #=========================================================================================================
  ### 2. complex tests ###
  #---------------------------------------------------------------------------------------------------------
  R[ "circular arrays with same layout and same values are equal (1)" ] = ->
    d = [ 1, 2, 3, ]; d.push d
    e = [ 1, 2, 3, ]; e.push d
    return eq d, e

  #---------------------------------------------------------------------------------------------------------
  R[ "circular arrays with same layout and same values are equal (2)" ] = ->
    d = [ 1, 2, 3, ]; d.push d
    e = [ 1, 2, 3, ]; e.push e
    return eq d, e

  #---------------------------------------------------------------------------------------------------------
  ### joshwilsdon's test (https://github.com/joyent/node/issues/7161) ###
  R[ "joshwilsdon" ] = ->
    d1 = [ NaN, undefined, null, true, false, Infinity, 0, 1, "a", "b", {a: 1}, {a: "a"},
      [{a: 1}], [{a: true}], {a: 1, b: 2}, [1, 2], [1, 2, 3], {a: "1"}, {a: "1", b: "2"} ]
    d2 = [ NaN, undefined, null, true, false, Infinity, 0, 1, "a", "b", {a: 1}, {a: "a"},
      [{a: 1}], [{a: true}], {a: 1, b: 2}, [1, 2], [1, 2, 3], {a: "1"}, {a: "1", b: "2"} ]
    errors = []
    for v1, idx1 in d1
      for idx2 in [ idx1 ... d2.length ]
        v2 = d2[ idx2 ]
        if idx1 == idx2
          unless eq v1, v2
            errors.push "eq #{rpr v1}, #{rpr v2}"
        else
          unless ne v1, v2
            errors.push "ne #{rpr v1}, #{rpr v2}"
    #.......................................................................................................
    return [ d1.length, errors, ]


  #---------------------------------------------------------------------------------------------------------
  return R
```

### Implementations Module Setup

Like the test cases, the `src/implementations.coffee` module is of rather light structure:

```coffeescript

#-----------------------------------------------------------------------------------------------------------
module.exports =

  # Ex.: how to use JS syntax
  #.........................................................................................................
  "==: native ==":
    #.......................................................................................................
    eq: ( a, b ) -> `a == b`
    ne: ( a, b ) -> `a != b`

  # Ex.: how to adapt methods of assertion frameworks
  #.........................................................................................................
  "NDE: NodeJS assert.deepEqual":
    #.......................................................................................................
    eq: ( a, b ) ->
      try
        ASSERT.deepEqual a, b
      catch error
        return false
      return true
    #.......................................................................................................
    ne: ( a, b ) ->
      try
        ASSERT.notDeepEqual a, b
      catch error
        return false
      return true

  # Ex.: how to adapt other methods
  #.........................................................................................................
  "LDS: lodash _.isEqual":
    #.......................................................................................................
    eq: ( a, b ) -> LODASH.isEqual a, b
    ne: ( a, b ) -> not LODASH.isEqual a, b
```

The setup is very simple: Each implementation is an object with two members, `eq` to test for 'is equal to'
and `ne` to test for 'is not equal to'. Each name starts with a one to three-letter (unique) key which is
used for reference in the report display (see above), followed by a `:` (colon) and the name proper (which
should be descriptive and unique). The name may be prepended with an `!` (exclamation sign) in case the way
it has been adapted is suspected to be faulty (happened to me with the QUnit framework, which has a weird
API; i will probably make the relevant test results appear in grey and not include them in the grand
totals). Each function `eq`, `ne` must accept two arguments and return `true` or `false`, indicating success
or failure.


### Equality, Identity, and Equivalence

There will be a lot of talk about equality and related topics in this text, so it behooves us to shortly if
not strictly define, then at least make sufficiently clear some pertinent terms. Fear not, this formal
discussion will be short, and save for one more stretch of (rather shallow) theoretical discussion, this
ReadMe will remain fairly pragmatic; it may even be said that it is a pronouncedly pragmatic text that aims
to deliver arguments against an ill-conceived standard fraught with artificial rules that serve no practical
purpose (readers who bear with me will not be left in doubt which standard i'm talking about).

Three vocables will have to be used in any discussion of 'what equals what' in programming languages: these
are **equality**, **identity**, and **equivalence**.

First off, to me, **equality and identity are extensional, formal qualities, but equivalence is an
intentional, informal quality**. With 'extensional' i mean 'inherent to the material qualities of a given
value', while 'intentional' pertains to values only in so far as they are put to some specific use, with a
certain functionality or result to be achieved.

Put simply, the physical weight of a given nail is an extensional quality of that nail; that it is used, in
a given case, to hang some framed picture onto some wall is an incidental property of it that arises from a
willful decision of some agent who arranged for this configuration. Likewise, the property that, in
JavaScript, i can say both `console.log( 42 )` and `console.log( '42' )` to achieve a display of a digit `4`
is an intentional property; it could be different. It surely strikes us as natural, but that is mainly
because we are so accustomed to write out numbers in the decimal system that we are prone to think of
'number forty-two' as 'sequence of digit 4, digit 2'. This analogy breaks down quickly as soon as one
modifies the setup: when i write `console.log( 042 )` (or `console.log( 0o42 )` in more recent editions of
JS), what i get is a sequence of 'digit 3, digit 4', which is different from the sequence `0`, `4`, `2` as
used in the source that caused this behavior. While it is acceptable to prefer the decimal system for
producing human-readable outputs, JavaScript's handling of strings-that-look-like-numbers is plain nutty.
Consider (using CoffeeScript and `log` for `console.log`):

```coffeescript
log '42' +  8     # prints 428
log  42  + '8'    # prints 428
log  42  * '8'    # prints 336
log '42' *  8     # prints 336
```

Here, we see that when we use the `+` (plus operator) to 'add' a string and a number, the output will be a
string that concatenates the string with the decimal representation of that number. BUT if we use the `*`
(times) operator, we get a number that is the result of the multiplication of the two arguments, the string
being interpreted as a decimal number, where possible. This is so confusing and leads to so many surprising
ramifications that there is, in the community, an expletive to describe such phenomena, and that expletive
is **WAT!**

I'm discussing these well-known JS WATs in the present context because JavaScript programmers (much like
users of PHP, and certainly more than users of Python) are very much inclined to have a rather muddled
view on data types, and, hence, of equality at large. This is borne out by the refusal of some people
to acknowledge that a method called `deepEqual` that considers `[ 42 ]` to 'equal' `[ '42' ]` is pretty
much useless; more on that topic below.

It can be said that JavaScript's `==` 'non-strict equals operator' never tested *value equality* at all,
rather, it tested *value equivalence*. Now we have seen that equivalence is a highly subjective concept that
is susceptible to the conditions of specific use cases. As such, it is a bad idea to implement it in the
language proper. The very concept that `3 == '3'` ('number three is equivalent to a string with the ASCII
digit three, U+0033') does hold in some common contexts (like `console.log( x )`), but it breaks down in
many other, also very common contexts (like `x.length`, which is undefined for numbers).

Further, it can be said that JavaScript's `===` 'strict equals operator' never tested *value equality* at
all, but rather *object identity* (alas, with a few lacunae, as we shall see), with the understanding that
all the primitive values have one single identity per value (something that e.g. seems to hold in Python for
all integers, but not necessarily all strings).


### First Axiom: Value Equality Entails Type Equality

An important axiom in computing is that

**Axiom 1** Two values `x` and `y` can only ever be equal when they both have the same type; conversely,
when two values are equal, they must be of equal type, too.

More formally, let **L** denote the language under inspection (JS or CS), and be **M** the meta-language to
discuss and / or to implement **L**. Then, saying that (in CS) `eq x, y` results in `true` implies that
`eq ( type_of x ), ( type_of y )` must also be `true`.

We can capture that by saying that in **M**, all values `x` of **L** are represented by tuples ⟨*t*, *v*⟩
where *t* is the type of `x` and *v* is its 'magnitude', or call it 'its underlying data proper', i.e. its
'value without its type'—which does sound strange but is technically feasible, since all unique values that
may occur within a real-world program at any given point in time are enumerable and, hence, reducible to
⟨*t*, *n*⟩, where *n* is a natural number. Since all *n* are of the same type, they can be said to be
typeless.

When we are comparing two values for equality in **L**, then, we are really comparing the two elements of
two tuples ⟨*t<sub>1</sub>*, *v<sub>1</sub>*⟩, ⟨*t<sub>2</sub>*, *v<sub>2</sub>*⟩ that represent the values
in **M**, and since we have reduced all values to integers, and since types are values, too, we have reduced
the problem of computing `eq x, y` to doing the equivalent of `eq [ 123, 5432, ], [ 887, 81673, ]` which has
an obvious solution: the result can only be `true` if the two elements of each tuple are pairwise identical.

> The above is not so abstruse as it may sound; in Python, `id( value )` will give you an integer that
> basically returns a number that represents a memory location, and in JavaScript, types are commonly
> represented as texts. Therefore, finding the ID of a type entails searching through memory whether
> a given string is already on record and where, and if not, to create such a record and return its memory
> address. Further, i would assume that most of the time, maybe always when you do `'foo' === 'foo'` in
> JavaScript, what you really do is comparing *IDs*, not strings of characters.
>
> To make it very clear: i am not proposing here that the shown implementation of **L** in **M** is actually
> used in practical programming languages, or that it would be overall a good design at all; rather, it is
> teaching device like BASIC (intended to be an easy language for beginners) and a thought-experiment like
> Turing machines (intended to make a proof by way of reduction).

I hope this short discussion will have eliminated almost any remaining doubt whether two values of different
types can ever be equal. However, there are two questions i assume the astute reader will be inclined
to ask. These are: **what about sub-typed values?** and, **what about numbers?**


### Equality of Sub-Types

As for the first question—**what about sub-typed values?**—i think we can safely give it short shrift. A
type is a type, irregardless of how it is derived. That an instance of a given type shares methods or data
fields with some other type doesn't change the fact that somewhere it must have—explicitly or implicitly,
accessible from **L** or only from **M**—a data field where its type is noted, and if the contents of that
field do not equal the equivalent field of the other instance, they cannot be equal if our above
considerations make any sense. True, some instances of some sub-types may stand in for some instances of
their super-type in some setups, but that is the same as saying that a nail can often do the work of a
screw—in other words, this consideration is about *fitness for a purpose* a.k.a. *equivalence*, not about
equality as understood here. Also, that a nail can often do the work of a screw does crucially not hinge on
a screw being conceptualized as 'a nail with a screw thread' or a nail reified as 'a screw with a zero-depth
thread'. In other words, just because, in some languages, both `print 3` and `print '3'` effect the
appearance of a digit three in the output medium doesn't mean that `3` and `'3'` are 'the same'.


### Equality of Numerical Values in Python

As for the second question—**what about numbers?**—it is in theory somewhat harder than the first, but,
fortunately, there is an easy solution.

JavaScript may be said to be simpler than many other languages, since it has only a single numerical
type, which implements the well-known IEEE 754 floating point standard with all its peculiarities.

Many languages do have more than a single numerical type. For instance, Java has no less than six: `byte`,
`short`, `int`, `long`, `float`, `double`, which users do have to deal consciously with.

Python before version 3 had four types: `int`, `float`, `long`, `complex`; in version 3, the `int` and
`long` types have been unified. Moreover, Python users have to worry much less about numerical types than
Java users, as Python tries very hard—and manages very well—to hide that fact; for most cases, numerical
types are more of a largely hidden implementation detail than a language feature. This even extends to
numerical types that are provided by the Standard Library, like the arbitrary-precision `Decimal` class.

Python has the best thought-out numerical system of any programming language i had ever contact with, so my
rule of thumb is that whatever Python does in the field of numbers is worthy of emulation.

It turns out that in Python, numbers of different types do compare equal when the signs and magnitudes of
their real and complex parts are equal; therefore, `1 == 1.0 == 1 + 0j == Decimal( 1 )` does hold. This
would appear to be in conflict with our theory (since we're comparing values of four different types here),
so either Python gets it wrong or the theory is incorrect.

One way to resolve the conflict is to say that the *t* in the tuples ⟨*t*, *v*⟩ of **M** do simply record an
abstract type `number` instead of any subclass of numbers, this being an exception that is made for
practical reasons. Another solution would be to state that our theory is only applicable to languages which
have only a single numerical type, so it may be valid for JavaScript, but certainly not Java or Python.

A third way, and i believe the right one, is to assert that **what Python does with its `1 == 1.0 == 1 + 0j
== Decimal( 1 )` comparison is really *not* doing equality, but rather equivalence testing, tailored to the
specific use-case of comparing numerical values for arithmetic purposes**. Indeed, it turns out that Python
allows you to overload the behavior of the `==` operator by defining a special method `__eq__` on a class,
and, if you are so inclined, you can make Python say yes to `x == y` even though `x.foo == y.foo` does *not*
hold! It is in fact very simple:

```python
class X:

  def __init__( self, foo ):
    self.foo = foo

  def __eq__( self, other ):
    return ( self is not other ) and self.foo % other.foo == 0

x = X( 12 )
y = X( 6 )
z = X( 7 )

print( x == x ) # False
print( x == y ) # True
print( x == z ) # False
print( y == z ) # False
```

This example is more evidence in favor of the above assertion. If Python's `==` operator had been intended
to comply with our strict version of equality, there would have been little need to encourage overloading
the `==` operator, as the answer to that question can be given without implementing any class-specific
methods, from an abstract point of view. It is not immediately clear what use could be made of a value  that
blatantly violates `x == x`, but the fact that Python has no qualms in allowing the programmer such utterly
subversive code corroborates the notion that what we're dealing with here is open-minded equivalence rather
than principled equality.

Since there is, anyways, only a single numerical type in JavaScript, i believe we should stick with the
unadultered version of the First Axiom which forbids cross-type equality even for numerical types.

### Second Axiom: Equality of Program Behavior

The above treatment of numerical types has shown that Python prefers to consider `1 == 1.0` true because it
may be said that for *most* practical cases, there will be no difference between results whatever numerical
type you use (although it should be pointed out that already division in older Pythons used to act very
differently whether used with integers or floating-point numbers).

But that, of course, is not *quite* right; the whole reason for using, say, `Decimal` instead of `Float` is
to make it so that arithmetic operations *do* turn out differently, e.g. in order to deal with precise
monetary amounts and avoid rounding errors (you never calculate prices using floating-point numbers in
JavaScript, right?).

Now, the reason for programmers to write test suites is to ensure that a program behaves the expected way,
and that it continues to return the expected values even when some part of it gets modified. It is clear
that using some `BigNum` class in place of ordinary numbers *will* likely make the program change behavior,
for the better or the worse, and in case you're writing an online shopping software, you *want* to catch all
those changes, which is tantamount to say you do *not* want *any* kind of `eq ( new X 0 ), 0` tests to
return `true`, precisely because `0.00` is your naive old way and `new X 0.00` is your fool-proof new way of
saying 'zero dollars', and you want to avoid missing out on any regression in this important detail.

Thus our second axiom becomes:

**Axiom 2** Even two values `x`, `y` of the same type that can be regarded as equal for most use cases, they
must not pass the test `eq x, y` in case it can be shown that there is at least one program that has different
outputs when run with `y` instead of with `x`.

The second axiom helps us to see very clearly that Python's concept of equality isn't ours, for there is a
very simple program `def f ( x ): print( type( x ) )` that will behave differently for each of `1`, `1.0`,
`1 + 0j`, `Decimal( 1 )`. As for JavaScript, the next section will discuss a relevant case.

### Infinity, Positive and Negative Zero

One of the (many) surprises / gotchas / peculiarities that JavaScript has in store for the n00be programmer
is the existence of *two zeroes*, one positive and one negative. What, i hear you say, and no sooner said
than done have you typed `+0 === -0`, return, into the NodeJS REPL, to be rewarded with a satisfyingly
reassuring `true`. That should do it, right?—for haven't we all learned that when a `x === y` test returns
`true` it 'is True', and only when that fails do we have to do more checking? Sadly, this belief is
mistaken, as the below code demonstrates:

```coffeescript
signed_rpr = ( x ) ->
  return ( if is_negative_zero x then '-0' else '+0' ) if x is 0
  return Number.prototype.toString.call x

is_negative_zero = ( x ) -> x is 0 and 1 / x < 0

test_signed_zero = ->
  log +0 == -0               # true
  log +1 / +0                # Infinity
  log +1 / -0                # -Infinity
  log 1 / +0 * 7             # Infinity
  log 1 / -0 * 7             # -Infinity
  log +0     < 0             # false
  log -0     < 0             # false
  log +0 * 7 < 0             # false
  log -0 * 7 < 0             # false
  log Infinity * 0           # NaN
  log Infinity / +0          # Infinity
  log Infinity / -0          # -Infinity
  log signed_rpr +0 ** +1    # +0
  log signed_rpr -0 ** +1    # -0
  log signed_rpr +0 ** -1    # Infinity
  log signed_rpr -0 ** -1    # -Infinity

test_signed_zero()
```

When i first became aware of there being a `+0` and a `-0` in JS, i immediately wrote a test case: `R[ "+0
should eq -0" ] = -> eq +0, -0`. I then proceeded adding libraries to jsEq and felt happy that the work i
put into delivering pretty detailed test reports was not for naught as more and more small differences
between the libraries popped up: this library misses that test case, the next passes the other test, and so
on. I sorted the results, and seeing that `underscore` got the highscore (pun intended), it surprised me to
see that it insisted on treating `+0` and `-0` as *not* equal. Ultimately, this led to the discovery of the
second Axiom, and with that in my hands, it became clear that `underscore` got this one right and my test
case got it wrong: **Since there are known programs that behave differently with positive and negative zero,
these two values must not be considered equal**.


### Not-A-Number

Yet another one of that rich collection of JavaScript easter eggs (and, like `+0` vs `-0`, one that is
mandated by IEEE 754), is the existence of a `NaN` (read: Not A Number) value. In my opinion, this value
shouldn't exist at all. JS does consistently the right thing when it throws an exception on `undefined.x`
(unable to access property of `undefined`) and on `f = 42; f 'helo'` (`f` is not a function), and, as
consistently, fails silently when you access undefined object properties or do numerical nonsense. In the
latter case, it resorts to returning sometimes `Infinity`, and sometimes `NaN`, both of which make little
sense in most cases.

Now, 'infinity' *can* be a useful concept in some cases, but there is hardly any use case for `NaN`, except
of course for `Array( 16 ).join( 'wat' - 1 ) + ' Batman!'` to get, you know that one,

```
NaNNaNNaNNaNNaNNaNNaNNaNNaNNaNNaNNaNNaNNaNNaN Batman!
```

Worse, while `NaN` is short for '*not* a number', `typeof NaN` returns... `'number'`! **WAT!**

This is not the end to the weirdness: as mandated by the standard, **`NaN` does not equal itself**. Now try
and tack attributes unto a `NaN`, and it will silently fail to accept any named members. There's no
constructor for this singleton value, so you can not produce a copy of it. You cannot delete it from the
language; it is always there, a solitary value with an identity crisis. Throw it into an arithmetic
expression and it will taint all output, turning everything into `NaN`.

**The sheer existence of `NaN` in a language that knows how to throw and catch exceptions is an oxymoron, as
all expressions that currently return it should really throw an error instead.**

Having read several discussion threads about the merits and demerits of JS `NaN !== NaN`, i'm fully
convinced by now that what we have seen concerning Python's concept of numerical equality (which turned out
to be equivalence) applies to `NaN !== NaN` as well: it was stipulated because any of a large class of
arithmetic expressions could have caused a given occurrence of `NaN`, and claiming that those results are
'equal' would be tantamount to claiming that `'wat' - 1` equals `Infinity * 0`, which is obviously wrong
(although it must be said that `Infinity * 0 !== Infinity * 0` is not very intuitive, either). Still, `NaN
!== NaN` is a purpose-oriented stipulation for defining equivalence, not the result of a principled approach
to define strict equality in our sense.

**I conclude that according to the First and Second Axioms, `eq NaN, NaN` must hold**, on the grounds
that no program using `NaN` values from different sources can make a difference on the base of manipulating
these values or passing them as arguments to the same functions.

A collateral result of these considerations is that while JavaScript's `===` so-called strict equality
operator (which is really an object identity operator) functions quite well in most cases, it fails with
`NaN`. Specifically, it violates the

**Fundamental Axiom**: value identity implies value equality. When a given test `f` purports to test for
equality, but `f x, x` fails to yield `true` for any given `x`, then that test must be considered broken.

**Update**: i just came across
[`Object.is`](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Object/is),
which, according to MDN,

> determines whether two values are the same value. Two values are the same if one of the following holds:
>
> *  both undefined
> *  both null
> *  both true or both false
> *  both strings of the same length with the same characters
> *  both the same object
> *  both numbers and
>    *  both +0
>    *  both -0
>    *  both NaN
>    *  or both non-zero and both not NaN and both have the same value

**Evidently, the 'both NaN' and 'both +0' / 'both –0' clauses corroborates our findings in the present and
the previous sections**.

Incidentally, this also shows that regulation 7.1 of
[the CommonJS Unit Testing specs](http://wiki.commonjs.org/wiki/Unit_Testing/1.0) is ever so slightly off
the mark when they say:

> All identical values are equivalent, as determined by ===.

(OBS that their use of 'equivalent' doesn't match my definition; the point is that the JS community has
already taken steps to provide for a more precise value identity metric than `===` can deliver).

Aside: **don't use the global function `isNaN` in your code unless you know what you're doing, as
[`isNaN` is broken](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/isNaN#Description).
Instead, do (JS) `x !== x` (`x != x`in CS).

### Object Property Ordering

Many people in the JS programming community are aware of the issues around ordering of object properties
ever since Chrome (and, because of that, NodeJS) broke customary behavior with regard to the ordering
of object properties. To wit, in NodeJS 0.10.28:

```coffeescript
obj = {}
obj[ 4 ] = 'first'
obj[ 2 ] = 'second'
obj[ 1 ] = 'third'

for name, value of obj
  log name, value
```

gives `1 third`, `2 second`, `4 first`, which reflects **the keys re-ordered by their numerical values, not
their order of insertion**. Confusingly, this behavior lingers on when we use `'4'`, `'2'`, `'1'` as
keys, and magically vanishes as soon as we use keys that can not be interpreted as (32-bit) integers.

Now, on the one hand it is evident that the ECMA specs do state that objects are unordered collections
of keys and values, but on the other hand, the agreement among browsers has—from the beginning, it would
seem—been that **objects should preserve the order of inserted properties**. As a commenter
[in a relevant thread on esdicuss.org](http://esdiscuss.org/topic/iteration-order-for-object#content-4)
put it:

> [Object property ordering] behavior was perfectly consistent across all browsers until Chrome 6. I think
> it's more appropriate to say that Chrome is not interoperable with thousands of sites than to define
> interoperable behavior based on a minority browser's very very recent break from a de-facto standard that
> stood for 15 years.

The real problem here lies with the Chrome folks. It is not the only occasion that they completely and
stubbornly shut up when anyone is so impertinent as to criticize their specific readings of their Holy Book.
They surely deserve praise for the general exactness of their work and the swiftness of JavaScript running
inside of V8, but their insistence on even the most marginal of performance gains at the expense of
long-standing but non-standardized expected behavior are nothing short of asinine. Sure, the Specs do not
mandate that any ordering of properties be kept, but does that mean it's a good idea to not keep ordering
when most people expect it, most JS engines keep it, and it can convincingly shown to be a very useful
behavior? But this is idle talk as the Chrome folks will only swear by the millisecond gained in some
synthetic test case. (They are likewise quite indifferent towards the merits of a stable sort and in all
earnesty expect the general public to accept an algorithm that shows one behavior for short and another
behavior for long lists, the threshold being set at an arbitrary limit of ten elements.)

It may then be asked whether our version of strict equality **(A)** should or **(B)** should not treat two
objects as equal when their only difference lies in the ordering of properties. First off, there would
appear to be little support from the tested libraries for (B) (i.e. most libraries discard ordering
information). Next, the Specs do not mandate any ordering behavior, so maybe equality tests shouldn't
require it, either. Then again, there is [a strawman proposal](http://wiki.ecmascript.org/doku.php?id=strawman:enumeration)
so there's a chance a future version of the language will indeed mandate preservation of object key insertion.
Moreover, our Second Axiom makes it quite clear that, since otherwise identical
programs can deliver different outputs for different order of key insertion, and people have come to rely on
consistent ordering for many years, there is something to be said in in favor of solution (B).

I guess that a good pragmatic solution is to go with crowd and use object property ordering
where supported, but not make that factor count in equality tests: **two objects that only differ
in the order of key insertion shall be regarded equal**. Where object key ordering is an important factor,
it can and should be tested separately.

### Properties on 'Non-Objects'

should be tested, also on functions and arrays

should we consider property descriptors? guess that's an opt-in

### Primitive Values vs Objects

The difference that exists in many object-oriented languages between primitive values (i.e. values without
properties) and objects (i.e. values that are composed of properties) is puzzling to many people. To make it
clear from the outstart: i believe that wherever and whenever a distinction has been or should have been
made in a program between, say, `5` plain and simple, and `new Number 5`, then that language is at fault for
not shielding the programmer from such an abomination.

I do get the feeling that the smart people who came up with JavaScript thought along the same lines, and
that the fact that you *can* sometimes make a difference between `5` and `new Number 5` is actually an
oversight where the intention was that programmers should never have to worry about that detail. Thus, in
JavaScript, when you access a property of a primitive value, that primitive is (at least conceptually)
temporarily cast as an object, and suddenly you can access properties on a primitive.

As for our inquiry, we have to ask: should `eq 5, new Number 5` hold or not? In the light of the foregoing
discussion, we can give a quick answer: **a primitive value and an equivocal object instance must be
regarded as different.** It follows from our Second Axiom in conjunction with the fact that trying to attach
a property to a primitive or an object will show a different outcome depending on the receiver.

> One could also assert that the need for `ne 5, new Number 5` follow from the First Axiom, as `5` and
> `new Number 5` are not of the same type. However, it is not quite as clear. After all, checking types
> can be done in two ways: one way is to submit a given value to a series of tests—how does it behave when
> passed to `Math.sin()`, what is the result of doing `x + ''`, and so on; the other way is to employ
> JavaScript language constructs like the `typeof` statement (there's a number of these devices, and
> usually a judiciously selected combination of several is needed to arrive at a sane result). Now let
> us imagine that all `typeof`-like devices were not implemented in a language **K** that compiles to
> JavaScript. Let it further be a known fact that no language construct of **K** results in an accidental
> use of a `typeof`-like device in the targetted JavaScript; still, we realize, on perusing the generated
> JS target code resulting from an input written in **K**, that in some cases, `5` appears in the target
> code, and `new Number 5` in others. The question is then: can we make it so that a program written in
> **K** behaves differently for two values `x`, `y`, where one compiles to a primitive, the other to an
> object? The answer will be 'yes' in case our probing method (as demonstrated below) can somehow be
> expressed within **K**. Thus, even in some more restricted dialects of JS, the equivalent of `ne 5, new Number 5`
> should hold; otherwise, our equality testing would be flawed.
>
> The reason i'm going to these lengths here lies in the observation that JavaScript's type system is
> rather deeply broken. It is for this reason that i've written the
> [CoffeeNode Types](https://github.com/loveencounterflow/coffeenode-types)
> package quite a while ago, and the present discussion is reason enough for me to work on a 2.0.0 release
> for that module which will introduce some breaking changes. Long story short: in the absence of a
> clear-cut typing system, using the First Axiom to decide on equality can only be done when type
> difference is more than obvious: a number is not a text, a boolean is not 'null', period. But whether
> or not both a primitive number and an objectified number are of the same type is a much harder question.

In JavaScript, there are the primitive types `undefined`, `null`, `boolean`, `string` and `number`;
`undefined` and `null` are singletons and do not have a constructor, there's only `Boolean`, `Number`
and `String`. When you try to attach a property to a primitive value, JavaScript will either complain
loudly (in the case of `undefined` and `null`), or fail silently (in the case of booleans, numbers and
strings). So one might say that there are really 'primeval primitives' and 'advanced(?) primitives' (rather
than just primitives) in JavaScript.

**It gets even a little worse.** Consider this:

```coffeescript
test = ( value, object ) ->
  value.foo   = 42
  object.foo  = 42
  #         ==                 ===                p                o
  return [ `value == object`, `value === object`, value.foo is 42, object.foo is 42 ]

                                #   ==  === p   o

log test    5, new Number 5     #   O   X   X   O
log test  'x', new String 'x'   #   O   X   X   O
log test true, new Boolean true #   X   X   X   O
log test  /x/, new RegExp /x/   #   X   X   O   O
log test   [], new Array()      #   X   X   O   O
```

For readability, i've here rendered `true` as `O` and `false` as `X`. We can readily discern *three*
patterns of output values, the `OXXO` kind, the `XXXO` kind, and the `XXOO` kind. When i say 'kind', i mean
'types of types', and it is plausible that longer series of like tests will result in 'fingerprint patterns'
that will allow us to sort out not only types of types, but also the types themselves.

The sobering factoid that is provided by the above program is that there are at least *three* kinds of
primitives.

**Worse**: since `NaN` is a primitive, too, but singularly fails to satisfy JS `x === x`, there are at least
*four* kinds.

**Worster still**: `undefined` can be re-defined in plain JS, something you can't do with `NaN`, so there
are at least *five* kinds of primitive values in JavaScript.

I think i'll leave it at that.

### Undefined Properties

Undefined properties are quite a nuisance. One might want to think that an 'undefined' property is just a
property that doesn't exit, but in the wonderful world of JavaScript, where there is an `undefined` value
that is actually used as a stand-in return value for cases like `{}[ 'foo' ]` and `[][ 87 ]` (instead of
throwing an exception), that is not so clear. To wit:

```coffeescript
d = { x: undefined }

log Object.keys d                     # [ 'x' ]

d = [ 'a', 'b', 'c' ]
delete d[ 2 ]

log d.length, Object.keys d           # 3 [ '0', '1' ]

d[ 3 ] = undefined

log d.length, Object.keys d           # 4 [ '0', '1', '3' ]
```

What this experiment shows is that according whether you base your judgement on (CS) `d[ 'x' ] != undefined`
or on (CS) `( ( Object.keys d ).indexOf 'x' ) != 1`, `d` has or has not a key `x`. Sometimes the one test
makes sense, sometimes the other; generally, it's probably best to avoid properties whose value has been set
to `undefined`.

The experiment further shows that `delete` just 'pokes a hole' into a list (instead of making all subsequent
entries move forward one position, as done in Python), but doesn't adjust the `length` property, therefore
causing the same trouble as with other objects (the one thing that can be said in favor of this mode of
operation is that it allows to make sparse lists with arbitrarily large indices on elements).

It may be said without hesitation that `ne { x: undefined }, {}` should hold without further qualification,
and in fact, there is very broad agreement across implementations about this.

### Functions (and Regular Expressions)

In this section, i want to discuss the tricky question whether two functions `f`, `g` can or cannot be
considered equal. First off, it should be clear that whenever (JS) `f === g` holds, `f` and `g` are merely
two names for the same object, so they are trivially equal in our sense. The troubles start when `f` and `g`
are two distinct callables, and this has to do with a couple of topics whose discovery and treatmeant must
be counted among the great intellectual achievements of the 20th century. You know all of these names:
[Gödel's incompleteness theorems](http://en.wikipedia.org/wiki/G%C3%B6del%27s_incompleteness_theorems),
[Turing machines](http://en.wikipedia.org/wiki/Turing_machine),
[Halting problem](http://en.wikipedia.org/wiki/Halting_problem),
[Rice's theorem](http://en.wikipedia.org/wiki/Rice%27s_theorem).

I will not iterate any details here, but what the programmer should understand is that **there is no, and
cannot be for logical reasons, any *general* algorithm that is able to test whether two given programs will
behave equally for all inputs**.

The emphasis is on *general*, because, of course, there *are* cases where one *can* say with confidence that
two given functions behave equally. For example, when i have two `f`, `g` that are explicitly limited to a
certain finite set of inputs (say, positive integer numbers less than ten), i can repeatedly call both
functions with each legal input and compare the results. But even that is not strictly true, because it is
simple to define a function that will *sometimes* deliver a different result (say, based on a random number
generator, or the time of the day). Furthermore, the test will break down when the returned value should be
a function itself, as we are then back to square one then and possibly caught in an infinite regress.

By inspecting source code, there are some cases where a decision can be made more confidently. For example,
if we have

```javascript
var f = function( a, b, c ){ return a * b * c; };
var g = function( a, b, c ){ return a * b * c  };
```

then we can tell with certainty that f and g will return the same value, as the only difference is in the
use of the `;` (semicolon) which in JavaScript in this case does not cause any behavioral difference. The
same goes when i reorder the factors of the product as `c * a * b`.

The question is: how to decide whether two functions have only minor differences in their sources? and the
answer is: **we shouldn't even try**. The reason is simple: A JavaScript program has access to the source
code of (most) functions; as such, we can always inspect that code and cause behavioral differences:

```coffeescript
log f.toString().indexOf ';' # 38
log g.toString().indexOf ';' # -1
```

We have now reduced our field of candidates for equality to one remaining special case: how about two
functions for which `eq f.toString(), g.toString()` holds?

I want to suggest that **two functions may be considered equal when their source code (as returned by
their `x.toString()` methods) are equal. However, because of some limitations to this, that should be made
optional**.

This i believe should be done for pragmatic reasons as, sometimes, the objects you want to test will contain
functions, and it can be a nuisance to first having to remove them and then be left without *any* way to
test whether the objects have the expected shapes (i'm not the only one to think so; the generally quite
good [`equals` method by jkroso](https://github.com/jkroso/equals) does essentially the same).

However, there's a hitch here. As i said, JavaScript can access the source of *most* functions. It cannot
show the source of *all* functions, because built-ins are typically not written in JS, but compiled (from
C). All that you get to see when you ask for, say, `[].toString.toString()` will be (at least in NodeJS and
Firefox)

```javascript
function toString() { [native code] }
```

and since all objects have that method, it's easy to come up with a litmus test that shows our
considerations are not quite watertight. I use the aformentioned `equals` implementation here:

```coffeescript
eq  = require 'equals' # https://github.com/jkroso/equals
f   = ( [] ).toString
g   = ( 42 ).toString
h   = -> 'test method'
log 'does method distinguish functions?', eq ( eq f, g ), ( eq f, h )     # false  (1)
log 'are `f` and `g`equal?             ', eq f, g                         # true   (2)
log 'do they show the same behavior?   ', eq ( f.call 88 ), ( g.call 88 ) # false  (3)
```

On line (1), we demonstrate that the `eq` implementation chosen does indeed considers some functions to be
different (`eq f, h` returns `false`) and others as equal (`eq f, g` returns `true`, as the result from line
(2) shows). According to our reasoning, `f` and `g` then should show equivalent behaviors for equivalent
inputs (in case they are deterministic functions that base their behavior solely on their explicit
arguments, which they are). However, as evidenced by the output of line (3), they return *different* outputs
(namely `[object Number]` and `88`) when called with the same argument, `88` (which acts as `this` in this
case, but that is beside the point).

Actually, i feel a bit stoopid, because, as i'm writing this, another, less contrived, conceptually
simpler, more transparent and probably more relevant counter example comes to my mind, viz.:

```coffeescript
get_function = ( x ) ->
  return ( n ) -> n * x

f = get_function 2
g = get_function 3

log eq f, g                 # true
log eq ( f 18 ), ( g 18 )   # false
```

These functions are the *same* in the sense that they always execute the same code; they are different in
the way that they see different values in their respective closures. I doubt it will make sense to go much
further than this; to me, the adduced evidence leaves me at 50/50 whether function equivalence makes sense
or not, which is why i think this feature should be made an opt-in.


### How Many Methods for Equality Testing?

It is a recurrent feature of many assertion libraries that they provide one method for doing shallow
equality testing and another for deep equality testing. A case in point is NodeJS' `assert` module with no
less than *six* equality-testing methods: `equal`, `notEqual`, `deepEqual`, `notDeepEqual`, `strictEqual`,
`notStrictEqual`. Given this state of affairs, it is perhaps not so surprising that
[issue #7161: assert.deepEqual doing inadequate comparison](https://github.com/joyent/node/issues/7161)
prompted the suggestion to add `deepStrictEqual` (and, to keep the tune, `notDeepStrictEqual` as well)
to the API, which ups the tally to *eight*.

The reader will not have failed to notice that i make do, in the present discussion and the implementation
of the jsEq package, with a mere *two* API items, `eq` and `ne`, a fourth of what NodeJS offers. One gets
the impression the CommonJS folks who wrote
[the unit testing specs](http://wiki.commonjs.org/wiki/Unit_Testing/1.0)
must have started out, like, "wah equality, that's JS
`==`", and then at some point realized "cool, there's JS `===`, let's add it, too". A little later someone
may have pointed out that JS `[] === []` fails, and those folks went, like, "oh noes, we need `deepEqual`, let's
add it already". Of course, since they started out with the broken JS `==` operator, they recycled that
experience when implementing `deepEqual`, so now their `deepEqual` is as broken as their `equal`. But, hey,
at least its **consistently broken**, and what's more, we have a standard! Yay!

So now we have a widely-deployed assertion framework which seriously claims that `assert.deepEqual [[]], [{}]` and
`assert.deepEqual [ 3 ], [ '3' ]` should both hold and not throw exceptions like crazy. One wonders what
the intended use cases for such tests are; i can't think of any.

It looks like it never came to the minds of these folks that JS `==` is, overall, a pretty much useless
operator (`===` was added to JavaScript specifically to remedy the pitfalls of `==`; the only reason it did
not *replace* `==` was a perceived concern about backwards compatibility). Likewise, it escaped their attention
that APIs do not get better just by adding more and more methods to them.

I believe it can be made unequivocally clear that **separating deep and shallow equality has no place
in an orderly API, especially not in an assertion framework**.

The reasoning is simple: when i test for
equality, i want to test two (or more) values `x`, `y`. If i knew for sure that `x` and `y` are equal,
there wasn't a need to test them. Given that i'm unsure about the value of at least one of `x`, `y`, which
method—shallow equality for testing primitive values (Booleans, numbers, strings, ...) or deep equality
for testing 'objects' (lists, dates, ...)—should i take? In the absence of more precise knowledge of my
values, i cannot choose. So maybe i do some type checking (notoriously hard to get right in JS), or i
play some `try ... catch` games to find out. It is clear that if `shallow_equals [], 42`
should fail (or return `false`) because one of the arguments is not a primitive value, i have to try the other method,
`deep_equals [], 42`. Since the first failed, the second should fail in the same way, so now i
know that the two values are not equal according to my library, since i have run out of methods. It is then
easy enough to come up with a method `equals x, y` that does exactly that: try one way and, should that fail,
try the other way, catch all the errors and reduce the output to `true` and `false`.

There is no reason why the burden of implementing an all-embracing `equals` method should be put *on the
user*; rather, it is a failure on part of the library authors to export anything *but* an `equals` method
(and maybe a `not_equals` method, especially in the context of an assertion library), which is one more reason
**i consider NodeJS' `assert` broken: instead of two methods, it exports six (and maybe eight at some point in
the future)**. This is also revealed by the jsEq tests: for instance, `assert.deepEqual 1234, 1234`
and `assert.notDeepEqual 1234, 1235` as such work correctly, obviating any need for both `assert.equal` and
`assert.notEqual` if there ever was one. Their presence is an implementation detail that happened to get
exposed to the general public.




### Plus and Minus Points

* **+1** if method allows to configure whether `eq NaN, NaN` should hold.
* **+1** if method allows to configure whether object key ordering should be honored.
* **+1** if method allows to configure whether function equality should be tested.
* **+1** if method allows to test arbitrary number of arguments for pairwise equality.
* **–1** if a (non-assertive) method throws an error on any comparison.
* **–1** if a method for deep equality testing fails on primitive values.
* **–1** where a method `eq` fails on `eq x, x` for any given `x` (except for `NaN` which is a hairy case).
* **–1** where a library provides both an `eq` and a `ne` method but `eq ( not eq x, y ), ( ne x, y )` fails
  for any given `x` and `y`.
* **–1** where a pair `x`, `y` can be found that cause `eq ( eq x, y ), ( eq y, x )` to fail.
* **–1000** where anyone dares to pollute the global namespace.
* **–1000** where anyone dares to monkey-patch built-ins like `String.prototype` *except* for doing a
  well-documented, well-motivated (by existing future standards), well-tested polyfill.

### Benchmarks

A through comparison of equality-testing implementations whould also consider performance (and maybe memory
consumption). This task has been left for a future day to be written.

### Libraries Tested

* **`==`&nbsp;**: native JavaScript comparison with `==`
* **`===`**: native JavaScript comparison with `===`
* **`OIS`**: native JavaScript comparison `Object.is`
* **`LDS`**: https://github.com/lodash/lodash
* **`UDS`**: https://github.com/jashkenas/underscore
* **`JKR`**: https://github.com/jkroso/equals
* **`o23`**: https://github.com/othiym23/node-deeper
* **`CJS`**: https://github.com/chaijs/deep-eql
* **`DEQ`**: https://github.com/substack/node-deep-equal
* **`QUN`**: http://qunitjs.com
* **`SH1`**: https://github.com/shouldjs/should.js#equal
* **`SH2`**: https://github.com/shouldjs/should.js#eql
* **`*JV`**: http://stackoverflow.com/a/6713782/256361
* **`EQ`&nbsp;**: jsEq's improved version of lodash's `isEqual` (LDS)
* **`*EQ`**: customized version of EQ for testing configurability
* **`CND`**: https://github.com/loveencounterflow/coffeenode-bitsnpieces

### Caveats and Rants

**Caveats**

* Tests from libraries whose name has been marked with an `!` are considered broken; in particular:
* <strike>The QUnit tests (**QUN**) are currently broken and always fail; i seemingly cannot come to grips with
  the QUnit API.</strike> (see Rants, below)
* Libraries whose key starts with `*` are either 'hobbyists solutions' or are inlcuded for comparison
  and testing other features (such as configurability).
* I suspect the **SH1** and **SH2** tests to be broken, too, due to their outstanding failure counts.

**Rants (1)**

Some sunny morning i ran into a strange bug that flooded my screen and braught testing to a gritty halt. I
had just done some tricky circular object testing and so, naturally, thought it must be my fault, the output
being indicative of some massive object-pileup as is prone to happen with faulty recursions.

Investigation of the output first pointed to the package i use to print result tables and seemed to be due
to some diagnostic printout of mine. i removed that printout only to realize that even with that, a very
basic test case (`eq { a:'b', c:'d' }, { a:'b', c:'d' }`) was the cause—not a recursion, to wit, but still
an endless loop of some sort (or so i thought).

I suspected a global namespace pollution of sorts, inserted a few sentinels, and, sure enough, quickly found
the culprit (or so i thought): it was that dreaded QUnit thingie which i had not managed to adapt for
testing, which was at that point nowhere called within jsEq, only `required` in the `implementations`
module. Turns out **QUnit injects no less than 28 words (!) into the global namespace**:

```
asyncTest begin deepEqual done equal equals expect log module moduleDone moduleStart
notDeepEqual notEqual notPropEqual notStrictEqual ok onerror propEqual QUnit raises
same start stop strictEqual test testDone testStart throws
```

We all know that putting names in the global namespace is a no-no, even if there's sometimes (e.g. in the
browser) hardly any way around it. Anyone who has been using the (great and justifiedly famous) jQuery
framework knows that its authors go to great lengths to avoid conflicts with the one name they do export
(`$`, or, should you choose so, only `jQuery`). To my amazement, the QUnit docs proudly state that

> QUnit was originally developed by John Resig as part of jQuery. [...] QUnit's assertion methods follow the
> CommonJS Unit Testing specification, which was to some degree influenced by QUnit.

I can't believe this—J.R. should be both responsible for both this flagrant violation of basic rules *and*
that bunch of half-baked misconceptions that are the CommonJS Unit Testing specs?—The docs also mention
a complete re-write of QUnit, so maybe it wasn't him. Anyways, i hardly need testing another `equals`
implementation that adheres to CommonJS. Time to move on.

**Rants (2)**

I had hoped that at this point, i could go back to testing my tests, so, having all references to QUnit
removed, i gave it another try only to... discover the problem had persisted! Back to the drawing table.
With more sentinels in the code, i was able to nail down a second piece of problematic software. My first
hunch had actually been correct: **the `colors` package that `cli-table` relies on extends the prototype
of `String` with its own names**, and since those are not made non-enumerable, they surely enough only wait
to spill into the output (especially in a testing situation where sometimes prototypes are being picked
apart, too). This means i'll have to look for another solution to printing out tabular data on the console.














