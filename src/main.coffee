



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
@imps                     = require './implementations'
BNP                       = require 'coffeenode-bitsnpieces'
TEXT                      = require 'coffeenode-text'
### TAINT should use customized fork ###
TYPES                     = require 'coffeenode-types'
Table                     = require 'cli-table'


#-----------------------------------------------------------------------------------------------------------
@new_counter = ( key, name ) ->
  R =
    'key':      key
    'name':     name
    'tests':    0
    'fails':    0
  return R

#-----------------------------------------------------------------------------------------------------------
@main = ->
  imp_count  = 0
  test_count            = 0
  fail_count            = 0
  counters              = {}
  results_by_test_name  = {}
  #.........................................................................................................
  for imp_name, imp of @imps
    imp_count += 1
    info imp_name
    [ imp_key
      imp_name
      illegal...              ] = imp_name.split /:\s+/
    unless illegal.length is 0
      throw new Error "unsyntactic implementation name: #{rpr imp_name}"
    unless 0 < imp_key.length < 4
      throw new Error "unsyntactic implementation name: #{rpr imp_name}"
    unless imp_name.length > 1
      throw new Error "unsyntactic implementation name: #{rpr imp_name}"
    if counters[ imp_key ]?
      throw new Error "duplicate implementation key: #{rpr imp_name}"
    counter = @new_counter imp_key, imp_name
    counters[ imp_key ] = counter
    #.......................................................................................................
    for test_name, test of @tests imp.eq, imp.ne
      continue if test_name[ 0 ] is '_'
      results_entry             = results_by_test_name[ test_name ]?= {}
      results_entry[ imp_key ]  = true
      title                     = "#{imp_name} / #{test_name}"
      result                    = test.call @test
      #.....................................................................................................
      switch result_type = TYPES.type_of result
        #...................................................................................................
        when 'boolean'
          test_count         += 1
          counter[ 'tests' ] += 1
          if result
            praise title
          else
            fail_count               += 1
            counter[ 'fails' ]       += 1
            results_entry[ imp_key ]  = false
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
          test_count         += sub_count
          counter[ 'tests' ] += sub_count
          if sub_errors.length is 0
            praise title
          else
            results_entry[ imp_key ] = false
            for sub_error in sub_errors
              fail_count         += 1
              counter[ 'fails' ] += 1
              # warn "#{title} / #{sub_error}"
            warn title
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
  info    "Tested #{imp_count} implementations."
  info    "Overall, #{test_count} tests were run"
  praise  "of which #{pass_count} tests passed,"
  warn    "and #{fail_count} tests failed."
  whisper '-------------------------------------------------------------'
  #.........................................................................................................
  counters = ( counter for ignored, counter of counters )
  counters.sort ( a, b ) ->
    return +1 if a[ 'name' ][ 0 ] is '!'
    return -1 if b[ 'name' ][ 0 ] is '!'
    return +1 if a[ 'fails' ] > b[ 'fails' ]
    return -1 if a[ 'fails' ] < b[ 'fails' ]
    return  0
  #.........................................................................................................
  options =
    head: [ 'rank', 'key', 'implementation name', 'tests', 'passes', '%', 'fails', '%' ]
    chars: 'mid': '', 'left-mid': '', 'mid-mid': '', 'right-mid': ''
  table_1 = new Table options
  width = 8
  for counter, idx in counters
    { key, name, tests, fails } = counter
    passes                      = tests - fails
    passes_percentage           = "#{( passes / tests * 100 ).toFixed 1} %"
    fails_percentage            = "#{(  fails / tests * 100 ).toFixed 1} %"
    table_1.push [
      TRM.grey  idx + 1
      TRM.gold  key
      TRM.gold  name
      TRM.blue  tests
      TRM.green TEXT.flush_right passes,            width
      TRM.green TEXT.flush_right passes_percentage, width
      TRM.red   TEXT.flush_right fails,             width
      TRM.red   TEXT.flush_right fails_percentage,  width
      ]
  #.........................................................................................................
  headers   = [ '', ]
  imp_keys  = ( counter[ 'key' ] for counter in counters )
  headers.push.apply headers, imp_keys
  options =
    head: headers
    chars: {
      'top':     '', 'top-mid':    '', 'top-left':     '', 'top-right':    '',
      'bottom':  '', 'bottom-mid': '', 'bottom-left':  '', 'bottom-right': '',
      'left':    '', 'left-mid':   '', 'mid':          '', 'mid-mid':      '',
      'right':   '', 'right-mid':  '', 'middle':       '' }
  table_2 = new Table options
  for test_name, success_by_imp_key of results_by_test_name
    test_name = test_name[ ... 50 ] + '⋯' if test_name.length > 50
    row = [ test_name ]
    for imp_key in imp_keys
      if success_by_imp_key[ imp_key ]
        row.push TRM.green '◌'
      else
        row.push TRM.red '▼'
    table_2.push row
  #.........................................................................................................
  log '\n\n' + table_1.toString()
  help "Figures for implementations marked with an `!` (exclamation mark)"
  help "should be treated with care as their test setup is probably not correct."
  #.........................................................................................................
  log '\n\n' + table_2.toString()
  #.........................................................................................................
  return null


############################################################################################################
unless module.parent?
  @main()


