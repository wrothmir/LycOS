{ config, ... }:

{
  home.file = {
    ".config/eww" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/PyrOS/modules/eww/config-eww/";
      recursive = true;
    };
  };
}
