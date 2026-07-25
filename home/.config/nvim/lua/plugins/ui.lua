local function preview_markdown()
  local filepath = vim.api.nvim_buf_get_name(0)
  local utils = require("livepreview.utils")
  if utils.supported_filetype(filepath) ~= "markdown" then
    vim.notify("Live preview: current buffer is not a Markdown file", vim.log.levels.WARN)
    return
  end

  filepath = vim.fs.normalize(filepath)
  local livepreview = require("livepreview")
  local config = require("livepreview.config").config
  local running = livepreview.is_running()
  local root = running and livepreview.serverObj.webroot or vim.uv.cwd()
  root = root and vim.fs.normalize(root)

  local urlpath = root and utils.get_relative_path(filepath, root)
  if not urlpath then
    vim.notify("Live preview: file is outside the server root", vim.log.levels.WARN)
    return
  end

  if not running and not livepreview.start(filepath, config.port) then
    return
  end

  local url = ("http://%s:%d/%s"):format(config.address, config.port, vim.uri_encode(urlpath))
  print("live-preview.nvim: Opening browser at " .. url)
  utils.open_browser(url, config.browser)
end

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
        dynamic_root = false,
      })
    end,
    keys = {
      {
        "<leader>lp",
        preview_markdown,
        ft = "markdown",
        desc = "Open live Markdown preview",
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
