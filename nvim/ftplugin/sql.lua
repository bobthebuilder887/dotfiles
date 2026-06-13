vim.wo.colorcolumn  = "0"

vim.bo.tabstop      = 4
vim.bo.shiftwidth   = 4
vim.bo.softtabstop  = 4

vim.bo.autoindent   = true
vim.bo.smartindent  = false
vim.bo.cindent      = false

local function assign_to_dbui()
  local buf  = vim.api.nvim_get_current_buf()
  local name = vim.api.nvim_buf_get_name(buf)
  local ft   = vim.bo[buf].filetype
  local bt   = vim.bo[buf].buftype
  -- TODO: add more filetypes and scenarios
  if (ft == "sql") or (name == "") or (bt == "sql") then
    vim.cmd.DBUIFindBuffer()
  end
end

-- assign_to_dbui()


local formats = {
  "FORMAT CSVWithNames",
  "FORMAT PrettyCompactMonoBlock",
}

local function get_last_nonempty_line(buf)
  local line_count = vim.api.nvim_buf_line_count(buf)

  for i = line_count, 1, -1 do
    local line = vim.api.nvim_buf_get_lines(buf, i - 1, i, false)[1]
    if line and line:match("%S") then
      return i, line
    end
  end

  return line_count, ""
end

local function toggle_format_cycle()
  local buf = vim.api.nvim_get_current_buf()
  local idx, last_line = get_last_nonempty_line(buf)

  local current_idx = nil

  if last_line:match("^%s*FORMAT%s+") then
    for i, f in ipairs(formats) do
      if last_line:match("^%s*" .. f) then
        current_idx = i
        break
      end
    end
  end

  if current_idx then
    -- move to next format or remove
    if current_idx == #formats then
      -- remove line (end of cycle)
      vim.api.nvim_buf_set_lines(buf, idx - 1, idx, false, {})
    else
      -- replace with next format
      vim.api.nvim_buf_set_lines(buf, idx - 1, idx, false, { formats[current_idx + 1] })
    end
  else
    -- no FORMAT → add first
    vim.api.nvim_buf_set_lines(buf, idx, idx, false, { formats[1] })
  end

  vim.cmd("write")
end

vim.keymap.set("n", "<leader>t", toggle_format_cycle, {
  buffer = true,
  desc = "Cycle FORMAT",
})
