-- TODO: it should make sure the file is csv-like 
local home_path     = vim.loop.os_homedir()
vim.keymap.set('n', '<leader>s', ":w! " .. home_path .. "/Projects/explorations/q.csv<CR>", {buffer = true, desc = 'save file into a csv' })
vim.bo.modifiable = true
vim.bo.readonly = false
vim.wo.colorcolumn = "0"
