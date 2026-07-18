local group = vim.api.nvim_create_augroup("dotfiles", { clear = true })

vim.api.nvim_create_autocmd("TextYankPost", {
  group = group,
  callback = function()
    vim.hl.on_yank()
  end,
})
vim.api.nvim_create_autocmd("FileType", {
  group = group,
  pattern = { "lua", "markdown", "python", "vimdoc" },
  callback = function(args)
    pcall(vim.treesitter.start, args.buf)
  end,
})
