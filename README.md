

- [jsEq](#jseq)

> **Table of Contents**  *generated with [DocToc](http://doctoc.herokuapp.com/)*


# jsEq

A test suite for testing shallow & deep, strict equality as provided by various libraries

```coffeescript

eq NaN, NaN
eq 1234, 1234

ne {}, []
ne [{}], [[]]
ne [ 3 ], [ '3' ]
ne 1234, '1234'

```

