---todo:
---autocommand to create baker file.
---@class BakerFloatingConfig
---@field position string      -- "center", "bottom_left", "bottom_right", "top_left", or "top_right"
---@field size table           -- Size configuration for floating windows.
---@field size.width number    -- Fraction of total columns (e.g. 0.4 for 40%).
---@field size.height number   -- Fraction of total lines (e.g. 0.3 for 30%).

---@class BakerSplitConfig
---@field position string      -- "bottom", "top", "left", or "right"
---@field size table           -- Size configuration for split windows.
---@field size.width number    -- For vertical splits ("left" or "right"): fraction of total columns.
---@field size.height number   -- For horizontal splits ("bottom" or "top"): fraction of total lines.

---@class BakerKeyMappings
---@field init string
---@field build string
---@field run string
---@field clean string
---@field test string
---@field close string
---@field hide string

---@class BakerConfig
---@field window_type string?           -- Options: "floating" ,"split". Default: "split".
---@field floating BakerFloatingConfig? -- Configuration for floating windows.
---@field split BakerSplitConfig?       -- Configuration for split windows.
---@field term_cmd string               -- Command to execute on terminal open.
---@field keys table<string, BakerKeyMappings>? -- Key mappings for different modes (e.g. "n", "i").

local baker_buf = nil
local baker_win = nil
local baker_ns_id = vim.api.nvim_create_namespace("baker_namespace") -- Create a valid namespace

local M = {}

--- Returns the default Baker configuration.
--- @return BakerConfig default configuration table.
function M.get_default_config()
  return {
    window_type = "split", -- Options: "floating" or "split"
    floating = {
      position = "center", -- Options: "center", "bottom_left", "bottom_right", "top_left", "top_right"
      size = {
        width = 0.4,       -- 40% of total columns by default.
        height = 0.3,      -- 30% of total lines by default.
      },
    },
    split = {
      position = "bottom", -- Options: "bottom", "top", "left", or "right"
      size = {
        height = 0.3,      -- For "bottom" or "top": 30% of total lines.
        width = 0.3,       -- For "left" or "right": 40% of total columns.
      },
    },
    term_cmd = "",
    keys = {
      ["n"] = {
        init  = "<leader>bi", -- Create Baker template file in cwd.
        build = "<leader>bb",
        run   = "<leader>br",
        clean = "<leader>bc",
        test  = "<leader>bt",
        close = "<leader>bx",
        hide  = "<leader>bh", -- Toggle hide/show Baker window.
      },
      ["i"] = {},
    },
  }
end

--- Merges a partial configuration with the default configuration.
--- @param partial_config? table Partial configuration table.
--- @param latest_config? table Existing configuration table.
--- @return BakerConfig merged configuration table.
function M.merge_config(partial_config, latest_config)
  partial_config = partial_config or {}
  local config = latest_config or M.get_default_config()
  config = vim.tbl_deep_extend("force", config, partial_config)
  return config
end

--- Creates a configuration using the given settings.
--- @param settings table Settings to override in the default configuration.
--- @return BakerConfig resulting configuration.
function M.create_config(settings)
  local config = M.get_default_config()
  for k, v in pairs(settings) do
    config[k] = v
  end
  return config
end

-- Define custom highlight groups.
vim.api.nvim_set_hl(0, "BakerSuccessLine", { fg = "#000000", bg = "#00FF00", bold = true })
vim.api.nvim_set_hl(0, "BakerFailureLine", { fg = "#000000", bg = "#FF0000", bold = true })
vim.api.nvim_set_hl(0, "BakerErrorText", { fg = "#FF0000", bold = true })

-- Remove ANSI escape codes (covers most SGR sequences).
local function strip_ansi(str)
  return str:gsub("\27%[[%d;?]*[ -/]*[@-~]", "")
end

