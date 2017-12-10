local xresources = require("beautiful.xresources")
local xrdb = xresources.get_current_theme()

theme                               = {}
theme.wallpaper                     = "~/Downloads/Wallpapers/jingle_hell_by_ivan_bliznak-d4jjver.jpg"

theme.font                          = "Cantarell 11"
theme.naughty_font                  = "Monospace Regular"
theme.tooltip_font                  = "Monospace Regular 11"

theme.color_dark                    = xrdb.background -- dark brown
theme.color_light                   = xrdb.color5     -- orange
theme.highlight_dark                = xrdb.color6     -- dark green
theme.highlight_light               = xrdb.color6
theme.text_dark                     = xrdb.foreground
theme.text_light                    = xrdb.foreground

theme.fg_focus                      = theme.highlight_dark
theme.bg_normal                     = theme.color_dark
theme.fg_urgent                     = theme.text_dark
theme.bg_urgent                     = xrdb.color1
theme.border_width                  = "1"
theme.border_normal                 = "#000000"         -- black borders on windows
theme.border_focus                  = theme.highlight_light
theme.taglist_bg_normal             = theme.color_dark
theme.taglist_bg_focus              = theme.color_dark
theme.taglist_fg_normal             = theme.text_light
theme.taglist_fg_focus              = theme.highlight_dark
theme.tasklist_bg_normal            = theme.color_dark
theme.tasklist_bg_focus             = theme.highlight_dark
theme.tooltip_bg                    = xrdb.background
theme.tooltip_fg                    = theme.text_light
theme.tooltip_border_width          = "1"
theme.tooltip_border_color          = theme.highlight_light
theme.bg_systray                    = theme.color_dark

theme.menu_width                    = "150"
theme.useless_gap                   = "0"
-- icon used when a client has no default
theme.generic_icon = "/usr/share/icons/Menda-Circle/apps/48x48/apps/utilities-terminal.svg"
theme.ff_icon = "/usr/share/icons/Menda-Circle/apps/48x48/apps/firefox-original.svg"
-- titlebar buttons
theme.tb_close_active              = os.getenv("HOME") .. "/.config/awesome/themes/icons/tb_close_active.png"
theme.tb_close_inactive              = os.getenv("HOME") .. "/.config/awesome/themes/icons/tb_close_inactive.png"
theme.tb_hide_active              = os.getenv("HOME") .. "/.config/awesome/themes/icons/tb_hide_active.png"
theme.tb_hide_inactive              = os.getenv("HOME") .. "/.config/awesome/themes/icons/tb_hid_inactive.png"
theme.tb_max_active              = os.getenv("HOME") .. "/.config/awesome/themes/icons/tb_max_active.png"
theme.tb_max_inactive              = os.getenv("HOME") .. "/.config/awesome/themes/icons/tb_max_inactive.png"
theme.titlebar_close_button_normal = theme.tb_close_inactive
theme.titlebar_close_button_focus  = theme.tb_close_active
theme.titlebar_maximized_button_normal_inactive = theme.tb_max_inactive
theme.titlebar_maximized_button_focus_inactive = theme.tb_max_active
theme.titlebar_maximized_button_normal_active = theme.tb_max_inactive
theme.titlebar_maximized_button_focus_active = theme.tb_max_active
theme.titlebar_minimize_button_normal_inactive = theme.tb_hide_inactive
theme.titlebar_minimize_button_focus_inactive = theme.tb_hide_active
theme.titlebar_minimize_button_normal_active = theme.tb_hide_inactive
theme.titlebar_minimize_button_focus_active = theme.tb_hide_active

theme.titlebar_bg_normal = "#2F343F"
theme.titlebar_bg = "#2F343F"

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

