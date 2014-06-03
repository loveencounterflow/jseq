

- [jsEq](#jseq)
	- [Test Module Setup](#test-module-setup)
		- [Comparing Numerical and Quasi-Numerical Values](#comparing-numerical-and-quasi-numerical-values)
		- [Concept of Type](#concept-of-type)
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

![Output of `node jseq/lib/main.js`](https://github.com/loveencounterflow/jseq/raw/master/._art/Screen%20Shot%202014-06-03%20at%2021.04.49.png)

The `lodash` and `underscore` results are probably identical because `lodash` strives to be a 'better
`underscore`'.

> Funny to see how they fail on `eq +0, -0`; i guess `underscore` made it a point to distinguish between the
> two since 'JS fails to'. No idea what that distinction could be useful for; see below for a discussion of
> comparing numerical and quasi-numerical values.

The `jkroso equals` and `CoffeeNode Bits'N'Pieces` results are identical since the former is really the
implementation of the latter; based on the results shown i'll try and combine different techniques /
libraries that manages to pass all tests.

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


equality, identity, and equivalence

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
identity per value (something that e.g. seems to hold in Python e.g. for all integers, but not necessarily
all strings).

### Comparing Numerical and Quasi-Numerical Values

According to the
[*ECMAScript® Language Specification*, section 11.6.3, “Applying the Additive Operators to Numbers”](http://www.ecma-international.org/ecma-262/5.1/#sec-11.6.3),
the existence of positive and negative (but no unsigned) zeroes causes logical problems (emphasis mine):

> The sum of two negative zeros is -0. The sum of **two positive zeros**, or of **two zeros of opposite sign**,
> is **+0.**

In other words, positive zero is preferred over negative zero when adding 'opposite' zeroes.

### Concept of Type


⟨*type*, *value*⟩

NaN

POD key ordering

## Bonus And Malus Points

* *+1*: if method allows to configure whether `eq NaN, NaN` should hold.
* *+1*: if method allows to configure whether object key ordering should be honored.
* *+1*: if method allows to test arbitrary number of arguments for pairwise equality.
* *—1*: if (non-assertive) method throws an error on any comparison

## Benchmarks

To be done.

## Motivation

https://github.com/joyent/node/issues/7161