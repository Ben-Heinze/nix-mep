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

  # {{{ Bootloader (lanzaboote for Secure Boot dual-boot)
  # Valorant's Vanguard anti-cheat requires Secure Boot enabled in Windows.
  # GRUB is unsigned, so Secure Boot had to stay off. Lanzaboote signs the
  # NixOS bootloader + kernel with our own keys (managed by sbctl) so both
  # OSes boot with Secure Boot on. Enroll keys with `sbctl enroll-keys
  # --microsoft` — Microsoft's certs must stay so Windows and the GPU
  # option ROM still verify.
  #
  # Windows lives on a separate disk (sdb1 EFI) from NixOS (nvme0n1p2 EFI),
  # so systemd-boot's menu can't list it. To boot Windows: run
  # `reboot-to-windows`, or use the firmware boot menu key at power-on.

  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot";
  boot.loader.systemd-boot.enable = lib.mkForce false; # lanzaboote replaces it
  boot.loader.timeout = 10; # seconds the menu stays up before booting NixOS
  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/var/lib/sbctl";
  };

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
    prismlauncher
    sbctl # Secure Boot key management for lanzaboote
    efibootmgr
    (writeShellScriptBin "reboot-to-windows" ''
      set -euo pipefail
      entry=$(${efibootmgr}/bin/efibootmgr | grep -i "Windows Boot Manager" | head -n1 | sed 's/^Boot\([0-9A-Fa-f]\{4\}\).*/\1/')
      if [ -z "$entry" ]; then
        echo "No 'Windows Boot Manager' entry found in efibootmgr output" >&2
        exit 1
      fi
      sudo ${efibootmgr}/bin/efibootmgr --bootnext "$entry" > /dev/null
      systemctl reboot
    '')
  ];
}
