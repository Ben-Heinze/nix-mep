# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, unstablePkgs, ... }:
let

  # {{{ wikiman
  wikiman = pkgs.fetchFromGitHub {
    owner = "filiparag";
    repo = "wikiman";
    rev = "dba1b2c";
    sha256 = "sha256-EvYMUHKFJhSFyoW85EEzI7q5OMGGe9c+A2JlkAoxt3o=";
  };
  # }}} wikiman

in

{

  # {{{ imports
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # }}} imports

  # {{{ Boot loader

  boot.supportedFilesystems = [ "ntfs" ];
  # Bootloader.
  boot.loader.efi.canTouchEfiVariables = true;
  # boot.loader.systemd-boot.enable = true;
  # boot.loader.systemd-boot.enable = false;
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "nodev";
  boot.loader.grub.useOSProber = true;
  boot.loader.grub.efiSupport = true;
  boot.loader.efi.efiSysMountPoint = "/boot";
  boot.loader.systemd-boot.configurationLimit = 10; # only 10 generations are kept

  # }}} Boot loader

  # {{{ Basic config
  networking.hostName = "euler"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  hardware.graphics.enable = true;
  # services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia.open = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Denver";

  # Select internationalisation properties.
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

  # TODO: hardware?
  hardware.bluetooth.enable = true;

  # }}} Basic config

  # {{{ services


  # Enable the X11 windowing system.
  # You can disable this if you're only using the Wayland session.
  services.xserver.enable = true;
  services.xserver.windowManager.i3.enable = true;
  services.xserver.videoDrivers = [ "nvidia" "amdgpu" ];

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.

  # }}} services

  # {{{ kanata

  boot.kernelModules = [ "uinput" ];

  # Enable uinput
  hardware.uinput.enable = true;

  # Set up udev rules for uinput
  services.udev.extraRules = ''
    KERNEL=="uinput", MODE="0660", GROUP="uinput", OPTIONS+="static_node=uinput"
  '';

  # Ensure the uinput group exists
  users.groups.uinput = {  };

 # Add the Kanata service user to necessary groups
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
        devices = [
          # Replace the paths below with the appropriate device paths for your setup.
          # Use `ls /dev/input/by-path/` to find your keyboard devices.
          "/dev/input/by-path/platform-i8042-serio-0-event-kbd"
          "/dev/input/by-id/usb-Microsoft_Natural®_Ergonomic_Keyboard_4000-event-kbd"
          # "/dev/input/by-path/pci-0000:00:14.0-usb-0:3:1.0-event-kbd"
        ];
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
  (tap-hold 100 100 esc lctl)	a    s    d    f    g    h    j    k    l    ;    '    ret
  lsft z    x    c    v    b    n    m    ,    .    /    rsft
  lctl lmet lalt           spc            ralt rmet rctl
)
        '';
      };
    };
  };

  # }}} kanata

  # {{{ users
  users.users.root = {
    password = "1234";
    extraGroups = [ "input" "uinput" ];
  };


  users.users.jordan = {
    isNormalUser = true;
    description = "jordan";
    extraGroups = [ "networkmanager" "wheel" "input" "uinput" ];
    packages = with pkgs; [
      kdePackages.kate
    #  thunderbird
    ];
    password = "1234";
  };


  users.users.test = {
    isNormalUser = true;
    description = "test";
    extraGroups = [ "networkmanager" "wheel" "input" "uinput" ];
    packages = with pkgs; [
      kdePackages.kate
    #  thunderbird
    ];
    password = "1234";
  };

  # }}} users

  # {{{ programs

  # Install firefox.
  programs.firefox.enable = true;

  # Allow unfree packages
  # nixpkgs.config.allowUnfree = true;

  # Enable Sway.
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
  };

  programs.niri.enable = true;
  programs.hyprland.enable = true; # enable Hyprland
    # programs.noctalia-shell = {
    #   enable = true;
    #   settings = {
    #     # configure options
    #   };
    # };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [

    fuzzel
    direnv
    just
    linuxquota
    unixtools.quota
    git
    htop
    inkscape
    kdePackages.krohnkite
    kitty
    libreoffice
    libxml2
    neovim
    networkmanagerapplet
    overskride
    pywal
    retroarch
    rofi
    rxvt-unicode
    starship
    unzip
    vim
    vscode
    wget
    xclip
    zathura
    neofetch
    kanata
    gh
    awesome
    i3
    xorg.xclock
    xorg.xev
    xorg.xhost
    xorg.xkbcomp
    xorg.xmodmap

    (pkgs.stdenv.mkDerivation {
      name = "wikiman";
      src = wikiman;
      buildInputs = [
        pkgs.autoconf
        pkgs.automake
        pkgs.gnumake
        pkgs.bison
        pkgs.libtool
        pkgs.pcre2
      ];
      buildPhase = ''
        make all
      '';
      installPhase = ''
        mkdir -p $out/bin
        cp pkgbuild/usr/bin/* $out/bin/
      '';
    })

    (
      pkgs.stdenv.mkDerivation {
        pname = "fzf";
        version = "0.65.2";
        src = pkgs.fetchurl {
          url = "https://github.com/junegunn/fzf/releases/download/v0.65.2/fzf-0.65.2-linux_amd64.tar.gz";
          sha256 = "5eb8efc0e94aa559f84ea83eeba99bea7dce818e63f92b4b62e60663220f1c14";
        };

        buildInputs = [
          pkgs.curl
        ];

        installPhase = ''
          # Create the bin directory
          mkdir -p $out/bin

          # Extract the FZF binary
          tar -xzf $src
          mv fzf $out/bin/
          chmod +x $out/bin/fzf

          # pull in text
          # # Make the additional scripts executable
          # chmod +x $out/bin/fzf-tmux
          # chmod +x $out/bin/fzf-preview.sh

        '';

        # Prevent unpackPhase from executing
        unpackPhase = "true";
      }
    )
    waybar
    quickshell
  ] ++ [
    unstablePkgs.noctalia-shell
    unstablePkgs.dms-shell
    unstablePkgs.jetbrains.idea
  ];

  # }}} programs

  # {{{ Display Manager


  services.xserver.displayManager.session = [
    {
      manage = "window";
      name = "awesomerzz";
      start = ''
        exec awesome
      '';
    }
    {
      manage = "window";
      name = "mwmzz"; # Adjust the name for the new session
      start = ''
        exec mwm
      '';
    }
    {
      manage = "window";
      name = "i3zz"; # Adjust the name for the new session
      start = ''
        exec i3
      '';
    }
  ];

  # Enable the KDE Plasma Desktop Environment.
  # services.displayManager.sddm.enable = true;
  # services.displayManager.sddm.wayland.enable = true;
  # services.desktopManager.plasma6.enable = true;

#  services.displayManager = {
#    sddm.enable = true;
#    defaultSession = "none+awesomerzz";
#  };

# services.xserver.displayManager.lightdm = {
#   enable = true;
#   # Setting gtk as the greeter
#   greeters.gtk.enable = true;
#   # Example of having background as a particular color
#   background = "#ffa07a";
#   # Example of the default image background (must be an absolute path)
#   #background = pkgs.nixos-artwork.wallpapers.simple-dark-gray-bottom.gnomeFilePath;
# };

services.xserver.displayManager.gdm = {
  enable = true;
};


  services.xserver.displayManager.sessionCommands = ''
    xset r rate 200 60
    # if xmodmap -pm | grep -q "Caps_Lock"; then
    # 	xmodmap -e 'remove lock = Caps_Lock'
    # fi
    # xmodmap -e 'keycode 66 = Control_L'
    # xcape -t 200 -e 'Control_L=Escape'
  '';

  # }}} Display Manager

  # {{{ Font

  fonts.packages = with pkgs; [
    nerd-fonts._0xproto
    nerd-fonts.droid-sans-mono
    nerd-fonts.ubuntu-mono
    # nerdfonts
  ];

  # }}} Font

  # {{{ inputrc

  environment.etc."inputrc" = {
    text = pkgs.lib.mkDefault (pkgs.lib.mkAfter ''
      #  alternate mappings for "page up" and "page down" to search the history
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




      # bind -p | grep '"\\e1"'
      # bind -r '\e1'
      # bind -r '\e2'
      # bind -r '\e3'
      # bind -r '\e4'
      # bind -r '\e5'
      # bind -r '\e6'
      # bind -r '\e7'
      # bind -r '\e8'
    '');
  };

  # }}} inputrc

  # {{{ virtual keyboard
  # services.kmonad = {
  #   enable = true;
  #   keyboards = {
  #     myKMonadOutput = {
  #       device = "/dev/input/by-path/platform-i8042-serio-0-event-kbd";
  #       config = builtins.readFile /etc/nixos/config.kbd;
  #     };
  #   };
  # };
  # }}} virtual keyboard

  # {{{ steam

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  };

  # }}} steam

  # {{{ comments
  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # }}} comments

  # {{{ stateVersion
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?
  # }}} stateVersion

}
