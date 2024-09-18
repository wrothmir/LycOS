
{ config, pkgs, ...}:

{
  programs.zellij = {
    enable = true;
  };

  home.file = {
    ".config/zellij" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/LycOS/modules/zellij/config-zellij";
      recursive = true;
    };
  };
}