--- Sets a highlighted line in a buffer.
--- @param buf number Buffer handle.
--- @param line number Line number (0-indexed).
--- @param text string Text to display.
--- @param hl_group string Highlight group.
local function set_highlighted_line(buf, line, text, hl_group)
  local padded_text = text .. string.rep(" ", vim.o.columns - #text)
  vim.api.nvim_buf_set_lines(buf, line, line, false, { padded_text })
  vim.api.nvim_buf_add_highlight(buf, baker_ns_id, hl_group, line, 0, -1)
end

--- Displays an error message in a buffer.
--- @param buf number Buffer handle.
--- @param message string Error message.
local function display_error(buf, message)
  vim.api.nvim_buf_set_lines(buf, -1, -1, false, { message })
  local line = #vim.api.nvim_buf_get_lines(buf, 0, -1, false) - 1
  vim.api.nvim_buf_add_highlight(buf, baker_ns_id, "BakerErrorText", line, 0, -1)
end

--- Loads the project configuration from a file named "baker.lua" in the current directory.
--- @return table config table if found
--- @return boolean error if table found then false, else true
local function load_project_conf()
  local error = nil
  local project_dir = vim.fn.getcwd()
  local baker_file = project_dir .. "/baker.lua"
  if vim.fn.filereadable(baker_file) ~= 1 then
    vim.notify("No baker.lua found in current project", vim.log.levels.ERROR)
    return {}, true
  end

  local ok, config = pcall(dofile, baker_file)
  if not ok then
    vim.notify("Error loading baker.lua: " .. config, vim.log.levels.ERROR)
    return {}, true
  end
  return config, false
end

--- Creates or reuses the Baker window based on the current configuration.
--- Reuses the Baker buffer if it exists.
--- @return number, number Baker buffer and window handles.
function M:manage_baker_window()
  local window_type = self.config.window_type

  -- If the Baker window is already visible, reuse it.
  if baker_win and vim.api.nvim_win_is_valid(baker_win) then
    vim.api.nvim_set_current_win(baker_win)
    if baker_buf and vim.api.nvim_buf_is_valid(baker_buf) then
      vim.api.nvim_set_current_buf(baker_buf)
      -- Clear previous contents.
      vim.api.nvim_buf_set_lines(baker_buf, 0, -1, false, {})
    else
      baker_buf = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_win_set_buf(baker_win, baker_buf)
    end
    return baker_buf, baker_win
  end

  -- Reuse existing baker_buf if available; otherwise create a new one.
  if not (baker_buf and vim.api.nvim_buf_is_valid(baker_buf)) then
    baker_buf = vim.api.nvim_create_buf(false, true)
  end

  if window_type == "split" then
    local split_config = self.config.split
    assert(split_config ~= nil)
    local pos = split_config.position or "bottom"
    if pos == "bottom" then
      vim.cmd("botright split")
      baker_win = vim.api.nvim_get_current_win()
      local height_percent = (split_config.size and split_config.size.height) or 0.3
      vim.api.nvim_win_set_height(baker_win, math.max(math.floor(vim.o.lines * height_percent), 10))
    elseif pos == "top" then
      vim.cmd("topleft split")
      baker_win = vim.api.nvim_get_current_win()
      local height_percent = (split_config.size and split_config.size.height) or 0.3
      vim.api.nvim_win_set_height(baker_win, math.max(math.floor(vim.o.lines * height_percent), 10))
    elseif pos == "left" then
      vim.cmd("leftabove vsplit")
      vim.cmd("wincmd H") -- Move the new vertical split to the far left.
      baker_win = vim.api.nvim_get_current_win()
      local width_percent = (split_config.size and split_config.size.width) or 0.4
      vim.api.nvim_win_set_width(baker_win, math.max(math.floor(vim.o.columns * width_percent), 30))
    elseif pos == "right" then
      vim.cmd("rightbelow vsplit")
      vim.cmd("wincmd L") -- Move the new vertical split to the far right.
      baker_win = vim.api.nvim_get_current_win()
      local width_percent = (split_config.size and split_config.size.width) or 0.4
      vim.api.nvim_win_set_width(baker_win, math.max(math.floor(vim.o.columns * width_percent), 30))
    else
      vim.cmd("botright split")
      baker_win = vim.api.nvim_get_current_win()
      local height_percent = (split_config.size and split_config.size.height) or 0.3
      vim.api.nvim_win_set_height(baker_win, math.max(math.floor(vim.o.lines * height_percent), 10))
    end
  else
    local float_position = self.config.floating.position
    local width_percent = (self.config.floating.size and self.config.floating.size.width) or 0.4
    local height_percent = (self.config.floating.size and self.config.floating.size.height) or 0.3
    local width = math.max(math.floor(vim.o.columns * width_percent), 60)
    local height = math.max(math.floor(vim.o.lines * height_percent), 15)
    local row, col
    if float_position == "bottom_left" then
      row = vim.o.lines - height - 2
      col = 2
    elseif float_position == "bottom_right" then
      row = vim.o.lines - height - 2
      col = vim.o.columns - width - 2
    elseif float_position == "top_left" then
      row = 2
      col = 2
    elseif float_position == "top_right" then
      row = 2
      col = vim.o.columns - width - 2
    else -- default to center.
      row = (vim.o.lines - height) / 2
      col = (vim.o.columns - width) / 2
    end
    baker_win = vim.api.nvim_open_win(baker_buf, true, {
      relative = "editor",
      width = width,
      height = height,
      row = row,
      col = col,
      style = "minimal",
      border = "rounded",
    })
  end

  vim.api.nvim_win_set_var(baker_win, "winblend", 10)
  vim.api.nvim_set_current_win(baker_win)
  vim.api.nvim_set_current_buf(baker_buf)
  return baker_buf, baker_win
end

function M:baker_edit(command_type)
  local valid_types = { build = true, run = true, test = true, clean = true }
  if not valid_types[command_type] then
    vim.notify("Invalid command type: " .. command_type, vim.log.levels.ERROR)
    return
  end

  local config, error = load_project_conf()
  if error then return end

  local commands = config[command_type] or {}

  local buf, win = self:manage_baker_window()

  -- 👇 Give the buffer a temporary file name to allow saving
  local cwd = vim.fn.getcwd()
  local tmp_path = cwd .. "/.baker_" .. command_type .. "_edit.lua"
  vim.api.nvim_buf_set_name(buf, tmp_path)

  -- Make the buffer writable
  vim.bo[buf].modifiable = true
  vim.bo[buf].readonly = false
  vim.bo[buf].buftype = ""

  -- Set content and filetype
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, commands)
  vim.bo[buf].filetype = "baker"

  -- Watch for save
  vim.api.nvim_create_autocmd("BufWritePost", {
    buffer = buf,
    callback = function()
      local updated_lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
      local updated_cmds = vim.tbl_filter(function(line)
        return line:match("%S")
      end, updated_lines)

      config[command_type] = updated_cmds

      local project_dir = vim.fn.getcwd()
      local baker_file = project_dir .. "/baker.lua"
      local f = assert(io.open(baker_file, "w"))
      f:write("return {\n")
      for key, val in pairs(config) do
        f:write(string.format("  %s = {\n", key))
        for _, cmd in ipairs(val) do
          f:write(string.format("    %q,\n", cmd))
        end
        f:write("  },\n")
      end
      f:write("}\n")
      f:close()

      vim.notify("Updated " .. command_type .. " in baker.lua", vim.log.levels.INFO)
      vim.api.nvim_win_close(win, true)
    end,
  })
