pcall(require, "luarocks.loader")

local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
local wibox = require("wibox")
local beautiful = require("beautiful")
local naughty = require("naughty")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")
require("awful.hotkeys_popup.keys")

if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        if in_error then return end
        in_error = true
        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = tostring(err) })
        in_error = false
    end)
end

beautiful.init(gears.filesystem.get_themes_dir() .. "default/theme.lua")

-- Modern dark theme overrides
beautiful.font                  = "UbuntuMono Nerd Font 14"
beautiful.wibar_height          = 44
beautiful.wibar_bg              = "#1f2229"
beautiful.wibar_fg              = "#d3dae3"
beautiful.bg_normal             = "#1f2229"
beautiful.bg_focus              = "#2f3440"
beautiful.bg_systray            = "#1f2229"
beautiful.fg_normal             = "#d3dae3"
beautiful.fg_focus              = "#ffffff"
beautiful.border_width          = 2
beautiful.border_normal         = "#2f3440"
beautiful.border_focus          = "#5294e2"
beautiful.taglist_squares_sel   = nil
beautiful.taglist_squares_unsel = nil
beautiful.taglist_bg_focus      = "#5294e2"
beautiful.taglist_fg_focus      = "#ffffff"
beautiful.taglist_bg_occupied   = "#2f3440"
beautiful.taglist_fg_occupied   = "#d3dae3"
beautiful.taglist_bg_empty      = "#252b36"
beautiful.taglist_fg_empty      = "#6b7685"
beautiful.tasklist_bg_focus     = "#2f3440"
beautiful.tasklist_fg_focus     = "#ffffff"

terminal = "kitty"
editor = os.getenv("EDITOR") or "nano"
editor_cmd = terminal .. " -e " .. editor

modkey = "Mod4"

awful.layout.layouts = {
    awful.layout.suit.floating,
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    awful.layout.suit.spiral,
    awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max,
    awful.layout.suit.max.fullscreen,
    awful.layout.suit.magnifier,
    awful.layout.suit.corner.nw,
}

myawesomemenu = {
   { "hotkeys", function() hotkeys_popup.show_help(nil, awful.screen.focused()) end },
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awesome.conffile },
   { "restart", awesome.restart },
   { "quit", function() awesome.quit() end },
}

mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
                                    { "open terminal", terminal }
                                  }
                        })

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = mymainmenu })

menubar.utils.terminal = terminal

mykeyboardlayout = awful.widget.keyboardlayout()

mytextclock = wibox.widget.textclock("%a %b %d  %I:%M %p")

local mybattery = awful.widget.watch(
    {"bash", "-c", "cat /sys/class/power_supply/BAT*/capacity /sys/class/power_supply/BAT*/status 2>/dev/null"},
    30,
    function(widget, stdout)
        local lines = {}
        for line in stdout:gmatch("[^\n]+") do table.insert(lines, line) end
        if #lines >= 2 then
            local pct, status = lines[1], lines[2]
            local prefix = status == "Charging" and "+" or ""
            widget:set_text("BAT " .. prefix .. pct .. "%")
        else
            widget:set_text("BAT N/A")
        end
    end
)

local function pill(w, bg_color)
    return wibox.widget {
        { w, left = 12, right = 12, top = 4, bottom = 4, widget = wibox.container.margin },
        bg     = bg_color or "#2a3045",
        shape  = function(cr, width, height) gears.shape.rounded_rect(cr, width, height, 10) end,
        widget = wibox.container.background,
    }
end

local mycpu = awful.widget.watch(
    {"bash", "-c", "awk '/^cpu / {u=$2+$4; t=$2+$3+$4+$5; printf \"%d\", u*100/t}' /proc/stat"},
    2,
    function(widget, stdout)
        widget:set_text("CPU " .. (stdout:match("%d+") or "?") .. "%")
    end
)

local myram = awful.widget.watch(
    {"bash", "-c", "awk '/MemTotal/ {t=$2} /MemAvailable/ {a=$2} END {printf \"%d\", (t-a)*100/t}' /proc/meminfo"},
    5,
    function(widget, stdout)
        widget:set_text("RAM " .. (stdout:match("%d+") or "?") .. "%")
    end
)

local mydisk = awful.widget.watch(
    {"bash", "-c", "df / | awk 'NR==2{print $5}' | tr -d '%'"},
    30,
    function(widget, stdout)
        widget:set_text("DSK " .. stdout:gsub("%s+", "") .. "%")
    end
)

