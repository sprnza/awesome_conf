theme                               = {}

theme.wallpaper                     = "~/.background.png"

theme.font                          = "Cantarell 11"
theme.naughty_font                  = "Monospace Regular"

theme.color_dark                    = "#111111"
theme.color_light                   = "#222222"
theme.highlight_dark                = "#336699"
theme.highlight_light               = "#88AADD"
theme.text_dark                     = "#999999"
theme.text_light                    = "#EEEEEE"

--theme.fg_normal                     = "#FFFFFF"
--theme.bg_focus                      = "#444444"
theme.useless_gap                   = "0"
theme.fg_focus                      = theme.highlight_dark
theme.bg_normal                     = theme.color_light
theme.fg_urgent                     = "#ff0000"
--theme.bg_urgent                     = "#2A1F1E"
theme.bg_urgent                     = "#800000"
theme.border_width                  = "2"
theme.border_normal                 = theme.color_dark
theme.border_focus                  = theme.highlight_light
theme.taglist_bg_focus              = theme.color_light
theme.taglist_fg_normal             = theme.text_light
theme.taglist_fg_focus              = theme.text_light
theme.tasklist_bg_normal            = theme.color_light
theme.tasklist_bg_focus             = theme.highlight_dark
theme.tooltip_bg                    = theme.color_light
theme.tooltip_fg                    = theme.text_light
theme.tooltip_border_width          = "1"
theme.bg_systray                    = theme.color_light

-- icon used when a client has no default
theme.generic_icon = "/usr/share/icons/Menda-Circle/apps/48x48/apps/utilities-terminal.svg"

-- layout images
theme.icon_dir                      = "/usr/share/awesome/themes/default/layouts"
theme.layout_tile                   = theme.icon_dir .. "/tilew.png"
theme.layout_tilegaps               = theme.icon_dir .. "/tilegapsw.png"
theme.layout_tileleft               = theme.icon_dir .. "/tileleftw.png"
theme.layout_tilebottom             = theme.icon_dir .. "/tilebottomw.png"
theme.layout_tiletop                = theme.icon_dir .. "/tiletopw.png"
theme.layout_fairv                  = theme.icon_dir .. "/fairvw.png"
theme.layout_fairh                  = theme.icon_dir .. "/fairhw.png"
theme.layout_spiral                 = theme.icon_dir .. "/spiralw.png"
theme.layout_dwindle                = theme.icon_dir .. "/dwindlew.png"
theme.layout_max                    = theme.icon_dir .. "/maxw.png"
theme.layout_fullscreen             = theme.icon_dir .. "/fullscreenw.png"
theme.layout_magnifier              = theme.icon_dir .. "/magnifierw.png"
theme.layout_floating               = theme.icon_dir .. "/floatingw.png"

return theme

