"use strict";
window.$docsify.plugins = [].concat((n, e) => {
    var t, o;
    localStorage && (t = !0), window.changelogDisplayHandler = function() {
        // alert('test');
        if (document.getElementById("CHANGELOG_RENDERER").classList.toggle("show"), t && null === localStorage.getItem(o)) {
            if (document.getElementById("CHANGELOG_NOTIFY") != null) {
                document.getElementById("CHANGELOG_NOTIFY").remove();
            }
            localStorage.setItem(o, !0);
        };
        if (document.getElementById("CHANGELOG_RENDERER").classList.contains("show")) {
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
            const ht = new XMLHttpRequest();
            // if (e.target != 'javascript:void(0);')
            // return
            ht.onreadystatechange = function() {
                ! function(n) {
                    var l;
                    const c = JSON.stringify(n);
                    t && localStorage.getItem(c) ? l = '<a href="javascript:void(0);" onClick="window.changelogDisplayHandler(); return false;" id="CHANGELOG">CHANGELOG</a>\n                <div id="CHANGELOG_RENDERER">\n                  <div class="CL_content">\n                    <div class="CL_content-body"></div>\n                  </div>\n                </div>' :
                        (l = '<a href="javascript:void(0);" onClick="window.changelogDisplayHandler(); return false;" id="CHANGELOG"><i id="CHANGELOG_NOTIFY"></i>  CHANGELOG</a>\n                <div id="CHANGELOG_RENDERER">\n                  <div class="CL_content">\n                    <div class="CL_content-body"></div>\n                  </div>\n                </div>', o = c);
                    i.innerHTML = a.map(n => n.trim()).slice(1, a.length - 1).concat(l.split("\n").map(n => n.trim())).concat(a.slice(-1, -1)).join("\n");
                    const s = e.compiler._marked.parse(n) + '';
                    document.querySelector("#CHANGELOG_RENDERER .CL_content .CL_content-body").innerHTML = s
                }(` ${this.responseText} \n # {docsify-ignore-all} `)
            }, ht.open("GET", e.config.changelog.path, !0), ht.send()
        }()
    }));
    n.mounted(function() {
        // Place the setting inject into the CSS here
        // We need to first build the entire settings object
        var u = {
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
            button: {
                notify: "orange",
                text: "goldenrod",
                text_hover: "darkorange",
                text_transition: "1s",
                background: "inherit",
                background_hover: "grey",
                background_transition: "1s",
                brightness_hover: "100%",
                position: "absolute",
                offset_right: "0px"
            },
            header: {
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
                p: "darkred",
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
        var a = e.config.changelog;
        if (Object.isObject(a)) {
            u.path = a.path || u.path;
            if (Object.isObject(a.window)) {
                u.window.height = a.window.height || u.window.height, u.window.width = a.window.width || u.window.width, u.window.portrait_height = a.window.portrait_height || u.window.portrait_height, u.window.portrait_width = a.window.portrait_width || u.window.portrait_width, u.window.background = a.window.background || u.window.background, u.window.scroll_track = a.window.scroll_track || u.window.scroll_track, u.window.scroll_button = a.window.scroll_button || u.window.scroll_button, u.window.border = a.window.border || u.window.border, u.window.shadow = a.window.shadow || u.window.shadow, u.window.shadow_params = a.window.shadow_params || u.window.shadow_params, u.window.offset_right = a.window.offset_right || u.window.offset_right;
            };
            if (Object.isObject(a.button)) {
                u.button.notify = a.button.notify || u.button.notify, u.button.text = a.button.text || u.button.text, u.button.text_hover = a.button.text_hover || u.button.text_hover, u.button.text_transition = a.button.text_transition || u.button.text_transition, u.button.background = a.button.background || u.button.background, u.button.background_hover = a.button.background_hover || u.button.background_hover, u.button.background_transition = a.button.background_transition || u.button.background_transition, u.button.brightness_hover = a.button.brightness_hover || u.button.brightness_hover, u.button.position = a.button.position || u.button.position, u.button.offset_right = a.button.offset_right || u.button.offset_right;
            };
            if (Object.isObject(a.header)) {
                u.header.auto_links = a.header.auto_links || u.header.auto_links, u.header.border_edge = a.header.border_edge || u.header.border_edge, u.header.h1_text = a.header.h1_text || u.header.h1_text, u.header.h1_background = a.header.h1_background || u.header.h1_background, u.header.h1_size = a.header.h1_size || u.header.h1_size, u.header.h2_text = a.header.h2_text || u.header.h2_text, u.header.h2_background = a.header.h2_background || u.header.h2_background, u.header.h2_size = a.header.h2_size || u.header.h2_size, u.header.h3_text = a.header.h3_text || u.header.h3_text, u.header.h3_background = a.header.h3_background || u.header.h3_background, u.header.h3_size = a.header.h3_size || u.header.h3_size, u.header.h4_text = a.header.h4_text || u.header.h4_text, u.header.h4_background = a.header.h4_background || u.header.h4_background, u.header.h4_size = a.header.h4_size || u.header.h4_size;
            };
            if (Object.isObject(a.text)) {
                if (a.text.list_icon === "caret") {
                    a.text.list_icon = `"\\f0da"`
                } else if (a.text.list_icon === "angle") {
                    a.text.list_icon = `"\\f105"`
                } else if (a.text.list_icon === "chevron") {
                    a.text.list_icon = `"\\f138"`
                } else if (a.text.list_icon === "calendar") {
                    a.text.list_icon = `"\\f274"`
                } else if (a.text.list_icon === "bars") {
                    a.text.list_icon = `"\\f0c9"`
                } else if (a.text.list_icon === "check") {
                    a.text.list_icon = `"\\f00c"`
                } else if (a.text.list_icon === "arrow") {
                    a.text.list_icon = `"\\f0a9"`
                };

                u.text.all = a.text.all || u.text.all, u.text.strong = a.text.strong || u.text.strong, u.text.strong_background = a.text.strong_background || u.text.strong_background, u.text.p = a.text.p || u.text.p, u.text.p_background = a.text.p_background || u.text.p_background, u.text.blockquote = a.text.blockquote || u.text.blockquote, u.text.blockquote_background = a.text.blockquote_background || u.text.blockquote_background, u.text.list = a.text.list || u.text.list, u.text.list_background = a.text.list_background || u.text.list_background, u.text.list_icon = a.text.list_icon || u.text.list_icon;
            };
            if (Object.isObject(a.link)) {
                u.link.text = a.link.text || u.link.text, u.link.text_hover = a.link.text_hover || u.link.text_hover, u.link.text_transition = a.link.text_transition || u.link.text_transition, u.link.background = a.link.background || u.link.background, u.link.background_hover = a.link.background_hover || u.link.background_hover, u.link.background_transition = a.link.background_transition || u.link.background_transition;
            };
        } else {
            u.path = a
        };
        document.documentElement.style.setProperty(`--changelog-window-height`, `${u.window.height}`),
            document.documentElement.style.setProperty(`--changelog-window-width`, `${u.window.width}`),
            document.documentElement.style.setProperty(`--changelog-window-portrait-height`, `${u.window.portrait_height}`),
            document.documentElement.style.setProperty(`--changelog-window-portrait-width`, `${u.window.portrait_width}`),
            document.documentElement.style.setProperty(`--changelog-window-background`, `${u.window.background}`),
            document.documentElement.style.setProperty(`--changelog-window-scroll-track`, `${u.window.scroll_track}`),
            document.documentElement.style.setProperty(`--changelog-window-scroll-button`, `${u.window.scroll_button}`),
            document.documentElement.style.setProperty(`--changelog-window-border`, `${u.window.border}`),
            document.documentElement.style.setProperty(`--changelog-window-shadow`, `${u.window.shadow}`),
            document.documentElement.style.setProperty(`--changelog-window-shadow-params`, `${u.window.shadow_params}`),
            document.documentElement.style.setProperty(`--changelog-window-offset-right`, `${u.window.offset_right}`)

        , document.documentElement.style.setProperty(`--changelog-button-notify`, `${u.button.notify}`),
            document.documentElement.style.setProperty(`--changelog-button-text`, `${u.button.text}`),
            document.documentElement.style.setProperty(`--changelog-button-text-hover`, `${u.button.text_hover}`),
            document.documentElement.style.setProperty(`--changelog-button-text-transition`, `${u.button.text_transition}`),
            document.documentElement.style.setProperty(`--changelog-button-background`, `${u.button.background}`),
            document.documentElement.style.setProperty(`--changelog-button-background-hover`, `${u.button.background_hover}`),
            document.documentElement.style.setProperty(`--changelog-button-background-transition`, `${u.button.background_transition}`),
            document.documentElement.style.setProperty(`--changelog-button-brightness-hover`, `${u.button.brightness_hover}`),
            document.documentElement.style.setProperty(`--changelog-button-position`, `${u.button.position}`),
            document.documentElement.style.setProperty(`--changelog-button-offset-right`, `${u.button.offset_right}`)

        , document.documentElement.style.setProperty(`--changelog-header-auto-links`, `${u.header.auto_links}`),
            document.documentElement.style.setProperty(`--changelog-header-border-edge`, `${u.header.border_edge}`),
            document.documentElement.style.setProperty(`--changelog-header-h1-text`, `${u.header.h1_text}`),
            document.documentElement.style.setProperty(`--changelog-header-h2-text`, `${u.header.h2_text}`),
            document.documentElement.style.setProperty(`--changelog-header-h3-text`, `${u.header.h3_text}`),
            document.documentElement.style.setProperty(`--changelog-header-h4-text`, `${u.header.h4_text}`),
            document.documentElement.style.setProperty(`--changelog-header-h1-background`, `${u.header.h1_background}`),
            document.documentElement.style.setProperty(`--changelog-header-h2-background`, `${u.header.h2_background}`),
            document.documentElement.style.setProperty(`--changelog-header-h3-background`, `${u.header.h3_background}`),
            document.documentElement.style.setProperty(`--changelog-header-h4-background`, `${u.header.h4_background}`),
            document.documentElement.style.setProperty(`--changelog-header-h1-size`, `${u.header.h1_size}`),
            document.documentElement.style.setProperty(`--changelog-header-h2-size`, `${u.header.h2_size}`),
            document.documentElement.style.setProperty(`--changelog-header-h3-size`, `${u.header.h3_size}`),
            document.documentElement.style.setProperty(`--changelog-header-h4-size`, `${u.header.h4_size}`)

        , document.documentElement.style.setProperty(`--changelog-text-all`, `${u.text.all}`),
            document.documentElement.style.setProperty(`--changelog-text-strong`, `${u.text.strong}`),
            document.documentElement.style.setProperty(`--changelog-text-strong-background`, `${u.text.strong_background}`),
            document.documentElement.style.setProperty(`--changelog-text-p`, `${u.text.p}`),
            document.documentElement.style.setProperty(`--changelog-text-p-background`, `${u.text.p_background}`),
            document.documentElement.style.setProperty(`--changelog-text-blockquote`, `${u.text.blockquote}`),
            document.documentElement.style.setProperty(`--changelog-text-blockquote-background`, `${u.text.blockquote_background}`),
            document.documentElement.style.setProperty(`--changelog-text-list`, `${u.text.list}`),
            document.documentElement.style.setProperty(`--changelog-text-list-background`, `${u.text.list_background}`),
            document.documentElement.style.setProperty(`--changelog-text-list-icon`, `${u.text.list_icon}`)

        , document.documentElement.style.setProperty(`--changelog-link-text`, `${u.link.a_text}`),
            document.documentElement.style.setProperty(`--changelog-link-text-hover`, `${u.link.text_hover}`),
            document.documentElement.style.setProperty(`--changelog-link-text-transition`, `${u.link.text_transition}`),
            document.documentElement.style.setProperty(`--changelog-link-background`, `${u.link.background}`),
            document.documentElement.style.setProperty(`--changelog-link-background-hover`, `${u.link.background_hover}`),
            document.documentElement.style.setProperty(`--changelog-link-background-transition`, `${u.link.background_transition}`);
        e.config.changelog = u
    });
}, window.$docsify.plugins);

function clickoutside(e) {
    if (document.getElementById('CHANGELOG_RENDERER').contains(e.target) != true &&
        document.querySelector('nav').contains(e.target) != true &&
        document.getElementById("CHANGELOG_RENDERER").classList.contains("show")) {
        document.getElementById("CHANGELOG_RENDERER").classList.remove("show");
        window.removeEventListener('click', clickoutside);
    }
}

Object.isObject = function(obj) {
    return obj && obj.constructor === this || false;
};