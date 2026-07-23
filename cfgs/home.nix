{ pkgs, lib, ... }:


let
  emacsDesktopEntry = ''
    [Desktop Entry]
    Version=0.1
    Name=Emacs (MiseEnPlace)
    Exec=nix run --refresh "github:jordanschupbach/emc" %U
    Type=Application
    Categories=Graphics;Viewer;
    StartupNotify=true
  '';
in

{
  home.username = "ben";
  home.homeDirectory = "/home/ben";

  home.stateVersion = "25.11";

  home.packages = with pkgs; [
  pkgs.taskwarrior3
  pkgs.arandr
  pkgs.feh
  pkgs.gh
  pkgs.htop
  pkgs.zathura
  pkgs.taskwarrior-tui
  pkgs.yazi
  pkgs.ripgrep
  pkgs.xclip
  pkgs.nerd-fonts.ubuntu-mono
  ];

  programs.rofi = {
    enable = true;
    font = "monospace 24";
    theme = "Arc-Dark";
  };

  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
    nix-direnv.enable = true;
  };

  programs.bash = {
    enable = true;
    bashrcExtra = builtins.readFile ./bashrc;
  };

  programs.starship = {
    enable = true;
    enableBashIntegration = true;
  };



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


  home.file.".local/share/applications/emacs.desktop".text = emacsDesktopEntry;


  programs.home-manager.enable = true;

  xdg.configFile."awesome/rc.lua".source = pkgs.replaceVars ./rc.lua {
    feh = pkgs.feh;
    wallpaper = ../wallpaper.png;
  };
}



