local utils = require 'config.utils'

local state = {
  terminal = {
    buf = -1,
    win = -1,
  }
}

local toggle_terminal = function()
  vim.api.nvim_create_autocmd("TermClose", {
    pattern = "*",  -- Applies to any terminal
    callback = function()
      -- Check if the terminal job_id matches
      if vim.b.terminal_job_id then
        -- Close the terminal window
        vim.api.nvim_win_close(state.terminal.win, true)
      end
    end,
  })
  if not vim.api.nvim_win_is_valid(state.terminal.win) then
    state.terminal = utils.create_bottom_split_window { buf = state.terminal.buf }
    if vim.bo[state.terminal.buf].buftype ~= "terminal" then
      vim.cmd.terminal("zsh")
    end
  else
    vim.api.nvim_win_hide(state.terminal.win)
  end
end

vim.api.nvim_create_user_command("Boterminal", toggle_terminal, {})
vim.keymap.set("t", "<esc><esc>", "<c-\\><c-n>")
vim.keymap.set({ "n", "t" }, "<leader>tt", toggle_terminal)
