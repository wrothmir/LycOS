local capabilites = require('cmp_nvim_lsp').default_capabilities()

local lspconfig = require("lspconfig")

lspconfig.gopls.setup({
  capabilites = capabilites,
})
lspconfig.lua_ls.setup({
  capabilites = capabilites,
  settings = {
    Lua = {
      runtime = {
        path = {
          '?.lua',
          '?/init.lua',
          '~/.config/nvim/pack/plugins/start/love2d/**/*.lua', -- Include the path to the Love2D addon
        }
      },
      diagnostics = {
        globals = { 'love' },
      },
      workspace = {
        library = {
          '~/.config/nvim/pack/plugins/start/love2d', -- Include the library path for the addon
        }
      }
    }
  },
  on_attach = function()
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = 0 })
    vim.keymap.set("n", "gt", vim.lsp.buf.type_definition, { buffer = 0 })
    vim.keymap.set("n", "gi", vim.lsp.buf.implementation, { buffer = 0 })
    vim.keymap.set("n", "K", vim.lsp.buf.hover, { buffer = 0 })
    vim.keymap.set("n", "<leader>dj", vim.diagnostic.goto_next, { buffer = 0 })
    vim.keymap.set("n", "<leader>dk", vim.diagnostic.goto_prev, { buffer = 0 })
    vim.keymap.set("n", "<leader>do", vim.diagnostic.open_float, { buffer = 0 })
    vim.keymap.set("n", "<leader>dl", "<cmd>Telescope diagnostics<cr>", { buffer = 0 })
    vim.keymap.set("n", "<leader>vws", vim.lsp.buf.workspace_symbol, { buffer = 0 })
    vim.keymap.set("n", "<leader>vca", vim.lsp.buf.code_action, { buffer = 0 })
    vim.keymap.set("n", "<leader>vrf", vim.lsp.buf.references, { buffer = 0 })
    vim.keymap.set("n", "<leader>vrn", vim.lsp.buf.rename, { buffer = 0 })
    vim.keymap.set("i", "<C-h>", vim.lsp.buf.signature_help, { buffer = 0 })
  end
})
