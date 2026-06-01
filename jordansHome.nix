{
  pkgs,
  lib,
  ...
}: let
  emacs = pkgs.emacs;
  zathura = pkgs.zathura;
  qutebrowser = pkgs.qutebrowser;
  zathuraDesktopEntry = ''
    [Desktop Entry]
    Version=1.0
    Name=Zathura Document Viewer
    Exec=${zathura}/bin/zathura %U
    Icon=${zathura}/share/icons/hicolor/scalable/apps/zathura.svg
    Type=Application
    Categories=Graphics;Viewer;
    StartupNotify=true
  '';

  qutebrowserDesktopEntry = ''
    [Desktop Entry]
    Version=1.0
    Name=Qutebrowser Web Browser
    Exec=${qutebrowser}/bin/qutebrowser %U
    Icon=${qutebrowser}/share/icons/hicolor/scalable/apps/zathura.svg
    Type=Application
    Categories=Browser;Viewer;
    StartupNotify=true
  '';

  emacsDesktopEntry = ''
    [Desktop Entry]
    Version=0.1
    Name=Emacs (MiseEnPlace)
    Exec=nix run --refresh "github:jordanschupbach/emc" %U
    Type=Application
    Categories=Graphics;Viewer;
    StartupNotify=true
  '';

  fzf = pkgs.fetchFromGitHub {
    owner = "junegunn";
    repo = "fzf";
    rev = "aa2e126a14c6456ab0e4b3b7bfd56c11c5a8dc02";
    sha256 = "sha256-E/sfMQQb8DFT8kxQwlqy8/hFI/JXvJDbGp7MvwseJhs=";
  };

  # {{{ r packages

  R-with-my-packages = pkgs.rWrapper.override {
    packages = with pkgs.rPackages; [
      snakecase
      lme4
      languageserver
      lintr
      geoR
      lme4
      plotly
      reshape2
      tidyr
      viridis
      lmerTest
      emdbook
      languageserver
      progressr
      progress
      pbapply
      foreach
      doParallel
      HLMdiag
    ];
  };
  # }}} r packages


