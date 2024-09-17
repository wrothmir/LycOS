return {
  {
    "nvim-telescope/telescope-file-browser.nvim",
    dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" },
  },
  {
    "catppuccin/nvim",
    name = "catppuccin",
  },
  {
    'ellisonleao/gruvbox.nvim',
    name = 'gruvbox',
    config = function()
      vim.cmd('colorscheme gruvbox')
    end,
    opts = {
      background = "dark"
    }
  },
  {
    'folke/tokyonight.nvim',
    name = 'tokyonight',
  },
  {
    "rebelot/kanagawa.nvim",
    name = 'kanagawa',
  },
  {
    'Shatur/neovim-ayu',
    name = 'ayu',
  },
  {
    "savq/melange-nvim",
    name = 'melange',
  },
  { "nvim-treesitter/playground" },
  {
    "williamboman/mason.nvim",
    config = function()
      local mason = require("mason")

      -- enable mason and configure icons
      mason.setup({
        ui = {
          icons = {
            package_installed = "✓",
            package_pending = "➜",
            package_uninstalled = "✗",
          },
        },
      })
    end,
  }
}
