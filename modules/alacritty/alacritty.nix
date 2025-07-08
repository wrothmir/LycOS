{ config, pkgs, ... }:

let
  gruvbox_light = {
    primary = {
      # hard contrast background = = "#f9f5d7"
      background = "#fbf1c7";
      # soft contrast background = = "#f2e5bc"
      foreground = "#3c3836";
    };

    # Normal colors
    normal = {
      black = "#fbf1c7";
      red = "#cc241d";
      green = "#98971a";
      yellow = "#d79921";
      blue = "#458588";
      magenta = "#b16286";
      cyan = "#689d6a";
      white = "#7c6f64";
    };

    # Bright colors
    bright = {
      black = "#928374";
      red = "#9d0006";
      green = "#79740e";
      yellow = "#b57614";
      blue = "#076678";
      magenta = "#8f3f71";
      cyan = "#427b58";
      white = "#3c3836";
    };

  };
  gruvbox_dark = {

    primary = {
      background = "#282828";
      foreground = "#ebdbb2";
    };

    normal = {
      black   = "#282828";
      red     = "#cc241d";
      green   = "#98971a";
      yellow  = "#d79921";
      blue    = "#458588";
      magenta = "#b16286";
      cyan    = "#689d6a";
      white   = "#a89984";
    };

    bright = {
      black   = "#928374";
      red     = "#fb4934";
      green   = "#b8bb26";
      yellow  = "#fabd2f";
      blue    = "#83a598";
      magenta = "#d3869b";
      cyan    = "#8ec07c";
      white   = "#ebdbb2";
    };
  };
  ayu_dark = {
# Colors (Ayu Dark)

# Default colors
    primary = {
      background = "#0A0E14";
      foreground = "#B3B1AD";
    };

# Normal colors
    normal = {
      black   = "#01060E";
      red     = "#EA6C73";
      green   = "#91B362";
      yellow  = "#F9AF4F";
      blue    = "#53BDFA";
      magenta = "#FAE994";
      cyan    = "#90E1C6";
      white   = "#C7C7C7";
    };

# Bright colors
    bright = {
      black   = "#686868";
      red     = "#F07178";
      green   = "#C2D94C";
      yellow  = "#FFB454";
      blue    = "#59C2FF";
      magenta = "#FFEE99";
      cyan    = "#95E6CB";
      white   = "#FFFFFF";
    };
  };
in
{
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
          family = "JetBrainsMono Nerd Font";
          style = "Regular";
        };
      };

      selection = {
        save_to_clipboard = true;
      };

      colors = gruvbox_dark;
    };
  };

  home.file = {
    ".config/alacritty/themes/" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/LycOS/modules/alacritty/themes";
      recursive = true;
    };
  };
}
