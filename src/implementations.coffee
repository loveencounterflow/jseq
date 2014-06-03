


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


#-----------------------------------------------------------------------------------------------------------
module.exports =
  #.........................................................................................................
  "native ==":
    #.......................................................................................................
    eq: ( a, b ) -> `a == b`
    ne: ( a, b ) -> `a != b`
  #.........................................................................................................
  "native ===":
    #.......................................................................................................
    eq: ( a, b ) -> `a === b`
    ne: ( a, b ) -> `a !== b`
  #.........................................................................................................
  "NodeJS assert.deepEqual":
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
  "underscore _.isEqual":
    #.......................................................................................................
    eq: ( a, b ) -> UNDERSCORE.isEqual a, b
    ne: ( a, b ) -> not UNDERSCORE.isEqual a, b
  #.........................................................................................................
  "lodash _.isEqual":
    #.......................................................................................................
    eq: ( a, b ) -> UNDERSCORE.isEqual a, b
    ne: ( a, b ) -> not UNDERSCORE.isEqual a, b
  #.........................................................................................................
  "jkroso equals":
    #.......................................................................................................
    eq: ( a, b ) -> jkroso_equals a, b
    ne: ( a, b ) -> not jkroso_equals a, b
  #.........................................................................................................
  "https://github.com/othiym23/node-deeper":
    #.......................................................................................................
    eq: ( a, b ) -> othiym23_deepEqual a, b
    ne: ( a, b ) -> not othiym23_deepEqual a, b
  #.........................................................................................................
  "https://github.com/substack/node-deep-equal":
    #.......................................................................................................
    eq: ( a, b ) ->
      try
        R = substack_deep_equal a, b
      catch error
        whisper error
        return false
      return R
    ne: ( a, b ) ->
      try
        R = not substack_deep_equal a, b
      catch error
        whisper error
        return false
      return R
  #.........................................................................................................
  "! qunitjs":
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
  "https://github.com/shouldjs/should.js#equal":
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
  "https://github.com/shouldjs/should.js#eql":
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
  "CoffeeNode Bits'N'Pieces":
    #.......................................................................................................
    eq: ( a, b ) -> BNP.equals a, b
    ne: ( a, b ) -> not BNP.equals a, b
