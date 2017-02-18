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


-- {{{ Notifications position and border width
naughty.config.presets.normal.position = "bottom_left"
naughty.config.icon_dirs = {os.getenv("HOME") .. "/.config/awesome/themes/icons/"}
naughty.config.icon_formats = {"png", "svg"}
naughty.config.presets.normal.font = "Monospace Regular 11"
naughty.config.presets.normal.bg = "#222222"
naughty.config.presets.normal.fg = "#999999"
-- }}}



-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

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
    function verticaltag(w, buttons, label, data, objects)
		w:reset()
		for i, o in ipairs(objects) do
			local cache = data[o]
			local tb, bgb, m, ah, bgt, ms
			if cache then
				tb = cache.tb
				bgb = cache.bgb
				m = cache.m
				ah = cache.ah
				bgt = cache.bgt
				ms = cache.ms
			else
				tb = wibox.widget.textbox()
				bgb = wibox.container.background()
				bgt = wibox.container.background()
				ah = wibox.layout.align.horizontal()
				ah:set_middle(tb)
                ah:set_expand("none")
				bgt:set_widget(ah)
				ms = wibox.container.margin(bgt, 0, 2, 0, 0)
				m = wibox.container.margin(ms, 0, 0, 0, 2)
				bgb:set_bg(beautiful.border_normal)
				bgb:set_widget(m)
				bgb:buttons(common.create_buttons(buttons, o))
				data[o] = {
					tb = tb,
					bgb = bgb,
					m   = m,
					ah = ah,
					bgt = bgt,
					ms = ms
				}
			end
			local text, bg, bg_image, icon = label(o)
			if not pcall(tb.set_markup, tb, markup(beautiful.text_dark, text)) then
				tb:set_markup("<i>&lt;Invalid text&gt;</i>")
			end
			if bg_image == "light" then
				tb:set_markup(markup(beautiful.text_light, text))
			end
			bgt:set_bg(bg)
			if bg == beautiful.taglist_bg_focus then
				ms:set_color(beautiful.fg_focus)
			else
				ms:set_color(beautiful.border_normal)
			end
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
hostname = io.popen("uname -n"):read()

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
run_once("kbdd")
run_once("redshift -o")
--run_once("xfce4-power-manager")
--run_once("xcompmgr")
if hostname == "arch" then
    DPMS=600
    run_once("numlockx on")
    run_once("xautolock -time 10 -locker 'systemctl suspend' -detectsleep &")
elseif hostname == "laptop" then
	run_once(os.getenv("HOME") .. "/.bin/disable_touch.sh")
	run_once("syndaemon -d -k -i 1")
    run_once("xautolock -time 5 -locker 'systemctl suspend' -detectsleep &")
    DPMS=180
    suspend = "enabled"
    --xset = true -- true=battery(180s), false=AC(300s) it's being set inside battery widget callback function
    lock = true -- 1=enabled, 0=disabled
end
run_once("xset s " .. DPMS)

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
            instance = awful.menu.clients({ theme = { width = 250 } })
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
        nid = naughty.notify({text = "Brightness: " .. brt .. "%", replaces_id = nid, icon = icon}).id 
end

function translate()
    awful.spawn.easy_async(os.getenv("HOME") .. "/.config/awesome/bin/trans.py", function(stdout, stderr, reason, exit_code)
        naughty.notify({ title = "Translation", text = string.gsub(stdout, "\n$", ""), icon = "dict" })
    end)
end

-- }}}

-- {{{ Menu
-- Create a launcher widget and a main menu
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
    { "Firefox Nusha", "env GTK_THEME=Greybird firefox" },
    { "Skype", "skype" },
    { "Luakit", "luakit" },
    { "Telegram", "telegram-desktop" },
    { "Geary", "geary"}
}


mymainmenu = awful.menu({ items = { { "Internet", internetMenu },
                                    { "Files", "thunar" },
                                    { "awesome", myawesomemenu, beautiful.awesome_icon },
                                    { "open terminal", terminal },
                                    { "Power", powerMenu },
                                  }
                        })

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = mymainmenu })

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
--app_folders = { "/usr/share/applications/", "~/.local/share/applications/" }

