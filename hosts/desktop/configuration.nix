{ config, pkgs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  networking.hostName = "desktop";

  # Keyboard layout (right shift -> super key)
  services.xserver.xkb = {
    layout = "us-custom";
    variant = "";
    extraLayouts = {
      us-custom = {
        description = "US layout with Right Shift as Meta";
        languages = [ "eng" ];
        symbolsFile = pkgs.writeText "us-custom" ''
          xkb_symbols "basic" {
            include "us"
            include "pc"
            key <RTSH> { [ Super_R, Super_R ] };
            modifier_map Mod4 { <RTSH> };
          };
        '';
      };
    };
  };

  # {{{ Bootloader (systemd-boot)

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # }}} Bootloader

  # {{{ AMD GPU

  services.xserver.videoDrivers = [ "amdgpu" ];
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
  hardware.enableRedistributableFirmware = true;

  # }}} AMD GPU

  # {{{ Bluetooth

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        Experimental = true;
        ControllerMode = "bredr";
        EnableLE = false;
        Enable = "Source,Sink,Media,Socket";
        FastConnectable = true;
        JustWorksRepairing = "always";
        SecureConnections = "false";
        Privacy = "device";
      };
    };
  };
  services.blueman.enable = true;
  boot.kernelParams = [ "bluetooth.disable_ertm=Y" ];

  # }}} Bluetooth

  # {{{ Steam & Gaming

  hardware.steam-hardware.enable = true;
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = false;
    localNetworkGameTransfers.openFirewall = true;
  };

  # PlayStation controller support
  boot.kernelModules = [ "hid_playstation" "joydev" ];
  services.udev.extraRules = ''
    SUBSYSTEM=="usb", ATTRS{idVendor}=="054c", ATTRS{idProduct}=="05c4", MODE="0660", TAG+="uaccess"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="054c", ATTRS{idProduct}=="09cc", MODE="0660", TAG+="uaccess"
  '';

  # }}} Steam & Gaming

  # Input remapper
  services.input-remapper.enable = true;

  # Kanata: no device filter = grabs all keyboards (fine for single-keyboard desktop)
  # To target a specific keyboard, run: ls /dev/input/by-id/
  # services.kanata.keyboards.internalKeyboard.devices = [
  #   "/dev/input/by-id/your-keyboard-here"
  # ];

  # Desktop-specific packages
  environment.systemPackages = with pkgs; [
    neovim-unwrapped
    blueman
    bluez
    bluez-tools
    alacritty
    pasystray
    xorg.xmodmap
    xorg.xev
  ];
}
