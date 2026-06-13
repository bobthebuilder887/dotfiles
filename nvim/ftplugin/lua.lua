vim.wo.list        = true
vim.wo.colorcolumn = "120"

vim.bo.autoindent  = true
vim.bo.smartindent = false
vim.bo.cindent     = false

vim.bo.tabstop     = 2
vim.bo.shiftwidth  = 2
vim.bo.softtabstop = 2

vim.lsp.start({
  name = "luals",
  fileypes = { "lua" },
  cmd = { "lua-language-server" },
  root_markers = { ".luarc.json", ".luarc.jsonc" },
  settings = {
    Lua = {
      runtime = {
        version = "LuaJIT",
        path = vim.split(package.path, ";"),
      },

      diagnostics = {
        globals = { "vim" },
      },

      workspace = {
        library = vim.list_extend(
          vim.api.nvim_get_runtime_file("", true),
          {
            vim.fn.stdpath("config"),
          }
        ),
        checkThirdParty = false,
      },

      telemetry = {
        enable = false,
      },
    },
  },
})


vim.keymap.set({"x", "v"}, "<leader>o", ":'<,'>lua<cr>", { desc = "Evaluate in lua", buffer = true })
