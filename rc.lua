-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup").widget

local common = require("awful.widget.common")
local lain = require("lain")

-- Custom libraries
local weather = require("weather")

local dpi = require("beautiful").xresources.apply_dpi


-- {{{ Notifications position and border width
naughty.config.presets.normal.position = "top_right"
naughty.config.icon_dirs = {os.getenv("HOME") .. "/.config/awesome/themes/icons/"}
naughty.config.icon_formats = {"png", "svg"}
naughty.config.presets.normal.font = "Monospace Regular 11"
naughty.config.presets.normal.bg = "#222222"
naughty.config.presets.normal.fg = "#999999"
naughty.config.presets.normal.width = 300
-- }}}



-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

awesome.connect_signal("exit",
    function()
        awful.spawn("pkill telegram-cli")
end
)

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = tostring(err) })
        in_error = false
    end)
end
-- }}}

-- {{ Markup helper
markup = lain.util.markup
-- {{


-- {{ Custom functions
-- Custom verticaltag and verticaltask are here for custom highlighting. By default there is no such a vertical line in the right of tag name and an active client's icon.
    function verticaltag(w, buttons, label, data, objects)
		w:reset()
		for i, o in ipairs(objects) do
			local cache = data[o]
			local ib, tb, bgb, m, ah, bgt, ms
			if cache then
                ib = cache.ib
				tb = cache.tb
				bgb = cache.bgb
				m = cache.m
				ah = cache.ah
				bgt = cache.bgt
				ms = cache.ms
			else
                ib = wibox.widget.imagebox()
				tb = wibox.widget.textbox()
				bgb = wibox.container.background()
				bgt = wibox.container.background()
				ah = wibox.layout.align.horizontal()
                ibm = wibox.container.margin(ib, dpi(4))
				ah:set_middle(tb)
                ah:set_left(ibm)
                ah:set_expand("none")
				bgt:set_widget(ah)
				ms = wibox.container.margin(bgt, 0, 2, 0, 0)
				m = wibox.container.margin(ms, 0, 0, 0, 2)
				bgb:set_bg(beautiful.bg_normal)
				bgb:set_widget(m)
				bgb:buttons(common.create_buttons(buttons, o))
				data[o] = {
                    ib = ib,
					tb = tb,
					bgb = bgb,
					m   = m,
					ah = ah,
					bgt = bgt,
					ms = ms,
                    ibm = ibm
				}
			end
			local text, bg, bg_image, icon, args = label(o)
            args = args or {}
			--if not pcall(tb.set_markup, tb, markup(beautiful.text_dark, text)) then
			--	tb:set_markup("<i>&lt;Invalid text&gt;</i>")
			--end
			--if bg_image == "light" then
			--	tb:set_markup(markup(beautiful.text_light, text))
			--end
			--bgt:set_bg(bg)
			if bg == beautiful.taglist_bg_focus then
				ms:set_color(beautiful.fg_focus)
			else
				ms:set_color(beautiful.bg_normal)
			end


                    -- The text might be invalid, so use pcall.
            if text == nil or text == "" then
                tbm:set_margins(0)
            else
                if not tb:set_markup_silently(text) then
                    tb:set_markup("<i>&lt;Invalid text&gt;</i>")
                end
            end
            bgb:set_bg(bg)
            if type(bg_image) == "function" then
                -- TODO: Why does this pass nil as an argument?
                bg_image = bg_image(tb,o,nil,objects,i)
            end
            bgb:set_bgimage(bg_image)


            --if icon then
            --    ib:set_image(icon)
            --else
            --    imb:set_margins(0)
            --end
			w:add(bgb)
	   end
	end

function verticaltask(w, buttons, label, data, objects)
    -- update the widgets, creating them if needed
    w:reset()
    for i, o in ipairs(objects) do
        local cache = data[o]
        local ib, tb, bgb, tbm, ibm, l
        if cache then
            ib = cache.ib
            tb = cache.tb
            bgb = cache.bgb
            tbm = cache.tbm
            ibm = cache.ibm
        else
            ib = wibox.widget.imagebox()
            tb = wibox.widget.textbox()
            bgb = wibox.container.background()
            tbm = wibox.container.margin(tb, 0, 0, 0, 0)
            ibm = wibox.container.margin(ib, 3, 3, 3, 3)
            l = wibox.layout.fixed.vertical()

            -- All of this is added in a fixed widget
            l:fill_space(true)
            l:add(ibm)

            -- And all of this gets a background
            bgb = wibox.container.margin(l, 0, 2, 0, 0)
            bgb:set_widget(l)

            bgb:buttons(common.create_buttons(buttons, o))

            data[o] = {
                ib  = ib,
                tb  = tb,
                bgb = bgb,
                tbm = tbm,
                ibm = ibm,
            }
        end

        local text, bg, bg_image, icon, args = label(o, tb)
        bgb:set_color(bg)
        if icon then
            ib:set_image(icon)
        else
            ib:set_image(beautiful.generic_icon)
        end

        w:add(bgb)
   end
end

function round(num, numDecimalPlaces)
	  local mult = 10^(numDecimalPlaces or 0)
	    return math.floor(num * mult + 0.5) / mult
end
-- END OF CUSTOM FUNCTIONS}}}

-- {{{ Variable definitions
-- Themes define colours, icons, font and wallpapers.
--beautiful.init(awful.util.get_themes_dir() .. "default/theme.lua")
beautiful.init("~/.config/awesome/themes/theme.lua")

-- This is used later as the default terminal and editor to run.
terminal = "xterm"
editor = os.getenv("EDITOR") or "vim"
editor_cmd = terminal .. " -e " .. editor

-- Custom variables

-- {{ Autostart
function run_once(cmd)
    findme = cmd
    firstspace = cmd:find(" ")
    if firstspace then
        findme = cmd:sub(0, firstspace-1)
    end
    awful.spawn.with_shell("pgrep -u $USER -x " .. findme .. " > /dev/null || (" .. cmd .. ")")
end

--awful.util.spawn_with_shell("xset s +dpms")
--awful.util.spawn_with_shell("wmctrl -x -a conky || conky")

run_once("setxkbmap -layout 'us,ru' -option grp:caps_toggle -option grp_led:caps")
--run_once("nextcloud")
run_once("telegram-cli -dERDC -P 23911 &")
run_once("light -S 30")
run_once("redshift -o")
run_once("xrdb -merge " .. os.getenv("HOME") .. "/.Xresources")
--run_once("xfce4-power-manager")
run_once("xcompmgr")
if awesome.hostname == "arch" then
    DPMS=600
    run_once("numlockx on")
    run_once("xautolock -time 10 -locker 'systemctl suspend' -detectsleep &")
    run_once("xset s off")
    run_once("xset -dpms")
    suspend = "enabled"
elseif awesome.hostname == "laptop" then
    run_once(os.getenv("HOME") .. "/.bin/disable_touch.sh")
    run_once("syndaemon -i 0.5 -t -K -R -d")
    run_once("xautolock -time 5 -locker 'systemctl suspend' -detectsleep &")
    DPMS=180
    suspend = "enabled"
    --xset = true -- true=battery(180s), false=AC(300s) it's being set inside battery widget callback function
    lock = true -- 1=enabled, 0=disabled
    elseif awesome.hostname == "acer" then
	    DPMS=180
	    suspend = "enabled"
    run_once("xset s " .. DPMS)
end

--}}


-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
    awful.layout.suit.floating,
    awful.layout.suit.tile,
--    awful.layout.suit.tile.left,
--    awful.layout.suit.tile.bottom,
--    awful.layout.suit.tile.top,
--    awful.layout.suit.fair,
--    awful.layout.suit.fair.horizontal,
--    awful.layout.suit.spiral,
--    awful.layout.suit.spiral.dwindle,
--    awful.layout.suit.max,
--    awful.layout.suit.max.fullscreen,
--    awful.layout.suit.magnifier,
--    awful.layout.suit.corner.nw,
    -- awful.layout.suit.corner.ne,
    -- awful.layout.suit.corner.sw,
    -- awful.layout.suit.corner.se,
}
-- }}}

-- {{{ Helper functions
local function client_menu_toggle_fn()
    local instance = nil

    return function ()
        if instance and instance.wibox.visible then
            instance:hide()
            instance = nil
        else
            instance = awful.menu.clients({ theme = { width = 100 } })
        end
    end
end
function b_notify()
        brt = io.popen("light")
        brt = brt:read("*a")
        brt = math.floor(tonumber(brt)/5+0.5)*5
        local icon = nil
        if brt == 10 then
            icon = "notification-display-brightness-off"
        elseif brt <= 35 then
            icon = "notification-display-brightness-low"
        elseif brt <= 60 then
            icon = "notification-display-brightness-medium"
        elseif brt <= 85 then
            icon = "notification-display-brightness-high"
        else
            icon = "notification-display-brightness-full"
        end
        return brt, icon
end

function translate()
    awful.spawn.easy_async(os.getenv("HOME") .. "/.config/awesome/bin/trans.py", function(stdout, stderr, reason, exit_code)
        naughty.notify({ title = "Translation", text = string.gsub(stdout, "\n$", ""), icon = "dict" })
    end)
end

-- }}}

-- {{{ Launchers

-- {{{ Menu
myawesomemenu = {
   { "hotkeys", function() return false, hotkeys_popup.show_help end},
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awesome.conffile },
   { "restart", awesome.restart },
   { "quit", function() awesome.quit() end}
}
powerMenu = {
    { "Logout", awesome.quit },
    { "Suspend", "systemctl suspend" },
    { "Hibernate", "systemctl hibernate" },
    { "Reboot", "systemctl reboot" },
    { "Shutdown", "systemctl poweroff" }
}
internetMenu = {
    { "Internet Nusha", "env GTK2_RC_FILES=/home/speranza/.gtkrc-2.0-light palemoon -P Nusha" },
    { "Transmission", "transmission-remote-gtk"},
    { "Skype", "skype" },
    { "Telegram", "telegram-desktop" },
    { "Mutt", terminal .. " -e mutt"},
    { "Weechat", terminal .. " -class WEECHAT -e ssh server -t 'LANG=en_US.UTF-8 exec tmux a -t weechat'"},
}

toolsMenu = {
    { "Calculator", "speedcrunch" },
    { "TodoMachine", terminal .. " -e todotxt-machine" },
    { "QOwnNotes", "QOwnNotes" },
    }

officeMenu = {
    { "Writer", "libreoffice --writer"},
    { "Calc", "libreoffice --calc"},
}

workMenu = {
    { "DBeaver", "dbeaver"},
    { "Cutecom", "cutecom"},
}

mymainmenu = awful.menu({ 
    items = { 
        { "Files", "thunar" },
        { "Tools", toolsMenu },
        { "Office", officeMenu },
        { "Internet", internetMenu },
        { "Work", workMenu },
        { "Awesome", myawesomemenu, beautiful.awesome_icon },
        { "Power", powerMenu },
    }
})

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
--app_folders = { "/usr/share/applications/", "~/.local/share/applications/" }

-- }}}

-- Keyboard map indicator and switcher
kbdwidget = awful.widget.keyboardlayout:new()
kbdwidget.widget.align = "center"

-- {{{ Custom widgets
paleLauncher = wibox.container.margin()
paleLauncher:setup {
    {      
        { 
            image = beautiful.palemoon_icon,
            widget = wibox.widget.imagebox,
            resize = true,
            forced_height = 32,
            buttons = gears.table.join(
                awful.button({ }, 1, function () 
                    local pm = false
                    local pm_c
                    for _, c in pairs(awful.screen.focused().all_clients) do
                        if c.class == "Pale moon" then
                            pm = true
                            pm_c = c
                        end
                    end
                    if pm then
                        client.focus = pm_c
                        pm_c:raise()
                        pm_c.first_tag:view_only()
                    else
                        awful.spawn("env GTK2_RC_FILES=/home/speranza/.gtkrc-2.0-light palemoon --no-remote -P Nusha")
                    end
                end)
                )
         },
        id = "root",
        widget = wibox.container.margin,
        left=5
    },
    id="right",
    right=2,
    color=theme.bg_normal,
    widget=wibox.container.margin
}
thunarLauncher = wibox.container.margin()
thunarLauncher:setup {
    {      
        { 
            image = beautiful.thunar_icon,
            widget = wibox.widget.imagebox,
            resize = true,
            forced_height = 32,
            buttons = gears.table.join(
                awful.button({ }, 1, function () 
                    local t = false
                    local t_c
                    for _, c in pairs(awful.screen.focused().all_clients) do
                        if c.class == "Thunar" then
                            t = true
                            t_c = c
                        end
                    end
                    if t then
                        client.focus = t_c
                        t_c:raise()
                        t_c.first_tag:view_only()
                    else
                        awful.spawn("env GTK2_RC_FILES=/home/speranza/.gtkrc-2.0-light thunar")
                    end
                end)
                )
         },
        id = "root",
        widget = wibox.container.margin,
        left=5
    },
    id="right",
    right=2,
    color=theme.bg_normal,
    widget=wibox.container.margin
}
if awesome.hostname ~= "laptop" then
    paleLauncher.visible = false
    thunarLauncher.visible = false
end

--- mail widget
mailwidget = wibox.container.margin()

mailwidget_buttons = gears.table.join(
    awful.button({ }, 1, function () awful.spawn(terminal .. " -e mutt") end)
    )
mailwidget:setup {
    {
        {
            id = "text",
            text = "@",
            align = "center",
            widget = wibox.widget.textbox
        },
        id = "bgd",
        buttons = mailwidget_buttons,
        widget = wibox.container.background
    },
    id = "root",
    layout = wibox.layout.fixed.vertical
}
mailwidget.root.bgd.forced_height=18
mailwidget.top = 0
mailwidget_tip = awful.tooltip({ objects = { mailwidget }})
mailwidgettimer = gears.timer({ timeout = 10 })
pr_mail = 0
wrk_mail = 0
telegram = 0
mailwidget_tip:set_text("MAIL\nPrivate\t\t" .. pr_mail .. "\n" .. "Work\t\t" .. wrk_mail .. "\nTELEGRAM\nDenis\t\t" .. telegram)
mailwidgettimer:connect_signal("timeout",
    function()
       if ( pr_mail > 0 or wrk_mail > 0) then
        mailwidget.root.bgd:set_bg(theme.bg_urgent)
        mailwidget.root.bgd.text:set_text(pr_mail+wrk_mail)
        mailwidget_buttons = gears.table.join(
            awful.button({ }, 1, function () awful.spawn(terminal .. " -e mutt") end)
            )
        mailwidget.root.bgd:buttons(mailwidget_buttons)
       else
        mailwidget.root.bgd:set_bg(theme.bg_normal)
        mailwidget.root.bgd.text:set_text("@")
        mailwidget_buttons = gears.table.join(
            awful.button({ }, 1, function () awful.spawn(terminal .. " -e mutt") end)
            )
        mailwidget.root.bgd:buttons(mailwidget_buttons)
       end
       if ( telegram > 0 ) then
        mailwidget.root.bgd:set_bg("#009DFF")
        mailwidget.root.bgd.text:set_text(telegram)
        mailwidget_buttons = gears.table.join(
            awful.button({ }, 1, function () awful.spawn("telegram-desktop") end)
            )
        mailwidget.root.bgd:buttons(mailwidget_buttons)
       end
       mailwidget_tip:set_text("MAIL\nPrivate\t" .. pr_mail .. "\n" .. "Work\t" .. wrk_mail .. "\nTELEGRAM\nDenis\t" .. telegram)
    end
)
mailwidgettimer:start()

-- Weather widget

weather_widget = wibox.container.margin()
i, w, t, h, wd, ws, c, u = getweather()
if i == nil then i, w, t, h, wd, ws, c, u = "", "na", "N/A", "na", "na", "na", "na", "na" end
weather_buttons = gears.table.join(
    awful.button({ }, 1, function () 
        i, w, t, h, wd, ws, c, u = getweather()
        awful.spawn(terminal .. " -hold -class CURL -e curl http://wttr.in/"..c)
    end)
    )
weather_widget:setup {
    {
        {
            id = "text",
            text = "w: "..t.."°",
            align = "center",
            widget = wibox.widget.textbox
        },
        id = "bgd",
        buttons = weather_buttons,
        widget = wibox.container.background
    },
    id = "root",
    layout = wibox.layout.fixed.vertical
}
weather_widget.top = 0
weather_widget_tip = awful.tooltip({ objects = { weather_widget }})
weatherwidgettimer = gears.timer({ timeout = 3600 })
weather_widget_tip:set_text("WEATHER @ "..c.."\nCondition:\t" .. w .. "\nHuminidity:\t" .. h .. "\nWind\t\t" .. wd .. " / " .. ws.." m/s\nUpdated:\t"..u)
weatherwidgettimer:connect_signal("timeout",
    function()
        --mailwidget_tip:set_text("MAIL\nPrivate\t" .. pr_mail .. "\n" .. "Work\t" .. wrk_mail .. "\nTELEGRAM\nDenis\t" .. telegram)

        i, w, t, h, wd, ws, c, u = getweather()
    end
)
weatherwidgettimer:start()

--- VPN widget
vpn_widget = wibox.container.margin()
vpn_buttons = gears.table.join(
    awful.button({ }, 1, function () 
        awful.spawn("networkmanager_dmenu")
    end)
    )
vpn_widget:setup {
    {
        {
            id = "text",
            text = "VPN",
            align = "center",
            widget = wibox.widget.textbox
        },
        id = "bgd",
        buttons = vpn_buttons,
        widget = wibox.container.background
    },
    id = "root",
    layout = wibox.layout.fixed.vertical
}
vpn_widget.top = 0
vpn_widget.visible = false
vpnwidgettimer = gears.timer({ timeout = 10 })
vpnwidgettimer:connect_signal("timeout",
    function()
       awful.spawn.with_line_callback(os.getenv("HOME").."/.config/awesome/bin/helpers.sh vpn", {
           stdout = function(line)
               vpn = line
           end})
       if vpn == "1" then
            vpn_widget.visible = true
       else
            vpn_widget.visible = false
       end
    end
)
vpnwidgettimer:start()
-- Background processes widget
bg_widget = wibox.container.margin()
bgds = {}
bg_buttons = gears.table.join(
    awful.button({ }, 1, function () 
        awful.menu(bgds):show()
    end)
    )
bg_widget:setup {
    {
        {
            id = "text",
            text = "BGND",
            align = "center",
            widget = wibox.widget.textbox
        },
        id = "bgd",
        buttons = bg_buttons,
        widget = wibox.container.background
    },
    id = "root",
    layout = wibox.layout.fixed.vertical
}
bg_widget.top = 0
bg_widget.visible = false
bg_widgettimer = gears.timer({ timeout = 10 })
bg_widgettimer:connect_signal("timeout",
    function()
        procs = {"test.sh", "fill.sh"}
        bgds={}
        for i, c in pairs(procs) do
            awful.spawn.easy_async("/usr/bin/pgrep "..c, function(stdout, stderr, reason, exit_code)
            if exit_code == 0 then
                table.insert(bgds, {"Kill "..c,
                      function()
                         awful.spawn("pkill "..c)
                      end
                     })
            end
            if next(bgds) ~= nil then
                bg_widget.visible = true
            else
                bg_widget.visible = false
            end
            end)
        end
    end
)
bg_widgettimer:start()

-- Volume widget stuff
step = 3 -- is used in key bindings on order to notify properly
function volume(action)
  local mixer
  local alsa_channel = vlm.channel
  if action == "+" or action == "-" then
      if volume_now.status == "off" then
          act = "toggle"
      else
          act = step .. "%" .. action
      end
  elseif action == "toggle" then
      act = action
  end
  mixer = io.popen("amixer -q sset " .. alsa_channel .. " " .. act)
end
volnotify = {}
volnotify.id = nil
function volnotify:notify(vol)
    if not awesome.startup then
        local icn = nil
        if vol == "M" then
            txt = 'Volume muted'
            icn = "notification-audio-volume-muted"
        else
            txt = 'Volume: ' .. vol .. '%'
            if tonumber(vol) == 0 then
                icn = "notification-audio-volume-off"
            elseif (tonumber(vol) <= 33) then
                icn = "notification-audio-volume-low"
            elseif (tonumber(vol) <= 66) then
                icn = "notification-audio-volume-medium"
            elseif (tonumber(vol) <= 100) then
                icn = "notification-audio-volume-high"
            end
        end
        self.id = naughty.notify({ text = txt, replaces_id = self.id, icon = icn}).id
    end
end

my_volume = wibox.container.margin()
my_volume.top = 0

vlm = lain.widget.alsa({timeout=1,
settings = function()
    if not awesome.startup then
        if volume_now.status == "off" then
            widget:set_markup(markup(beautiful.fg_urgent,"♫M"))
        else
            widget:set_markup(markup(beautiful.text_light,"♫" .. volume_now.level .. "%"))
        end
	    if volume_now.level == "100" then
            widget:set_markup(markup(beautiful.fg_urgent,"♫" .. "MAX"))
        end
        widget:set_align("center")
    end
end
})
my_volume:setup {
    id = "vlm",
    widget = vlm.widget
}
my_volume:buttons(gears.table.join(
    awful.button({ }, 1, function () volume("toggle") end),
    awful.button({ }, 4, function () volume("+") end),
    awful.button({ }, 5, function () volume("-") end)
    ))
-- Memory widget
mmr = lain.widget.mem{
    settings = function()
        if (math.floor(mem_now.used) *1.048576) >= 1000 then
            displ_mem = round(mem_now.used / 1024 * 1.048576, 1) .. "G"
        else
            displ_mem = math.floor(mem_now.used * 1.048676)
        end
            widget:set_text("☢" .. displ_mem)
    end
}
my_mem = wibox.container.margin(
    wibox.widget {
        align = "center",
        widget = mmr.widget
})
my_mem.top = 0

-- Battery widget stuff
my_bat = wibox.container.margin()
my_bat.top = 0
my_bat_tip = awful.tooltip({ objects = {my_bat}})
my_bat.visible = true
--local ff_tabs = os.getenv("HOME") .. "/.config/awesome/bin/helpers.sh firefox_tabs"
local pm_tabs = os.getenv("HOME") .. "/.config/awesome/bin/helpers.sh pm_tabs"
DPMS = 0
sleep = 0
check_tabs = {"youtube.com", "192.168.1.10"}
tabs = {}
luakit_yt = false
fullscreenClient = false
redshift = true
btt = lain.widget.bat({
        timeout = 60,
        settings=function()
		if awesome.hostname ~= "arch" then
        	widget:set_text("b: " .. bat_now.perc .. "%")
	   		if bat_now.perc == 100 then
       			widget:set_text("b: " .. " F")
		    end
    	else
			bat_now.ac_status = 0
			widget:set_text("⚕")
	   	end	
            widget:set_align("center")
            triggerTab = false
            if suspend ~= "manually" then
                if awesome.startup then
                    if bat_now.ac_status == 1 then
                        xset = true
                    else
                        xset = false
                    end
                else
                    awful.spawn.with_line_callback(pm_tabs, {
                        stdout = function(line)
                            tabs = line
                            loadstring(tabs)()
                        end})
                end
                local apps = {"Vlc", "Deadbeef", "mpv"}
                local roles = {"CallWindow"} --Skype's call window
                local clients = client.get()
                local i = 0
                for _, clientsValue in pairs(clients) do
                    for _, appsValue in pairs(apps) do
                        if clientsValue.class == appsValue then
                            i = i + 1
                        end
                    end
                    if clientsValue.fullscreen then
                        fullscreenClient = true
                        break
                    else
                        fullscreenClient = false
                    end
                    for _, rolesValue in pairs(roles) do
                        if clientsValue.role == rolesValue then
                            i = i + 1
                        end
                    end
                end
                if fullscreenClient and redshift then
                    awful.spawn("redshift -x >/dev/null 2>&1")
                    redshift = false
                elseif not fullscreenClient and not redshift then
                    awful.spawn("redshift -o >/dev/null 2>&1")
                    redshift = true
                end
                for _, checkTab in pairs(check_tabs) do
                    for _,currTab in pairs(tabs) do
                        if currTab == checkTab then
                            triggerTab = true
                        end
                    end
                end
                if i > 0 or triggerTab or luakit_yt and suspend == "enabled" then
                    awful.spawn("xautolock -disable")
                    awful.spawn("xset -dpms")
                    awful.spawn("xset s off")
                    suspend = "disabled"
                    my_bat.root.bgd:set_bg("#7A4000")
                    my_bat_tip:set_text("DPMS\t" .. suspend .. "\nSleep\t" .. suspend)
                elseif i == 0 and not triggerTab and not luakit_yt and suspend == "disabled" then
                    awful.spawn("xautolock -enable")
                    awful.spawn("xset +dpms")
                    --awful.spawn("xset s " .. DPMS)
                    suspend = "enabled"
                    my_bat.root.bgd:set_bg(theme.bg_normal)
                    my_bat_tip:set_text("DPMS\t" .. string.format("%.0f", DPMS/60) .. " min\nSleep\t" .. sleep)
    --                end

                end
                if suspend == "enabled" then
                    if bat_now.ac_status == 1 and xset then -- transition from battery to ac
                        DPMS=300
                        awful.spawn("xset -dpms")
                        --awful.spawn("xset s " .. DPMS)
                        awful.spawn("xautolock -disable")
                        sleep="disabled"
                        xset = false
                        if not awesome.startup then
                            naughty.notify({text = "Power connected"})
                        end
                        my_bat_tip:set_text("DPMS\t" .. string.format("%.0f", DPMS/60) .. " min\nSleep\t" .. sleep)
                    elseif bat_now.ac_status == 0 and not xset then --transition from ac to battery
                        DPMS=180
                        awful.spawn("xset +dpms")
                        --awful.spawn("xset s " .. DPMS)
                        awful.spawn("xautolock -enable")
                        sleep="5 min"
                        xset = true
                        if not awesome.startup then
                            naughty.notify({text = "Power disconnected"})
                        end
                        my_bat_tip:set_text("DPMS\t" .. string.format("%.0f", DPMS/60) .. " min\nSleep\t" .. sleep)
                    end
                end

            end
            bat_notification_low_preset = {fg = "#ffffff",bg = "#ff0000", title = "Battery low", text = "Plug the cable!"}
            bat_notification_critical_preset = {fg = "#202020",bg = "#CDCDCD", title = "Battery exhausted", text = "Shutdown imminent"}
    end
})
my_bat:setup {
   {
       {
           id = "lain_bat",
           widget = btt.widget
       },
       id = "bgd",
       widget = wibox.container.background
   },
   id = "root",
   layout = wibox.layout.fixed.vertical
}
my_bat.root.bgd.forced_height=25
my_bat:buttons(gears.table.join(
  awful.button({ }, 1, function() --click to disable suspend
    if suspend == "enabled" then
        awful.spawn("xset -dpms")
        awful.spawn("xautolock -disable")
        suspend = "manually"
        my_bat.root.bgd:set_bg("#7A4000")
        my_bat_tip:set_text("DPMS\t" .. suspend .. "\nSleep\t" .. suspend)
    else
        awful.spawn("xset +dpms")
        --awful.spawn("xset s " .. DPMS)
        awful.spawn("xautolock -enable")
        suspend = "enabled"
        my_bat.root.bgd:set_bg(theme.bg_normal)
        my_bat_tip:set_text("DPMS\t" .. string.format("%.0f", DPMS/60) .. " min\nSleep\t" .. sleep)
    end
  end)
))




-- Systray widget
systray = wibox.container.margin()
systray:setup {
	id = "sstr",
	widget = wibox.widget.systray()
}
systray.sstr:set_horizontal(false)
if awesome.hostname == "arch" then
	systray.left = 13
	systray.right = 13
elseif awesome.hostname == "laptop" then
    systray.left = 14
    systray.right = 14
end
-- Server monitoring widget
awful.widget.watch('bash -c "cat $HOME/.bin/temp/server_status"', 300, function(widget, stdout)
    local avg_bg = theme.bg_normal
    local temp_bg = theme.bg_normal
    local hdd_bg = theme.bg_normal
    local upd_bg = theme.bg_normal
    local ram_bg = theme.bg_normal
    srv_mon.root.right:set_color(theme.bg_normal)
    local lines = {}
    for line in stdout:gmatch("[^\r\n]+") do 
        lines[#lines + 1] = line
    end
    if tonumber(lines[5]) > 10 then
        upd_bg = "#2943FF"
        srv_mon.root.right:set_color(upd_bg)
        srv_mon_buttons = gears.table.join(
            awful.button({ }, 1, function () awful.spawn(terminal .. " -e ssh server -t pacaur -Syu --noedit --noconfirm && exit 0") end)
            )
        srv_mon.root.right:buttons(srv_mon_buttons)
    end
    if tonumber(string.match(lines[3], "%d+")) > 65 then
        temp_bg = "#800000"
        srv_mon.root.right:set_color(temp_bg)
    end
    if tonumber(string.match(lines[7], "%d+")) > 999 then
        ram_bg = "#A52A2A"
        srv_mon.root.right:set_color(ram_bg)
    end
    local root, home, backup = string.match(lines[4], "^(%d+)%% (%d+)%% (%d+)%%")
    if tonumber(root) > 80 or tonumber(home) > 80 or tonumber(backup) > 80 then
        hdd_bg = "#739300"
        srv_mon.root.right:set_color(hdd_bg)
    end
    local five_min_load = string.match(lines[2], "^%d+.%d+, (%d+).%d+")
    if tonumber(five_min_load) >= 1 then
        avg_bg = "#FF0000"
        srv_mon.root.right:set_color(avg_bg)
    end
    srv_tip:set_markup("SERVER\n" .. lines[1].."<span background='" .. avg_bg .. "'>\nAverage load:\t\t" .. lines[2] .. "</span><span background='"..temp_bg .. "'>\nTemperature:\t\t" .. lines[3] .. "</span><span background='".. hdd_bg .. "'>\nRoot/Home/Backup usage:\t" .. lines[4] .. "</span><span background='" .. upd_bg .. "'>\nUpdates pending:\t".. lines[5] .. "</span>\nWashing:\t\t" .. lines[6]..":00".."<span background='" .. ram_bg.."'>\nRAM:\t\t\t"..lines[7].."</span>\nUpdated at:\t\t" ..lines[8])
end)
awful.widget.watch('bash -c "cat $HOME/.bin/temp/local_status"', 300, function(widget, stdout)
    local avg_bg = theme.bg_normal
    local temp_bg = theme.bg_normal
    local hdd_bg = theme.bg_normal
    local upd_bg = theme.bg_normal
    local ram_bg = theme.bg_normal
    srv_mon.root.right_loc:set_color(theme.bg_normal)
    local lines = {}
    for line in stdout:gmatch("[^\r\n]+") do 
        lines[#lines + 1] = line
    end
    if tonumber(lines[3]) > 10 then
        upd_bg = "#2943FF"
        srv_mon.root.right_loc:set_color(upd_bg)
        srv_mon_buttons = gears.table.join(
            awful.button({ }, 1, function () awful.spawn(terminal .. " -e pacaur -Syu --noedit --noconfirm && exit 0") end)
            )
        srv_mon.root.right_loc:buttons(srv_mon_buttons)
    end
    if tonumber(string.match(lines[5], "%d+")) > 65 then
        temp_bg = "#800000"
        srv_mon.root.right_loc:set_color(temp_bg)
    end
    local root, home = string.match(lines[4], "^(%d+)%% (%d+)%%")
    if tonumber(root) > 80 or tonumber(home) > 80 then
        hdd_bg = "#739300"
        srv_mon.root.right_loc:set_color(hdd_bg)
        srv_mon_buttons = gears.table.join(
            awful.button({ }, 1, function () awful.spawn(terminal .. " -e ncdu /") end)
            )
        srv_mon.root.right_loc:buttons(srv_mon_buttons)
    end
    local five_min_load = string.match(lines[2], "^%d+.%d+, (%d+).%d+")
    if tonumber(five_min_load) >= 1 then
        avg_bg = "#FF0000"
        srv_mon.root.right_loc:set_color(avg_bg)
    end
    loc_tip:set_markup("This machine\n" .. lines[1].."<span background='"..avg_bg.."'>\nAverage load:\t\t" .. lines[2].. "</span><span background='"..temp_bg .. "'>\nTemperature:\t\t" .. lines[5] .. "</span><span background='".. hdd_bg .. "'>\nRoot/Home usage:\t" .. lines[4] .. "</span><span background='" .. upd_bg .. "'>\nUpdates pending:\t".. lines[3].."</span>")
end)
srv_mon = wibox.container.margin()
srv_mon:setup {
    {
        {
            id = "text",
            text = "⚒",
            align = "center",
            widget = wibox.widget.textbox
        },
        id = "right",
        right = 2,
        color = theme.bg_normal,
        widget = wibox.container.margin
    },
    {
        {
            id = "text_loc",
            text = "⚔",
            align = "center",
            widget = wibox.widget.textbox
        },
        id = "right_loc",
        right = 2,
        color = theme.bg_normal,
        widget = wibox.container.margin
    },
    id = "root",
    layout = wibox.layout.flex.horizontal
}
srv_mon.top = 3
srv_tip = awful.tooltip({ objects = { srv_mon.root.right }})
loc_tip = awful.tooltip({ objects = { srv_mon.root.right_loc }})
-- }}}

-- {{{ Wibar
-- Create a textclock widget
--mytextclock:set_align("center")
txtclock = wibox.container.margin()
txtclock:setup {
    {
        {
            id = "text",
            align = "center",
            widget = wibox.widget.textclock("%H:%M")
        },
        id = "right",
        right = 4,
        widget = wibox.container.margin,
        color = theme.bg_normal,

    },
    id = "root",
    layout = wibox.layout.flex.horizontal
}
local words = {"годовщина", "Годовщина", "ДР", "birthdays"}
awful.widget.watch('khal list today --format "{calendar} {title}"', 300, function(widget, stdout)
    for line in stdout:gmatch("[^\r\n]+") do 
        for _, word in pairs(words) do
            if string.find(line, word) then
                txtclock.root.right:set_color(theme.bg_urgent)
                break
            end
        end
    end

end)
cal = lain.widget.calendar({attach_to = {txtclock}, cal = os.getenv("HOME") .. "/.config/awesome/bin/cal.sh", notification_preset = {fg = theme.text_dark,bg = theme.bg_normal, border_color = theme.highlight_light, font = "Monospace Regular 11", position = "bottom_left"}, icons = "/"})

-- Create a wibox for each screen and add it
local taglist_buttons = gears.table.join(
    awful.button({ }, 1, function(t) t:view_only() end),
    awful.button({ modkey }, 1, function(t)
        if client.focus then
            client.focus:move_to_tag(t)
        end
    end),
    awful.button({ }, 3, awful.tag.viewtoggle),
    awful.button({ modkey }, 3, function(t)
        if client.focus then
            client.focus:toggle_tag(t)
        end
    end),
    awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) end),
    awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end)
                )

local tasklist_buttons = gears.table.join(
    awful.button({ }, 1, function (c)
        if c == client.focus then
            c.minimized = true
        else
            -- Without this, the following
            -- :isvisible() makes no sense
            c.minimized = false
            if not c:isvisible() and c.first_tag then
                c.first_tag:view_only()
            end
            -- This will also un-minimize
            -- the client, if needed
            client.focus = c
            c:raise()
        end
    end),
    awful.button({ }, 3, client_menu_toggle_fn()),
    awful.button({ }, 4, function ()
        awful.client.focus.byidx(1)
    end),
    awful.button({ }, 5, function ()
        awful.client.focus.byidx(-1)
    end)
)

local function set_wallpaper(s)
    -- Wallpaper
    if beautiful.wallpaper then
        local wallpaper = beautiful.wallpaper
        -- If wallpaper is a function, call it with the screen
        if type(wallpaper) == "function" then
            wallpaper = wallpaper(s)
        end
        gears.wallpaper.maximized(wallpaper, s, true)
    end
end

			
-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)

awful.screen.connect_for_each_screen(function(s)
    -- Wallpaper
    set_wallpaper(s)

    if awesome.hostname == "laptop" then
        awful.tag.add("Nush", {
            layout = awful.layout.layouts[1],
            screen = s,
            selected = true
        })
    end
    awful.tag.add("Term", {
        layout = awful.layout.layouts[2],
        screen = s,
    })
    awful.tag.add("Den", {
        layout = awful.layout.layouts[2],
        screen = s,
    })
    awful.tag.add("Chat", {
        layout = awful.layout.layouts[2],
        screen = s,
    })
    awful.tag.add("Docs", {
        layout = awful.layout.layouts[2],
        screen = s,
    })
    awful.tag.add("Devs", {
        layout = awful.layout.layouts[2],
        screen = s,
    })



--   mytag.incnmaster(2)
    -- Create a promptbox for each screen
    s.mypromptbox = awful.widget.prompt()
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
--    s.mylayoutbox = awful.widget.layoutbox(s)
--    s.mylayoutbox = wibox.container.margin(awful.widget.layoutbox(s), 4, 4, 4, 4)
--    s.mylayoutbox:buttons(gears.table.join(
--                           awful.button({ }, 1, function () awful.layout.inc( 1) end),
--                           awful.button({ }, 3, function () awful.layout.inc(-1) end),
--                           awful.button({ }, 4, function () awful.layout.inc( 1) end),
--                           awful.button({ }, 5, function () awful.layout.inc(-1) end)))
    -- Create a taglist widget
    s.mytaglist = awful.widget.taglist(s, awful.widget.taglist.filter.all, taglist_buttons, nil, verticaltag, wibox.layout.fixed.vertical())

    -- Create a tasklist widget
    s.mytasklist = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, tasklist_buttons, nil, verticaltask, wibox.layout.fixed.vertical())


    -- Create the wibox
    s.mywibar = awful.wibar({ position = "left", screen = s, width = 44})

    -- Add widgets to the wibox
    local top_layout = wibox.layout.fixed.vertical(s.mytaglist, paleLauncher, thunarLauncher)
    local mid_layout =  wibox.layout.fixed.vertical(s.mytasklist)
    local bot_layout = wibox.layout.fixed.vertical(systray, srv_mon, bg_widget, vpn_widget, my_mem, mailwidget, my_bat, weather_widget, my_volume, kbdwidget, txtclock)
    
    local layout = wibox.layout.align.vertical()
    layout:set_top(top_layout)
    layout:set_middle(mid_layout)
    layout:set_bottom(bot_layout)

    s.mywibar:set_widget(layout)

end)
-- }}}

-- {{{ Mouse bindings
root.buttons(gears.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = gears.table.join(
    awful.key({ modkey,           }, "s",      hotkeys_popup.show_help,
              {description="show help", group="awesome"}),
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev,
              {description = "view previous", group = "tag"}),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext,
              {description = "view next", group = "tag"}),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore,
              {description = "go back", group = "tag"}),

    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
        end,
        {description = "focus next by index", group = "client"}
    ),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
        end,
        {description = "focus previous by index", group = "client"}
    ),
    awful.key({ modkey,           }, "w", function () mymainmenu:show() end,
              {description = "show main menu", group = "awesome"}),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end,
              {description = "swap with next client by index", group = "client"}),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end,
              {description = "swap with previous client by index", group = "client"}),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end,
              {description = "focus the next screen", group = "screen"}),
