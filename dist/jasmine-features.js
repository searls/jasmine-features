(function() {
  var buildErrors, buildResults,
    __hasProp = Object.prototype.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

  jasmine || (jasmine = {});

  jasmine.features || (jasmine.features = {});

  jasmine.features.dsl = function() {
    var o$;
    o$ = $;
    return {
      within: function(selector, action) {
        o$ = function(s) {
          return $(s, selector);
        };
        action();
        return o$ = $;
      },
      click: function(selector) {
        expect(selector).toBeAttached();
        return o$(selector).trigger('click');
      },
      fillIn: function(name, options) {
        var $input;
        $input = o$(":input[name=" + name + "]");
        expect($input).toBeAttached();
        switch ($input.attr('type')) {
          case "checkbox":
            check(name, options["with"]);
            return expect($input).toBeChecked(options["with"]);
          default:
            $input.val(options["with"]).trigger('change');
            return expect($input).toHaveValue(options["with"]);
        }
      },
      check: function(name, doCheckIt) {
        var $checkbox;
        if (doCheckIt == null) doCheckIt = true;
        $checkbox = o$(":checkbox[name=" + name + "]");
        return $checkbox.attr('checked', doCheckIt).trigger('change');
      },
      uncheck: function(name) {
        var $checkbox;
        $checkbox = o$(":checkbox[name=" + name + "]");
        return $checkbox.attr('checked', false).trigger('change');
      },
      drag: function(selector, options) {
        var $from, $to, delta;
        $from = o$(selector);
        $to = o$(options.to);
        delta = _({
          dx: 0,
          dy: 0
        }).chain().tap(function(delta) {
          var offset;
          offset = $from.offset();
          delta.dx -= offset.left;
          return delta.dy -= offset.top;
        }).tap(function(delta) {
          var offset;
          offset = $to.offset();
          delta.dx += offset.left;
          return delta.dy += offset.top;
        }).value();
        return $from.simulate('drag', delta);
      }
    };
  };

  _(window).extend(jasmine.features.dsl());

  jasmine || (jasmine = {});

  jasmine.features || (jasmine.features = {});

  jasmine.features.FeatureReporter = (function(_super) {

    __extends(FeatureReporter, _super);

    function FeatureReporter(whenDone) {
      FeatureReporter.__super__.constructor.call(this, arguments);
      this.whenDone = whenDone;
    }

    FeatureReporter.prototype.reportRunnerResults = function(runner) {
      FeatureReporter.__super__.reportRunnerResults.apply(this, arguments);
      return this.whenDone.call(this, this, runner);
    };

    return FeatureReporter;

  })(jasmine.JsApiReporter);

  jasmine.features.Feature = function(name, suite) {
    var _base;
    return ((_base = jasmine.features).queue || (_base.queue = [])).push({
      name: name,
      suite: suite
    });
  };

  jasmine.features.run = function() {
    var reporter;
    if ($('#jasmine_features_results').length === 0) {
      $('<div id="jasmine_features_results"></div>').appendTo('body').removeClass();
    }
    _(jasmine.features.queue).each(function(feature) {
      return describe(feature.name, feature.suite);
    });
    reporter = new jasmine.features.FeatureReporter(function(reporter) {
      var results;
      results = buildResults(reporter.results());
      $('#jasmine_features_results').html(results.message).addClass('finished').toggleClass('passed', results.failed === 0).append("<pre>" + results.errors + "</pre>");
      return typeof console !== "undefined" && console !== null ? typeof console.log === "function" ? console.log(results.message, results, reporter.results()) : void 0 : void 0;
    });
    jasmine.getEnv().reporter.subReporters_ = [reporter];
    jasmine.getEnv().execute();
    return reporter;
  };

  buildResults = function(results) {
    return _({
      passed: 0,
      failed: 0
    }).chain().tap(function(score) {
      return _(results).each(function(r) {
        return score[r.result] += 1;
      });
    }).tap(function(score) {
      return score.message = "Results: " + score.passed + " passed, " + score.failed + " failed";
    }).tap(function(score) {
      return score.errors = buildErrors(results);
    }).value();
  };

  buildErrors = function(results) {
    return _(results).chain().pluck('messages').flatten().filter(function(r) {
      return !r.passed();
    }).reduce(function(memo, result) {
      return "" + memo + "\n" + (result.toString());
    }, '').value();
  };

  window.Feature = jasmine.features.Feature;

}).call(this);
