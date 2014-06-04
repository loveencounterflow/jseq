

- [jsEq](#jseq)
	- [Test Module Setup](#test-module-setup)
	- [Equality, Identity, and Equivalence](#equality-identity-and-equivalence)
	- [First Axiom: Value Equality Entails Type Equality](#first-axiom-value-equality-entails-type-equality)
	- [Equality of Sub-Types](#equality-of-sub-types)
	- [Equality of Numerical Values in Python](#equality-of-numerical-values-in-python)
	- [Second Axiom: Equality of Program Behavior](#second-axiom-equality-of-program-behavior)
	- [Infinity, Positive and Negative Zero](#infinity-positive-and-negative-zero)
	- [Not-A-Number](#not-a-number)
	- [POD key ordering](#pod-key-ordering)
	- [Bonus And Malus Points](#bonus-and-malus-points)
	- [Benchmarks](#benchmarks)
	- [Motivation](#motivation)

> **Table of Contents**  *generated with [DocToc](http://doctoc.herokuapp.com/)*


# jsEq

There are a couple of related, recurrent and, well, relatively 'deep' problems that vex many people who
program in JavaScript on a daily base, and those are sane **(deep) equality testing**, sane **deep
copying**, and sane **type checking**.

jsEq attempts to answer the first of these questions—how to do sane testing for deep equality in JavaScript
(specifically in NodeJS)—by providing an easy to use test bed that compares a number of libraries that
purport to deliver solutions for deep equality. It turns out that there are surprising differences in detail
between the libraries tested, as the screen shot below readily shows (don't take the `qunitjs` test
seriously, those are currently broken due to the (to me at least) strange API of that library).
Here is a sample output of jsEq running `node jseq/lib/main.js`:

![Output of `node jseq/lib/main.js`](https://github.com/loveencounterflow/jseq/raw/master/._art/Screen%20Shot%202014-06-04%20at%2000.31.24.png)

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

## Test Module Setup

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


## Equality, Identity, and Equivalence

equality and identity are extensional, formal qualities; equivalence is an intentional, informal
quality

It can be said that JavaScript's `==` 'non-strict equals operator' never tested *value equality* at all,
rather, it tested *value equivalence*. Now we have seen that equivalence is a highly subjective concept that
is suceptible to the conditions of specific use cases. As such, it is a bad idea to implement it in the
language proper. The concept that `3 == '3'` (number three is equivalent to a string with the ASCII digit
three, U+0033) does hold in some common contexts (like `console.log(3)`) and breaks down in some other, also
very common contexts (like `x.length`, which is undefined for numbers).

Further, it can be said that JavaScript's `===` 'strict equals operator' never tested *value equality* at
all, but rather *object identity*, with the understanding that all the primitive types have one single
identity per value (something that e.g. seems to hold in Python for all integers, but not necessarily
all strings).

## First Axiom: Value Equality Entails Type Equality

An important axiom in computing is that

**Axiom 1** Two values `x` and `y` can only ever be equal when they both have the same type; conversely,
when two values are equal, they must be of equal type, too.

More formally, let **L** denote the language under inspection, and be **M** the meta-language to discuss and
/ or to implement **L**. Then, saying that `eq x, y` results in `true` implies that
`eq ( type-of x ), ( type-of y )` is also `true`.

We can capture that by saying that in **M**, all values `x` of **L** are represented by tuples ⟨*t*, *v*⟩
where *t* is the type of `x` and *v* is its value—'without' its type, which may sound strange but is
possible, since all unique values that may occur within a real-world program at any given point in time are
enumerable and, hence, reducible to ⟨*t*, *n*⟩, where *n* is a natural number. Since all *n* are of the same
type, they can be said to be typeless.

When we are comparing two values for equality in **L**, then, we are really comparing the two elements of
two tuples ⟨*t<sub>1</sub>*, *v<sub>1</sub>*⟩, ⟨*t<sub>2</sub>*, *v<sub>2</sub>*⟩ that represent the values
in **M**, and since we have reduced all values to integers, and since types are values, too, we have reduced
the problem to doing the equivalent of `eq [ 123, 5432, ], [ 887, 81673, ]` which has an obvious solution:
the result can only be `true` if the two elements of each tuple are pairwise identical.

> The above is not so abstruse as it may sound; in Python, `id( value )` will give you an integer that
> basically returns a number that represents a memory location, and in JavaScript, types are commonly
> represented as texts. Therefore, finding the ID of a type entails searching through memory whether
> a given string is already on record and where, and if not, to create such a record and return its memory
> address. Further, i would assume that most of the time, maybe always when you do `'foo' === 'foo'` in
> JavaScript, what you really do is comparing *IDs*, not strings of characters.

I hope this short discussion will have eliminated almost any remaining doubt whether two values of different
types can ever be equal. However, there are two questions i assume the astute reader will be inclined
to ask. These are: what about sub-typed values? and what about numbers?


## Equality of Sub-Types

As for the first question, i think we can safely give it short shrift. A type is a type, irregardless of how
it is derived. That an instance of a given type shares methods or data fields with some other type doesn't
change the fact that somewhere it must have—explicitly or implicitly, accessible from **L** or only from
**M**—a data field where its type is noted, and if the contents of that field do not equal the equivalent
field of the other instance, they cannot be equal if our above considerations make any sense. True, some
instances of some sub-types may stand in for some instances of their super-type in some setups, but that is
the same as saying that a nail can often do the work of a screw—in other words, this consideration is about
*fitness for a purpose* a.k.a. *equivalence*, not about equality as understood here. Also, that a nail can
often do the work of a screw does crucially not hinge on a screw being conceptualized as 'a nail with a
screw thread' or a nail reified as 'a screw with a zero-depth thread'.


## Equality of Numerical Values in Python

As for the second question, it is in theory somewhat harder than the first, but fortunately, there is an
easy solution.

JavaScript may be said to be simpler than many other languages, since it has only a single numerical
type, which implements the well-known IEEE 754 floating point standard with all its peculiarities.

Many languages do have more than a single numerical type: For instance, Java has no less than six—`byte`,
`short`, `int`, `long`, `float`, `double`, which users do have to deal consciously with.

Python before version 3 had four types: `int`, `float`, `long`, `complex`; in version 3, the `int` and
`long` types have been unified. Moreover, Python users have to worry much less about numerical types than
Java users, as Python tries very hard—and manages very well—to hide that fact; for most cases, numerical
types are more of a largely hidden implementation detail than a language feature. This even extends to
numerical types that are provided by the Standard Library, like the arbitrary-precision `Decimal` class.

In my experience, Python has the best thought-out numerical system of any programming language i had ever
contact with, so my rule of thumb is that whatever Python does in the field of numbers is worthy of
emulation.

It turns out that in Python, numbers of different types do compare equal when the signs and magnitudes of
their real and complex parts are equal; therefore, `1 == 1.0 == 1 + 0j == Decimal( 1 )`. This would be in
conflict with our theory, so either Python gets it wrong or the theory is incorrect.

One way to resolve the conflict is to say that the *t* in the tuples ⟨*t*, *v*⟩ of **M** do simply record an
abstract type `number` instead of any subclass of numbers, this being an exception that is made for
practical reasons. Another solution would be to state that our theory is only applicable to languages which
have only a single numerical type, so it may be valid for JavaScript, but certainly not Java or Python.

A third way, and i believe the right one, is to assert that **what Python does with its `1 == 1.0 == 1 + 0j ==
Decimal( 1 )` comparison is really *not* doing equality, but equivalence testing for the well-known,
well-documented, exceptional case of comparing numerical values for arithmetic purposes**. And, in fact,
it so turns out that in Python you can overload the behavior of the `==` operator by defining a specical
method `__eq__` on a class, and if you so want it, you can make Python say yes to `x == y` even though
`x.foo == y.foo` does *not* hold! It is in fact very simple:

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
methods, from an abstract point of view. It is not immediately clear what use could be made of an object
that satisfies `x != x`, but the fact that Python has no qualms in allowing the programmer such utterly
subversive code corroborates that what we deal with here is open-minded equivalence rather than principled
equality.

Since there is, anyways, only a single numerical type in JavaScript, i believe we should stick with the
unadultered version of Axiom 1 that forbids cross-type equality even for numerical types.

## Second Axiom: Equality of Program Behavior

The above treatment of numerical types has shown that Python prefers to consider `1 == 1.0` true because for
most practical, arithmetic use cases, there will be no difference (in modern Pythons; older Pythons had `1 /
7 != 1.0 / 7.0`) between results whatever numerical type you used. But that, of course, is not *quite*
right; the whole reason for using `Decimal` instead of `Float` is to make it so that arithmetic operations
*do* turn out differently—say, with a hundred decimals printed out, or with precise monetary amounts (you
never calculate prices using floating-point numbers in JavaScript, right?).

Now, the reason for programmers to write test suites is to ensure that a program behaves the expected way,
and that it continues to return the expected values even when some part of it gets modified. It is clear
that using some `BigNum` class in place of ordinary numbers *will* likely make the program change behavior,
for the better or the worse, and in case you're writing an online shopping software, you *want* to catch all
those changes, which is tantamount to say you do *not* want *any* kind of `eq ( new X 0 ), 0` tests to
return `true`, even if `0.00` is your naive old and `new X 0.00` is your fool-proof new way of saying
'zero dollars'.

Thus our second axiom becomes:

**Axiom 2** Even two values `x`, `y` of the same type that can be regarded as equal for most use cases, they
must not pass the test `eq x, y` in case in can be shown that there is at least one program that has different
outputs when run with `y` instead of with `y`.

The second axiom helps us to see very clearly that Python's concept of equality isn't ours, for there is a
very simple program `def f ( x ): print( type( x ) )` that will behave differently for each of `1`, `1.0`,
`1 + 0j`, `Decimal( 1 )`. As for JavaScript, the next section will discuss a relevant case.

## Infinity, Positive and Negative Zero

One of the (*many*) surprises / gotchas / peculiarities that JavaScript has in store for the n00be
programmer is the existence of *two zeroes*, one positive and one negative. What, i hear you say, and no
sooner said than done have you typed `+0 === -0`, return, into the NodeJS REPL, to be rewarded with a
satisfyingly reassuring `true`. That should do it, right?—for haven't we all learned that when a `x === y`
test returns `true` it 'is True', and only when that fails do we have to do more checking? Sadly, this
belief is mistaken, as the below code demonstrates:

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
see that it insisted on claiming `+0` and `-0` should differ. Ultimately, this led me to the discovery of
the second Axiom, and with that in my hands, it became clear that `underscore` got this one right and my
test case got it wrong: **Since there are known programs that behave differently with positive and negative
zero, these two values must not be considered equal**.


## Not-A-Number

Yet another one of that rich collection of JavaScript easter eggs (and, like `+0` vs `-0`, one that is
mandated by IEEE 754), is the existence of a `NaN` (read: Not A Number) value. In my opinion, this value
shouldn't exist at all. JS does consistently the right thing when it throws an exception on `undefined.x`
(unable to access property of `undefined`) and on `d.f = 42; d.f 'helo'` (not a function), and, as
consistently fails silently when you access undefined object properties and do numerical nonsense. In
the latter case, it resorts to returning sometimes `Infinity`, and sometimes `NaN`, both of which make
little sense in most cases.

Now, 'infinity' can be a useful concept for some use cases, but there is hardly any use case for `NaN`,
except of course for `Array( 16 ).join( 'wat' - 1 ) + ' Batman!'` to get, you know that one,

```
NaNNaNNaNNaNNaNNaNNaNNaNNaNNaNNaNNaNNaNNaNNaN Batman!
```

Worse, while `NaN` is short for *not* a number, `typeof NaN` returns... `'number'`! WAT!! And this is not
the end to the weirdness: as mandated by the standard, **`NaN` does not equal itself**. Now try and tack
attributes unto a `NaN`, and will silently fail to accept any named members. There's no constructor for this
singleton value, so you can not produce a copy of it. You cannot delete it from the language; it is always
there, a solitary value with an identity crisis. Throw it into an arithmetic expression and it will taint
all output. The sheer existence of `NaN` in a language that knows how to throw and catch exceptions is an
oxymoron, as all expressions that currently return it should relly throw an error instead.

Having read a discussion on StackOverflow about the merits and demerits of `NaN != NaN`, i'm fully convinced
that whatever i have said about Python's concept of numerical equality (which turned out to be equivalence)
applies to `NaN != NaN` as well: it was stipulated because any of a large class of arithmetic expressions
could have caused a given occurrence of `NaN`, and claiming that those results are 'equal' would be
tantamount to claiming that `'wat' - 1` equals `Infinity * 0`, which is obviously wrong. Still, this is
a pragmatic and purpose-oriented solution for defining equivalence, not a principled one to define strict
equality.

**I conclude that according to the First and Second Axioms, `eq NaN, NaN` must hold**, on the grounds
that no program using `NaN` values from different sources can make a difference on the base of manipulating
these values or passing them as arguments to the same functions.


## POD key ordering




## Bonus And Malus Points

* **+1** if method allows to configure whether `eq NaN, NaN` should hold.
* **+1** if method allows to configure whether object key ordering should be honored.
* **+1** if method allows to test arbitrary number of arguments for pairwise equality.
* **–1** if (non-assertive) method throws an error on any comparison

## Benchmarks

To be done.

## Motivation

https://github.com/joyent/node/issues/7161