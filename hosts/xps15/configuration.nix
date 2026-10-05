{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  networking.hostName = "xps15";

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

  # {{{ Bluetooth

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };
  services.blueman.enable = true;

  # }}} Bluetooth

  # {{{ Bootloader (GRUB with OS-prober for dual-boot)

  boot.supportedFilesystems = [ "ntfs" ];
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "nodev";
  boot.loader.grub.useOSProber = true;
  boot.loader.grub.efiSupport = true;
  boot.loader.efi.efiSysMountPoint = "/boot";

  # }}} Bootloader

  # {{{ NVIDIA dGPU (GTX 1050 Ti) — the HDMI port is wired through it

  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.graphics.enable = true;
  hardware.nvidia = {
    modesetting.enable = true;
    # Runtime power management: lets the dGPU power fully OFF when no offloaded
    # app is using it. True fine-grained RTD3 is Turing+; the Pascal 1050 Ti
    # uses coarse-grained runtime PM (whole-GPU power-off), which this enables.
    powerManagement.enable = true;
    open = false; # GTX 1050 Ti (Pascal) needs the closed kernel module
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    prime = {
      # Offload mode: apps default to the Intel iGPU (big battery win vs sync,
      # which kept the dGPU powered on 24/7). Launch GPU apps with `nvidia-offload`.
      # NOTE: HDMI is wired through the dGPU — external output may require running
      # the compositor/app with nvidia-offload, or waking the dGPU first.
      offload = {
        enable = true;
        enableOffloadCmd = true; # provides the `nvidia-offload` wrapper script
      };
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };

  # }}} NVIDIA dGPU

  # Trackpad acceleration
  services.libinput.touchpad.accelSpeed = "0.3";

  # Kanata: target the laptop's built-in keyboard and the external Das Keyboard
  services.kanata.keyboards.internalKeyboard.devices = [
    "/dev/input/by-path/platform-i8042-serio-0-event-kbd"
    "/dev/input/by-id/usb-_Das_Keyboard-event-kbd"
  ];

  # {{{ Thermal + power management

  # Intel thermal daemon: actively manages CPU thermals so the package doesn't
  # sit pinned at ~97 °C and throttle (which felt like sluggishness + fan spin).
  services.thermald.enable = true;

  # }}} Thermal + power management

  # xps15-specific packages
  environment.systemPackages = with pkgs; [
    brave
    kdePackages.dolphin

    # Performance / power monitoring (see notes below)
    powertop            # per-device power draw + battery estimate
    btop                # live CPU/mem/process TUI (spot runaway procs)
    lm_sensors          # `sensors` — CPU/package temps + fan speeds
    # GPU monitoring: use `nvidia-smi` (ships with the driver). nvtop pulls the
    # full CUDA toolkit here, which isn't in the binary cache, so it's omitted.
  ];
}