--    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end,
--              {description = "focus the previous screen", group = "screen"}),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto,
              {description = "jump to urgent client", group = "client"}),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end,
        {description = "go back", group = "client"}),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.spawn(terminal) end,
              {description = "open a terminal", group = "launcher"}),
    awful.key({ modkey, "Control" }, "r", awesome.restart,
              {description = "reload awesome", group = "awesome"}),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit,
              {description = "quit awesome", group = "awesome"}),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)          end,
              {description = "increase master width factor", group = "layout"}),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)          end,
              {description = "decrease master width factor", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1, nil, true) end,
              {description = "increase the number of master clients", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1, nil, true) end,
              {description = "decrease the number of master clients", group = "layout"}),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1, nil, true)    end,
              {description = "increase the number of columns", group = "layout"}),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1, nil, true)    end,
              {description = "decrease the number of columns", group = "layout"}),
    awful.key({ modkey,           }, "space", function () awful.layout.inc( 1)                end,
              {description = "select next", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(-1)                end,
              {description = "select previous", group = "layout"}),

    awful.key({ modkey, "Control" }, "n",
              function ()
                  local c = awful.client.restore()
                  -- Focus restored client
                  if c then
                      client.focus = c
                      c:raise()
                  end
              end,
              {description = "restore minimized", group = "client"}),

    awful.key({ modkey },            "r",     function () awful.spawn("rofi -show drun") end), 
    -- Menubar
    awful.key({ modkey }, "p", function() menubar.show() end,
              {description = "show the menubar", group = "launcher"}),
    -- ALSA volume
    awful.key({ }, "XF86AudioRaiseVolume", function() 
        volume("+") 
        if volume_now.status == "on" then
            volnotify:notify(string.format("%.0f", volume_now.level+step))
        else
            volnotify:notify(volume_now.level)
        end
    end),
    awful.key({ }, "XF86AudioLowerVolume", function() volume("-")
        volnotify:notify(string.format("%.0f", volume_now.level-step))
    end),
    awful.key({ }, "XF86AudioMute",        function() volume("toggle")
        if volume_now.status == "on" then
            volnotify:notify("M")
        else
            volnotify:notify(volume_now.level)
        end

    end),
    -- Brightness buttons
    awful.key({ }, "XF86MonBrightnessDown", function () 
        brt, icon=b_notify()
        if brt > 5 then
            awful.spawn("light -U 5")
            brt=brt-5
        end
        nid = naughty.notify({text = "Brightness: " .. brt .. "%", replaces_id = nid, icon = icon}).id 
    end),
    awful.key({ }, "XF86MonBrightnessUp", function ()
        brt, icon=b_notify()
        if brt < 100 then
            brt=brt+5
        end
        awful.spawn("light -A 5")
        nid = naughty.notify({text = "Brightness: " .. brt .. "%", replaces_id = nid, icon = icon}).id
    end),
    -- Custom keybindings
   awful.key({ }, "Pause", function () awful.spawn("systemctl suspend") end),
   awful.key({ modkey, "Shift" }, "n",     function () awful.spawn("env GTK2_RC_FILES=/home/speranza/.gtkrc-2.0-light palemoon -P Nusha")          end,
              {description = "launch Nusha's Palemoon", group = "custom"}),
   awful.key({ modkey, "Control" }, "l",     function () awful.spawn("env GTK2_RC_FILES=/home/speranza/.gtkrc-2.0-light luakit")          end,
              {description = "launch Luakit", group = "custom"}),
   awful.key({ modkey, "Control" }, "m",     function () awful.spawn(terminal .. " -e mutt")          end,
              {description = "launch Mutt", group = "custom"}),
   awful.key({ modkey, "Control" }, "w",     function () awful.spawn(terminal .. " -class WEECHAT -e ssh server -t 'LANG=en_US.UTF-8 exec tmux a -t weechat'")          end,
              {description = "attach to Weechat", group = "custom"}),
   awful.key({ modkey, "Control" }, "x",     function () awful.spawn(terminal .. " -hold -e \"xprop\"")          end,
              {description = "Get window.Class property", group = "custom"}),
   awful.key({ modkey, "Shift" }, "t",     translate,
              {description = "Translate selected text using Yandex.Translate", group = "custom"}),
   awful.key({ modkey,  }, "o",     function() awful.spawn(os.getenv("HOME").."/.bin/rofi_files.sh launch") end,
              {description = "Translate selected text using Yandex.Translate", group = "custom"}),
   awful.key({ modkey, "Control" }, "k",     function () awful.spawn("rofi-pass") end,
              {description = "Password manager", group = "custom"}),
   awful.key({ }, "Print",     function () awful.spawn("xfce4-screenshooter -f") end,
              {description = "Take a screenshot of the entire screen", group = "custom"}),
   awful.key({"Control" }, "Print",     function () awful.spawn("xfce4-screenshooter -r") end,
              {description = "Take a screenshot ot the selected region", group = "custom"}),
   awful.key({"Mod1" }, "Print",     function () awful.spawn("xfce4-screenshooter -w") end,
              {description = "Take a screenshot ot the active window", group = "custom"}),
   awful.key({"Mod1" }, "m",     function () awful.spawn(os.getenv("HOME").."/.hud/hud-menu.py") end,
              {description = "Show a HUD menu", group = "custom"}),
   awful.key({"Mod1", "Control" }, "n",     function () awful.spawn("networkmanager_dmenu") end,
              {description = "Launch networkmanager-dmenu", group = "custom"})
)

