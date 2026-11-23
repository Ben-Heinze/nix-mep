{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  networking.hostName = "miniPC";

  # Awesome WM as default session with extra lua modules
  services.xserver.windowManager.awesome.luaModules = with pkgs.luaPackages; [
    luarocks
    luadbi-mysql
    awesome-wm-widgets
  ];
  services.displayManager.defaultSession = "none+awesome";

  # Keyboard layout
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # {{{ Bluetooth

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };
  services.blueman.enable = true;

  # }}} Bluetooth

  # {{{ Bootloader (systemd-boot — single-boot NixOS on this machine)

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot";

  # }}} Bootloader

  # {{{ AMD Radeon Vega iGPU (Ryzen 5 3550H APU)

  # amdgpu handles the integrated Vega graphics; no discrete GPU on this box.
  services.xserver.videoDrivers = [ "amdgpu" ];
  hardware.graphics.enable = true;

  # }}} AMD GPU

  # Kanata: target the external Das Keyboard (no built-in keyboard on this mini PC)
  services.kanata.keyboards.internalKeyboard.devices = [
    "/dev/input/by-id/usb-_Das_Keyboard-event-kbd"
  ];

  # miniPC-specific packages
  environment.systemPackages = with pkgs; [
    brave
    kdePackages.dolphin

    # Performance / monitoring
    btop                # live CPU/mem/process TUI (spot runaway procs)
    lm_sensors          # `sensors` — CPU/package temps + fan speeds
    # GPU monitoring: `amdgpu_top` or `radeontop` for the integrated Vega.
  ];
}
