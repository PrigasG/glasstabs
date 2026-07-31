# representative widget HTML remains byte-stable

    Code
      for (i in seq_len(nrow(configurations))) {
        theme <- configurations$theme[[i]]
        shape <- configurations$shape[[i]]
        cat("\nTABS:", theme, shape, "\n")
        cat(as.character(glassTabsUI("tabs", glassTabPanel("one", "One", shiny::p(
          "First"), selected = TRUE), glassTabPanel("two", "Two", shiny::p("Second"),
        icon = shiny::icon("table")), theme = theme, shape = shape)))
        cat("\nMULTISELECT:", theme, shape, "\n")
        cat(as.character(glassMultiSelect("multi", choices, selected = "apple",
          theme = theme, shape = shape)))
        cat("\nSELECT:", theme, shape, "\n")
        cat(as.character(glassSelect("single", choices, selected = "banana", theme = theme,
          shape = shape)))
        cat("\n")
      }
    Output
      
      TABS: dark rounded 
      <div class="gt-container gt-align-center" id="tabs-wrap">
        <style>#tabs-wrap{--gt-tab-text:rgba(207,230,255,0.78);--gt-tab-active-text:#ffffff;--gt-halo-bg:rgba(126,195,247,0.16);--gt-halo-border:rgba(126,195,247,0.38);--gt-halo-shadow:inset 0 1px 0 rgba(255,255,255,.22),inset 0 -1px 0 rgba(255,255,255,.06),0 6px 20px rgba(0,0,0,.38),0 0 0 1px rgba(255,255,255,.03);--gt-content-bg:transparent;--gt-content-border:transparent;--gt-card-bg:transparent;--gt-card-text:#cfe6ff;}</style>
        <div class="gt-topbar">
          <div class="gt-navbar" id="tabs-navbar" data-ns="tabs" role="tablist" aria-orientation="horizontal">
            <div class="gt-tab-link active" data-value="one" data-ns="tabs" role="tab" tabindex="0" aria-selected="true">One</div>
            <div class="gt-tab-link " data-value="two" data-ns="tabs" role="tab" tabindex="0" aria-selected="false">
              <span class="gt-tab-icon">
                <i class="fas fa-table" role="presentation" aria-label="table icon"></i>
              </span>
              <span class="gt-tab-label">Two</span>
            </div>
          </div>
        </div>
        <div class="gt-halo" id="tabs-halo"></div>
        <div class="gt-transfer" id="tabs-transfer"></div>
        <div class="gt-tab-wrap">
          <div class="gt-tab-pane active" id="tabs-pane-one" role="tabpanel">
            <div class="gt-card">
              <p>First</p>
            </div>
          </div>
          <div class="gt-tab-pane " id="tabs-pane-two" role="tabpanel">
            <div class="gt-card">
              <p>Second</p>
            </div>
          </div>
        </div>
      </div>
      MULTISELECT: dark rounded 
      <style>#multi-field{--ms-bg:rgba(9,20,42,0.97);--ms-border:rgba(255,255,255,0.10);--ms-text:#cfe6ff;--ms-accent:#7ec3f7;--ms-label:#cfe6ff;--ms-ac-12:rgba(126,195,247,0.120);--ms-ac-16:rgba(126,195,247,0.160);--ms-ac-18:rgba(126,195,247,0.180);--ms-ac-22:rgba(126,195,247,0.220);--ms-ac-28:rgba(126,195,247,0.280);--ms-ac-32:rgba(126,195,247,0.320);--ms-ac-40:rgba(126,195,247,0.400);--ms-ac-55:rgba(126,195,247,0.550);--ms-ac-60:rgba(126,195,247,0.600);--ms-ac-75:rgba(126,195,247,0.750);--ms-tx-03:rgba(207,230,255,0.030);--ms-tx-04:rgba(207,230,255,0.040);--ms-tx-05:rgba(207,230,255,0.050);--ms-tx-06:rgba(207,230,255,0.060);--ms-tx-08:rgba(207,230,255,0.080);--ms-tx-35:rgba(207,230,255,0.350);--ms-tx-45:rgba(207,230,255,0.450);--ms-tx-50:rgba(207,230,255,0.500);--ms-tx-80:rgba(207,230,255,0.800);--ms-ac-tx-75:rgba(146,204,249,1.000);}</style>
      <div class="gt-ms-field" id="multi-field">
        <div class="gt-ms-wrap style-checkbox    " id="multi-wrap" data-input-id="multi" data-placeholder="Filter by Category" data-all-label="All categories" data-server="false" data-server-total="2" data-server-min-chars="0" data-selected-values="[&quot;apple&quot;]">
          <div class="gt-ms-trigger" id="multi-trigger" role="combobox" tabindex="0" aria-haspopup="listbox" aria-expanded="false" aria-controls="multi-dropdown">
            <span id="multi-label">Apple</span>
            <div style="display:flex;align-items:center;gap:6px;">
              <span class="gt-ms-badge hidden" id="multi-badge">1</span>
              <svg class="gt-ms-chevron" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2">
                <path stroke-linecap="round" stroke-linejoin="round" d="M19 9l-7 7-7-7"></path>
              </svg>
            </div>
          </div>
          <div class="gt-ms-dropdown" id="multi-dropdown" role="listbox">
            <div class="gt-ms-search">
              <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="#7ec3f7" stroke-width="2.2">
                <circle cx="11" cy="11" r="8"></circle>
                <path stroke-linecap="round" d="M21 21l-4.35-4.35"></path>
              </svg>
              <input type="text" id="multi-search" placeholder="Search options..." autocomplete="off"/>
            </div>
            <div class="gt-style-switcher">
              <div class="gt-style-btn " data-style="check-only">
                <svg class="gt-sb-icon" viewBox="0 0 14 14" fill="none">
                  <path d="M2 7l3.5 4L12 3" stroke="#7ec3f7" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round"></path>
                </svg>
                <span>Check</span>
              </div>
              <div class="gt-style-btn active" data-style="checkbox">
                <svg class="gt-sb-icon" viewBox="0 0 14 14" fill="none">
                  <rect x="1.5" y="1.5" width="11" height="11" rx="3" stroke="#7ec3f7" stroke-width="1.6"></rect>
                  <path d="M3.5 7l2.8 3L10.5 4" stroke="#7ec3f7" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round"></path>
                </svg>
                <span>Box</span>
              </div>
              <div class="gt-style-btn " data-style="filled">
                <svg class="gt-sb-icon" viewBox="0 0 14 14" fill="none">
                  <rect x="1.5" y="1.5" width="11" height="11" rx="3" fill="#7ec3f7" fill-opacity="0.45" stroke="#7ec3f7" stroke-opacity="0.75" stroke-width="1.4"></rect>
                </svg>
                <span>Fill</span>
              </div>
            </div>
            <div class="gt-ms-all indeterminate" id="multi-all" role="option" aria-selected="false">
              <div class="gt-ms-check">
                <svg width="10" height="8" viewBox="0 0 10 8" fill="none">
                  <path d="M1 4l2.8 3L9 1" stroke="#7ec3f7" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"></path>
                </svg>
              </div>
              <span>Select all</span>
            </div>
            <div id="multi-options">
              <div class="gt-ms-option checked" data-value="apple" style="--opt-hue:200;" role="option" aria-selected="true">
                <div class="gt-ms-check">
                  <svg width="10" height="8" viewBox="0 0 10 8" fill="none">
                    <path d="M1 4l2.8 3L9 1" stroke="#7ec3f7" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"></path>
                  </svg>
                </div>
                <span>Apple</span>
              </div>
              <div class="gt-ms-option" data-value="banana" style="--opt-hue:20;" role="option" aria-selected="false">
                <div class="gt-ms-check">
                  <svg width="10" height="8" viewBox="0 0 10 8" fill="none">
                    <path d="M1 4l2.8 3L9 1" stroke="#7ec3f7" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"></path>
                  </svg>
                </div>
                <span>Banana</span>
              </div>
            </div>
            <div class="gt-ms-footer">
              <span class="gt-ms-count" id="multi-count">1 / 2 selected</span>
              <span class="gt-ms-clear" id="multi-clear">Clear all</span>
            </div>
          </div>
        </div>
      </div>
      SELECT: dark rounded 
      <style>#single-field{--ms-bg:rgba(9,20,42,0.97);--ms-border:rgba(255,255,255,0.10);--ms-text:#cfe6ff;--ms-accent:#7ec3f7;--ms-label:#cfe6ff;--ms-ac-12:rgba(126,195,247,0.120);--ms-ac-16:rgba(126,195,247,0.160);--ms-ac-18:rgba(126,195,247,0.180);--ms-ac-22:rgba(126,195,247,0.220);--ms-ac-28:rgba(126,195,247,0.280);--ms-ac-32:rgba(126,195,247,0.320);--ms-ac-40:rgba(126,195,247,0.400);--ms-ac-55:rgba(126,195,247,0.550);--ms-ac-60:rgba(126,195,247,0.600);--ms-ac-75:rgba(126,195,247,0.750);--ms-tx-03:rgba(207,230,255,0.030);--ms-tx-04:rgba(207,230,255,0.040);--ms-tx-05:rgba(207,230,255,0.050);--ms-tx-06:rgba(207,230,255,0.060);--ms-tx-08:rgba(207,230,255,0.080);--ms-tx-35:rgba(207,230,255,0.350);--ms-tx-45:rgba(207,230,255,0.450);--ms-tx-50:rgba(207,230,255,0.500);--ms-tx-80:rgba(207,230,255,0.800);--ms-ac-tx-75:rgba(146,204,249,1.000);}</style>
      <div class="gt-gs-field" id="single-field">
        <div class="gt-gs-wrap style-checkbox    " id="single-wrap" data-input-id="single" data-placeholder="Select an option" data-searchable="true" data-clearable="false" data-all-choice-label="All categories" data-all-choice-value="__all__" data-server="false" data-server-total="2" data-server-min-chars="0">
          <div class="gt-gs-trigger" id="single-trigger" role="combobox" tabindex="0" aria-haspopup="listbox" aria-expanded="false" aria-controls="single-dropdown">
            <span id="single-label">Banana</span>
            <div style="display:flex;align-items:center;gap:6px;">
              <span class="gt-gs-clear" id="single-clear" style="display:none;">Clear</span>
              <svg class="gt-gs-chevron" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2">
                <path stroke-linecap="round" stroke-linejoin="round" d="M19 9l-7 7-7-7"></path>
              </svg>
            </div>
          </div>
          <div class="gt-gs-dropdown" id="single-dropdown" role="listbox">
            <div class="gt-gs-search">
              <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="#7ec3f7" stroke-width="2.2">
                <circle cx="11" cy="11" r="8"></circle>
                <path stroke-linecap="round" d="M21 21l-4.35-4.35"></path>
              </svg>
              <input type="text" id="single-search" placeholder="Search options..." autocomplete="off"/>
            </div>
            <div id="single-options">
              <div class="gt-gs-option" data-value="apple" role="option" aria-selected="false">
                <div class="gt-gs-check">
                  <svg width="10" height="8" viewBox="0 0 10 8" fill="none">
                    <path d="M1 4l2.8 3L9 1" stroke="#7ec3f7" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"></path>
                  </svg>
                </div>
                <span>Apple</span>
              </div>
              <div class="gt-gs-option selected" data-value="banana" role="option" aria-selected="true">
                <div class="gt-gs-check">
                  <svg width="10" height="8" viewBox="0 0 10 8" fill="none">
                    <path d="M1 4l2.8 3L9 1" stroke="#7ec3f7" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"></path>
                  </svg>
                </div>
                <span>Banana</span>
              </div>
            </div>
          </div>
        </div>
      </div>
      
      TABS: light rounded 
      <div class="gt-container gt-align-center theme-light" id="tabs-wrap">
        <style>#tabs-wrap{--gt-tab-text:#374151;--gt-tab-active-text:#1d4ed8;--gt-halo-bg:rgba(37,99,235,0.12);--gt-halo-border:rgba(37,99,235,0.60);--gt-halo-shadow:inset 0 1px 0 rgba(255,255,255,.80),0 4px 16px rgba(37,99,235,.20),0 0 0 1px rgba(37,99,235,.12);--gt-content-bg:transparent;--gt-content-border:transparent;--gt-card-bg:transparent;--gt-card-text:#1e293b;}</style>
        <div class="gt-topbar">
          <div class="gt-navbar" id="tabs-navbar" data-ns="tabs" role="tablist" aria-orientation="horizontal">
            <div class="gt-tab-link active" data-value="one" data-ns="tabs" role="tab" tabindex="0" aria-selected="true">One</div>
            <div class="gt-tab-link " data-value="two" data-ns="tabs" role="tab" tabindex="0" aria-selected="false">
              <span class="gt-tab-icon">
                <i class="fas fa-table" role="presentation" aria-label="table icon"></i>
              </span>
              <span class="gt-tab-label">Two</span>
            </div>
          </div>
        </div>
        <div class="gt-halo" id="tabs-halo"></div>
        <div class="gt-transfer" id="tabs-transfer"></div>
        <div class="gt-tab-wrap">
          <div class="gt-tab-pane active" id="tabs-pane-one" role="tabpanel">
            <div class="gt-card">
              <p>First</p>
            </div>
          </div>
          <div class="gt-tab-pane " id="tabs-pane-two" role="tabpanel">
            <div class="gt-card">
              <p>Second</p>
            </div>
          </div>
        </div>
      </div>
      MULTISELECT: light rounded 
      <style>#multi-field{--ms-bg:rgba(255,255,255,0.98);--ms-border:rgba(0,0,0,0.12);--ms-text:#111111;--ms-accent:#2563eb;--ms-label:#111111;--ms-ac-12:rgba(37,99,235,0.120);--ms-ac-16:rgba(37,99,235,0.160);--ms-ac-18:rgba(37,99,235,0.180);--ms-ac-22:rgba(37,99,235,0.220);--ms-ac-28:rgba(37,99,235,0.280);--ms-ac-32:rgba(37,99,235,0.320);--ms-ac-40:rgba(37,99,235,0.400);--ms-ac-55:rgba(37,99,235,0.550);--ms-ac-60:rgba(37,99,235,0.600);--ms-ac-75:rgba(37,99,235,0.750);--ms-tx-03:rgba(17,17,17,0.030);--ms-tx-04:rgba(17,17,17,0.040);--ms-tx-05:rgba(17,17,17,0.050);--ms-tx-06:rgba(17,17,17,0.060);--ms-tx-08:rgba(17,17,17,0.080);--ms-tx-35:rgba(17,17,17,0.350);--ms-tx-45:rgba(17,17,17,0.450);--ms-tx-50:rgba(17,17,17,0.500);--ms-tx-80:rgba(17,17,17,0.800);--ms-ac-tx-75:rgba(32,78,180,1.000);}</style>
      <div class="gt-ms-field" id="multi-field">
        <div class="gt-ms-wrap style-checkbox    theme-light" id="multi-wrap" data-input-id="multi" data-placeholder="Filter by Category" data-all-label="All categories" data-server="false" data-server-total="2" data-server-min-chars="0" data-selected-values="[&quot;apple&quot;]">
          <div class="gt-ms-trigger" id="multi-trigger" role="combobox" tabindex="0" aria-haspopup="listbox" aria-expanded="false" aria-controls="multi-dropdown">
            <span id="multi-label">Apple</span>
            <div style="display:flex;align-items:center;gap:6px;">
              <span class="gt-ms-badge hidden" id="multi-badge">1</span>
              <svg class="gt-ms-chevron" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2">
                <path stroke-linecap="round" stroke-linejoin="round" d="M19 9l-7 7-7-7"></path>
              </svg>
            </div>
          </div>
          <div class="gt-ms-dropdown" id="multi-dropdown" role="listbox">
            <div class="gt-ms-search">
              <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="#2563eb" stroke-width="2.2">
                <circle cx="11" cy="11" r="8"></circle>
                <path stroke-linecap="round" d="M21 21l-4.35-4.35"></path>
              </svg>
              <input type="text" id="multi-search" placeholder="Search options..." autocomplete="off"/>
            </div>
            <div class="gt-style-switcher">
              <div class="gt-style-btn " data-style="check-only">
                <svg class="gt-sb-icon" viewBox="0 0 14 14" fill="none">
                  <path d="M2 7l3.5 4L12 3" stroke="#2563eb" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round"></path>
                </svg>
                <span>Check</span>
              </div>
              <div class="gt-style-btn active" data-style="checkbox">
                <svg class="gt-sb-icon" viewBox="0 0 14 14" fill="none">
                  <rect x="1.5" y="1.5" width="11" height="11" rx="3" stroke="#2563eb" stroke-width="1.6"></rect>
                  <path d="M3.5 7l2.8 3L10.5 4" stroke="#2563eb" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round"></path>
                </svg>
                <span>Box</span>
              </div>
              <div class="gt-style-btn " data-style="filled">
                <svg class="gt-sb-icon" viewBox="0 0 14 14" fill="none">
                  <rect x="1.5" y="1.5" width="11" height="11" rx="3" fill="#2563eb" fill-opacity="0.45" stroke="#2563eb" stroke-opacity="0.75" stroke-width="1.4"></rect>
                </svg>
                <span>Fill</span>
              </div>
            </div>
            <div class="gt-ms-all indeterminate" id="multi-all" role="option" aria-selected="false">
              <div class="gt-ms-check">
                <svg width="10" height="8" viewBox="0 0 10 8" fill="none">
                  <path d="M1 4l2.8 3L9 1" stroke="#2563eb" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"></path>
                </svg>
              </div>
              <span>Select all</span>
            </div>
            <div id="multi-options">
              <div class="gt-ms-option checked" data-value="apple" style="--opt-hue:200;" role="option" aria-selected="true">
                <div class="gt-ms-check">
                  <svg width="10" height="8" viewBox="0 0 10 8" fill="none">
                    <path d="M1 4l2.8 3L9 1" stroke="#2563eb" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"></path>
                  </svg>
                </div>
                <span>Apple</span>
              </div>
              <div class="gt-ms-option" data-value="banana" style="--opt-hue:20;" role="option" aria-selected="false">
                <div class="gt-ms-check">
                  <svg width="10" height="8" viewBox="0 0 10 8" fill="none">
                    <path d="M1 4l2.8 3L9 1" stroke="#2563eb" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"></path>
                  </svg>
                </div>
                <span>Banana</span>
              </div>
            </div>
            <div class="gt-ms-footer">
              <span class="gt-ms-count" id="multi-count">1 / 2 selected</span>
              <span class="gt-ms-clear" id="multi-clear">Clear all</span>
            </div>
          </div>
        </div>
      </div>
      SELECT: light rounded 
      <style>#single-field{--ms-bg:rgba(255,255,255,0.98);--ms-border:rgba(0,0,0,0.12);--ms-text:#111111;--ms-accent:#2563eb;--ms-label:#111111;--ms-ac-12:rgba(37,99,235,0.120);--ms-ac-16:rgba(37,99,235,0.160);--ms-ac-18:rgba(37,99,235,0.180);--ms-ac-22:rgba(37,99,235,0.220);--ms-ac-28:rgba(37,99,235,0.280);--ms-ac-32:rgba(37,99,235,0.320);--ms-ac-40:rgba(37,99,235,0.400);--ms-ac-55:rgba(37,99,235,0.550);--ms-ac-60:rgba(37,99,235,0.600);--ms-ac-75:rgba(37,99,235,0.750);--ms-tx-03:rgba(17,17,17,0.030);--ms-tx-04:rgba(17,17,17,0.040);--ms-tx-05:rgba(17,17,17,0.050);--ms-tx-06:rgba(17,17,17,0.060);--ms-tx-08:rgba(17,17,17,0.080);--ms-tx-35:rgba(17,17,17,0.350);--ms-tx-45:rgba(17,17,17,0.450);--ms-tx-50:rgba(17,17,17,0.500);--ms-tx-80:rgba(17,17,17,0.800);--ms-ac-tx-75:rgba(32,78,180,1.000);}</style>
      <div class="gt-gs-field" id="single-field">
        <div class="gt-gs-wrap style-checkbox    theme-light" id="single-wrap" data-input-id="single" data-placeholder="Select an option" data-searchable="true" data-clearable="false" data-all-choice-label="All categories" data-all-choice-value="__all__" data-server="false" data-server-total="2" data-server-min-chars="0">
          <div class="gt-gs-trigger" id="single-trigger" role="combobox" tabindex="0" aria-haspopup="listbox" aria-expanded="false" aria-controls="single-dropdown">
            <span id="single-label">Banana</span>
            <div style="display:flex;align-items:center;gap:6px;">
              <span class="gt-gs-clear" id="single-clear" style="display:none;">Clear</span>
              <svg class="gt-gs-chevron" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2">
                <path stroke-linecap="round" stroke-linejoin="round" d="M19 9l-7 7-7-7"></path>
              </svg>
            </div>
          </div>
          <div class="gt-gs-dropdown" id="single-dropdown" role="listbox">
            <div class="gt-gs-search">
              <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="#2563eb" stroke-width="2.2">
                <circle cx="11" cy="11" r="8"></circle>
                <path stroke-linecap="round" d="M21 21l-4.35-4.35"></path>
              </svg>
              <input type="text" id="single-search" placeholder="Search options..." autocomplete="off"/>
            </div>
            <div id="single-options">
              <div class="gt-gs-option" data-value="apple" role="option" aria-selected="false">
                <div class="gt-gs-check">
                  <svg width="10" height="8" viewBox="0 0 10 8" fill="none">
                    <path d="M1 4l2.8 3L9 1" stroke="#2563eb" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"></path>
                  </svg>
                </div>
                <span>Apple</span>
              </div>
              <div class="gt-gs-option selected" data-value="banana" role="option" aria-selected="true">
                <div class="gt-gs-check">
                  <svg width="10" height="8" viewBox="0 0 10 8" fill="none">
                    <path d="M1 4l2.8 3L9 1" stroke="#2563eb" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"></path>
                  </svg>
                </div>
                <span>Banana</span>
              </div>
            </div>
          </div>
        </div>
      </div>
      
      TABS: auto rounded 
      <div class="gt-container gt-align-center theme-auto theme-light" id="tabs-wrap">
        <style>#tabs-wrap{--gt-tab-text:#374151;--gt-tab-active-text:#1d4ed8;--gt-halo-bg:rgba(37,99,235,0.12);--gt-halo-border:rgba(37,99,235,0.60);--gt-halo-shadow:inset 0 1px 0 rgba(255,255,255,.80),0 4px 16px rgba(37,99,235,.20),0 0 0 1px rgba(37,99,235,.12);--gt-content-bg:transparent;--gt-content-border:transparent;--gt-card-bg:transparent;--gt-card-text:#1e293b;}</style>
        <style>[data-bs-theme="dark"] #tabs-wrap{--gt-tab-text:rgba(207,230,255,0.78);--gt-tab-active-text:#ffffff;--gt-halo-bg:rgba(126,195,247,0.16);--gt-halo-border:rgba(126,195,247,0.38);--gt-halo-shadow:inset 0 1px 0 rgba(255,255,255,.22),inset 0 -1px 0 rgba(255,255,255,.06),0 6px 20px rgba(0,0,0,.38),0 0 0 1px rgba(255,255,255,.03);--gt-content-bg:transparent;--gt-content-border:transparent;--gt-card-bg:transparent;--gt-card-text:#cfe6ff;}</style>
        <div class="gt-topbar">
          <div class="gt-navbar" id="tabs-navbar" data-ns="tabs" role="tablist" aria-orientation="horizontal">
            <div class="gt-tab-link active" data-value="one" data-ns="tabs" role="tab" tabindex="0" aria-selected="true">One</div>
            <div class="gt-tab-link " data-value="two" data-ns="tabs" role="tab" tabindex="0" aria-selected="false">
              <span class="gt-tab-icon">
                <i class="fas fa-table" role="presentation" aria-label="table icon"></i>
              </span>
              <span class="gt-tab-label">Two</span>
            </div>
          </div>
        </div>
        <div class="gt-halo" id="tabs-halo"></div>
        <div class="gt-transfer" id="tabs-transfer"></div>
        <div class="gt-tab-wrap">
          <div class="gt-tab-pane active" id="tabs-pane-one" role="tabpanel">
            <div class="gt-card">
              <p>First</p>
            </div>
          </div>
          <div class="gt-tab-pane " id="tabs-pane-two" role="tabpanel">
            <div class="gt-card">
              <p>Second</p>
            </div>
          </div>
        </div>
      </div>
      MULTISELECT: auto rounded 
      <style>#multi-field{--ms-bg:rgba(255,255,255,0.98);--ms-border:rgba(0,0,0,0.12);--ms-text:#111111;--ms-accent:#2563eb;--ms-label:#111111;--ms-ac-12:rgba(37,99,235,0.120);--ms-ac-16:rgba(37,99,235,0.160);--ms-ac-18:rgba(37,99,235,0.180);--ms-ac-22:rgba(37,99,235,0.220);--ms-ac-28:rgba(37,99,235,0.280);--ms-ac-32:rgba(37,99,235,0.320);--ms-ac-40:rgba(37,99,235,0.400);--ms-ac-55:rgba(37,99,235,0.550);--ms-ac-60:rgba(37,99,235,0.600);--ms-ac-75:rgba(37,99,235,0.750);--ms-tx-03:rgba(17,17,17,0.030);--ms-tx-04:rgba(17,17,17,0.040);--ms-tx-05:rgba(17,17,17,0.050);--ms-tx-06:rgba(17,17,17,0.060);--ms-tx-08:rgba(17,17,17,0.080);--ms-tx-35:rgba(17,17,17,0.350);--ms-tx-45:rgba(17,17,17,0.450);--ms-tx-50:rgba(17,17,17,0.500);--ms-tx-80:rgba(17,17,17,0.800);--ms-ac-tx-75:rgba(32,78,180,1.000);}</style>
      <style>[data-bs-theme="dark"] #multi-field{--ms-bg:rgba(9,20,42,0.97);--ms-border:rgba(255,255,255,0.10);--ms-text:#cfe6ff;--ms-accent:#7ec3f7;--ms-label:#cfe6ff;--ms-ac-12:rgba(126,195,247,0.120);--ms-ac-16:rgba(126,195,247,0.160);--ms-ac-18:rgba(126,195,247,0.180);--ms-ac-22:rgba(126,195,247,0.220);--ms-ac-28:rgba(126,195,247,0.280);--ms-ac-32:rgba(126,195,247,0.320);--ms-ac-40:rgba(126,195,247,0.400);--ms-ac-55:rgba(126,195,247,0.550);--ms-ac-60:rgba(126,195,247,0.600);--ms-ac-75:rgba(126,195,247,0.750);--ms-tx-03:rgba(207,230,255,0.030);--ms-tx-04:rgba(207,230,255,0.040);--ms-tx-05:rgba(207,230,255,0.050);--ms-tx-06:rgba(207,230,255,0.060);--ms-tx-08:rgba(207,230,255,0.080);--ms-tx-35:rgba(207,230,255,0.350);--ms-tx-45:rgba(207,230,255,0.450);--ms-tx-50:rgba(207,230,255,0.500);--ms-tx-80:rgba(207,230,255,0.800);--ms-ac-tx-75:rgba(146,204,249,1.000);}</style>
      <div class="gt-ms-field" id="multi-field">
        <div class="gt-ms-wrap style-checkbox   theme-auto theme-light" id="multi-wrap" data-input-id="multi" data-placeholder="Filter by Category" data-all-label="All categories" data-server="false" data-server-total="2" data-server-min-chars="0" data-selected-values="[&quot;apple&quot;]">
          <div class="gt-ms-trigger" id="multi-trigger" role="combobox" tabindex="0" aria-haspopup="listbox" aria-expanded="false" aria-controls="multi-dropdown">
            <span id="multi-label">Apple</span>
            <div style="display:flex;align-items:center;gap:6px;">
              <span class="gt-ms-badge hidden" id="multi-badge">1</span>
              <svg class="gt-ms-chevron" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2">
                <path stroke-linecap="round" stroke-linejoin="round" d="M19 9l-7 7-7-7"></path>
              </svg>
            </div>
          </div>
          <div class="gt-ms-dropdown" id="multi-dropdown" role="listbox">
            <div class="gt-ms-search">
              <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="#2563eb" stroke-width="2.2">
                <circle cx="11" cy="11" r="8"></circle>
                <path stroke-linecap="round" d="M21 21l-4.35-4.35"></path>
              </svg>
              <input type="text" id="multi-search" placeholder="Search options..." autocomplete="off"/>
            </div>
            <div class="gt-style-switcher">
              <div class="gt-style-btn " data-style="check-only">
                <svg class="gt-sb-icon" viewBox="0 0 14 14" fill="none">
                  <path d="M2 7l3.5 4L12 3" stroke="#2563eb" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round"></path>
                </svg>
                <span>Check</span>
              </div>
              <div class="gt-style-btn active" data-style="checkbox">
                <svg class="gt-sb-icon" viewBox="0 0 14 14" fill="none">
                  <rect x="1.5" y="1.5" width="11" height="11" rx="3" stroke="#2563eb" stroke-width="1.6"></rect>
                  <path d="M3.5 7l2.8 3L10.5 4" stroke="#2563eb" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round"></path>
                </svg>
                <span>Box</span>
              </div>
              <div class="gt-style-btn " data-style="filled">
                <svg class="gt-sb-icon" viewBox="0 0 14 14" fill="none">
                  <rect x="1.5" y="1.5" width="11" height="11" rx="3" fill="#2563eb" fill-opacity="0.45" stroke="#2563eb" stroke-opacity="0.75" stroke-width="1.4"></rect>
                </svg>
                <span>Fill</span>
              </div>
            </div>
            <div class="gt-ms-all indeterminate" id="multi-all" role="option" aria-selected="false">
              <div class="gt-ms-check">
                <svg width="10" height="8" viewBox="0 0 10 8" fill="none">
                  <path d="M1 4l2.8 3L9 1" stroke="#2563eb" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"></path>
                </svg>
              </div>
              <span>Select all</span>
            </div>
            <div id="multi-options">
              <div class="gt-ms-option checked" data-value="apple" style="--opt-hue:200;" role="option" aria-selected="true">
                <div class="gt-ms-check">
                  <svg width="10" height="8" viewBox="0 0 10 8" fill="none">
                    <path d="M1 4l2.8 3L9 1" stroke="#2563eb" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"></path>
                  </svg>
                </div>
                <span>Apple</span>
              </div>
              <div class="gt-ms-option" data-value="banana" style="--opt-hue:20;" role="option" aria-selected="false">
                <div class="gt-ms-check">
                  <svg width="10" height="8" viewBox="0 0 10 8" fill="none">
                    <path d="M1 4l2.8 3L9 1" stroke="#2563eb" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"></path>
                  </svg>
                </div>
                <span>Banana</span>
              </div>
            </div>
            <div class="gt-ms-footer">
              <span class="gt-ms-count" id="multi-count">1 / 2 selected</span>
              <span class="gt-ms-clear" id="multi-clear">Clear all</span>
            </div>
          </div>
        </div>
      </div>
      SELECT: auto rounded 
      <style>#single-field{--ms-bg:rgba(255,255,255,0.98);--ms-border:rgba(0,0,0,0.12);--ms-text:#111111;--ms-accent:#2563eb;--ms-label:#111111;--ms-ac-12:rgba(37,99,235,0.120);--ms-ac-16:rgba(37,99,235,0.160);--ms-ac-18:rgba(37,99,235,0.180);--ms-ac-22:rgba(37,99,235,0.220);--ms-ac-28:rgba(37,99,235,0.280);--ms-ac-32:rgba(37,99,235,0.320);--ms-ac-40:rgba(37,99,235,0.400);--ms-ac-55:rgba(37,99,235,0.550);--ms-ac-60:rgba(37,99,235,0.600);--ms-ac-75:rgba(37,99,235,0.750);--ms-tx-03:rgba(17,17,17,0.030);--ms-tx-04:rgba(17,17,17,0.040);--ms-tx-05:rgba(17,17,17,0.050);--ms-tx-06:rgba(17,17,17,0.060);--ms-tx-08:rgba(17,17,17,0.080);--ms-tx-35:rgba(17,17,17,0.350);--ms-tx-45:rgba(17,17,17,0.450);--ms-tx-50:rgba(17,17,17,0.500);--ms-tx-80:rgba(17,17,17,0.800);--ms-ac-tx-75:rgba(32,78,180,1.000);}</style>
      <style>[data-bs-theme="dark"] #single-field{--ms-bg:rgba(9,20,42,0.97);--ms-border:rgba(255,255,255,0.10);--ms-text:#cfe6ff;--ms-accent:#7ec3f7;--ms-label:#cfe6ff;--ms-ac-12:rgba(126,195,247,0.120);--ms-ac-16:rgba(126,195,247,0.160);--ms-ac-18:rgba(126,195,247,0.180);--ms-ac-22:rgba(126,195,247,0.220);--ms-ac-28:rgba(126,195,247,0.280);--ms-ac-32:rgba(126,195,247,0.320);--ms-ac-40:rgba(126,195,247,0.400);--ms-ac-55:rgba(126,195,247,0.550);--ms-ac-60:rgba(126,195,247,0.600);--ms-ac-75:rgba(126,195,247,0.750);--ms-tx-03:rgba(207,230,255,0.030);--ms-tx-04:rgba(207,230,255,0.040);--ms-tx-05:rgba(207,230,255,0.050);--ms-tx-06:rgba(207,230,255,0.060);--ms-tx-08:rgba(207,230,255,0.080);--ms-tx-35:rgba(207,230,255,0.350);--ms-tx-45:rgba(207,230,255,0.450);--ms-tx-50:rgba(207,230,255,0.500);--ms-tx-80:rgba(207,230,255,0.800);--ms-ac-tx-75:rgba(146,204,249,1.000);}</style>
      <div class="gt-gs-field" id="single-field">
        <div class="gt-gs-wrap style-checkbox   theme-auto theme-light" id="single-wrap" data-input-id="single" data-placeholder="Select an option" data-searchable="true" data-clearable="false" data-all-choice-label="All categories" data-all-choice-value="__all__" data-server="false" data-server-total="2" data-server-min-chars="0">
          <div class="gt-gs-trigger" id="single-trigger" role="combobox" tabindex="0" aria-haspopup="listbox" aria-expanded="false" aria-controls="single-dropdown">
            <span id="single-label">Banana</span>
            <div style="display:flex;align-items:center;gap:6px;">
              <span class="gt-gs-clear" id="single-clear" style="display:none;">Clear</span>
              <svg class="gt-gs-chevron" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2">
                <path stroke-linecap="round" stroke-linejoin="round" d="M19 9l-7 7-7-7"></path>
              </svg>
            </div>
          </div>
          <div class="gt-gs-dropdown" id="single-dropdown" role="listbox">
            <div class="gt-gs-search">
              <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="#2563eb" stroke-width="2.2">
                <circle cx="11" cy="11" r="8"></circle>
                <path stroke-linecap="round" d="M21 21l-4.35-4.35"></path>
              </svg>
              <input type="text" id="single-search" placeholder="Search options..." autocomplete="off"/>
            </div>
            <div id="single-options">
              <div class="gt-gs-option" data-value="apple" role="option" aria-selected="false">
                <div class="gt-gs-check">
                  <svg width="10" height="8" viewBox="0 0 10 8" fill="none">
                    <path d="M1 4l2.8 3L9 1" stroke="#2563eb" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"></path>
                  </svg>
                </div>
                <span>Apple</span>
              </div>
              <div class="gt-gs-option selected" data-value="banana" role="option" aria-selected="true">
                <div class="gt-gs-check">
                  <svg width="10" height="8" viewBox="0 0 10 8" fill="none">
                    <path d="M1 4l2.8 3L9 1" stroke="#2563eb" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"></path>
                  </svg>
                </div>
                <span>Banana</span>
              </div>
            </div>
          </div>
        </div>
      </div>
      
      TABS: dark square 
      <div class="gt-container shape-square gt-align-center" id="tabs-wrap">
        <style>#tabs-wrap{--gt-tab-text:rgba(207,230,255,0.78);--gt-tab-active-text:#ffffff;--gt-halo-bg:rgba(126,195,247,0.16);--gt-halo-border:rgba(126,195,247,0.38);--gt-halo-shadow:inset 0 1px 0 rgba(255,255,255,.22),inset 0 -1px 0 rgba(255,255,255,.06),0 6px 20px rgba(0,0,0,.38),0 0 0 1px rgba(255,255,255,.03);--gt-content-bg:transparent;--gt-content-border:transparent;--gt-card-bg:transparent;--gt-card-text:#cfe6ff;}</style>
        <div class="gt-topbar">
          <div class="gt-navbar" id="tabs-navbar" data-ns="tabs" role="tablist" aria-orientation="horizontal">
            <div class="gt-tab-link active" data-value="one" data-ns="tabs" role="tab" tabindex="0" aria-selected="true">One</div>
            <div class="gt-tab-link " data-value="two" data-ns="tabs" role="tab" tabindex="0" aria-selected="false">
              <span class="gt-tab-icon">
                <i class="fas fa-table" role="presentation" aria-label="table icon"></i>
              </span>
              <span class="gt-tab-label">Two</span>
            </div>
          </div>
        </div>
        <div class="gt-halo" id="tabs-halo"></div>
        <div class="gt-transfer" id="tabs-transfer"></div>
        <div class="gt-tab-wrap">
          <div class="gt-tab-pane active" id="tabs-pane-one" role="tabpanel">
            <div class="gt-card">
              <p>First</p>
            </div>
          </div>
          <div class="gt-tab-pane " id="tabs-pane-two" role="tabpanel">
            <div class="gt-card">
              <p>Second</p>
            </div>
          </div>
        </div>
      </div>
      MULTISELECT: dark square 
      <style>#multi-field{--ms-bg:rgba(9,20,42,0.97);--ms-border:rgba(255,255,255,0.10);--ms-text:#cfe6ff;--ms-accent:#7ec3f7;--ms-label:#cfe6ff;--ms-ac-12:rgba(126,195,247,0.120);--ms-ac-16:rgba(126,195,247,0.160);--ms-ac-18:rgba(126,195,247,0.180);--ms-ac-22:rgba(126,195,247,0.220);--ms-ac-28:rgba(126,195,247,0.280);--ms-ac-32:rgba(126,195,247,0.320);--ms-ac-40:rgba(126,195,247,0.400);--ms-ac-55:rgba(126,195,247,0.550);--ms-ac-60:rgba(126,195,247,0.600);--ms-ac-75:rgba(126,195,247,0.750);--ms-tx-03:rgba(207,230,255,0.030);--ms-tx-04:rgba(207,230,255,0.040);--ms-tx-05:rgba(207,230,255,0.050);--ms-tx-06:rgba(207,230,255,0.060);--ms-tx-08:rgba(207,230,255,0.080);--ms-tx-35:rgba(207,230,255,0.350);--ms-tx-45:rgba(207,230,255,0.450);--ms-tx-50:rgba(207,230,255,0.500);--ms-tx-80:rgba(207,230,255,0.800);--ms-ac-tx-75:rgba(146,204,249,1.000);}</style>
      <div class="gt-ms-field" id="multi-field">
        <div class="gt-ms-wrap style-checkbox shape-square   " id="multi-wrap" data-input-id="multi" data-placeholder="Filter by Category" data-all-label="All categories" data-server="false" data-server-total="2" data-server-min-chars="0" data-selected-values="[&quot;apple&quot;]">
          <div class="gt-ms-trigger" id="multi-trigger" role="combobox" tabindex="0" aria-haspopup="listbox" aria-expanded="false" aria-controls="multi-dropdown">
            <span id="multi-label">Apple</span>
            <div style="display:flex;align-items:center;gap:6px;">
              <span class="gt-ms-badge hidden" id="multi-badge">1</span>
              <svg class="gt-ms-chevron" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2">
                <path stroke-linecap="round" stroke-linejoin="round" d="M19 9l-7 7-7-7"></path>
              </svg>
            </div>
          </div>
          <div class="gt-ms-dropdown" id="multi-dropdown" role="listbox">
            <div class="gt-ms-search">
              <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="#7ec3f7" stroke-width="2.2">
                <circle cx="11" cy="11" r="8"></circle>
                <path stroke-linecap="round" d="M21 21l-4.35-4.35"></path>
              </svg>
              <input type="text" id="multi-search" placeholder="Search options..." autocomplete="off"/>
            </div>
            <div class="gt-style-switcher">
              <div class="gt-style-btn " data-style="check-only">
                <svg class="gt-sb-icon" viewBox="0 0 14 14" fill="none">
                  <path d="M2 7l3.5 4L12 3" stroke="#7ec3f7" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round"></path>
                </svg>
                <span>Check</span>
              </div>
              <div class="gt-style-btn active" data-style="checkbox">
                <svg class="gt-sb-icon" viewBox="0 0 14 14" fill="none">
                  <rect x="1.5" y="1.5" width="11" height="11" rx="3" stroke="#7ec3f7" stroke-width="1.6"></rect>
                  <path d="M3.5 7l2.8 3L10.5 4" stroke="#7ec3f7" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round"></path>
                </svg>
                <span>Box</span>
              </div>
              <div class="gt-style-btn " data-style="filled">
                <svg class="gt-sb-icon" viewBox="0 0 14 14" fill="none">
                  <rect x="1.5" y="1.5" width="11" height="11" rx="3" fill="#7ec3f7" fill-opacity="0.45" stroke="#7ec3f7" stroke-opacity="0.75" stroke-width="1.4"></rect>
                </svg>
                <span>Fill</span>
              </div>
            </div>
            <div class="gt-ms-all indeterminate" id="multi-all" role="option" aria-selected="false">
              <div class="gt-ms-check">
                <svg width="10" height="8" viewBox="0 0 10 8" fill="none">
                  <path d="M1 4l2.8 3L9 1" stroke="#7ec3f7" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"></path>
                </svg>
              </div>
              <span>Select all</span>
            </div>
            <div id="multi-options">
              <div class="gt-ms-option checked" data-value="apple" style="--opt-hue:200;" role="option" aria-selected="true">
                <div class="gt-ms-check">
                  <svg width="10" height="8" viewBox="0 0 10 8" fill="none">
                    <path d="M1 4l2.8 3L9 1" stroke="#7ec3f7" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"></path>
                  </svg>
                </div>
                <span>Apple</span>
              </div>
              <div class="gt-ms-option" data-value="banana" style="--opt-hue:20;" role="option" aria-selected="false">
                <div class="gt-ms-check">
                  <svg width="10" height="8" viewBox="0 0 10 8" fill="none">
                    <path d="M1 4l2.8 3L9 1" stroke="#7ec3f7" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"></path>
                  </svg>
                </div>
                <span>Banana</span>
              </div>
            </div>
            <div class="gt-ms-footer">
              <span class="gt-ms-count" id="multi-count">1 / 2 selected</span>
              <span class="gt-ms-clear" id="multi-clear">Clear all</span>
            </div>
          </div>
        </div>
      </div>
      SELECT: dark square 
      <style>#single-field{--ms-bg:rgba(9,20,42,0.97);--ms-border:rgba(255,255,255,0.10);--ms-text:#cfe6ff;--ms-accent:#7ec3f7;--ms-label:#cfe6ff;--ms-ac-12:rgba(126,195,247,0.120);--ms-ac-16:rgba(126,195,247,0.160);--ms-ac-18:rgba(126,195,247,0.180);--ms-ac-22:rgba(126,195,247,0.220);--ms-ac-28:rgba(126,195,247,0.280);--ms-ac-32:rgba(126,195,247,0.320);--ms-ac-40:rgba(126,195,247,0.400);--ms-ac-55:rgba(126,195,247,0.550);--ms-ac-60:rgba(126,195,247,0.600);--ms-ac-75:rgba(126,195,247,0.750);--ms-tx-03:rgba(207,230,255,0.030);--ms-tx-04:rgba(207,230,255,0.040);--ms-tx-05:rgba(207,230,255,0.050);--ms-tx-06:rgba(207,230,255,0.060);--ms-tx-08:rgba(207,230,255,0.080);--ms-tx-35:rgba(207,230,255,0.350);--ms-tx-45:rgba(207,230,255,0.450);--ms-tx-50:rgba(207,230,255,0.500);--ms-tx-80:rgba(207,230,255,0.800);--ms-ac-tx-75:rgba(146,204,249,1.000);}</style>
      <div class="gt-gs-field" id="single-field">
        <div class="gt-gs-wrap style-checkbox shape-square   " id="single-wrap" data-input-id="single" data-placeholder="Select an option" data-searchable="true" data-clearable="false" data-all-choice-label="All categories" data-all-choice-value="__all__" data-server="false" data-server-total="2" data-server-min-chars="0">
          <div class="gt-gs-trigger" id="single-trigger" role="combobox" tabindex="0" aria-haspopup="listbox" aria-expanded="false" aria-controls="single-dropdown">
            <span id="single-label">Banana</span>
            <div style="display:flex;align-items:center;gap:6px;">
              <span class="gt-gs-clear" id="single-clear" style="display:none;">Clear</span>
              <svg class="gt-gs-chevron" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2">
                <path stroke-linecap="round" stroke-linejoin="round" d="M19 9l-7 7-7-7"></path>
              </svg>
            </div>
          </div>
          <div class="gt-gs-dropdown" id="single-dropdown" role="listbox">
            <div class="gt-gs-search">
              <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="#7ec3f7" stroke-width="2.2">
                <circle cx="11" cy="11" r="8"></circle>
                <path stroke-linecap="round" d="M21 21l-4.35-4.35"></path>
              </svg>
              <input type="text" id="single-search" placeholder="Search options..." autocomplete="off"/>
            </div>
            <div id="single-options">
              <div class="gt-gs-option" data-value="apple" role="option" aria-selected="false">
                <div class="gt-gs-check">
                  <svg width="10" height="8" viewBox="0 0 10 8" fill="none">
                    <path d="M1 4l2.8 3L9 1" stroke="#7ec3f7" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"></path>
                  </svg>
                </div>
                <span>Apple</span>
              </div>
              <div class="gt-gs-option selected" data-value="banana" role="option" aria-selected="true">
                <div class="gt-gs-check">
                  <svg width="10" height="8" viewBox="0 0 10 8" fill="none">
                    <path d="M1 4l2.8 3L9 1" stroke="#7ec3f7" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"></path>
                  </svg>
                </div>
                <span>Banana</span>
              </div>
            </div>
          </div>
        </div>
      </div>
      
      TABS: light square 
      <div class="gt-container shape-square gt-align-center theme-light" id="tabs-wrap">
        <style>#tabs-wrap{--gt-tab-text:#374151;--gt-tab-active-text:#1d4ed8;--gt-halo-bg:rgba(37,99,235,0.12);--gt-halo-border:rgba(37,99,235,0.60);--gt-halo-shadow:inset 0 1px 0 rgba(255,255,255,.80),0 4px 16px rgba(37,99,235,.20),0 0 0 1px rgba(37,99,235,.12);--gt-content-bg:transparent;--gt-content-border:transparent;--gt-card-bg:transparent;--gt-card-text:#1e293b;}</style>
        <div class="gt-topbar">
          <div class="gt-navbar" id="tabs-navbar" data-ns="tabs" role="tablist" aria-orientation="horizontal">
            <div class="gt-tab-link active" data-value="one" data-ns="tabs" role="tab" tabindex="0" aria-selected="true">One</div>
            <div class="gt-tab-link " data-value="two" data-ns="tabs" role="tab" tabindex="0" aria-selected="false">
              <span class="gt-tab-icon">
                <i class="fas fa-table" role="presentation" aria-label="table icon"></i>
              </span>
              <span class="gt-tab-label">Two</span>
            </div>
          </div>
        </div>
        <div class="gt-halo" id="tabs-halo"></div>
        <div class="gt-transfer" id="tabs-transfer"></div>
        <div class="gt-tab-wrap">
          <div class="gt-tab-pane active" id="tabs-pane-one" role="tabpanel">
            <div class="gt-card">
              <p>First</p>
            </div>
          </div>
          <div class="gt-tab-pane " id="tabs-pane-two" role="tabpanel">
            <div class="gt-card">
              <p>Second</p>
            </div>
          </div>
        </div>
      </div>
      MULTISELECT: light square 
      <style>#multi-field{--ms-bg:rgba(255,255,255,0.98);--ms-border:rgba(0,0,0,0.12);--ms-text:#111111;--ms-accent:#2563eb;--ms-label:#111111;--ms-ac-12:rgba(37,99,235,0.120);--ms-ac-16:rgba(37,99,235,0.160);--ms-ac-18:rgba(37,99,235,0.180);--ms-ac-22:rgba(37,99,235,0.220);--ms-ac-28:rgba(37,99,235,0.280);--ms-ac-32:rgba(37,99,235,0.320);--ms-ac-40:rgba(37,99,235,0.400);--ms-ac-55:rgba(37,99,235,0.550);--ms-ac-60:rgba(37,99,235,0.600);--ms-ac-75:rgba(37,99,235,0.750);--ms-tx-03:rgba(17,17,17,0.030);--ms-tx-04:rgba(17,17,17,0.040);--ms-tx-05:rgba(17,17,17,0.050);--ms-tx-06:rgba(17,17,17,0.060);--ms-tx-08:rgba(17,17,17,0.080);--ms-tx-35:rgba(17,17,17,0.350);--ms-tx-45:rgba(17,17,17,0.450);--ms-tx-50:rgba(17,17,17,0.500);--ms-tx-80:rgba(17,17,17,0.800);--ms-ac-tx-75:rgba(32,78,180,1.000);}</style>
      <div class="gt-ms-field" id="multi-field">
        <div class="gt-ms-wrap style-checkbox shape-square   theme-light" id="multi-wrap" data-input-id="multi" data-placeholder="Filter by Category" data-all-label="All categories" data-server="false" data-server-total="2" data-server-min-chars="0" data-selected-values="[&quot;apple&quot;]">
          <div class="gt-ms-trigger" id="multi-trigger" role="combobox" tabindex="0" aria-haspopup="listbox" aria-expanded="false" aria-controls="multi-dropdown">
            <span id="multi-label">Apple</span>
            <div style="display:flex;align-items:center;gap:6px;">
              <span class="gt-ms-badge hidden" id="multi-badge">1</span>
              <svg class="gt-ms-chevron" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2">
                <path stroke-linecap="round" stroke-linejoin="round" d="M19 9l-7 7-7-7"></path>
              </svg>
            </div>
          </div>
          <div class="gt-ms-dropdown" id="multi-dropdown" role="listbox">
            <div class="gt-ms-search">
              <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="#2563eb" stroke-width="2.2">
                <circle cx="11" cy="11" r="8"></circle>
                <path stroke-linecap="round" d="M21 21l-4.35-4.35"></path>
              </svg>
              <input type="text" id="multi-search" placeholder="Search options..." autocomplete="off"/>
            </div>
            <div class="gt-style-switcher">
              <div class="gt-style-btn " data-style="check-only">
                <svg class="gt-sb-icon" viewBox="0 0 14 14" fill="none">
                  <path d="M2 7l3.5 4L12 3" stroke="#2563eb" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round"></path>
                </svg>
                <span>Check</span>
              </div>
              <div class="gt-style-btn active" data-style="checkbox">
                <svg class="gt-sb-icon" viewBox="0 0 14 14" fill="none">
                  <rect x="1.5" y="1.5" width="11" height="11" rx="3" stroke="#2563eb" stroke-width="1.6"></rect>
                  <path d="M3.5 7l2.8 3L10.5 4" stroke="#2563eb" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round"></path>
                </svg>
                <span>Box</span>
              </div>
              <div class="gt-style-btn " data-style="filled">
                <svg class="gt-sb-icon" viewBox="0 0 14 14" fill="none">
                  <rect x="1.5" y="1.5" width="11" height="11" rx="3" fill="#2563eb" fill-opacity="0.45" stroke="#2563eb" stroke-opacity="0.75" stroke-width="1.4"></rect>
                </svg>
                <span>Fill</span>
              </div>
            </div>
            <div class="gt-ms-all indeterminate" id="multi-all" role="option" aria-selected="false">
              <div class="gt-ms-check">
                <svg width="10" height="8" viewBox="0 0 10 8" fill="none">
                  <path d="M1 4l2.8 3L9 1" stroke="#2563eb" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"></path>
                </svg>
              </div>
              <span>Select all</span>
            </div>
            <div id="multi-options">
              <div class="gt-ms-option checked" data-value="apple" style="--opt-hue:200;" role="option" aria-selected="true">
                <div class="gt-ms-check">
                  <svg width="10" height="8" viewBox="0 0 10 8" fill="none">
                    <path d="M1 4l2.8 3L9 1" stroke="#2563eb" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"></path>
                  </svg>
                </div>
                <span>Apple</span>
              </div>
              <div class="gt-ms-option" data-value="banana" style="--opt-hue:20;" role="option" aria-selected="false">
                <div class="gt-ms-check">
                  <svg width="10" height="8" viewBox="0 0 10 8" fill="none">
                    <path d="M1 4l2.8 3L9 1" stroke="#2563eb" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"></path>
                  </svg>
                </div>
                <span>Banana</span>
              </div>
            </div>
            <div class="gt-ms-footer">
              <span class="gt-ms-count" id="multi-count">1 / 2 selected</span>
              <span class="gt-ms-clear" id="multi-clear">Clear all</span>
            </div>
          </div>
        </div>
      </div>
      SELECT: light square 
      <style>#single-field{--ms-bg:rgba(255,255,255,0.98);--ms-border:rgba(0,0,0,0.12);--ms-text:#111111;--ms-accent:#2563eb;--ms-label:#111111;--ms-ac-12:rgba(37,99,235,0.120);--ms-ac-16:rgba(37,99,235,0.160);--ms-ac-18:rgba(37,99,235,0.180);--ms-ac-22:rgba(37,99,235,0.220);--ms-ac-28:rgba(37,99,235,0.280);--ms-ac-32:rgba(37,99,235,0.320);--ms-ac-40:rgba(37,99,235,0.400);--ms-ac-55:rgba(37,99,235,0.550);--ms-ac-60:rgba(37,99,235,0.600);--ms-ac-75:rgba(37,99,235,0.750);--ms-tx-03:rgba(17,17,17,0.030);--ms-tx-04:rgba(17,17,17,0.040);--ms-tx-05:rgba(17,17,17,0.050);--ms-tx-06:rgba(17,17,17,0.060);--ms-tx-08:rgba(17,17,17,0.080);--ms-tx-35:rgba(17,17,17,0.350);--ms-tx-45:rgba(17,17,17,0.450);--ms-tx-50:rgba(17,17,17,0.500);--ms-tx-80:rgba(17,17,17,0.800);--ms-ac-tx-75:rgba(32,78,180,1.000);}</style>
      <div class="gt-gs-field" id="single-field">
        <div class="gt-gs-wrap style-checkbox shape-square   theme-light" id="single-wrap" data-input-id="single" data-placeholder="Select an option" data-searchable="true" data-clearable="false" data-all-choice-label="All categories" data-all-choice-value="__all__" data-server="false" data-server-total="2" data-server-min-chars="0">
          <div class="gt-gs-trigger" id="single-trigger" role="combobox" tabindex="0" aria-haspopup="listbox" aria-expanded="false" aria-controls="single-dropdown">
            <span id="single-label">Banana</span>
            <div style="display:flex;align-items:center;gap:6px;">
              <span class="gt-gs-clear" id="single-clear" style="display:none;">Clear</span>
              <svg class="gt-gs-chevron" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2">
                <path stroke-linecap="round" stroke-linejoin="round" d="M19 9l-7 7-7-7"></path>
              </svg>
            </div>
          </div>
          <div class="gt-gs-dropdown" id="single-dropdown" role="listbox">
            <div class="gt-gs-search">
              <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="#2563eb" stroke-width="2.2">
                <circle cx="11" cy="11" r="8"></circle>
                <path stroke-linecap="round" d="M21 21l-4.35-4.35"></path>
              </svg>
              <input type="text" id="single-search" placeholder="Search options..." autocomplete="off"/>
            </div>
            <div id="single-options">
              <div class="gt-gs-option" data-value="apple" role="option" aria-selected="false">
                <div class="gt-gs-check">
                  <svg width="10" height="8" viewBox="0 0 10 8" fill="none">
                    <path d="M1 4l2.8 3L9 1" stroke="#2563eb" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"></path>
                  </svg>
                </div>
                <span>Apple</span>
              </div>
              <div class="gt-gs-option selected" data-value="banana" role="option" aria-selected="true">
                <div class="gt-gs-check">
                  <svg width="10" height="8" viewBox="0 0 10 8" fill="none">
                    <path d="M1 4l2.8 3L9 1" stroke="#2563eb" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"></path>
                  </svg>
                </div>
                <span>Banana</span>
              </div>
            </div>
          </div>
        </div>
      </div>
      
      TABS: auto square 
      <div class="gt-container shape-square gt-align-center theme-auto theme-light" id="tabs-wrap">
        <style>#tabs-wrap{--gt-tab-text:#374151;--gt-tab-active-text:#1d4ed8;--gt-halo-bg:rgba(37,99,235,0.12);--gt-halo-border:rgba(37,99,235,0.60);--gt-halo-shadow:inset 0 1px 0 rgba(255,255,255,.80),0 4px 16px rgba(37,99,235,.20),0 0 0 1px rgba(37,99,235,.12);--gt-content-bg:transparent;--gt-content-border:transparent;--gt-card-bg:transparent;--gt-card-text:#1e293b;}</style>
        <style>[data-bs-theme="dark"] #tabs-wrap{--gt-tab-text:rgba(207,230,255,0.78);--gt-tab-active-text:#ffffff;--gt-halo-bg:rgba(126,195,247,0.16);--gt-halo-border:rgba(126,195,247,0.38);--gt-halo-shadow:inset 0 1px 0 rgba(255,255,255,.22),inset 0 -1px 0 rgba(255,255,255,.06),0 6px 20px rgba(0,0,0,.38),0 0 0 1px rgba(255,255,255,.03);--gt-content-bg:transparent;--gt-content-border:transparent;--gt-card-bg:transparent;--gt-card-text:#cfe6ff;}</style>
        <div class="gt-topbar">
          <div class="gt-navbar" id="tabs-navbar" data-ns="tabs" role="tablist" aria-orientation="horizontal">
            <div class="gt-tab-link active" data-value="one" data-ns="tabs" role="tab" tabindex="0" aria-selected="true">One</div>
            <div class="gt-tab-link " data-value="two" data-ns="tabs" role="tab" tabindex="0" aria-selected="false">
              <span class="gt-tab-icon">
                <i class="fas fa-table" role="presentation" aria-label="table icon"></i>
              </span>
              <span class="gt-tab-label">Two</span>
            </div>
          </div>
        </div>
        <div class="gt-halo" id="tabs-halo"></div>
        <div class="gt-transfer" id="tabs-transfer"></div>
        <div class="gt-tab-wrap">
          <div class="gt-tab-pane active" id="tabs-pane-one" role="tabpanel">
            <div class="gt-card">
              <p>First</p>
            </div>
          </div>
          <div class="gt-tab-pane " id="tabs-pane-two" role="tabpanel">
            <div class="gt-card">
              <p>Second</p>
            </div>
          </div>
        </div>
      </div>
      MULTISELECT: auto square 
      <style>#multi-field{--ms-bg:rgba(255,255,255,0.98);--ms-border:rgba(0,0,0,0.12);--ms-text:#111111;--ms-accent:#2563eb;--ms-label:#111111;--ms-ac-12:rgba(37,99,235,0.120);--ms-ac-16:rgba(37,99,235,0.160);--ms-ac-18:rgba(37,99,235,0.180);--ms-ac-22:rgba(37,99,235,0.220);--ms-ac-28:rgba(37,99,235,0.280);--ms-ac-32:rgba(37,99,235,0.320);--ms-ac-40:rgba(37,99,235,0.400);--ms-ac-55:rgba(37,99,235,0.550);--ms-ac-60:rgba(37,99,235,0.600);--ms-ac-75:rgba(37,99,235,0.750);--ms-tx-03:rgba(17,17,17,0.030);--ms-tx-04:rgba(17,17,17,0.040);--ms-tx-05:rgba(17,17,17,0.050);--ms-tx-06:rgba(17,17,17,0.060);--ms-tx-08:rgba(17,17,17,0.080);--ms-tx-35:rgba(17,17,17,0.350);--ms-tx-45:rgba(17,17,17,0.450);--ms-tx-50:rgba(17,17,17,0.500);--ms-tx-80:rgba(17,17,17,0.800);--ms-ac-tx-75:rgba(32,78,180,1.000);}</style>
      <style>[data-bs-theme="dark"] #multi-field{--ms-bg:rgba(9,20,42,0.97);--ms-border:rgba(255,255,255,0.10);--ms-text:#cfe6ff;--ms-accent:#7ec3f7;--ms-label:#cfe6ff;--ms-ac-12:rgba(126,195,247,0.120);--ms-ac-16:rgba(126,195,247,0.160);--ms-ac-18:rgba(126,195,247,0.180);--ms-ac-22:rgba(126,195,247,0.220);--ms-ac-28:rgba(126,195,247,0.280);--ms-ac-32:rgba(126,195,247,0.320);--ms-ac-40:rgba(126,195,247,0.400);--ms-ac-55:rgba(126,195,247,0.550);--ms-ac-60:rgba(126,195,247,0.600);--ms-ac-75:rgba(126,195,247,0.750);--ms-tx-03:rgba(207,230,255,0.030);--ms-tx-04:rgba(207,230,255,0.040);--ms-tx-05:rgba(207,230,255,0.050);--ms-tx-06:rgba(207,230,255,0.060);--ms-tx-08:rgba(207,230,255,0.080);--ms-tx-35:rgba(207,230,255,0.350);--ms-tx-45:rgba(207,230,255,0.450);--ms-tx-50:rgba(207,230,255,0.500);--ms-tx-80:rgba(207,230,255,0.800);--ms-ac-tx-75:rgba(146,204,249,1.000);}</style>
      <div class="gt-ms-field" id="multi-field">
        <div class="gt-ms-wrap style-checkbox shape-square  theme-auto theme-light" id="multi-wrap" data-input-id="multi" data-placeholder="Filter by Category" data-all-label="All categories" data-server="false" data-server-total="2" data-server-min-chars="0" data-selected-values="[&quot;apple&quot;]">
          <div class="gt-ms-trigger" id="multi-trigger" role="combobox" tabindex="0" aria-haspopup="listbox" aria-expanded="false" aria-controls="multi-dropdown">
            <span id="multi-label">Apple</span>
            <div style="display:flex;align-items:center;gap:6px;">
              <span class="gt-ms-badge hidden" id="multi-badge">1</span>
              <svg class="gt-ms-chevron" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2">
                <path stroke-linecap="round" stroke-linejoin="round" d="M19 9l-7 7-7-7"></path>
              </svg>
            </div>
          </div>
          <div class="gt-ms-dropdown" id="multi-dropdown" role="listbox">
            <div class="gt-ms-search">
              <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="#2563eb" stroke-width="2.2">
                <circle cx="11" cy="11" r="8"></circle>
                <path stroke-linecap="round" d="M21 21l-4.35-4.35"></path>
              </svg>
              <input type="text" id="multi-search" placeholder="Search options..." autocomplete="off"/>
            </div>
            <div class="gt-style-switcher">
              <div class="gt-style-btn " data-style="check-only">
                <svg class="gt-sb-icon" viewBox="0 0 14 14" fill="none">
                  <path d="M2 7l3.5 4L12 3" stroke="#2563eb" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round"></path>
                </svg>
                <span>Check</span>
              </div>
              <div class="gt-style-btn active" data-style="checkbox">
                <svg class="gt-sb-icon" viewBox="0 0 14 14" fill="none">
                  <rect x="1.5" y="1.5" width="11" height="11" rx="3" stroke="#2563eb" stroke-width="1.6"></rect>
                  <path d="M3.5 7l2.8 3L10.5 4" stroke="#2563eb" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round"></path>
                </svg>
                <span>Box</span>
              </div>
              <div class="gt-style-btn " data-style="filled">
                <svg class="gt-sb-icon" viewBox="0 0 14 14" fill="none">
                  <rect x="1.5" y="1.5" width="11" height="11" rx="3" fill="#2563eb" fill-opacity="0.45" stroke="#2563eb" stroke-opacity="0.75" stroke-width="1.4"></rect>
                </svg>
                <span>Fill</span>
              </div>
            </div>
            <div class="gt-ms-all indeterminate" id="multi-all" role="option" aria-selected="false">
              <div class="gt-ms-check">
                <svg width="10" height="8" viewBox="0 0 10 8" fill="none">
                  <path d="M1 4l2.8 3L9 1" stroke="#2563eb" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"></path>
                </svg>
              </div>
              <span>Select all</span>
            </div>
            <div id="multi-options">
              <div class="gt-ms-option checked" data-value="apple" style="--opt-hue:200;" role="option" aria-selected="true">
                <div class="gt-ms-check">
                  <svg width="10" height="8" viewBox="0 0 10 8" fill="none">
                    <path d="M1 4l2.8 3L9 1" stroke="#2563eb" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"></path>
                  </svg>
                </div>
                <span>Apple</span>
              </div>
              <div class="gt-ms-option" data-value="banana" style="--opt-hue:20;" role="option" aria-selected="false">
                <div class="gt-ms-check">
                  <svg width="10" height="8" viewBox="0 0 10 8" fill="none">
                    <path d="M1 4l2.8 3L9 1" stroke="#2563eb" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"></path>
                  </svg>
                </div>
                <span>Banana</span>
              </div>
            </div>
            <div class="gt-ms-footer">
              <span class="gt-ms-count" id="multi-count">1 / 2 selected</span>
              <span class="gt-ms-clear" id="multi-clear">Clear all</span>
            </div>
          </div>
        </div>
      </div>
      SELECT: auto square 
      <style>#single-field{--ms-bg:rgba(255,255,255,0.98);--ms-border:rgba(0,0,0,0.12);--ms-text:#111111;--ms-accent:#2563eb;--ms-label:#111111;--ms-ac-12:rgba(37,99,235,0.120);--ms-ac-16:rgba(37,99,235,0.160);--ms-ac-18:rgba(37,99,235,0.180);--ms-ac-22:rgba(37,99,235,0.220);--ms-ac-28:rgba(37,99,235,0.280);--ms-ac-32:rgba(37,99,235,0.320);--ms-ac-40:rgba(37,99,235,0.400);--ms-ac-55:rgba(37,99,235,0.550);--ms-ac-60:rgba(37,99,235,0.600);--ms-ac-75:rgba(37,99,235,0.750);--ms-tx-03:rgba(17,17,17,0.030);--ms-tx-04:rgba(17,17,17,0.040);--ms-tx-05:rgba(17,17,17,0.050);--ms-tx-06:rgba(17,17,17,0.060);--ms-tx-08:rgba(17,17,17,0.080);--ms-tx-35:rgba(17,17,17,0.350);--ms-tx-45:rgba(17,17,17,0.450);--ms-tx-50:rgba(17,17,17,0.500);--ms-tx-80:rgba(17,17,17,0.800);--ms-ac-tx-75:rgba(32,78,180,1.000);}</style>
      <style>[data-bs-theme="dark"] #single-field{--ms-bg:rgba(9,20,42,0.97);--ms-border:rgba(255,255,255,0.10);--ms-text:#cfe6ff;--ms-accent:#7ec3f7;--ms-label:#cfe6ff;--ms-ac-12:rgba(126,195,247,0.120);--ms-ac-16:rgba(126,195,247,0.160);--ms-ac-18:rgba(126,195,247,0.180);--ms-ac-22:rgba(126,195,247,0.220);--ms-ac-28:rgba(126,195,247,0.280);--ms-ac-32:rgba(126,195,247,0.320);--ms-ac-40:rgba(126,195,247,0.400);--ms-ac-55:rgba(126,195,247,0.550);--ms-ac-60:rgba(126,195,247,0.600);--ms-ac-75:rgba(126,195,247,0.750);--ms-tx-03:rgba(207,230,255,0.030);--ms-tx-04:rgba(207,230,255,0.040);--ms-tx-05:rgba(207,230,255,0.050);--ms-tx-06:rgba(207,230,255,0.060);--ms-tx-08:rgba(207,230,255,0.080);--ms-tx-35:rgba(207,230,255,0.350);--ms-tx-45:rgba(207,230,255,0.450);--ms-tx-50:rgba(207,230,255,0.500);--ms-tx-80:rgba(207,230,255,0.800);--ms-ac-tx-75:rgba(146,204,249,1.000);}</style>
      <div class="gt-gs-field" id="single-field">
        <div class="gt-gs-wrap style-checkbox shape-square  theme-auto theme-light" id="single-wrap" data-input-id="single" data-placeholder="Select an option" data-searchable="true" data-clearable="false" data-all-choice-label="All categories" data-all-choice-value="__all__" data-server="false" data-server-total="2" data-server-min-chars="0">
          <div class="gt-gs-trigger" id="single-trigger" role="combobox" tabindex="0" aria-haspopup="listbox" aria-expanded="false" aria-controls="single-dropdown">
            <span id="single-label">Banana</span>
            <div style="display:flex;align-items:center;gap:6px;">
              <span class="gt-gs-clear" id="single-clear" style="display:none;">Clear</span>
              <svg class="gt-gs-chevron" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2">
                <path stroke-linecap="round" stroke-linejoin="round" d="M19 9l-7 7-7-7"></path>
              </svg>
            </div>
          </div>
          <div class="gt-gs-dropdown" id="single-dropdown" role="listbox">
            <div class="gt-gs-search">
              <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="#2563eb" stroke-width="2.2">
                <circle cx="11" cy="11" r="8"></circle>
                <path stroke-linecap="round" d="M21 21l-4.35-4.35"></path>
              </svg>
              <input type="text" id="single-search" placeholder="Search options..." autocomplete="off"/>
            </div>
            <div id="single-options">
              <div class="gt-gs-option" data-value="apple" role="option" aria-selected="false">
                <div class="gt-gs-check">
                  <svg width="10" height="8" viewBox="0 0 10 8" fill="none">
                    <path d="M1 4l2.8 3L9 1" stroke="#2563eb" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"></path>
                  </svg>
                </div>
                <span>Apple</span>
              </div>
              <div class="gt-gs-option selected" data-value="banana" role="option" aria-selected="true">
                <div class="gt-gs-check">
                  <svg width="10" height="8" viewBox="0 0 10 8" fill="none">
                    <path d="M1 4l2.8 3L9 1" stroke="#2563eb" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"></path>
                  </svg>
                </div>
                <span>Banana</span>
              </div>
            </div>
          </div>
        </div>
      </div>