clientkeys = gears.table.join(
    awful.key({ modkey,           }, "f",
        function (c)
            c.fullscreen = not c.fullscreen
            c:raise()
        end,
        {description = "toggle fullscreen", group = "client"}),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end,
              {description = "close", group = "client"}),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ,
              {description = "toggle floating", group = "client"}),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end,
              {description = "move to master", group = "client"}),
    awful.key({ modkey,           }, "o",      function (c) c:move_to_screen()               end,
              {description = "move to screen", group = "client"}),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end,
              {description = "toggle keep on top", group = "client"}),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end ,
        {description = "minimize", group = "client"}),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized = not c.maximized
            c:raise()
        end ,
        {description = "maximize", group = "client"})
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    globalkeys = gears.table.join(globalkeys,
        -- View tag only.
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = awful.screen.focused()
                        local tag = screen.tags[i]
                        if tag then
                           tag:view_only()
                        end
                  end,
                  {description = "view tag #"..i, group = "tag"}),
        -- Toggle tag display.
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = awful.screen.focused()
                      local tag = screen.tags[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end,
                  {description = "toggle tag #" .. i, group = "tag"}),
        -- Move client to tag.
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:move_to_tag(tag)
                          end
                     end
                  end,
                  {description = "move focused client to tag #"..i, group = "tag"}),
        -- Toggle tag on focused client.
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:toggle_tag(tag)
                          end
                      end
                  end,
                  {description = "toggle focused client on tag #" .. i, group = "tag"})
    )
