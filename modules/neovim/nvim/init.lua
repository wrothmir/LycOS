require 'fenrir.remap'
require 'fenrir.opts'
require 'fenrir.colors'

require 'config.mini'
require 'config.oil'
require 'config.lualine'
require 'config.treesitter'
require 'config.telescope'
require 'config.undotree'
require 'config.blink'
require 'config.lsp'
require 'config.zenmode'

require 'custom.baker'.setup({ term_cmd = "zsh", })
require 'custom.multigrep'.setup()
