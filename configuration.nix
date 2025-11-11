{ config, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  # boot.loader = {
  #   systemd-boot.enable = true;
  #   efi.canTouchEfiVariables = true;
  # };

  boot.loader = {
    efi.canTouchEfiVariables = true;
    grub = {
      enable = true;
      devices = [ "nodev" ];
      efiSupport = true;
      useOSProber = false; # true = find Windows
    };
  };

  # networking.hostName = "nixos"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  # networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.
  networking.wireless = {
    enable = true;
    userControlled.enable = true;

    networks = {
      "Granny Juju 2.0" = {
        pskRaw = "043e02184fb292a0f3eb60604cceeba411d75100d567ab2a8e50aaf80d23526d";
	priority = 500;
      };

      "VIRUS1" = {
        pskRaw = "3606d96d56dc88de86d572c92ebd5a6591cf6a5398e8343f15c33761f651b83c";
	priority = 501;
      };
    };

    extraConfig = ''
      ctrl_interface=/run/wpa_supplicant
      ctrl_interface_group=wheel
    '';
  };

  # Set your time zone.
  time.timeZone = "America/Bahia";

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  #services.xserver.displayManager.lightdm = {
  #  enable = true;
  #  greeters = {
  #    slick.enable = true;
  #  };
  #};

  services.displayManager = lib.mkForce {
    sddm = {
      enable = true;
      wayland.enable = true;
    };

    autoLogin = {
      enable = true;
      user = "naum";
    };
  };

  # Enable Hyprland
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  # Nvidia kernel modules
  hardware.graphics.enable = true;
  #services.xserver.videoDrivers = [ "nvidia" ];
  #hardware.nvidia = {
  #  # Modesetting is required.
  #  modesetting.enable = true;

  #  # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
  #  # Enable this if you have graphical corruption issues or application crashes after waking
  #  # up from sleep. This fixes it by saving the entire VRAM memory to /tmp/ instead 
  #  # of just the bare essentials.
  #  powerManagement.enable = false;

  #  # Fine-grained power management. Turns off GPU when not in use.
  #  # Experimental and only works on modern Nvidia GPUs (Turing or newer).
  #  powerManagement.finegrained = false;

  #  # Use the NVidia open source kernel module (not to be confused with the
  #  # independent third-party "nouveau" open source driver).
  #  # Support is limited to the Turing and later architectures. Full list of 
  #  # supported GPUs is at: 
  #  # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus 
  #  # Only available from driver 515.43.04+
  #  open = false;

  #  # Enable the Nvidia settings menu,
  #  # accessible via `nvidia-settings`.
  #  nvidiaSettings = true;

  #  # Optionally, you may need to select the appropriate driver version for your specific GPU.
  #  package = config.boot.kernelPackages.nvidiaPackages.stable;
  #};

  # Hint Electron apps to use wayland
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
  
  # Configure keymap in X11
  services.xserver.xkb.layout = "us";

  # Configure audio
  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  # Configure bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        # Shows battery charge of connected devices on supported
        # Bluetooth adapters. Defaults to 'false'.
        Experimental = true;
        # When enabled other devices can connect faster to us, however
        # the tradeoff is increased power consumption. Defaults to
        # 'false'.
        FastConnectable = false;
      };
      Policy = {
        # Enable all controllers when they are found. This includes
        # adapters present on start as well as adapters that are plugged
        # in later on. Defaults to 'true'.
        AutoEnable = true;
	    };	
    };
  };

  services.blueman.enable = true;

  # Define a user account
  users.users.naum = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    shell = pkgs.nushell;
  };

  nix.settings.allowed-users = [ "naum" ];

  # Change default shell
  users.defaultUserShell = pkgs.nushell;

  # git
  programs.git.enable = true;

  # Enable Steam
  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "steam"
      "steam-original"
      "steam-unwrapped"
      "steam-run"
    ];

  programs.steam = {
    enable = true;
    #remotePlay.openFirewall = true;
    #dedicatedServer.openFirewall = true;
    #localNetworkGameTransfer.openFirewall = true;
  };

  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
  environment.systemPackages = with pkgs; [
    neovim
    wget
    git
    clang
    ripgrep
    telegram-desktop
    vesktop # discord
    brave # browser
    pavucontrol # pulseaudio/pipewire volume control
    playerctl # music control

    kitty # terminal
    wl-clipboard # wl-copy + wl-paste

    # Hyperland config

    hyprpaper # wallpaper manager
    waybar # status bar. alternatively, more options, DIY: eww
    dunst # notification manager
    libnotify # dep for dunst
    rofi-wayland # app launcher
    papirus-icon-theme # icons
  ];

  # Desktop portals
  #xdg.portal.enable = true;
  #xdg.portal.extraPortals = [ ];

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Rules to allow KeyboardIO Model 100 to be accessed via Kaleidoscope/Chrysalis
  services.udev.extraRules = ''
  SUBSYSTEMS=="usb", ATTRS{idVendor}=="1209", ATTRS{idProduct}=="2303", SYMLINK+="Atreus",  ENV{ID_MM_DEVICE_IGNORE}="1", ENV{ID_MM_CANDIDATE}="0", TAG+="uaccess", TAG+="seat"
  SUBSYSTEMS=="usb", ATTRS{idVendor}=="1209", ATTRS{idProduct}=="2302", SYMLINK+="Atreus",  ENV{ID_MM_DEVICE_IGNORE}="1", ENV{ID_MM_CANDIDATE}="0", TAG+="uaccess", TAG+="seat"
  SUBSYSTEMS=="usb", ATTRS{idVendor}=="1209", ATTRS{idProduct}=="2301", SYMLINK+="Model01",  ENV{ID_MM_DEVICE_IGNORE}="1", ENV{ID_MM_CANDIDATE}="0", TAG+="uaccess", TAG+="seat"
  SUBSYSTEMS=="usb", ATTRS{idVendor}=="1209", ATTRS{idProduct}=="2300", SYMLINK+="Model01",  ENV{ID_MM_DEVICE_IGNORE}="1", ENV{ID_MM_CANDIDATE}="0", TAG+="uaccess", TAG+="seat"
  SUBSYSTEMS=="usb", ATTRS{idVendor}=="3496", ATTRS{idProduct}=="0006", SYMLINK+="Model100",  ENV{ID_MM_DEVICE_IGNORE}="1", ENV{ID_MM_CANDIDATE}="0", TAG+="uaccess", TAG+="seat"
  SUBSYSTEMS=="usb", ATTRS{idVendor}=="3496", ATTRS{idProduct}=="0005", SYMLINK+="Model100",  ENV{ID_MM_DEVICE_IGNORE}="1", ENV{ID_MM_CANDIDATE}="0", TAG+="uaccess", TAG+="seat"
  SUBSYSTEMS=="usb", ATTRS{idVendor}=="3496", ATTRS{idProduct}=="00a1", SYMLINK+="Preonic",  ENV{ID_MM_DEVICE_IGNORE}="1", ENV{ID_MM_CANDIDATE}="0", TAG+="uaccess", TAG+="seat"
  SUBSYSTEMS=="usb", ATTRS{idVendor}=="3496", ATTRS{idProduct}=="00a3", SYMLINK+="Preonic",  ENV{ID_MM_DEVICE_IGNORE}="1", ENV{ID_MM_CANDIDATE}="0", TAG+="uaccess", TAG+="seat"
  SUBSYSTEMS=="usb", ATTRS{idVendor}=="3496", ATTRS{idProduct}=="00a0", SYMLINK+="Preonic",  ENV{ID_MM_DEVICE_IGNORE}="1", ENV{ID_MM_CANDIDATE}="0", TAG+="uaccess", TAG+="seat"
  SUBSYSTEMS=="usb", ATTRS{idVendor}=="3496", ATTRS{idProduct}=="00a3", SYMLINK+="Preonic",  ENV{ID_MM_DEVICE_IGNORE}="1", ENV{ID_MM_CANDIDATE}="0", TAG+="uaccess", TAG+="seat"
  '';

  # Fonts
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];

  # Enable experimental features
  nix.settings.experimental-features = [ "nix-command" ];

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  #system.copySystemConfiguration = true;

  # Do not touch
  system.stateVersion = "25.05"; # Did you read the comment?
}
