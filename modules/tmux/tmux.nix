
{ config, pkgs, ...}:

{
  home.file = {
    ".config/tmux" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/LycOS/modules/tmux/config-tmux";
      recursive = true;
    };
  };
}
