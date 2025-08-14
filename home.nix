{ config, pkgs, pkgs-stable, ghostty, ... }:

{
  imports = [
    #./modules/waybar.nix
    #./modules/hyprland/hyprland.nix
    #./modules/zellij.nix
    #./modules/mako.nix
    ./modules/alacritty/alacritty.nix
    ./modules/neovim.nix
    ./modules/rofi.nix
    ./modules/nh.nix
    ./modules/git.nix
    ./modules/eww.nix
    ./modules/tmux.nix
    ./modules/sound/sound.nix
    ./modules/fmodstudio/fmodstudio.nix
  ];
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "wrothmir";
  home.homeDirectory = "/home/wrothmir";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "25.11"; # Please read the comment before changing.

  fonts.fontconfig.enable = true;
  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = [

    pkgs.git
    pkgs.git-lfs
    pkgs.diff-so-fancy
    pkgs.tmux
    pkgs.bat
    pkgs.wofi
    pkgs.libnotify
    pkgs.brightnessctl
    pkgs.playerctl
    pkgs.wl-clipboard
    pkgs.tre-command
    pkgs.lshw
    pkgs.nh
    pkgs.alsa-utils
    pkgs.wlsunset
    pkgs.wl-gammarelay-rs
    pkgs.networkmanagerapplet
    pkgs.libimobiledevice
    pkgs.ifuse
    pkgs.exfat
    pkgs.ntfs3g

    pkgs.thunderbird
    pkgs.librewolf
    pkgs.steam
    pkgs.discord

    pkgs.steam-run

    pkgs.android-studio
    pkgs.brave
    pkgs.blender

    pkgs.distrobox
    pkgs.lilipod

    #pkgs.onlyoffice-bin
    pkgs.libreoffice-qt6-fresh
    pkgs.qbittorrent

    pkgs.gimp
    pkgs.krita
    pkgs.drawio
    #pkgs.davinci-resolve
    pkgs.fmodex
    pkgs.penpot-desktop
    pkgs.aseprite
    pkgs.ldtk
    pkgs.tiled

    pkgs.qmk
    pkgs.vlc

    pkgs.tmuxinator
    pkgs.ghostty
    pkgs.anki-bin
    pkgs.mplayer

    pkgs.testdisk-qt
    #pkgs.hypridle
    #pkgs.hyprlock
  ];

  nixpkgs.config.allowUnfree = true;

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/raikan/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    # EDITOR = "neovim";
    TERM = "ghostty";
    SAL_USE_VCLPLUGIN = "kf5";
  };

  home.shellAliases = {
    tx = "tmuxinator";
    txs = "tmuxinator start";
    rbs = "sudo nixos-rebuild switch --flake ~/LycOS";
    nd = "nix develop";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  programs.gitui = {
    enable = true;
  };

  programs.fzf = {
    tmux = {
      enableShellIntegration = true;
    };
  };
  
  programs.zsh = {
    enable = true;
  };

  programs.starship = {
    enable = true;
    settings = {
      scan_timeout = 10;
      command_timeout = 200;
    };
    enableBashIntegration = true;
    enableZshIntegration = true;
  };

  programs.btop = {
    enable = true;
  };

  programs.eza = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    icons = "always";
  };

  programs.hyprlock = {
    enable = false;
  };

  programs.ripgrep = {
    enable = true;
  };

  programs.jq = {
    enable = true;
  };

}