local mytemp = awful.widget.watch(
    {"bash", "-c", "awk '{printf \"%d\", $1/1000}' /sys/class/thermal/thermal_zone0/temp 2>/dev/null || echo '?'"},
    10,
    function(widget, stdout)
        widget:set_text("TMP " .. stdout:gsub("%s+", "") .. "°C")
    end
)

local mynet = awful.widget.watch(
    {"bash", "-c", "nmcli -t -f active,ssid dev wifi 2>/dev/null | grep '^yes:' | cut -d: -f2-"},
    10,
    function(widget, stdout)
        local ssid = stdout:gsub("%s+", "")
        if ssid == "" then
            widget:set_text("No WiFi")
        else
            widget:set_text("WiFi " .. ssid)
        end
    end
)

local mybluetooth = awful.widget.watch(
    {"bash", "-c", "if bluetoothctl show 2>/dev/null | grep -q 'Powered: yes'; then devs=$(bluetoothctl devices Connected 2>/dev/null | cut -d' ' -f3- | paste -sd, -); if [ -z \"$devs\" ]; then echo on; else echo \"$devs\"; fi; else echo off; fi"},
    15,
    function(widget, stdout)
        local text = stdout:gsub("%s+$", "")
        if text == "" or text == "off" then
            widget:set_text("BT off")
        elseif text == "on" then
            widget:set_text("BT on")
        else
            widget:set_text("BT " .. text)
        end
    end
)

local myvolume = awful.widget.watch(
    {"bash", "-c", "export XDG_RUNTIME_DIR=/run/user/$(id -u); wpctl get-volume @DEFAULT_AUDIO_SINK@"},
    2,
    function(widget, stdout)
        local vol = stdout:match("(%d+%.%d+)")
        if not vol then
            widget:set_text("VOL ?%")
        elseif stdout:find("MUTED") then
            widget:set_text("VOL muted")
        else
            widget:set_text("VOL " .. math.floor(tonumber(vol) * 100 + 0.5) .. "%")
        end
    end
)

-- The surfacepro's hardware volume rocker should unmute on press (phone-style);
-- other hosts keep plain volume-key behavior.
local is_surfacepro = false
do
    local f = io.open("/proc/sys/kernel/hostname")
    if f then
        is_surfacepro = f:read("*l") == "surfacepro"
        f:close()
    end
end

-- Volume OSD: popup bar shown when the volume keys/buttons are pressed
local volume_osd_bar = wibox.widget {
    max_value        = 100,
    value            = 0,
    forced_height    = 10,
    forced_width     = 220,
    color            = "#5294e2",
    background_color = "#2f3440",
    shape            = gears.shape.rounded_bar,
    bar_shape        = gears.shape.rounded_bar,
    widget           = wibox.widget.progressbar,
}

local volume_osd_text = wibox.widget {
    align  = "center",
    widget = wibox.widget.textbox,
}

local volume_osd = awful.popup {
    widget = {
        {
            volume_osd_text,
            volume_osd_bar,
            spacing = 8,
            layout  = wibox.layout.fixed.vertical,
        },
        margins = 16,
        widget  = wibox.container.margin,
    },
    bg           = "#1f2229",
    border_color = "#2f3440",
    border_width = 1,
    shape        = function(cr, w, h) gears.shape.rounded_rect(cr, w, h, 12) end,
    ontop        = true,
    visible      = false,
    placement    = function(d)
        awful.placement.bottom(d, { margins = { bottom = 80 } })
    end,
}

local volume_osd_timer = gears.timer {
    timeout     = 1.5,
    single_shot = true,
    callback    = function() volume_osd.visible = false end,
}

local function show_volume_osd()
    awful.spawn.easy_async(
        {"bash", "-c", "export XDG_RUNTIME_DIR=/run/user/$(id -u); wpctl get-volume @DEFAULT_AUDIO_SINK@"},
        function(stdout)
            local vol   = stdout:match("(%d+%.%d+)")
            local pct   = vol and math.floor(tonumber(vol) * 100 + 0.5) or 0
            local muted = stdout:find("MUTED")
            volume_osd_bar.value = pct
            volume_osd_bar.color = muted and "#6b7685" or "#5294e2"
            volume_osd_text.text = muted and "Muted" or ("Volume " .. pct .. "%")
            volume_osd.visible = true
            volume_osd_timer:stop()
            volume_osd_timer:start()
        end
    )
end

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
                                                  c:emit_signal(
                                                      "request::activate",
                                                      "tasklist",
                                                      {raise = true}
                                                  )
                                              end
                                          end),
                     awful.button({ }, 3, function()
                                              awful.menu.client_list({ theme = { width = 250 } })
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                          end))

-- Set wallpaper via feh after awesome initializes (runs after gears.wallpaper would, so it wins)
awful.spawn.with_shell("@feh@/bin/feh --bg-scale @wallpaper@")
screen.connect_signal("property::geometry", function()
    awful.spawn.with_shell("@feh@/bin/feh --bg-scale @wallpaper@")
end)

awful.screen.connect_for_each_screen(function(s)
    awful.tag({ "1", "2", "3", "4", "5", "6", "7", "8", "9" }, s, awful.layout.layouts[1])

    s.mypromptbox = awful.widget.prompt()
    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(gears.table.join(
                           awful.button({ }, 1, function () awful.layout.inc( 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(-1) end),
                           awful.button({ }, 4, function () awful.layout.inc( 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(-1) end)))
    s.mytaglist = awful.widget.taglist {
        screen  = s,
        filter  = awful.widget.taglist.filter.all,
        buttons = taglist_buttons,
        layout  = { spacing = 4, layout = wibox.layout.fixed.horizontal },
        widget_template = {
            {
                {
                    id     = "text_role",
                    align  = "center",
                    widget = wibox.widget.textbox,
                },
                left = 10, right = 10, top = 4, bottom = 4,
                widget = wibox.container.margin,
            },
            id     = "background_role",
            shape  = function(cr, w, h) gears.shape.rounded_rect(cr, w, h, 8) end,
            widget = wibox.container.background,
        },
    }

    s.mytasklist = awful.widget.tasklist {
        screen  = s,
        filter  = awful.widget.tasklist.filter.currenttags,
        buttons = tasklist_buttons
    }

    s.mywibox = awful.wibar({ position = "top", screen = s, height = beautiful.wibar_height })

    s.mywibox:setup {
        layout = wibox.layout.align.horizontal,
        { -- Left: taglist + prompt
            layout  = wibox.layout.fixed.horizontal,
            spacing = 4,
            wibox.container.margin(s.mytaglist, 8, 4, 0, 0),
            s.mypromptbox,
        },
        wibox.container.margin(s.mytasklist, 8, 8),
        { -- Right: system pills
            layout  = wibox.layout.fixed.horizontal,
            spacing = 6,
            wibox.container.margin(wibox.widget.systray(), 4, 4, 8, 8),
            pill(mytemp,      "#3a1515"),
            pill(mycpu,       "#3d2800"),
            pill(myram,       "#1a3a20"),
            pill(mydisk,      "#2e2800"),
            pill(mynet,       "#0f2e2e"),
            pill(mybluetooth, "#102a43"),
            pill(myvolume,    "#2a1a40"),
            pill(mybattery,   "#1a2e4a"),
            pill(mytextclock, "#1e2a50"),
            wibox.container.margin(s.mylayoutbox, 4, 10, 8, 8),
        },
    }
end)

root.buttons(gears.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))

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
                  if c then
                    c:emit_signal(
                        "request::activate", "key.unminimize", {raise = true}
                    )
                  end
              end,
              {description = "restore minimized", group = "client"}),

    awful.key({ modkey },            "r",     function () awful.screen.focused().mypromptbox:run() end,
              {description = "run prompt", group = "launcher"}),

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
    awful.key({ modkey }, "p", function() awful.spawn("rofi -show drun") end,
              {description = "show rofi launcher", group = "launcher"}),

    awful.key({ }, "XF86MonBrightnessUp",
              function () awful.spawn("brightnessctl set +10%") end,
              {description = "increase brightness", group = "system"}),
    awful.key({ }, "XF86MonBrightnessDown",
              function () awful.spawn("brightnessctl set 10%-") end,
              {description = "decrease brightness", group = "system"}),
    awful.key({ }, "XF86AudioRaiseVolume",
              function ()
                  local unmute = is_surfacepro and "wpctl set-mute @DEFAULT_AUDIO_SINK@ 0; " or ""
                  awful.spawn.easy_async(
                      {"bash", "-c", "export XDG_RUNTIME_DIR=/run/user/$(id -u); " .. unmute .. "wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+"},
                      show_volume_osd)
              end,
              {description = "raise volume", group = "media"}),
    awful.key({ }, "XF86AudioLowerVolume",
              function ()
                  local unmute = is_surfacepro and "wpctl set-mute @DEFAULT_AUDIO_SINK@ 0; " or ""
                  awful.spawn.easy_async(
                      {"bash", "-c", "export XDG_RUNTIME_DIR=/run/user/$(id -u); " .. unmute .. "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"},
                      show_volume_osd)
              end,
              {description = "lower volume", group = "media"}),
    awful.key({ }, "XF86AudioMute",
              function ()
                  awful.spawn.easy_async(
                      {"bash", "-c", "export XDG_RUNTIME_DIR=/run/user/$(id -u); wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"},
                      show_volume_osd)
              end,
              {description = "toggle mute", group = "media"})
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
            c.minimized = true
        end ,
        {description = "minimize", group = "client"}),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized = not c.maximized
            c:raise()
        end ,
        {description = "(un)maximize", group = "client"}),
    awful.key({ modkey, "Control" }, "m",
        function (c)
            c.maximized_vertical = not c.maximized_vertical
            c:raise()
        end ,
        {description = "(un)maximize vertically", group = "client"}),
    awful.key({ modkey, "Shift"   }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c:raise()
        end ,
        {description = "(un)maximize horizontally", group = "client"})
)

