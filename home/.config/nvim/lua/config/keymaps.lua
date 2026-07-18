local map = vim.keymap.set

map("n", "<CR>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })
map("n", "|", "<cmd>vsplit<CR>", { desc = "Split window vertically" })
map("n", "-", "<cmd>split<CR>", { desc = "Split window horizontally" })
map("t", "<Esc>", [[<C-\><C-n>]], { desc = "Leave terminal mode" })
