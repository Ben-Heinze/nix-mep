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

  # PhotoGIMP: Photoshop-style configuration overlay for GIMP.
  # On first build, set `hash` to lib.fakeHash and rebuild — nix will print the
  # real hash, paste it back here. Update `rev` periodically to pull upstream changes.
  photogimp = pkgs.fetchFromGitHub {
    owner = "Diolinux";
    repo = "PhotoGIMP";
    rev = "master";
    hash = "sha256-EafWnUnHmcWsKlUZtT/GLyIeq+S9wFuKCijn3BedKGo=";
  };
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

  # Photo editing stack (Photoshop replacement)
  pkgs.gimp-with-plugins   # GIMP 3 + bundled plugins (gmic, resynthesizer, fourier, lqr, etc. where ported)
  pkgs.darktable           # RAW developer (Lightroom equivalent)
  pkgs.rawtherapee         # Alternative RAW developer — sometimes better per-camera
  pkgs.upscayl             # AI image upscaler (covers PS Neural Filters / Super Resolution gap)
  pkgs.gpick               # Advanced color picker / palette tool
  pkgs.imagemagick         # CLI image processing for batch / scripting
  ];

  # PhotoGIMP overlay: copy the upstream Photoshop-style profile into
  # ~/.config/GIMP/3.0/ so GIMP launches with PS-like splash, toolbox order,
  # and defaults. Uses `cp -n` (no-clobber) so any later in-GIMP customizations
  # you make are preserved across rebuilds. To re-pull a fresh PhotoGIMP,
  # delete ~/.config/GIMP/3.0/ and run `just switch`.
  #
  # PS-style keybinds (shortcutsrc) are installed separately below — upstream
  # PhotoGIMP only ships GIMP 2.10's menurc, which GIMP 3 doesn't read.
  home.activation.installPhotoGIMP = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    src="${photogimp}/.config/GIMP"
    if [ -d "$src" ]; then
      mkdir -p "$HOME/.config/GIMP/3.0"
      for verdir in "$src"/*/; do
        [ -d "$verdir" ] || continue
        cp -rn "$verdir"/. "$HOME/.config/GIMP/3.0/" 2>/dev/null || true
      done
      chmod -R u+w "$HOME/.config/GIMP" 2>/dev/null || true
    fi

    # PS-style keybinds for GIMP 3 (managed file). Reinstalled only when the
    # source file content changes — so in-GIMP keybind tweaks persist between
    # nix-mep updates, but bumping cfgs/gimp/shortcutsrc propagates on next switch.
    nixmep_src="${./gimp/shortcutsrc}"
    nixmep_dst="$HOME/.config/GIMP/3.0/shortcutsrc"
    nixmep_marker="$HOME/.config/GIMP/3.0/.nix-mep-shortcuts-hash"
    nixmep_src_hash="$(${pkgs.coreutils}/bin/sha256sum "$nixmep_src" | ${pkgs.coreutils}/bin/cut -d' ' -f1)"
    if [ ! -f "$nixmep_marker" ] || [ "$(${pkgs.coreutils}/bin/cat "$nixmep_marker" 2>/dev/null)" != "$nixmep_src_hash" ]; then
      mkdir -p "$HOME/.config/GIMP/3.0"
      ${pkgs.coreutils}/bin/cp -f "$nixmep_src" "$nixmep_dst"
      chmod u+w "$nixmep_dst"
      echo "$nixmep_src_hash" > "$nixmep_marker"
    fi
  '';

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



