(function() {
  //###########################################################################################################
  var TRM, alert, badge, debug, echo, help, info, log, rpr, warn, whisper;

  TRM = require('coffeenode-trm');

  rpr = TRM.rpr.bind(TRM);

  badge = 'jsEq/tests';

  log = TRM.get_logger('plain', badge);

  info = TRM.get_logger('info', badge);

  whisper = TRM.get_logger('whisper', badge);

  alert = TRM.get_logger('alert', badge);

  debug = TRM.get_logger('debug', badge);

  warn = TRM.get_logger('warn', badge);

  help = TRM.get_logger('help', badge);

  echo = TRM.echo.bind(TRM);

  //-----------------------------------------------------------------------------------------------------------
  module.exports = function(eq, ne) {
    var R;
    R = {};
    /* 1. simple tests */
    //---------------------------------------------------------------------------------------------------------
    /* 1.1. positive */
    R["№ 1: NaN eqs NaN"] = function() {
      return eq(0/0, 0/0);
    };
    R["№ 2: finite integer n eqs n"] = function() {
      return eq(1234, 1234);
    };
    R["№ 3: emtpy list eqs empty list"] = function() {
      return eq([], []);
    };
    R["№ 4: emtpy obj eqs empty obj"] = function() {
      return eq({}, {});
    };
    R["№ 5: number eqs number of same value"] = function() {
      return eq(123.45678, 123.45678);
    };
    R["№ 6: regex lit's w same pattern, flags are eq"] = function() {
      return eq(/^abc[a-zA-Z]/, /^abc[a-zA-Z]/);
    };
    R["№ 7: pods w same properties are eq"] = function() {
      return eq({
        a: 'b',
        c: 'd'
      }, {
        a: 'b',
        c: 'd'
      });
    };
    R["№ 8: pods that only differ wrt prop ord are eq"] = function() {
      return eq({
        a: 'b',
        c: 'd'
      }, {
        c: 'd',
        a: 'b'
      });
    };
    //---------------------------------------------------------------------------------------------------------
    /* 1.2. negative */
    R["№ 9: obj doesn't eq list"] = function() {
      return ne({}, []);
    };
    R["№ 10: obj in a list doesn't eq list in list"] = function() {
      return ne([{}], [[]]);
    };
    R["№ 11: integer n doesn't eq rpr n"] = function() {
      return ne(1234, '1234');
    };
    R["№ 12: integer n doesn't eq n + 1"] = function() {
      return ne(1234, 1235);
    };
    R["№ 13: empty list doesn't eq false"] = function() {
      return ne([], false);
    };
    R["№ 14: list w an integer doesn't eq one w rpr n"] = function() {
      return ne([3], ['3']);
    };
    R["№ 15: regex lit's w diff. patterns, same flags aren't eq"] = function() {
      return ne(/^abc[a-zA-Z]/, /^abc[a-zA-Z]x/);
    };
    R["№ 16: regex lit's w same patterns, diff. flags aren't eq"] = function() {
      return ne(/^abc[a-zA-Z]/, /^abc[a-zA-Z]/i);
    };
    R["№ 17: +0 should ne -0"] = function() {
      return ne(+0, -0);
    };
    R["№ 18: number obj not eqs primitive number of same value"] = function() {
      return ne(5, new Number(5));
    };
    R["№ 19: string obj not eqs primitive string of same value"] = function() {
      return ne('helo', new String('helo'));
    };
    R["№ 20: (1) bool obj not eqs primitive bool of same value"] = function() {
      return ne(false, new Boolean(false));
    };
    R["№ 21: (2) bool obj not eqs primitive bool of same value"] = function() {
      return ne(true, new Boolean(true));
    };
    //=========================================================================================================
    /* 2. complex tests */
    //---------------------------------------------------------------------------------------------------------
    R["№ 22: obj w undef member not eqs other obj w/out same member"] = function() {
      var d, e;
      d = {
        x: void 0
      };
      e = {};
      return ne(d, e);
    };
    //---------------------------------------------------------------------------------------------------------
    R["№ 23: fn1: two functions are always ne"] = function() {
      var d, e;
      d = function( a, b, c ){ return a * b * c; };
      e = function( a, b, c ){ return a * b * c; };
      return eq(d, e);
    };
    //---------------------------------------------------------------------------------------------------------
    R["№ 24: fn1: functions are eq to themselves"] = function() {
      var d, e;
      d = function( a, b, c ){ return a * b * c; };
      e = d;
      return eq(d, e);
    };
    //---------------------------------------------------------------------------------------------------------
    R["№ 25: list w named member eqs other list w same member"] = function() {
      var d, e;
      d = ['foo', null, 3];
      d['extra'] = 42;
      e = ['foo', null, 3];
      e['extra'] = 42;
      return eq(d, e);
    };
    //---------------------------------------------------------------------------------------------------------
    R["№ 26: list w named member doesn't eq list w same member, other value"] = function() {
      var d, e;
      d = ['foo', null, 3];
      d['extra'] = 42;
      e = ['foo', null, 3];
      e['extra'] = 108;
      return ne(d, e);
    };
    //---------------------------------------------------------------------------------------------------------
    R["№ 27: date eqs other date pointing to same time"] = function() {
      var d, e;
      d = new Date("1995-12-17T03:24:00");
      e = new Date("1995-12-17T03:24:00");
      return eq(d, e);
    };
    //---------------------------------------------------------------------------------------------------------
    R["№ 28: date does not eq other date pointing to other time"] = function() {
      var d, e;
      d = new Date("1995-12-17T03:24:00");
      e = new Date("1995-12-17T03:24:01");
      return ne(d, e);
    };
    //---------------------------------------------------------------------------------------------------------
    R["№ 29: str obj w props eq same str, same props"] = function() {
      var d, e;
      d = new String("helo test");
      d['abc'] = 42;
      e = new String("helo test");
      e['abc'] = 42;
      return ne(d, e);
    };
    //---------------------------------------------------------------------------------------------------------
    R["№ 30: str obj w props not eq same str, other props"] = function() {
      var d, e;
      d = new String("helo test");
      d['abc'] = 42;
      e = new String("helo test");
      e['def'] = 42;
      return ne(d, e);
    };
    //---------------------------------------------------------------------------------------------------------
    R["№ 31: str obj w props eq same str, same props (circ)"] = function() {
      var c, d, e;
      c = ['a list'];
      c.push(c);
      d = new String("helo test");
      d['abc'] = c;
      e = new String("helo test");
      e['abc'] = c;
      return ne(d, e);
    };
    //---------------------------------------------------------------------------------------------------------
    R["№ 32: str obj w props not eq same str, other props (circ)"] = function() {
      var c, d, e;
      c = ['a list'];
      c.push(c);
      d = new String("helo test");
      d['abc'] = c;
      e = new String("helo test");
      e['def'] = c;
      return ne(d, e);
    };
    //---------------------------------------------------------------------------------------------------------
    R["№ 33: empty objs ne when diff prototypes"] = function() {
      var d, e;
      d = {};
      e = Object.create(null);
      return ne(d, e);
    };
    //---------------------------------------------------------------------------------------------------------
    R["№ 34: (1) circ arrays w similar layout, same values aren't eq"] = function() {
      var d, e;
      d = [1, 2, 3];
      d.push(d);
      e = [1, 2, 3];
      e.push(d);
      return ne(d, e);
    };
    //---------------------------------------------------------------------------------------------------------
    R["№ 35: (2) circ arrays w same layout, same values are eq"] = function() {
      var d, e;
      d = [1, 2, 3];
      d.push(d);
      e = [1, 2, 3];
      e.push(e);
      return eq(d, e);
    };
    //---------------------------------------------------------------------------------------------------------
    R["№ 36: (fkling1) arrays w eq subarrays are eq"] = function() {
      var a, b, bar, foo;
      a = [1, 2, 3];
      b = [1, 2, 3];
      foo = [a, a];
      bar = [b, b];
      return eq(foo, bar);
    };
    //---------------------------------------------------------------------------------------------------------
    R["№ 37: (fkling2) arrays w eq subarrays but diff distribution aren't eq"] = function() {
      var a, b, bar, foo;
      a = [1, 2, 3];
      b = [1, 2, 3];
      foo = [a, a];
      bar = [a, b];
      return ne(foo, bar);
    };
    //---------------------------------------------------------------------------------------------------------
    /* joshwilsdon's test (https://github.com/joyent/node/issues/7161) */
    R["№ 38: joshwilsdon"] = function() {
      var count, d1, d2, errors, i, idx1, idx2, j, len, ref, ref1, v1, v2;
      d1 = [
        0/0,
        void 0,
        null,
        true,
        false,
        2e308,
        0,
        1,
        "a",
        "b",
        {
          a: 1
        },
        {
          a: "a"
        },
        [
          {
            a: 1
          }
        ],
        [
          {
            a: true
          }
        ],
        {
          a: 1,
          b: 2
        },
        [1,
        2],
        [1,
        2,
        3],
        {
          a: "1"
        },
        {
          a: "1",
          b: "2"
        }
      ];
      d2 = [
        0/0,
        void 0,
        null,
        true,
        false,
        2e308,
        0,
        1,
        "a",
        "b",
        {
          a: 1
        },
        {
          a: "a"
        },
        [
          {
            a: 1
          }
        ],
        [
          {
            a: true
          }
        ],
        {
          a: 1,
          b: 2
        },
        [1,
        2],
        [1,
        2,
        3],
        {
          a: "1"
        },
        {
          a: "1",
          b: "2"
        }
      ];
      errors = [];
      count = 0;
      for (idx1 = i = 0, len = d1.length; i < len; idx1 = ++i) {
        v1 = d1[idx1];
        for (idx2 = j = ref = idx1, ref1 = d2.length; (ref <= ref1 ? j < ref1 : j > ref1); idx2 = ref <= ref1 ? ++j : --j) {
          count += 1;
          v2 = d2[idx2];
          if (idx1 === idx2) {
            if (!eq(v1, v2)) {
              errors.push(`eq ${rpr(v1)}, ${rpr(v2)}`);
            }
          } else {
            if (!ne(v1, v2)) {
              errors.push(`ne ${rpr(v1)}, ${rpr(v2)}`);
            }
          }
        }
      }
      //.......................................................................................................
      // whisper count
      return [count, errors];
    };
    //---------------------------------------------------------------------------------------------------------
    R["№ 39: (MapSet1) Support for Maps and Sets"] = function() {
      var a, b;
      a = new Set('abcdef');
      b = new Set('abcdef');
      return eq(a, b);
    };
    //---------------------------------------------------------------------------------------------------------
    R["№ 40: (MapSet2) Support for Maps and Sets"] = function() {
      var a, b;
      a = new Set('abcdef');
      b = new Set('abcdefg');
      return ne(a, b);
    };
    //---------------------------------------------------------------------------------------------------------
    R["№ 41: (MapSet3) Support for Maps and Sets"] = function() {
      var a, b;
      a = new Map([['a', 42], ['b', 108], [true, 'yes']]);
      b = new Map([['a', 42], ['b', 108], [true, 'yes']]);
      return eq(a, b);
    };
    //---------------------------------------------------------------------------------------------------------
    R["№ 42: (MapSet4) Support for Maps and Sets"] = function() {
      var a, b;
      a = new Map([['a', 42], ['b', 108], [true, 'yes'], [[1, 2, 3]]]);
      b = new Map([['a', 42], ['b', 108], [true, 'yes'], [[1, 2, 3]]]);
      return eq(a, b);
    };
    //---------------------------------------------------------------------------------------------------------
    return R;
  };

}).call(this);

//# sourceMappingURL=tests.js.map