end

clientbuttons = gears.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).

if awesome.hostname == "laptop" then
    is_laptop = true
else
    is_laptop = false
end
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = theme.border_width,
                     border_color = theme.border_normal,
                     focus = awful.client.focus.filter,
                     raise = true,
                     keys = clientkeys,
                     buttons = clientbuttons,
                     screen = awful.screen.preferred,
                     placement = awful.placement.no_overlap+awful.placement.no_offscreen,
                     size_hints_honor = false,
                     switchtotag = true,
     }
    },

    -- Floating clients.
    { rule_any = {
        instance = {
          "DTA",  -- Firefox addon DownThemAll.
          "copyq",  -- Includes session name in class.
        },
        class = {
          "Arandr",
          "Gpick",
          "Kruler",
          "MessageWin",  -- kalarm.
          "Sxiv",
          "Wpa_gui",
          "pinentry",
          "veromix",
          "xtightvncviewer",
          "Keepassx2",
          "Tk",
          "Dialog",
          "feh",
          "SpeedCrunch"},

        name = {
          "Event Tester",  -- xev.
          "Computers & Contacts", --teamviewer contact list
        },
        role = {
          "AlarmWindow",  -- Thunderbird's calendar.
          "pop-up",       -- e.g. Google Chrome's (detached) Developer Tools.
        }
      }, properties = { floating = true }},

    -- Add titlebars to normal clients and dialogs
    { rule_any = {type = { "normal", "dialog" }
      }, properties = { titlebars_enabled = true }
    },

     --Set Firefox to always map on the tag named "1" on screen 1.
     { rule_any = { class = {"Firefox", "Luakit"}},
       except = { type = "dialog"},
       properties = { screen = 1, tag = "Den", maximized = true} },
     { rule_any = { class = {"Pale moon"}},
       except = { type = "dialog"},
       properties = { tag = "Nush", skip_taskbar = is_laptop} },
     { rule = { class = "Thunar" },
       properties = { skip_taskbar = is_laptop } },
     { rule = { name = "Keyboard" },
       properties = { focusable = false, ontop = true } },
     { rule = { class = "CURL" },
       properties = { maximized = true } },
     { rule = { class = "XTerm" },
       properties = { tag = "Term"} },
     --{ rule = { class = "Luakit" },
     --  properties = { screen = 1, tag = "1" } },
     { rule_any = { instance = { "libreoffice"} },
       properties = { screen = 1, tag = "Docs" } },
     { rule_any = { class = { "Geary", "TelegramDesktop", "WEECHAT" } },
       properties = { screen = 1, tag = "Chat",  callback =  function()
                        if not awesome.startup then    
                            local screen = awful.screen.focused()
                            local tag = screen.tags[4]
                            if tag then
                                tag:view_only()
                            end
                        end
                    end
       } },
}
-- }}}
-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    -- if not awesome.startup then awful.client.setslave(c) end

    if awesome.startup and
      not c.size_hints.user_position
      and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end
    if awful.screen.focused().selected_tag.name == "Term" and #awful.screen.focused().selected_tag:clients() == 3 and not awful.screen.focused().selected_tag:clients()[3].floating then
        awful.tag.incnmaster(1, nil, true)
        master_increased = true
    end
    if awesome.hostname == "laptop" then
        if awful.screen.focused().selected_tag.index == 1 then
            awful.titlebar.show(c)
        end
    end
