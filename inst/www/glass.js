/* glasstabs v0.1.0 */
(function () {
  'use strict';

  function px(n) { return Math.round(n) + 'px'; }

  function centerOf(el, container) {
    var r  = el.getBoundingClientRect();
    var cr = container.getBoundingClientRect();
    return { x: r.left + r.width  / 2 - cr.left,
             y: r.top  + r.height / 2 - cr.top,
             w: r.width, h: r.height };
  }

  /* ══════════════════════════════════════════════════════
     TAB ENGINE
  ══════════════════════════════════════════════════════ */
  function initTabs(navbar) {
    var ns    = navbar.getAttribute('data-ns');

    /* ── Container resolution ──────────────────────────────────────────────
       Priority:
         1. Nearest .gt-container ancestor  (wrap = TRUE, plain Shiny)
         2. Nearest .card-body ancestor      (bs4Dash / Bootstrap cards)
         3. Nearest .box-body ancestor       (shinydashboard)
         4. Parent's parent                  (last resort)
    ─────────────────────────────────────────────────────────────────────── */
    var container = navbar.closest('.gt-container')
                 || navbar.closest('.card-body')
                 || navbar.closest('.box-body')
                 || navbar.parentElement.parentElement;

    var halo  = container.querySelector('.gt-halo');
    var trf   = container.querySelector('.gt-transfer');
    var links = Array.from(navbar.querySelectorAll('.gt-tab-link'));
    var order = links.map(function(l) { return l.getAttribute('data-value'); });
    var activeEl = links.find(function(l) { return l.classList.contains('active'); }) || links[0];
    var active = activeEl.getAttribute('data-value');

    if (!halo || !trf || links.length === 0) return;

    /* ── Halo positioning ──────────────────────────────────────────────────
       When wrap = FALSE (bs4Dash mode) the halo sits inside .card-body whose
       position may not be 'relative'. We force it so coordinate maths work.
    ─────────────────────────────────────────────────────────────────────── */
    var cs = getComputedStyle(container);
    if (cs.position === 'static') container.style.position = 'relative';

    function placeHalo(el, immediate, scale) {
      var c = centerOf(el, container), s = scale || 1;
      var w = Math.floor((c.w + 8) * s), h = Math.floor((c.h + 4) * s);
      var br = (parseFloat(getComputedStyle(el).borderRadius) || 12) + 1;
      function set() {
        halo.style.left = c.x + 'px'; halo.style.top  = c.y + 'px';
        halo.style.width = w + 'px';  halo.style.height = h + 'px';
        halo.style.borderRadius = br + 'px';
      }
      if (immediate) {
        halo.style.transition = 'none'; set();
        halo.style.opacity = 0.80; void halo.offsetWidth; halo.style.transition = '';
      } else {
        set(); halo.style.opacity = 0.92;
      }
    }

    function buildKF(cs2, fw, fh) {
      var f = [], sc = Math.max(1, cs2.length - 1);
      for (var i = 0; i < cs2.length; i++) {
        var p = cs2[i], off = i / sc, nf = off >= 0.7;
        var w = nf ? Math.round(fw * (0.45 + (off - 0.7) / 0.3 * 0.55)) : 40;
        var h = nf ? Math.round(fh * (0.45 + (off - 0.7) / 0.3 * 0.55)) : 14;
        f.push({ left: px(p.x), top: px(p.y), width: px(w), height: px(h),
                 opacity: nf ? 0.80 : 0.60, offset: off });
      }
      var last = cs2[cs2.length - 1];
      f.push({ left: px(last.x), top: px(last.y), width: px(fw), height: px(fh), opacity: 0, offset: 1 });
      return f;
    }

    function animateTransfer(fromEl, toEl) {
      var fi   = order.indexOf(fromEl.getAttribute('data-value'));
      var ti   = order.indexOf(toEl.getAttribute('data-value'));
      var step = ti > fi ? 1 : -1, pts = [];
      for (var i = fi; step > 0 ? i <= ti : i >= ti; i += step)
        pts.push(centerOf(navbar.querySelector('.gt-tab-link[data-value="' + order[i] + '"]'), container));
      var last = pts[pts.length - 1];
      var fw = Math.max(50, last.w), fh = Math.max(22, last.h * 0.70);
      trf.getAnimations().forEach(function(a) { a.cancel(); });
      var dur = 200 + Math.max(1, Math.abs(ti - fi)) * 55;
      trf.style.opacity = 0; trf.style.left = px(pts[0].x); trf.style.top = px(pts[0].y);
      trf.style.width = px(32); trf.style.height = px(11);
      trf.animate(buildKF(pts, fw, fh), { duration: dur, easing: 'cubic-bezier(.15,.9,.2,1)', fill: 'forwards' });
      trf.animate([
        { filter: 'blur(3px)',   opacity: 0 },
        { filter: 'blur(2.4px)', opacity: 0.88, offset: 0.10 },
        { filter: 'blur(2.8px)', opacity: 0.72, offset: 0.78 },
        { filter: 'blur(7px)',   opacity: 0,    offset: 1 }
      ], { duration: dur, easing: 'linear', fill: 'forwards' });
      return dur;
    }

    function initHalo() {
      var el = navbar.querySelector('.gt-tab-link.active');
      if (!el) return;
      requestAnimationFrame(function() {
        requestAnimationFrame(function() {
          requestAnimationFrame(function() {
            placeHalo(el, true, 0.90);
            setTimeout(function() { placeHalo(el, false, 1.0); }, 80);
          });
        });
      });
    }
    initHalo();
    if (document.fonts && document.fonts.ready) document.fonts.ready.then(initHalo).catch(function(){});

    links.forEach(function(link) {
      link.addEventListener('click', function() {
        var target = link.getAttribute('data-value');
        if (target === active) return;
        var fromEl = navbar.querySelector('.gt-tab-link[data-value="' + active  + '"]');
        var toEl   = navbar.querySelector('.gt-tab-link[data-value="' + target + '"]');
        links.forEach(function(t) { t.classList.remove('active'); });
        toEl.classList.add('active');
        placeHalo(fromEl, true, 1.0);
        halo.style.opacity = '0.38';
        var dur = animateTransfer(fromEl, toEl);

        setTimeout(function() {
          var ap = container.querySelector('.gt-tab-pane.active');
          if (ap) ap.classList.remove('active');
          var next = document.getElementById(ns + '-pane-' + target);
          if (next) next.classList.add('active');
          active = target;
          if (window.Shiny) Shiny.setInputValue(ns + '-active_tab', target, { priority: 'event' });
        }, Math.max(100, dur * 0.50));

        setTimeout(function() {
          placeHalo(toEl, false, 0.90);
          setTimeout(function() { placeHalo(toEl, false, 1.0); }, 80);
        }, dur * 0.60);

        setTimeout(function() {
          placeHalo(toEl, true, 1.0);
          halo.classList.remove('gt-arrival-pulse');
          void halo.offsetWidth;
          halo.classList.add('gt-arrival-pulse');
        }, dur);
      });
    });

    document.addEventListener('keydown', function(e) {
      if (!container.contains(document.activeElement) &&
          document.activeElement !== document.body) return;
      var idx = order.indexOf(active);
      if (e.key === 'ArrowRight') navbar.querySelector('.gt-tab-link[data-value="' + order[(idx + 1) % order.length] + '"]').click();
      if (e.key === 'ArrowLeft')  navbar.querySelector('.gt-tab-link[data-value="' + order[(idx - 1 + order.length) % order.length] + '"]').click();
    });

    window.addEventListener('resize', function() {
      placeHalo(navbar.querySelector('.gt-tab-link[data-value="' + active + '"]'), true, 1.0);
    });
  }

  /* ══════════════════════════════════════════════════════
     MULTI-SELECT ENGINE
  ══════════════════════════════════════════════════════ */
  function initMultiSelect(wrap) {
    var inputId     = wrap.getAttribute('data-input-id');
    var placeholder = wrap.getAttribute('data-placeholder') || 'Filter by Category';
    var trigger     = wrap.querySelector('.gt-ms-trigger');
    var dropdown    = wrap.querySelector('.gt-ms-dropdown');
    var allRow      = wrap.querySelector('.gt-ms-all');
    var options     = Array.from(wrap.querySelectorAll('.gt-ms-option'));
    var badge       = wrap.querySelector('.gt-ms-badge');
    var label       = wrap.querySelector('[id$="-label"]');
    var countEl     = wrap.querySelector('.gt-ms-count');
    var clearBtn    = wrap.querySelector('.gt-ms-clear');
    var searchIn    = wrap.querySelector('input[type="text"]');
    var styleBtns   = Array.from(wrap.querySelectorAll('.gt-style-btn'));
    var STYLES      = ['check-only', 'checkbox', 'filled'];
    var currentStyle = 'checkbox';
    STYLES.forEach(function(s) { if (wrap.classList.contains('style-' + s)) currentStyle = s; });

    function visibleChecked() {
      return options.filter(function(o) {
        return !o.classList.contains('hidden') && o.classList.contains('checked');
      });
    }
    function visible() {
      return options.filter(function(o) { return !o.classList.contains('hidden'); });
    }

    function syncAll() {
      var vc    = visibleChecked().length, v = visible().length;
      var allC  = options.filter(function(o) { return o.classList.contains('checked'); }).length;
      var total = options.length;

      allRow.classList.remove('checked', 'indeterminate');
      if (vc > 0 && vc === v) allRow.classList.add('checked');
      else if (vc > 0)        allRow.classList.add('indeterminate');

      badge.textContent = allC;
      badge.classList.toggle('hidden', allC < 2 || allC === total);
      countEl.textContent = allC + ' / ' + total + ' selected';

      if (allC === 0)           label.textContent = placeholder;
      else if (allC === total)  label.textContent = 'All categories';
      else if (allC === 1) {
        var s = options.find(function(o) { return o.classList.contains('checked'); });
        label.textContent = s ? s.querySelector('span').textContent : placeholder;
      } else                    label.textContent = 'Multiple selection';

      renderTags();
      sendToShiny();
    }

    function renderTags() {
      var sel = options.filter(function(o) { return o.classList.contains('checked'); });
      document.querySelectorAll('[data-tags-for="' + inputId + '"]').forEach(function(pane) {
        pane.innerHTML = '';
        if (sel.length === 0) {
          pane.innerHTML = '<span class="gt-no-filters">No filters active</span>';
          return;
        }
        sel.forEach(function(o) {
          var name = o.querySelector('span').textContent;
          var val  = o.getAttribute('data-value');
          var hue  = getComputedStyle(o).getPropertyValue('--opt-hue').trim() || '210';
          var tag  = document.createElement('div');
          tag.className = 'gt-filter-tag';
          if (currentStyle === 'filled') {
            tag.style.background  = 'hsla(' + hue + ',65%,50%,0.18)';
            tag.style.borderColor = 'hsla(' + hue + ',65%,60%,0.35)';
            tag.style.color       = 'hsl('  + hue + ',80%,78%)';
          }
          tag.innerHTML = name + '<span class="gt-remove-tag" data-value="' + val + '">&times;</span>';
          tag.querySelector('.gt-remove-tag').addEventListener('click', function() {
            var opt = wrap.querySelector('.gt-ms-option[data-value="' + val + '"]');
            if (opt) opt.classList.remove('checked');
            syncAll();
          });
          pane.appendChild(tag);
        });
      });
    }

    function sendToShiny() {
      var vals = options
        .filter(function(o) { return o.classList.contains('checked'); })
        .map(function(o) { return o.getAttribute('data-value'); });
      if (window.Shiny) {
        Shiny.setInputValue(inputId,               vals,         { priority: 'event' });
        Shiny.setInputValue(inputId + '_style',    currentStyle, { priority: 'event' });
      }
    }

    /* ── Open / close ── */
    trigger.addEventListener('click', function(e) {
      e.stopPropagation();
      if (dropdown.classList.contains('open')) close(); else open();
    });
    document.addEventListener('click', function(e) {
      if (!dropdown.contains(e.target) && e.target !== trigger) close();
    });
    function open()  { dropdown.classList.add('open');    trigger.classList.add('open');    searchIn.focus(); }
    function close() { dropdown.classList.remove('open'); trigger.classList.remove('open'); }

    /* ── Style switcher ── */
    styleBtns.forEach(function(btn) {
      btn.addEventListener('click', function() {
        var s = btn.getAttribute('data-style');
        if (s === currentStyle) return;
        styleBtns.forEach(function(b) { b.classList.remove('active'); });
        btn.classList.add('active');
        STYLES.forEach(function(st) { wrap.classList.remove('style-' + st); });
        wrap.classList.add('style-' + s);
        currentStyle = s;
        syncAll();
      });
    });

    /* ── Option clicks ── */
    options.forEach(function(opt) {
      opt.addEventListener('click', function() {
        opt.classList.toggle('checked');
        syncAll();
      });
    });

    /* ── Select all ── */
    allRow.addEventListener('click', function() {
      var v = visible();
      var anyUnchecked = v.some(function(o) { return !o.classList.contains('checked'); });
      v.forEach(function(o) {
        if (anyUnchecked) o.classList.add('checked');
        else              o.classList.remove('checked');
      });
      syncAll();
    });

    /* ── Clear all — does NOT close the dropdown ── */
    if (clearBtn) {
      clearBtn.addEventListener('click', function() {
        options.forEach(function(o) { o.classList.remove('checked'); });
        syncAll();
        /* intentionally no close() call here */
      });
    }

    /* ── Search ── */
    searchIn.addEventListener('input', function() {
      var q = searchIn.value.toLowerCase().trim();
      options.forEach(function(o) {
        o.classList.toggle('hidden',
          q !== '' && !o.querySelector('span').textContent.toLowerCase().includes(q));
      });
      syncAll();
    });

    syncAll();
  }

  /* ══════════════════════════════════════════════════════
     BOOT
  ══════════════════════════════════════════════════════ */
  function bootAll() {
    document.querySelectorAll('.gt-navbar:not([data-gt-init])').forEach(function(nb) {
      nb.setAttribute('data-gt-init', '1');
      initTabs(nb);
    });
    document.querySelectorAll('.gt-ms-wrap:not([data-gt-init])').forEach(function(w) {
      w.setAttribute('data-gt-init', '1');
      initMultiSelect(w);
    });
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', bootAll);
  } else {
    bootAll();
  }
  window.addEventListener('load', bootAll);

  if (typeof Shiny !== 'undefined') {
    Shiny.addCustomMessageHandler('glasstabs_reinit', function() { bootAll(); });
  }
  document.addEventListener('shiny:value', function() { setTimeout(bootAll, 50); });

})();
