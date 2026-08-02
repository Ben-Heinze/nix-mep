{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  networking.hostName = "surfacepro";

  # 4K display scaling
  services.xserver.dpi = 192;

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

  # Session commands for 4K DPI
  services.xserver.displayManager.sessionCommands = ''
    xrdb -merge <<EOF
    Xft.dpi: 192
    EOF
  '';

  # {{{ Bootloader (GRUB with OS-prober for dual-boot)

  boot.supportedFilesystems = [ "ntfs" ];
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "nodev";
  boot.loader.grub.useOSProber = true;
  boot.loader.grub.efiSupport = true;
  boot.loader.efi.efiSysMountPoint = "/boot";

  # }}} Bootloader

  # Trackpad acceleration
  services.libinput.touchpad.accelSpeed = "0.3";

  # Kanata: target the laptop's built-in keyboard
  services.kanata.keyboards.internalKeyboard.devices = [
    "/dev/input/by-path/pci-0000:00:14.0-usb-0:9:1.0-event-kbd"
  ];
}
