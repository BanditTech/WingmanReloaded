const plugin = (hook, vm) => {
  var isLS, LS_CONTENT
  if (localStorage) {
    isLS = true
  }

  window.changelogDisplayHandler = function () {
    const element = document.getElementById('CHANGELOG_RENDERER')
    element.classList.toggle('show')

    if (isLS && localStorage.getItem(LS_CONTENT) === null) {
      const elToRemove = document.getElementById('CHANGELOG_NOTIFY')
      elToRemove.remove()
      localStorage.setItem(LS_CONTENT, true)
    }
    if (document.getElementById("CHANGELOG_RENDERER").classList.contains("show")){
        window.addEventListener('click', clickoutside);
    } else {
        window.removeEventListener('click', clickoutside);
    };
  }
  let navEl = document.querySelector('nav.app-nav')
  if (navEl === null) {
    navEl = document.querySelector('nav')
    if (navEl === null) {
      console.error(
        '[Docsify-plugin-changelog] : please Write the nav element statically and set the loadNavbar option to false'
      )
      return
    }
  }
  const initiaNavlEl = navEl.outerHTML.split('\n')

  hook.ready(function () {
    // Called when the script starts running, only trigger once, no arguments,
    if (!!vm.config.changelog.path && !vm.config.loadNavbar) {
      loadDoc()
    }
  })
  hook.mounted(function() {
    // Place the setting inject into the CSS here
    // We need to first build the entire settings object
    var SetParams = {
      path: "changelog.md",
      window: {
        height: "60vh",
        width: "400px",
        portrait_height: "60vh",
        portrait_width: "400px",
        background: "#FFF",
        scroll_track: "inherit",
        scroll_button: "grey",
        border: "rgba(0, 0, 0, 0.1)",
        shadow: "rgba(0, 0, 0, .3)",
        shadow_params: "0 0 34px 15px",
        offset_right: "4vw"
      },
      button:{
        notify: "red",
        text: "goldenrod",
        text_hover: "darkorange",
        text_transition: "1s",
        background: "inherit",
        background_hover: "#00000033",
        background_transition: "1s",
        background_padding: "5px",
        brightness_hover: "100%",
        position: "absolute",
        offset_right: "0px",
        offset_top: "auto"
      },
      header:{
        auto_links: "none", 
        border_edge: "rgba(0, 0, 0, 0.1)",
        h1_text: "inherit",
        h1_background: "rgba(0, 0, 0, 0.03)",
        h1_size: "1.5rem",
        h2_text: "inherit",
        h2_background: "inherit",
        h2_size: "2rem",
        h3_text: "inherit",
        h3_background: "inherit",
        h3_size: "24px",
        h4_text: "inherit",
        h4_background: "inherit",
        h4_size: "inherit"
      },
      text: {
        all: "black",
        strong: "inherit",
        strong_background: "silver",
        p: "orange",
        p_background: "inherit",
        blockquote: "inherit",
        blockquote_background: "inherit",
        list: "inherit",
        list_background: "inherit",
        list_icon: `"\\f00c"` // accepts "caret", "angle", "chevron", "calendar", "bars", "check", or "arrow"
      },
      link: {
        text: "inherit",
        text_hover: "orange",
        text_transition: "0.5s",
        background: "inherit",
        background_hover: "inherit",
        background_transition: "0.5s"
      }
    };
    var UserParams = vm.config.changelog;
    if (Object.isObject(UserParams)) {
      SetParams.path = UserParams.path || SetParams.path;
      if (Object.isObject(UserParams.window)) {
        SetParams.window = Object.assign({}, SetParams.window, UserParams.window)
      };
      if (Object.isObject(UserParams.button)){
        SetParams.button = Object.assign({}, SetParams.button, UserParams.button)
      };
      if (Object.isObject(UserParams.header)){
        SetParams.header = Object.assign({}, SetParams.header, UserParams.header)
      };
      if (Object.isObject(UserParams.text)){
        if        (UserParams.text.list_icon === "caret"){
          UserParams.text.list_icon = `"\\f0da"`
        } else if (UserParams.text.list_icon === "angle"){
          UserParams.text.list_icon = `"\\f105"`
        } else if (UserParams.text.list_icon === "chevron"){
          UserParams.text.list_icon = `"\\f138"`
        } else if (UserParams.text.list_icon === "calendar"){
          UserParams.text.list_icon = `"\\f274"`
        } else if (UserParams.text.list_icon === "bars"){
          UserParams.text.list_icon = `"\\f0c9"`
        } else if (UserParams.text.list_icon === "check"){
          UserParams.text.list_icon = `"\\f00c"`
        } else if (UserParams.text.list_icon === "arrow"){
          UserParams.text.list_icon = `"\\f0a9"`
        };
        SetParams.text = Object.assign({},SetParams.text, UserParams.text)
      };
      if (Object.isObject(UserParams.link)){
        SetParams.link = Object.assign({}, SetParams.link, UserParams.link)
      };
    } else {
      SetParams.path = UserParams
    };
    document.documentElement.style.setProperty(`--changelog-window-height`, `${SetParams.window.height}`)
    , document.documentElement.style.setProperty(`--changelog-window-width`, `${SetParams.window.width}`)
    , document.documentElement.style.setProperty(`--changelog-window-portrait-height`, `${SetParams.window.portrait_height}`)
    , document.documentElement.style.setProperty(`--changelog-window-portrait-width`, `${SetParams.window.portrait_width}`)
    , document.documentElement.style.setProperty(`--changelog-window-background`, `${SetParams.window.background}`)
    , document.documentElement.style.setProperty(`--changelog-window-scroll-track`, `${SetParams.window.scroll_track}`)
    , document.documentElement.style.setProperty(`--changelog-window-scroll-button`, `${SetParams.window.scroll_button}`)
    , document.documentElement.style.setProperty(`--changelog-window-border`, `${SetParams.window.border}`)
    , document.documentElement.style.setProperty(`--changelog-window-shadow`, `${SetParams.window.shadow}`)
    , document.documentElement.style.setProperty(`--changelog-window-shadow-params`, `${SetParams.window.shadow_params}`)
    , document.documentElement.style.setProperty(`--changelog-window-offset-right`, `${SetParams.window.offset_right}`)
    , document.documentElement.style.setProperty(`--changelog-button-notify`, `${SetParams.button.notify}`)
    , document.documentElement.style.setProperty(`--changelog-button-text`, `${SetParams.button.text}`)
    , document.documentElement.style.setProperty(`--changelog-button-text-hover`, `${SetParams.button.text_hover}`)
    , document.documentElement.style.setProperty(`--changelog-button-text-transition`, `${SetParams.button.text_transition}`)
    , document.documentElement.style.setProperty(`--changelog-button-background`, `${SetParams.button.background}`)
    , document.documentElement.style.setProperty(`--changelog-button-background-hover`, `${SetParams.button.background_hover}`)
    , document.documentElement.style.setProperty(`--changelog-button-background-transition`, `${SetParams.button.background_transition}`)
    , document.documentElement.style.setProperty(`--changelog-button-background-padding`, `${SetParams.button.background_padding}`)
    , document.documentElement.style.setProperty(`--changelog-button-brightness-hover`, `${SetParams.button.brightness_hover}`)
    , document.documentElement.style.setProperty(`--changelog-button-position`, `${SetParams.button.position}`)
    , document.documentElement.style.setProperty(`--changelog-button-offset-right`, `${SetParams.button.offset_right}`)
    , document.documentElement.style.setProperty(`--changelog-header-auto-links`, `${SetParams.header.auto_links}`)
    , document.documentElement.style.setProperty(`--changelog-header-border-edge`, `${SetParams.header.border_edge}`)
    , document.documentElement.style.setProperty(`--changelog-header-h1-text`, `${SetParams.header.h1_text}`)
    , document.documentElement.style.setProperty(`--changelog-header-h2-text`, `${SetParams.header.h2_text}`)
    , document.documentElement.style.setProperty(`--changelog-header-h3-text`, `${SetParams.header.h3_text}`)
    , document.documentElement.style.setProperty(`--changelog-header-h4-text`, `${SetParams.header.h4_text}`)
    , document.documentElement.style.setProperty(`--changelog-header-h1-background`, `${SetParams.header.h1_background}`)
    , document.documentElement.style.setProperty(`--changelog-header-h2-background`, `${SetParams.header.h2_background}`)
    , document.documentElement.style.setProperty(`--changelog-header-h3-background`, `${SetParams.header.h3_background}`)
    , document.documentElement.style.setProperty(`--changelog-header-h4-background`, `${SetParams.header.h4_background}`)
    , document.documentElement.style.setProperty(`--changelog-header-h1-size`, `${SetParams.header.h1_size}`)
    , document.documentElement.style.setProperty(`--changelog-header-h2-size`, `${SetParams.header.h2_size}`)
    , document.documentElement.style.setProperty(`--changelog-header-h3-size`, `${SetParams.header.h3_size}`)
    , document.documentElement.style.setProperty(`--changelog-header-h4-size`, `${SetParams.header.h4_size}`)
    , document.documentElement.style.setProperty(`--changelog-text-all`, `${SetParams.text.all}`)
    , document.documentElement.style.setProperty(`--changelog-text-strong`, `${SetParams.text.strong}`)
    , document.documentElement.style.setProperty(`--changelog-text-strong-background`, `${SetParams.text.strong_background}`)
    , document.documentElement.style.setProperty(`--changelog-text-p`, `${SetParams.text.p}`)
    , document.documentElement.style.setProperty(`--changelog-text-p-background`, `${SetParams.text.p_background}`)
    , document.documentElement.style.setProperty(`--changelog-text-blockquote`, `${SetParams.text.blockquote}`)
    , document.documentElement.style.setProperty(`--changelog-text-blockquote-background`, `${SetParams.text.blockquote_background}`)
    , document.documentElement.style.setProperty(`--changelog-text-list`, `${SetParams.text.list}`)
    , document.documentElement.style.setProperty(`--changelog-text-list-background`, `${SetParams.text.list_background}`)
    , document.documentElement.style.setProperty(`--changelog-text-list-icon`, `${SetParams.text.list_icon}`)
    , document.documentElement.style.setProperty(`--changelog-link-text`, `${SetParams.link.a_text}`)
    , document.documentElement.style.setProperty(`--changelog-link-text-hover`, `${SetParams.link.text_hover}`)
    , document.documentElement.style.setProperty(`--changelog-link-text-transition`, `${SetParams.link.text_transition}`)
    , document.documentElement.style.setProperty(`--changelog-link-background`, `${SetParams.link.background}`)
    , document.documentElement.style.setProperty(`--changelog-link-background-hover`, `${SetParams.link.background_hover}`)
    , document.documentElement.style.setProperty(`--changelog-link-background-transition`, `${SetParams.link.background_transition}`);
    vm.config.changelog = SetParams
  })
  
  function renderChangelog (md) {
    var html
    const normalizeMD = JSON.stringify(md)

    if (isLS && localStorage.getItem(normalizeMD)) {
      // this is an old changelog content. no need to show the RED DOT
      html = `<a href="javascript:void(0)" onClick="window.changelogDisplayHandler(); return false;" id="CHANGELOG">CHANGELOG</a>
                <div id="CHANGELOG_RENDERER">
                  <div class="CL_content">
                    <div class="CL_content-body"></div>
                  </div>
                </div>`
    } else {
      // this is new CHangelog content,
      // show the RED DOT

      html = `<a href="javascript:void(0)" onClick="window.changelogDisplayHandler(); return false;" id="CHANGELOG"><i id="CHANGELOG_NOTIFY"></i>  CHANGELOG</a>
                <div id="CHANGELOG_RENDERER">
                  <div class="CL_content">
                    <div class="CL_content-body"></div>
                  </div>
                </div>`
      LS_CONTENT = normalizeMD
    }

    navEl.innerHTML = initiaNavlEl
      .map(el => el.trim())
      .slice(1, initiaNavlEl.length - 1)
      .concat(html.split('\n').map(el => el.trim()))
      .concat(initiaNavlEl.slice(-1, -1))
      .join('\n')

    const changelogContentHTML = vm.compiler._marked.parse(md)
    const changelogPlaceHolder = document.querySelector(
      '#CHANGELOG_RENDERER .CL_content .CL_content-body'
    )

    changelogPlaceHolder.innerHTML = changelogContentHTML
  }

  function loadDoc () {
    const xhttp = new XMLHttpRequest()
    xhttp.onreadystatechange = function () {
      const md = ` ${this.responseText} \n # {docsify-ignore-all} `
      renderChangelog(md)
    }
    xhttp.open('GET', vm.config.changelog.path, true)
    xhttp.send()
  }
  
  function clickoutside(e){
      if (document.getElementById('CHANGELOG_RENDERER').contains(e.target) != true 
      && document.querySelector('nav').contains(e.target) != true 
      && document.getElementById("CHANGELOG_RENDERER").classList.contains("show")){
          document.getElementById("CHANGELOG_RENDERER").classList.remove("show");
          window.removeEventListener('click', clickoutside);
      }
  }
}

window.$docsify.plugins = [].concat(plugin, window.$docsify.plugins)

Object.isObject = function(obj) {
    return obj && obj.constructor === this || false;
};
