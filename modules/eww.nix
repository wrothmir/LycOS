{ config, ... }:

{
  home.file = {
    ".config/eww" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/LycOS/dotfiles/eww/";
      recursive = true;
    };
  };
}
