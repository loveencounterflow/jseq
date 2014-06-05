`
'use strict';

var path         = require('path')
  , EventEmitter = require('events').EventEmitter
  , tap          = require('tap')
  , test         = tap.test
  , d            = require(path.join(__dirname, '..', 'deeper'))
  ;

function functionA(a) { return a; }
var heinous = {
  nothin   : null,
  nope     : undefined,
  number   : 0,
  funky    : functionA,
  stringer : "heya",
  then     : new Date("1981-03-30"),
  rexpy    : /^(pi|π)$/,
  granular : {
    stuff : [0, 1, 2]
  }
};
heinous.granular.self = heinous;

var awful = {
  nothin   : null,
  nope     : undefined,
  number   : 0,
  funky    : functionA,
  stringer : "heya",
  then     : new Date("1981-03-30"),
  rexpy    : /^(pi|π)$/,
  granular : {
    stuff : [0, 1, 2]
  }
};
awful.granular.self = awful;

test("deeper handles all the edge cases", function (t) {
  /*
   *
   * SUCCESS
   *
   */

  var functionB = functionA;

  // 1. === gets the job done
  t.ok(d(null, null), "null is the same as itself");
  t.ok(d(undefined, undefined), "undefined is the same as itself");
  t.ok(d(0, 0), "numbers check out");
  t.ok(d(1 / 0, 1 / 0), "it's a travesty that 1 / 0 = Infinity, but Infinities are equal");
  t.ok(d("ok", "ok"), "strings check out");
  t.ok(d(functionA, functionB), "references to the same function are equal");

  // 4. buffers are compared by value
  var bufferA = new Buffer("abc");
  var bufferB = new Buffer('abc');
  t.ok(d(bufferA, bufferB), "buffers are compared by value");

  // 5. dates are compared by numeric (time) value
  var dateA = new Date("2001-01-11");
  var dateB = new Date('2001-01-11');
  t.ok(d(dateA, dateB), "dates are compared by time value");

  // 6. regexps are compared by their properties
  var rexpA = /^h[oe][wl][dl][oy]$/;
  var rexpB = /^h[oe][wl][dl][oy]$/;
  t.ok(d(rexpA, rexpB), "regexps are compared by their properties");

  // 8. loads of tests for objects
  t.ok(d({}, {}), "bare objects check out");
  var a = {a : 'a'};
  var b = a;
  t.ok(d(a, b), "identical object references check out");
  b = {a : 'a'};
  t.ok(d(a, b), "identical simple object values check out");

  t.ok(d([0,1], [0,1]), "arrays check out");

  function onerror(error) { console.err(error.stack); }
  var eeA = new EventEmitter(); eeA.on('error', onerror);
  var eeB = new EventEmitter(); eeB.on('error', onerror);
  t.ok(d(eeA, eeB), "more complex objects check out");

  var cyclicA = {}; cyclicA.x = cyclicA;
  var cyclicB = {}; cyclicB.x = cyclicB;
  t.ok(d(cyclicA, cyclicB), "can handle cyclic data structures");

  var y = {v:{v:{v:{v:{v:{v:{v:{v:{v:{v:{v:{v:{v:{v:{v:{}}}}}}}}}}}}}}}};
  y.v.v.v.v.v.v.v.v.v.v.v.v.v.v.v.v = y;
  var z = {v:{v:{v:{v:{v:{v:{v:{v:{v:{v:{v:{v:{v:{v:{v:{}}}}}}}}}}}}}}}};
  z.v.v.v.v.v.v.v.v.v.v.v.v.v.v.v.v = z;
  t.ok(d(y, z), "deeply recursive data structures also work");

  t.ok(d(heinous, awful), "more complex objects also check out");

  awful.granular.self = heinous;
  heinous.granular.self = awful;
  t.ok(d(heinous, awful),
       "mutual recursion with otherwise identical structures fools deepEquals");

  /*
   *
   * FAILURE
   *
   */

  // 1. === does its job
  t.notOk(d(NaN, NaN), "NaN is the only JavaScript value not equal to itself");
  t.notOk(d(1 / 0, -1 / 0), "opposite infinities are different");
  t.notOk(d(1, "1"), "strict equality, no coercion between strings and numbers");
  t.notOk(d("ok", "nok"), "different strings are different");
  t.notOk(d(0, "0"), "strict equality, no coercion between strings and numbers");
  t.notOk(d(undefined, null), "so many kinds of nothingness!");
  t.notOk(d(function nop() {},
            function nop() {}), "functions are only the same by reference");

  // 2. one is an object, the other is not
  t.notOk(d(undefined, {}), "if both aren't objects, not the same");

  // 3. null is an object
  t.notOk(d({}, null), "null is of type object");

  // 4. buffers are compared by both byte length (for speed) and value
  bufferB = new Buffer("abcd");
  t.notOk(d(bufferA, bufferB), "Buffers are checked for length");
  bufferB = new Buffer("abd");
  t.notOk(d(bufferA, bufferB), "Buffers are also checked for value");

  // 5. dates
  dateB = new Date('2001-01-12');
  t.notOk(d(dateA, dateB), "different dates are not the same");

  // 6. regexps
  rexpB = /^(howdy|hello)$/;
  t.notOk(d(rexpA, rexpB), "different regexps are not the same");

  // 8. objects present edge cases galore
  t.notOk(d([], {}), "different object types shouldn't match");

  var nullstructor = Object.create(null);
  t.notOk(d({}, nullstructor), "Object.create(null).constructor === undefined");

  b = {b : 'b'};
  t.notOk(d(a, b), "different object values aren't the same");

  function ondata(data) { console.log(data); }
  eeB.on('data', ondata);
  t.notOk(d(eeA, eeB), "changed objects don't match");

  awful.granular.stuff[2] = 3;
  t.notOk(d(heinous, awful), "small changes should be found");

  awful.granular.stuff[2] = 2;
  t.ok(d(heinous, awful), "small changes should be fixable");

  t.end();
});

test("monkeypatching assert.deepEqual works", function (t) {
  var assert = require('assert');
  t.throws(function () { assert.deepEqual(heinous, awful); },
           new RangeError("Maximum call stack size exceeded"),
           "should blow up with stock assert.deepEqual");

  d.patchAssert();

  t.doesNotThrow(function () { assert.deepEqual(heinous, awful); },
                 "shouldn't blow up with patched assert.deepEqual");
  t.end();
});

test("monkeypatching chai.eql works", function (t) {
  var chai           = require('chai')
    , expect         = chai.expect
    , AssertionError = chai.AssertionError
    ;

  t.doesNotThrow(function () { expect([]).eql({}); },
                 "chai.eql should be broken because it clones assert's bug");
  t.doesNotThrow(function () { expect([]).deep.equal({}); },
                 "chail.deep.equal should be broken because it clones assert's bug");

  d.patchChai();

  t.throws(function () { expect({}).eql([]); },
           new AssertionError({message : "expected {} to deeply equal []"}),
           "chai.eql should blow up now that bug is gone");
  t.throws(function () { expect({}).deep.equal([]); },
           new AssertionError({message : "expected {} to deeply equal []"}),
           "chai.deep.equal should blow up now that bug is gone");

  t.end();
});

test("before monkeypatching tap itself", function (t) {
  t.deepEqual({}, [], "using buggy version of deepEqual");
  t.deepEquals({}, [], "using buggy version of deepEquals");
  t.equivalent({}, [], "using buggy version of equivalent");
  t.isEquivalent({}, [], "using buggy version of isEquivalent");
  t.looseEqual({}, [], "using buggy version of looseEqual");
  t.looseEquals({}, [], "using buggy version of looseEquals");
  t.isDeeply({}, [], "using buggy version of isDeeply");
  t.same({}, [], "using buggy version of same");

  // trying to compare heinous and awful here will cause a RangeError

  t.end();
});

d.patchTap();

test("after monkeypatching tap", function (t) {
  t.notDeepEqual({}, [], "using deeper (behind notDeepEqual)");
  t.isNotDeepEqual({}, [], "using deeper (behind isNotDeepEqual)");
  t.inequivalent({}, [], "using deeper (behind inequivalent)");
  t.isInequivalent({}, [], "using deeper (behind isInequivalent)");
  t.notEquivalent({}, [], "using deeper (behind notEquivalent)");
  t.isNotEquivalent({}, [], "using deeper (behind isNotEquivalent)");
  t.isNotDeeply({}, [], "using deeper (behind isNotDeeply)");
  t.notDeeply({}, [], "using deeper (behind notDeeply)");
  t.notSame({}, [], "using deeper (behind notSame)");

  t.deepEqual(heinous, awful, "everything's awesome now");

  t.end();
});
`
###########################################################################################################
###########################################################################################################
###########################################################################################################
###########################################################################################################
###########################################################################################################
###########################################################################################################
`
var should = require('chai').should()
  , equal = require('..')

describe('Object strucures', function () {
  it('when structures match', function () {
    equal(
      { a : [ 2, 3 ], b : [ 4 ] },
      { a : [ 2, 3 ], b : [ 4 ] }
    ).should.be.true
  })

   it('when structures don\'t match', function () {
    equal(
      { x : 5, y : [6] },
      { x : 5, y : 6 }
    ).should.be.false
   })

   it('should handle nested nulls', function () {
    equal([ null, null, null ], [ null, null, null ]).should.be.true
    equal([ null, null, null ], [ null, 'null', null ]).should.be.false
   })

   it('should handle nested NaNs', function () {
    equal([ NaN, NaN, NaN ], [ NaN, NaN, NaN ]).should.be.true
    equal([ NaN, NaN, NaN ], [ NaN, 'NaN', NaN ]).should.be.false
   })
})

describe('Comparing arguments', function () {
  var a = (function a(a,b,c) {return arguments}(1,2,3))
  var b = (function b(a,b,c) {return arguments}(1,2,3))
  var c = (function c(a,b,c) {return arguments}(2,2,3))

  it('should not consider the callee', function () {
    equal(a,b).should.be.true
    equal(a,c).should.be.false
  })

  it('should be comparable to an Array', function () {
    equal(a,[1,2,3]).should.be.true
    equal(a,[1,2,4]).should.be.false
    equal(a,[1,2]).should.be.false
  })

  it.skip('should be comparable to an Object', function () {
    equal(a, {0:1,1:2,2:3,length:3}).should.be.true
    equal(a, {0:1,1:2,2:3,length:4}).should.be.false
    equal(a, {0:1,1:2,2:4,length:3}).should.be.false
    equal(a, {0:1,1:2,length:2}).should.be.false
  })
})

describe('Numbers', function () {
  it('should not coerce strings', function () {
    equal('1', 1).should.equal(false)
  })
  it('-0 should equal +0', function () {
    equal(-0, +0).should.be.true
  })
  describe('NaN', function () {
    it('should equal Nan', function () {
      equal(NaN, NaN).should.be.true
    })
    it('NaN should not equal undefined', function () {
      equal(NaN, undefined).should.be.false
    })
    it('NaN should not equal null', function () {
      equal(NaN, null).should.be.false
    })
    it('NaN should not equal empty string', function () {
      equal(NaN, '').should.be.false
    })
    it('should not equal zero', function () {
      equal(NaN, 0).should.be.false
    })
  })
})

describe('Strings', function () {
  it('should be case sensitive', function () {
    equal('hi', 'Hi').should.equal(false)
    equal('hi', 'hi').should.equal(true)
  })

  it('empty string should equal empty string', function () {
    equal('', "").should.be.true
  })
})

describe('undefined', function () {
  it('should equal only itself', function () {
    equal(undefined, null).should.be.false
    equal(undefined, '').should.be.false
    equal(undefined, 0).should.be.false
    equal(undefined, []).should.be.false
    equal(undefined, undefined).should.be.true
    equal(undefined, NaN).should.be.false
  })
})

describe('null', function () {
  it('should equal only itself', function () {
    equal(null, undefined).should.be.false
    equal(null, '').should.be.false
    equal(null, 0).should.be.false
    equal(null, []).should.be.false
    equal(null, null).should.be.true
    equal(null, NaN).should.be.false
  })
})

describe('Cyclic structures', function () {
  it('should not go into an infinite loop', function () {
    var a = {}
    var b = {}
    a.self = a
    b.self = b
    equal(a, b).should.equal(true)
  })
})

describe('functions', function () {
  it('should fail if they have different names', function () {
    equal(function a() {}, function b() {}).should.be.false
  })

  it('should pass if they are both anonamous', function () {
    equal(function () {}, function () {}).should.be.true
  })

  it.skip('handle the case where they have different argument names', function () {
    equal(function (b) {return b}, function (a) {return a}).should.be.true
  })

  it('should compare them as objects', function () {
    var a = function () {}
    var b = function () {}
    a.title = 'sometitle'
    equal(a, b).should.be.false
  })

  it('should compare their prototypes', function () {
    var a = function () {}
    var b = function () {}
    a.prototype.a = 1
    equal(a,b).should.be.false
  })

  it('should be able to compare object methods', function () {
    equal(
      {noop: function () {}},
      {noop: function () {}}
    ).should.be.true
    equal(
      {noop: function (a) {}},
      {noop: function () {}}
    ).should.be.false
  })
})

describe('many arguments', function () {
  it('should handle no values', function () {
    equal().should.be.true
  })

  it('should handle one value', function () {
    equal({}).should.be.true
  })

  it('should handle many values', function () {
    var vals = []
    for (var i = 0; i < 1000; i++) {
      vals.push({1:'I', 2:'am', 3:'equal'})
    }
    equal.apply(null, vals).should.be.true
  })

  it('should handle an odd number of values', function () {
    equal([1], {}, {}).should.be.false
  })
})

// Don't run these in the browser
if (typeof Buffer != 'undefined') {
  describe.skip('Buffer', function () {
    it('should compare on content', function () {
      equal(new Buffer('abc'), new Buffer('abc')).should.be.true
      equal(new Buffer('a'), new Buffer('b')).should.be.false
      equal(new Buffer('a'), new Buffer('ab')).should.be.false
    })

    it('should fail against anything other than a buffer', function () {
      equal(new Buffer('abc'), [97,98,99]).should.be.false
      equal(new Buffer('abc'), {0:97,1:98,2:99,length:3}).should.be.false
      equal([97,98,99], new Buffer('abc')).should.be.false
      equal({0:97,1:98,2:99,length:3}, new Buffer('abc')).should.be.false
    })
  })
}

describe.skip('configurable property exclusion', function () {
  it('should ignore properties that match the given regex', function () {
    var eq = equal.custom(/^_/)
    eq({_b:2}, {_b:3}).should.be.true
  })

  it('should default to not excluding any properties', function () {
    var eq = equal.custom()
    eq({a:1},{a:1}).should.be.true
    eq({"":1},{}).should.be.false
    eq({a:1},{}).should.be.false
    eq({b:1},{}).should.be.false
    eq({"!":1},{}).should.be.false
    eq({"~":1},{}).should.be.false
    eq({"#":1},{}).should.be.false
    eq({"$":1},{}).should.be.false
    eq({"%":1},{}).should.be.false
    eq({"^":1},{}).should.be.false
    eq({"&":1},{}).should.be.false
    eq({"*":1},{}).should.be.false
    eq({"(":1},{}).should.be.false
    eq({")":1},{}).should.be.false
    eq({"-":1},{}).should.be.false
    eq({"+":1},{}).should.be.false
    eq({"=":1},{}).should.be.false
  })
})

describe('possible regressions', function () {
  it('should handle objects with no constructor property', function () {
    var a = Object.create(null)
    equal(a, {}).should.be.true
    equal({}, a).should.be.true
    equal(a, {a:1}).should.be.false
    equal({a:1}, a).should.be.false
  })

  it('when comparing primitives to composites', function () {
    equal({}, undefined).should.be.false
    equal(undefined, {}).should.be.false

    equal(new String, {}).should.be.false
    equal({}, new String).should.be.false

    equal({}, new Number).should.be.false
    equal(new Number, {}).should.be.false

    equal(new Boolean, {}).should.be.false
    equal({}, new Boolean).should.be.false

    equal(new Date, {}).should.be.false
    equal({}, new Date).should.be.false

    equal(new RegExp, {}).should.be.false
    equal({}, new RegExp).should.be.false
  })
})

describe('compare', function(){
  it('should be usable', function(){
    equal.compare({}, new Date).should.be.false
    equal.compare({}, {}).should.be.true
    equal.compare([], []).should.be.true
  })
})
`

###############################################################################################
###############################################################################################
###############################################################################################
###############################################################################################
###############################################################################################
###############################################################################################
###############################################################################################
###############################################################################################
[1, 1, true],
[1, new Number(1), true],
[1, '1', false],
[1, 2, false],
[-0, -0, true],
[0, 0, true],
[0, new Number(0), true],
[new Number(0), new Number(0), true],
[-0, 0, false],
[0, '0', false],
[0, null, false],
[NaN, NaN, true],
[NaN, new Number(NaN), true],
[new Number(NaN), new Number(NaN), true],
[NaN, 'a', false],
[NaN, Infinity, false],
['a', 'a', true],
['a', new String('a'), true],
[new String('a'), new String('a'), true],
['a', 'b', false],
['a', ['a'], false],
[true, true, true],
[true, new Boolean(true), true],
[new Boolean(true), new Boolean(true), true],
[true, 1, false],
[true, 'a', false],
[false, false, true],
[false, new Boolean(false), true],
[new Boolean(false), new Boolean(false), true],
[false, 0, false],
[false, '', false],
[null, null, true],
[null, undefined, false],
[null, {}, false],
[null, '', false],
[undefined, undefined, true],
[undefined, null, false],
[undefined, '', false]
