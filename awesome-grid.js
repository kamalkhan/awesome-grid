
/*
AwesomeGrid v2.0.0
https://github.com/kamalkhan/awesome-grid
A minimalist javascript library that allows you to display a responsive grid
layout stacked on top of each other into rows and columns.
The MIT License (MIT)
Copyright (c) 2015 M. Kamal Khan <shout@bhittani.com>
 */

(function() {
  var AwesomeGrid,
    indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  AwesomeGrid = (function() {
    AwesomeGrid.prototype.__els = [];

    AwesomeGrid.prototype.__kids = [];

    AwesomeGrid.prototype.__watch = null;

    AwesomeGrid.prototype.__adopt = false;

    AwesomeGrid.prototype.__width = null;

    AwesomeGrid.prototype.__rows = [0];

    AwesomeGrid.prototype.__columns = [0];

    AwesomeGrid.prototype.__scroll = {
      watch: null,
      fn: null
    };

    AwesomeGrid.prototype.__devices = null;

    AwesomeGrid.prototype.__current = null;

    AwesomeGrid.prototype.__screen = null;

    AwesomeGrid.prototype.__small = null;

    AwesomeGrid.prototype.__mobile = null;

    AwesomeGrid.prototype.__tablet = null;

    AwesomeGrid.prototype.__desktop = null;

    AwesomeGrid.prototype.__tv = null;

    AwesomeGrid.prototype.__events = [];

    AwesomeGrid.prototype.__context = null;

    AwesomeGrid.options = {
      context: 'window',
      mobile: 420,
      tablet: 768,
      desktop: 992,
      tv: 1200
    };

    function AwesomeGrid(selector, args, isel) {
      var child, e, el, i, j, len, len1, ref, ref1;
      if (args == null) {
        args = AwesomeGrid.options;
      }
      if (isel == null) {
        isel = false;
      }
      this.__els = isel ? [selector] : document.querySelectorAll(selector);
      if (!this.__els) {
        return this;
      }
      ref = this.__els;
      for (e = i = 0, len = ref.length; i < len; e = ++i) {
        el = ref[e];
        el.style.position = 'relative';
        this.__kids[e] = el.children.length;
        ref1 = el.children;
        for (j = 0, len1 = ref1.length; j < len1; j++) {
          child = ref1[j];
          child.style.position = 'absolute';
          child.style.margin = 0;
        }
      }
      this._reset(this._merge(AwesomeGrid.options, args));
      this._respond();
      this._docontext();
      this._doresize();
      this._doscroll();
    }

    AwesomeGrid.prototype._make = function(name, screen) {
      return {
        device: name,
        screen: screen,
        columns: 1,
        gutters: {
          column: 0,
          row: 0,
          force: false
        }
      };
    };

    AwesomeGrid.prototype._reset = function(options) {
      this.__context = options.context;
      this.__small = this._make('small', 0);
      this.__mobile = this._make('mobile', options.mobile);
      this.__tablet = this._make('tablet', options.tablet);
      this.__desktop = this._make('desktop', options.desktop);
      this.__tv = this._make('tv', options.tv);
      this.__columns = [0];
      this.__devices = ['small'];
      return this.__current = {};
    };

    AwesomeGrid.prototype._device = function(which, columns, gutters, force) {
      var device, x;
      if (!this.__els) {
        return this;
      }
      if (columns === false) {
        this.__devices = (function() {
          var i, len, ref, results;
          ref = this.__devices;
          results = [];
          for (i = 0, len = ref.length; i < len; i++) {
            x = ref[i];
            if (x !== which) {
              results.push(x);
            }
          }
          return results;
        }).call(this);
      } else {
        device = (function() {
          switch (false) {
            case which !== 'tv':
              return this.__tv;
            case which !== 'desktop':
              return this.__desktop;
            case which !== 'tablet':
              return this.__tablet;
            case which !== 'mobile':
              return this.__mobile;
          }
        }).call(this);
        device.columns = columns;
        this.gutters(gutters, force, device);
        if (indexOf.call(this.__devices, which) < 0) {
          this.__devices.push(which);
        }
      }
      return this._respond();
    };

    AwesomeGrid.prototype._respond = function(size) {
      var el, i, len, ref, respond, results;
      if (size == null) {
        size = window.innerWidth;
      }
      respond = (function(_this) {
        return function(size, els) {
          var device;
          _this.__screen = (function() {
            switch (false) {
              case !(size >= this.__tv.screen):
                return this.__tv;
              case !(size >= this.__desktop.screen):
                return this.__desktop;
              case !(size >= this.__tablet.screen):
                return this.__tablet;
              case !(size >= this.__mobile.screen):
                return this.__mobile;
              default:
                return this.__small;
            }
          }).call(_this);
          device = _this.__current.device;
          _this.__current = (function() {
            var ref, ref1, ref2, ref3;
            switch (false) {
              case ref = this.__screen.device, indexOf.call(this.__devices, ref) < 0:
                return this.__screen;
              case !(this.__screen.device === 'tv' && indexOf.call(this.__devices, 'tv') >= 0):
                return this.__tv;
              case !(((ref1 = this.__screen.device) === 'tv' || ref1 === 'desktop') && indexOf.call(this.__devices, 'desktop') >= 0):
                return this.__desktop;
              case !(((ref2 = this.__screen.device) === 'tv' || ref2 === 'desktop' || ref2 === 'tablet') && indexOf.call(this.__devices, 'tablet') >= 0):
                return this.__tablet;
              case !(((ref3 = this.__screen.device) === 'tv' || ref3 === 'desktop' || ref3 === 'tablet' || ref3 === 'mobile') && indexOf.call(this.__devices, 'mobile') >= 0):
                return this.__mobile;
              default:
                return this.__small;
            }
          }).call(_this);
          if (_this.__current.device !== device) {
            _this._emit('grid:device', null, [_this.__current.device, device]);
          }
          return _this.grid(false, els);
        };
      })(this);
      if (this.__context === 'self') {
        ref = this.__els;
        results = [];
        for (i = 0, len = ref.length; i < len; i++) {
          el = ref[i];
          results.push(respond(el.offsetWidth, [el]));
        }
        return results;
      } else {
        return respond(size, this.__els);
      }
    };

    AwesomeGrid.prototype._docontext = function() {
      if (this.__context !== 'self') {
        return null;
      }
      this._respond();
      return this.__watch = setTimeout((function(_this) {
        return function() {
          return _this._docontext();
        };
      })(this), 220);
    };

    AwesomeGrid.prototype._doresize = function() {
      var timeout;
      if (this.__context === 'self') {
        return null;
      }
      timeout = null;
      return window.addEventListener('resize', (function(_this) {
        return function() {
          if (timeout == null) {
            return timeout = setTimeout(function() {
              timeout = null;
              return _this._respond();
            }, 66);
          }
        };
      })(this), true);
    };

    AwesomeGrid.prototype._grow = function() {
      var e, el, height, i, len, ref, results, style, x;
      if ((this.__scroll.fn == null) || (this.__scroll.watch != null)) {
        return this;
      }
      ref = this.__els;
      results = [];
      for (e = i = 0, len = ref.length; i < len; e = ++i) {
        el = ref[e];
        style = getComputedStyle(el);
        height = parseInt(style.getPropertyValue('height'));

        /* should we use this?
        offsetTop = ((el) ->
            box = el.getBoundingClientRect()
            body = document.body;
            docEl = document.documentElement;
            scrollTop = window.pageYOffset or docEl.scrollTop or body.scrollTop
            scrollLeft = window.pageXOffset or docEl.scrollLeft or body.scrollLeft
            clientTop = docEl.clientTop or body.clientTop or 0
            clientLeft = docEl.clientLeft or body.clientLeft or 0
            top  = box.top +  scrollTop - clientTop
            #left = box.left + scrollLeft - clientLeft
            Math.round top
        ) el
         */
        if (document.body.scrollTop >= height + el.offsetTop - window.innerHeight) {
          this._emit('grid:scrolled', el, [this.__current.device]);
          this.__scroll.watch = true;
          x = e;
          results.push(this.__scroll.fn((function(_this) {
            return function() {
              var child, children, j, len1, tag, tel;
              if (!arguments.length || !arguments[0]) {
                _this.__scroll.watch = null;
                return _this;
              }
              if (arguments[0].constructor === Array) {
                children = arguments[0];
              } else {
                children = arguments;
              }
              for (j = 0, len1 = children.length; j < len1; j++) {
                child = children[j];
                tag = el.children[0].tagName.toLowerCase();
                tel = document.createElement(tag);
                tel.innerHTML = child;
                el.appendChild(tel);
              }
              _this._sync(x);
              return _this.__scroll.watch = null;
            };
          })(this)));
        } else {
          results.push(void 0);
        }
      }
      return results;
    };

    AwesomeGrid.prototype._doscroll = function() {
      var timeout;
      timeout = null;
      return window.addEventListener('scroll', (function(_this) {
        return function() {
          if (timeout == null) {
            return timeout = setTimeout(function() {
              timeout = null;
              return _this._grow();
            }, 66);
          }
        };
      })(this), true);
    };

    AwesomeGrid.prototype._isInt = function(n) {
      return (n != null) && (!isNaN(n)) && ((function(z) {
        return (z | 0) === z;
      })(parseFloat(n)));
    };

    AwesomeGrid.prototype._clone = function(obj) {
      var key, temp;
      if ((obj == null) || typeof obj !== 'object') {
        return obj;
      }
      temp = {};
      for (key in obj) {
        temp[key] = this._clone(obj[key]);
      }
      return temp;
    };

    AwesomeGrid.prototype._merge = function(obj1, obj2) {
      var key, obj, val;
      obj = this._clone(obj1);
      for (key in obj2) {
        val = obj2[key];
        obj[key] = val;
      }
      return obj;
    };

    AwesomeGrid.prototype._x = function(el, max) {
      var size, x;
      size = 1;
      x = el.getAttribute('data-ag-x');
      if (this._isInt(x)) {
        size = parseInt(x);
      }
      if (size > max) {
        return max;
      } else if (size < 1) {
        return 1;
      } else {
        return size;
      }
    };

    AwesomeGrid.prototype._spacing = function(el) {
      var s, style;
      s = {};
      style = getComputedStyle(el);
      s.pl = parseInt(style.paddingLeft);
      s.pr = parseInt(style.paddingRight);
      s.bl = parseInt(style.getPropertyValue('border-left-width'));
      s.br = parseInt(style.getPropertyValue('border-right-width'));
      return s;
    };

    AwesomeGrid.prototype._giant = function(from, to) {
      var g;
      if (from == null) {
        from = -1;
      }
      if (to == null) {
        to = -1;
      }
      if (from === to && from > -1) {
        return from;
      }
      if (from === to && from === -1) {
        return this.__columns.indexOf(Math.max.apply(null, this.__columns));
      }
      g = this.__columns.slice(from, +to + 1 || 9e9);
      return from + g.indexOf(Math.max.apply(null, g));
    };

    AwesomeGrid.prototype._midget = function(from, to) {
      var m;
      if (from == null) {
        from = -1;
      }
      if (to == null) {
        to = -1;
      }
      if (from === to && from > -1) {
        return from;
      }
      if (from === to && from === -1) {
        return this.__columns.indexOf(Math.min.apply(null, this.__columns));
      }
      m = this.__columns.slice(from, +to + 1 || 9e9);
      return from + m.indexOf(Math.min.apply(null, m));
    };

    AwesomeGrid.prototype._clearClass = function(el) {
      var className;
      className = el.className.replace(/(?:^|\s)(ag-col-.+?)|(ag-row-.+?)(?!\S)/img, '');
      if (className !== '') {
        className = className.trim() + ' ';
      }
      return className;
    };

    AwesomeGrid.prototype._emit = function(event, context, args) {
      var ev, i, len, ref, results;
      ref = this.__events;
      results = [];
      for (i = 0, len = ref.length; i < len; i++) {
        ev = ref[i];
        if (ev[0] === event) {
          results.push(ev[1].apply(context, [event].concat(args)));
        } else {
          results.push(void 0);
        }
      }
      return results;
    };

    AwesomeGrid.prototype._gutters = function(obj) {
      var gutters;
      if (!this.__els || (obj == null)) {
        return this;
      }
      if (this._isInt(obj)) {
        return {
          column: parseInt(obj),
          row: parseInt(obj)
        };
      }
      gutters = {
        column: this.__small.gutters.column,
        row: this.__small.gutters.row
      };
      if (this._isInt(obj.column)) {
        gutters.column = parseInt(obj.column);
      }
      if (this._isInt(obj.row)) {
        gutters.row = parseInt(obj.row);
      }
      return gutters;
    };

    AwesomeGrid.prototype._grid = function(pel, el, columns, dynamic) {
      var c, ci, cols, i, left, ref, ref1, ref2, rows, s, size, space, tallest, tr, w;
      if (dynamic == null) {
        dynamic = false;
      }
      if (dynamic) {
        el.style.position = 'absolute';
        el.style.margin = 0;
      }
      c = this._midget();
      size = this._x(el, columns);
      if ((c + size) > columns) {
        c -= c + size - columns;
      }
      left = (c * this.__width) + (c * this.__current.gutters.column);
      w = (size * this.__width) + ((size - 1) * this.__current.gutters.column);
      s = this._spacing(el);
      tallest = this._giant(c, c + size - 1);
      el.style.width = (w - s.pl - s.pr - s.bl - s.br) + "px";
      el.style.top = this.__columns[tallest] + "px";
      el.style.left = left + "px";
      el.className = this._clearClass(el);
      this.__columns[tallest] = this.__columns[tallest] + el.offsetHeight + this.__current.gutters.row;
      space = '';
      tr = [];
      cols = [];
      rows = [];
      for (ci = i = ref = c, ref1 = c + size - 1; ref <= ref1 ? i <= ref1 : i >= ref1; ci = ref <= ref1 ? ++i : --i) {
        el.className += space + "ag-col-" + (ci + 1);
        if (ref2 = this.__rows[ci], indexOf.call(tr, ref2) < 0) {
          el.className += " ag-row-" + (this.__rows[ci] + 1);
        }
        tr.push(this.__rows[ci]);
        this.__rows[ci]++;
        space = ' ';
        this.__columns[ci] = this.__columns[tallest];
        cols.push(ci + 1);
        rows.push(this.__rows[ci]);
      }
      pel.style.height = this.__columns[this._giant()] + "px";
      return this._emit('item:stacked', el, [pel, rows, cols, this.__current.device]);
    };

    AwesomeGrid.prototype._sync = function(e) {
      var c, children, i, kids, ref, ref1, results;
      kids = this.__kids[e];
      children = this.__els[e].children.length;
      if (children > kids) {
        this.__kids[e] = children;
        results = [];
        for (c = i = ref = kids, ref1 = children; ref <= ref1 ? i < ref1 : i > ref1; c = ref <= ref1 ? ++i : --i) {
          results.push(this._grid(this.__els[e], this.__els[e].children[c], this.__columns.length, true));
        }
        return results;
      }
    };

    AwesomeGrid.prototype.gutters = function(obj, force, device) {
      var g;
      if (force == null) {
        force = false;
      }
      if (device == null) {
        device = this.__small;
      }
      if (!this.__els) {
        return this;
      }
      g = this._gutters(obj);
      device.gutters = {
        column: g.column,
        row: g.row,
        force: force ? true : false
      };
      return this;
    };

    AwesomeGrid.prototype.grid = function(columns, els) {
      var child, device, el, gutters, i, j, len, len1, ref;
      if (els == null) {
        els = this.__els;
      }
      if (!this.__els) {
        return this;
      }
      if (columns) {
        this.__small.columns = columns;
      }
      device = this.__current;
      columns = device.columns;
      if (!this._isInt(columns)) {
        return this;
      }
      for (i = 0, len = els.length; i < len; i++) {
        el = els[i];
        this.__columns = (function() {
          var j, ref, results;
          results = [];
          for (j = 1, ref = columns; 1 <= ref ? j <= ref : j >= ref; 1 <= ref ? j++ : j--) {
            results.push(0);
          }
          return results;
        })();
        this.__rows = this.__columns.slice(0);
        gutters = this._clone(device.gutters);
        if (!gutters.force) {
          this.gutters((el.getAttribute('data-ag-gutters')) || {
            column: el.getAttribute('data-ag-gutters-column'),
            row: el.getAttribute('data-ag-gutters-row')
          }, device);
        }
        this.__width = (el.offsetWidth - ((columns - 1) * device.gutters.column)) / columns;
        ref = el.children;
        for (j = 0, len1 = ref.length; j < len1; j++) {
          child = ref[j];
          this._grid(el, child, columns);
        }
        device.gutters = gutters;
        this._emit('grid:done', el, [device.device]);
      }
      return this;
    };

    AwesomeGrid.prototype.apply = function() {
      var e, i, kids, len, ref;
      ref = this.__kids;
      for (e = i = 0, len = ref.length; i < len; e = ++i) {
        kids = ref[e];
        this._sync(e);
      }
      return this;
    };

    AwesomeGrid.prototype.scroll = function(fn) {
      if (fn === false) {
        this.__scroll.fn = null;
        this.__scroll.watch = null;
        return this;
      }
      if (typeof fn !== 'function') {
        return this;
      }
      this.__scroll.fn = fn;
      return this;
    };

    AwesomeGrid.prototype.mobile = function(columns, gutters, force) {
      if (gutters == null) {
        gutters = {};
      }
      if (force == null) {
        force = false;
      }
      this._device('mobile', columns, gutters, force);
      return this;
    };

    AwesomeGrid.prototype.tablet = function(columns, gutters, force) {
      if (gutters == null) {
        gutters = {};
      }
      if (force == null) {
        force = false;
      }
      this._device('tablet', columns, gutters, force);
      return this;
    };

    AwesomeGrid.prototype.desktop = function(columns, gutters, force) {
      if (gutters == null) {
        gutters = {};
      }
      if (force == null) {
        force = false;
      }
      this._device('desktop', columns, gutters, force);
      return this;
    };

    AwesomeGrid.prototype.tv = function(columns, gutters, force) {
      if (gutters == null) {
        gutters = {};
      }
      if (force == null) {
        force = false;
      }
      this._device('tv', columns, gutters, force);
      return this;
    };

    AwesomeGrid.prototype.on = function(event, fn) {
      if (typeof fn !== 'function') {
        return this;
      }
      this.__events.push([event, fn]);
      return this;
    };

    AwesomeGrid.prototype.off = function(event, fn) {
      var e, ev, events, i, len, ref;
      if (fn == null) {
        fn = null;
      }
      if (event == null) {
        this.__events = [];
        return this;
      }
      events = [];
      ref = this.__events;
      for (e = i = 0, len = ref.length; i < len; e = ++i) {
        ev = ref[e];
        if (ev[0] !== event || ((fn != null) && fn.toString() !== ev[1].toString())) {
          events.push(ev);
        }
      }
      this.__events = events;
      return this;
    };

    return AwesomeGrid;

  })();

  window.addEventListener('load', function() {
    var el, i, len, ref, results;
    ref = document.querySelectorAll('[data-awesome-grid]');
    results = [];
    for (i = 0, len = ref.length; i < len; i++) {
      el = ref[i];
      results.push((new AwesomeGrid(el, AwesomeGrid.options, true)).grid(el.getAttribute('data-awesome-grid')));
    }
    return results;
  }, true);

  if (typeof window !== "undefined" && window !== null) {
    window.AwesomeGrid = AwesomeGrid;
  }

  if ((typeof define === 'function') && define.amd) {
    define('AwesomeGrid', [], function() {
      return AwesomeGrid;
    });
  }

  if (typeof module !== "undefined" && module !== null ? module.exports : void 0) {
    module.exports = AwesomeGrid;
  }

}).call(this);
