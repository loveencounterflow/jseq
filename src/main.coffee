




############################################################################################################
TRM                       = require 'coffeenode-trm'
rpr                       = TRM.rpr.bind TRM
badge                     = 'jsEq'
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
@tests                    = require './tests'
BNP                       = require 'coffeenode-bitsnpieces'
### TAINT should use customized fork ###
TYPES                     = require 'coffeenode-types'
#...........................................................................................................
### implementations of deep equality tests: ###
assert                    = require 'assert'


#-----------------------------------------------------------------------------------------------------------
@implementations =
  #.........................................................................................................
  'NodeJS assert':
    #.......................................................................................................
    eq: ( a, b ) ->
      try
        assert.deepEqual a, b
      catch error
        return false
      return true
    #.......................................................................................................
    ne: ( a, b ) ->
      try
        assert.notDeepEqual a, b
      catch error
        return false
      return true

#-----------------------------------------------------------------------------------------------------------
@new_counter = ( name ) ->
  R =
    'name':     name
    'tests':    0
    'fails':    0
  return R

#-----------------------------------------------------------------------------------------------------------
@main = ->
  implementation_count  = 0
  test_count            = 0
  fail_count            = 0
  counters              = {}
  #.........................................................................................................
  for implementation_name, implementation of @implementations
    implementation_count += 1
    info implementation_name
    counter = counters[ implementation_name ] = @new_counter implementation_name
    #.......................................................................................................
    for test_name, test of @tests implementation.eq, implementation.ne
      continue if test_name[ 0 ] is '_'
      test_count         += 1
      counter[ 'tests' ] += 1
      title       = "#{implementation_name} / #{test_name}"
      result      = test.call @test
      #.....................................................................................................
      switch result_type = TYPES.type_of result
        #...................................................................................................
        when 'boolean'
          if result
            praise title
          else
            fail_count         += 1
            counter[ 'fails' ] += 1
            warn title
        #...................................................................................................
        when 'list'
          unless ( length = result.length ) is 2
            throw new Error "#{title}: expected list of length 2, got one with length #{length}"
          [ sub_count, sub_errors, ] = result
          unless ( count_type = TYPES.type_of sub_count ) is 'number'
            throw new Error "#{title}: expected a number, got a #{count_type}"
          unless sub_count > 0 and sub_count is Math.floor sub_count
            throw new Error "#{title}: expected an integer greater than zero, got #{sub_count}"
          unless ( errors_type = TYPES.type_of sub_errors ) is 'list'
            throw new Error "#{title}: expected a list, got a #{errors_type}"
          test_count += sub_count
          if sub_errors.length is 0
            praise title
          else
            for sub_error in sub_errors
              fail_count         += 1
              counter[ 'fails' ] += 1
              warn "#{title} / #{sub_error}"
        #...................................................................................................
        else
          throw new Error "#{title}: expected a boolean or a list, got a #{result_type}"
  #.........................................................................................................
  # whisper '-------------------------------------------------------------'
  # info    "Skipped #{skip_count} out of #{route_count} modules;"
  # info    "of the #{route_count - skip_count} modules inspected,"
  # urge    "#{miss_count} modules had no test cases."
  # info    "In the remaining #{route_count - miss_count - skip_count} modules,"
  # info    "#{test_count} tests were performed,"
  # praise  "of which #{pass_count} tests passed,"
  # warn    "and #{fail_count} tests failed."
  pass_count = test_count - fail_count
  whisper '-------------------------------------------------------------'
  info    "Tested #{implementation_count} implementations."
  info    "Overall, #{test_count} tests were run"
  praise  "of which #{pass_count} tests passed,"
  warn    "and #{fail_count} tests failed."
  whisper '-------------------------------------------------------------'
  whisper counters
  #.........................................................................................................
  return null


############################################################################################################
unless module.parent?
  @main()