# side-effect message payloads remain byte-stable

    {
      "type": "list",
      "attributes": {},
      "value": [
        {
          "type": "list",
          "attributes": {
            "names": {
              "type": "character",
              "attributes": {},
              "value": ["method", "type", "message"]
            }
          },
          "value": [
            {
              "type": "character",
              "attributes": {},
              "value": ["sendCustomMessage"]
            },
            {
              "type": "character",
              "attributes": {},
              "value": ["glasstabs_update_tabs"]
            },
            {
              "type": "list",
              "attributes": {
                "names": {
                  "type": "character",
                  "attributes": {},
                  "value": ["ns", "selected"]
                }
              },
              "value": [
                {
                  "type": "character",
                  "attributes": {},
                  "value": ["mod-tabs"]
                },
                {
                  "type": "character",
                  "attributes": {},
                  "value": ["new"]
                }
              ]
            }
          ]
        },
        {
          "type": "list",
          "attributes": {
            "names": {
              "type": "character",
              "attributes": {},
              "value": ["method", "type", "message"]
            }
          },
          "value": [
            {
              "type": "character",
              "attributes": {},
              "value": ["sendCustomMessage"]
            },
            {
              "type": "character",
              "attributes": {},
              "value": ["glasstabs_tab_badge"]
            },
            {
              "type": "list",
              "attributes": {
                "names": {
                  "type": "character",
                  "attributes": {},
                  "value": ["ns", "value", "count"]
                }
              },
              "value": [
                {
                  "type": "character",
                  "attributes": {},
                  "value": ["mod-tabs"]
                },
                {
                  "type": "character",
                  "attributes": {},
                  "value": ["new"]
                },
                {
                  "type": "integer",
                  "attributes": {},
                  "value": [7]
                }
              ]
            }
          ]
        },
        {
          "type": "list",
          "attributes": {
            "names": {
              "type": "character",
              "attributes": {},
              "value": ["method", "type", "message"]
            }
          },
          "value": [
            {
              "type": "character",
              "attributes": {},
              "value": ["sendCustomMessage"]
            },
            {
              "type": "character",
              "attributes": {},
              "value": ["glasstabs_show_tab"]
            },
            {
              "type": "list",
              "attributes": {
                "names": {
                  "type": "character",
                  "attributes": {},
                  "value": ["ns", "value"]
                }
              },
              "value": [
                {
                  "type": "character",
                  "attributes": {},
                  "value": ["mod-tabs"]
                },
                {
                  "type": "character",
                  "attributes": {},
                  "value": ["new"]
                }
              ]
            }
          ]
        },
        {
          "type": "list",
          "attributes": {
            "names": {
              "type": "character",
              "attributes": {},
              "value": ["method", "type", "message"]
            }
          },
          "value": [
            {
              "type": "character",
              "attributes": {},
              "value": ["sendCustomMessage"]
            },
            {
              "type": "character",
              "attributes": {},
              "value": ["glasstabs_hide_tab"]
            },
            {
              "type": "list",
              "attributes": {
                "names": {
                  "type": "character",
                  "attributes": {},
                  "value": ["ns", "value"]
                }
              },
              "value": [
                {
                  "type": "character",
                  "attributes": {},
                  "value": ["mod-tabs"]
                },
                {
                  "type": "character",
                  "attributes": {},
                  "value": ["new"]
                }
              ]
            }
          ]
        },
        {
          "type": "list",
          "attributes": {
            "names": {
              "type": "character",
              "attributes": {},
              "value": ["method", "type", "message"]
            }
          },
          "value": [
            {
              "type": "character",
              "attributes": {},
              "value": ["sendCustomMessage"]
            },
            {
              "type": "character",
              "attributes": {},
              "value": ["glasstabs_disable_tab"]
            },
            {
              "type": "list",
              "attributes": {
                "names": {
                  "type": "character",
                  "attributes": {},
                  "value": ["ns", "value"]
                }
              },
              "value": [
                {
                  "type": "character",
                  "attributes": {},
                  "value": ["mod-tabs"]
                },
                {
                  "type": "character",
                  "attributes": {},
                  "value": ["new"]
                }
              ]
            }
          ]
        },
        {
          "type": "list",
          "attributes": {
            "names": {
              "type": "character",
              "attributes": {},
              "value": ["method", "type", "message"]
            }
          },
          "value": [
            {
              "type": "character",
              "attributes": {},
              "value": ["sendCustomMessage"]
            },
            {
              "type": "character",
              "attributes": {},
              "value": ["glasstabs_enable_tab"]
            },
            {
              "type": "list",
              "attributes": {
                "names": {
                  "type": "character",
                  "attributes": {},
                  "value": ["ns", "value"]
                }
              },
              "value": [
                {
                  "type": "character",
                  "attributes": {},
                  "value": ["mod-tabs"]
                },
                {
                  "type": "character",
                  "attributes": {},
                  "value": ["new"]
                }
              ]
            }
          ]
        },
        {
          "type": "list",
          "attributes": {
            "names": {
              "type": "character",
              "attributes": {},
              "value": ["method", "type", "message"]
            }
          },
          "value": [
            {
              "type": "character",
              "attributes": {},
              "value": ["sendCustomMessage"]
            },
            {
              "type": "character",
              "attributes": {},
              "value": ["glasstabs_append_tab"]
            },
            {
              "type": "list",
              "attributes": {
                "names": {
                  "type": "character",
                  "attributes": {},
                  "value": ["ns", "value", "link_html", "pane_html", "select"]
                }
              },
              "value": [
                {
                  "type": "character",
                  "attributes": {},
                  "value": ["mod-tabs"]
                },
                {
                  "type": "character",
                  "attributes": {},
                  "value": ["new"]
                },
                {
                  "type": "character",
                  "attributes": {},
                  "value": ["<div class=\"gt-tab-link\" data-value=\"new\" data-ns=\"mod-tabs\" role=\"tab\" tabindex=\"0\" aria-selected=\"false\">\n  <span class=\"gt-tab-icon\">\n    <i class=\"fas fa-table\" role=\"presentation\" aria-label=\"table icon\"><\/i>\n  <\/span>\n  <span class=\"gt-tab-label\">New<\/span>\n<\/div>"]
                },
                {
                  "type": "character",
                  "attributes": {},
                  "value": ["<div class=\"gt-tab-pane\" id=\"mod-tabs-pane-new\" role=\"tabpanel\">\n  <div class=\"gt-card\">\n    <p>Content<\/p>\n  <\/div>\n<\/div>"]
                },
                {
                  "type": "logical",
                  "attributes": {},
                  "value": [true]
                }
              ]
            }
          ]
        },
        {
          "type": "list",
          "attributes": {
            "names": {
              "type": "character",
              "attributes": {},
              "value": ["method", "type", "message"]
            }
          },
          "value": [
            {
              "type": "character",
              "attributes": {},
              "value": ["sendCustomMessage"]
            },
            {
              "type": "character",
              "attributes": {},
              "value": ["glasstabs_remove_tab"]
            },
            {
              "type": "list",
              "attributes": {
                "names": {
                  "type": "character",
                  "attributes": {},
                  "value": ["ns", "value"]
                }
              },
              "value": [
                {
                  "type": "character",
                  "attributes": {},
                  "value": ["mod-tabs"]
                },
                {
                  "type": "character",
                  "attributes": {},
                  "value": ["new"]
                }
              ]
            }
          ]
        },
        {
          "type": "list",
          "attributes": {
            "names": {
              "type": "character",
              "attributes": {},
              "value": ["method", "type", "message"]
            }
          },
          "value": [
            {
              "type": "character",
              "attributes": {},
              "value": ["sendCustomMessage"]
            },
            {
              "type": "character",
              "attributes": {},
              "value": ["glasstabs_update_multiselect"]
            },
            {
              "type": "list",
              "attributes": {
                "names": {
                  "type": "character",
                  "attributes": {},
                  "value": ["inputId", "data"]
                }
              },
              "value": [
                {
                  "type": "character",
                  "attributes": {},
                  "value": ["mod-multi"]
                },
                {
                  "type": "list",
                  "attributes": {
                    "names": {
                      "type": "character",
                      "attributes": {},
                      "value": ["choices", "selected", "shape"]
                    }
                  },
                  "value": [
                    {
                      "type": "list",
                      "attributes": {},
                      "value": [
                        {
                          "type": "list",
                          "attributes": {
                            "names": {
                              "type": "character",
                              "attributes": {},
                              "value": ["label", "value", "group", "disabled"]
                            }
                          },
                          "value": [
                            {
                              "type": "character",
                              "attributes": {},
                              "value": ["Apple"]
                            },
                            {
                              "type": "character",
                              "attributes": {},
                              "value": ["apple"]
                            },
                            {
                              "type": "character",
                              "attributes": {},
                              "value": [""]
                            },
                            {
                              "type": "logical",
                              "attributes": {},
                              "value": [false]
                            }
                          ]
                        },
                        {
                          "type": "list",
                          "attributes": {
                            "names": {
                              "type": "character",
                              "attributes": {},
                              "value": ["label", "value", "group", "disabled"]
                            }
                          },
                          "value": [
                            {
                              "type": "character",
                              "attributes": {},
                              "value": ["Banana"]
                            },
                            {
                              "type": "character",
                              "attributes": {},
                              "value": ["banana"]
                            },
                            {
                              "type": "character",
                              "attributes": {},
                              "value": [""]
                            },
                            {
                              "type": "logical",
                              "attributes": {},
                              "value": [false]
                            }
                          ]
                        }
                      ]
                    },
                    {
                      "type": "character",
                      "attributes": {},
                      "value": ["apple"]
                    },
                    {
                      "type": "character",
                      "attributes": {},
                      "value": ["square"]
                    }
                  ]
                }
              ]
            }
          ]
        },
        {
          "type": "list",
          "attributes": {
            "names": {
              "type": "character",
              "attributes": {},
              "value": ["method", "inputId", "message"]
            }
          },
          "value": [
            {
              "type": "character",
              "attributes": {},
              "value": ["sendInputMessage"]
            },
            {
              "type": "character",
              "attributes": {},
              "value": ["single"]
            },
            {
              "type": "list",
              "attributes": {
                "names": {
                  "type": "character",
                  "attributes": {},
                  "value": ["choices", "selected", "shape"]
                }
              },
              "value": [
                {
                  "type": "list",
                  "attributes": {},
                  "value": [
                    {
                      "type": "list",
                      "attributes": {
                        "names": {
                          "type": "character",
                          "attributes": {},
                          "value": ["label", "value", "group", "disabled"]
                        }
                      },
                      "value": [
                        {
                          "type": "character",
                          "attributes": {},
                          "value": ["Apple"]
                        },
                        {
                          "type": "character",
                          "attributes": {},
                          "value": ["apple"]
                        },
                        {
                          "type": "character",
                          "attributes": {},
                          "value": [""]
                        },
                        {
                          "type": "logical",
                          "attributes": {},
                          "value": [false]
                        }
                      ]
                    },
                    {
                      "type": "list",
                      "attributes": {
                        "names": {
                          "type": "character",
                          "attributes": {},
                          "value": ["label", "value", "group", "disabled"]
                        }
                      },
                      "value": [
                        {
                          "type": "character",
                          "attributes": {},
                          "value": ["Banana"]
                        },
                        {
                          "type": "character",
                          "attributes": {},
                          "value": ["banana"]
                        },
                        {
                          "type": "character",
                          "attributes": {},
                          "value": [""]
                        },
                        {
                          "type": "logical",
                          "attributes": {},
                          "value": [false]
                        }
                      ]
                    }
                  ]
                },
                {
                  "type": "character",
                  "attributes": {},
                  "value": ["banana"]
                },
                {
                  "type": "character",
                  "attributes": {},
                  "value": ["square"]
                }
              ]
            }
          ]
        },
        {
          "type": "list",
          "attributes": {
            "names": {
              "type": "character",
              "attributes": {},
              "value": ["method", "inputId", "message"]
            }
          },
          "value": [
            {
              "type": "character",
              "attributes": {},
              "value": ["sendInputMessage"]
            },
            {
              "type": "character",
              "attributes": {},
              "value": ["single"]
            },
            {
              "type": "list",
              "attributes": {
                "names": {
                  "type": "character",
                  "attributes": {},
                  "value": ["close"]
                }
              },
              "value": [
                {
                  "type": "logical",
                  "attributes": {},
                  "value": [true]
                }
              ]
            }
          ]
        },
        {
          "type": "list",
          "attributes": {
            "names": {
              "type": "character",
              "attributes": {},
              "value": ["method", "inputId", "message"]
            }
          },
          "value": [
            {
              "type": "character",
              "attributes": {},
              "value": ["sendInputMessage"]
            },
            {
              "type": "character",
              "attributes": {},
              "value": ["multi"]
            },
            {
              "type": "list",
              "attributes": {
                "names": {
                  "type": "character",
                  "attributes": {},
                  "value": ["close"]
                }
              },
              "value": [
                {
                  "type": "logical",
                  "attributes": {},
                  "value": [true]
                }
              ]
            }
          ]
        },
        {
          "type": "list",
          "attributes": {
            "names": {
              "type": "character",
              "attributes": {},
              "value": ["method", "type", "message"]
            }
          },
          "value": [
            {
              "type": "character",
              "attributes": {},
              "value": ["sendCustomMessage"]
            },
            {
              "type": "character",
              "attributes": {},
              "value": ["glasstabs_close_selects"]
            },
            {
              "type": "list",
              "attributes": {},
              "value": []
            }
          ]
        }
      ]
    }

