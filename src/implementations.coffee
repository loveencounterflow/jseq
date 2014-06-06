


############################################################################################################
TRM                       = require 'coffeenode-trm'
rpr                       = TRM.rpr.bind TRM
badge                     = 'jsEq/implementations'
log                       = TRM.get_logger 'plain',     badge
info                      = TRM.get_logger 'info',      badge
whisper                   = TRM.get_logger 'whisper',   badge
alert                     = TRM.get_logger 'alert',     badge
debug                     = TRM.get_logger 'debug',     badge
warn                      = TRM.get_logger 'warn',      badge
help                      = TRM.get_logger 'help',      badge
urge                      = TRM.get_logger 'urge',      badge
praise                    = TRM.get_logger 'praise',    badge
echo                      = TRM.echo.bind TRM
#...........................................................................................................
### implementations of deep equality tests: ###
BNP                       = require 'coffeenode-bitsnpieces'
ASSERT                    = require 'assert'
LODASH                    = require 'lodash'
UNDERSCORE                = require 'underscore'
jkroso_equals             = require 'equals'
QUNITJS                   = require 'qunitjs'
othiym23_deepEqual        = require 'deeper'
should                    = require 'should'
substack_deep_equal       = require 'deep-equal'
jv_equals                 = require '../3rd-party/JV-jeanvincent.js'
cjs_deep_eql              = require 'deep-eql'
jseq                      = require './eq'

#-----------------------------------------------------------------------------------------------------------
custom_jseq_options =
  'signed-zeroes':        yes
  'functions':            no
  'NaN':                  no
  'properties':           no
  'primitive-and-object': no

#-----------------------------------------------------------------------------------------------------------
custom_jseq = jseq.new custom_jseq_options

#-----------------------------------------------------------------------------------------------------------
get_errorproof_comparator = ( test_method ) ->
  return ( a, b ) ->
    try
      R = test_method a, b
    catch error
      if error[ 'message' ] is 'Maximum call stack size exceeded'
        error[ 'code' ] = 'jsEq'
        throw error
      return false
    return R

#-----------------------------------------------------------------------------------------------------------
module.exports =
  #.........................................................................................................
  "==: native ==":
    #.......................................................................................................
    eq: ( a, b ) -> `a == b`
    ne: ( a, b ) -> `a != b`
  #.........................................................................................................
  "===: native ===":
    #.......................................................................................................
    eq: ( a, b ) -> `a === b`
    ne: ( a, b ) -> `a !== b`
  #.........................................................................................................
  "OIS: native Object.is":
    #.......................................................................................................
    eq: ( a, b ) -> Object.is a, b
    ne: ( a, b ) -> Object.is a, b
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
  # #.........................................................................................................
  # "NEQ: NodeJS assert.equal":
  #   #.......................................................................................................
  #   eq: ( a, b ) ->
  #     try
  #       ASSERT.equal a, b
  #     catch error
  #       return false
  #     return true
  #   #.......................................................................................................
  #   ne: ( a, b ) ->
  #     try
  #       ASSERT.notEqual a, b
  #     catch error
  #       return false
  #     return true
  #.........................................................................................................
  "JKR: jkroso equals":
    #.......................................................................................................
    eq: ( a, b ) -> jkroso_equals a, b
    ne: ( a, b ) -> not jkroso_equals a, b
  #.........................................................................................................
  "CJS: https://github.com/chaijs/deep-eql":
    #.......................................................................................................
    eq: ( a, b ) -> cjs_deep_eql a, b
    ne: ( a, b ) -> not cjs_deep_eql a, b
  #.........................................................................................................
  "o23: https://github.com/othiym23/node-deeper":
    #.......................................................................................................
    eq: ( a, b ) -> othiym23_deepEqual a, b
    ne: ( a, b ) -> not othiym23_deepEqual a, b
  #.........................................................................................................
  "*JV: http://stackoverflow.com/a/6713782/256361":
    eq: get_errorproof_comparator jv_equals
    ne: get_errorproof_comparator ( a, b ) -> not jv_equals a, b
  #.........................................................................................................
  "DEQ: https://github.com/substack/node-deep-equal":
    eq: get_errorproof_comparator substack_deep_equal
    ne: get_errorproof_comparator ( a, b ) -> not substack_deep_equal a, b
  #.........................................................................................................
  "QUN: ! qunitjs":
    #.......................................................................................................
    eq: ( a, b ) -> return false
      # try
      #   QUNITJS.test 'message', ->
      #     R = QUNITJS.deepEqual a, b, 'message'
      # catch error
      #   whisper error[ 'message' ]
      #   return false
      # return R
    ne: ( a, b ) -> return false
      # try
      #   QUNITJS.test 'message', ->
      #     R = QUNITJS.notDeepEqual a, b, 'message'
      # catch error
      #   whisper error[ 'message' ]
      #   return false
      # return R
  #.........................................................................................................
  "SH1: https://github.com/shouldjs/should.js#equal":
    #.......................................................................................................
    eq: ( a, b ) ->
      try
        ( should a ).equal b
      catch error
        return false
      return true
    ne: ( a, b ) ->
      try
        not ( should a ).equal b
      catch error
        return false
      return true
  #.........................................................................................................
  "SH2: https://github.com/shouldjs/should.js#eql":
    #.......................................................................................................
    eq: ( a, b ) ->
      try
        ( should a ).eql b
      catch error
        return false
      return true
    ne: ( a, b ) ->
      try
        not ( should a ).eql b
      catch error
        return false
      return true
  #.........................................................................................................
  "CND: CoffeeNode Bits'N'Pieces":
    #.......................................................................................................
    eq: ( a, b ) -> BNP.equals a, b
    ne: ( a, b ) -> not BNP.equals a, b
  #.........................................................................................................
  "UDS: underscore _.isEqual":
    #.......................................................................................................
    eq: ( a, b ) -> UNDERSCORE.isEqual a, b
    ne: ( a, b ) -> not UNDERSCORE.isEqual a, b
  #.........................................................................................................
  "LDS: lodash _.isEqual":
    #.......................................................................................................
    eq: ( a, b ) -> LODASH.isEqual a, b
    ne: ( a, b ) -> not LODASH.isEqual a, b
  #.........................................................................................................
  "EQ: jsEq.eq":
    #.......................................................................................................
    eq: ( a, b ) -> jseq a, b
    ne: ( a, b ) -> not jseq a, b
  #.........................................................................................................
  "*EQ: custom version of jsEq.eq":
    #.......................................................................................................
    eq: ( a, b ) -> custom_jseq a, b
    ne: ( a, b ) -> not custom_jseq a, b



