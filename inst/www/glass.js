(function () {
  'use strict';

  /* ══════════════════════════════════════════════════════
     UTILITIES
  ══════════════════════════════════════════════════════ */
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

  function debounce(fn, ms) {
    var timer;
    return function () {
      var ctx = this, args = arguments;
      clearTimeout(timer);
      timer = setTimeout(function () { fn.apply(ctx, args); }, ms);
    };
  }

  function triggerShinyChange(el) {
    if (window.jQuery) {
      window.jQuery(el).trigger('change');
    }
  }

  /** Lazy-init helper used by Shiny input bindings */
  function ensureInit(el) {
    if (el._gt) return el._gt;
    if (el.classList.contains('gt-gs-wrap')) initGlassSelect(el);
    else if (el.classList.contains('gt-ms-wrap')) initMultiSelect(el);
    return el._gt || null;
  }

  /** Close every open glasstabs dropdown except the one being opened */
  function closeAllDropdowns(except) {
    document.querySelectorAll('.gt-gs-wrap.gt-layer-active, .gt-ms-wrap.gt-layer-active').forEach(function (w) {
      if (w === except) return;
      w.classList.remove('gt-layer-active');
      var dd = w.querySelector('.gt-gs-dropdown, .gt-ms-dropdown');
      if (dd) dd.classList.remove('open');
      var trig = w.querySelector('.gt-gs-trigger, .gt-ms-trigger');
      if (trig) trig.classList.remove('open');
    });
  }

  /* ══════════════════════════════════════════════════════
     TAB ENGINE
  ══════════════════════════════════════════════════════ */
  function initTabs(navbar) {
    function clearTabTimers() {
      if (navbar._gtTabTimers) {
        navbar._gtTabTimers.forEach(function (id) { clearTimeout(id); });
      }
      navbar._gtTabTimers = [];
    }

    /* Clean up previous init so dynamic tabs can safely re-initialize */
    if (navbar._gtTabsInit) {
      clearTabTimers();
      if (navbar._gtClickHandler)  navbar.removeEventListener('click',   navbar._gtClickHandler);
      if (navbar._gtKeyHandler)    document.removeEventListener('keydown', navbar._gtKeyHandler);
      if (navbar._gtResizeHandler) window.removeEventListener('resize',  navbar._gtResizeHandler);
      navbar._gtClickHandler = navbar._gtKeyHandler = navbar._gtResizeHandler = navbar._gtActivate = null;
    }
    navbar._gtTabsInit = true;
    navbar._gtTabTimers = navbar._gtTabTimers || [];

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
    var activeEl = links.find(function (l) { return l.classList.contains('active'); }) || links[0];

    if (!halo || !trf || links.length === 0 || !activeEl) return;

    var active = activeEl.getAttribute('data-value');

    function currentVisibleOrder() {
      return Array.from(navbar.querySelectorAll('.gt-tab-link'))
        .filter(function (l) { return !l.classList.contains('gt-tab-hidden'); })
        .map(function (l) { return l.getAttribute('data-value'); });
    }

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

      var order = currentVisibleOrder();
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

    /* Activate a tab by value. skipFromAnim = true skips the transfer
       animation (used when the previous tab is hidden or removed). */
    function activateTab(target, skipFromAnim) {
      clearTabTimers();

      var toEl = navbar.querySelector('.gt-tab-link[data-value="' + target + '"]');
      if (!toEl || target === active) return;

      var fromEl = skipFromAnim ? null
        : navbar.querySelector('.gt-tab-link[data-value="' + active + '"]');

      navbar.querySelectorAll('.gt-tab-link').forEach(function (t) {
        t.classList.remove('active');
        t.setAttribute('aria-selected', 'false');
      });
      toEl.classList.add('active');
      toEl.setAttribute('aria-selected', 'true');

      var animated = fromEl && !fromEl.classList.contains('gt-tab-hidden');
      if (animated) {
        placeHalo(fromEl, true, 1.0);
        halo.style.opacity = '0.38';
      }

      var dur = animated ? animateTransfer(fromEl, toEl) : 0;

      navbar._gtTabTimers.push(setTimeout(function () {
        var ap = container.querySelector('.gt-tab-pane.active');
        if (ap) ap.classList.remove('active');
        var next = document.getElementById(ns + '-pane-' + target);
        if (next) next.classList.add('active');
        active = target;
        if (window.Shiny) Shiny.setInputValue(ns + '-active_tab', target, { priority: 'event' });
      }, dur > 0 ? Math.max(100, dur * 0.50) : 0));

      if (dur > 0) {
        navbar._gtTabTimers.push(setTimeout(function () {
          placeHalo(toEl, false, 0.90);
          navbar._gtTabTimers.push(setTimeout(function () {
            placeHalo(toEl, false, 1.0);
          }, 80));
        }, dur * 0.60));

        navbar._gtTabTimers.push(setTimeout(function () {
          placeHalo(toEl, true, 1.0);
          halo.classList.remove('gt-arrival-pulse');
          void halo.offsetWidth;
          halo.classList.add('gt-arrival-pulse');
        }, dur));
      } else {
        placeHalo(toEl, true, 1.0);
        navbar._gtTabTimers.push(setTimeout(function () { placeHalo(toEl, false, 1.0); }, 80));
      }
    }

    navbar._gtActivate = activateTab;

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

    /* Single delegated click handler — covers dynamically appended tabs */
    navbar._gtClickHandler = function (e) {
      var link = e.target.closest ? e.target.closest('.gt-tab-link') : null;
      if (!link || link.classList.contains('gt-tab-hidden')) return;
      activateTab(link.getAttribute('data-value'));
    };
    navbar.addEventListener('click', navbar._gtClickHandler);

    navbar._gtKeyHandler = function (e) {
      if (e.key !== 'ArrowRight' && e.key !== 'ArrowLeft') return;
      if (!navbar.contains(document.activeElement)) return;

      var visibleOrder = currentVisibleOrder();
      var idx = visibleOrder.indexOf(active);
      if (idx < 0) return;

      if (e.key === 'ArrowRight') {
        activateTab(visibleOrder[(idx + 1) % visibleOrder.length]);
      }

      if (e.key === 'ArrowLeft') {
        activateTab(visibleOrder[(idx - 1 + visibleOrder.length) % visibleOrder.length]);
      }
    };
    document.addEventListener('keydown', navbar._gtKeyHandler);

    navbar._gtResizeHandler = function () {
      var activeLink = navbar.querySelector('.gt-tab-link[data-value="' + active + '"]');
      if (activeLink) placeHalo(activeLink, true, 1.0);
    };
    window.addEventListener('resize', navbar._gtResizeHandler);
  }

  /* ══════════════════════════════════════════════════════
     SINGLE-SELECT ENGINE
  ══════════════════════════════════════════════════════ */
  function initGlassSelect(wrap) {
    if (wrap._gtSelectInit) return;
    wrap._gtSelectInit = true;

    var inputId = wrap.getAttribute('data-input-id');
    var placeholder = wrap.getAttribute('data-placeholder') || 'Select an option';

    /* ── DOM refs ── */
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

    /* ── Capture check SVG template before any rebuilds ── */
    var checkTemplate = wrap.querySelector('.gt-gs-check');
    var checkHtml = checkTemplate ? checkTemplate.innerHTML : '';

    /* ── Add scroll class to options container ── */
    if (optionsBox) optionsBox.classList.add('gt-gs-options-scroll');

    /* ── Internal state ── */
    var state = {
      choices: [],     // [{label, value, hidden, _labelLower}]
      selected: null,  // string | null
      query: ''
    };

    /* ── Read initial state from R-generated DOM ── */
    Array.from(wrap.querySelectorAll('.gt-gs-option')).forEach(function (el) {
      var value = el.getAttribute('data-value');
      var span = el.querySelector('span');
      var label = span ? span.textContent : value;
      state.choices.push({
        label: label,
        value: value,
        hidden: false,
        _labelLower: label.toLowerCase()
      });
      if (el.classList.contains('selected')) {
        state.selected = value;
      }
      bindOption(el);
    });

    /* ── State readers ── */
    function getValue() {
      return state.selected;
    }

    function findChoice(value) {
      if (value === null) return null;
      for (var i = 0; i < state.choices.length; i++) {
        if (state.choices[i].value === value) return state.choices[i];
      }
      return null;
    }

    /* ── DOM patching ── */
    function patchOptionClasses() {
      Array.from(wrap.querySelectorAll('.gt-gs-option')).forEach(function (el) {
        var v = el.getAttribute('data-value');
        el.classList.toggle('selected', state.selected !== null && v === state.selected);
      });
    }

    function patchVisibility() {
      Array.from(wrap.querySelectorAll('.gt-gs-option')).forEach(function (el) {
        var v = el.getAttribute('data-value');
        var ch = findChoice(v);
        el.classList.toggle('hidden', ch ? ch.hidden : false);
      });
    }

    /* ── UI sync (visual only, no Shiny notification) ── */
    function syncUI() {
      var ch = findChoice(state.selected);
      labelEl.textContent = ch ? ch.label : placeholder;
      patchOptionClasses();
    }

    /* ── Shiny notification ── */
    function commitSelection() {
      triggerShinyChange(wrap);
      if (window.Shiny) {
        Shiny.setInputValue(inputId, state.selected, { priority: 'event' });
      }
    }

    /* ── setValue with opts ── */
    function setValue(value, opts) {
      opts = opts || {};
      var doNotify = opts.notify !== false;
      var valueStr = (value === null || typeof value === 'undefined' || value === '') ? null : String(value);

      if (valueStr !== null && !findChoice(valueStr)) {
        valueStr = null;
      }

      state.selected = valueStr;
      syncUI();
      if (doNotify) commitSelection();
    }

    /* ── Option click binding ── */
    function bindOption(opt) {
      if (!opt || opt._gtBound) return;
      opt._gtBound = true;

      opt.addEventListener('click', function () {
        setValue(opt.getAttribute('data-value'), { notify: true });
        close();
      });
    }

    /* ── Build a single option DOM node ── */
    function buildOptionNode(ch) {
      var row = document.createElement('div');
      row.className = 'gt-gs-option';
      row.setAttribute('data-value', ch.value);

      row.innerHTML =
        '<div class="gt-gs-check">' + checkHtml + '</div>' +
        '<span>' + escapeHtml(ch.label) + '</span>';

      bindOption(row);
      return row;
    }

    /* ── setChoices: rebuild from state ── */
    function setChoices(choices, opts) {
      opts = opts || {};
      var preserveSel = opts.preserveSelection !== false;
      var doNotify = opts.notify !== false;

      var oldSelected = preserveSel ? state.selected : null;

      /* Update state */
      state.choices = (choices || []).map(function (ch) {
        return {
          label: String(ch.label),
          value: String(ch.value),
          hidden: false,
          _labelLower: String(ch.label).toLowerCase()
        };
      });

      /* Intersect selection */
      if (oldSelected !== null && findChoice(oldSelected)) {
        state.selected = oldSelected;
      } else {
        state.selected = null;
      }

      /* Rebuild DOM */
      var frag = document.createDocumentFragment();
      state.choices.forEach(function (ch) {
        frag.appendChild(buildOptionNode(ch));
      });
      optionsBox.innerHTML = '';
      optionsBox.appendChild(frag);

      /* Re-apply search if active */
      if (state.query) {
        applySearchNow(state.query);
      }

      syncUI();
      if (doNotify) commitSelection();
    }

    /* ── Search (debounced) ── */
    function applySearchNow(q) {
      var qq = (q || '').toLowerCase().trim();
      state.query = qq;

      state.choices.forEach(function (ch) {
        ch.hidden = qq !== '' && ch._labelLower.indexOf(qq) === -1;
      });

      patchVisibility();
    }

    var debouncedSearch = debounce(function () {
      applySearchNow(searchIn ? searchIn.value : '');
    }, 75);

    /* ── Open / Close ── */
    function open() {
      closeAllDropdowns(wrap);
      wrap.classList.add('gt-layer-active');
      dropdown.classList.add('open');
      trigger.classList.add('open');
      if (searchIn) searchIn.focus();
    }

    function close() {
      wrap.classList.remove('gt-layer-active');
      dropdown.classList.remove('open');
      trigger.classList.remove('open');
    }

    /* ── Event listeners ── */
    trigger.addEventListener('click', function (e) {
      e.stopPropagation();
      if (dropdown.classList.contains('open')) close(); else open();
    });

    wrap._gtDocClickHandler = function (e) {
      if (!wrap.contains(e.target)) close();
    };
    document.addEventListener('click', wrap._gtDocClickHandler);

    if (clearBtn) {
      clearBtn.addEventListener('click', function (e) {
        e.stopPropagation();
        setValue(null, { notify: true });
      });
    }

    if (searchIn) {
      searchIn.addEventListener('input', debouncedSearch);
    }

    /* ── Destroy (lifecycle teardown) ── */
    function destroy() {
      if (wrap._gtDocClickHandler) {
        document.removeEventListener('click', wrap._gtDocClickHandler);
        wrap._gtDocClickHandler = null;
      }
      wrap._gt = null;
      wrap._gtSelectInit = false;
    }

    /* ── Initial UI sync ── */
    syncUI();

    /* ── Emit initial value to Shiny ── */
    if (window.Shiny && window.Shiny.setInputValue) {
      Shiny.setInputValue(inputId, state.selected, { priority: 'deferred' });
      Shiny.setInputValue(inputId + '_ready', true, { priority: 'deferred' });
    }

    /* ── Public controller ── */
    wrap._gt = {
      kind: 'single',
      getValue: getValue,
      setValue: function (v, opts) {
        setValue(v, opts);
      },
      setChoices: function (choices, opts) {
        setChoices(choices, opts);
      },
      getStyle: function () {
        return currentStyle;
      },
      setStyle: function (s, opts) {
        if (STYLES.indexOf(s) === -1) return;
        STYLES.forEach(function (st) { wrap.classList.remove('style-' + st); });
        wrap.classList.add('style-' + s);
        currentStyle = s;
      },
      clear: function (opts) {
        setValue(null, opts);
      },
      destroy: destroy
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
    var allLabel = wrap.getAttribute('data-all-label') || 'All categories';

    /* ── DOM refs ── */
    var trigger = wrap.querySelector('.gt-ms-trigger');
    var dropdown = wrap.querySelector('.gt-ms-dropdown');
    var allRow = wrap.querySelector('.gt-ms-all');
    var badge = wrap.querySelector('.gt-ms-badge');
    var labelEl = wrap.querySelector('[id$="-label"]');
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

    /* ── Capture check SVG template ── */
    var checkTemplate = wrap.querySelector('.gt-ms-check');
    var checkHtml = checkTemplate ? checkTemplate.innerHTML : '';

    /* ── Add scroll class ── */
    if (optionsBox) optionsBox.classList.add('gt-ms-options-scroll');

    /* ── Internal state ── */
    var state = {
      choices: [],          // [{label, value, hidden, hue, _labelLower}]
      selected: new Set(),  // Set of value strings
      query: ''
    };

    /* ── Read initial state from R-generated DOM ── */
    Array.from(wrap.querySelectorAll('.gt-ms-option')).forEach(function (el) {
      var value = el.getAttribute('data-value');
      var span = el.querySelector('span');
      var label = span ? span.textContent : value;
      var hue = el.style.getPropertyValue('--opt-hue') || '210';

      state.choices.push({
        label: label,
        value: value,
        hidden: false,
        hue: parseInt(hue, 10) || 210,
        _labelLower: label.toLowerCase()
      });

      if (el.classList.contains('checked')) {
        state.selected.add(value);
      }

      bindOption(el);
    });

    /* ── State readers ── */
    function getValue() {
      /* Return in choice order, not Set insertion order */
      var out = [];
      state.choices.forEach(function (ch) {
        if (state.selected.has(ch.value)) out.push(ch.value);
      });
      return out;
    }

    function visibleChoices() {
      return state.choices.filter(function (ch) { return !ch.hidden; });
    }

    function visibleSelectedCount() {
      var n = 0;
      state.choices.forEach(function (ch) {
        if (!ch.hidden && state.selected.has(ch.value)) n++;
      });
      return n;
    }

    /* ── DOM patching ── */
    function patchOptionClasses() {
      Array.from(wrap.querySelectorAll('.gt-ms-option')).forEach(function (el) {
        var v = el.getAttribute('data-value');
        el.classList.toggle('checked', state.selected.has(v));
      });
    }

    function patchVisibility() {
      Array.from(wrap.querySelectorAll('.gt-ms-option')).forEach(function (el) {
        var v = el.getAttribute('data-value');
        for (var i = 0; i < state.choices.length; i++) {
          if (state.choices[i].value === v) {
            el.classList.toggle('hidden', state.choices[i].hidden);
            break;
          }
        }
      });
    }

    /* ── syncUI: visual-only update ── */
    function syncUI() {
      var total = state.choices.length;
      var selCount = state.selected.size;
      var vis = visibleChoices().length;
      var visSel = visibleSelectedCount();

      /* All row */
      if (allRow) {
        allRow.classList.remove('checked', 'indeterminate');
        if (visSel > 0 && visSel === vis) {
          allRow.classList.add('checked');
        } else if (visSel > 0) {
          allRow.classList.add('indeterminate');
        }
      }

      /* Badge */
      if (badge) {
        badge.textContent = selCount;
        badge.classList.toggle('hidden', selCount < 2 || selCount === total);
      }

      /* Count */
      if (countEl) {
        countEl.textContent = selCount + ' / ' + total + ' selected';
      }

      /* Label */
      if (labelEl) {
        if (selCount === 0) {
          labelEl.textContent = placeholder;
        } else if (total > 0 && selCount === total) {
          labelEl.textContent = allLabel;
        } else if (selCount === 1) {
          var first = null;
          for (var i = 0; i < state.choices.length; i++) {
            if (state.selected.has(state.choices[i].value)) {
              first = state.choices[i];
              break;
            }
          }
          labelEl.textContent = first ? first.label : placeholder;
        } else {
          labelEl.textContent = 'Multiple selection';
        }
      }

      patchOptionClasses();
      renderTags();
    }

    /* ── commitSelection: notify Shiny ── */
    function commitSelection() {
      triggerShinyChange(wrap);
      if (window.Shiny) {
        Shiny.setInputValue(inputId, getValue(), { priority: 'event' });
        Shiny.setInputValue(inputId + '_style', currentStyle, { priority: 'event' });
      }
    }

    /* ── renderTags: reads from state, not DOM ── */
    function renderTags() {
      var tagPanes = document.querySelectorAll('[data-tags-for="' + inputId + '"]');
      if (tagPanes.length === 0) return;

      tagPanes.forEach(function (pane) {
        pane.innerHTML = '';

        if (state.selected.size === 0) {
          pane.innerHTML = '<span class="gt-no-filters">No filters active</span>';
          return;
        }

        state.choices.forEach(function (ch) {
          if (!state.selected.has(ch.value)) return;

          var tag = document.createElement('div');
          tag.className = 'gt-filter-tag';

          if (currentStyle === 'filled') {
            tag.style.background = 'hsla(' + ch.hue + ',65%,50%,0.18)';
            tag.style.borderColor = 'hsla(' + ch.hue + ',65%,60%,0.35)';
            tag.style.color = 'hsl(' + ch.hue + ',80%,78%)';
          }

          tag.innerHTML =
            escapeHtml(ch.label) +
            '<span class="gt-remove-tag" data-value="' + escapeHtml(ch.value) + '">&times;</span>';

          var remove = tag.querySelector('.gt-remove-tag');
          if (remove) {
            remove.addEventListener('click', function () {
              state.selected.delete(ch.value);
              syncUI();
              commitSelection();
            });
          }

          pane.appendChild(tag);
        });
      });
    }

    /* ── setValue with opts ── */
    function setValue(vals, opts) {
      opts = opts || {};
      var doNotify = opts.notify !== false;
      var arr = Array.isArray(vals) ? vals.map(String) : [];

      state.selected = new Set();
      var validValues = new Set(state.choices.map(function (ch) { return ch.value; }));

      arr.forEach(function (v) {
        if (validValues.has(v)) state.selected.add(v);
      });

      syncUI();
      if (doNotify) commitSelection();
    }

    /* ── Option click binding ── */
    function bindOption(opt) {
      if (!opt || opt._gtBound) return;
      opt._gtBound = true;

      opt.addEventListener('click', function () {
        var v = opt.getAttribute('data-value');
        if (state.selected.has(v)) {
          state.selected.delete(v);
        } else {
          state.selected.add(v);
        }
        syncUI();
        commitSelection();
      });
    }

    /* ── Build a single option DOM node ── */
    function buildOptionNode(ch) {
      var row = document.createElement('div');
      row.className = 'gt-ms-option';
      row.setAttribute('data-value', ch.value);
      row.style.setProperty('--opt-hue', String(ch.hue));

      if (state.selected.has(ch.value)) {
        row.className += ' checked';
      }

      row.innerHTML =
        '<div class="gt-ms-check">' + checkHtml + '</div>' +
        '<span>' + escapeHtml(ch.label) + '</span>';

      bindOption(row);
      return row;
    }

    /* ── setChoices: rebuild from state ── */
    function setChoices(choices, opts) {
      opts = opts || {};
      var preserveSel = opts.preserveSelection !== false;
      var doNotify = opts.notify !== false;

      var oldSelected = preserveSel ? new Set(state.selected) : new Set();

      /* Update state */
      var n = (choices || []).length;
      state.choices = (choices || []).map(function (ch, i) {
        return {
          label: String(ch.label),
          value: String(ch.value),
          hidden: false,
          hue: ch.hue || Math.round((200 + 360 * i / Math.max(1, n)) % 360),
          _labelLower: String(ch.label).toLowerCase()
        };
      });

      /* Intersect selection */
      var newValues = new Set(state.choices.map(function (ch) { return ch.value; }));
      state.selected = new Set();
      oldSelected.forEach(function (v) {
        if (newValues.has(v)) state.selected.add(v);
      });

      /* Rebuild DOM using fragment */
      var frag = document.createDocumentFragment();
      state.choices.forEach(function (ch) {
        frag.appendChild(buildOptionNode(ch));
      });
      optionsBox.innerHTML = '';
      optionsBox.appendChild(frag);

      /* Re-apply search if active */
      if (state.query) {
        applySearchNow(state.query);
      }

      syncUI();
      if (doNotify) commitSelection();
    }

    /* ── Search (debounced) ── */
    function applySearchNow(q) {
      var qq = (q || '').toLowerCase().trim();
      state.query = qq;

      state.choices.forEach(function (ch) {
        ch.hidden = qq !== '' && ch._labelLower.indexOf(qq) === -1;
      });

      patchVisibility();
      /* Update allRow and counts without notifying Shiny */
      var total = state.choices.length;
      var vis = visibleChoices().length;
      var visSel = visibleSelectedCount();

      if (allRow) {
        allRow.classList.remove('checked', 'indeterminate');
        if (visSel > 0 && visSel === vis) {
          allRow.classList.add('checked');
        } else if (visSel > 0) {
          allRow.classList.add('indeterminate');
        }
      }
    }

    var debouncedSearch = debounce(function () {
      applySearchNow(searchIn ? searchIn.value : '');
    }, 75);

    /* ── Open / Close ── */
    function open() {
      closeAllDropdowns(wrap);
      wrap.classList.add('gt-layer-active');
      dropdown.classList.add('open');
      trigger.classList.add('open');
      if (searchIn) searchIn.focus();
    }

    function close() {
      wrap.classList.remove('gt-layer-active');
      dropdown.classList.remove('open');
      trigger.classList.remove('open');
    }

    /* ── Event listeners ── */
    trigger.addEventListener('click', function (e) {
      e.stopPropagation();
      if (dropdown.classList.contains('open')) close(); else open();
    });

    wrap._gtDocClickHandler = function (e) {
      if (!wrap.contains(e.target)) close();
    };
    document.addEventListener('click', wrap._gtDocClickHandler);

    styleBtns.forEach(function (btn) {
      btn.addEventListener('click', function () {
        var s = btn.getAttribute('data-style');
        if (s === currentStyle || STYLES.indexOf(s) === -1) return;

        styleBtns.forEach(function (b) { b.classList.remove('active'); });
        btn.classList.add('active');

        STYLES.forEach(function (st) { wrap.classList.remove('style-' + st); });
        wrap.classList.add('style-' + s);
        currentStyle = s;

        syncUI();
        commitSelection();
      });
    });

    if (allRow) {
      allRow.addEventListener('click', function () {
        var vis = visibleChoices();
        var anyUnchecked = vis.some(function (ch) { return !state.selected.has(ch.value); });

        vis.forEach(function (ch) {
          if (anyUnchecked) {
            state.selected.add(ch.value);
          } else {
            state.selected.delete(ch.value);
          }
        });

        syncUI();
        commitSelection();
      });
    }

    if (clearBtn) {
      clearBtn.addEventListener('click', function () {
        state.selected = new Set();
        syncUI();
        commitSelection();
      });
    }

    if (searchIn) {
      searchIn.addEventListener('input', debouncedSearch);
    }

    /* ── Destroy (lifecycle teardown) ── */
    function destroy() {
      if (wrap._gtDocClickHandler) {
        document.removeEventListener('click', wrap._gtDocClickHandler);
        wrap._gtDocClickHandler = null;
      }
      wrap._gt = null;
      wrap._gtMultiInit = false;
    }

    /* ── Initial sync ── */
    syncUI();

    /* ── Emit initial value to Shiny ── */
    if (window.Shiny && window.Shiny.setInputValue) {
      Shiny.setInputValue(inputId, getValue(), { priority: 'deferred' });
      Shiny.setInputValue(inputId + '_style', currentStyle, { priority: 'deferred' });
      Shiny.setInputValue(inputId + '_ready', true, { priority: 'deferred' });
    }

    /* ── Public controller ── */
    wrap._gt = {
      kind: 'multi',
      getValue: getValue,
      setValue: function (vals, opts) {
        setValue(Array.isArray(vals) ? vals : [], opts);
      },
      setChoices: function (choices, opts) {
        setChoices(choices, opts);
      },
      getStyle: function () {
        return currentStyle;
      },
      setStyle: function (s, opts) {
        opts = opts || {};
        if (STYLES.indexOf(s) === -1) return;

        styleBtns.forEach(function (b) {
          b.classList.toggle('active', b.getAttribute('data-style') === s);
        });

        STYLES.forEach(function (st) { wrap.classList.remove('style-' + st); });
        wrap.classList.add('style-' + s);
        currentStyle = s;

        syncUI();
        if (opts.notify !== false) commitSelection();
      },
      clear: function (opts) {
        setValue([], opts);
      },
      destroy: destroy,
      /* Expose for binding — stable reference, not the closure var */
      commitSelection: commitSelection
    };
  }

  /* ══════════════════════════════════════════════════════
     SHINY INPUT BINDINGS
  ══════════════════════════════════════════════════════ */
  function registerBindings() {
    if (typeof Shiny === 'undefined' || !window.jQuery || registerBindings._done) return;
    registerBindings._done = true;

    var $ = window.jQuery;

    /* ── Single-select binding ── */
    var glassSelectBinding = new Shiny.InputBinding();
    $.extend(glassSelectBinding, {
      find: function (scope) {
        return $(scope).find('.gt-gs-wrap');
      },
      getId: function (el) {
        return el.getAttribute('data-input-id');
      },
      getValue: function (el) {
        var ctrl = ensureInit(el);
        return ctrl ? ctrl.getValue() : null;
      },
      subscribe: function (el, callback) {
        ensureInit(el);
        $(el).on('change.glasstabs', function () {
          callback();
        });
      },
      unsubscribe: function (el) {
        $(el).off('.glasstabs');
        if (el._gt && typeof el._gt.destroy === 'function') {
          el._gt.destroy();
        }
      },
      receiveMessage: function (el, data) {
        var ctrl = ensureInit(el);
        if (!ctrl) return;

        if (hasOwn(data, 'choices')) {
          ctrl.setChoices(data.choices || [], { notify: false });
        }

        if (hasOwn(data, 'selected')) {
          var sel = data.selected;
          if (Array.isArray(sel)) sel = sel.length ? sel[0] : null;
          if (sel === '') sel = null;
          ctrl.setValue(sel, { notify: false });
        }

        if (hasOwn(data, 'style')) {
          ctrl.setStyle(data.style, { notify: false });
        }

        /* Single commit after all fields are set */
        triggerShinyChange(el);
      }
    });
    Shiny.inputBindings.register(glassSelectBinding, 'glasstabs.glassSelect');

    /* ── Multi-select binding ── */
    var glassMultiSelectBinding = new Shiny.InputBinding();
    $.extend(glassMultiSelectBinding, {
      find: function (scope) {
        return $(scope).find('.gt-ms-wrap');
      },
      getId: function (el) {
        return el.getAttribute('data-input-id');
      },
      getValue: function (el) {
        var ctrl = ensureInit(el);
        return ctrl ? ctrl.getValue() : [];
      },
      subscribe: function (el, callback) {
        ensureInit(el);
        $(el).on('change.glasstabs', function () {
          callback();
        });
      },
      unsubscribe: function (el) {
        $(el).off('.glasstabs');
        if (el._gt && typeof el._gt.destroy === 'function') {
          el._gt.destroy();
        }
      },
      receiveMessage: function (el, data) {
        var ctrl = ensureInit(el);
        if (!ctrl) return;

        if (hasOwn(data, 'choices')) {
          ctrl.setChoices(data.choices || [], { notify: false });
        }

        if (hasOwn(data, 'selected')) {
          ctrl.setValue(Array.isArray(data.selected) ? data.selected : [], { notify: false });
        }

        if (hasOwn(data, 'style')) {
          ctrl.setStyle(data.style, { notify: false });
        }

        /* Single commit after all fields are set */
        if (ctrl.commitSelection) ctrl.commitSelection();
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

  /* Report the initial active tab for every navbar once the Shiny session
     is ready — so glassTabsServer() is never NULL on first render. */
  document.addEventListener('shiny:sessioninitialized', function () {
    document.querySelectorAll('.gt-navbar').forEach(function (nb) {
      var ns = nb.getAttribute('data-ns');
      var activeLink = nb.querySelector('.gt-tab-link.active');
      if (ns && activeLink && window.Shiny) {
        Shiny.setInputValue(ns + '-active_tab', activeLink.getAttribute('data-value'));
      }
    });
  });

  function registerCustomMessageHandlers() {
    if (typeof Shiny === 'undefined' || registerCustomMessageHandlers._done) return;
    
    Shiny.addCustomMessageHandler('glasstabs_reinit', function (msg) {
      bootAll();
    });

    Shiny.addCustomMessageHandler('glasstabs_debug_ping', function (msg) {
      if (window.Shiny && window.Shiny.setInputValue) {
        Shiny.setInputValue('glasstabs_debug_ping_payload', msg || null, { priority: 'event' });
      }
    });

    Shiny.addCustomMessageHandler('glasstabs_update_tabs', function (msg) {
      if (!msg.ns || !msg.selected) return;
      var navbar = document.querySelector('.gt-navbar[data-ns="' + msg.ns + '"]');
      if (navbar && navbar._gtActivate) navbar._gtActivate(msg.selected);
    });

    Shiny.addCustomMessageHandler('glasstabs_show_tab', function (msg) {
      var navbar = document.querySelector('.gt-navbar[data-ns="' + msg.ns + '"]');
      if (!navbar) return;
      var link = navbar.querySelector('.gt-tab-link[data-value="' + msg.value + '"]');
      if (!link) return;
      link.classList.remove('gt-tab-hidden');
      link.style.display = '';
      link.setAttribute('aria-hidden', 'false');
      if (navbar._gtResizeHandler) {
        setTimeout(function () { navbar._gtResizeHandler(); }, 0);
      }
    });

    Shiny.addCustomMessageHandler('glasstabs_hide_tab', function (msg) {
      var navbar = document.querySelector('.gt-navbar[data-ns="' + msg.ns + '"]');
      if (!navbar) return;
      var link = navbar.querySelector('.gt-tab-link[data-value="' + msg.value + '"]');
      if (!link) return;
      var container = navbar.closest('.gt-container')
        || navbar.closest('.card-body')
        || navbar.closest('.box-body')
        || (navbar.parentElement && navbar.parentElement.parentElement)
        || navbar.parentElement;
      var pane = document.getElementById(msg.ns + '-pane-' + msg.value);
      var wasActive = link.classList.contains('active');

      link.classList.remove('active');
      link.classList.add('gt-tab-hidden');
      link.style.display = 'none';
      link.setAttribute('aria-selected', 'false');
      link.setAttribute('aria-hidden', 'true');
      if (pane) pane.classList.remove('active');

      if (wasActive && navbar._gtActivate) {
        var first = navbar.querySelector('.gt-tab-link:not(.gt-tab-hidden)');
        if (first) navbar._gtActivate(first.getAttribute('data-value'), true);
      } else if (!wasActive && container && !container.querySelector('.gt-tab-pane.active')) {
        var currentActive = navbar.querySelector('.gt-tab-link.active:not(.gt-tab-hidden)');
        if (currentActive) {
          var currentPane = document.getElementById(msg.ns + '-pane-' + currentActive.getAttribute('data-value'));
          if (currentPane) currentPane.classList.add('active');
        }
      }
      if (!wasActive && navbar._gtResizeHandler) {
        setTimeout(function () { navbar._gtResizeHandler(); }, 0);
      }
    });

    Shiny.addCustomMessageHandler('glasstabs_append_tab', function (msg) {
      var navbar = document.querySelector('.gt-navbar[data-ns="' + msg.ns + '"]');
      if (!navbar) return;
      if (navbar.querySelector('.gt-tab-link[data-value="' + msg.value + '"]')) return;

      var container = navbar.closest('.gt-container')
        || navbar.closest('.card-body')
        || navbar.closest('.box-body')
        || (navbar.parentElement && navbar.parentElement.parentElement)
        || navbar.parentElement;
      if (!container) return;

      var paneWrap = container.querySelector('.gt-tab-wrap');
      if (!paneWrap) return;

      if (msg.select) {
        navbar.querySelectorAll('.gt-tab-link.active').forEach(function (l) {
          l.classList.remove('active');
          l.setAttribute('aria-selected', 'false');
        });
        container.querySelectorAll('.gt-tab-pane.active').forEach(function (p) { p.classList.remove('active'); });
      }

      var tmp = document.createElement('div');
      tmp.innerHTML = msg.link_html;
      var newLink = tmp.firstElementChild;
      if (msg.select) {
        newLink.classList.add('active');
        newLink.setAttribute('aria-selected', 'true');
      }
      navbar.appendChild(newLink);

      tmp.innerHTML = msg.pane_html;
      var newPane = tmp.firstElementChild;
      if (msg.select) newPane.classList.add('active');
      paneWrap.appendChild(newPane);

      initTabs(navbar);
      if (navbar._gtResizeHandler) {
        setTimeout(function () { navbar._gtResizeHandler(); }, 0);
      }

      if (msg.select && window.Shiny) {
        Shiny.setInputValue(msg.ns + '-active_tab', msg.value, { priority: 'event' });
      }
    });

    Shiny.addCustomMessageHandler('glasstabs_remove_tab', function (msg) {
      var navbar = document.querySelector('.gt-navbar[data-ns="' + msg.ns + '"]');
      if (!navbar) return;
      var link = navbar.querySelector('.gt-tab-link[data-value="' + msg.value + '"]');
      if (!link) return;

      var container = navbar.closest('.gt-container')
        || navbar.closest('.card-body')
        || navbar.closest('.box-body')
        || (navbar.parentElement && navbar.parentElement.parentElement)
        || navbar.parentElement;

      var wasActive = link.classList.contains('active');
      var nextValue = null;

      if (wasActive) {
        var remaining = Array.from(navbar.querySelectorAll('.gt-tab-link:not(.gt-tab-hidden)'))
          .filter(function (l) { return l.getAttribute('data-value') !== msg.value; });
        if (remaining.length) {
          nextValue = remaining[0].getAttribute('data-value');
          remaining[0].classList.add('active');
          remaining[0].setAttribute('aria-selected', 'true');
          if (container) {
            var ap = container.querySelector('.gt-tab-pane.active');
            if (ap) ap.classList.remove('active');
            var nextPane = document.getElementById(msg.ns + '-pane-' + nextValue);
            if (nextPane) nextPane.classList.add('active');
          }
        }
      }

      link.remove();
      if (container) {
        var pane = document.getElementById(msg.ns + '-pane-' + msg.value);
        if (pane) pane.remove();
      }

      initTabs(navbar);
      if (navbar._gtResizeHandler) {
        setTimeout(function () { navbar._gtResizeHandler(); }, 0);
      }

      if (wasActive && nextValue && window.Shiny) {
        Shiny.setInputValue(msg.ns + '-active_tab', nextValue, { priority: 'event' });
      }
    });

    registerCustomMessageHandlers._done = true;
    if (window.Shiny && window.Shiny.setInputValue) {
      Shiny.setInputValue('glasstabs_debug_handlers_registered', true, { priority: 'event' });
    }
  }

  registerCustomMessageHandlers();
  document.addEventListener('shiny:sessioninitialized', registerCustomMessageHandlers);

})();
