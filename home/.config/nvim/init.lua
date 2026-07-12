if vim.fn.has("nvim-0.12") == 0 then
  error("This configuration requires Neovim 0.12 or newer")
end

-- No configured plugins use Neovim's language-host providers. Language
-- servers managed by Mason are separate and do not depend on these providers.
vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0

require("config.options")
require("config.keymaps")
require("config.autocmds")
require("config.lazy")
