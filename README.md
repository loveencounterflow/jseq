

- [jsEq](#jseq)

> **Table of Contents**  *generated with [DocToc](http://doctoc.herokuapp.com/)*


# jsEq

A test suite for testing shallow & deep, strict equality as provided by various libraries

```coffeescript

### 1. simple tests ###

#----------------------------------------------------------------------------------------
### 1.1. positive ###

@[ "NaN equals NaN"                                           ] = -> eq NaN, NaN
@[ "finite integer n equals n"                                ] = -> eq 1234, 1234
@[ "emtpy array equals empty array"                           ] = -> eq [], []
@[ "emtpy object equals empty object"                         ] = -> eq {}, {}

#----------------------------------------------------------------------------------------
### 1.2. negative ###

@[ "object doesn't equal array"                               ] = -> ne {}, []
@[ "object in a list doesn't equal array in array"            ] = -> ne [{}], [[]]
@[ "integer n doesn't equal rpr n"                            ] = -> ne 1234, '1234'
@[ "empty array doesn't equal false"                          ] = -> ne [], false
@[ "array with an integer doesnt equal one with rpr n"        ] = -> ne [ 3 ], [ '3' ]

### 2. complex tests ###
@[ "circular arrays with same layout and same values are equal" ] = ->
  d = [ 1, 2, 3, ]
  d.push d
  e = [ 1, 2, 3, ]
  e.push d
  eq d, e

### joshwilsdon's test (https://github.com/joyent/node/issues/7161) ###
@[ "all values in joshwilsdon's list shouldnt equal any other" ] = ->
  d1 = [ NaN, undefined, null, true, false, Infinity, 0, 1, "a", "b", {a: 1}, {a: "a"},
    [{a: 1}], [{a: true}], {a: 1, b: 2}, [1, 2], [1, 2, 3], {a: "1"}, {a: "1", b: "2"} ]
  d2 = [ NaN, undefined, null, true, false, Infinity, 0, 1, "a", "b", {a: 1}, {a: "a"},
    [{a: 1}], [{a: true}], {a: 1, b: 2}, [1, 2], [1, 2, 3], {a: "1"}, {a: "1", b: "2"} ]
  errors = []
  for v1, idx1 in d1
    for v2, idx2 in d2
      if idx1 == idx2
        try
          eq v1, v2
        catch error
          ...
      else
        try
          ne v1, v2
        catch error
          ...

```

