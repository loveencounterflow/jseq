


############################################################################################################
TRM                       = require 'coffeenode-trm'
rpr                       = TRM.rpr.bind TRM
badge                     = 'jsEq/jseq'
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
LODASH                    = require 'lodash'



#-----------------------------------------------------------------------------------------------------------
options =
  'signed-zeroes':      no
  'functions':          yes
  'NaN':                yes
  'array-attributes':   yes

#-----------------------------------------------------------------------------------------------------------
js_type_of = ( x ) -> Object::toString.call x


#-----------------------------------------------------------------------------------------------------------
new_ = ( options_or_handler, self ) ->
  if ( js_type_of options_or_handler ) is '[object Function]'
    handler   = options_or_handler
    settings  = options
  else
    settings  = LODASH.merge {}, options, ( options_or_handler ? {} )
    handler   = null
  #---------------------------------------------------------------------------------------------------------
  properties_are_equal = ( a, b, all = true ) ->
    ### TAINT should we check for property descriptors? ###
    pa = {}; pa[ name ] = value for name, value of a when all or not ( 0 <= name < a.length )
    pb = {}; pb[ name ] = value for name, value of b when all or not ( 0 <= name < b.length )
    whisper pa, pb
    return eq pa, pb
  #---------------------------------------------------------------------------------------------------------
  return eq = ( P... ) ->
    if ( arity = P.length ) < 2
      throw new Error "need at least 2 arguments, got #{arity}"
    else
      R = true
      for idx in [ 1 ... P.length ]
        #...................................................................................................
        R = R and LODASH.isEqual P[ 0 ], P[ idx ], ( a, b ) ->
          return handler a, b if handler?
          #.................................................................................................
          if a == 0 and b == 0 and settings[ 'signed-zeroes' ]
            ### taken verbatim from lodash: ###
            return not `a !== 0 || (1 / a == 1 / b )`
          #.................................................................................................
          if settings[ 'functions' ]
            if ( '[object Function]' == js_type_of a ) and ( '[object Function]' == js_type_of b )
              return false if a.toString() isnt b.toString()
              return properties_are_equal a, b, true
          #.................................................................................................
          if not settings[ 'NaN' ]
            ### isNaN is broken as per MDN, so we don't use it ###
            return false if ( a != a ) and ( b != b )
          #.................................................................................................
          if settings[ 'array-attributes' ]
            if ( '[object Array]' == js_type_of a ) and ( '[object Array]' == js_type_of b )
              return false unless a.length is b.length
              return false unless properties_are_equal a, b, false
              return LODASH.isEqual a, b
          #.................................................................................................
          return undefined
        #...................................................................................................
        return R if not R
      return R

#-----------------------------------------------------------------------------------------------------------
module.exports      = new_()
module.exports.new  = new_