for i = 1, 9 do
    globalkeys = gears.table.join(globalkeys,
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = awful.screen.focused()
                        local tag = screen.tags[i]
                        if tag then
                           tag:view_only()
                        end
                  end,
                  {description = "view tag #"..i, group = "tag"}),
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = awful.screen.focused()
                      local tag = screen.tags[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end,
                  {description = "toggle tag #" .. i, group = "tag"}),
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
    awful.button({ }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
    end),
    awful.button({ modkey }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.move(c)
    end),
    awful.button({ modkey }, 3, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.resize(c)
    end)
)

root.keys(globalkeys)

awful.rules.rules = {
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     raise = true,
                     keys = clientkeys,
                     buttons = clientbuttons,
                     screen = awful.screen.preferred,
                     placement = awful.placement.no_overlap+awful.placement.no_offscreen
     }
    },

    { rule_any = {
        instance = {
          "DTA",
          "copyq",
          "pinentry",
        },
        class = {
          "Arandr",
          "Blueman-manager",
          "Gpick",
          "Kruler",
          "MessageWin",
          "Sxiv",
          "Tor Browser",
          "Wpa_gui",
          "veromix",
          "xtightvncviewer"},

        name = {
          "Event Tester",
        },
        role = {
          "AlarmWindow",
          "ConfigManager",
          "pop-up",
        }
      }, properties = { floating = true }},

    { rule_any = {type = { "normal", "dialog" }
      }, properties = { titlebars_enabled = true }
    },
}

client.connect_signal("manage", function (c)
    if awesome.startup
      and not c.size_hints.user_position
      and not c.size_hints.program_position then
        awful.placement.no_offscreen(c)
    end
end)

client.connect_signal("request::titlebars", function(c)
    local buttons = gears.table.join(
        awful.button({ }, 1, function()
            c:emit_signal("request::activate", "titlebar", {raise = true})
            awful.mouse.client.move(c)
        end),
        awful.button({ }, 3, function()
            c:emit_signal("request::activate", "titlebar", {raise = true})
            awful.mouse.client.resize(c)
        end)
    )

    awful.titlebar(c) : setup {
        { -- Left
            awful.titlebar.widget.iconwidget(c),
            buttons = buttons,
            layout  = wibox.layout.fixed.horizontal
        },
        { -- Middle
            { -- Title
                align  = "center",
                widget = awful.titlebar.widget.titlewidget(c)
            },
            buttons = buttons,
            layout  = wibox.layout.flex.horizontal
        },
        { -- Right
            awful.titlebar.widget.floatingbutton (c),
            awful.titlebar.widget.maximizedbutton(c),
            awful.titlebar.widget.stickybutton   (c),
            awful.titlebar.widget.ontopbutton    (c),
            awful.titlebar.widget.closebutton    (c),
            layout = wibox.layout.fixed.horizontal()
        },
        layout = wibox.layout.align.horizontal
    }
end)

client.connect_signal("mouse::enter", function(c)
    c:emit_signal("request::activate", "mouse_enter", {raise = false})
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