in {

  home.stateVersion = "25.11";
  programs.home-manager.enable = true;

#   # {{{ xsession
# 
#   xsession.initExtra = ''
# 
#     xset r rate 200 60
# 
#   '';
# 
#   # }}} xsession
# 
#   # {{{ Themes
# 
#   # home.pointerCursor = {
#   #   gtk.enable = true;
#   #   name = "Catppuccin-Mocha-Light-Cursors";
#   #   package = pkgs.catppuccin-cursors.mochaLight;
#   #   size = 16;
#   # };
# 
#   # gtk = {
#   #   enable = true;
#   #   theme = {
#   #     name = "Breeze-Dark";
#   #     package = pkgs.libsForQt5.breeze-gtk;
#   #   };
#   #   iconTheme = {
#   #     name = "Papirus-Dark";
#   #     package = pkgs.catppuccin-papirus-folders.override {
#   #       flavor = "mocha";
#   #       accent = "lavender";
#   #     };
#   #   };
#   #   cursorTheme = {
#   #     name = "Catppuccin-Mocha-Light-Cursors";
#   #     package = pkgs.catppuccin-cursors.mochaLight;
#   #   };
#   #   gtk3 = {
#   #     extraConfig.gtk-application-prefer-dark-theme = true;
#   #   };
#   # };
# 
#   # dconf.settings."org/gtk/settings/file-chooser" = {
#   #   sort-directories-first = true;
#   # };
# 
#   # # GTK4 Setup
#   # dconf.settings."org/gnome/desktop/interface" = {
#   #   gtk-theme = lib.mkForce "Breeze";
#   #   color-scheme = "prefer-dark";
#   # };
# 
#   # }}} Themes
# 
# {{{ User

home.username = "jordan";
home.homeDirectory = "/home/jordan";
home.file = {};

# }}} User
# 
# {{{ Packages

home.packages = [

  pkgs.nwg-bar
  pkgs.nwg-look
  pkgs.nwg-dock
  pkgs.nwg-menu
  pkgs.nwg-panel
  pkgs.nwg-drawer

  pkgs.emacs
  pkgs.zoom-us
  pkgs.slack
  pkgs.sqlite
  pkgs.hello
  #
  # pkgs.rWrapper
  # R-with-my-packages
  pkgs.paraview
  pkgs.uair
  pkgs.yad
  pkgs.tomato-c
  pkgs.pinta
  pkgs.discord
  pkgs.taskwarrior3
  pkgs.taskwarrior-tui
  pkgs.jdt-language-server
  pkgs.vlc
  pkgs.bat
  pkgs.btop
  pkgs.byobu
  pkgs.chromium
  pkgs.entr
  pkgs.eza
  pkgs.ffmpeg
  pkgs.copilot-language-server
  # pkgs.fzf
  pkgs.gimp
  pkgs.htop
  pkgs.hub
  pkgs.imagemagick
  # pkgs.kdePackages.dolphin
  # pkgs.kitty
  pkgs.libnotify
  pkgs.rsclock
  pkgs.libreoffice
  pkgs.mc
  pkgs.libxcb-cursor
  pkgs.dunst
  pkgs.feh
  pkgs.zsnes2
  pkgs.dolphin-emu
  pkgs.duckstation
  pkgs.slock
  pkgs.ollama-cuda
  pkgs.opencode
  pkgs.codex
  pkgs.fastfetch
  pkgs.lazygit
  pkgs.yt-dlp
  pkgs.youtube-tui
  pkgs.mpv
  pkgs.cmus
  pkgs.pdftk
  pkgs.grip-search
  pkgs.qpdfview
  pkgs.gnome-screenshot
  pkgs.ncdu
  pkgs.neofetch
  pkgs.qemu
  pkgs.virtualbox
  pkgs.quickemu
  pkgs.qutebrowser
  pkgs.ranger
  pkgs.ripgrep
  pkgs.rofi
  pkgs.screen
  pkgs.tldr
  pkgs.tmux
  pkgs.tree
  pkgs.vim
  pkgs.xfce.thunar
  zathura
  pkgs.zellij
  pkgs.zoxide
  pkgs.alsa-utils
  pkgs.yazi
  pkgs.zotero
  pkgs.vimiv-qt
  pkgs.rnote
  pkgs.gh
  pkgs.man
  pkgs.man-pages
  pkgs.inkscape
  pkgs.curlWithGnuTls
  pkgs.ghostty pkgs.caligula
  pkgs.nushell
  pkgs.pastel
  pkgs.openconnect
  # pkgs.astroterm

  # TODO: remove and pull into nvim-mep?
  pkgs.neovim
  # pkgs.libclang
  # pkgs.bear
  pkgs.arandr
  # pkgs.libxml2

  # For fun
  pkgs.fireplace
  pkgs.cbonsai
  pkgs.cmatrix
  pkgs.asciiquarium
  pkgs.cava
  pkgs.openconnect
  # pkgs.libsForQt5.dolphin
  # pkgs.ghostscript

  #
  # (
  #   pkgs.stdenv.mkDerivation {
  #     pname = "fzf";
  #     version = "0.65.2";

  #     src = pkgs.fetchurl {
  #       url = "https://github.com/junegunn/fzf/releases/download/v0.65.2/fzf-0.65.2-linux_amd64.tar.gz";
  #       sha256 = "5eb8efc0e94aa559f84ea83eeba99bea7dce818e63f92b4b62e60663220f1c14";
  #     };

  #     buildInputs = [
  #       pkgs.curl
  #     ];

  #     installPhase = ''
  #       # Create the bin directory
  #       mkdir -p $out/bin

  #       # Extract the FZF binary
  #       tar -xzf $src
  #       mv fzf $out/bin/
  #       chmod +x $out/bin/fzf

  #       # Download additional scripts directly from the repository
  #       curl -L -o $out/bin/fzf-tmux https://raw.githubusercontent.com/junegunn/fzf/refs/tags/v0.65.2/bin/fzf-preview.sh
  #       curl -L -o $out/bin/fzf-preview.sh https://raw.githubusercontent.com/junegunn/fzf/refs/tags/v0.65.2/bin/fzf-tmux

  #       # Make the additional scripts executable
  #       chmod +x $out/bin/fzf-tmux
  #       chmod +x $out/bin/fzf-preview.sh
  #     '';

  #     # Prevent unpackPhase from executing
  #     unpackPhase = "true";
  #   }
  # )
];

# }}} Packages
# 
#   # {{{ env
#   # home.sessionVariables = [
#   #   # EDITOR = "nvim";
#   # ];
#   # }}} env
# 
#   # {{{ Alacritty
# 
#   # programs.alacritty.settings = {
#   #   env = {
#   #     WINIT_X11_SCALE_FACTOR = "2.0";
#   #   };
#   # };
# 
#   # }}} Alacritty
# 
# {{{ Kitty config

programs.kitty = {
  enable = true;
  extraConfig = ''
    # font_size = 30.0
  '';
  font.size = 16.0;
  font.name = "UbuntuMono Nerd Font";
  settings = {
    tab_bar_edge = "top";
    tab_bar_margin_width = 0.0;
    tab_bar_style = "separator";
    tab_separator = "''";
    tab_bar_min_tabs = 2;
    tab_title_template = "{fmt.fg._5c6370}{fmt.bg._11111b}{fmt.fg._cdd6f4}{fmt.bg._5c6370} ({index}) {title} {fmt.fg._5c6370}{fmt.bg._11111b} ";
    active_tab_title_template = "{fmt.fg._BAA0E8}{fmt.bg._11111b}{fmt.fg._1e1e2e}{fmt.bg._BAA0E8} ({index}) {title} {fmt.fg._BAA0E8}{fmt.bg._11111b} ";
    active_tab_font_style = "bold";
    # background = "#ffffff";
    # background_opacity = 0.9;
  };
};

# }}} Kitty config


# {{{ Bash

programs.bash = {
  enable = true; # see note on other shells below
  initExtra = ''
    eval -- "$(/run/current-system/sw/bin/starship init bash --print-full-init)"
    export PATH="/home/jordan/scripts/:$PATH"
    export PATH="/home/jordan/.scripts/:$PATH"
    alias gs='git status'
    alias ga='git add'
    alias gcom='git commit -m'
    alias gpush='git push'
    alias gpull='git pull'
    alias gl='git log --oneline --graph --decorate --all'
    alias dr='direnv reload'
    alias da='direnv allow'
    alias db='direnv block'
    alias ll='ls -l'
    alias la='ls -la'
    alias tom='tomato'
    alias t='taskwarrior-tui --taskdata ./task'
    alias yaz='yazi'
    alias y='yazi'
    alias cmu='cmus'
    # alias nvm='nix run "github:jordanschupbach/nvim-mep"'
    alias n='nix run --refresh "github:jordanschupbach/nvmep2"'
    alias mux='nix run --refresh "github:dlm/muxwm"'
    alias emc='nix run --refresh "github:jordanschupbach/emc"'
    alias e='nix run --refresh "github:jordanschupbach/emc" -- -nw'
    # alias emc='emacs --init-dir /home/jordan/.emacs.misenplace/ -nw'
    alias q='exit'
    alias r='yazi'
    export EDITOR='nvim'
    function wd() {
      cmd=$1
      name=$2
      path=$(pwd)
      dirname=$(basename "$path")
      WD_FILE="$HOME/.wd"
      if [ $# -gt 2 ]; then
          echo "Error: Too many arguments."
          echo "Usage: wd <command> [args]"
          echo "Use 'wd help' for more information."
          return
      fi
      if [ -z "$cmd" ]; then
          echo "Error: Command not provided."
          echo "Usage: wd <command> [args]"
          echo "Use 'wd help' for more information."
          return
      fi
      if [ "$cmd" == "help" ]; then
          echo "Usage: wd <command> [args]"
          echo "Commands:"
          echo "  add [<name>]  Add the current directory with the optional given name"
          echo "  delete <name>    Delete the directory with the given name"
          echo "  list             List all saved directories"
          echo "  clean            Remove all saved directories"  
          echo "  help             Show this help message"
          return
      fi
      if [ "$cmd" == "clean" ]; then
        echo "Cleaning up (deleting the) wd file..."
        rm -f "$HOME/.wd"
        return
      fi
      if [ ! -f "$WD_FILE" ]; then
          touch "$WD_FILE"
      fi
      if [ "$cmd" == "list" ]; then
          echo "Saved directories:"
          cat "$WD_FILE"
          return
      fi
      function add_dir() {
          if [ -z "$name" ]; then
              name=$(basename "$path")
          fi
          if grep -q "^$name=" "$WD_FILE"; then
              echo "Error: Directory with the name '$name' already exists."
              return
          fi
          echo "$name=$path" >> "$WD_FILE"
          echo "Added '$path' as '$name'."
      }
      function switch_dir() {
        while read -r line; do
          saved_name=$(echo "$line" | cut -d '=' -f 1)
          saved_path=$(echo "$line" | cut -d '=' -f 2-)
          if [ "$saved_name" == "$cmd" ]; then
            echo "Switching to directory $saved_path."
            cd "$saved_path" || return # Ensure it handles errors if cd fails
            return
          fi
        done < "$WD_FILE"
      }
      function main() {
        if [ "$cmd" == "add" ]; then
          add_dir
          return
        fi
        if [ "$cmd" == "delete" ]; then
          if [ $name == "" ]; then
            echo "Error: No name provided for deletion."
            return
          fi
          sed -i "/^$name=/d" "$WD_FILE"
          echo "Deleted directory with name '$name'."
          return
        fi
        if [ "$cmd" != "add" ] && [ "$cmd" != "delete" ] && [ "$cmd" != "list" ] && [ "$cmd" != "clean" ]; then
          switch_dir
          return
        fi
      }
      main
    }

    # bind -r '\e-'
    # bind -r '\e0'
    # bind -r '\e1'
    # bind -r '\e2'
    # bind -r '\e3'
    # bind -r '\e4'
    # bind -r '\e5'
    # bind -r '\e6'
    # bind -r '\e7'
    # bind -r '\e8'
    # bind -r '\e9'



  '';
};

# }}} Bash

# {{{ zsh

  programs.zsh = {
    enable = true;
    initExtra = ''
    '';
  };

# }}} zsh

#   # {{{ emacs
# 
#   programs.emacs = {
#     enable = true;
#     package = pkgs.emacs; # replace with pkgs.emacs-gtk, or a version provided by the community overlay if desired.
#     extraConfig = ''
# 
#       (require 'package)
#       (add-to-list 'package-archives '("gnu"   . "https://elpa.gnu.org/packages/"))
#       (add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/"))
#       (package-initialize)
# 
#       (unless (package-installed-p 'use-package)
#         (package-refresh-contents)
#         (package-install 'use-package))
#       (eval-and-compile
#         (setq use-package-always-ensure t
#               use-package-expand-minimally t))
# 
#       (use-package markdown-mode
#         :hook (markdown-mode . auto-fill-mode))
# 
#     '';
#   };
# 
#   # }}} emacs
# 
# {{{ picom

services.picom = {
  enable = true;
  activeOpacity = 1.0;
  inactiveOpacity = 0.80;
  backend = "glx";
  fade = false;
  fadeDelta = 5;
  opacityRules = [
    "95:class_g = 'URxvt' && !_NET_WM_STATE@:32a"
    "0:_NET_WM_STATE@:32a *= '_NET_WM_STATE_HIDDEN'"
    "100:name *= 'i3lock'"
    "99:fullscreen"
    "97:class_g = 'btop' && focused"
    "94:class_g = 'kitty' && focused"
    "94:class_g = 'kitty' && !focused"
    "94:class_g = 'Alacritty' && focused"
    "98:class_g = 'Emacs' && focused"
    "98:class_g = 'emacs' && focused"
    "98:class_g = 'emacs' && !focused"
    "98:class_g = 'Emacs' && !focused"

    # "90:class_g = 'Alacritty' && !focused"
    # "94:class_g = 'emacs' && !focused"

    "100:class_g = 'Brave-browser' && focused"
    "100:class_g = 'Brave-browser' && !focused"
  ];
  shadow = true;
  shadowOpacity = 0.75;
};

# }}} picom

# {{{ alacritty

programs.alacritty = {
  enable = true;
  settings = lib.mkOptionDefault {
    font = {
      normal = {
        family = "UbuntuMono Nerd Font";
      };
      size = 18.0;
    };

    #window.opacity = 0.9;

    #shell = {
    #  program = "${fish}";
    #  args = [ "--login" ];
    #};

    colors = {
      primary = {
        background = "#161821";
        foreground = "#d2d4de";
      };
      normal = {
        black = "#161821";
        red = "#e27878";
        green = "#b4be82";
        yellow = "#e2a478";
        blue = "#84a0c6";
        magenta = "#a093c7";
        cyan = "#89b8c2";
        white = "#c6c8d1";
      };
      bright = {
        black = "#6b7089";
        red = "#e98989";
        green = "#c0ca8e";
        yellow = "#e9b189";
        blue = "#91acd1";
        magenta = "#ada0d3";
        cyan = "#95c4ce";
        white = "#d2d4de";
      };
    };
  };
};

# }}} alacritty

# {{{ awesome
home.file = {
  ".config/awesome/rc.lua" = {
    text = ''             
      -- {{{ Header
      -- If LuaRocks is installed, make sure that packages installed through it are
      -- found (e.g. lgi). If LuaRocks is not installed, do nothing.
      pcall(require, "luarocks.loader")

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
      local hotkeys_popup = require("awful.hotkeys_popup")
      -- Enable hotkeys help widget for VIM and other apps
      -- when client with a matching name is opened:
      require("awful.hotkeys_popup.keys")

      -- }}} Header

      -- {{{ Error handling
      -- Check if awesome encountered an error during startup and fell back to
      -- another config (This code will only ever execute for the fallback config)
      if awesome.startup_errors then naughty.notify({ preset = naughty.config.presets.critical,
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

      -- {{{ Variable definitions


      -- {{{ theme

      local theme_assets = require("beautiful.theme_assets")
      local xresources = require("beautiful.xresources")
      -- local rnotification = require("ruled.notification")
      local dpi = xresources.apply_dpi
      local gfs = require("gears.filesystem")
      local themes_path = gfs.get_themes_dir()

      -- Themes define colours, icons, font and wallpapers.
      beautiful.init(gears.filesystem.get_themes_dir() .. "default/theme.lua")
      local theme = beautiful.get()
      theme.font = "sans 18"
      theme.bg_normal = "#1e1e39"
      theme.bg_focus = "#1e1e29"
      theme.bg_urgent = "#d7474b"
      theme.bg_minimize = "#444444"
      theme.bg_systray = "#1e1e39"
      theme.fg_focus = "#da267f"
      theme.fg_normal = "#8a469f"
      theme.fg_urgent = "#3b267f"
      theme.fg_minimize = "#3b267f"
      theme.useless_gap = dpi(2)
      theme.border_width = dpi(6)
      theme.border_color_normal = "#000000"
      theme.border_color_active = "#43436c"
      theme.border_color_marked = "#91231c"
      theme.bg_widget = "#1e1e39"
      theme.taglist_bg_focus = "#1e1e39"
      theme.taglist_bg_volatile = "#1e1e39"
      theme.taglist_bg_empty = "#1e1e39"
      theme.taglist_bg_occupied = "#1e1e39"
      theme.tasklist_bg_normal = "#1e1e39"
      theme.tasklist_bg_focus = "#1e1e39"

      beautiful.init(theme)
      -- beautiful.init("/home/jordan/.config/awesome/themes/dark-theme/theme.lua")
      -- beautiful.init(gears.filesystem.get_themes_dir() .. "dark-theme/theme.lua")

      -- }}} theme

      local function notify_theme_dir()
          local theme_dir = gears.filesystem.get_themes_dir()
          naughty.notify({ preset = naughty.config.presets.notify,
                            title = "Theme Directory",
                            text = theme_dir })
      end

      -- This is used later as the default terminal and editor to run.
      terminal = "kitty"
      editor = os.getenv("EDITOR") or "nano"
      editor_cmd = terminal .. " -e " .. editor

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
          -- awful.layout.suit.corner.ne,
          -- awful.layout.suit.corner.sw,
          -- awful.layout.suit.corner.se,
      }
      -- }}}

      -- {{{ Menu
      -- Create a launcher widget and a main menu
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

      -- Menubar configuration
      menubar.utils.terminal = terminal -- Set the terminal for applications that require it
      -- }}}

      -- Keyboard map indicator and switcher
      mykeyboardlayout = awful.widget.keyboardlayout()

      -- {{{ Wibar
      -- Create a textclock widget
      mytextclock = wibox.widget.textclock()

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

          -- Each screen has its own tag table.
          awful.tag({ "1", "2", "3", "4", "5", "6", "7", "8", "9" }, s, awful.layout.layouts[1])

          -- Create a promptbox for each screen
          s.mypromptbox = awful.widget.prompt()
          -- Create an imagebox widget which will contain an icon indicating which layout we're using.
          -- We need one layoutbox per screen.
          s.mylayoutbox = awful.widget.layoutbox(s)
          s.mylayoutbox:buttons(gears.table.join(
                                 awful.button({ }, 1, function () awful.layout.inc( 1) end),
                                 awful.button({ }, 3, function () awful.layout.inc(-1) end),
                                 awful.button({ }, 4, function () awful.layout.inc( 1) end),
                                 awful.button({ }, 5, function () awful.layout.inc(-1) end)))
          -- Create a taglist widget
          s.mytaglist = awful.widget.taglist {
              screen  = s,
              filter  = awful.widget.taglist.filter.all,
              buttons = taglist_buttons
          }

          -- Create a tasklist widget
          s.mytasklist = awful.widget.tasklist {
              screen  = s,
              filter  = awful.widget.tasklist.filter.currenttags,
              buttons = tasklist_buttons
          }

          -- Create the wibox
          s.mywibox = awful.wibar({ position = "top", screen = s })

          -- Add widgets to the wibox
          s.mywibox:setup {
              layout = wibox.layout.align.horizontal,
              { -- Left widgets
                  layout = wibox.layout.fixed.horizontal,
                  mylauncher,
                  s.mytaglist,
                  s.mypromptbox,
              },
              s.mytasklist, -- Middle widget
              { -- Right widgets
                  layout = wibox.layout.fixed.horizontal,
                  mykeyboardlayout,
                  wibox.widget.systray(),
                  mytextclock,
                  s.mylayoutbox,
              },
          }
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

          awful.key({ modkey }, ";", notify_theme_dir,
                    {description = "show theme directory", group = "custom"}),

          -- awful.key({ modkey,           }, "j",
          --     function ()
          --         awful.client.focus.byidx( 1)
          --     end,
          --     {description = "focus next by index", group = "client"}
          -- ),
          -- awful.key({ modkey,           }, "k",
          --     function ()
          --         awful.client.focus.byidx(-1)
          --     end,
          --     {description = "focus previous by index", group = "client"}
          -- ),
          awful.key({ modkey,           }, "w", function () mymainmenu:show() end,
                    {description = "show main menu", group = "awesome"}),

          awful.key({ modkey }, "[", function()
              awful.spawn.with_shell("/home/jordan/.scripts/pp")
          end, {description = "select project directory", group = "custom"}),


          awful.key({ modkey }, "]", function()
              awful.spawn.with_shell("/home/jordan/.scripts/pp")
          end, {description = "select project directory", group = "custom"}),


          -- Layout manipulation
          -- awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end,
          --           {description = "swap with next client by index", group = "client"}),
          -- awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end,
          --           {description = "swap with previous client by index", group = "client"}),
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

          awful.key({ modkey,  "Shift"   }, "l",     function () awful.tag.incmwfact( 0.05)          end,
                    {description = "increase master width factor", group = "layout"}),
          awful.key({ modkey,  "Shift"   }, "h",     function () awful.tag.incmwfact(-0.05)          end,
                    {description = "decrease master width factor", group = "layout"}),


          awful.key({ modkey,           }, "j", function() 
            awful.client.focus.global_bydirection("down")
            if client.focus then
              client.focus:raise()
            end
          end),

          awful.key({ modkey,           }, "k", function() 
            awful.client.focus.global_bydirection("up")
            if client.focus then
              client.focus:raise()
            end
          end),

          awful.key({ modkey,           }, "h", function() 
            awful.client.focus.global_bydirection("left")
            if client.focus then
              client.focus:raise()
            end
          end),

          awful.key({ modkey,           }, "l", function() 
            awful.client.focus.global_bydirection("right")
            if client.focus then
              client.focus:raise()
            end
          end),



          -- awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1, nil, true) end,
          --           {description = "increase the number of master clients", group = "layout"}),
          -- awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1, nil, true) end,
          --           {description = "decrease the number of master clients", group = "layout"}),
          awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1, nil, true)    end,
                    {description = "increase the number of columns", group = "layout"}),
          awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1, nil, true)    end,
                    {description = "decrease the number of columns", group = "layout"}),
          awful.key({ modkey,           }, "space", function () awful.layout.inc( 1)                end,
                    {description = "select next", group = "layout"}),
          awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(-1)                end,
                    {description = "select previous", group = "layout"}),

      	-- By direction client focus
      	awful.key({ modkey, "Control" }, "j", function()
      		awful.client.swap.global_bydirection("down")
      		-- if client.focus then client.focus:raise() end
      	end),
      	awful.key({ modkey, "Control" }, "k", function()
      		awful.client.swap.global_bydirection("up")
      		-- if client.focus then client.focus:raise() end
      	end),
      	awful.key({ modkey, "Control" }, "h", function()
      		awful.client.swap.global_bydirection("left")
      		-- if client.focus then client.focus:raise() end
      	end),
      	awful.key({ modkey, "Control" }, "l", function()
      		awful.client.swap.global_bydirection("right")
      		-- if client.focus then client.focus:raise() end
      	end),

      	awful.key({ modkey, "Shift" }, "l", function()
      		awful.tag.incmwfact(0.01)
      	end),
      	awful.key({ modkey, "Shift" }, "h", function()
      		awful.tag.incmwfact(-0.01)
      	end),
      	awful.key({ modkey, "Shift" }, "j", function()
      		awful.client.incwfact(0.05)
      	end),
      	awful.key({ modkey, "Shift" }, "k", function()
      		awful.client.incwfact(-0.05)
      	end),

      	awful.key({ modkey, "Control" }, "u", function()
      		local active_layout = awful.layout.getname(awful.layout.get(awful.screen.focused()))
      		naughty.notify({ text = "Active Layout: " .. active_layout })
      	end),





          awful.key({ modkey, "Control" }, "n",
                    function ()
                        local c = awful.client.restore()
                        -- Focus restored client
                        if c then
                          c:emit_signal(
                              "request::activate", "key.unminimize", {raise = true}
                          )
                        end
                    end,
                    {description = "restore minimized", group = "client"}),

          -- Prompt
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

      	awful.key({ modkey, "Control" }, "r", awesome.restart, { description = "reload awesome", group = "awesome" }),
      	awful.key({ modkey, "Shift" }, "q", awesome.quit, { description = "quit awesome", group = "awesome" }),
      	awful.key({ modkey }, "x", function()
      		awful.prompt.run({
      			prompt = "Run Lua code: ",
      			textbox = awful.screen.focused().mypromptbox.widget,
      			exe_callback = awful.util.eval,
      			history_path = awful.util.get_cache_dir() .. "/history_eval",
      		})
      	end, { description = "lua execute prompt", group = "awesome" }),
      	awful.key({ modkey }, "Return", function()
      		awful.spawn("")
      	end, { description = "open a terminal", group = "launcher" }),
      	-- awful.key({ modkey }, "r", function()
      	--   awful.screen.focused().mypromptbox:run()
      	-- end, { description = "run prompt", group = "launcher" }),
      	-- awful.key({ modkey }, "p", function() menubar.show() end,
      	--           {description = "show the menubar", group = "launcher"}),
      	awful.key({ modkey }, "p", function()
      		os.execute("rofi -show drun")
      	end, { description = "show rofi", group = "launcher" }),
      	awful.key({ modkey }, "u", function()
      		os.execute("/home/jordan/.scripts/waldark")
      	end, { description = "show the d-menu", group = "launcher" }),
      	awful.key({ modkey }, "y", function()
      		os.execute("slock")
      	end, { description = "show the d-menu", group = "launcher" }),

      	awful.key({ modkey }, "/", function()
      		os.execute("rofi -show window")
      	end, { description = "show the d-menu", group = "launcher" }),

      	-- awful.key({ modkey }, "r", function()
      	-- 	os.execute("rofi -show run")
      	-- end, { description = "show rofi run menu", group = "launcher" }),

      	-- Bind the function to a key combination
      	awful.key({ modkey }, "r", changeWindowName, { description = "Rename window", group = "Client" }),

      	awful.key({ modkey, "Shift" }, "g", function()
      		os.execute("firefox --new-instance -url https://www.openai.com/")
      	end, { description = "open openai", group = "launcher" })


          -- -- Menubar
          -- awful.key({ modkey }, "p", function() menubar.show() end,
          --           {description = "show the menubar", group = "launcher"}),
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
                           placement = awful.placement.no_overlap+awful.placement.no_offscreen
           }
          },

          -- Floating clients.
          { rule_any = {
              instance = {
                "DTA",  -- Firefox addon DownThemAll.
                "copyq",  -- Includes session name in class.
                "pinentry",
              },
              class = {
                "Arandr",
                "Blueman-manager",
                "Gpick",
                "Kruler",
                "MessageWin",  -- kalarm.
                "Sxiv",
                "Tor Browser", -- Needs a fixed window size to avoid fingerprinting by screen size.
                "Wpa_gui",
                "veromix",
                "xtightvncviewer"},

              -- Note that the name property shown in xprop might be set slightly after creation of the client
              -- and the name shown there might not match defined rules here.
              name = {
                "Event Tester",  -- xev.
              },
              role = {
                "AlarmWindow",  -- Thunderbird's calendar.
                "ConfigManager",  -- Thunderbird's about:config.
                "pop-up",       -- e.g. Google Chrome's (detached) Developer Tools.
              }
            }, properties = { floating = true }},

          -- Add titlebars to normal clients and dialogs
          { rule_any = {type = { "normal", "dialog" }
            }, properties = { titlebars_enabled = false }
          },

          -- Set Firefox to always map on the tag named "2" on screen 1.
          -- { rule = { class = "Firefox" },
          --   properties = { screen = 1, tag = "2" } },
      }
      -- }}}

      -- {{{ Signals
      -- Signal function to execute when a new client appears.
      client.connect_signal("manage", function (c)
          -- Set the windows at the slave,
          -- i.e. put it at the end of others instead of setting it master.
          -- if not awesome.startup then awful.client.setslave(c) end

          if awesome.startup
            and not c.size_hints.user_position
            and not c.size_hints.program_position then
              -- Prevent clients from being unreachable after screen count changes.
              awful.placement.no_offscreen(c)
          end
      end)

      -- Add a titlebar if titlebars_enabled is set to true in the rules.
      client.connect_signal("request::titlebars", function(c)
          -- buttons for the titlebar
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

      -- Enable sloppy focus, so that focus follows mouse.
      client.connect_signal("mouse::enter", function(c)
          c:emit_signal("request::activate", "mouse_enter", {raise = false})
      end)

      client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
      client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
      -- }}}    '';

    executable = false;
  };
};

