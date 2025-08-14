# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, inputs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      inputs.home-manager.nixosModules.default
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Los_Angeles";

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
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # NVIDIA
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
  hardware.bluetooth.enable = true;
  services.xserver.videoDrivers = ["nvidia"];
  hardware.nvidia = {

    modesetting.enable = true;

    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = false;
    nvidiaSettings = true;

    package = config.boot.kernelPackages.nvidiaPackages.stable;

    prime = { 
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
      intelBusId = "PCI:00:02:0";
      nvidiaBusId = "PCI:01:00:0";
    };

  };

  # Configure console keymap
  console.keyMap = "dvorak";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  services.udev.packages = [
    pkgs.qmk-udev-rules
  ];

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  # services.tlp.enable = true;
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
  services.usbmuxd = {
    enable = true;
    package = pkgs.usbmuxd2;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.wrothmir = {
    isNormalUser = true;
    description = "wrothmir";
    extraGroups = [ "networkmanager" "wheel" "audio"];
    packages = with pkgs; [
    ];
    shell = pkgs.zsh;
  };

  musnix.enable = true;
  home-manager = {
    extraSpecialArgs = {inherit inputs;};
    backupFileExtension = "backup";
    users = {
      "wrothmir" = import ./home.nix;
    };
  };

  # Install firefox.
  programs.firefox.enable = true;
  programs.zsh.enable = true;
  programs.ssh.startAgent = true;

  # Enable Hyprland
  programs.hyprland = {
    enable = false;
    package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  nix.settings = {
    experimental-features = [ "nix-command" "flakes"];
  };


  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  ];

  programs.nix-ld.dev.enable = true;
  programs.appimage = {
    enable = true;
    binfmt = true;
    package = pkgs.appimage-run.override {
      extraPkgs = pkgs: [
        pkgs.fuse
        pkgs.desktop-file-utils
        pkgs.xorg.libXcomposite
        pkgs.xorg.libXtst
        pkgs.xorg.libXrandr
        pkgs.xorg.libXext
        pkgs.xorg.libX11
        pkgs.xorg.libXau
        pkgs.xorg.libXfixes
        pkgs.libGL
        pkgs.gst_all_1.gstreamer
        pkgs.gst_all_1.gst-plugins-ugly
        pkgs.gst_all_1.gst-plugins-base
        pkgs.libdrm
        pkgs.xorg.xkeyboardconfig
        pkgs.xorg.libpciaccess
        pkgs.glib
        pkgs.gtk2
        pkgs.bzip2
        pkgs.zlib
        pkgs.gdk-pixbuf
        pkgs.xorg.libXinerama
        pkgs.xorg.libXdamage
        pkgs.xorg.libXcursor
        pkgs.xorg.libXrender
        pkgs.xorg.libXScrnSaver
        pkgs.xorg.libXxf86vm
        pkgs.xorg.libXi
        pkgs.xorg.libSM
        pkgs.xorg.libICE
        pkgs.freetype
        pkgs.curlWithGnuTls
        pkgs.nspr
        pkgs.nss
        pkgs.fontconfig
        pkgs.cairo
        pkgs.pango
        pkgs.expat
        pkgs.dbus
        pkgs.cups
        pkgs.libcap
        pkgs.SDL2
        pkgs.libusb1
        pkgs.udev
        pkgs.dbus-glib
        pkgs.atk
        pkgs.at-spi2-atk
        pkgs.libudev0-shim
        pkgs.xorg.libXt
        pkgs.xorg.libXmu
        pkgs.xorg.libxcb
        pkgs.xorg.xcbutil
        pkgs.xorg.xcbutilwm
        pkgs.xorg.xcbutilimage
        pkgs.xorg.xcbutilkeysyms
        pkgs.xorg.xcbutilrenderutil
        pkgs.libGLU
        pkgs.libuuid
        pkgs.libogg
        pkgs.libvorbis
        pkgs.SDL
        pkgs.SDL2_image
        pkgs.glew110
        pkgs.openssl
        pkgs.libidn
        pkgs.tbb
        pkgs.wayland
        pkgs.mesa
        pkgs.libxkbcommon
        pkgs.vulkan-loader
        pkgs.flac
        pkgs.freeglut
        pkgs.libjpeg
        pkgs.libpng12
        pkgs.libpulseaudio
        pkgs.libsamplerate
        pkgs.libmikmod
        pkgs.libtheora
        pkgs.libtiff
        pkgs.pixman
        pkgs.speex
        #pkgs.SDL_image
        #pkgs.SDL_ttf
        #pkgs.SDL_mixer
        #pkgs.SDL2_ttf
        #pkgs.SDL2_mixer
        pkgs.libappindicator-gtk2
        pkgs.libcaca
        pkgs.libcanberra
        pkgs.libgcrypt
        pkgs.libvpx
        pkgs.librsvg
        pkgs.xorg.libXft
        pkgs.libvdpau
        pkgs.alsa-lib
        pkgs.harfbuzz
        pkgs.e2fsprogs
        pkgs.libgpg-error
        pkgs.keyutils.lib
        pkgs.libjack2
        pkgs.fribidi
        pkgs.p11-kit
        pkgs.gmp
        pkgs.libtool.lib
        pkgs.xorg.libxshmfence
        pkgs.xorg.libxkbfile
        pkgs.at-spi2-core
        pkgs.gtk3
        pkgs.stdenv.cc.cc.lib
      ];
    };
  };

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.droid-sans-mono
    nerd-fonts.fira-code
    nerd-fonts.monoid
    ipafont
    kochi-substitute
  ];

  fonts.fontconfig.defaultFonts = {
    monospace = [
      "JetBrains Mono"
      "IPAGothic"
    ];
    sansSerif = [
      "JetBrains Mono"
      "IPAPGothic"
    ];
    serif = [
      "JetBrains Mono"
      "IPAPMincho"
    ];
  };

  i18n.inputMethod = {
     type = "fcitx5";
     enable = true;
     fcitx5.addons = with pkgs; [
       fcitx5-mozc
       fcitx5-gtk
       kdePackages.fcitx5-with-addons
     ];
  };

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

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?

}
