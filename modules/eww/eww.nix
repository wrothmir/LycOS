{ config, ... }:

{
  programs.eww = {
    enable = true;
  };

  home.file = {
    ".config/eww/eww" = { 
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/PyrOS/modules/eww/config-eww"; 
      recursive = true;
    };
  };
}
