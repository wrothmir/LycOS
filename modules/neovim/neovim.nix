{ config, pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    vimAlias = true;
    plugins = with pkgs.vimPlugins; [
      nvim-treesitter
      nvim-treesitter-parsers.lua
      nvim-treesitter-parsers.python
      nvim-treesitter-parsers.go
      nvim-treesitter-parsers.ocaml
      nvim-treesitter-parsers.nix
      nvim-treesitter-parsers.rust
      lualine-nvim

      telescope-nvim
      telescope-file-browser-nvim
      oil-nvim
      zen-mode-nvim

      undotree

      cmp-buffer
      nvim-cmp
      cmp-path
      cmp-zsh
      cmp-nvim-lua

      luasnip
      friendly-snippets
      cmp_luasnip

      nvim-lspconfig
      cmp-nvim-lsp

      gruvbox-nvim
      mini-icons
      neovim-ayu
    ];
    #extraConfig = ''
    #  :luafile ~/.config/nvim/lua/init.lua
    #'';

  };

  home.packages = with pkgs; [
    stylua
    lua-language-server
    gopls
  ];

  home.file = {
    ".config/nvim" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/LycOS/modules/neovim/nvim";
      recursive = true;
    };
  };
}
