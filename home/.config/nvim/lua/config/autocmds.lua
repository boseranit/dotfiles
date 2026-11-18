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

vim.api.nvim_create_autocmd("FileType", {
  group = group,
  pattern = "python",
  callback = function(args)
    -- Leave source line breaks to Ruff, not insert-mode text wrapping.
    vim.bo[args.buf].textwidth = 0
  end,
})

vim.api.nvim_create_autocmd("BufWritePre", {
  group = group,
  callback = function(args)
    local ruff = vim.lsp.get_clients({
      bufnr = args.buf,
      name = "ruff",
      method = "textDocument/formatting",
    })[1]
    if ruff then
      vim.lsp.buf.format({ bufnr = args.buf, id = ruff.id })
    end
  end,
})
