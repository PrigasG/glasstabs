(function () {
  'use strict';

  /* UTILITIES */
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

  function asValueArray(value) {
    if (Array.isArray(value)) return value;
    if (value === null || typeof value === 'undefined') return [];
    return [value];
  }

  function parseBoolAttr(el, name) {
    return String(el.getAttribute(name) || '').toLowerCase() === 'true';
  }

  function parseIntAttr(el, name, fallback) {
    var parsed = parseInt(el.getAttribute(name), 10);
    return isNaN(parsed) ? fallback : parsed;
  }

  function parseJsonArrayAttr(el, name) {
    var raw = el.getAttribute(name);
    if (!raw) return [];
    try {
      var parsed = JSON.parse(raw);
      return Array.isArray(parsed) ? parsed.map(String) : [];
    } catch (e) {
      return [];
    }
  }

  function asChoiceArray(choices) {
    if (Array.isArray(choices)) return choices;
    if (choices && typeof choices === 'object') return Object.values(choices);
    return [];
  }

  function escapeHtml(x) {
    return String(x)
      .replace(/&/g, '&amp;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;')
      .replace(/"/g, '&quot;')
      .replace(/'/g, '&#39;');
  }

  function attrEquals(name, value) {
    var escaped = String(value)
      .replace(/\\/g, '\\\\')
      .replace(/"/g, '\\"')
      .replace(/\r?\n/g, '\\a ');
    return '[' + name + '="' + escaped + '"]';
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

  /** Hide group headers whose options are all hidden (e.g. by search).
      Walks the options container once; a header is shown only when at least
      one option between it and the next header is visible. */
  function syncOptgroupHeaders(container) {
    if (!container) return;
    var kids = container.children;
    var header = null;
    var anyVisible = false;
    for (var i = 0; i < kids.length; i++) {
      var el = kids[i];
      var isHeader = el.classList.contains('gt-gs-optgroup') ||
                     el.classList.contains('gt-ms-optgroup');
      var isOption = el.classList.contains('gt-gs-option') ||
                     el.classList.contains('gt-ms-option');
      if (isHeader) {
        if (header) header.classList.toggle('hidden', !anyVisible);
        header = el;
        anyVisible = false;
      } else if (isOption) {
        if (!el.classList.contains('hidden')) anyVisible = true;
      }
    }
    if (header) header.classList.toggle('hidden', !anyVisible);
  }

  /** Build a group-header node for the rebuilt-from-payload path. */
  function buildOptgroupNode(label, cssClass) {
    var h = document.createElement('div');
    h.className = cssClass;
    h.setAttribute('data-group', label);
    h.setAttribute('role', 'presentation');
    h.textContent = label;
    return h;
  }

  /** Lazy-init helper used by Shiny input bindings */
  function ensureInit(el) {
    if (el._gt) return el._gt;
    if (el.classList.contains('gt-gs-wrap')) initGlassSelect(el);
    else if (el.classList.contains('gt-ms-wrap')) initMultiSelect(el);
    return el._gt || null;
  }

  var MS_VARS = [
    '--ms-bg','--ms-border','--ms-text','--ms-accent','--ms-label',
    '--ms-ac-12','--ms-ac-16','--ms-ac-18','--ms-ac-22','--ms-ac-28',
    '--ms-ac-32','--ms-ac-40','--ms-ac-55','--ms-ac-60','--ms-ac-75',
    '--ms-tx-03','--ms-tx-04','--ms-tx-05','--ms-tx-06','--ms-tx-08',
    '--ms-tx-35','--ms-tx-45','--ms-tx-50','--ms-tx-80','--ms-ac-tx-75'
  ];

  var TELEPORT_CLASSES = ['style-checkbox','style-check-only','style-filled','theme-light','shape-square'];

  /** Teleport a dropdown to <body> so no parent overflow/transform can clip it */
  function teleportOpen(wrap, dropdown) {
    if (dropdown.parentNode === document.body) return;
    /* Read CSS vars from the field ancestor which has them via the scoped <style> tag.
       Falling back up the tree ensures we find them even in deeply nested layouts. */
    var source = wrap.closest ? (wrap.closest('.gt-ms-field, .gt-gs-field') || wrap) : wrap;
    var cs = getComputedStyle(source);
    var isLight = wrap.classList.contains('theme-light');
    var fallbacks = isLight
      ? { '--ms-bg': 'rgba(255,255,255,0.98)', '--ms-border': 'rgba(0,0,0,0.12)',
          '--ms-text': '#111111', '--ms-accent': '#2563eb', '--ms-label': '#111111' }
      : { '--ms-bg': 'rgba(9,20,42,0.97)', '--ms-border': 'rgba(255,255,255,0.10)',
          '--ms-text': '#cfe6ff', '--ms-accent': '#7ec3f7', '--ms-label': '#cfe6ff' };
    MS_VARS.forEach(function (v) {
      var val = cs.getPropertyValue(v).trim();
      if (val) dropdown.style.setProperty(v, val);
      else if (hasOwn(fallbacks, v)) dropdown.style.setProperty(v, fallbacks[v]);
    });
    /* Copy style/theme classes onto the dropdown so CSS ancestor selectors still match */
    TELEPORT_CLASSES.forEach(function (cls) {
      if (wrap.classList.contains(cls)) dropdown.classList.add(cls);
      else dropdown.classList.remove(cls);
    });
    document.body.appendChild(dropdown);
    /* Use absolute positioning so AdminLTE's overflow-x:hidden on body/html
       doesn't clip the dropdown (position:fixed breaks in those scroll contexts) */
    dropdown.style.position = 'absolute';
  }

  /** Move a teleported dropdown back to its wrap */
  function teleportClose(wrap, dropdown) {
    if (dropdown.parentNode !== document.body) return;
    MS_VARS.forEach(function (v) { dropdown.style.removeProperty(v); });
    dropdown.style.removeProperty('position');
    dropdown.style.removeProperty('top');
    dropdown.style.removeProperty('right');
    dropdown.style.removeProperty('left');
    TELEPORT_CLASSES.forEach(function (cls) { dropdown.classList.remove(cls); });
    wrap.appendChild(dropdown);
  }

  /** Close every open glasstabs dropdown except the one being opened */
  function closeAllDropdowns(except) {
    document.querySelectorAll('.gt-gs-wrap.gt-layer-active, .gt-ms-wrap.gt-layer-active').forEach(function (w) {
      if (w === except) return;
      w.classList.remove('gt-layer-active');
      var dd = w._gtDropdown || w.querySelector('.gt-gs-dropdown, .gt-ms-dropdown');
      if (dd) {
        dd.classList.remove('open');
        teleportClose(w, dd);
      }
      var trig = w.querySelector('.gt-gs-trigger, .gt-ms-trigger');
      if (trig) {
        trig.classList.remove('open');
        trig.setAttribute('aria-expanded', 'false');
      }
    });
  }

  /* TAB ENGINE */
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

    var container = navbar.closest('.gt-container, .gt-wrap-shell')
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
    if (window.Shiny && window.Shiny.setInputValue) {
      Shiny.setInputValue(ns + '-active_tab', active, { priority: 'deferred' });
    }

    /* Repair pane visibility to match link state.  When bootAll() re-runs
       initTabs mid-animation (e.g. triggered by shiny:value on dyn_out),
       clearTabTimers() kills the deferred pane-swap - leaving the active link
       and the visible pane out of sync.  Syncing here makes every re-init
       self-healing regardless of when it fires. */
    links.forEach(function (l) {
      var v = l.getAttribute('data-value');
      var pane = document.getElementById(ns + '-pane-' + v);
      if (!pane) return;
      if (l === activeEl) {
        pane.classList.add('active');
      } else {
        pane.classList.remove('active');
      }
    });

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
        /* Use the namespace-qualified ID so we never accidentally deactivate
           a nested glassTabsUI pane that also carries gt-tab-pane.active */
        var ap = document.getElementById(ns + '-pane-' + active);
        if (ap) ap.classList.remove('active');
        var next = document.getElementById(ns + '-pane-' + target);
        if (next) next.classList.add('active');
        active = target;
        if (window.Shiny) Shiny.setInputValue(ns + '-active_tab', target, { priority: 'event' });
        triggerShinyChange(navbar);
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

    /* Single delegated click handler - covers dynamically appended tabs */
    navbar._gtClickHandler = function (e) {
      var link = e.target.closest ? e.target.closest('.gt-tab-link') : null;
      if (!link || link.classList.contains('gt-tab-hidden')) return;
      activateTab(link.getAttribute('data-value'));
    };
    navbar.addEventListener('click', navbar._gtClickHandler);

    navbar._gtKeyHandler = function (e) {
      if (!navbar.contains(document.activeElement)) return;

      if (e.key === 'Enter' || e.key === ' ') {
        var focused = document.activeElement && document.activeElement.closest
          ? document.activeElement.closest('.gt-tab-link')
          : null;
        if (focused && !focused.classList.contains('gt-tab-hidden')) {
          e.preventDefault();
          activateTab(focused.getAttribute('data-value'));
        }
        return;
      }

      if (e.key !== 'ArrowRight' && e.key !== 'ArrowLeft') return;

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

  /* SINGLE-SELECT ENGINE */
  function initGlassSelect(wrap) {
    if (wrap._gtSelectInit) return;
    wrap._gtSelectInit = true;

    var inputId = wrap.getAttribute('data-input-id');
    var placeholder = wrap.getAttribute('data-placeholder') || 'Select an option';
    var serverMode = parseBoolAttr(wrap, 'data-server');
    var serverMinChars = parseIntAttr(wrap, 'data-server-min-chars', 0);

    /* DOM refs */
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

    wrap._gtDropdown = dropdown;

    /* Capture check SVG template before any rebuilds */
    var checkTemplate = wrap.querySelector('.gt-gs-check');
    var checkHtml = checkTemplate ? checkTemplate.innerHTML : '';

    /* Add scroll class to options container */
    if (optionsBox) optionsBox.classList.add('gt-gs-options-scroll');

    var statusRow = document.createElement('div');
    statusRow.className = 'gt-select-status hidden';
    statusRow.setAttribute('role', 'status');
    statusRow.setAttribute('aria-live', 'polite');

    /* Internal state */
    var state = {
      choices: [],     // [{label, value, hidden, _labelLower}]
      selected: null,  // string | null
      selectedLabel: null,
      loading: false,
      query: ''
    };

    /* Read initial state from R-generated DOM */
    Array.from(wrap.querySelectorAll('.gt-gs-option')).forEach(function (el) {
      var value = el.getAttribute('data-value');
      var span = el.querySelector('span');
      var label = span ? span.textContent : value;
      state.choices.push({
        label: label,
        value: value,
        hidden: false,
        disabled: el.classList.contains('disabled'),
        group: el.getAttribute('data-group') || '',
        _labelLower: label.toLowerCase()
      });
      if (el.classList.contains('selected')) {
        state.selected = value;
        state.selectedLabel = label;
      }
      bindOption(el);
    });

    /* State readers */
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

    function visibleChoiceCount() {
      var n = 0;
      state.choices.forEach(function (ch) {
        if (!ch.hidden) n++;
      });
      return n;
    }

    function setStatus(text, active, loading) {
      statusRow.textContent = text || '';
      statusRow.classList.toggle('hidden', !active);
      statusRow.classList.toggle('loading', !!loading);
      if (active && optionsBox && statusRow.parentNode !== optionsBox) {
        optionsBox.appendChild(statusRow);
      }
    }

    function updateStatus() {
      if (state.loading) {
        setStatus('Searching...', true, true);
      } else if (visibleChoiceCount() === 0) {
        setStatus('No matches', true, false);
      } else {
        setStatus('', false, false);
      }
    }

    /* DOM patching */
    function patchOptionClasses() {
      Array.from(dropdown.querySelectorAll('.gt-gs-option')).forEach(function (el) {
        var v = el.getAttribute('data-value');
        var isSelected = state.selected !== null && v === state.selected;
        el.classList.toggle('selected', isSelected);
        el.setAttribute('aria-selected', isSelected ? 'true' : 'false');
      });
    }

    function patchVisibility() {
      Array.from(dropdown.querySelectorAll('.gt-gs-option')).forEach(function (el) {
        var v = el.getAttribute('data-value');
        var ch = findChoice(v);
        el.classList.toggle('hidden', ch ? ch.hidden : false);
      });
      syncOptgroupHeaders(optionsBox);
    }

    /* UI sync (visual only, no Shiny notification) */
    function syncUI() {
      var ch = findChoice(state.selected);
      labelEl.textContent = ch ? ch.label : (state.selectedLabel || placeholder);
      patchOptionClasses();
      updateStatus();
    }

    /* Shiny notification */
    function commitSelection() {
      triggerShinyChange(wrap);
      if (window.Shiny) {
        Shiny.setInputValue(inputId, state.selected, { priority: 'event' });
      }
    }

    /* setValue with opts */
    function setValue(value, opts) {
      opts = opts || {};
      var doNotify = opts.notify !== false;
      var valueStr = (value === null || typeof value === 'undefined' || value === '') ? null : String(value);

      if (valueStr !== null && !findChoice(valueStr)) {
        if (opts.preserveMissingSelection) {
          state.selectedLabel = opts.label || state.selectedLabel;
        } else {
          valueStr = null;
        }
      }

      state.selected = valueStr;
      if (valueStr === null) {
        state.selectedLabel = null;
      } else {
        var selectedChoice = findChoice(valueStr);
        if (selectedChoice) state.selectedLabel = selectedChoice.label;
      }
      syncUI();
      if (doNotify) commitSelection();
    }

    /* Option click binding */
    function bindOption(opt) {
      if (!opt || opt._gtBound) return;
      opt._gtBound = true;

      opt.addEventListener('click', function () {
        setValue(opt.getAttribute('data-value'), { notify: true });
        close();
        trigger.focus();
      });
    }

    /* Build a single option DOM node */
    function buildOptionNode(ch) {
      var row = document.createElement('div');
      row.className = 'gt-gs-option';
      row.setAttribute('data-value', ch.value);
      row.setAttribute('role', 'option');
      row.setAttribute('aria-selected', state.selected !== null && ch.value === state.selected ? 'true' : 'false');
      if (ch.disabled) {
        row.classList.add('disabled');
        row.setAttribute('aria-disabled', 'true');
      }
      if (ch.group) row.setAttribute('data-group', ch.group);

      row.innerHTML =
        '<div class="gt-gs-check">' + checkHtml + '</div>' +
        '<span>' + escapeHtml(ch.label) + '</span>';

      bindOption(row);
      return row;
    }

    /* setChoices: rebuild from state */
    function setChoices(choices, opts) {
      opts = opts || {};
      var preserveSel = opts.preserveSelection !== false;
      var preserveMissingSel = opts.preserveMissingSelection === true;
      var doNotify = opts.notify !== false;

      var oldSelected = preserveSel ? state.selected : null;
      var oldSelectedLabel = preserveSel ? state.selectedLabel : null;
      choices = asChoiceArray(choices);
      state.loading = false;

      /* Update state */
      state.choices = choices.map(function (ch) {
        return {
          label: String(ch.label),
          value: String(ch.value),
          hidden: false,
          disabled: !!ch.disabled,
          group: ch.group ? String(ch.group) : '',
          _labelLower: String(ch.label).toLowerCase()
        };
      });

      /* Intersect selection */
      if (oldSelected !== null && findChoice(oldSelected)) {
        state.selected = oldSelected;
        state.selectedLabel = findChoice(oldSelected).label;
      } else if (oldSelected !== null && preserveMissingSel) {
        state.selected = oldSelected;
        state.selectedLabel = oldSelectedLabel;
      } else {
        state.selected = null;
        state.selectedLabel = null;
      }

      /* Rebuild DOM */
      var frag = document.createDocumentFragment();
      var prevGroup = '';
      state.choices.forEach(function (ch) {
        if (ch.group && ch.group !== prevGroup) {
          frag.appendChild(buildOptgroupNode(ch.group, 'gt-gs-optgroup'));
        }
        prevGroup = ch.group || '';
        frag.appendChild(buildOptionNode(ch));
      });
      optionsBox.innerHTML = '';
      optionsBox.appendChild(frag);
      optionsBox.appendChild(statusRow);

      /* Re-apply search if active */
      if (!serverMode && state.query) {
        applySearchNow(state.query);
      } else {
        syncOptgroupHeaders(optionsBox);
      }

      syncUI();
      if (doNotify) commitSelection();
    }

    /* Search (debounced) */
    function applySearchNow(q) {
      var qq = (q || '').toLowerCase().trim();
      state.query = qq;

      state.choices.forEach(function (ch) {
        ch.hidden = qq !== '' && ch._labelLower.indexOf(qq) === -1;
      });

      patchVisibility();
      updateStatus();
    }

    function sendServerSearch(q) {
      var query = (q || '').trim();
      state.query = query.toLowerCase();
      if (!window.Shiny || !window.Shiny.setInputValue) return;
      if (query.length < serverMinChars) query = '';
      state.loading = true;
      updateStatus();
      Shiny.setInputValue(inputId + '_search', {
        query: query,
        nonce: Date.now()
      }, { priority: 'event' });
    }

    var debouncedSearch = debounce(function () {
      if (serverMode) sendServerSearch(searchIn ? searchIn.value : '');
      else applySearchNow(searchIn ? searchIn.value : '');
    }, 75);

    /* Position the dropdown below the trigger 
       Uses document-space coordinates (viewport + scrollY) to match
       position:absolute on the body-appended teleported element.
       This avoids the position:fixed + overflow:hidden quirk in AdminLTE. */
    function positionDropdown() {
      var rect = trigger.getBoundingClientRect();
      var scrollY = window.pageYOffset || 0;
      var vw = window.innerWidth;
      var vh = window.innerHeight;
      var ddHeight = dropdown.offsetHeight || 0;
      var top = rect.bottom + scrollY + 8;
      /* Flip upward if not enough room below */
      if (rect.bottom + ddHeight + 8 > vh - 8 && rect.top - ddHeight - 8 > 0) {
        top = rect.top + scrollY - ddHeight - 8;
      }
      dropdown.style.top = top + 'px';
      if ((wrap.closest('[dir]') || document.documentElement).getAttribute('dir') === 'rtl') {
        var left = rect.left;
        if (left < 4) left = 4;
        dropdown.style.left = left + 'px';
        dropdown.style.right = 'auto';
      } else {
        /* Right-align with trigger; clamp to viewport edge */
        var right = vw - rect.right;
        if (right < 4) right = 4;
        dropdown.style.right = right + 'px';
        dropdown.style.left = 'auto';
      }
    }

    var openedAt = 0;

    /* Open / Close */
    function open() {
      closeAllDropdowns(wrap);
      wrap.classList.add('gt-layer-active');
      teleportOpen(wrap, dropdown);
      /* rAF ensures the browser has laid out the element in body before we
         read offsetHeight (needed for the upward-flip calculation) */
      requestAnimationFrame(function () {
        positionDropdown();
        dropdown.classList.add('open');
        trigger.classList.add('open');
        trigger.setAttribute('aria-expanded', 'true');
      });
      openedAt = Date.now();
      /* Delay focus so synthetic-click re-fires from AdminLTE don't close us */
      if (searchIn) setTimeout(function () { searchIn.focus(); }, 100);
    }

    function close() {
      wrap.classList.remove('gt-layer-active');
      dropdown.classList.remove('open');
      trigger.classList.remove('open');
      trigger.setAttribute('aria-expanded', 'false');
      teleportClose(wrap, dropdown);
    }

    function closeAndReturnFocus() {
      if (dropdown.classList.contains('open')) {
        close();
        trigger.focus();
      }
    }

    /* Event listeners */
    trigger.addEventListener('click', function (e) {
      e.stopPropagation();
      if (dropdown.classList.contains('open')) {
        /* Ignore close triggers within 500 ms of opening - prevents synthetic
           re-fires from focus changes (e.g. bs4Dash / AdminLTE environments) */
        if (Date.now() - openedAt < 500) return;
        close();
      } else {
        open();
      }
    });

    trigger.addEventListener('keydown', function (e) {
      if (e.key === 'Enter' || e.key === ' ') {
        e.preventDefault();
        if (dropdown.classList.contains('open')) closeAndReturnFocus();
        else open();
      } else if (e.key === 'Escape' || e.key === 'Tab') {
        closeAndReturnFocus();
      }
    });

    dropdown.addEventListener('keydown', function (e) {
      if (e.key === 'Escape' || e.key === 'Tab') closeAndReturnFocus();
    });

    wrap._gtDocClickHandler = function (e) {
      if (Date.now() - openedAt < 500) return;
      if (!wrap.contains(e.target) && !dropdown.contains(e.target)) close();
    };
    document.addEventListener('click', wrap._gtDocClickHandler);

    /* Reposition on scroll/resize while open */
    wrap._gtScrollHandler = function () {
      if (dropdown.classList.contains('open')) positionDropdown();
    };
    window.addEventListener('scroll', wrap._gtScrollHandler, true);
    window.addEventListener('resize', wrap._gtScrollHandler);

    if (clearBtn) {
      clearBtn.addEventListener('click', function (e) {
        e.stopPropagation();
        setValue(null, { notify: true });
      });
    }

    if (searchIn) {
      searchIn.addEventListener('input', debouncedSearch);
    }

    /* Destroy (lifecycle teardown) */
    function destroy() {
      if (wrap._gtDocClickHandler) {
        document.removeEventListener('click', wrap._gtDocClickHandler);
        wrap._gtDocClickHandler = null;
      }
      if (wrap._gtScrollHandler) {
        window.removeEventListener('scroll', wrap._gtScrollHandler, true);
        window.removeEventListener('resize', wrap._gtScrollHandler);
        wrap._gtScrollHandler = null;
      }
      teleportClose(wrap, dropdown);
      wrap._gtDropdown = null;
      wrap._gt = null;
      wrap._gtSelectInit = false;
    }

    /* Initial UI sync */
    syncUI();

    /* Emit initial value to Shiny */
    if (window.Shiny && window.Shiny.setInputValue) {
      Shiny.setInputValue(inputId, state.selected, { priority: 'deferred' });
      Shiny.setInputValue(inputId + '_ready', true, { priority: 'deferred' });
    }

    /* Public controller */
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
        STYLES.forEach(function (st) { wrap.classList.remove('style-' + st); dropdown.classList.remove('style-' + st); });
        wrap.classList.add('style-' + s);
        dropdown.classList.add('style-' + s);
        currentStyle = s;
      },
      setShape: function (sh) {
        var square = (sh === 'square');
        wrap.classList.toggle('shape-square', square);
        if (dropdown) dropdown.classList.toggle('shape-square', square);
      },
      setDisabledChoices: function (vals) {
        var disabled = new Set(asValueArray(vals));
        state.choices.forEach(function (ch) {
          ch.disabled = disabled.has(ch.value);
        });
        Array.from(dropdown.querySelectorAll('.gt-gs-option')).forEach(function (el) {
          var off = disabled.has(el.getAttribute('data-value'));
          el.classList.toggle('disabled', off);
          if (off) el.setAttribute('aria-disabled', 'true');
          else el.removeAttribute('aria-disabled');
        });
      },
      setDisabled: function (d) {
        var off = !!d;
        wrap.classList.toggle('gt-disabled', off);
        if (off) close();
        if (trigger) {
          trigger.setAttribute('tabindex', off ? '-1' : '0');
          if (off) trigger.setAttribute('aria-disabled', 'true');
          else trigger.removeAttribute('aria-disabled');
        }
      },
      clear: function (opts) {
        setValue(null, opts);
      },
      destroy: destroy,
      commitSelection: commitSelection
    };
  }

  /* MULTI-SELECT ENGINE */
  function initMultiSelect(wrap) {
    if (wrap._gtMultiInit) return;
    wrap._gtMultiInit = true;

    var inputId = wrap.getAttribute('data-input-id');
    var placeholder = wrap.getAttribute('data-placeholder') || 'Filter by Category';
    var allLabel = wrap.getAttribute('data-all-label') || 'All categories';
    var serverMode = parseBoolAttr(wrap, 'data-server');
    var serverMinChars = parseIntAttr(wrap, 'data-server-min-chars', 0);

    /* DOM refs */
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

    wrap._gtDropdown = dropdown;

    var STYLES = ['check-only', 'checkbox', 'filled'];
    var currentStyle = 'checkbox';
    STYLES.forEach(function (s) {
      if (wrap.classList.contains('style-' + s)) currentStyle = s;
    });

    /* Capture check SVG template */
    var checkTemplate = wrap.querySelector('.gt-ms-check');
    var checkHtml = checkTemplate ? checkTemplate.innerHTML : '';

    /* Add scroll class */
    if (optionsBox) optionsBox.classList.add('gt-ms-options-scroll');

    var statusRow = document.createElement('div');
    statusRow.className = 'gt-select-status hidden';
    statusRow.setAttribute('role', 'status');
    statusRow.setAttribute('aria-live', 'polite');

    /* Internal state */
    var state = {
      choices: [],          // [{label, value, hidden, hue, _labelLower}]
      selected: new Set(),  // Set of value strings
      total: parseIntAttr(wrap, 'data-server-total', null),
      loading: false,
      query: ''
    };

    /* Read initial state from R-generated DOM */
    Array.from(wrap.querySelectorAll('.gt-ms-option')).forEach(function (el) {
      var value = el.getAttribute('data-value');
      var span = el.querySelector('span');
      var label = span ? span.textContent : value;
      var hue = el.style.getPropertyValue('--opt-hue') || '210';

      state.choices.push({
        label: label,
        value: value,
        hidden: false,
        disabled: el.classList.contains('disabled'),
        group: el.getAttribute('data-group') || '',
        hue: parseInt(hue, 10) || 210,
        _labelLower: label.toLowerCase()
      });

      if (el.classList.contains('checked')) {
        state.selected.add(value);
      }

      bindOption(el);
    });

    parseJsonArrayAttr(wrap, 'data-selected-values').forEach(function (v) {
      state.selected.add(v);
    });

    /* State readers */
    function getValue() {
      /* Return in choice order, not Set insertion order */
      var out = [];
      var seen = new Set();
      state.choices.forEach(function (ch) {
        if (state.selected.has(ch.value)) {
          out.push(ch.value);
          seen.add(ch.value);
        }
      });
      state.selected.forEach(function (v) {
        if (!seen.has(v)) out.push(v);
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

    function setStatus(text, active, loading) {
      statusRow.textContent = text || '';
      statusRow.classList.toggle('hidden', !active);
      statusRow.classList.toggle('loading', !!loading);
      if (active && optionsBox && statusRow.parentNode !== optionsBox) {
        optionsBox.appendChild(statusRow);
      }
    }

    function updateStatus() {
      if (state.loading) {
        setStatus('Searching...', true, true);
      } else if (visibleChoices().length === 0) {
        setStatus('No matches', true, false);
      } else {
        setStatus('', false, false);
      }
    }

    /* DOM patching */
    function patchOptionClasses() {
      Array.from(dropdown.querySelectorAll('.gt-ms-option')).forEach(function (el) {
        var v = el.getAttribute('data-value');
        var isSelected = state.selected.has(v);
        el.classList.toggle('checked', isSelected);
        el.setAttribute('aria-selected', isSelected ? 'true' : 'false');
      });
    }

    function patchVisibility() {
      Array.from(dropdown.querySelectorAll('.gt-ms-option')).forEach(function (el) {
        var v = el.getAttribute('data-value');
        for (var i = 0; i < state.choices.length; i++) {
          if (state.choices[i].value === v) {
            el.classList.toggle('hidden', state.choices[i].hidden);
            break;
          }
        }
      });
      syncOptgroupHeaders(optionsBox);
    }

    /* syncUI: visual-only update */
    function syncUI() {
      var total = state.total === null ? state.choices.length : state.total;
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
        allRow.setAttribute('aria-selected', vis > 0 && visSel === vis ? 'true' : 'false');
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
          labelEl.textContent = first ? first.label : '1 selected';
        } else {
          labelEl.textContent = 'Multiple selection';
        }
      }

      patchOptionClasses();
      updateStatus();
      renderTags();
    }

    /* commitSelection: notify Shiny */
    function commitSelection() {
      triggerShinyChange(wrap);
      if (window.Shiny) {
        Shiny.setInputValue(inputId, getValue(), { priority: 'event' });
        Shiny.setInputValue(inputId + '_style', currentStyle, { priority: 'event' });
      }
    }

    /* renderTags: reads from state, not DOM */
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

    /* setValue with opts */
    function setValue(vals, opts) {
      opts = opts || {};
      var doNotify = opts.notify !== false;
      var preserveMissingSel = opts.preserveMissingSelection === true;
      var arr = Array.isArray(vals) ? vals.map(String) : [];

      state.selected = new Set();
      var validValues = new Set(state.choices.map(function (ch) { return ch.value; }));

      arr.forEach(function (v) {
        if (validValues.has(v) || preserveMissingSel) state.selected.add(v);
      });

      syncUI();
      if (doNotify) commitSelection();
    }

    /* Option click binding */
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

    /* Build a single option DOM node */
    function buildOptionNode(ch) {
      var row = document.createElement('div');
      row.className = 'gt-ms-option';
      row.setAttribute('data-value', ch.value);
      row.setAttribute('role', 'option');
      row.setAttribute('aria-selected', state.selected.has(ch.value) ? 'true' : 'false');
      row.style.setProperty('--opt-hue', String(ch.hue));

      if (state.selected.has(ch.value)) {
        row.className += ' checked';
      }
      if (ch.disabled) {
        row.classList.add('disabled');
        row.setAttribute('aria-disabled', 'true');
      }
      if (ch.group) row.setAttribute('data-group', ch.group);

      row.innerHTML =
        '<div class="gt-ms-check">' + checkHtml + '</div>' +
        '<span>' + escapeHtml(ch.label) + '</span>';

      bindOption(row);
      return row;
    }

    /* setChoices: rebuild from state */
    function setChoices(choices, opts) {
      opts = opts || {};
      var preserveSel = opts.preserveSelection !== false;
      var preserveMissingSel = opts.preserveMissingSelection === true;
      var doNotify = opts.notify !== false;
      var total = typeof opts.total === 'number' ? opts.total : null;

      var oldSelected = preserveSel ? new Set(state.selected) : new Set();
      choices = asChoiceArray(choices);
      state.loading = false;

      /* Update state */
      var n = choices.length;
      state.choices = choices.map(function (ch, i) {
        return {
          label: String(ch.label),
          value: String(ch.value),
          hidden: false,
          disabled: !!ch.disabled,
          group: ch.group ? String(ch.group) : '',
          hue: ch.hue || Math.round((200 + 360 * i / Math.max(1, n)) % 360),
          _labelLower: String(ch.label).toLowerCase()
        };
      });
      state.total = total === null ? state.choices.length : total;

      /* Intersect selection */
      var newValues = new Set(state.choices.map(function (ch) { return ch.value; }));
      state.selected = new Set();
      oldSelected.forEach(function (v) {
        if (newValues.has(v) || preserveMissingSel) state.selected.add(v);
      });

      /* Rebuild DOM using fragment */
      var frag = document.createDocumentFragment();
      var prevGroup = '';
      state.choices.forEach(function (ch) {
        if (ch.group && ch.group !== prevGroup) {
          frag.appendChild(buildOptgroupNode(ch.group, 'gt-ms-optgroup'));
        }
        prevGroup = ch.group || '';
        frag.appendChild(buildOptionNode(ch));
      });
      optionsBox.innerHTML = '';
      optionsBox.appendChild(frag);
      optionsBox.appendChild(statusRow);

      /* Re-apply search if active */
      if (!serverMode && state.query) {
        applySearchNow(state.query);
      } else {
        syncOptgroupHeaders(optionsBox);
      }

      syncUI();
      if (doNotify) commitSelection();
    }

    /* Search (debounced) */
    function applySearchNow(q) {
      var qq = (q || '').toLowerCase().trim();
      state.query = qq;

      state.choices.forEach(function (ch) {
        ch.hidden = qq !== '' && ch._labelLower.indexOf(qq) === -1;
      });

      patchVisibility();
      /* Update allRow and counts without notifying Shiny */
      var vis = visibleChoices().length;
      var visSel = visibleSelectedCount();

      if (allRow) {
        allRow.classList.remove('checked', 'indeterminate');
        if (visSel > 0 && visSel === vis) {
          allRow.classList.add('checked');
        } else if (visSel > 0) {
          allRow.classList.add('indeterminate');
        }
        allRow.setAttribute('aria-selected', vis > 0 && visSel === vis ? 'true' : 'false');
      }
      updateStatus();
    }

    function sendServerSearch(q) {
      var query = (q || '').trim();
      state.query = query.toLowerCase();
      if (!window.Shiny || !window.Shiny.setInputValue) return;
      if (query.length < serverMinChars) query = '';
      state.loading = true;
      updateStatus();
      Shiny.setInputValue(inputId + '_search', {
        query: query,
        nonce: Date.now()
      }, { priority: 'event' });
    }

    var debouncedSearch = debounce(function () {
      if (serverMode) sendServerSearch(searchIn ? searchIn.value : '');
      else applySearchNow(searchIn ? searchIn.value : '');
    }, 75);

    /* Position the dropdown below the trigger 
       Uses document-space coordinates (viewport + scrollY) to match
       position:absolute on the body-appended teleported element. */
    function positionDropdown() {
      var rect = trigger.getBoundingClientRect();
      var scrollY = window.pageYOffset || 0;
      var vw = window.innerWidth;
      var vh = window.innerHeight;
      var ddHeight = dropdown.offsetHeight || 0;
      var top = rect.bottom + scrollY + 8;
      /* Flip upward if not enough room below */
      if (rect.bottom + ddHeight + 8 > vh - 8 && rect.top - ddHeight - 8 > 0) {
        top = rect.top + scrollY - ddHeight - 8;
      }
      dropdown.style.top = top + 'px';
      if ((wrap.closest('[dir]') || document.documentElement).getAttribute('dir') === 'rtl') {
        var left = rect.left;
        if (left < 4) left = 4;
        dropdown.style.left = left + 'px';
        dropdown.style.right = 'auto';
      } else {
        /* Right-align with trigger; clamp to viewport edge */
        var right = vw - rect.right;
        if (right < 4) right = 4;
        dropdown.style.right = right + 'px';
        dropdown.style.left = 'auto';
      }
    }

    var openedAt = 0;

    /* Open / Close */
    function open() {
      closeAllDropdowns(wrap);
      wrap.classList.add('gt-layer-active');
      teleportOpen(wrap, dropdown);
      requestAnimationFrame(function () {
        positionDropdown();
        dropdown.classList.add('open');
        trigger.classList.add('open');
        trigger.setAttribute('aria-expanded', 'true');
      });
      openedAt = Date.now();
      /* Delay focus so synthetic-click re-fires from AdminLTE don't close us */
      if (searchIn) setTimeout(function () { searchIn.focus(); }, 100);
    }

    function close() {
      wrap.classList.remove('gt-layer-active');
      dropdown.classList.remove('open');
      trigger.classList.remove('open');
      trigger.setAttribute('aria-expanded', 'false');
      teleportClose(wrap, dropdown);
    }

    function closeAndReturnFocus() {
      if (dropdown.classList.contains('open')) {
        close();
        trigger.focus();
      }
    }

    /* Event listeners */
    trigger.addEventListener('click', function (e) {
      e.stopPropagation();
      if (dropdown.classList.contains('open')) {
        /* Ignore close triggers within 500 ms of opening - prevents synthetic
           re-fires from focus changes (e.g. bs4Dash / AdminLTE environments) */
        if (Date.now() - openedAt < 500) return;
        close();
      } else {
        open();
      }
    });

    trigger.addEventListener('keydown', function (e) {
      if (e.key === 'Enter' || e.key === ' ') {
        e.preventDefault();
        if (dropdown.classList.contains('open')) closeAndReturnFocus();
        else open();
      } else if (e.key === 'Escape' || e.key === 'Tab') {
        closeAndReturnFocus();
      }
    });

    dropdown.addEventListener('keydown', function (e) {
      if (e.key === 'Escape' || e.key === 'Tab') closeAndReturnFocus();
    });

    wrap._gtDocClickHandler = function (e) {
      if (Date.now() - openedAt < 500) return;
      if (!wrap.contains(e.target) && !dropdown.contains(e.target)) close();
    };
    document.addEventListener('click', wrap._gtDocClickHandler);

    /* Reposition on scroll/resize while open */
    wrap._gtScrollHandler = function () {
      if (dropdown.classList.contains('open')) positionDropdown();
    };
    window.addEventListener('scroll', wrap._gtScrollHandler, true);
    window.addEventListener('resize', wrap._gtScrollHandler);

    styleBtns.forEach(function (btn) {
      btn.addEventListener('click', function () {
        var s = btn.getAttribute('data-style');
        if (s === currentStyle || STYLES.indexOf(s) === -1) return;

        styleBtns.forEach(function (b) { b.classList.remove('active'); });
        btn.classList.add('active');

        STYLES.forEach(function (st) { wrap.classList.remove('style-' + st); dropdown.classList.remove('style-' + st); });
        wrap.classList.add('style-' + s);
        dropdown.classList.add('style-' + s);
        currentStyle = s;

        syncUI();
        commitSelection();
      });
    });

    if (allRow) {
      allRow.addEventListener('click', function () {
        /* Select-all only ever acts on enabled, visible options */
        var vis = visibleChoices().filter(function (ch) { return !ch.disabled; });
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

    /* Destroy (lifecycle teardown) */
    function destroy() {
      if (wrap._gtDocClickHandler) {
        document.removeEventListener('click', wrap._gtDocClickHandler);
        wrap._gtDocClickHandler = null;
      }
      if (wrap._gtScrollHandler) {
        window.removeEventListener('scroll', wrap._gtScrollHandler, true);
        window.removeEventListener('resize', wrap._gtScrollHandler);
        wrap._gtScrollHandler = null;
      }
      teleportClose(wrap, dropdown);
      wrap._gtDropdown = null;
      wrap._gt = null;
      wrap._gtMultiInit = false;
    }

    /* Initial sync */
    syncUI();

    /* Emit initial value to Shiny */
    if (window.Shiny && window.Shiny.setInputValue) {
      Shiny.setInputValue(inputId, getValue(), { priority: 'deferred' });
      Shiny.setInputValue(inputId + '_style', currentStyle, { priority: 'deferred' });
      Shiny.setInputValue(inputId + '_ready', true, { priority: 'deferred' });
    }

    /* Public controller */
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

        STYLES.forEach(function (st) { wrap.classList.remove('style-' + st); dropdown.classList.remove('style-' + st); });
        wrap.classList.add('style-' + s);
        dropdown.classList.add('style-' + s);
        currentStyle = s;

        syncUI();
        if (opts.notify !== false) commitSelection();
      },
      setShape: function (sh) {
        var square = (sh === 'square');
        wrap.classList.toggle('shape-square', square);
        if (dropdown) dropdown.classList.toggle('shape-square', square);
      },
      setDisabledChoices: function (vals) {
        var disabled = new Set(asValueArray(vals));
        state.choices.forEach(function (ch) {
          ch.disabled = disabled.has(ch.value);
        });
        Array.from(dropdown.querySelectorAll('.gt-ms-option')).forEach(function (el) {
          var off = disabled.has(el.getAttribute('data-value'));
          el.classList.toggle('disabled', off);
          if (off) el.setAttribute('aria-disabled', 'true');
          else el.removeAttribute('aria-disabled');
        });
        syncUI();
      },
      setDisabled: function (d) {
        var off = !!d;
        wrap.classList.toggle('gt-disabled', off);
        if (off) close();
        if (trigger) {
          trigger.setAttribute('tabindex', off ? '-1' : '0');
          if (off) trigger.setAttribute('aria-disabled', 'true');
          else trigger.removeAttribute('aria-disabled');
        }
      },
      clear: function (opts) {
        setValue([], opts);
      },
      destroy: destroy,
      /* Expose for binding - stable reference, not the closure var */
      commitSelection: commitSelection
    };
  }

  /* SHINY INPUT BINDINGS */
  function registerBindings() {
    if (typeof Shiny === 'undefined' || !window.jQuery || registerBindings._done) return;
    registerBindings._done = true;

    var $ = window.jQuery;

    var glassTabsBinding = new Shiny.InputBinding();
    $.extend(glassTabsBinding, {
      find: function (scope) {
        return $(scope).find('.gt-navbar');
      },
      getId: function (el) {
        var ns = el.getAttribute('data-ns');
        return ns ? ns + '-active_tab' : null;
      },
      getValue: function (el) {
        initTabs(el);
        var activeLink = el.querySelector('.gt-tab-link.active');
        return activeLink ? activeLink.getAttribute('data-value') : null;
      },
      subscribe: function (el, callback) {
        initTabs(el);
        $(el).on('change.glasstabs', function () {
          callback();
        });
      },
      unsubscribe: function (el) {
        $(el).off('.glasstabs');
      }
    });
    Shiny.inputBindings.register(glassTabsBinding, 'glasstabs.glassTabs');

    /* Single-select binding */
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
        var shouldCommit = false;

        if (hasOwn(data, 'choices')) {
          ctrl.setChoices(data.choices || [], { notify: false });
          shouldCommit = true;
        }

        if (hasOwn(data, 'selected')) {
          var sel = data.selected;
          if (Array.isArray(sel)) sel = sel.length ? sel[0] : null;
          if (sel === '') sel = null;
          ctrl.setValue(sel, { notify: false });
          shouldCommit = true;
        }

        if (hasOwn(data, 'style')) {
          ctrl.setStyle(data.style, { notify: false });
          shouldCommit = true;
        }

        if (hasOwn(data, 'shape') && typeof ctrl.setShape === 'function') {
          ctrl.setShape(data.shape);
        }

        if (hasOwn(data, 'disabled') && typeof ctrl.setDisabled === 'function') {
          ctrl.setDisabled(data.disabled);
        }

        if (hasOwn(data, 'disabled_choices') && typeof ctrl.setDisabledChoices === 'function') {
          ctrl.setDisabledChoices(data.disabled_choices);
        }

        /* Single commit after all fields are set */
        if (shouldCommit && ctrl.commitSelection) ctrl.commitSelection();
        if (shouldCommit) triggerShinyChange(el);
      }
    });
    Shiny.inputBindings.register(glassSelectBinding, 'glasstabs.glassSelect');

    /* Multi-select binding */
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
        var shouldCommit = false;

        if (hasOwn(data, 'choices')) {
          ctrl.setChoices(data.choices || [], { notify: false });
          shouldCommit = true;
        }

        if (hasOwn(data, 'selected')) {
          ctrl.setValue(asValueArray(data.selected), { notify: false });
          shouldCommit = true;
        }

        if (hasOwn(data, 'style')) {
          ctrl.setStyle(data.style, { notify: false });
          shouldCommit = true;
        }

        if (hasOwn(data, 'shape') && typeof ctrl.setShape === 'function') {
          ctrl.setShape(data.shape);
        }

        if (hasOwn(data, 'disabled') && typeof ctrl.setDisabled === 'function') {
          ctrl.setDisabled(data.disabled);
        }

        if (hasOwn(data, 'disabled_choices') && typeof ctrl.setDisabledChoices === 'function') {
          ctrl.setDisabledChoices(data.disabled_choices);
        }

        /* Single commit after all fields are set */
        if (shouldCommit && ctrl.commitSelection) ctrl.commitSelection();
        if (shouldCommit) triggerShinyChange(el);
      }
    });
    Shiny.inputBindings.register(glassMultiSelectBinding, 'glasstabs.glassMultiSelect');
  }

  /* BOOT */
  var bootTimer = null;

  function scheduleBoot() {
    if (bootTimer !== null) return;
    bootTimer = setTimeout(function () {
      bootTimer = null;
      bootAll();
    }, 0);
  }

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
    registerCustomMessageHandlers();
  }

  document.addEventListener('click', function (e) {
    var link = e.target && e.target.closest ? e.target.closest('.gt-tab-link') : null;
    if (!link || link.classList.contains('gt-tab-hidden') || link.classList.contains('gt-tab-disabled')) return;
    var navbar = link.closest ? link.closest('.gt-navbar') : null;
    if (!navbar) return;
    initTabs(navbar);
    if (navbar._gtActivate) navbar._gtActivate(link.getAttribute('data-value'));
  });

  document.addEventListener('keydown', function (e) {
    if (e.key !== 'Enter' && e.key !== ' ') return;
    var link = document.activeElement && document.activeElement.closest
      ? document.activeElement.closest('.gt-tab-link')
      : null;
    if (!link || link.classList.contains('gt-tab-hidden') || link.classList.contains('gt-tab-disabled')) return;
    var navbar = link.closest ? link.closest('.gt-navbar') : null;
    if (!navbar) return;
    e.preventDefault();
    initTabs(navbar);
    if (navbar._gtActivate) navbar._gtActivate(link.getAttribute('data-value'));
  });

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', bootAll);
  } else {
    bootAll();
  }

  window.addEventListener('load', bootAll);

  if (window.MutationObserver) {
    var bootObserver = new MutationObserver(function (mutations) {
      for (var i = 0; i < mutations.length; i++) {
        var nodes = mutations[i].addedNodes || [];
        for (var j = 0; j < nodes.length; j++) {
          var n = nodes[j];
          if (!n || n.nodeType !== 1) continue;
          if (
            (n.matches && n.matches('.gt-navbar, .gt-gs-wrap, .gt-ms-wrap')) ||
            (n.querySelector && n.querySelector('.gt-navbar, .gt-gs-wrap, .gt-ms-wrap'))
          ) {
            scheduleBoot();
            return;
          }
        }
      }
    });
    bootObserver.observe(document.documentElement, { childList: true, subtree: true });
  }

  /* Report the initial active tab for every navbar once the Shiny session
     is ready - so glassTabsServer() is never NULL on first render. */
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

    function applyMultiSelectUpdate(msg, attempt) {
      attempt = attempt || 0;
      var wrap = msg && msg.inputId
        ? document.querySelector('.gt-ms-wrap' + attrEquals('data-input-id', msg.inputId))
        : null;
      var ctrl = wrap ? ensureInit(wrap) : null;

      if (!ctrl) {
        if (attempt < 20) {
          setTimeout(function () { applyMultiSelectUpdate(msg, attempt + 1); }, 25);
        }
        return;
      }

      var data = msg.data || {};
      var shouldCommit = false;
      if (hasOwn(data, 'choices')) {
        ctrl.setChoices(data.choices || [], { notify: false });
        shouldCommit = true;
      }
      if (hasOwn(data, 'selected')) {
        ctrl.setValue(asValueArray(data.selected), { notify: false });
        shouldCommit = true;
      }
      if (hasOwn(data, 'style')) {
        ctrl.setStyle(data.style, { notify: false });
        shouldCommit = true;
      }
      if (hasOwn(data, 'shape') && typeof ctrl.setShape === 'function') {
        ctrl.setShape(data.shape);
      }
      if (hasOwn(data, 'disabled') && typeof ctrl.setDisabled === 'function') {
        ctrl.setDisabled(data.disabled);
      }
      if (hasOwn(data, 'disabled_choices') && typeof ctrl.setDisabledChoices === 'function') {
        ctrl.setDisabledChoices(data.disabled_choices);
      }
      if (shouldCommit && ctrl.commitSelection) ctrl.commitSelection();
    }

    Shiny.addCustomMessageHandler('glasstabs_reinit', function (msg) {
      bootAll();
    });

    Shiny.addCustomMessageHandler('glasstabs_update_multiselect', function (msg) {
      setTimeout(function () { applyMultiSelectUpdate(msg, 0); }, 50);
    });

    Shiny.addCustomMessageHandler('glasstabs_server_choices', function (msg) {
      if (!msg || !msg.inputId) return;
      var selector = msg.type === 'multi' ? '.gt-ms-wrap' : '.gt-gs-wrap';
      var wrap = document.querySelector(selector + attrEquals('data-input-id', msg.inputId));
      var ctrl = wrap ? ensureInit(wrap) : null;
      if (!ctrl || !ctrl.setChoices) return;

      ctrl.setChoices(msg.choices || [], {
        notify: false,
        preserveMissingSelection: true,
        total: typeof msg.total === 'number' ? msg.total : undefined
      });
    });

    Shiny.addCustomMessageHandler('glasstabs_update_tabs', function (msg) {
      if (!msg.ns || !msg.selected) return;
      var navbar = document.querySelector('.gt-navbar' + attrEquals('data-ns', msg.ns));
      if (navbar && navbar._gtActivate) navbar._gtActivate(msg.selected);
    });

    Shiny.addCustomMessageHandler('glasstabs_show_tab', function (msg) {
      var navbar = document.querySelector('.gt-navbar' + attrEquals('data-ns', msg.ns));
      if (!navbar) return;
      var link = navbar.querySelector('.gt-tab-link' + attrEquals('data-value', msg.value));
      if (!link) return;
      link.classList.remove('gt-tab-hidden');
      link.style.display = '';
      link.setAttribute('aria-hidden', 'false');
      if (navbar._gtResizeHandler) {
        setTimeout(function () { navbar._gtResizeHandler(); }, 0);
      }
    });

    Shiny.addCustomMessageHandler('glasstabs_hide_tab', function (msg) {
      var navbar = document.querySelector('.gt-navbar' + attrEquals('data-ns', msg.ns));
      if (!navbar) return;
      var link = navbar.querySelector('.gt-tab-link' + attrEquals('data-value', msg.value));
      if (!link) return;
      var container = navbar.closest('.gt-container, .gt-wrap-shell')
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
      } else if (!wasActive) {
        var currentActive = navbar.querySelector('.gt-tab-link.active:not(.gt-tab-hidden)');
        if (currentActive) {
          var currentPane = document.getElementById(msg.ns + '-pane-' + currentActive.getAttribute('data-value'));
          if (currentPane && !currentPane.classList.contains('active')) currentPane.classList.add('active');
        }
      }
      if (!wasActive && navbar._gtResizeHandler) {
        setTimeout(function () { navbar._gtResizeHandler(); }, 0);
      }
    });

    Shiny.addCustomMessageHandler('glasstabs_append_tab', function (msg) {
      var navbar = document.querySelector('.gt-navbar' + attrEquals('data-ns', msg.ns));
      if (!navbar) return;
      if (navbar.querySelector('.gt-tab-link' + attrEquals('data-value', msg.value))) return;

      var container = navbar.closest('.gt-container, .gt-wrap-shell')
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
          /* Deactivate only this namespace's pane - not nested glassTabsUI panes */
          var v = l.getAttribute('data-value');
          var p = document.getElementById(msg.ns + '-pane-' + v);
          if (p) p.classList.remove('active');
        });
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
      var navbar = document.querySelector('.gt-navbar' + attrEquals('data-ns', msg.ns));
      if (!navbar) return;
      var link = navbar.querySelector('.gt-tab-link' + attrEquals('data-value', msg.value));
      if (!link) return;

      var container = navbar.closest('.gt-container, .gt-wrap-shell')
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
          var ap = document.getElementById(msg.ns + '-pane-' + msg.value);
          if (ap) ap.classList.remove('active');
          var nextPane = document.getElementById(msg.ns + '-pane-' + nextValue);
          if (nextPane) nextPane.classList.add('active');
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

    Shiny.addCustomMessageHandler('glasstabs_disable_tab', function (msg) {
      var navbar = document.querySelector('.gt-navbar' + attrEquals('data-ns', msg.ns));
      if (!navbar) return;
      var link = navbar.querySelector('.gt-tab-link' + attrEquals('data-value', msg.value));
      if (!link) return;
      link.classList.add('gt-tab-disabled');
      link.setAttribute('aria-disabled', 'true');
      link.setAttribute('tabindex', '-1');
    });

    Shiny.addCustomMessageHandler('glasstabs_enable_tab', function (msg) {
      var navbar = document.querySelector('.gt-navbar' + attrEquals('data-ns', msg.ns));
      if (!navbar) return;
      var link = navbar.querySelector('.gt-tab-link' + attrEquals('data-value', msg.value));
      if (!link) return;
      link.classList.remove('gt-tab-disabled');
      link.removeAttribute('aria-disabled');
      link.setAttribute('tabindex', '0');
    });

    Shiny.addCustomMessageHandler('glasstabs_tab_badge', function (msg) {
      var navbar = document.querySelector('.gt-navbar' + attrEquals('data-ns', msg.ns));
      if (!navbar) return;
      var link = navbar.querySelector('.gt-tab-link' + attrEquals('data-value', msg.value));
      if (!link) return;
      var badge = link.querySelector('.gt-tab-badge');
      if (!badge) {
        badge = document.createElement('span');
        badge.className = 'gt-tab-badge';
        link.appendChild(badge);
      }
      var n = parseInt(msg.count, 10);
      if (isNaN(n) || n <= 0) {
        badge.textContent = '';
        badge.style.display = 'none';
      } else {
        badge.textContent = n > 99 ? '99+' : String(n);
        badge.style.display = '';
      }
    });

    registerCustomMessageHandlers._done = true;
  }

  /* Re-init glasstabs elements injected by renderGlassTabs / renderUI.
     Only fires bootAll() when the updated output actually contains glasstabs
     nodes, so ordinary Shiny outputs are not affected. */
  document.addEventListener('shiny:value', function (e) {
    var el = e.target || (e.binding && e.binding.el);
    if (!el) return;
    if (el.querySelector('.gt-navbar, .gt-gs-wrap, .gt-ms-wrap')) {
      scheduleBoot();
    }
  });

  registerCustomMessageHandlers();
  document.addEventListener('shiny:sessioninitialized', registerCustomMessageHandlers);
  if (window.jQuery) {
    window.jQuery(document).on('shiny:sessioninitialized.glasstabs', function () {
      registerBindings();
      registerCustomMessageHandlers();
      bootAll();
    });
  }

})();