-- }}}

-- Keyboard map indicator and switcher
--local mykeyboardlayout = wibox.widget.textbox()
kbdwidget = awful.widget.keyboardlayout:new()
kbdwidget.widget.align = "center"

--mykeyboardlayout:set_text(kbw)
--]]
-- {{{ Custom widgets
mailwidget = wibox.container.margin()

mailwidget_buttons = awful.util.table.join(
    awful.button({ }, 1, function () awful.spawn("geary") end)
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
        mailwidget_buttons = awful.util.table.join(
            awful.button({ }, 1, function () awful.spawn("geary") end)
            )
        mailwidget.root.bgd:buttons(mailwidget_buttons)
       else
        mailwidget.root.bgd:set_bg(theme.bg_normal)
        mailwidget.root.bgd.text:set_text("@")
        mailwidget_buttons = awful.util.table.join(
            awful.button({ }, 1, function () awful.spawn("geary") end)
            )
        mailwidget.root.bgd:buttons(mailwidget_buttons)
       end
       if ( telegram > 0 ) then
        mailwidget.root.bgd:set_bg("#009DFF")
        mailwidget.root.bgd.text:set_text(telegram)
        mailwidget_buttons = awful.util.table.join(
            awful.button({ }, 1, function () awful.spawn("telegram-desktop") end)
            )
        mailwidget.root.bgd:buttons(mailwidget_buttons)
       end
       mailwidget_tip:set_text("MAIL\nPrivate\t" .. pr_mail .. "\n" .. "Work\t" .. wrk_mail .. "\nTELEGRAM\nDenis\t" .. telegram)
    end
)
mailwidgettimer:start()

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
my_volume.top = "3"

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
my_volume:buttons(awful.util.table.join(
    awful.button({ }, 1, function () volume("toggle") end),
    awful.button({ }, 4, function () volume("+") end),
    awful.button({ }, 5, function () volume("-") end)
    ))
-- Battery widget stuff
if hostname ~= "arch" then
my_bat = wibox.container.margin()
my_bat.top = "3"
my_bat_tip = awful.tooltip({ objects = {my_bat}})
my_bat.visible = true
local mpstat = os.getenv("HOME") .. "/.config/awesome/bin/helpers.sh mpstat"
local xget = os.getenv("HOME") .. "/.config/awesome/bin/helpers.sh xset"
local ff_tabs = os.getenv("HOME") .. "/.config/awesome/bin/helpers.sh firefox_tabs"
DPMS = 0
sleep = 0
check_tabs = {"youtube.com"}
tabs = {}
fullscreenClient = false
redshift = true
btt = lain.widget.bat({
        bat_notification_low_preset = naughty.config.presets.normal,
        bat_notification_critical_preset = naughty.config.presets.critical,
        timeout = 60,
        settings=function()
            widget:set_text("⚕" .. bat_now.perc .. "%")
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
                    awful.spawn.with_line_callback(ff_tabs, {
                        stdout = function(line)
                            tabs = line
                            loadstring(tabs)()
                        end})
                end
                local apps = {"Vlc", "Deadbeef"}
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
                    awful.util.spawn("redshift -x >/dev/null 2>&1")
                    redshift = false
                elseif not fullscreenClient then
                    awful.util.spawn("redshift -o >/dev/null 2>&1")
                    redshift = true
                end
                for _, checkTab in pairs(check_tabs) do
                    for _,currTab in pairs(tabs) do
                        if currTab == checkTab then
                            triggerTab = true
                        end
                    end
                end
                if i > 0 or triggerTab and suspend == "enabled" then
                    awful.spawn("xautolock -disable")
                    awful.spawn("xset s off")
                    suspend = "disabled"
                    my_bat.root.bgd:set_bg("#7A4000")
                    my_bat_tip:set_text("DPMS\t" .. suspend .. "\nSleep\t" .. suspend)
                elseif i == 0 and not triggerTab and suspend == "disabled" then
                    awful.spawn("xautolock -enable")
                    awful.spawn("xset s " .. DPMS)
                    suspend = "enabled"
                    my_bat.root.bgd:set_bg(theme.bg_normal)
                    my_bat_tip:set_text("DPMS\t" .. string.format("%.0f", DPMS/60) .. " min\nSleep\t" .. sleep)
    --                end

                end
                if suspend == "enabled" then
                    if bat_now.ac_status == 1 and xset then -- transition from battery to ac
                        DPMS=300
                        awful.spawn("xset s " .. DPMS)
                        awful.spawn("xautolock -disable")
                        sleep="disabled"
                        xset = false
                        if not awesome.startup then
                            naughty.notify({text = "Power connected"})
                        end
                        my_bat_tip:set_text("DPMS\t" .. string.format("%.0f", DPMS/60) .. " min\nSleep\t" .. sleep)
                    elseif bat_now.ac_status == 0 and not xset then --transition from ac to battery
                        DPMS=180
                        awful.spawn("xset s " .. DPMS)
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
my_bat:buttons(awful.util.table.join(
  awful.button({ }, 1, function() --click to disable suspend
    if suspend == "enabled" then
        awful.util.spawn("xset s off")
        awful.util.spawn("xautolock -disable")
        suspend = "manually"
        my_bat.root.bgd:set_bg("#7A4000")
        my_bat_tip:set_text("DPMS\t" .. suspend .. "\nSleep\t" .. suspend)
    else
        awful.util.spawn("xset s " .. DPMS)
        awful.util.spawn("xautolock -enable")
        suspend = "enabled"
        my_bat.root.bgd:set_bg(theme.bg_normal)
        my_bat_tip:set_text("DPMS\t" .. string.format("%.0f", DPMS/60) .. " min\nSleep\t" .. sleep)
    end
  end)
))

end


-- Systray widget
systray = wibox.container.margin()
systray:setup {
	id = "sstr",
	widget = wibox.widget.systray()
}
systray.sstr:set_horizontal(false)
if hostname == "arch" then
	systray.left = 11
	systray.right = 11
end
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
my_mem.top = 3

-- Server monitoring widget
awful.widget.watch('bash -c "cat $HOME/.bin/temp/server_status"', 300, function(widget, stdout)
    local avg_bg = theme.bg_normal
    local temp_bg = theme.bg_normal
    local hdd_bg = theme.bg_normal
    local upd_bg = theme.bg_normal
    local ram_bg = theme.bg_normal
    srv_mon.root.bgd:set_bg(theme.bg_normal)
    local lines = {}
    for line in stdout:gmatch("[^\r\n]+") do 
        lines[#lines + 1] = line
    end
    if tonumber(lines[5]) > 10 then
        upd_bg = "#2943FF"
        srv_mon.root.bgd:set_bg(upd_bg)
    end
    if tonumber(string.match(lines[3], "%d+")) > 65 then
        temp_bg = "#800000"
        srv_mon.root.bgd:set_bg(temp_bg)
    end
    if tonumber(string.match(lines[7], "%d+")) > 999 then
        ram_bg = "#A52A2A"
        srv_mon.root.bgd:set_bg(ram_bg)
    end
    local root, home, backup = string.match(lines[4], "^(%d+)%% (%d+)%% (%d+)%%")
    if tonumber(root) > 50 or tonumber(home) > 80 or tonumber(backup) > 60 then
        hdd_bg = "#739300"
        srv_mon.root.bgd:set_bg(hdd_bg)
    end
    local five_min_load = string.match(lines[2], "^%d+.%d+, (%d+).%d+")
    if tonumber(five_min_load) >= 1 then
        avg_bg = "#FF0000"
        srv_mon.root.bgd:set_bg(avg_bg)
    end
    srv_tip:set_markup("SERVER\n" .. lines[1].."<span background='" .. avg_bg .. "'>\nAverage load:\t\t" .. lines[2] .. "</span><span background='"..temp_bg .. "'>\nTemperature:\t\t" .. lines[3] .. "</span><span background='".. hdd_bg .. "'>\nRoot/Home/Backup usage:\t" .. lines[4] .. "</span><span background='" .. upd_bg .. "'>\nUpdates pending:\t".. lines[5] .. "</span>\nWashing:\t\t" .. lines[6]..":00".."<span background='" .. ram_bg.."'>\nRAM:\t\t\t"..lines[7].."</span>\nUpdated at:\t\t" ..lines[8])
end)
awful.widget.watch('bash -c "cat $HOME/.bin/temp/local_status"', 300, function(widget, stdout)
    local avg_bg = theme.bg_normal
    local temp_bg = theme.bg_normal
    local hdd_bg = theme.bg_normal
    local upd_bg = theme.bg_normal
    local ram_bg = theme.bg_normal
    srv_mon.root.bgd_loc:set_bg(theme.bg_normal)
    local lines = {}
    for line in stdout:gmatch("[^\r\n]+") do 
        lines[#lines + 1] = line
    end
    if tonumber(lines[3]) > 10 then
        upd_bg = "#2943FF"
        srv_mon.root.bgd_loc:set_bg(upd_bg)
    end
    if tonumber(string.match(lines[5], "%d+")) > 65 then
        temp_bg = "#800000"
        srv_mon.root.bgd_loc:set_bg(temp_bg)
    end
    local root, home = string.match(lines[4], "^(%d+)%% (%d+)%%")
    if tonumber(root) > 60 or tonumber(home) > 60 then
        hdd_bg = "#739300"
        srv_mon.root.bgd_loc:set_bg(hdd_bg)
    end
    local five_min_load = string.match(lines[2], "^%d+.%d+, (%d+).%d+")
    if tonumber(five_min_load) >= 1 then
        avg_bg = "#FF0000"
        srv_mon.root.bgd:set_bg(avg_bg)
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
        id = "bgd",
        widget = wibox.container.background
    },
    {
        {
            id = "text_loc",
            text = "⚔",
            align = "center",
            widget = wibox.widget.textbox
        },
        id = "bgd_loc",
        widget = wibox.container.background
    },
    id = "root",
    layout = wibox.layout.flex.horizontal
}
srv_mon.top = 3
srv_tip = awful.tooltip({ objects = { srv_mon.root.bgd }})
loc_tip = awful.tooltip({ objects = { srv_mon.root.bgd_loc}})
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
        id = "bgd",
        widget = wibox.container.background
    },
    id = "root",
    layout = wibox.layout.flex.horizontal
}
txtclock.top = 3
awful.widget.watch('bash -c "khal at today"', 300, function(widget, stdout)
    lines = {}
    for line in stdout:gmatch("[^\r\n]+") do 
        lines[#lines + 1] = line
    end

end)
cal = lain.widget.calendar({attach_to = {mytextclock}, cal = os.getenv("HOME") .. "/.config/awesome/bin/cal.sh", notification_preset = naughty.config.presets.normal, icons = "/"})

-- Create a wibox for each screen and add it
local taglist_buttons = awful.util.table.join(
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

local tasklist_buttons = awful.util.table.join(
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
                                          end))

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

clock = wibox ({bg = "#000000",
                width = 300,
                height = 200,
                })
clock.ontop = true
clock.visible = false
clock.opacity = "0.7"
clock:geometry({x = 20, y = 500})
clock_widget = wibox.widget.textbox()
value = 0
clock_widget:set_align("center")
clock_widget:set_markup("<span foreground='#db6823' font_family='Cantarell' size='65000'>" .. value .. "</span>")
local clock_layout = wibox.layout.fixed.horizontal()
clock:set_widget(clock_widget)
clock_timer = gears.timer ({ timeout = 1 })
clock_timer:connect_signal("timeout",
	function()
		clock.visible = true
	if clock_counter ~= -1 then
		m = math.floor(clock_counter / 60)
		s = math.fmod(clock_counter, 60)
		clock_widget:set_markup("<span foreground='#db6823' font_family='Cantarell' size='65000'>" .. string.format("%02.0f:%02d", m, s) .. "</span>")
		clock_counter = clock_counter - 1
	else
		clock.visible = false
		clock_timer:stop()
		naughty.notify({text = "Finished!"})
	end
		
	end	)
			
-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)

awful.screen.connect_for_each_screen(function(s)
    -- Wallpaper
    set_wallpaper(s)

    -- Each screen has its own tag table.
    mytag = awful.tag({"➊", "➋", "➌", "➍"}, s, awful.layout.layouts[2])
--   mytag.incnmaster(2)
    -- Create a promptbox for each screen
    s.mypromptbox = awful.widget.prompt()
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox = wibox.container.margin(awful.widget.layoutbox(s), 4, 4, 4, 4)
    s.mylayoutbox:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc( 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(-1) end),
                           awful.button({ }, 4, function () awful.layout.inc( 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(-1) end)))
    -- Create a taglist widget
    s.mytaglist = awful.widget.taglist(s, awful.widget.taglist.filter.all, taglist_buttons, nil, verticaltag, wibox.layout.fixed.vertical())

    -- Create a tasklist widget
    s.mytasklist = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, tasklist_buttons, nil, verticaltask, wibox.layout.fixed.vertical())


    -- Create the wibox
    s.mywibox = awful.wibar({ position = "left", screen = s, width = 44})

    -- Add widgets to the wibox
    local top_layout = wibox.layout.fixed.vertical()
    top_layout:add(s.mytaglist)
    local mid_layout =  wibox.layout.fixed.vertical()
    mid_layout:add(s.mytasklist)
    local bot_layout = wibox.layout.fixed.vertical()
    --bot_layout:add(wibox.widget.systray)
    bot_layout:add(systray)
    bot_layout:add(srv_mon)
    bot_layout:add(my_mem)
    bot_layout:add(mailwidget)
    if hostname ~= "arch" then
    bot_layout:add(my_bat)
    end
    bot_layout:add(my_volume)
    bot_layout:add(kbdwidget)
    bot_layout:add(s.mylayoutbox)
    bot_layout:add(txtclock)
    
    local layout = wibox.layout.align.vertical()
    layout:set_top(top_layout)
    layout:set_middle(mid_layout)
    layout:set_bottom(bot_layout)

    s.mywibox:set_widget(layout)

end)
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
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
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end,
              {description = "focus the previous screen", group = "screen"}),
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

    -- Prompt
--    awful.key({ modkey },            "r",     function () awful.screen.focused().mypromptbox:run() end,
--              {description = "run prompt", group = "launcher"}),
    awful.key({ modkey },            "r",     function () awful.spawn("rofi -show drun") end), 
    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run {
                    prompt       = "Run Lua code: ",
                    textbox      = awful.screen.focused().mypromptbox.widget,
                    exe_callback = awful.util.eval,
                    history_path = awful.util.get_cache_dir() .. "/history_eval"
                  }
              end,
              {description = "lua execute prompt", group = "awesome"}),
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
    awful.key({ }, "XF86MonBrightnessDown", function () b_notify()    end),
    awful.key({ }, "XF86MonBrightnessUp", function () b_notify() end),
    -- Custom keybindings
   awful.key({ }, "Pause", function () awful.spawn("systemctl suspend") end),
   awful.key({ modkey, "Shift" }, "n",     function () awful.spawn("env GTK_THEME=Greybird firefox -P Nusha")          end,
              {description = "launch Nusha's Firefox", group = "custom"}),
   awful.key({ modkey, "Shift" }, "f",     function () awful.spawn("env GTK_THEME=Greybird firefox -P Sprnza")          end,
              {description = "launch Firefox", group = "custom"}),
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
              {description = "Take a screenshot ot the active window", group = "custom"})
)