end

-- Executes a list of commands and displays the results in the Baker window.
--- @param commands table Array of command strings to execute.
--- @param show_elapsed_time boolean If true, displays the elapsed time.
--- @param open_term boolean If true, sends commands to a terminal.
function M:execute_bake_command(commands, show_elapsed_time, open_term)
  vim.notify("", vim.log.levels.INFO)
  vim.api.nvim_set_option_value("modifiable", true, { buf = baker_buf })
  if not commands or #commands == 0 then
    assert(baker_buf ~= nil)
    display_error(baker_buf, "No commands found.")
    return
  end

  self:manage_baker_window()

  assert(baker_buf ~= nil)
  vim.api.nvim_set_option_value("modifiable", true, { buf = baker_buf })
  vim.api.nvim_buf_set_lines(baker_buf, 0, -1, false, {})

  local start_time = vim.uv.hrtime()
  local overall_success = true

  if not open_term then
    for _, cmd in ipairs(commands) do
      vim.api.nvim_buf_set_lines(baker_buf, -1, -1, false, { "Executing: " .. cmd })
      local line_index = #vim.api.nvim_buf_get_lines(baker_buf, 0, -1, false) - 1

      local success, output = pcall(function()
        local handle = io.popen(cmd .. " 2>&1 ; echo $?")
        if not handle then error("Failed to execute command: " .. cmd) end
        local result = handle:read("*a")
        handle:close()
        return result
      end)

      if success then
        output = strip_ansi(output)
      end

      if not success then
        overall_success = false
        set_highlighted_line(baker_buf, line_index + 1, "FAILURE", "BakerFailureLine")
        display_error(baker_buf, "Error: " .. cmd)
        display_error(baker_buf, "Traceback: " .. tostring(output))
      else
        local lines = vim.split(output, "\n")
        local exit_code = tonumber(lines[#lines - 1])
        table.remove(lines, #lines - 1)

        if exit_code == 0 then
          set_highlighted_line(baker_buf, line_index + 1, "SUCCESS", "BakerSuccessLine")
          vim.api.nvim_buf_set_lines(baker_buf, -1, -1, false, lines)
        else
          overall_success = false
          set_highlighted_line(baker_buf, line_index + 1, "FAILURE", "BakerFailureLine")
          display_error(baker_buf, "Error: Command failed with exit code " .. exit_code)
          vim.api.nvim_buf_set_lines(baker_buf, -1, -1, false, lines)
        end
      end
    end
  else
    vim.cmd.terminal(self.config.term_cmd)
    assert(baker_win ~= nil)
    baker_buf = vim.api.nvim_win_get_buf(baker_win)
    local jobid = vim.bo[baker_buf].channel

    for _, command in ipairs(commands) do
      vim.fn.chansend(jobid, command .. "\n")
    end

    local last_line = #vim.api.nvim_buf_get_lines(baker_buf, 0, -1, false)
    vim.api.nvim_win_set_cursor(baker_win, { last_line, 0 })

    vim.api.nvim_create_autocmd("TermClose", {
      buffer = baker_buf,
      callback = function()
        M:baker_close()
      end,
      once = true,
    })
  end

  if show_elapsed_time then
    local elapsed_time_s = (vim.uv.hrtime() - start_time) / 1e9
    local result_message = overall_success and string.format("Build completed in %.3fs.", elapsed_time_s)
        or string.format("Build failed in %.3fs.", elapsed_time_s)
    set_highlighted_line(baker_buf, #vim.api.nvim_buf_get_lines(baker_buf, 0, -1, false), result_message,
      overall_success and "BakerSuccessLine" or "BakerFailureLine")
  end

  vim.api.nvim_set_option_value("modifiable", false, { buf = baker_buf })
end

--- Toggles the hidden state of the Baker window.
--- If the window is visible, it is closed (hidden) but the buffer remains.
--- If it is hidden, the window is reopened using the existing buffer.
--- If there is no buffer, the command does nothing.
function M:baker_hide()
  if baker_win and vim.api.nvim_win_is_valid(baker_win) then
    -- Hide the window while keeping the buffer in memory
    vim.api.nvim_win_close(baker_win, false)
    baker_win = nil
  elseif baker_buf and vim.api.nvim_buf_is_valid(baker_buf) then
    -- Reopen the window only if a valid buffer exists
    self:manage_baker_window()
  else
    -- Do nothing if there is no valid buffer
    vim.notify("No Baker buffer to show", vim.log.levels.INFO)
  end
end

--- Executes the build commands from the project configuration.
function M:baker_build()
  local conf, error = load_project_conf()
  if error then return end
  assert(conf["build"], "No build commands found")
  self:execute_bake_command(conf["build"], true, false)
end

--- Executes the test commands from the project configuration.
function M:baker_test()
  local conf, error = load_project_conf()
  if error then return end
  assert(conf["test"], "No test commands found")
  self:execute_bake_command(conf["test"], false, false)
end

--- Executes the clean commands from the project configuration.
function M:baker_clean()
  local conf, error = load_project_conf()
  if error then return end
  assert(conf["clean"], "No clean commands found")
  self:execute_bake_command(conf["clean"], false, false)
end

--- Executes the run commands from the project configuration.
function M:baker_run()
  local conf, error = load_project_conf()
  if error then return end
  assert(conf["run"], "No run commands found")
  self:execute_bake_command(conf["run"], false, true)
end

--- Closes the Baker window.
function M:baker_close()
  if baker_win and vim.api.nvim_win_is_valid(baker_win) then
    if baker_buf and vim.api.nvim_buf_is_valid(baker_buf) then
      if vim.bo[baker_buf].buftype == "terminal" then
        local chan_id = vim.b[baker_buf].terminal_job_id or vim.bo[baker_buf].channel
        if chan_id and vim.fn.jobwait({ chan_id }, 0)[1] == -1 then
          -- Only send if job is still running
          vim.fn.chansend(chan_id, "\003") -- Send Ctrl+C

          -- Optional force-kill after 200ms if still running
          vim.defer_fn(function()
            if vim.fn.jobwait({ chan_id }, 0)[1] == -1 then
              vim.fn.jobstop(chan_id)
            end
          end, 200)
        end
      end
    end

    vim.api.nvim_win_close(baker_win, true)
    baker_win = nil

    if baker_buf and vim.api.nvim_buf_is_valid(baker_buf) then
      vim.cmd("bdelete! " .. baker_buf)
    end
    baker_buf = nil
  end
end

--- Creates a default `baker.lua` config file in the current working directory.
function M:baker_init()
  local path = vim.fn.getcwd() .. "/baker.lua"
  if vim.fn.filereadable(path) == 1 then
    vim.notify("baker.lua already exists in this directory.", vim.log.levels.WARN)
    return
  end

  local template = [[
-- baker.lua
return {
  build = {
    "echo Building project...",
    -- Add your actual build commands here
  },
  run = {
    "echo Running project...",
    -- Add your actual run commands here
  },
  test = {
    "echo Running tests...",
    -- Add your actual test commands here
  },
  clean = {
    "echo Cleaning up...",
    -- Add your actual clean commands here
  },
}
]]

  local file = io.open(path, "w")
  if file then
    file:write(template)
    file:close()
    vim.notify("Created baker.lua in " .. path, vim.log.levels.INFO)
  else
    vim.notify("Failed to create baker.lua", vim.log.levels.ERROR)
  end
end

--- Sets up Baker with user configuration.
--- @param partial_config? BakerConfig Partial configuration table to merge with the defaults.
function M.setup(partial_config)
  local config = M.merge_config(partial_config, M.get_default_config())
  M.config = config

  local commands = {
    init  = function() M:baker_init() end,
    build = function() M:baker_build() end,
    run   = function() M:baker_run() end,
    clean = function() M:baker_clean() end,
    test  = function() M:baker_test() end,
    close = function() M:baker_close() end,
    hide  = function() M:baker_hide() end,
    edit  = function(opts) M:baker_edit(opts.args) end
  }

  for mode, mappings in pairs(config.keys) do
    for command, keymap in pairs(mappings) do
      vim.keymap.set(mode, keymap, commands[command])
    end
  end

  vim.api.nvim_create_user_command("BakerInit", commands["init"], {})
  vim.api.nvim_create_user_command("BakerBuild", commands["build"], {})
  vim.api.nvim_create_user_command("BakerTest", commands["test"], {})
  vim.api.nvim_create_user_command("BakerClean", commands["clean"], {})
  vim.api.nvim_create_user_command("BakerRun", commands["run"], {})
  vim.api.nvim_create_user_command("BakerClose", commands["close"], {})
  vim.api.nvim_create_user_command("BakerHide", commands["hide"], {})
  vim.api.nvim_create_user_command("BakerEdit", commands["edit"], {
    nargs = 1,
    complete = function(_, _, _)
      return { "build", "test", "run", "clean" }
    end,
  })
end

return M
