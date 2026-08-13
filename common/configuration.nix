{ config, pkgs, unstablePkgs, ... }:

let
  # Spotify's Chromium/Electron backend leaves a SingletonLock (+ SingletonSocket/
  # SingletonCookie) in ~/.cache/spotify. If the hostname changes or the machine
  # loses power uncleanly, that lock can point at a process that no longer exists,
  # and Spotify silently no-ops on launch instead of starting. This wrapper clears
  # the lock files before exec'ing the real binary, but only when no Spotify
  # process is actually running, so a genuinely running instance is left alone.
  # NOTE: this shadows `pkgs.spotify` in the `with pkgs; [ ... spotify ... ]` list
  # below via lexical scoping, so the rest of that list is unaffected.
  spotify = pkgs.symlinkJoin {
    name = "spotify";
    paths = [ pkgs.spotify ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      rm "$out/bin/spotify"
      makeWrapper ${pkgs.spotify}/bin/spotify "$out/bin/spotify" \
        --run '
          cache_dir="$HOME/.cache/spotify"
          if [ -e "$cache_dir/SingletonLock" ] && ! ${pkgs.procps}/bin/pgrep -f "share/spotify/.spotify-wrapped" >/dev/null 2>&1; then
            rm -f "$cache_dir/SingletonLock" "$cache_dir/SingletonSocket" "$cache_dir/SingletonCookie"
          fi
        '
    '';
  };
in

{
  # Networking
  networking.networkmanager.enable = true;

  # Allow the phone-import app's local web server (walks 47820->47829 on conflict)
  networking.firewall.allowedTCPPortRanges = [
    { from = 47820; to = 47829; }
  ];

  # Timezone & Locale
  time.timeZone = "America/Denver";

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Key repeat rate (shared across all machines)
  services.xserver.autoRepeatDelay = 200;
  services.xserver.autoRepeatInterval = 17;

  # Display & Desktop Environments
  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;
  services.xserver.windowManager.awesome.enable = true;

  # Nix
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Printing
  services.printing.enable = true;

  # Audio (PipeWire)
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # User account
  users.users.ben = {
    isNormalUser = true;
    description = "ben";
    extraGroups = [ "networkmanager" "wheel" "video" ];
    packages = with pkgs; [
      kdePackages.kate
    ];
  };

  # Programs
  programs.firefox.enable = true;
  programs.ssh.startAgent = true;
  nixpkgs.config.allowUnfree = true;

  # System packages (shared across all machines)
  environment.systemPackages = with pkgs; [
    vim
    just
    git
    unstablePkgs.claude-code
    rofi
    zathura
    kitty
    yazi
    direnv
    neofetch
    starship
    brightnessctl
    xclip
    pciutils
    usbutils
    pavucontrol
    wl-clipboard
    stow
    networkmanagerapplet
    discord
    spotify
    copilot-language-server
    flameshot
    libreoffice
    unzip
    p7zip
  ];

  # Fonts
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];

  # {{create edges b{ Kanata (shared keybinds across all machines)

  boot.kernelModules = [ "uinput" ];
  hardware.uinput.enable = true;
  users.groups.uinput = {};

  services.udev.extraRules = ''
    KERNEL=="uinput", MODE="0660", GROUP="uinput", OPTIONS+="static_node=uinput"
  '';

  systemd.services.kanata-internalKeyboard.serviceConfig = {
    SupplementaryGroups = [
      "input"
      "uinput"
    ];
  };

  services.kanata = {
    enable = true;
    keyboards = {
      internalKeyboard = {
        extraDefCfg = "process-unmapped-keys yes";
        config = ''
(defsrc
  grv  1    2    3    4    5    6    7    8    9    0    -    =    bspc
  tab  q    w    e    r    t    y    u    i    o    p    [    ]    \
  caps a    s    d    f    g    h    j    k    l    ;    '    ret
  lsft z    x    c    v    b    n    m    ,    .    /    rsft
  lctl lmet lalt           spc            ralt rmet rctl
)
(deflayer start
  grv  1    2    3    4    5    6    7    8    9    0    -    =    bspc
  tab  q    w    e    r    t    y    u    i    o    p    [    ]    \
  (tap-hold-press 200 200 esc lctl)	a    s    d    f    g    h    j    k    l    ;    '    ret
  lsft z    x    c    v    b    n    m    ,    .    /    lmet
  lctl lmet lalt           spc            ralt rmet rctl
)
        '';
      };
    };
  };

  # }}} Kanata

  # {{{ inputrc

  environment.etc."inputrc" = {
    text = pkgs.lib.mkDefault (pkgs.lib.mkAfter ''
      set editing-mode vi
      set show-mode-in-prompt
      "\e[5~": history-search-backward
      "\e[6~": history-search-forward

      "\e-":
      "\e0":
      "\e1":
      "\e2":
      "\e3":
      "\e4":
      "\e5":
      "\e6":
      "\e7":
      "\e8":
      "\e9":
    '');
  };

  # }}} inputrc

  system.stateVersion = "25.11";
}
