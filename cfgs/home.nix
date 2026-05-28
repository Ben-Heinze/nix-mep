{ pkgs, ... }:

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
  pkgs.rofi
  pkgs.taskwarrior-tui
  pkgs.yazi
  pkgs.ripgrep
  ];

  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
    nix-direnv.enable = true;
  };

  programs.home-manager.enable = true;

  xdg.configFile."awesome/rc.lua".source = pkgs.substituteAll {
    src = ./rc.lua;
    feh = pkgs.feh;
    wallpaper = ../wallpaper.png;
  };
}
