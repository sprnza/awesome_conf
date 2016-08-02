-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
awful.rules = require("awful.rules")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")

-- Custom requirements
local cal = require("cal")
local blingbling = require("blingbling")

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
                         text = err })
        in_error = false
    end)
end
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, font and wallpapers.
beautiful.init(os.getenv("HOME") .. "/.config/awesome/themes/theme.lua")

-- This is used later as the default terminal and editor to run.
terminal = "xfce4-terminal"
editor = os.getenv("EDITOR") or "vim"
editor_cmd = terminal .. " -e \"" .. editor

-- Autostart
function run_once(cmd)
    findme = cmd
    firstspace = cmd:find(" ")
    if firstspace then
        findme = cmd:sub(0, firstspace-1)
    end
    awful.util.spawn_with_shell("pgrep -u $USER -x " .. findme .. " > /dev/null || (" .. cmd .. ")")
end

--awful.util.spawn_with_shell("xcompmgr &")
--awful.util.spawn_with_shell("wmctrl -x -a conky || conky")

run_once("setxkbmap -layout 'us,ru' -variant ',winkeys,winkeys' -option grp:caps_toggle -option grp_led:caps")
run_once("kbdd")
run_once("conky")
run_once(os.getenv("HOME") .. "/.bin/disable_touch.sh")
run_once("syndaemon -d -i 1")
--run_once("xfce4-power-manager")
run_once("xautolock -time 5 -locker 'systemctl suspend' -detectsleep &")
run_once("xcompmgr &")
run_once("xset s 180 180")
-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
local layouts =
{
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
--    awful.layout.suit.magnifier
}
-- }}}

-- {{{ Wallpaper
if beautiful.wallpaper then
    for s = 1, screen.count() do
        gears.wallpaper.maximized(beautiful.wallpaper, s, true)
    end
end
-- }}}

-- {{{ Tags
-- Define a tag table which hold all screen tags.
tags = {
names = {"⠐", "⠡", "⠪", "⠵", "⠻", "⠿",},
layout = {layouts[2],layouts[2],layouts[2],layouts[2],layouts[2],layouts[2]},
}

for s = 1, screen.count() do
    -- Each screen has its own tag table.
    tags[s] = awful.tag(tags.names, s, tags.layout)
end
-- }}}

-- {{{ Menu
-- Create a laucher widget and a main menu
myawesomemenu = {
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awesome.conffile .. '"' },
   { "restart", awesome.restart },
}
internetMenu = {
    { "Firefox", "firefox" },
    { "Luakit", "luakit" },
    { "Telegram", "telegram-desktop" },
    { "Geary", "geary"}
}
powerMenu = {
    { "Logout", awesome.quit },
    { "Suspend", "systemctl suspend" },
    { "Hibernate", "systemctl hibernate" },
    { "Reboot", "systemctl reboot" },
    { "Shutdown", "systemctl poweroff" }
}
officeMenu = {
    { "Writer", "libreoffice --writer" },
    { "Calc", "libreoffice --calc" },
    { "Calculator", "speedcrunch" },
    { "Mousepad", "mousepad" }
}
mymainmenu = awful.menu({ items = { 
                                    { "Firefox", "firefox" },
                                    { "Files", "thunar" },
                                    { "Internet", internetMenu },
                                    { "Office", officeMenu },
                                    { "awesome", myawesomemenu },
                                    { "Power", powerMenu }
                                  }
                        })

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = mymainmenu })

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
app_folders = { "/usr/share/applications/", "~/.local/share/applications/" }
-- }}}

-- {{{ Wibox
sep = wibox.widget.textbox()
sep:set_text(" | ")
-- Create a textclock widget
mytextclock = awful.widget.textclock("%H:%M ")
cal.register(mytextclock,"<span color='#16a085'>%s</span>")
cal.bg_focus = theme.bg_normal
-- Create a battery monitor widget
batterywidget = wibox.widget.textbox()    
batterywidget:set_text(" | Battery | ")    
battery_tip = awful.tooltip({ objects = { batterywidget }})
batterywidgettimer = timer({ timeout = 60 })    
batterywidgettimer:connect_signal("timeout",    
  function()    
    fh = assert(io.popen("acpi | cut -d, -f 2"))    
    batterywidget:set_text(" | ⛃" .. fh:read("*l") .. " | ")    
    fh:close()    
  end    
)    
battery_tip:set_text("\nDPMS\t" .. "5 min\nSleep\t" .."5 min")
batterywidgettimer:start()
---- ALSA volume widget
volume_label = wibox.widget.textbox()
volume_label:set_text("♫")
my_volume=blingbling.volume.new()
my_volume:set_height(10)
my_volume:set_v_margin(6)
my_volume:set_width(25)
my_volume:set_graph_color(theme.bg_focus)
--bind the volume widget on the master channel
my_volume:update_master()
my_volume:set_master_control()
my_volume:set_bar(true)

----{{ Mail & Telegram widget
local mailwidget_label = wibox.widget.textbox()
local mailwidget = wibox.widget.background()
mailwidget_label:set_text("@")
mailwidget:set_widget(mailwidget_label)
mailwidget_tip = awful.tooltip({ objects = { mailwidget }})
mailwidgettimer = timer({ timeout = 60 })
mailwidgettimer:connect_signal("timeout",
    function()
       local f_sp_mail = assert(io.popen("cat $HOME/.bin/temp/mail_counter|grep denis@speran.info|awk '{print $2}'"))
       local f_pfk_mail = assert(io.popen("cat $HOME/.bin/temp/mail_counter|grep denis@pfk-rus.ru|awk '{print $2}'"))
       local f_telegram = assert(io.popen("for i in `echo dialog_list|telegram-cli|grep unread|awk '{print $(NF-1)}'`; do res=$((res + i));done; [[ -z $res ]] && echo 0 || echo $res"))
       local sp_mail = tonumber(f_sp_mail:read())
       local pfk_mail = tonumber(f_pfk_mail:read())
       local telegram = tonumber(f_telegram:read())
       if ( sp_mail > 0 or pfk_mail > 0) then
        mailwidget:set_bg("#FF0000")
        mailwidget_label:set_text(" " .. sp_mail+pfk_mail .. " ")
       else
        mailwidget:set_bg(theme.bg_normal)
        mailwidget_label:set_text("@")
       end
       if ( telegram > 0 ) then
        mailwidget:set_bg("009DFF")
        mailwidget_label:set_text(" T ")
       end
       mailwidget_tip:set_text("\nMAIL\ndenis@speran.info\t" .. sp_mail .. "\n" .. "denis@pfk-rus.ru\t" .. pfk_mail .. "\nTELEGRAM\nDenis\t\t\t" .. telegram)
    end
)
mailwidgettimer:start()

function volume(action)
  local mixer 
  local alsa_channel = "Master"
  if action == "+" or action == "-" then
    mixer = awful.util.pread("amixer sset " .. alsa_channel .. " 5%" .. action) --change the step to you taste
  elseif action == "toggle" then
    mixer = awful.util.pread("amixer sset " .. alsa_channel .. " " .. action)
  else
    mixer = awful.util.pread("amixer get " .. alsa_channel)
  end
end
--[[
  local volu, mute = string.match(mixer, "([%d]+)%%.*%[([%l]*)")
  if volu == nil or (mute == "" and volu == "0") or mute == "off" then
    alsawidget:set_image(i_dir .. "audio-volume-muted.png")
    alsawidget_tip:set_text("[Muted]")
  else
    if tonumber(volu) >= 66 then
      alsawidget:set_image(i_dir .. "audio-volume-high.svg")
    elseif tonumber(volu) >= 33 then
      alsawidget:set_image(i_dir .. "audio-volume-medium.svg")
    else
      alsawidget:set_image(i_dir .. "audio-volume-low.svg")
    end
    alsawidget_tip:set_text(alsa_channel .. ": " .. volu .. "%")
  end
end
volume("set") -- set the icon and tooltip at startup or restart
-- mouse bindings
alsawidget:buttons(awful.util.table.join(
  awful.button({ }, 1, function() --click to (un)mute
    volume("toggle")
  end),
  awful.button({ }, 4, function() --wheel to rise or reduce volume
    volume("+")
  end),
  awful.button({ }, 5, function()
    volume("-")
  end)
))
--]]
-- Keyboard widget
kbdwidget = wibox.widget.textbox()
kbdwidget:set_text("Eng")
kbdwidget.border_color = beautiful.fg_normal

kbdstrings = {[0] = " Eng ", 
              [1] = " Рус "}

dbus.request_name("session", "ru.gentoo.kbdd")
dbus.add_match("session", "interface='ru.gentoo.kbdd',member='layoutChanged'")
dbus.connect_signal("ru.gentoo.kbdd", function(...)
    local data = {...}
    local layout = data[2]
    kbdwidget:set_markup(kbdstrings[layout])
    end
)



-- Create a wibox for each screen and add it
mywibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end)
                    )
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  -- Without this, the following
                                                  -- :isvisible() makes no sense
                                                  c.minimized = false
                                                  if not c:isvisible() then
                                                      awful.tag.viewonly(c:tags()[1])
                                                  end
                                                  -- This will also un-minimize
                                                  -- the client, if needed
                                                  client.focus = c
                                                  c:raise()
                                              end
                                          end),
                     awful.button({ }, 3, function ()
                                              if instance then
                                                  instance:hide()
                                                  instance = nil
                                              else
                                                  instance = awful.menu.clients({
                                                      theme = { width = 250 }
                                                  })
                                              end
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                              if client.focus then client.focus:raise() end
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                              if client.focus then client.focus:raise() end
                                          end))

for s = 1, screen.count() do
    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt()
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons)

    -- Create the wibox
    mywibox[s] = awful.wibox({ position = "top", screen = s, height = 24 })
