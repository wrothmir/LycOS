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

      vimPlugins.nvim-treesitter-parsers.svelte
      vimPlugins.nvim-treesitter-parsers.html
      vimPlugins.nvim-treesitter-parsers.css
      vimPlugins.nvim-treesitter-parsers.typescript
      vimPlugins.nvim-treesitter-parsers.javascript
      vimPlugins.lualine-nvim

      vimPlugins.telescope-nvim
      vimPlugins.telescope-fzf-native-nvim
      vimPlugins.telescope-file-browser-nvim
      vimPlugins.oil-nvim
      vimPlugins.zen-mode-nvim
      vimPlugins.neodev-nvim

      vimPlugins.tailwind-tools-nvim
      vimPlugins.undotree

      vimPlugins.blink-cmp

      vimPlugins.nvim-lspconfig
      vimPlugins.friendly-snippets
      vimPlugins.luasnip

      vimPlugins.mini-icons
      vimPlugins.mini-indentscope

      vimPlugins.gruvbox-nvim
      vimPlugins.neovim-ayu
      vimPlugins.kanagawa-nvim

    ];
    #extraConfig = ''
    #  :luafile ~/.config/nvim/lua/init.lua
    #'';

  };

  home.packages = with pkgs; [
    stylua
    lua-language-server
    svelte-language-server
    tailwindcss-language-server
    gopls
    nil
    ruff
    ols
  ];

  home.file = {
    ".config/nvim" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/LycOS/dotfiles/nvim";
      recursive = true;
    };
  };
}
