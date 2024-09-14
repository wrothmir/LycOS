{ config, pkgs, ... }:

{
  programs.rofi = {
    enable = true;
  };

  home.file = {
    ".config/rofi" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/PyrOS/modules/rofi/config-rofi";
      recursive = true;
    };
  };
}
