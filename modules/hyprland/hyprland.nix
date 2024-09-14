{ config, pkgs, ... }:

{
  home.file = {
    ".config/hypr" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/PyrOS/modules/hyprland/config-hyprland";
      recursive = true;
  };
}
