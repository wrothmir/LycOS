{ config, pkgs, ... }:

{
  home.file = {
    ".config/ghostty/" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/LycOS/dotfiles/ghostty";
      recursive = true;
    };
  };
}
