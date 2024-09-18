{ config, pkgs, ... }:

{
  home.file = {
    ".config/hypr" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/LycOS/modules/hyprland/config-hyprland";
      recursive = true;
    };
  };
}
