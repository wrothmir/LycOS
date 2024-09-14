
{ config, pkgs, ...}:

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

    };
  };

  home.file = {
    ".config/alacritty/themes/" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/PyrOS/modules/alacritty/themes";
      recursive = true;
    };
  };
}
