

- [jsEq](#jseq)
	- [Test Module Setup](#test-module-setup)
		- [Concept of Type](#concept-of-type)
	- [Bonus And Malus Points](#bonus-and-malus-points)
	- [Benchmarks](#benchmarks)
	- [Motivation](#motivation)

> **Table of Contents**  *generated with [DocToc](http://doctoc.herokuapp.com/)*


# jsEq

There are a couple of related, recurrent and, well, relatively 'deep' problems that vex many people who
program in JavaScript on a daily base, and those are sane (deep) equality testing, sane deep copying, and
sane type checking.

jsEq attempts to answer the first of these questions—how to do sane testing for deep
equality in JavaScript (specifically in NodeJS)—by providing an easy to use test bed that compares a number
of libraries that purport to deliver solutions for deep equality.



Here is a sample output of jsEq running `node jseq/lib/main.js`:

![Output of `node jseq/lib/main.js`](https://github.com/loveencounterflow/jseq/raw/master/._art/Screen%20Shot%202014-06-03%20at%2021.04.49.png)

## Test Module Setup

Test cases are set up inside a function that accepts two functions `eq`, `ne` and returns an object with
each function (whose name does not start with an `_` underscore) being a test case. Each test case will run
either a single or multiple tests. Tests that run a single test simply return the result of applying the
provided `eq` or `ne` to test for the current implementation's concept of equality with `eq` or inequality
with `ne` aginst a pair of values. Tests that run multiple subtests should return a pair `[ n, errors, ]`
where `n` is the subtest count and `errors` is a list with a meaningful message for each failed subtest.

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