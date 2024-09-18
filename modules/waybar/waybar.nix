{ config, pkgs, ...}:

{
  programs.waybar = {
    enable = true;
  };

  home.file = {
    ".config/waybar/" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/LycOS/modules/waybar/config-waybar";
      recursive = true;
    };
  };
}
