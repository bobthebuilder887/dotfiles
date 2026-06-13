-- Buffer deletion that does not mess with the current window layout
vim.keymap.set("n", "<leader>q", ":bd<CR>", {buffer=true, desc="use default buffer behaviour for help window"})
