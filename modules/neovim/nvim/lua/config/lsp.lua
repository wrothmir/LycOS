local capabilities = require('blink.cmp').get_lsp_capabilities()

require 'lspconfig'.pylsp.setup({
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
})

require 'lspconfig'.gopls.setup({ capabilites = capabilities, })

require 'lspconfig'.ols.setup({ capabilites = capabilities, })

require 'lspconfig'.rust_analyzer.setup({ capabilities = capabilities, })

require 'lspconfig'.tailwindcss.setup({ capabilities = capabilities, })

--
--on_attach = function(client, bufnr)
--  on_attach()
--  vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
--end


require 'neodev'.setup()
require 'lspconfig'.lua_ls.setup({
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
})

--vim.lsp.set_log_level("debug")
--
local function setLspKeymaps(opts)
  vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
  vim.keymap.set("n", "gtd", function() vim.lsp.buf.type_definition() end, opts)
  vim.keymap.set("n", "gi", function() vim.lsp.buf.implementation() end, opts)
  vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)
  vim.keymap.set("n", "<leader>dj", function() vim.diagnostic.goto_next() end, opts)
  vim.keymap.set("n", "<leader>dk", function() vim.diagnostic.goto_prev() end, opts)
  vim.keymap.set("n", "<leader>do", function() vim.diagnostic.open_float() end, opts)
  vim.keymap.set("n", "<leader>dl", "<cmd>Telescope diagnostics<cr>", opts)
  vim.keymap.set("n", "<leader>vws", function() vim.lsp.buf.workspace_symbol() end, opts)
  vim.keymap.set("n", "<leader>vca", function() vim.lsp.buf.code_action() end, opts)
  vim.keymap.set("n", "<leader>vrf", function() vim.lsp.buf.references() end, opts)
  vim.keymap.set("n", "<leader>vrn", function() vim.lsp.buf.rename() end, opts)
  vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help() end, opts)
end

vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(event)
    local opts = { buffer = event.buf }
    setLspKeymaps(opts)
  end

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
