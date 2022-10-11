(function() {
  //###########################################################################################################
  var ASSERT, BNP, LODASH, TRM, UNDERSCORE, alert, assert_paranoid_equal, badge, cjs_deep_eql, custom_jseq, custom_jseq_options, debug, deep_equal_ident, echo, fast_equals_deepEquals, fde_equal, fdq_equal, get_errorproof_comparator, help, info, is_equal, jdq_deepequal, jkroso_equals, jseq, jv_equals, log, othiym23_deepEqual, praise, rpr, should, should_equal, substack_deep_equal, urge, util_isDeepStrictEqual, warn, whisper;

  TRM = require('coffeenode-trm');

  rpr = TRM.rpr.bind(TRM);

  badge = 'jsEq/implementations';

  log = TRM.get_logger('plain', badge);

  info = TRM.get_logger('info', badge);

  whisper = TRM.get_logger('whisper', badge);

  alert = TRM.get_logger('alert', badge);

  debug = TRM.get_logger('debug', badge);

  warn = TRM.get_logger('warn', badge);

  help = TRM.get_logger('help', badge);

  urge = TRM.get_logger('urge', badge);

  praise = TRM.get_logger('praise', badge);

  echo = TRM.echo.bind(TRM);

  //...........................................................................................................
  /* implementations of deep equality tests: */
  BNP = require('coffeenode-bitsnpieces');

  ASSERT = require('node:assert');

  ({
    isDeepStrictEqual: util_isDeepStrictEqual
  } = require('node:util'));

  LODASH = require('lodash');

  UNDERSCORE = require('underscore');

  jkroso_equals = require('equals');

  othiym23_deepEqual = require('deeper');

  should = require('should');

  should_equal = require('should-equal');

  substack_deep_equal = require('deep-equal');

  jv_equals = require('../3rd-party/JV-jeanvincent.js');

  cjs_deep_eql = require('deep-eql');

  jseq = require('./eq');

  jdq_deepequal = require('deepequal');

  assert_paranoid_equal = require('assert-paranoid-equal');

  is_equal = require('is-equal');

  // angular                   = require 'angular'
  // warn '©oganH'
  deep_equal_ident = require('deep-equal-ident');

  fdq_equal = require('fast-deep-equal');

  fde_equal = require('fast-deep-equal/es6/index.js');

  ({
    circularDeepEqual: fast_equals_deepEquals
  } = require('fast-equals/dist/fast-equals.cjs.js'));

  //-----------------------------------------------------------------------------------------------------------
  /* https://github.com/planttheidea/fast-equals */  custom_jseq_options = {
    'signed-zeroes': true,
    'functions': false,
    'NaN': false,
    'properties': false,
    'primitive-and-object': false
  };

  //-----------------------------------------------------------------------------------------------------------
  custom_jseq = jseq.new(custom_jseq_options);

  //-----------------------------------------------------------------------------------------------------------
  get_errorproof_comparator = function(test_method) {
    return function(a, b) {
      var R, error;
      try {
        R = test_method(a, b);
      } catch (error1) {
        error = error1;
        if (error['message'] === 'Maximum call stack size exceeded') {
          error['code'] = 'jsEq';
          throw error;
        }
        return false;
      }
      return R;
    };
  };

  //-----------------------------------------------------------------------------------------------------------
  module.exports = {
    //.........................................................................................................
    "JKR: https://github.com/jkroso/equals": {
      //.......................................................................................................
      eq: function(a, b) {
        return jkroso_equals(a, b);
      },
      ne: function(a, b) {
        return !jkroso_equals(a, b);
      }
    },
    //.........................................................................................................
    "NUI: NodeJS util.isDeepStrictEqual": {
      //.......................................................................................................
      eq: function(a, b) {
        return util_isDeepStrictEqual(a, b);
      },
      ne: function(a, b) {
        return !util_isDeepStrictEqual(a, b);
      }
    },
    //.........................................................................................................
    "ADE: NodeJS assert.deepEqual": {
      //.......................................................................................................
      eq: function(a, b) {
        var error;
        try {
          ASSERT.deepEqual(a, b);
        } catch (error1) {
          error = error1;
          return false;
        }
        return true;
      },
      //.......................................................................................................
      ne: function(a, b) {
        var error;
        try {
          ASSERT.notDeepEqual(a, b);
        } catch (error1) {
          error = error1;
          return false;
        }
        return true;
      }
    },
    //.........................................................................................................
    "ASE: NodeJS assert.strictEqual": {
      //.......................................................................................................
      eq: function(a, b) {
        var error;
        try {
          ASSERT.strictEqual(a, b);
        } catch (error1) {
          error = error1;
          return false;
        }
        return true;
      },
      //.......................................................................................................
      ne: function(a, b) {
        var error;
        try {
          ASSERT.notStrictEqual(a, b);
        } catch (error1) {
          error = error1;
          return false;
        }
        return true;
      }
    },
    //.........................................................................................................
    "ADS: NodeJS assert.deepStrictEqual": {
      //.......................................................................................................
      eq: function(a, b) {
        var error;
        try {
          ASSERT.deepStrictEqual(a, b);
        } catch (error1) {
          error = error1;
          return false;
        }
        return true;
      },
      //.......................................................................................................
      ne: function(a, b) {
        var error;
        try {
          ASSERT.notDeepStrictEqual(a, b);
        } catch (error1) {
          error = error1;
          return false;
        }
        return true;
      }
    },
    //.........................................................................................................
    "AEQ: NodeJS assert.equal": {
      //.......................................................................................................
      eq: function(a, b) {
        var error;
        try {
          ASSERT.equal(a, b);
        } catch (error1) {
          error = error1;
          return false;
        }
        return true;
      },
      //.......................................................................................................
      ne: function(a, b) {
        var error;
        try {
          ASSERT.notEqual(a, b);
        } catch (error1) {
          error = error1;
          return false;
        }
        return true;
      }
    },
    //.........................................................................................................
    "CND: CoffeeNode Bits'N'Pieces": {
      //.......................................................................................................
      eq: function(a, b) {
        return BNP.equals(a, b);
      },
      ne: function(a, b) {
        return !BNP.equals(a, b);
      }
    },
    //.........................................................................................................
    "==: native ==": {
      //.......................................................................................................
      eq: function(a, b) {
        return a == b;
      },
      ne: function(a, b) {
        return a != b;
      }
    },
    //.........................................................................................................
    "===: native ===": {
      //.......................................................................................................
      eq: function(a, b) {
        return a === b;
      },
      ne: function(a, b) {
        return a !== b;
      }
    },
    //.........................................................................................................
    "OIS: native Object.is": {
      //.......................................................................................................
      eq: function(a, b) {
        return Object.is(a, b);
      },
      ne: function(a, b) {
        return Object.is(a, b);
      }
    },
    //.........................................................................................................
    "CHA: https://github.com/chaijs/deep-eql": {
      //.......................................................................................................
      eq: function(a, b) {
        return cjs_deep_eql(a, b);
      },
      ne: function(a, b) {
        return !cjs_deep_eql(a, b);
      }
    },
    //.........................................................................................................
    "o23: https://github.com/othiym23/node-deeper": {
      //.......................................................................................................
      eq: function(a, b) {
        return othiym23_deepEqual(a, b);
      },
      ne: function(a, b) {
        return !othiym23_deepEqual(a, b);
      }
    },
    //.........................................................................................................
    "*JV: http://stackoverflow.com/a/6713782/256361": {
      eq: get_errorproof_comparator(jv_equals),
      ne: get_errorproof_comparator(function(a, b) {
        return !jv_equals(a, b);
      })
    },
    //.........................................................................................................
    "DEQ: https://github.com/substack/node-deep-equal": {
      eq: get_errorproof_comparator(substack_deep_equal),
      ne: get_errorproof_comparator(function(a, b) {
        return !substack_deep_equal(a, b);
      })
    },
    // #.........................................................................................................
    // "SH1: https://github.com/shouldjs/should.js#equal":
    //   #.......................................................................................................
    //   eq: ( a, b ) ->
    //     try
    //       ( should a ).equal b
    //     catch error
    //       return false
    //     return true
    //   ne: ( a, b ) ->
    //     try
    //       ( should a ).not.equal b
    //     catch error
    //       return false
    //     return true
    // #.........................................................................................................
    // "SH2: https://github.com/shouldjs/should.js#eql":
    //   #.......................................................................................................
    //   eq: ( a, b ) ->
    //     try
    //       ( should a ).eql b
    //     catch error
    //       return false
    //     return true
    //   ne: ( a, b ) ->
    //     try
    //       ( should a ).not.eql b
    //     catch error
    //       return false
    //     return true
    // #.........................................................................................................
    // "SH5: https://github.com/shouldjs/should.js#equal":
    //   #.......................................................................................................
    //   eq: ( a, b ) ->
    //     try
    //       ( should a ).equal b
    //     catch error
    //       return false
    //     return true
    //   ne: ( a, b ) ->
    //     try
    //       ( should a ).equal b
    //     catch error
    //       return true
    //     return false
    // #.........................................................................................................
    // "SH6: https://github.com/shouldjs/should.js#eql":
    //   #.......................................................................................................
    //   eq: ( a, b ) ->
    //     try
    //       ( should a ).eql b
    //     catch error
    //       return false
    //     return true
    //   ne: ( a, b ) ->
    //     try
    //       ( should a ).eql b
    //     catch error
    //       return true
    //     return false
    //.........................................................................................................
    "JDQ: https://github.com/JayceTDE/deepequal": {
      //.......................................................................................................
      eq: get_errorproof_comparator(jdq_deepequal),
      ne: get_errorproof_comparator(function(a, b) {
        return !jdq_deepequal(a, b);
      })
    },
    //.........................................................................................................
    "APE: https://github.com/dervus/assert-paranoid-equal": {
      //.......................................................................................................
      eq: function(a, b) {
        var error;
        try {
          assert_paranoid_equal.paranoidEqual(a, b);
        } catch (error1) {
          error = error1;
          return false;
        }
        return true;
      },
      //.......................................................................................................
      ne: function(a, b) {
        var error;
        try {
          assert_paranoid_equal.notParanoidEqual(a, b);
        } catch (error1) {
          error = error1;
          return false;
        }
        return true;
      }
    },
    // #.........................................................................................................
    // "SEQ: https://github.com/shouldjs/equal":
    //   #.......................................................................................................
    //   eq: ( a, b ) -> should_equal a, b
    //   ne: ( a, b ) -> not should_equal a, b
    //.........................................................................................................
    "UDS: underscore _.isEqual": {
      //.......................................................................................................
      eq: function(a, b) {
        return UNDERSCORE.isEqual(a, b);
      },
      ne: function(a, b) {
        return !UNDERSCORE.isEqual(a, b);
      }
    },
    //.........................................................................................................
    "LDS: lodash _.isEqual": {
      //.......................................................................................................
      eq: function(a, b) {
        return LODASH.isEqual(a, b);
      },
      ne: function(a, b) {
        return !LODASH.isEqual(a, b);
      }
    },
    //.........................................................................................................
    "DQI: https://github.com/fkling/deep-equal-ident": {
      //.......................................................................................................
      eq: get_errorproof_comparator(deep_equal_ident),
      ne: get_errorproof_comparator(function(a, b) {
        return !deep_equal_ident(a, b);
      })
    },
    //.........................................................................................................
    "ISE: https://github.com/ljharb/is-equal": {
      //.......................................................................................................
      eq: get_errorproof_comparator(is_equal),
      ne: get_errorproof_comparator(function(a, b) {
        return !is_equal(a, b);
      })
    },
    // #.........................................................................................................
    // "ANG: https://github.com/bclinkinbeard/angular":
    //   #.......................................................................................................
    //   eq: get_errorproof_comparator angular.equals
    //   ne: get_errorproof_comparator ( a, b ) -> not angular.equals a, b
    //.........................................................................................................
    "EQ: jsEq.eq": {
      //.......................................................................................................
      eq: get_errorproof_comparator(jseq),
      ne: get_errorproof_comparator(function(a, b) {
        return !jseq(a, b);
      })
    },
    //.........................................................................................................
    "*EQ: custom version of jsEq.eq": {
      //.......................................................................................................
      eq: get_errorproof_comparator(custom_jseq),
      ne: get_errorproof_comparator(function(a, b) {
        return !custom_jseq(a, b);
      })
    },
    //.........................................................................................................
    "FDQ: fast-deep-equal": { // https://github.com/epoberezkin/fast-deep-equal
      //.......................................................................................................
      eq: get_errorproof_comparator(fdq_equal),
      ne: get_errorproof_comparator(function(a, b) {
        return !fdq_equal(a, b);
      })
    },
    //.........................................................................................................
    "FDE: fast-deep-equal (ES6)": { // https://github.com/epoberezkin/fast-deep-equal
      //.......................................................................................................
      eq: get_errorproof_comparator(fde_equal),
      ne: get_errorproof_comparator(function(a, b) {
        return !fde_equal(a, b);
      })
    },
    //.........................................................................................................
    "FEQ: fast-equals": { // https://github.com/planttheidea/fast-equals
      //.......................................................................................................
      eq: fast_equals_deepEquals,
      ne: function(a, b) {
        return !fast_equals_deepEquals(a, b);
      }
    }
  };

}).call(this);

//# sourceMappingURL=implementations.js.map