--    mystatusbar = awful.wibox({ position = "bottom", screen = 1, ontop = true, height = 16 })

    -- Widgets that are aligned to the left
    local left_layout = wibox.layout.fixed.horizontal()
    left_layout:add(mylauncher)
    left_layout:add(mytaglist[s])
    left_layout:add(mypromptbox[s])

    -- Widgets that are aligned to the right
    local right_layout = wibox.layout.fixed.horizontal()
    if s == 1 then right_layout:add(wibox.widget.systray()) end
    right_layout:add(sep)
    right_layout:add(mailwidget)
    right_layout:add(sep)
    right_layout:add(kbdwidget)
    right_layout:add(sep)
    right_layout:add(volume_label)
    right_layout:add(my_volume)
--    right_layout:add(alsawidget)
    right_layout:add(batterywidget)
    right_layout:add(mytextclock)
--    right_layout:add(mylayoutbox[s])

    -- Now bring it all together (with the tasklist in the middle)
    local layout = wibox.layout.align.horizontal()
    layout:set_left(left_layout)
    layout:set_middle(mytasklist[s])
    layout:set_right(right_layout)

    mywibox[s]:set_widget(layout)
end
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
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev       ),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext       ),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore),

    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "w", function () mymainmenu:show() end),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end),
    awful.key({ modkey, "Control" }, "r", awesome.restart),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),

    awful.key({ modkey, "Control" }, "n", awful.client.restore),

    -- Prompt
    awful.key({ modkey },            "r",     function () mypromptbox[mouse.screen]:run() end),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run({ prompt = "Run Lua code: " },
                  mypromptbox[mouse.screen].widget,
                  awful.util.eval, nil,
                  awful.util.getdir("cache") .. "/history_eval")
              end),
    -- Menubar
    awful.key({ modkey }, "p", function() menubar.show() end),
    -- ALSA volume
    awful.key({ }, "XF86AudioRaiseVolume", function() volume("+") end),
    awful.key({ }, "XF86AudioLowerVolume", function() volume("-") end),
    awful.key({ }, "XF86AudioMute",        function() volume("toggle") end),
    -- Custom keybindings
    awful.key({ modkey,         }, "d", function() awful.util.spawn("luakit drebedengi.ru")end),
    awful.key({ }, "Print", function () awful.util.spawn("xfce4-screenshooter") end)
    )

clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end)
)
-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    globalkeys = awful.util.table.join(globalkeys,
        -- View tag only.
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = mouse.screen
                        local tag = awful.tag.gettags(screen)[i]
                        if tag then
                           awful.tag.viewonly(tag)
                        end
                  end),
        -- Toggle tag.
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = mouse.screen
                      local tag = awful.tag.gettags(screen)[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end),
        -- Move client to tag.
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = awful.tag.gettags(client.focus.screen)[i]
                          if tag then
                              awful.client.movetotag(tag)
                          end
                     end
                  end),
        -- Toggle tag.
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = awful.tag.gettags(client.focus.screen)[i]
                          if tag then
                              awful.client.toggletag(tag)
                          end
                      end
                  end))
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
                     size_hints_honor = false } },
    { rule = { class = "MPlayer" },
      properties = { floating = true } },
    { rule = { class = "pinentry" },
      properties = { floating = true } },
    { rule = { class = "Keepassx" },
      properties = { floating = true } },
    { rule = { class = "Speedcrunch" },
      properties = { floating = true } },
    -- Set Firefox to always map on tags number 2 of screen 1.
     { rule = { class = "Firefox" },
       properties = { tag = tags[1][1] } },
     { rule = { class = "luakit" },
       properties = { tag = tags[1][1] } },
     { rule = { class = "Gmpc" },
       properties = { tag = tags[1][5] } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c, startup)
    -- Enable sloppy focus
    c:connect_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)

    if not startup then
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        -- awful.client.setslave(c)

        -- Put windows in a smart way, only if they does not set an initial position.
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end

    local titlebars_enabled = false
    if titlebars_enabled and (c.type == "normal" or c.type == "dialog") then
        -- buttons for the titlebar
        local buttons = awful.util.table.join(
                awful.button({ }, 1, function()
                    client.focus = c
                    c:raise()
                    awful.mouse.client.move(c)
                end),
                awful.button({ }, 3, function()
                    client.focus = c
                    c:raise()
                    awful.mouse.client.resize(c)
                end)
                )

        -- Widgets that are aligned to the left
        local left_layout = wibox.layout.fixed.horizontal()
        left_layout:add(awful.titlebar.widget.iconwidget(c))
        left_layout:buttons(buttons)

        -- Widgets that are aligned to the right
        local right_layout = wibox.layout.fixed.horizontal()
        right_layout:add(awful.titlebar.widget.floatingbutton(c))
        right_layout:add(awful.titlebar.widget.maximizedbutton(c))
        right_layout:add(awful.titlebar.widget.stickybutton(c))
        right_layout:add(awful.titlebar.widget.ontopbutton(c))
        right_layout:add(awful.titlebar.widget.closebutton(c))

        -- The title goes in the middle
        local middle_layout = wibox.layout.flex.horizontal()
        local title = awful.titlebar.widget.titlewidget(c)
        title:set_align("center")
        middle_layout:add(title)
        middle_layout:buttons(buttons)

        -- Now bring it all together
        local layout = wibox.layout.align.horizontal()
        layout:set_left(left_layout)
        layout:set_right(right_layout)
        layout:set_middle(middle_layout)

        awful.titlebar(c):set_widget(layout)
    end
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)

