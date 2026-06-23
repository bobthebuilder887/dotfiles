vim.wo.list        = true
vim.wo.colorcolumn = "120"

vim.bo.autoindent  = true
vim.bo.smartindent = false
vim.bo.cindent     = false

vim.bo.tabstop     = 4
vim.bo.shiftwidth  = 4
vim.bo.softtabstop = 4

local file = vim.api.nvim_buf_get_name(0)
if file:match("venv") then
  vim.bo.readonly = true
end

vim.lsp.start({
  name = "basedpyright",
  cmd = { "basedpyright-langserver", "--stdio" },
  filetypes = { "python" },
  root_dir = vim.fs.root(0, { "pyproject.toml", ".git", "requirements.txt", ".venv" , "venv"}),
  settings = {
    basedpyright = {
      analysis = {
        typeCheckingMode = "basic",
      },
    },
  },
})

local function find_venv()
  local dir = vim.fs.dirname(vim.api.nvim_buf_get_name(0))
  local venv = vim.fs.find(".venv", {
    path = dir,
    upward = true,
    type = "directory",
  })[1]
  return venv
end


local function grep_venv()
  local venv = find_venv()
  if not venv then
    print("No .venv found")
    return
  end
  require("telescope.builtin").live_grep({
    search_dirs = { venv },
    additional_args = function()
      return {
        "--hidden",
        "--no-ignore",
        "--glob", "*.py",
      }
    end,
  })
end


-- TODO bit excesive. Maybe we can reduce the LOC?
local function toggle_notebook()
  local file = vim.api.nvim_buf_get_name(0)
  if file == "" then
    print("No file available to convert")
    return
  end

  local ext = file:match("^.+(%..+)$")
  local target

  if ext == ".ipynb" then
    target = file:gsub("%.ipynb$", ".py")
  elseif ext == ".py" then
    target = file:gsub("%.py$", ".ipynb")
  else
    print("Not a .py or .ipynb file")
    return
  end

  local cmd = {
    "uv", "tool", "run", "jupytext",
    "--to", (ext == ".ipynb") and "py" or "ipynb",
    file,
  }

  vim.fn.jobstart(cmd, {
    stdout_buffered = true,
    stderr_buffered = true,
    on_exit = function(_, code)
      if code == 0 then
        print("Converted → " .. target)
        vim.cmd("edit " .. target)
      else
        print("Jupytext failed")
      end
    end,
  })
end


vim.keymap.set("n", "<leader>fv",  grep_venv,       { buffer = true })
vim.keymap.set("n", "<leader>W",   toggle_notebook, { buffer = true })

-----------------------------------------------------------------------------------------------------------------------
-- REPL (VIM-SLIME + VIM-IPYTHON-CELL)
-----------------------------------------------------------------------------------------------------------------------
vim.g.ipython_cell_highlight_cells = 0

-- Send cell to ipython shell
local function run_current_cell()
  vim.cmd.IPythonCellExecuteCellJump()
  Terminal.preview()
end

local function run_file()
  vim.cmd.write()
  vim.cmd.IPythonCellRun()
  Terminal.preview()
end

local function clear_ipython_screen()
  vim.cmd.IPythonCellClear()
  Terminal.preview()
end

vim.keymap.set({ "n"      }, M.a,  run_current_cell,                  { remap = true, buffer = true })
vim.keymap.set({ "n"      }, M.r,  run_file,                          { remap = true, buffer = true })
vim.keymap.set({ "n"      }, M.l,  clear_ipython_screen,              { remap = true, buffer = true })
vim.keymap.set({ "n", "v" }, M.j,  vim.cmd.IPythonCellNextCell,       { remap = true, buffer = true })
vim.keymap.set({ "n", "v" }, M.k,  vim.cmd.IPythonCellPrevCell,       { remap = true, buffer = true })
vim.keymap.set({ "n",     }, M.m,  vim.cmd.IPythonCellToMarkdown,     { remap = true, buffer = true })
vim.keymap.set({ "n"      }, M.lb, vim.cmd.IPythonCellInsertAbove,    { remap = true, buffer = true })
vim.keymap.set({ "n"      }, M.rb, vim.cmd.IPythonCellInsertBelow,    { remap = true, buffer = true })
vim.keymap.set({ "n"      }, M.c,  vim.cmd.IPythonCellClose,          { remap = true, buffer = true })
