{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  networking.hostName = "laptop";

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

  # Session commands for 4K DPI and key repeat
  services.xserver.displayManager.sessionCommands = ''
    xset r rate 200 60
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

  # Kanata: target the laptop's built-in keyboard
  services.kanata.keyboards.internalKeyboard.devices = [
    "/dev/input/by-path/platform-i8042-serio-0-event-kbd"
  ];
}
