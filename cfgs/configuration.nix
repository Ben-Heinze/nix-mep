# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  # boot.loader.systemd-boot.enable = true;
  # boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

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

  # Enable the X11 windowing system.
      services={
        xserver = {
            enable = true; # disable if youre only using Wayland session
            dpi = 192; # 2x scaling for 4K display, gives ~1080p logical resolution
            windowManager.awesome = {
                enable = true;
                luaModules = with pkgs.luaPackages; [
                    luarocks # is the package manager for Lua modules
                    luadbi-mysql # Database abstraction layer
                    awesome-wm-widgets # Community collection of widgets
                ];

            };
        };

        displayManager = {
            sddm.enable = true;
            defaultSession = "none+awesome";
        };
    };

  # Enable the KDE Plasma Desktop Environment.
  services.desktopManager.plasma6.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # experimental features

  services.xserver.displayManager.sessionCommands = ''
    xset r rate 200 60
    xrdb -merge <<EOF
    Xft.dpi: 192
    EOF
    # if xmodmap -pm | grep -q "Caps_Lock"; then
    # 	xmodmap -e 'remove lock = Caps_Lock'
    # fi
    # xmodmap -e 'keycode 66 = Control_L'
    # xcape -t 200 -e 'Control_L=Escape'
  '';



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
  users.users.ben = {
    isNormalUser = true;
    description = "ben";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      kdePackages.kate
    #  thunderbird
    ];
  };

  # Install firefox.
  programs.firefox.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  just 
  git
  claude-code
  awesome
  kanata
  rofi
  zathura
  kitty
  direnv
  neofetch
  starship
  #  wget
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

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
  (tap-hold-press 200 200 esc lctl)	a    s    d    f    g    h    j    k    l    ;    '    ret
  lsft z    x    c    v    b    n    m    ,    .    /    lmet
  lctl lmet lalt           spc            ralt rmet rctl
)
        '';
      };
    };
  };

  # }}} kanata



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

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?

}
