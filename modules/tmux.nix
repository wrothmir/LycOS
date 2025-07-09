
{ config, pkgs, ...}:

{
  home.file = {
    ".config/tmux" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/LycOS/dotfiles/tmux";
      recursive = true;
    };
  };
}
