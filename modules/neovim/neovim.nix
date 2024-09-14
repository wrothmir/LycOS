{ config, pkgs, ...}: 

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    vimAlias = true;
  };

  home.file = {
    ".config/nvim/" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/PyrOS/modules/neovim/nvim";
      recursive = true;
    };
  };
}
