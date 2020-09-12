


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
QUNIT                     = require 'qunit'
UNDERSCORE                = require 'underscore'
jkroso_equals             = require 'equals'
othiym23_deepEqual        = require 'deeper'
should                    = require 'should'
should_equal              = require 'should-equal'
substack_deep_equal       = require 'deep-equal'
jv_equals                 = require '../3rd-party/JV-jeanvincent.js'
cjs_deep_eql              = require 'deep-eql'
jseq                      = require './eq'
jdq_deepequal             = require 'deepequal'
assert_paranoid_equal     = require 'assert-paranoid-equal'
is_equal                  = require 'is-equal'
# angular                   = require 'angular'
# warn '©oganH'
deep_equal_ident          = require 'deep-equal-ident'


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
  "JKR: https://github.com/jkroso/equals":
    #.......................................................................................................
    eq: ( a, b ) -> jkroso_equals a, b
    ne: ( a, b ) -> not jkroso_equals a, b
  #.........................................................................................................
  "ADE: NodeJS assert.deepEqual":
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
  #.........................................................................................................
  "ASE: NodeJS assert.strictEqual":
    #.......................................................................................................
    eq: ( a, b ) ->
      try
        ASSERT.strictEqual a, b
      catch error
        return false
      return true
    #.......................................................................................................
    ne: ( a, b ) ->
      try
        ASSERT.notStrictEqual a, b
      catch error
        return false
      return true
  #.........................................................................................................
  "ADS: NodeJS assert.deepStrictEqual":
    #.......................................................................................................
    eq: ( a, b ) ->
      try
        ASSERT.deepStrictEqual a, b
      catch error
        return false
      return true
    #.......................................................................................................
    ne: ( a, b ) ->
      try
        ASSERT.notDeepStrictEqual a, b
      catch error
        return false
      return true
  #.........................................................................................................
  "AEQ: NodeJS assert.equal":
    #.......................................................................................................
    eq: ( a, b ) ->
      try
        ASSERT.equal a, b
      catch error
        return false
      return true
    #.......................................................................................................
    ne: ( a, b ) ->
      try
        ASSERT.notEqual a, b
      catch error
        return false
      return true
  #.........................................................................................................
  "CND: CoffeeNode Bits'N'Pieces":
    #.......................................................................................................
    eq: ( a, b ) -> BNP.equals a, b
    ne: ( a, b ) -> not BNP.equals a, b
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
  "CHA: https://github.com/chaijs/deep-eql":
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
  # #.........................................................................................................
  # "SH1: https://github.com/shouldjs/should.js#equal":
  #   #.......................................................................................................
  #   eq: ( a, b ) ->
  #     try
  #       ( should a ).equal b
  #     catch error
  #       return false
  #     return true
  #   ne: ( a, b ) ->
  #     try
  #       ( should a ).not.equal b
  #     catch error
  #       return false
  #     return true
  # #.........................................................................................................
  # "SH2: https://github.com/shouldjs/should.js#eql":
  #   #.......................................................................................................
  #   eq: ( a, b ) ->
  #     try
  #       ( should a ).eql b
  #     catch error
  #       return false
  #     return true
  #   ne: ( a, b ) ->
  #     try
  #       ( should a ).not.eql b
  #     catch error
  #       return false
  #     return true
  # #.........................................................................................................
  # "SH5: https://github.com/shouldjs/should.js#equal":
  #   #.......................................................................................................
  #   eq: ( a, b ) ->
  #     try
  #       ( should a ).equal b
  #     catch error
  #       return false
  #     return true
  #   ne: ( a, b ) ->
  #     try
  #       ( should a ).equal b
  #     catch error
  #       return true
  #     return false
  # #.........................................................................................................
  # "SH6: https://github.com/shouldjs/should.js#eql":
  #   #.......................................................................................................
  #   eq: ( a, b ) ->
  #     try
  #       ( should a ).eql b
  #     catch error
  #       return false
  #     return true
  #   ne: ( a, b ) ->
  #     try
  #       ( should a ).eql b
  #     catch error
  #       return true
  #     return false
  #.........................................................................................................
  "JDQ: https://github.com/JayceTDE/deepequal":
    #.......................................................................................................
    eq: get_errorproof_comparator jdq_deepequal
    ne: get_errorproof_comparator ( a, b ) -> not jdq_deepequal a, b
  #.........................................................................................................
  "APE: https://github.com/dervus/assert-paranoid-equal":
    #.......................................................................................................
    eq: ( a, b ) ->
      try
        assert_paranoid_equal.paranoidEqual a, b
      catch error
        return false
      return true
    #.......................................................................................................
    ne: ( a, b ) ->
      try
        assert_paranoid_equal.notParanoidEqual a, b
      catch error
        return false
      return true
  # #.........................................................................................................
  # "SEQ: https://github.com/shouldjs/equal":
  #   #.......................................................................................................
  #   eq: ( a, b ) -> should_equal a, b
  #   ne: ( a, b ) -> not should_equal a, b
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
  "QUN: QUnit assert.deepEqual":
    #.......................................................................................................
    eq: ( a, b ) -> QUNIT.equiv a, b
    ne: ( a, b ) -> not QUNIT.equiv a, b
  #.........................................................................................................
  "DQI: https://github.com/fkling/deep-equal-ident":
    #.......................................................................................................
    eq: get_errorproof_comparator deep_equal_ident
    ne: get_errorproof_comparator ( a, b ) -> not deep_equal_ident a, b
  #.........................................................................................................
  "ISE: https://github.com/ljharb/is-equal":
    #.......................................................................................................
    eq: get_errorproof_comparator is_equal
    ne: get_errorproof_comparator ( a, b ) -> not is_equal a, b
  # #.........................................................................................................
  # "ANG: https://github.com/bclinkinbeard/angular":
  #   #.......................................................................................................
  #   eq: get_errorproof_comparator angular.equals
  #   ne: get_errorproof_comparator ( a, b ) -> not angular.equals a, b
  #.........................................................................................................
  "EQ: jsEq.eq":
    #.......................................................................................................
    eq: get_errorproof_comparator jseq
    ne: get_errorproof_comparator ( a, b ) -> not jseq a, b
  #.........................................................................................................
  "*EQ: custom version of jsEq.eq":
    #.......................................................................................................
    eq: get_errorproof_comparator custom_jseq
    ne: get_errorproof_comparator ( a, b ) -> not custom_jseq a, b



