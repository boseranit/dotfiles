return {
  {
    "D0nw0r/dark2026.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd.colorscheme "dark2026"
      vim.cmd.highlight "Normal guibg=#101010"
    end,
  },
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts = {
      sections = {
        lualine_a = { "mode" },
        lualine_b = { "branch", "diff", "diagnostics" },
        lualine_c = { { "filename", path = 1 } },
        lualine_x = { "encoding", "fileformat", "filetype" },
        lualine_y = { "progress" },
        lualine_z = { "location" },
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { "filename" },
        lualine_x = { "location" },
        lualine_y = {},
        lualine_z = {},
      },
      extensions = { "oil" },
    },
  },
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {},
  },
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = "markdown",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-mini/mini.icons",
    },
    opts = {},
  },
  {
    "brianhuster/live-preview.nvim",
    cmd = "LivePreview",
    ft = "markdown",
    config = function()
      require("livepreview.config").set({
        address = "192.168.1.104",
        port = 5050,
        browser = "true",
        dynamic_root = true,
      })
    end,
    keys = {
      {
        "<leader>lp",
        "<cmd>LivePreview start<CR>",
        ft = "markdown",
        desc = "Start live Markdown preview",
      },
      {
        "<leader>lq",
        "<cmd>LivePreview close<CR>",
        ft = "markdown",
        desc = "Close live Markdown preview",
      },
    },
  },
}
