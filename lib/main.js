(function() {
  //###########################################################################################################
  /* TAINT should use customized fork */
  var BNP, TEXT, TRM, TYPES, alert, badge, debug, echo, help, info, log, praise, rpr, urge, warn, whisper;

  TRM = require('coffeenode-trm');

  rpr = TRM.rpr.bind(TRM);

  badge = 'jsEq';

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
  this.tests = require('./tests');

  this.imps = require('./implementations');

  BNP = require('coffeenode-bitsnpieces');

  TEXT = require('coffeenode-text');

  TYPES = require('coffeenode-types');

  //-----------------------------------------------------------------------------------------------------------
  this.new_counter = function(key, name) {
    var R;
    R = {
      'key': key,
      'name': name,
      'tests': 0,
      'fails': 0
    };
    return R;
  };

  //-----------------------------------------------------------------------------------------------------------
  this.main = function() {
    var Table, count_type, counter, counters, error, errors_type, fail_count, fails, fails_percentage, headers, i, idx, ignored, illegal, imp, imp_count, imp_key, imp_keys, imp_name, j, k, key, l, len, len1, len2, len3, length, message, minus_points, name, options, pass_count, passes, passes_percentage, ref, ref1, ref2, result, result_type, results_by_test_name, results_entry, row, sub_count, sub_error, sub_errors, success_by_imp_key, table_1, table_2, table_3, test, test_count, test_name, tests, title, width;
    imp_count = 0;
    test_count = 0;
    fail_count = 0;
    counters = {};
    results_by_test_name = {};
    minus_points = [];
    ref = this.imps;
    //.........................................................................................................
    for (imp_name in ref) {
      imp = ref[imp_name];
      imp_count += 1;
      info(imp_name);
      [imp_key, imp_name, ...illegal] = imp_name.split(/:\s+/);
      if (illegal.length !== 0) {
        throw new Error(`unsyntactic implementation name: ${rpr(imp_name)}`);
      }
      if (!((0 < (ref1 = imp_key.length) && ref1 < 4))) {
        throw new Error(`unsyntactic implementation name: ${rpr(imp_name)}`);
      }
      if (!(imp_name.length > 1)) {
        throw new Error(`unsyntactic implementation name: ${rpr(imp_name)}`);
      }
      if (counters[imp_key] != null) {
        throw new Error(`duplicate implementation key: ${rpr(imp_name)}`);
      }
      counter = this.new_counter(imp_key, imp_name);
      counters[imp_key] = counter;
      ref2 = this.tests(imp.eq, imp.ne);
      //.......................................................................................................
      for (test_name in ref2) {
        test = ref2[test_name];
        if (test_name[0] === '_') {
          continue;
        }
        results_entry = results_by_test_name[test_name] != null ? results_by_test_name[test_name] : results_by_test_name[test_name] = {};
        results_entry[imp_key] = true;
        title = `${imp_name} / ${test_name}`;
        try {
          result = test.call(this.test);
        } catch (error1) {
          error = error1;
          if (error['code'] !== 'jsEq') {
            throw error;
          }
          minus_points.push([imp_key, test_name, error['message']]);
          result = false;
        }
        //.....................................................................................................
        switch (result_type = TYPES.type_of(result)) {
          //...................................................................................................
          case 'boolean':
            test_count += 1;
            counter['tests'] += 1;
            if (result) {
              praise(title);
            } else {
              fail_count += 1;
              counter['fails'] += 1;
              results_entry[imp_key] = false;
              warn(title);
            }
            break;
          //...................................................................................................
          case 'list':
            if ((length = result.length) !== 2) {
              throw new Error(`${title}: expected list of length 2, got one with length ${length}`);
            }
            [sub_count, sub_errors] = result;
            if ((count_type = TYPES.type_of(sub_count)) !== 'number') {
              throw new Error(`${title}: expected a number, got a ${count_type}`);
            }
            if (!(sub_count > 0 && sub_count === Math.floor(sub_count))) {
              throw new Error(`${title}: expected an integer greater than zero, got ${sub_count}`);
            }
            if ((errors_type = TYPES.type_of(sub_errors)) !== 'list') {
              throw new Error(`${title}: expected a list, got a ${errors_type}`);
            }
            test_count += sub_count;
            counter['tests'] += sub_count;
            if (sub_errors.length === 0) {
              praise(title);
            } else {
              results_entry[imp_key] = false;
              for (i = 0, len = sub_errors.length; i < len; i++) {
                sub_error = sub_errors[i];
                fail_count += 1;
                counter['fails'] += 1;
              }
              // warn "#{title} / #{sub_error}"
              warn(title);
            }
            break;
          default:
            //...................................................................................................
            throw new Error(`${title}: expected a boolean or a list, got a ${result_type}`);
        }
      }
    }
    //.........................................................................................................
    // whisper '-------------------------------------------------------------'
    // info    "Skipped #{skip_count} out of #{route_count} modules;"
    // info    "of the #{route_count - skip_count} modules inspected,"
    // urge    "#{miss_count} modules had no test cases."
    // info    "In the remaining #{route_count - miss_count - skip_count} modules,"
    // info    "#{test_count} tests were performed,"
    // praise  "of which #{pass_count} tests passed,"
    // warn    "and #{fail_count} tests failed."
    pass_count = test_count - fail_count;
    whisper('-------------------------------------------------------------');
    info(`Tested ${imp_count} implementations.`);
    info(`Overall, ${test_count} tests were run`);
    praise(`of which ${pass_count} tests passed,`);
    warn(`and ${fail_count} tests failed.`);
    whisper('-------------------------------------------------------------');
    //.........................................................................................................
    counters = (function() {
      var results;
      results = [];
      for (ignored in counters) {
        counter = counters[ignored];
        results.push(counter);
      }
      return results;
    })();
    counters.sort(function(a, b) {
      if (a['name'][0] === '!') {
        return +1;
      }
      if (b['name'][0] === '!') {
        return -1;
      }
      if (a['fails'] > b['fails']) {
        return +1;
      }
      if (a['fails'] < b['fails']) {
        return -1;
      }
      return 0;
    });
    Table = require('cli-table');
    //.........................................................................................................
    options = {
      head: ['rank', 'key', 'implementation name', 'tests', 'passes', '%', 'fails', '%'],
      chars: {
        'mid': '',
        'left-mid': '',
        'mid-mid': '',
        'right-mid': ''
      }
    };
    table_1 = new Table(options);
    width = 8;
    for (idx = j = 0, len1 = counters.length; j < len1; idx = ++j) {
      counter = counters[idx];
      ({key, name, tests, fails} = counter);
      passes = tests - fails;
      passes_percentage = `${(passes / tests * 100).toFixed(2)} %`;
      fails_percentage = `${(fails / tests * 100).toFixed(2)} %`;
      table_1.push([TRM.grey(idx + 1), TRM.gold(key), TRM.gold(name), TRM.blue(tests), TRM.green(TEXT.flush_right(passes, width)), TRM.green(TEXT.flush_right(passes_percentage, width)), TRM.red(TEXT.flush_right(fails, width)), TRM.red(TEXT.flush_right(fails_percentage, width))]);
    }
    //.........................................................................................................
    headers = [''];
    imp_keys = (function() {
      var k, len2, results;
      results = [];
      for (k = 0, len2 = counters.length; k < len2; k++) {
        counter = counters[k];
        results.push(counter['key']);
      }
      return results;
    })();
    headers.push.apply(headers, imp_keys);
    options = {
      head: headers,
      chars: {
        'top': '',
        'top-mid': '',
        'top-left': '',
        'top-right': '',
        'bottom': '',
        'bottom-mid': '',
        'bottom-left': '',
        'bottom-right': '',
        'left': '',
        'left-mid': '',
        'mid': '',
        'mid-mid': '',
        'right': '',
        'right-mid': '',
        'middle': ''
      }
    };
    table_2 = new Table(options);
    for (test_name in results_by_test_name) {
      success_by_imp_key = results_by_test_name[test_name];
      if (test_name.length > 50) {
        test_name = test_name.slice(0, 50) + '⋯';
      }
      row = [test_name];
      for (k = 0, len2 = imp_keys.length; k < len2; k++) {
        imp_key = imp_keys[k];
        if (success_by_imp_key[imp_key]) {
          row.push(TRM.green('◌'));
        } else {
          row.push(TRM.red('▼'));
        }
      }
      table_2.push(row);
    }
    //.........................................................................................................
    log('\n\n' + table_1.toString());
    help("Figures for implementations marked with an `!` (exclamation mark)");
    help("should be treated with care as their test setup is probably not correct.");
    //.........................................................................................................
    log('\n\n' + table_2.toString());
    //.........................................................................................................
    if (minus_points.length > 0) {
      options = {
        head: ['key', 'test', 'reason'],
        chars: {
          'mid': '',
          'left-mid': '',
          'mid-mid': '',
          'right-mid': ''
        }
      };
      table_3 = new Table(options);
      for (l = 0, len3 = minus_points.length; l < len3; l++) {
        [imp_key, test_name, message] = minus_points[l];
        table_3.push([TRM.gold(imp_key), test_name, TRM.red(message)]);
      }
      log('\n' + (TRM.blue('Minus Points:\n')) + table_3.toString());
    }
    //.........................................................................................................
    return null;
  };

  //###########################################################################################################
  if (module.parent == null) {
    this.main();
  }

}).call(this);

//# sourceMappingURL=main.js.map