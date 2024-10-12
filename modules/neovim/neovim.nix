{ config, pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    vimAlias = true;
    plugins = with pkgs.vimPlugins; [
      nvim-treesitter.withAllGrammars
      lualine-nvim

      telescope-nvim
      telescope-file-browser-nvim

      undotree

      cmp-buffer
      cmp-path
      cmp-zsh
      cmp-nvim-lua

      luasnip
      friendly-snippets
      cmp_luasnip

      nvim-lspconfig
      cmp-nvim-lsp

    ];
    extraConfig = ''
      :luafile ~/.config/nvim/lua/init.lua
    '';

  };

  home.packages = with pkgs; [
    stylua
  ];

  xdg.configFile.nvim = {
    source = ./nvim;
    recursive = true;
  };

}
