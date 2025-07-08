{ config, pkgs, ... }:

{
  home.file = {
    ".config/ghostty/" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/LycOS/modules/ghostty/config-ghostty";
      recursive = true;
    };
  };
}
