return {
  {
    "neovim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    dependencies = { "neovim-treesitter/treesitter-parser-registry" },
    config = function()
      -- tree-sitter-cli otherwise selects cl.exe for native Windows builds.
      -- Use Clang with the MinGW libraries supplied by Strawberry Perl when
      -- the user has not selected a compiler explicitly.
      if vim.fn.has("win32") == 1 and (vim.env.CC == nil or vim.env.CC == "") then
        local clang = vim.fn.exepath("clang")
        local strawberry = "C:/Strawberry/c"
        if clang ~= "" and vim.fn.isdirectory(strawberry) == 1 then
          vim.env.CC = clang
          vim.env.CXX = vim.fn.exepath("clang++")
          local mingw_flags = "--target=x86_64-w64-windows-gnu --gcc-toolchain=" .. strawberry
          vim.env.CFLAGS = mingw_flags
          vim.env.CXXFLAGS = mingw_flags
        end
      end

      require("nvim-treesitter").install({
        "c",
        "cpp",
        "ecma",
        "javascript",
        "jsx",
        "lua",
        "python",
        "vim",
        "vimdoc",
      }):wait(300000)
    end,
  },
  {
    "saghen/blink.cmp",
    version = "1.*",
    dependencies = {
      {
        "L3MON4D3/LuaSnip",
        build = vim.fn.has("win32") == 1 and "gmake CC=gcc install_jsregexp"
          or "make install_jsregexp",
      },
      "rafamadriz/friendly-snippets",
    },
    opts = {
      keymap = {
        preset = "none",
        ["<C-Space>"] = { "show", "show_documentation", "hide_documentation" },
        ["<C-e>"] = { "hide", "fallback" },
        ["<C-Up>"] = { "scroll_documentation_up", "fallback" },
        ["<C-Down>"] = { "scroll_documentation_down", "fallback" },
        ["<CR>"] = { "accept", "fallback" },
        ["<Tab>"] = {
          function()
            local luasnip = require("luasnip")
            if luasnip.expand_or_locally_jumpable() then
              luasnip.expand_or_jump()
              return true
            end
          end,
          "select_next",
          "fallback",
        },
        ["<S-Tab>"] = {
          function()
            local luasnip = require("luasnip")
            if luasnip.locally_jumpable(-1) then
              luasnip.jump(-1)
              return true
            end
          end,
          "select_prev",
          "fallback",
        },
      },
      snippets = { preset = "luasnip" },
      sources = {
        default = { "lazydev", "lsp", "path", "snippets", "buffer" },
        providers = {
          lazydev = {
            name = "LazyDev",
            module = "lazydev.integrations.blink",
            score_offset = 100,
          },
        },
      },
      completion = { documentation = { auto_show = true } },
    },
    config = function(_, opts)
      local luasnip = require("luasnip")
      luasnip.config.setup({
        enable_autosnippets = true,
        cut_selection_keys = "<Tab>",
      })
      require("luasnip.loaders.from_vscode").lazy_load()
      require("luasnip.loaders.from_lua").lazy_load({
        paths = vim.fn.stdpath("config") .. "/lua/snippets",
      })
      require("blink.cmp").setup(opts)
    end,
  },
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = {},
    config = function(_, opts)
      local autopairs = require("nvim-autopairs")
      autopairs.setup(opts)
      autopairs.add_rule(require("nvim-autopairs.rule")("/*", "*/"))
    end,
  },
}
