
/*
jasmine-features 0.0.1

A toolkit for writing functional/integrated tests with Jasmine in JavaScript

site: https://github.com/searls/jasmine-features
*/

(function() {
  var buildErrors, buildResults,
    __hasProp = Object.prototype.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

  jasmine || (jasmine = {});

  jasmine.features || (jasmine.features = {});

  jasmine.features.addDsl = function($) {
    var dsl, find, o$;
    o$ = $;
    find = function(nameOrSelector, type) {
      var $r;
      if (type == null) type = ":input";
      $r = o$("" + type + "[name=" + nameOrSelector + "]");
      if ($r.length === 0) $r = o$(nameOrSelector);
      return $r;
    };
    dsl = {
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
        $input = find(name);
        expect($input).toBeAttached();
        switch ($input.attr('type')) {
          case "checkbox":
            return check(name, options["with"]);
          default:
            $input.val(options["with"]).trigger('change');
            return expect($input.val()).toEqual(options["with"]);
        }
      },
      check: function(name, doCheckIt) {
        var $checkbox;
        if (doCheckIt == null) doCheckIt = true;
        $checkbox = find(name, ":checkbox");
        $checkbox.attr('checked', doCheckIt).trigger('change');
        return expect($checkbox.is(':checked')).toBe(doCheckIt);
      },
      uncheck: function(name) {
        return dsl.check(name, false);
      },
      drag: function(selector, options) {
        var $from, $to;
        $from = o$(selector);
        $to = o$(options.to);
        return $from.simulate('drag', {
          dx: $to.offset().left - $from.offset().left,
          dy: $to.offset().top - $from.offset().top
        });
      }
    };
    _(window).extend(dsl);
    return dsl;
  };

  /*
  jquery.simulate - simulate browser mouse and keyboard events
  
  Copyright 2011, AUTHORS.txt (http://jqueryui.com/about)
  Dual licensed under the MIT or GPL Version 2 licenses.
  http://jquery.org/license
  */

  jasmine || (jasmine = {});

  jasmine.features || (jasmine.features = {});

  jasmine.features.addSimulate = function($) {
    $.fn.extend({
      simulate: function(type, options) {
        return this.each(function() {
          var opt;
          opt = $.extend({}, $.simulate.defaults, options);
          return new $.simulate(this, type, opt);
        });
      }
    });
    $.simulate = function(el, type, options) {
      this.target = el;
      this.options = options;
      if (type === "drag") {
        return this[type].apply(this, [this.target, options]);
      } else if (type === "focus" || type === "blur") {
        return this[type]();
      } else {
        return this.simulateEvent(el, type, options);
      }
    };
    $.extend($.simulate.prototype, {
      simulateEvent: function(el, type, options) {
        var evt;
        evt = this.createEvent(type, options);
        this.dispatchEvent(el, type, evt, options);
        return evt;
      },
      createEvent: function(type, options) {
        if (/^mouse(over|out|down|up|move)|(dbl)?click$/.test(type)) {
          return this.mouseEvent(type, options);
        } else {
          if (/^key(up|down|press)$/.test(type)) {
            return this.keyboardEvent(type, options);
          }
        }
      },
      mouseEvent: function(type, options) {
        var body, doc, e, eventDoc, evt, relatedTarget;
        e = $.extend({
          bubbles: true,
          cancelable: type !== "mousemove",
          view: window,
          detail: 0,
          screenX: 0,
          screenY: 0,
          clientX: 0,
          clientY: 0,
          ctrlKey: false,
          altKey: false,
          shiftKey: false,
          metaKey: false,
          button: 0,
          relatedTarget: void 0
        }, options);
        relatedTarget = $(e.relatedTarget)[0];
        if ($.isFunction(document.createEvent)) {
          evt = document.createEvent("MouseEvents");
          evt.initMouseEvent(type, e.bubbles, e.cancelable, e.view, e.detail, e.screenX, e.screenY, e.clientX, e.clientY, e.ctrlKey, e.altKey, e.shiftKey, e.metaKey, e.button, e.relatedTarget || document.body.parentNode);
          if (evt.pageX === 0 && evt.pageY === 0 && Object.defineProperty) {
            eventDoc = evt.relatedTarget.ownerDocument || document;
            doc = eventDoc.documentElement;
            body = eventDoc.body;
            Object.defineProperty(evt, "pageX", {
              get: function() {
                return e.clientX + (doc && doc.scrollLeft || body && body.scrollLeft || 0) - (doc && doc.clientLeft || body && body.clientLeft || 0);
              }
            });
            Object.defineProperty(evt, "pageY", {
              get: function() {
                return e.clientY + (doc && doc.scrollTop || body && body.scrollTop || 0) - (doc && doc.clientTop || body && body.clientTop || 0);
              }
            });
          }
        } else if (document.createEventObject) {
          evt = document.createEventObject();
          $.extend(evt, e);
          evt.button = {
            0: 1,
            1: 4,
            2: 2
          };
          [evt.button] || evt.button;
        }
        return evt;
      },
      keyboardEvent: function(type, options) {
        var e, evt;
        e = $.extend({
          bubbles: true,
          cancelable: true,
          view: window,
          ctrlKey: false,
          altKey: false,
          shiftKey: false,
          metaKey: false,
          keyCode: 0,
          charCode: void 0
        }, options);
        if ($.isFunction(document.createEvent)) {
          try {
            evt = document.createEvent("KeyEvents");
            evt.initKeyEvent(type, e.bubbles, e.cancelable, e.view, e.ctrlKey, e.altKey, e.shiftKey, e.metaKey, e.keyCode, e.charCode);
          } catch (err) {
            evt = document.createEvent("Events");
            evt.initEvent(type, e.bubbles, e.cancelable);
            $.extend(evt, {
              view: e.view,
              ctrlKey: e.ctrlKey,
              altKey: e.altKey,
              shiftKey: e.shiftKey,
              metaKey: e.metaKey,
              keyCode: e.keyCode,
              charCode: e.charCode
            });
          }
        } else if (document.createEventObject) {
          evt = document.createEventObject();
          $.extend(evt, e);
        }
        if ($.browser.msie || $.browser.opera) {
          evt.keyCode = (e.charCode > 0 ? e.charCode : e.keyCode);
          evt.charCode = void 0;
        }
        return evt;
      },
      dispatchEvent: function(el, type, evt) {
        if (el.dispatchEvent) {
          el.dispatchEvent(evt);
        } else {
          if (el.fireEvent) el.fireEvent("on" + type, evt);
        }
        return evt;
      },
      drag: function(el) {
        var center, coord, dx, dy, options, self, target, x, y;
        self = this;
        center = this.findCenter(this.target);
        options = this.options;
        x = Math.floor(center.x);
        y = Math.floor(center.y);
        dx = options.dx || 0;
        dy = options.dy || 0;
        target = this.target;
        coord = {
          clientX: x,
          clientY: y
        };
        this.simulateEvent(target, "mousedown", coord);
        coord = {
          clientX: x + 1,
          clientY: y + 1
        };
        this.simulateEvent(document, "mousemove", coord);
        coord = {
          clientX: x + dx,
          clientY: y + dy
        };
        this.simulateEvent(document, "mousemove", coord);
        this.simulateEvent(document, "mousemove", coord);
        this.simulateEvent(target, "mouseup", coord);
        return this.simulateEvent(target, "click", coord);
      },
      findCenter: function(el) {
        var d, o;
        el = $(this.target);
        o = el.offset();
        d = $(document);
        return {
          x: o.left + el.outerWidth() / 2 - d.scrollLeft(),
          y: o.top + el.outerHeight() / 2 - d.scrollTop()
        };
      },
      focus: function() {
        var element, focusinEvent, trigger, triggered;
        trigger = function() {
          var triggered;
          return triggered = true;
        };
        triggered = false;
        element = $(this.target);
        element.bind("focus", trigger);
        element[0].focus();
        if (!triggered) {
          focusinEvent = $.Event("focusin");
          focusinEvent.preventDefault();
          element.trigger(focusinEvent);
          element.triggerHandler("focus");
        }
        return element.unbind("focus", trigger);
      },
      blur: function() {
        var element, trigger, triggered;
        trigger = function() {
          var triggered;
          return triggered = true;
        };
        triggered = false;
        element = $(this.target);
        element.bind("blur", trigger);
        element[0].blur();
        return setTimeout((function() {
          var focusoutEvent;
          if (element[0].ownerDocument.activeElement === element[0]) {
            element[0].ownerDocument.body.focus();
          }
          if (!triggered) {
            focusoutEvent = $.Event("focusout");
            focusoutEvent.preventDefault();
            element.trigger(focusoutEvent);
            element.triggerHandler("blur");
          }
          return element.unbind("blur", trigger);
        }), 1);
      }
    });
    return $.extend($.simulate, {
      defaults: {
        speed: "sync"
      },
      VK_TAB: 9,
      VK_ENTER: 13,
      VK_ESC: 27,
      VK_PGUP: 33,
      VK_PGDN: 34,
      VK_END: 35,
      VK_HOME: 36,
      VK_LEFT: 37,
      VK_UP: 38,
      VK_RIGHT: 39,
      VK_DOWN: 40
    });
  };

  beforeEach(function() {
    return this.addMatchers({
      toBeAttached: function(within) {
        var $, $el, $within, isContainedWithin;
        if (within == null) within = 'body';
        $ = jasmine.features.$;
        $el = $(this.actual);
        $within = $(within);
        isContainedWithin = $.contains($within[0], $el[0]);
        this.message = function() {
          return "Expected '" + $el.selector + "' to be contained within '" + $within.selector + "'";
        };
        return isContainedWithin;
      }
    });
  });

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

  jasmine.features.run = function(jazmine) {
    var $, $results, reporter;
    if (jazmine == null) jazmine = jasmine;
    $ = jazmine.features.$;
    $results = $('#jasmine_features_results');
    if ($results.length === 0) {
      $results = $('<div id="jasmine_features_results"></div>').appendTo('body');
    }
    $results.removeClass();
    _(jazmine.features.queue).each(function(feature) {
      return describe(feature.name, feature.suite);
    });
    reporter = new jazmine.features.FeatureReporter(function(reporter) {
      var results;
      results = buildResults(reporter.results());
      $('#jasmine_features_results').html(results.message).addClass('finished').toggleClass('passed', results.failed === 0).append("<pre>" + results.errors + "</pre>");
      return typeof console !== "undefined" && console !== null ? typeof console.log === "function" ? console.log(results.message, results, reporter.results()) : void 0 : void 0;
    });
    jazmine.getEnv().reporter.subReporters_ = [reporter];
    jazmine.getEnv().execute();
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

  jasmine || (jasmine = {});

  jasmine.features || (jasmine.features = {});

  jasmine.features.using = function(config) {
    if (config == null) {
      config = {
        jQuery: $
      };
    }
    jasmine.features.$ = config.jQuery;
    jasmine.features.addDsl(jasmine.features.$);
    if (jasmine.features.$.fn.simulate == null) {
      return jasmine.features.addSimulate(jasmine.features.$);
    }
  };

  /*
  Kick everything off with default dependencies.
  */

  jasmine.features.using();

}).call(this);
