
############################################################################################################
TRM                       = require 'coffeenode-trm'
rpr                       = TRM.rpr.bind TRM
badge                     = 'jsEq/tests'
log                       = TRM.get_logger 'plain',     badge
info                      = TRM.get_logger 'info',      badge
whisper                   = TRM.get_logger 'whisper',   badge
alert                     = TRM.get_logger 'alert',     badge
debug                     = TRM.get_logger 'debug',     badge
warn                      = TRM.get_logger 'warn',      badge
help                      = TRM.get_logger 'help',      badge
echo                      = TRM.echo.bind TRM





#-----------------------------------------------------------------------------------------------------------
module.exports = ( eq, ne ) ->
  R = {}

  ### 1. simple tests ###

  #---------------------------------------------------------------------------------------------------------
  ### 1.1. positive ###

  R[ "NaN eqs NaN"                                        ] = -> eq NaN, NaN
  R[ "finite integer n eqs n"                             ] = -> eq 1234, 1234
  R[ "emtpy list eqs empty list"                          ] = -> eq [], []
  R[ "emtpy obj eqs empty obj"                            ] = -> eq {}, {}
  R[ "number eqs number of same value"                    ] = -> eq 123.45678, 123.45678
  R[ "regex lit's w same pattern, flags are eq"           ] = -> eq /^abc[a-zA-Z]/, /^abc[a-zA-Z]/
  R[ "pods w same properties are eq"                      ] = -> eq { a:'b', c:'d' }, { a:'b', c:'d' }
  R[ "pods that only differ wrt prop ord are eq"          ] = -> eq { a:'b', c:'d' }, { c:'d', a:'b' }

  #---------------------------------------------------------------------------------------------------------
  ### 1.2. negative ###

  R[ "obj doesn't eq list"                                ] = -> ne {}, []
  R[ "obj in a list doesn't eq list in list"              ] = -> ne [{}], [[]]
  R[ "integer n doesn't eq rpr n"                         ] = -> ne 1234, '1234'
  R[ "integer n doesn't eq n + 1"                         ] = -> ne 1234, 1235
  R[ "empty list doesn't eq false"                        ] = -> ne [], false
  R[ "list w an integer doesn't eq one w rpr n"           ] = -> ne [ 3 ], [ '3' ]
  R[ "regex lit's w diff. patterns, same flags aren't eq" ] = -> ne /^abc[a-zA-Z]/, /^abc[a-zA-Z]x/
  R[ "regex lit's w same patterns, diff. flags aren't eq" ] = -> ne /^abc[a-zA-Z]/, /^abc[a-zA-Z]/i
  R[ "+0 should ne -0"                                    ] = -> ne +0, -0
  R[ "number obj not eqs primitive number of same value"  ] = -> ne 5, new Number 5
  R[ "string obj not eqs primitive string of same value"  ] = -> ne 'helo', new String 'helo'
  R[ "(1) bool obj not eqs primitive bool of same value"  ] = -> ne false, new Boolean false
  R[ "(2) bool obj not eqs primitive bool of same value"  ] = -> ne true,  new Boolean true

  #=========================================================================================================
  ### 2. complex tests ###
  #---------------------------------------------------------------------------------------------------------
  R[ "obj w undef member not eqs other obj w/out same member" ] = ->
    d = { x: undefined }
    e = {}
    return ne d, e

  #---------------------------------------------------------------------------------------------------------
  R[ "fn1: functions w same source are eq" ] = ->
    d = `function( a, b, c ){ return a * b * c; }`
    e = `function( a, b, c ){ return a * b * c; }`
    return eq d, e

  #---------------------------------------------------------------------------------------------------------
  R[ "fn2: functions w diff source aren't eq" ] = ->
    d = `function( a, b, c ){ return a * b * c; }`
    e = `function( a, b, c ){ return a  *  b  *  c; }`
    return ne d, e

  #---------------------------------------------------------------------------------------------------------
  R[ "fn3: equal functions w equal props are eq" ] = ->
    d = -> null
    d.foo = some: 'meaningless', properties: 'here'
    e = -> null
    e.foo = some: 'meaningless', properties: 'here'
    return eq d, e

  #---------------------------------------------------------------------------------------------------------
  R[ "fn4: equal functions w unequal props aren't eq" ] = ->
    d = -> null
    d.foo = some: 'meaningless', properties: 'here'
    e = -> null
    e.foo = some: 'meaningless', properties: 'here!!!'
    return ne d, e

  #---------------------------------------------------------------------------------------------------------
  R[ "list w named member eqs other list w same member" ] = ->
    d = [ 'foo', null, 3, ]; d[ 'extra' ] = 42
    e = [ 'foo', null, 3, ]; e[ 'extra' ] = 42
    return eq d, e

  #---------------------------------------------------------------------------------------------------------
  R[ "list w named member doesn't eq list w same member, other value" ] = ->
    d = [ 'foo', null, 3, ]; d[ 'extra' ] = 42
    e = [ 'foo', null, 3, ]; e[ 'extra' ] = 108
    return ne d, e

  #---------------------------------------------------------------------------------------------------------
  R[ "date eqs other date pointing to same time" ] = ->
    d = new Date "1995-12-17T03:24:00"
    e = new Date "1995-12-17T03:24:00"
    return eq d, e

  #---------------------------------------------------------------------------------------------------------
  R[ "date does not eq other date pointing to other time" ] = ->
    d = new Date "1995-12-17T03:24:00"
    e = new Date "1995-12-17T03:24:01"
    return ne d, e

  #---------------------------------------------------------------------------------------------------------
  R[ "str obj w props eq same str, same props" ] = ->
    d = new String "helo test"; d[ 'abc' ] = 42
    e = new String "helo test"; e[ 'abc' ] = 42
    return ne d, e

  #---------------------------------------------------------------------------------------------------------
  R[ "str obj w props not eq same str, other props" ] = ->
    d = new String "helo test"; d[ 'abc' ] = 42
    e = new String "helo test"; e[ 'def' ] = 42
    return ne d, e

  #---------------------------------------------------------------------------------------------------------
  R[ "str obj w props eq same str, same props (circ)" ] = ->
    c = [ 'a list', ]; c.push c
    d = new String "helo test"; d[ 'abc' ] = c
    e = new String "helo test"; e[ 'abc' ] = c
    return ne d, e

  #---------------------------------------------------------------------------------------------------------
  R[ "str obj w props not eq same str, other props (circ)" ] = ->
    c = [ 'a list', ]; c.push c
    d = new String "helo test"; d[ 'abc' ] = c
    e = new String "helo test"; e[ 'def' ] = c
    return ne d, e

  #---------------------------------------------------------------------------------------------------------
  R[ "(1) circ arrays w same layout, same values are eq" ] = ->
    d = [ 1, 2, 3, ]; d.push d
    e = [ 1, 2, 3, ]; e.push d
    return eq d, e

  #---------------------------------------------------------------------------------------------------------
  R[ "(2) circ arrays w same layout, same values are eq" ] = ->
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
    count = 0
    for v1, idx1 in d1
      for idx2 in [ idx1 ... d2.length ]
        count += 1
        v2 = d2[ idx2 ]
        if idx1 == idx2
          unless eq v1, v2
            errors.push "eq #{rpr v1}, #{rpr v2}"
        else
          unless ne v1, v2
            errors.push "ne #{rpr v1}, #{rpr v2}"
    #.......................................................................................................
    # whisper count
    return [ count, errors, ]


  #---------------------------------------------------------------------------------------------------------
  return R


