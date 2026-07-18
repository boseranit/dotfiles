local map = vim.keymap.set

map("n", "<CR>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })
map("n", "<leader>|", "<cmd>vsplit<CR>", { desc = "Split window vertically" })
map("n", "<leader>-", "<cmd>split<CR>", { desc = "Split window horizontally" })
map("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
map("n", "gD", vim.lsp.buf.declaration, { desc = "Go to declaration" })
map("n", "<leader>ws", vim.lsp.buf.workspace_symbol, { desc = "Workspace symbols" })
map("n", "<leader>f", vim.lsp.buf.format, { desc = "Format buffer" })
map("n", "<leader>q", vim.diagnostic.setqflist, { desc = "Diagnostic list" })
map("n", "<leader>uh", function()
  local filter = { bufnr = 0 }
  vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled(filter), filter)
end, { desc = "Toggle inlay hints" })
map("t", "<Esc>", [[<C-\><C-n>]], { desc = "Leave terminal mode" })
