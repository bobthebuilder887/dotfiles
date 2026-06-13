local function toggle_notebook()
  local buf = vim.api.nvim_get_current_buf()
  local file = vim.api.nvim_buf_get_name(buf)
  if file == "" then
    print("No file")
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
    "uv", "run", "jupytext",
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

local buf = vim.api.nvim_get_current_buf()
local file = vim.api.nvim_buf_get_name(0)
local ext = file:match("^.+(%..+)$")
if ext == ".ipynb" then
  vim.bo.readonly = true
end

vim.keymap.set("n", "<leader>W", toggle_notebook, {buffer=true})