# }}} awesome

# {{{ direnv

programs.direnv = {
  enable = true;
  enableBashIntegration = true;
  nix-direnv.enable = true;
  #  NOTE: is my version up to date? should be iin 25.05
  # direnvrcExtra = ''
  #   export FOO="foo"
  #   echo "loaded direnv!"
  # '';
};

# }}} direnv

#   # {{{ qutebrowser
# 
#   programs.qutebrowser = {
#     enable = true;
#     settings = {
#       content = {
#         javascript.enabled = true;
#         webgl = true;
#       };
#       colors.webpage.darkmode.enabled = true;
#     };
#   };
# 
#   # }}} qutebrowser

# {{{ Applications desktop entries

home.file.".local/share/applications/zathura.desktop".text = zathuraDesktopEntry;
home.file.".local/share/applications/qutebrowser.desktop".text = qutebrowserDesktopEntry;
home.file.".local/share/applications/emacs.desktop".text = emacsDesktopEntry;

# }}} Applications desktop entries

xdg.mimeApps = {
  enable = true;
  defaultApplications = {
    "text/html" = "firefox.desktop";
    "x-scheme-handler/http" = "firefox.desktop";
    "x-scheme-handler/https" = "firefox.desktop";
    "x-scheme-handler/about" = "firefox.desktop";
    "x-scheme-handler/unknown" = "firefox.desktop";
    "application/pdf" = "zathura.desktop";
  };
};
}
# vim: set foldmarker={{{,}}} foldmethod=marker foldlevel=0:

