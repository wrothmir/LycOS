{ config, pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    vimAlias = true;
    plugins = with pkgs; [
      vimPlugins.nvim-treesitter
      vimPlugins.nvim-treesitter-parsers.lua
      vimPlugins.nvim-treesitter-parsers.python
      vimPlugins.nvim-treesitter-parsers.go
      vimPlugins.nvim-treesitter-parsers.ocaml
      vimPlugins.nvim-treesitter-parsers.nix
      vimPlugins.nvim-treesitter-parsers.rust
      vimPlugins.nvim-treesitter-parsers.odin
      vimPlugins.lualine-nvim

      vimPlugins.telescope-nvim
      vimPlugins.telescope-file-browser-nvim
      vimPlugins.oil-nvim
      vimPlugins.zen-mode-nvim

      vimPlugins.undotree

      vimPlugins.cmp-buffer
      vimPlugins.nvim-cmp
      vimPlugins.cmp-path
      vimPlugins.cmp-zsh
      vimPlugins.cmp-nvim-lua

      vimPlugins.luasnip
      vimPlugins.friendly-snippets
      vimPlugins.cmp_luasnip

      vimPlugins.nvim-lspconfig
      vimPlugins.cmp-nvim-lsp

      vimPlugins.gruvbox-nvim
      vimPlugins.mini-icons
      vimPlugins.neovim-ayu

    ];
    #extraConfig = ''
    #  :luafile ~/.config/nvim/lua/init.lua
    #'';

  };

  home.packages = with pkgs; [
    stylua
    lua-language-server
    gopls
    nil
    ruff
    ols
  ];

  home.file = {
    ".config/nvim" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/LycOS/modules/neovim/nvim";
      recursive = true;
    };
  };
}
