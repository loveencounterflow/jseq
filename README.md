

- [jsEq](#jseq)

> **Table of Contents**  *generated with [DocToc](http://doctoc.herokuapp.com/)*


# jsEq

A test suite for testing shallow & deep, strict equality as provided by various libraries

```coffeescript
#----------------------------------------------------------------------------------------
# 1. positive tests

@[ "NaN equals NaN"                                           ] = -> eq NaN, NaN
@[ "finite integer n equals n"                                ] = -> eq 1234, 1234
@[ "emtpy array equals empty array"                           ] = -> eq [], []
@[ "emtpy object equals empty object"                         ] = -> eq {}, {}

#----------------------------------------------------------------------------------------
# 2. negative tests

@[ "object doesn't equal array"                               ] = -> ne {}, []
@[ "object in a list doesn't equal array in array"            ] = -> ne [{}], [[]]
@[ "integer n doesn't equal rpr n"                            ] = -> ne 1234, '1234'
@[ "empty array doesn't equal false"                          ] = -> ne [], false
@[ "array with an integer doesnt equal one with rpr n"        ] = -> ne [ 3 ], [ '3' ]

d = [ 1, 2, 3, ]
d.push d
e = [ 1, 2, 3, ]
e.push d
eq d, e


```

