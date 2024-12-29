local capabilities = require('cmp_nvim_lsp').default_capabilities()

local lspconfig = require("lspconfig")

local on_attach = function()
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

lspconfig.pylsp.setup({
  capabilites = capabilities,
  settings = {
    pylsp = {
      plugins = {
        ruff = {
          enabled = true,
          formatEnabled = true,    -- Enable formatting using ruffs formatter
          targetVersion = "py310", -- The minimum python version to target (applies for both linting and formatting).
        },
      }
    }
  },
  on_attach = on_attach
})

lspconfig.gopls.setup({
  capabilites = capabilities,
  on_attach = on_attach
})

lspconfig.rust_analyzer.setup({
  capabilities = capabilities,
  on_attach = function(client, bufnr)
    on_attach()
    vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
  end
})

lspconfig.lua_ls.setup({
  capabilites = capabilities,
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
  on_attach = on_attach
})

for _, method in ipairs({ 'textDocument/diagnostic', 'workspace/diagnostic' }) do
    local default_diagnostic_handler = vim.lsp.handlers[method]
    vim.lsp.handlers[method] = function(err, result, context, config)
        if err ~= nil and err.code == -32802 then
            return
        end
        return default_diagnostic_handler(err, result, context, config)
    end
end
