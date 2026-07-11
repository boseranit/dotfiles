return {
  {
    "folke/lazydev.nvim",
    ft = "lua",
    opts = {},
  },
  {
    "mason-org/mason-lspconfig.nvim",
    dependencies = {
      { "mason-org/mason.nvim", opts = {} },
      "neovim/nvim-lspconfig",
      "saghen/blink.cmp",
    },
    opts = function()
      vim.lsp.config("*", {
        capabilities = require("blink.cmp").get_lsp_capabilities(),
      })

      return {
        ensure_installed = { "clangd", "lua_ls", "pyright", "ts_ls" },
      }
    end,
    config = function(_, opts)
      local registry = require("mason-registry")
      if #registry.get_all_package_specs() == 0 then
        local ok, err = registry.refresh()
        if not ok then
          vim.notify("Unable to initialize the Mason registry: " .. tostring(err), vim.log.levels.ERROR)
          return
        end
      end

      require("mason-lspconfig").setup(opts)
    end,
  },
}
