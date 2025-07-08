require("telescope").setup {
  pickers = {
    find_files = {
      theme = "ivy"
    }
  },
  extensions = {
    fzf = {}
  }
}

require 'telescope'.load_extension('fzf')

local builtin = require('telescope.builtin')
local themes = require('telescope.themes')

vim.keymap.set("n", "<leader>ff", builtin.find_files, {})
vim.keymap.set("n", "<leader>ht", builtin.help_tags, {})
vim.keymap.set("n", "<leader>ps", builtin.live_grep, {})
vim.keymap.set("n", "<leader>en", function()
  builtin.find_files { cwd = vim.fn.stdpath("config") }
end)
vim.keymap.set("n", "<leader>ep", function()
  builtin.find_files { cwd = vim.fs.joinpath(vim.fn.stdpath("data"), "lazy") }
end)
