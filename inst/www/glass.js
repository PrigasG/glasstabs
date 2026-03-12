/* glasstabs patched */
(function () {
  'use strict';

  function px(n) { return Math.round(n) + 'px'; }

  function centerOf(el, container) {
    var r = el.getBoundingClientRect();
    var cr = container.getBoundingClientRect();
    return {
      x: r.left + r.width / 2 - cr.left,
      y: r.top + r.height / 2 - cr.top,
      w: r.width,
      h: r.height
    };
  }

  function hasOwn(obj, key) {
    return Object.prototype.hasOwnProperty.call(obj, key);
  }

  function escapeHtml(x) {
    return String(x)
      .replace(/&/g, '&amp;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;')
      .replace(/"/g, '&quot;')
      .replace(/'/g, '&#39;');
  }

  function triggerShinyChange(el) {
    if (window.jQuery) {
      window.jQuery(el).trigger('change');
    }
  }

  /* ══════════════════════════════════════════════════════
     TAB ENGINE
  ══════════════════════════════════════════════════════ */
  function initTabs(navbar) {
    if (navbar._gtTabsInit) return;
    navbar._gtTabsInit = true;

    var ns = navbar.getAttribute('data-ns');

    var container = navbar.closest('.gt-container')
      || navbar.closest('.card-body')
      || navbar.closest('.box-body')
      || (navbar.parentElement && navbar.parentElement.parentElement)
      || navbar.parentElement;

    if (!container) return;

    var halo = container.querySelector('.gt-halo');
    var trf = container.querySelector('.gt-transfer');
    var links = Array.from(navbar.querySelectorAll('.gt-tab-link'));
    var order = links.map(function (l) { return l.getAttribute('data-value'); });
    var activeEl = links.find(function (l) { return l.classList.contains('active'); }) || links[0];

    if (!halo || !trf || links.length === 0 || !activeEl) return;

    var active = activeEl.getAttribute('data-value');

    var cs = getComputedStyle(container);
    if (cs.position === 'static') container.style.position = 'relative';

    function placeHalo(el, immediate, scale) {
      if (!el || !container.isConnected) return;
      var c = centerOf(el, container);
      var s = scale || 1;
      var w = Math.floor((c.w + 8) * s);
      var h = Math.floor((c.h + 4) * s);
      var br = (parseFloat(getComputedStyle(el).borderRadius) || 12) + 1;

      function set() {
        halo.style.left = c.x + 'px';
        halo.style.top = c.y + 'px';
        halo.style.width = w + 'px';
        halo.style.height = h + 'px';
        halo.style.borderRadius = br + 'px';
      }

      if (immediate) {
        halo.style.transition = 'none';
        set();
        halo.style.opacity = 0.80;
        void halo.offsetWidth;
        halo.style.transition = '';
      } else {
        set();
        halo.style.opacity = 0.92;
      }
    }

    function buildKF(cs2, fw, fh) {
      var f = [];
      var sc = Math.max(1, cs2.length - 1);

      for (var i = 0; i < cs2.length; i++) {
        var p = cs2[i];
        var off = i / sc;
        var nf = off >= 0.7;
        var w = nf ? Math.round(fw * (0.45 + (off - 0.7) / 0.3 * 0.55)) : 40;
        var h = nf ? Math.round(fh * (0.45 + (off - 0.7) / 0.3 * 0.55)) : 14;
        f.push({
          left: px(p.x),
          top: px(p.y),
          width: px(w),
          height: px(h),
          opacity: nf ? 0.80 : 0.60,
          offset: off
        });
      }

      var last = cs2[cs2.length - 1];
      f.push({
        left: px(last.x),
        top: px(last.y),
        width: px(fw),
        height: px(fh),
        opacity: 0,
        offset: 1
      });

      return f;
    }

    function animateTransfer(fromEl, toEl) {
      if (!fromEl || !toEl) return 200;

      var fi = order.indexOf(fromEl.getAttribute('data-value'));
      var ti = order.indexOf(toEl.getAttribute('data-value'));
      if (fi < 0 || ti < 0) return 200;

      var step = ti > fi ? 1 : -1;
      var pts = [];

      for (var i = fi; step > 0 ? i <= ti : i >= ti; i += step) {
        var link = navbar.querySelector('.gt-tab-link[data-value="' + order[i] + '"]');
        if (link) pts.push(centerOf(link, container));
      }

      if (pts.length === 0) return 200;

      var last = pts[pts.length - 1];
      var fw = Math.max(50, last.w);
      var fh = Math.max(22, last.h * 0.70);

      if (trf.getAnimations) {
        trf.getAnimations().forEach(function (a) { a.cancel(); });
      }

      var dur = 200 + Math.max(1, Math.abs(ti - fi)) * 55;

      trf.style.opacity = 0;
      trf.style.left = px(pts[0].x);
      trf.style.top = px(pts[0].y);
      trf.style.width = px(32);
      trf.style.height = px(11);

      trf.animate(buildKF(pts, fw, fh), {
        duration: dur,
        easing: 'cubic-bezier(.15,.9,.2,1)',
        fill: 'forwards'
      });

      trf.animate([
        { filter: 'blur(3px)', opacity: 0 },
        { filter: 'blur(2.4px)', opacity: 0.88, offset: 0.10 },
        { filter: 'blur(2.8px)', opacity: 0.72, offset: 0.78 },
        { filter: 'blur(7px)', opacity: 0, offset: 1 }
      ], {
        duration: dur,
        easing: 'linear',
        fill: 'forwards'
      });

      return dur;
    }

    function initHalo() {
      var el = navbar.querySelector('.gt-tab-link.active');
      if (!el) return;

      requestAnimationFrame(function () {
        requestAnimationFrame(function () {
          requestAnimationFrame(function () {
            placeHalo(el, true, 0.90);
            setTimeout(function () { placeHalo(el, false, 1.0); }, 80);
          });
        });
      });
    }

    initHalo();

    if (document.fonts && document.fonts.ready) {
      document.fonts.ready.then(initHalo).catch(function () {});
    }

    links.forEach(function (link) {
      link.addEventListener('click', function () {
        var target = link.getAttribute('data-value');
        if (target === active) return;

        var fromEl = navbar.querySelector('.gt-tab-link[data-value="' + active + '"]');
        var toEl = navbar.querySelector('.gt-tab-link[data-value="' + target + '"]');
        if (!toEl) return;

        links.forEach(function (t) { t.classList.remove('active'); });
        toEl.classList.add('active');

        if (fromEl) placeHalo(fromEl, true, 1.0);
        halo.style.opacity = '0.38';

        var dur = animateTransfer(fromEl, toEl);

        setTimeout(function () {
          var ap = container.querySelector('.gt-tab-pane.active');
          if (ap) ap.classList.remove('active');

          var next = document.getElementById(ns + '-pane-' + target);
          if (next) next.classList.add('active');

          active = target;

          if (window.Shiny) {
            Shiny.setInputValue(ns + '-active_tab', target, { priority: 'event' });
          }
        }, Math.max(100, dur * 0.50));

        setTimeout(function () {
          placeHalo(toEl, false, 0.90);
          setTimeout(function () { placeHalo(toEl, false, 1.0); }, 80);
        }, dur * 0.60);

        setTimeout(function () {
          placeHalo(toEl, true, 1.0);
          halo.classList.remove('gt-arrival-pulse');
          void halo.offsetWidth;
          halo.classList.add('gt-arrival-pulse');
        }, dur);
      });
    });

    if (!navbar._gtKeyHandler) {
      navbar._gtKeyHandler = function (e) {
        if (!container.contains(document.activeElement) &&
            document.activeElement !== document.body) {
          return;
        }

        var idx = order.indexOf(active);
        if (idx < 0) return;

        if (e.key === 'ArrowRight') {
          var right = navbar.querySelector('.gt-tab-link[data-value="' + order[(idx + 1) % order.length] + '"]');
          if (right) right.click();
        }

        if (e.key === 'ArrowLeft') {
          var left = navbar.querySelector('.gt-tab-link[data-value="' + order[(idx - 1 + order.length) % order.length] + '"]');
          if (left) left.click();
        }
      };
      document.addEventListener('keydown', navbar._gtKeyHandler);
    }

    if (!navbar._gtResizeHandler) {
      navbar._gtResizeHandler = function () {
        var activeLink = navbar.querySelector('.gt-tab-link[data-value="' + active + '"]');
        if (activeLink) placeHalo(activeLink, true, 1.0);
      };
      window.addEventListener('resize', navbar._gtResizeHandler);
    }
  }

  /* ══════════════════════════════════════════════════════
     SINGLE-SELECT ENGINE
  ══════════════════════════════════════════════════════ */
  function initGlassSelect(wrap) {
    if (wrap._gtSelectInit) return;
    wrap._gtSelectInit = true;

    var inputId = wrap.getAttribute('data-input-id');
    var placeholder = wrap.getAttribute('data-placeholder') || 'Select an option';

    var trigger = wrap.querySelector('.gt-gs-trigger');
    var dropdown = wrap.querySelector('.gt-gs-dropdown');
    var labelEl = wrap.querySelector('[id$="-label"]');
    var clearBtn = wrap.querySelector('.gt-gs-clear');
    var searchIn = wrap.querySelector('input[type="text"]');
    var optionsBox = wrap.querySelector('[id$="-options"]') || wrap;
    var STYLES = ['check-only', 'checkbox', 'filled'];
    var currentStyle = 'checkbox';

    STYLES.forEach(function (s) {
      if (wrap.classList.contains('style-' + s)) currentStyle = s;
    });

    if (!trigger || !dropdown || !labelEl) return;

    function optionEls() {
      return Array.from(wrap.querySelectorAll('.gt-gs-option'));
    }

    function selectedEl() {
      return wrap.querySelector('.gt-gs-option.selected');
    }

    function getValue() {
      var el = selectedEl();
      return el ? el.getAttribute('data-value') : null;
    }

    function updateLabel() {
      var el = selectedEl();
      labelEl.textContent = el ? el.querySelector('span').textContent : placeholder;
    }

    function notify() {
      triggerShinyChange(wrap);
      if (window.Shiny) {
        Shiny.setInputValue(inputId, getValue(), { priority: 'event' });
      }
    }

    function setValue(value, notifyShiny) {
      var found = false;
      var valueStr = (value === null || typeof value === 'undefined' || value === '') ? null : String(value);

      optionEls().forEach(function (opt) {
        var isSel = valueStr !== null && opt.getAttribute('data-value') === valueStr;
        opt.classList.toggle('selected', isSel);
        if (isSel) found = true;
      });

      if (!found) {
        optionEls().forEach(function (opt) {
          opt.classList.remove('selected');
        });
      }

      updateLabel();
      if (notifyShiny !== false) notify();
    }

    function bindOption(opt) {
      if (!opt || opt._gtBound) return;
      opt._gtBound = true;

      opt.addEventListener('click', function () {
        setValue(opt.getAttribute('data-value'), true);
        close();
      });
    }

    function buildOptionNode(ch) {
      var row = document.createElement('div');
      row.className = 'gt-gs-option';
      row.setAttribute('data-value', String(ch.value));

      var checkTemplate = wrap.querySelector('.gt-gs-check');
      var checkHtml = checkTemplate ? checkTemplate.innerHTML : '';

      row.innerHTML =
        '<div class="gt-gs-check">' + checkHtml + '</div>' +
        '<span>' + escapeHtml(ch.label) + '</span>';

      bindOption(row);
      return row;
    }

    function setChoices(choices) {
      var current = getValue();
      optionsBox.innerHTML = '';

      (choices || []).forEach(function (ch) {
        optionsBox.appendChild(buildOptionNode(ch));
      });

      if (current !== null && (choices || []).some(function (x) { return String(x.value) === current; })) {
        setValue(current, false);
      } else {
        setValue(null, false);
      }

      applySearch();
    }

    function applySearch() {
      if (!searchIn) return;

      var q = searchIn.value.toLowerCase().trim();
      optionEls().forEach(function (o) {
        var txt = (o.querySelector('span') ? o.querySelector('span').textContent : '').toLowerCase();
        o.classList.toggle('hidden', q !== '' && txt.indexOf(q) === -1);
      });
    }

    function open() {
      dropdown.classList.add('open');
      trigger.classList.add('open');
      if (searchIn) searchIn.focus();
    }

    function close() {
      dropdown.classList.remove('open');
      trigger.classList.remove('open');
    }

    trigger.addEventListener('click', function (e) {
      e.stopPropagation();
      if (dropdown.classList.contains('open')) close(); else open();
    });

    if (!wrap._gtDocClickHandler) {
      wrap._gtDocClickHandler = function (e) {
        if (!wrap.contains(e.target)) close();
      };
      document.addEventListener('click', wrap._gtDocClickHandler);
    }

    optionEls().forEach(bindOption);

    if (clearBtn) {
      clearBtn.addEventListener('click', function (e) {
        e.stopPropagation();
        setValue(null, true);
      });
    }

    if (searchIn) {
      searchIn.addEventListener('input', applySearch);
    }

    updateLabel();

    wrap._gt = {
      kind: 'single',
      getValue: getValue,
      setValue: function (v) {
        setValue(v, false);
      },
      setChoices: setChoices,
      getStyle: function () {
        return currentStyle;
      },
      setStyle: function (s) {
        if (STYLES.indexOf(s) === -1) return;

        STYLES.forEach(function (st) {
          wrap.classList.remove('style-' + st);
        });

        wrap.classList.add('style-' + s);
        currentStyle = s;
      },
      clear: function () {
        setValue(null, false);
      }
    };
  }

  /* ══════════════════════════════════════════════════════
     MULTI-SELECT ENGINE
  ══════════════════════════════════════════════════════ */
  function initMultiSelect(wrap) {
    if (wrap._gtMultiInit) return;
    wrap._gtMultiInit = true;

    var inputId = wrap.getAttribute('data-input-id');
    var placeholder = wrap.getAttribute('data-placeholder') || 'Filter by Category';
    var trigger = wrap.querySelector('.gt-ms-trigger');
    var dropdown = wrap.querySelector('.gt-ms-dropdown');
    var allRow = wrap.querySelector('.gt-ms-all');
    var badge = wrap.querySelector('.gt-ms-badge');
    var label = wrap.querySelector('[id$="-label"]');
    var countEl = wrap.querySelector('.gt-ms-count');
    var clearBtn = wrap.querySelector('.gt-ms-clear');
    var searchIn = wrap.querySelector('input[type="text"]');
    var styleBtns = Array.from(wrap.querySelectorAll('.gt-style-btn'));
    var optionsBox = wrap.querySelector('[id$="-options"]') || wrap;
    var STYLES = ['check-only', 'checkbox', 'filled'];
    var currentStyle = 'checkbox';

    STYLES.forEach(function (s) {
      if (wrap.classList.contains('style-' + s)) currentStyle = s;
    });

    function optionEls() {
      return Array.from(wrap.querySelectorAll('.gt-ms-option'));
    }

    function visibleChecked() {
      return optionEls().filter(function (o) {
        return !o.classList.contains('hidden') && o.classList.contains('checked');
      });
    }

    function visible() {
      return optionEls().filter(function (o) {
        return !o.classList.contains('hidden');
      });
    }

    function getValue() {
      return optionEls()
        .filter(function (o) { return o.classList.contains('checked'); })
        .map(function (o) { return o.getAttribute('data-value'); });
    }

    function notify() {
      triggerShinyChange(wrap);
      if (window.Shiny) {
        Shiny.setInputValue(inputId, getValue(), { priority: 'event' });
        Shiny.setInputValue(inputId + '_style', currentStyle, { priority: 'event' });
      }
    }

    function renderTags() {
      var sel = optionEls().filter(function (o) { return o.classList.contains('checked'); });

      document.querySelectorAll('[data-tags-for="' + inputId + '"]').forEach(function (pane) {
        pane.innerHTML = '';

        if (sel.length === 0) {
          pane.innerHTML = '<span class="gt-no-filters">No filters active</span>';
          return;
        }

        sel.forEach(function (o) {
          var name = o.querySelector('span').textContent;
          var val = o.getAttribute('data-value');
          var hue = getComputedStyle(o).getPropertyValue('--opt-hue').trim() || '210';

          var tag = document.createElement('div');
          tag.className = 'gt-filter-tag';

          if (currentStyle === 'filled') {
            tag.style.background = 'hsla(' + hue + ',65%,50%,0.18)';
            tag.style.borderColor = 'hsla(' + hue + ',65%,60%,0.35)';
            tag.style.color = 'hsl(' + hue + ',80%,78%)';
          }

          tag.innerHTML =
            escapeHtml(name) +
            '<span class="gt-remove-tag" data-value="' + escapeHtml(val) + '">&times;</span>';

          var remove = tag.querySelector('.gt-remove-tag');
          if (remove) {
            remove.addEventListener('click', function () {
              var opt = wrap.querySelector('.gt-ms-option[data-value="' + CSS.escape(val) + '"]');
              if (opt) opt.classList.remove('checked');
              syncAll();
            });
          }

          pane.appendChild(tag);
        });
      });
    }

    function syncAll() {
      var opts = optionEls();
      var vc = visibleChecked().length;
      var v = visible().length;
      var allC = opts.filter(function (o) { return o.classList.contains('checked'); }).length;
      var total = opts.length;

      if (allRow) {
        allRow.classList.remove('checked', 'indeterminate');
        if (vc > 0 && vc === v) {
          allRow.classList.add('checked');
        } else if (vc > 0) {
          allRow.classList.add('indeterminate');
        }
      }

      if (badge) {
        badge.textContent = allC;
        badge.classList.toggle('hidden', allC < 2 || allC === total);
      }

      if (countEl) {
        countEl.textContent = allC + ' / ' + total + ' selected';
      }

      if (label) {
        if (allC === 0) {
          label.textContent = placeholder;
        } else if (allC === total) {
          label.textContent = 'All categories';
        } else if (allC === 1) {
          var s = opts.find(function (o) { return o.classList.contains('checked'); });
          label.textContent = s ? s.querySelector('span').textContent : placeholder;
        } else {
          label.textContent = 'Multiple selection';
        }
      }

      renderTags();
      notify();
    }

    function bindOption(opt) {
      if (!opt || opt._gtBound) return;
      opt._gtBound = true;

      opt.addEventListener('click', function () {
        opt.classList.toggle('checked');
        syncAll();
      });
    }

    function buildOptionNode(ch, hue) {
      var row = document.createElement('div');
      row.className = 'gt-ms-option';
      row.setAttribute('data-value', String(ch.value));
      row.style.setProperty('--opt-hue', String(hue));

      var checkTemplate = wrap.querySelector('.gt-ms-check');
      var checkHtml = checkTemplate ? checkTemplate.innerHTML : '';

      row.innerHTML =
        '<div class="gt-ms-check">' + checkHtml + '</div>' +
        '<span>' + escapeHtml(ch.label) + '</span>';

      bindOption(row);
      return row;
    }

    function setValue(vals, notifyShiny) {
      vals = Array.isArray(vals) ? vals.map(String) : [];

      optionEls().forEach(function (o) {
        o.classList.toggle('checked', vals.indexOf(o.getAttribute('data-value')) !== -1);
      });

      syncAll();

      if (notifyShiny === false) {
        /* syncAll already notifies. We suppress by restoring after a quiet set. */
      }
    }

    function setValueQuiet(vals) {
      vals = Array.isArray(vals) ? vals.map(String) : [];

      optionEls().forEach(function (o) {
        o.classList.toggle('checked', vals.indexOf(o.getAttribute('data-value')) !== -1);
      });

      var oldNotify = notify;
      notify = function () {};
      syncAll();
      notify = oldNotify;
    }

    function setChoices(choices) {
      var selectedNow = getValue();
      optionsBox.innerHTML = '';

      var n = (choices || []).length;
      (choices || []).forEach(function (ch, i) {
        var hue = Math.round((200 + 360 * i / Math.max(1, n)) % 360);
        optionsBox.appendChild(buildOptionNode(ch, hue));
      });

      var keep = selectedNow.filter(function (v) {
        return (choices || []).some(function (ch) { return String(ch.value) === v; });
      });

      setValueQuiet(keep);
      applySearch();
    }

    function applySearch() {
      if (!searchIn) return;

      var q = searchIn.value.toLowerCase().trim();
      optionEls().forEach(function (o) {
        var txt = (o.querySelector('span') ? o.querySelector('span').textContent : '').toLowerCase();
        o.classList.toggle('hidden', q !== '' && txt.indexOf(q) === -1);
      });

      var oldNotify = notify;
      notify = function () {};
      syncAll();
      notify = oldNotify;
    }

    function open() {
      dropdown.classList.add('open');
      trigger.classList.add('open');
      if (searchIn) searchIn.focus();
    }

    function close() {
      dropdown.classList.remove('open');
      trigger.classList.remove('open');
    }

    trigger.addEventListener('click', function (e) {
      e.stopPropagation();
      if (dropdown.classList.contains('open')) close(); else open();
    });

    if (!wrap._gtDocClickHandler) {
      wrap._gtDocClickHandler = function (e) {
        if (!wrap.contains(e.target)) close();
      };
      document.addEventListener('click', wrap._gtDocClickHandler);
    }

    styleBtns.forEach(function (btn) {
      btn.addEventListener('click', function () {
        var s = btn.getAttribute('data-style');
        if (s === currentStyle || STYLES.indexOf(s) === -1) return;

        styleBtns.forEach(function (b) { b.classList.remove('active'); });
        btn.classList.add('active');

        STYLES.forEach(function (st) { wrap.classList.remove('style-' + st); });
        wrap.classList.add('style-' + s);
        currentStyle = s;
        syncAll();
      });
    });

    optionEls().forEach(bindOption);

    if (allRow) {
      allRow.addEventListener('click', function () {
        var v = visible();
        var anyUnchecked = v.some(function (o) { return !o.classList.contains('checked'); });

        v.forEach(function (o) {
          if (anyUnchecked) o.classList.add('checked');
          else o.classList.remove('checked');
        });

        syncAll();
      });
    }

    if (clearBtn) {
      clearBtn.addEventListener('click', function () {
        optionEls().forEach(function (o) { o.classList.remove('checked'); });
        syncAll();
      });
    }

    if (searchIn) {
      searchIn.addEventListener('input', applySearch);
    }

    syncAll();

    wrap._gt = {
      kind: 'multi',
      getValue: getValue,
      setValue: function (vals) {
        setValueQuiet(Array.isArray(vals) ? vals : []);
      },
      setChoices: setChoices,
      getStyle: function () {
        return currentStyle;
      },
      setStyle: function (s) {
        if (STYLES.indexOf(s) === -1) return;

        styleBtns.forEach(function (b) {
          b.classList.toggle('active', b.getAttribute('data-style') === s);
        });

        STYLES.forEach(function (st) { wrap.classList.remove('style-' + st); });
        wrap.classList.add('style-' + s);
        currentStyle = s;

        var oldNotify = notify;
        notify = function () {};
        syncAll();
        notify = oldNotify;
      },
      clear: function () {
        setValueQuiet([]);
      },
      notify: notify
    };
  }

  /* ══════════════════════════════════════════════════════
     SHINY INPUT BINDINGS
  ══════════════════════════════════════════════════════ */
  function registerBindings() {
    if (typeof Shiny === 'undefined' || !window.jQuery || registerBindings._done) return;
    registerBindings._done = true;

    var $ = window.jQuery;

    var glassSelectBinding = new Shiny.InputBinding();
    $.extend(glassSelectBinding, {
      find: function (scope) {
        return $(scope).find('.gt-gs-wrap');
      },
      getId: function (el) {
        return el.getAttribute('data-input-id');
      },
      getValue: function (el) {
        return el._gt ? el._gt.getValue() : null;
      },
      subscribe: function (el, callback) {
        $(el).on('change.glasstabs', function () {
          callback();
        });
      },
      unsubscribe: function (el) {
        $(el).off('.glasstabs');
      },
      receiveMessage: function (el, data) {
        if (!el._gt) initGlassSelect(el);
        if (!el._gt) return;

        if (hasOwn(data, 'choices')) {
          el._gt.setChoices(data.choices || []);
        }

        if (hasOwn(data, 'selected')) {
          var sel = data.selected;
          if (Array.isArray(sel)) sel = sel.length ? sel[0] : null;
          if (sel === '') sel = null;
          el._gt.setValue(sel);
        }

        if (hasOwn(data, 'style')) {
          el._gt.setStyle(data.style);
        }

        triggerShinyChange(el);
      }
    });
    Shiny.inputBindings.register(glassSelectBinding, 'glasstabs.glassSelect');

    var glassMultiSelectBinding = new Shiny.InputBinding();
    $.extend(glassMultiSelectBinding, {
      find: function (scope) {
        return $(scope).find('.gt-ms-wrap');
      },
      getId: function (el) {
        return el.getAttribute('data-input-id');
      },
      getValue: function (el) {
        return el._gt ? el._gt.getValue() : [];
      },
      subscribe: function (el, callback) {
        $(el).on('change.glasstabs', function () {
          callback();
        });
      },
      unsubscribe: function (el) {
        $(el).off('.glasstabs');
      },
      receiveMessage: function (el, data) {
        if (!el._gt) initMultiSelect(el);
        if (!el._gt) return;

        if (hasOwn(data, 'choices')) {
          el._gt.setChoices(data.choices || []);
        }

        if (hasOwn(data, 'selected')) {
          el._gt.setValue(Array.isArray(data.selected) ? data.selected : []);
        }

        if (hasOwn(data, 'style')) {
          el._gt.setStyle(data.style);
        }

        if (el._gt.notify) el._gt.notify();
        triggerShinyChange(el);
      }
    });
    Shiny.inputBindings.register(glassMultiSelectBinding, 'glasstabs.glassMultiSelect');
  }

  /* ══════════════════════════════════════════════════════
     BOOT
  ══════════════════════════════════════════════════════ */
  function bootAll() {
    document.querySelectorAll('.gt-navbar').forEach(function (nb) {
      initTabs(nb);
    });

    document.querySelectorAll('.gt-gs-wrap').forEach(function (w) {
      initGlassSelect(w);
    });

    document.querySelectorAll('.gt-ms-wrap').forEach(function (w) {
      initMultiSelect(w);
    });

    registerBindings();
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', bootAll);
  } else {
    bootAll();
  }

  window.addEventListener('load', bootAll);

  if (typeof Shiny !== 'undefined') {
    Shiny.addCustomMessageHandler('glasstabs_reinit', function () {
      bootAll();
    });
  }

  document.addEventListener('shiny:value', function () {
    setTimeout(bootAll, 50);
  });
})();