# input-message fallback payloads remain byte-stable

    {
      "type": "list",
      "attributes": {},
      "value": [
        {
          "type": "list",
          "attributes": {
            "names": {
              "type": "character",
              "attributes": {},
              "value": ["method", "inputId", "message"]
            }
          },
          "value": [
            {
              "type": "character",
              "attributes": {},
              "value": ["sendInputMessage"]
            },
            {
              "type": "character",
              "attributes": {},
              "value": ["multi"]
            },
            {
              "type": "list",
              "attributes": {
                "names": {
                  "type": "character",
                  "attributes": {},
                  "value": ["choices", "selected"]
                }
              },
              "value": [
                {
                  "type": "list",
                  "attributes": {},
                  "value": [
                    {
                      "type": "list",
                      "attributes": {
                        "names": {
                          "type": "character",
                          "attributes": {},
                          "value": ["label", "value", "group", "disabled"]
                        }
                      },
                      "value": [
                        {
                          "type": "character",
                          "attributes": {},
                          "value": ["Apple"]
                        },
                        {
                          "type": "character",
                          "attributes": {},
                          "value": ["apple"]
                        },
                        {
                          "type": "character",
                          "attributes": {},
                          "value": [""]
                        },
                        {
                          "type": "logical",
                          "attributes": {},
                          "value": [false]
                        }
                      ]
                    },
                    {
                      "type": "list",
                      "attributes": {
                        "names": {
                          "type": "character",
                          "attributes": {},
                          "value": ["label", "value", "group", "disabled"]
                        }
                      },
                      "value": [
                        {
                          "type": "character",
                          "attributes": {},
                          "value": ["Banana"]
                        },
                        {
                          "type": "character",
                          "attributes": {},
                          "value": ["banana"]
                        },
                        {
                          "type": "character",
                          "attributes": {},
                          "value": [""]
                        },
                        {
                          "type": "logical",
                          "attributes": {},
                          "value": [false]
                        }
                      ]
                    }
                  ]
                },
                {
                  "type": "character",
                  "attributes": {},
                  "value": []
                }
              ]
            }
          ]
        },
        {
          "type": "list",
          "attributes": {
            "names": {
              "type": "character",
              "attributes": {},
              "value": ["method", "inputId", "message"]
            }
          },
          "value": [
            {
              "type": "character",
              "attributes": {},
              "value": ["sendInputMessage"]
            },
            {
              "type": "character",
              "attributes": {},
              "value": ["single"]
            },
            {
              "type": "list",
              "attributes": {
                "names": {
                  "type": "character",
                  "attributes": {},
                  "value": ["choices", "selected"]
                }
              },
              "value": [
                {
                  "type": "list",
                  "attributes": {},
                  "value": [
                    {
                      "type": "list",
                      "attributes": {
                        "names": {
                          "type": "character",
                          "attributes": {},
                          "value": ["label", "value", "group", "disabled"]
                        }
                      },
                      "value": [
                        {
                          "type": "character",
                          "attributes": {},
                          "value": ["Apple"]
                        },
                        {
                          "type": "character",
                          "attributes": {},
                          "value": ["apple"]
                        },
                        {
                          "type": "character",
                          "attributes": {},
                          "value": [""]
                        },
                        {
                          "type": "logical",
                          "attributes": {},
                          "value": [false]
                        }
                      ]
                    },
                    {
                      "type": "list",
                      "attributes": {
                        "names": {
                          "type": "character",
                          "attributes": {},
                          "value": ["label", "value", "group", "disabled"]
                        }
                      },
                      "value": [
                        {
                          "type": "character",
                          "attributes": {},
                          "value": ["Banana"]
                        },
                        {
                          "type": "character",
                          "attributes": {},
                          "value": ["banana"]
                        },
                        {
                          "type": "character",
                          "attributes": {},
                          "value": [""]
                        },
                        {
                          "type": "logical",
                          "attributes": {},
                          "value": [false]
                        }
                      ]
                    }
                  ]
                },
                {
                  "type": "character",
                  "attributes": {},
                  "value": []
                }
              ]
            }
          ]
        },
        {
          "type": "list",
          "attributes": {
            "names": {
              "type": "character",
              "attributes": {},
              "value": ["method", "inputId", "message"]
            }
          },
          "value": [
            {
              "type": "character",
              "attributes": {},
              "value": ["sendInputMessage"]
            },
            {
              "type": "character",
              "attributes": {},
              "value": ["single"]
            },
            {
              "type": "list",
              "attributes": {
                "names": {
                  "type": "character",
                  "attributes": {},
                  "value": ["close"]
                }
              },
              "value": [
                {
                  "type": "logical",
                  "attributes": {},
                  "value": [true]
                }
              ]
            }
          ]
        },
        {
          "type": "list",
          "attributes": {
            "names": {
              "type": "character",
              "attributes": {},
              "value": ["method", "inputId", "message"]
            }
          },
          "value": [
            {
              "type": "character",
              "attributes": {},
              "value": ["sendInputMessage"]
            },
            {
              "type": "character",
              "attributes": {},
              "value": ["multi"]
            },
            {
              "type": "list",
              "attributes": {
                "names": {
                  "type": "character",
                  "attributes": {},
                  "value": ["close"]
                }
              },
              "value": [
                {
                  "type": "logical",
                  "attributes": {},
                  "value": [true]
                }
              ]
            }
          ]
        }
      ]
    }

