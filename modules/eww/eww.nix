{ config, ... }:

{
  home.file = {
    ".config/eww" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/LycOS/modules/eww/config-eww/";
      recursive = true;
    };
  };
}
