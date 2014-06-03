

- [jsEq](#jseq)
	- [Test Module Setup](#test-module-setup)
		- [Concept of Type](#concept-of-type)

> **Table of Contents**  *generated with [DocToc](http://doctoc.herokuapp.com/)*


# jsEq

A test suite for testing shallow & deep, strict equality as provided by various libraries

![Output of `node jseq/lib/main.js`](https://github.com/loveencounterflow/jseq/raw/master/._art/Screen%20Shot%202014-06-03%20at%2016.48.01.png)

## Test Module Setup

Test cases are set up inside a function that accepts two functions `eq`, `ne` and returns an object with
each function (whose name does not start with an `_` underscore) being a test case. Each test case will run
either a single or multiple tests. Tests that run a single test simply return the result of applying the
provided `eq` or `ne` to test for the current implementation's concept of equality with `eq` or inequality
with `ne` aginst a pair of values. Tests that run multiple subtests should return a pair `[ n, errors, ]`
where `n` is the subtest count and `errors` is a list with a meaningful message for each failed subtest.

```coffeescript
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

  #---------------------------------------------------------------------------------------------------------
  ### 2. complex tests ###
  R[ "circular arrays with same layout and same values are equal" ] = ->
    d = [ 1, 2, 3, ]
    d.push d
    e = [ 1, 2, 3, ]
    e.push d
    eq d, e

  #---------------------------------------------------------------------------------------------------------
  ### joshwilsdon's test (https://github.com/joyent/node/issues/7161) ###
  R[ "all values in joshwilsdon's list shouldnt equal any other" ] = ->
    d1 = [ NaN, undefined, null, true, false, Infinity, 0, 1, "a", "b", {a: 1}, {a: "a"},
      [{a: 1}], [{a: true}], {a: 1, b: 2}, [1, 2], [1, 2, 3], {a: "1"}, {a: "1", b: "2"} ]
    d2 = [ NaN, undefined, null, true, false, Infinity, 0, 1, "a", "b", {a: 1}, {a: "a"},
      [{a: 1}], [{a: true}], {a: 1, b: 2}, [1, 2], [1, 2, 3], {a: "1"}, {a: "1", b: "2"} ]
    errors = []
    for v1, idx1 in d1
      for v2, idx2 in d2[ idx1 ... d2.length ]
        if idx1 == idx2
          errors.push "eq #{rpr d1}, #{rpr d2} failed" unless eq v1, v2
        else
          errors.push "eq #{rpr d1}, #{rpr d2} failed" unless ne v1, v2
    #.......................................................................................................
    return [ d1.length, errors, ]
```


equality, identity, and equivalence

equality and identity are extensional, formal qualities; equivalence is an intentional, informal
quality

### Concept of Type


`⟨type, value⟩`

NaN

POD key ordering



