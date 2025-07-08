require 'mini.icons'.setup({})
require 'mini.indentscope'.setup({
  symbol = "│",
  options = { try_as_border = true },
  draw = {
    delay = 0,
    animation = function(s, n) return 0 end
  },
})