clientkeys = awful.util.table.join(
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
    globalkeys = awful.util.table.join(globalkeys,
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

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     raise = true,
                     keys = clientkeys,
                     buttons = clientbuttons,
                     screen = awful.screen.preferred,
                     placement = awful.placement.no_overlap+awful.placement.no_offscreen,
                     size_hints_honor = false,
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
         -- "mpv",
          "SpeedCrunch"},

        name = {
          "Event Tester",  -- xev.
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

    -- Set Firefox to always map on the tag named "2" on screen 1.
     { rule = { class = "Firefox" },
       properties = { screen = 1, tag = "➋" } },
     { rule_any = { class = { "libreoffice-calc", "libreoffice-writer"} },
       properties = { screen = 1, tag = "➌" } },
     { rule_any = { class = { "Geary", "TelegramDesktop" } },
       properties = { screen = 1, tag = "➍", callback =  function()
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
    if awful.screen.focused().selected_tag.index == 1 and #awful.tag.find_by_name(awful.screen.focused(), "➊"):clients() == 3 and awful.tag.find_by_name(awful.screen.focused(), "➊"):clients()[3].floating ~= true  then
        awful.tag.incnmaster(1, awful.tag.find_by_name(awful.screen.focused(), "➊"))
        master_increased = true
    end
end)
client.connect_signal("unmanage", function (c)
    if awful.screen.focused().selected_tag.index == 1 and #awful.tag.find_by_name(awful.screen.focused(), "➊"):clients() == 2 and master_increased then
        awful.tag.incnmaster(-1, awful.tag.find_by_name(awful.screen.focused(), "➊"))
        master_increased = false
    end
end)

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)

    -- buttons for the titlebar
    local buttons = awful.util.table.join(
            awful.button({ }, 1, function()
                client.focus = c
                c:raise()
                awful.mouse.client.move(c)
            end)
            )

    -- Minimize, Maximize, Close buttons
    local right_layout = wibox.layout.flex.horizontal()
    right_layout:add(awful.titlebar.widget.minimizebutton(c))
    right_layout:add(awful.titlebar.widget.maximizedbutton(c))
    right_layout:add(awful.titlebar.widget.closebutton(c))
    right_layout.forced_width=150

    -- Dragable titlebar
    local middle_layout = wibox.layout.flex.horizontal()
    middle_layout:buttons(buttons)

    -- Now bring it all together
    local layout = wibox.layout.align.horizontal()
    layout:set_right(right_layout)
    layout:set_middle(middle_layout)

    awful.titlebar(c,{size=7}):set_widget(layout) 
    awful.titlebar.show(c)
end)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
    if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
        and awful.client.focus.filter(c) then
        client.focus = c
    end
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}

-- {{{ Arrange signal handler
for s = 1, screen.count() do screen[s]:connect_signal("arrange", function ()
        local clients = screen[s].clients
        local layout  = awful.layout.getname(awful.layout.get(s))

        if #clients > 0 then -- Fine grained borders and floaters control
            for _, c in pairs(clients) do -- Floaters always have borders
				if (c.maximized_horizontal == true and c.maximized_vertical == true) then
					c.border_width = 0
                else
					c.border_width = beautiful.border_width
                end
                if layout == "tile" then
					awful.titlebar.hide(c)
				else
					awful.titlebar.show(c)
				end
            end
        end
      end)
end
-- }}}
