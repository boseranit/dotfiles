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
      vim.lsp.config("basedpyright", {
        settings = {
          basedpyright = {
            disableOrganizeImports = true,
            analysis = {
              typeCheckingMode = "basic",
            },
          },
        },
      })
      vim.lsp.config("ruff", {
        on_attach = function(client)
          client.server_capabilities.hoverProvider = false
        end,
      })

      return {
        automatic_enable = { "basedpyright", "clangd", "lua_ls", "ruff" },
        ensure_installed = { "basedpyright", "clangd", "lua_ls", "ruff" },
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
