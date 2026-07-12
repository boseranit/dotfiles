return {
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
      local sumatra_options = "-reuse-instance -forward-search @tex @line @pdf"
      if vim.fn.has("win32") == 1 then
        vim.g.vimtex_view_general_viewer = "SumatraPDF"
        vim.g.vimtex_view_general_options = sumatra_options
      elseif vim.fn.has("wsl") == 1 then
        local adapter = vim.fn.stdpath("config") .. "/scripts/sumatrapdf-wsl.sh"
        vim.g.vimtex_view_general_viewer = adapter
        vim.g.vimtex_view_general_options = sumatra_options
      end
      vim.g.tex_conceal = "abdmg"
    end,
    config = function()
      vim.api.nvim_set_hl(0, "Conceal", { bg = "NONE" })
    end,
  },
}
