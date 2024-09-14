{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "nooodlesoup";
  home.homeDirectory = "/home/nooodlesoup";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "24.05"; # Please read the comment before changing.

  fonts.fontconfig.enable = true;
  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    (pkgs.nerdfonts.override { fonts = [ "Monoid" ]; })

    alacritty
    zellij
    bat
    btop
    nushell
    starship
    wofi
    brightnessctl

    floorp
    discord

    python3
    ocaml
    opam
    dune_3
    gcc
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
  #  /etc/profiles/per-user/nooodlesoup/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    # EDITOR = "neovim";
    TERMINAL = "alacritty";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  programs.git = {
    enable = true;
    userEmail = "vineetagarwal2402@gmail.com";
    userName = "Vineet Agarwal";
  };

  programs.waybar = {
    enable = true;
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    vimAlias = true;
  };

  programs.zsh = {
    enable = true;
  };

  programs.alacritty = {
    enable = true;
    settings = {
      window = {
        decorations = "None";
        opacity = 1;
        startup_mode = "Maximized";
        padding = { x = 10; y = 4; };
      };

      font = {
        size = 12;
        normal = {
	  family = "Monoid";
	  style = "Regular";
	};
      };

      selection = {
        save_to_clipboard = true;
      };

    };
  };
}
