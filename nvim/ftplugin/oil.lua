-- TODO need something like cd ..
vim.keymap.set({ "n", "v", "t", "x", "c" }, "<D-o>", require("oil").close, { desc = "close oil", buffer = true })
vim.keymap.set({ "n", "v", "t", "x", "c" }, "<leader>e", require("oil").close, { desc = "close oil", buffer = true })

vim.keymap.set({ "n", "v", "t", "x", "c" }, "<D-u>", require("oil").open, { desc = "close oil", buffer = true })
vim.keymap.set({ "n", "v", "t", "x", "c" }, "<leader>u", require("oil").open, { desc = "close oil", buffer = true })
