return {
  {
    "willothy/flatten.nvim",
    lazy = false,
    priority = 1001,
    opts = {},
  },
  {
    "stevearc/oil.nvim",
    lazy = false,
    opts = { default_file_explorer = true },
    keys = {
      { "-", "<cmd>Oil<CR>", desc = "Open parent directory" },
      { "<C-n>", "<cmd>Oil --float<CR>", desc = "Open file explorer" },
    },
  },
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>ff", "<cmd>Telescope find_files<CR>", desc = "Find files" },
      { "<leader>fg", "<cmd>Telescope live_grep<CR>", desc = "Live grep" },
      { "<leader>fb", "<cmd>Telescope buffers<CR>", desc = "Buffers" },
      { "<leader>fh", "<cmd>Telescope help_tags<CR>", desc = "Help tags" },
    },
    opts = {},
  },
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {},
  },
  {
    "kdheepak/lazygit.nvim",
    cmd = { "LazyGit", "LazyGitConfig", "LazyGitCurrentFile", "LazyGitFilter", "LazyGitFilterCurrentFile" },
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = { { "<leader>gg", "<cmd>LazyGit<CR>", desc = "LazyGit" } },
  },
  { "tpope/vim-sleuth" },
  { "karb94/neoscroll.nvim", opts = {} },
  {
    "lervag/vimtex",
    lazy = false,
    init = function()
      vim.g.tex_flavor = "latex"
      vim.g.vimtex_compiler_latexmk = {
        out_dir = "build",
        options = {
          "-shell-escape",
          "-verbose",
          "-file-line-error",
          "-interaction=nonstopmode",
          "-synctex=1",
        },
      }
      vim.g.vimtex_view_general_viewer = "SumatraPDF"
      vim.g.vimtex_view_general_options = "-reuse-instance -forward-search @tex @line @pdf"
      vim.g.tex_conceal = "abdmg"
    end,
    config = function()
      vim.api.nvim_set_hl(0, "Conceal", { bg = "NONE" })
    end,
  },
}