end)
client.connect_signal("unmanage", function (c)
    if awful.screen.focused().selected_tag.name == "Term" and #awful.screen.focused().selected_tag:clients() == 2 and master_increased then
        awful.tag.incnmaster(-1, nil, true)
        master_increased = false
    end
end)


-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)

    -- buttons for the titlebar
    local buttons = gears.table.join(
            awful.button({ }, 1, function()
                client.focus = c
                c:raise()
                awful.mouse.client.move(c)
            end)
            )

    -- Minimize, Maximize, Close buttons
    local right_layout = wibox.layout.fixed.horizontal()
    right_layout:add(awful.titlebar.widget.minimizebutton(c))
    right_layout:add(awful.titlebar.widget.maximizedbutton(c))
    right_layout:add(awful.titlebar.widget.closebutton(c))
    --right_layout.forced_width=150

    -- Dragable titlebar
    local middle_layout = wibox.layout.fixed.horizontal()
    middle_layout:buttons(buttons)

    -- Now bring it all together
    local layout = wibox.layout.align.horizontal()
    layout:set_right(right_layout)
    layout:set_middle(middle_layout)

    awful.titlebar(c,{size=15}):set_widget(layout) 
    awful.titlebar.hide(c)
end)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
    if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
        and awful.client.focus.filter(c) then
        client.focus = c
    end
end)

client.connect_signal("focus", function(c) 
    c.border_color = theme.border_focus
    if c.class == "Pale moon" then
        paleLauncher.right:set_color(theme.highlight_light)
    end
    if c.class == "Thunar" then
        thunarLauncher.right:set_color(theme.highlight_light)
    end
end)
client.connect_signal("unfocus", function(c) 
    c.border_color = theme.border_normal 
    if c.class == "Pale moon" then
        paleLauncher.right:set_color(theme.bg_normal)
    end
    if c.class == "Thunar" then
        thunarLauncher.right:set_color(theme.bg_normal)
    end
end)
-- }}}

-- {{{ Arrange signal handler
for s = 1, screen.count() do screen[s]:connect_signal("arrange", function ()
        local clients = screen[s].clients
        local layout  = awful.layout.getname(awful.layout.get(s))

        if #clients > 0 then
            for _, c in pairs(clients) do
				if (c.maximized == true) then
					c.border_width = 0
                else
					c.border_width = beautiful.border_width
                end
            end
        end
      end)
end
-- }}}
