local map = vim.keymap.set

map("n", "<CR>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })
map("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
map("n", "<C-j>", "<C-w>j", { desc = "Move to lower window" })
map("n", "<C-k>", "<C-w>k", { desc = "Move to upper window" })
map("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })
map("t", "<Esc>", [[<C-\><C-n>]], { desc = "Leave terminal mode" })