--alsawidget:connect_signal("mouse::enter", function() volume("update") end)
-- }}}
-- {{ CUSTOM daemons
local xsetState = "bat"
local xautolockState = "enabled"
-- Battery warning

local function trim(s)
  return s:find'^%s*$' and '' or s:match'^%s*(.*%S)'
end

local function bat_notification()
  
  local f_capacity = assert(io.open("/sys/class/power_supply/BAT0/capacity", "r"))
  local f_status = assert(io.open("/sys/class/power_supply/BAT0/status", "r"))

  local bat_capacity = tonumber(f_capacity:read("*all"))
  local bat_status = trim(f_status:read("*all"))

  if (bat_capacity <= 10 and bat_status == "Discharging") then
    naughty.notify({ title      = "Battery Warning"
      , text       = "Battery low! " .. bat_capacity .."%" .. " left!"
      , fg="#ff0000"
      , bg="#deb887"
      , timeout    = 15
      , position   = "top_right"
    })
  end
  if bat_status == "Charging" and xsetState == "bat" then
    awful.util.spawn("xset s 300 300")
    xsetState = "ac"
    battery_tip:set_text("\nDPMS\t" .. "5 min\nSleep\t" .."5 min")
    if xautolockState == "enabled" then
        awful.util.spawn("xautolock -disable")
        battery_tip:set_text("\nDPMS\t" .. "5 min\nSleep\t" .."Disabled")
    end
  elseif bat_status == "Discharging" and xsetState == "ac" then
    awful.util.spawn("xset s 180 180")
    battery_tip:set_text("\nDPMS\t" .. "3 min\nSleep\t" .."Disabled")
    if xautolockState == "disabled" then
        awful.util.spawn("xautolock -enable")
        battery_tip:set_text("\nDPMS\t" .. "3 min\nSleep\t" .."5 min")
    end
    xsetState = "bat"
  end
end

battimer = timer({timeout = 120})
battimer:connect_signal("timeout", bat_notification)
battimer:start()

-- end here for battery warning

-- suspend on idle
local function pauseSuspend()
    local apps = {"Vlc", "Deadbeef"}
    local clients = client.get()
    local i = 0
    for _, appsValue in pairs(apps) do
        for _, clientsValue in pairs(clients) do
                if clientsValue.class == appsValue then
                    i = i + 1
                end
        end
    end
    if i > 0 and xautolockState == "enabled" then
        naughty.notify({text = "Disabling PM"})
        awful.util.spawn("xautolock -disable")
        awful.util.spawn("xset s -dpms")
        battery_tip:set_text("\nDPMS\t" .. "Disabled\nSleep\t" .."Disabled")
        xautolockState = "disabled"
    elseif i == 0 and xautolockState == "disabled" then
        naughty.notify({text = "Enabling PM"})
        awful.util.spawn("xautolock -enable")
        if xsetStatus == "ac" then
            awful.util.spawn("xset s 300 300")
            battery_tip:set_text("\nDPMS\t" .. "5 min\nSleep\t" .."5 min")
        else
            awful.util.spawn("xset s 180 180")
            battery_tip:set_text("\nDPMS\t" .. "3 min\nSleep\t" .."5 min")
        end
        xautolockState = "enabled"
     end

end
suspendtimer = timer({timeout = 120 })
suspendtimer:connect_signal("timeout", pauseSuspend)
suspendtimer:start()
-- end for suspend on idle
