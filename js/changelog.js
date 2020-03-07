"use strict";
window.$docsify.plugins = [].concat((n, e) => {
    var t, o;
    localStorage && (t = !0), window.changelogDisplayHandler = function() {
        if (document.getElementById("CHANGELOG_RENDERER").classList.toggle("show"), t && null === localStorage.getItem(o)) {
            if (document.getElementById("CHANGELOG_NOTIFY") != null ) {
                document.getElementById("CHANGELOG_NOTIFY").remove();
            }
            localStorage.setItem(o, !0);
        };
        if (document.getElementById("CHANGELOG_RENDERER").classList.contains("show")){
            window.addEventListener('click', clickoutside);
        } else {
            window.removeEventListener('click', clickoutside);
        };
    };
    let i = document.querySelector("nav.app-nav");
    if (null === i && (i = document.querySelector("nav"), null === i)) return void console.error("[Docsify-plugin-changelog] : please Write the nav element statically and set the loadNavbar option to false");
    const a = i.outerHTML.split("\n");
    n.ready((function() {
        e.config.changelog.path && !e.config.loadNavbar && function() {
            const n = new XMLHttpRequest;
            n.onreadystatechange = function() {
                ! function(n) {
                    var l;
                    const c = JSON.stringify(n);
                    t && localStorage.getItem(c) ? l = '<a href="javascript:void(0);" onClick="window.changelogDisplayHandler(); return false;" id="CHANGELOG">CHANGELOG</a>\n                <div id="CHANGELOG_RENDERER">\n                  <div class="CL_content">\n                    <div class="CL_content-body"></div>\n                  </div>\n                </div>' 
                    : (l = '<a href="javascript:void(0);" onClick="window.changelogDisplayHandler(); return false;" id="CHANGELOG"><i id="CHANGELOG_NOTIFY"></i>  CHANGELOG</a>\n                <div id="CHANGELOG_RENDERER">\n                  <div class="CL_content">\n                    <div class="CL_content-body"></div>\n                  </div>\n                </div>', o = c);
                    i.innerHTML = a.map(n => n.trim()).slice(1, a.length - 1).concat(l.split("\n").map(n => n.trim())).concat(a.slice(-1, -1)).join("\n");
                    const s = e.compiler._marked.parse(n);
                    document.querySelector("#CHANGELOG_RENDERER .CL_content .CL_content-body").innerHTML = s
                }(` ${this.responseText} \n # {docsify-ignore-all} `)
            }, n.open("GET", e.config.changelog.path, !0), n.send()
        }()
    }));
    n.mounted(function() {
        // Place the setting inject into the CSS here
        // We need to first build the entire settings object
        var u = {
            path: "changelog.md",
            height: "90vh",
            width: "65%",
            heading_links: "none",
            colors: {
                button_text: "#e78931",
                button_notify: "#e78931",
                background: "#000000",
                background_high: "#070707",
                scroll_track: "#000000",
                scroll_button: "#6d6d6d",
                border_edge: "#000000",
                border_header_edge: "#e78931",
                border_shadow: "#000000",
                border_shadow_params: "0px 0px 50px 23px",
                strong_text: "#e6c409",
                strong_background: "#462200",
                p_text: "#e78931",
                blockquote_text: "#e6c409",
                list_text: "#80e42e",
                a_text: "#e6c409",
                a_background: "#070707",
                a_background_hover: "#6868687a",
                h1_background: "#070707",
                h2_background: "#070707",
                h3_background: "#070707",
                h4_background: "#070707",
            }
        };
        var a = e.config.changelog;
        if (Object.isObject(a)) {
            u.path = a.path || u.path
            , u.width = a.width || u.width
            , u.height = a.height || u.height
            , u.heading_links = a.heading_links || u.heading_links;
            if (Object.isObject(a.colors)){
                u.colors.button_text = a.colors.button_text || u.colors.button_text
                , u.colors.button_notify = a.colors.button_notify || a.colors.button_text || u.colors.button_text
                , u.colors.list_text = a.colors.list_text || u.colors.list_text
                , u.colors.background = a.colors.background || u.colors.background
                , u.colors.background_high = a.colors.background_high || u.colors.background_high
                , u.colors.scroll_track = a.colors.scroll_track || a.colors.background || u.colors.scroll_track
                , u.colors.scroll_button = a.colors.scroll_button || u.colors.scroll_button
                , u.colors.border_edge = a.colors.border_edge || a.colors.background || u.colors.border_edge
                , u.colors.border_header_edge = a.colors.border_header_edge || a.colors.button_text || u.colors.border_header_edge
                , u.colors.border_shadow = a.colors.border_shadow || a.colors.background || u.colors.border_shadow
                , u.colors.border_shadow_params = a.colors.border_shadow_params || u.colors.border_shadow_params
                , u.colors.strong_text = a.colors.strong_text || u.colors.strong_text
                , u.colors.strong_background = a.colors.strong_background || u.colors.strong_background
                , u.colors.blockquote_text = a.colors.blockquote_text || a.colors.strong_text || u.colors.blockquote_text
                , u.colors.p_text = a.colors.p_text || a.colors.button_text || u.colors.p_text
                , u.colors.a_text = a.colors.a_text || a.colors.strong_text || u.colors.a_text
                , u.colors.a_background = a.colors.a_background || a.colors.background_high || u.colors.a_background
                , u.colors.a_background_hover = a.colors.a_background_hover || u.colors.a_background_hover
                , u.colors.h1_background = a.colors.h1_background || a.colors.background_high || u.colors.h1_background
                , u.colors.h2_background = a.colors.h2_background || a.colors.background_high || u.colors.h2_background
                , u.colors.h3_background = a.colors.h3_background || a.colors.background_high || u.colors.h3_background
                , u.colors.h4_background = a.colors.h4_background || a.colors.background_high || u.colors.h4_background;
            };
        } else {
            u.path = a
        };
        document.documentElement.style.setProperty(`--setting-changelog-width`, `${u.width}`)
        , document.documentElement.style.setProperty(`--setting-changelog-height`, `${u.height}`)
        , document.documentElement.style.setProperty(`--setting-heading-links`, `${u.heading_links}`)
        , document.documentElement.style.setProperty(`--color-button-text`, `${u.colors.button_text}`)
        , document.documentElement.style.setProperty(`--color-button-notify`, `${u.colors.button_notify}`)
        , document.documentElement.style.setProperty(`--color-background`, `${u.colors.background}`)
        , document.documentElement.style.setProperty(`--color-background-high`, `${u.colors.background_high}`)
        , document.documentElement.style.setProperty(`--color-scroll-track`, `${u.colors.scroll_track}`)
        , document.documentElement.style.setProperty(`--color-scroll-button`, `${u.colors.scroll_button}`)
        , document.documentElement.style.setProperty(`--color-border-edge`, `${u.colors.border_edge}`)
        , document.documentElement.style.setProperty(`--color-border-shadow`, `${u.colors.border_shadow}`)
        , document.documentElement.style.setProperty(`--color-border-shadow-params`, `${u.colors.border_shadow_params}`)
        , document.documentElement.style.setProperty(`--color-border-header-edge`, `${u.colors.border_header_edge}`)
        , document.documentElement.style.setProperty(`--color-strong-text`, `${u.colors.strong_text}`)
        , document.documentElement.style.setProperty(`--color-strong-background`, `${u.colors.strong_background}`)
        , document.documentElement.style.setProperty(`--color-list-text`, `${u.colors.list_text}`)
        , document.documentElement.style.setProperty(`--color-p-text`, `${u.colors.p_text}`)
        , document.documentElement.style.setProperty(`--color-blockquote-text`, `${u.colors.blockquote_text}`)
        , document.documentElement.style.setProperty(`--color-a-text`, `${u.colors.a_text}`)
        , document.documentElement.style.setProperty(`--color-a-background`, `${u.colors.a_background}`)
        , document.documentElement.style.setProperty(`--color-a-background-hover`, `${u.colors.a_background_hover}`)
        , document.documentElement.style.setProperty(`--color-h1-background`, `${u.colors.h1_background}`)
        , document.documentElement.style.setProperty(`--color-h2-background`, `${u.colors.h2_background}`)
        , document.documentElement.style.setProperty(`--color-h3-background`, `${u.colors.h3_background}`)
        , document.documentElement.style.setProperty(`--color-h4-background`, `${u.colors.h4_background}`);
        // e.config.changelog = [].concat(a,u)
        e.config.changelog = u
    });
}, window.$docsify.plugins);

function clickoutside(e){
    if (document.getElementById('CHANGELOG_RENDERER').contains(e.target) != true 
    && document.querySelector('nav').contains(e.target) != true 
    && document.getElementById("CHANGELOG_RENDERER").classList.contains("show")){
        document.getElementById("CHANGELOG_RENDERER").classList.remove("show");
        window.removeEventListener('click', clickoutside);
    }
}

Object.isObject = function(obj) {
    return obj && obj.constructor === this || false;
};