-- HIGH
-- TODO: Improved ClickHouse support, especially better syntax support but also some LSP support would be amazing
-- TODO: Lua-lsp needs to also be able to autocomplete require('plugin') type calls (+ go to plugin definition)
-- TODO: VERSION-CONTROL Need to improve my diff workflow for comparing both undo file histories (debug gpt version for git)
-- TODO: IMPROVE GIT WORKFLOW: - add common git commands / lazygit floating terminal for neovim leader + g/G + command
--  Need to be able to do something like <leader>go or <leader>Go to open the gitlab link in browser important for ipynb
--  ideally should work upon existing telescope and vimdiff features

-- MEDIUM
-- TODO: better folder navigation (add a filetree of some sorts make neovide as stand-alone as possible)
-- On a new window/tab it should not launch a new buffer but switch to netrw?
-- TODO: Improve debugging neovim. Make various fallback states if plugins break
-- TODO: Improve working with config files. Make a dedicated tab for them (don't open same thing in multiple tabs)
-- TODO: add python specific tools and settings, including linting, jupyter notebook support and formatting
-- TODO: Fix markdown issues for hover windows (so that markdown gets loaded + treesitter) 
-- TODO: Fix ipython cell not being highlighted properly
-- TODO: Improve DBUI and DBOUT. In particular improve window and buffer management around this plugin for better workflow with sql
-- potentially switch to dbee for pagination, better lsp support and query log

-- LOW
-- TODO: force read-only if a file exists and was never edited by me
-- TODO: Get to know folds (in particular good to have for undotree)
-- TODO: add treesitter highlights for !shell_cmd and markdown inside of python
-- TODO: Introduce various variables to make the files more manageable, e.g. global path variables to common directories
-- TODO: Review the input sources function that assigns keyboard layout icon. Is it really dependant on MacOS?
-- TODO: Maybe it is possible do some auto-command that remaps meta the keys on layout switch
-- TODO: Look into settings for Blink
-- TODO: Look into being able do manage lsp (diagnostics and restarts)

-----------------------------------------------------------------------------------------------------------------------
-- General settings
-----------------------------------------------------------------------------------------------------------------------

local home_path     = vim.loop.os_homedir()
local cfg_path      = home_path .. '/.config'
local projects_path = home_path .. '/Projects'
local query_path    = projects_path .. '/local_queries'

vim.g.python3_host_prog =  home_path .. "/.local/share/uv/tools/pynvim/bin/pynvim-python"
vim.g.mapleader         = " "  -- Map leader key to space


-- Meta keys in macos default keyboard layout
_G.M = { a = "å", c = "ç", j = "∆", k = "˚", l = "¬", m = "µ", o = "ø", p = "π", r = "®", t = "†", lb = "“", rb = "‘" }

local function input_source()

  if vim.fn.has("mac") == 0 then
    return ""
  end

  local out = vim.fn.system({
    "defaults",
    "read",
    "com.apple.HIToolbox.plist",
    "AppleCurrentKeyboardLayoutInputSourceID",
  })

  out = out:gsub("%s+", "")

  local names = {
    ["com.apple.keylayout.ABC"    ] = "",
    ["com.apple.keylayout.US"     ] = "🇺🇸",
    ["com.apple.keylayout.British"] = "🇬🇧",
    ["com.apple.keylayout.Latvian"] = "🇱🇻",
    ["com.apple.keylayout.Russian"] = "🇷🇺",
  }
  return names[out] or out:gsub("^com%.apple%.keylayout%.", "")
end

-- TODO look into a more dynamic version of this like in case of multiple windows or no tabs
function _G.MyWinbar()
  if vim.bo.buftype == "terminal" then
    return ""
  end
  return " " .. vim.fn.expand("%:t") .. " "
end
_G.StatuslineInputSource = input_source

-- Visuals
vim.o.colorcolumn     = '0'
vim.o.cursorcolumn    = false
vim.o.cursorline      = true

-- TODO make this context specific
vim.o.winbar          = "%{%v:lua.MyWinbar()%}"
vim.opt.laststatus    = 3      -- One global status line
vim.opt.statusline    = " %{toupper(mode())} ┃ %{v:lua.StatuslineInputSource()} ┃ %f%m%r %= %l:%c "
vim.opt.showmode      = false  -- Don't show separate line for vim mode to not hide commands

vim.o.guifont         = "Maple Mono NF:h16:#e-subpixelantialias"
vim.o.list            = false
vim.o.listchars       = "tab:→ ,trail:⋅,extends:»,precedes:«"

vim.o.number          = true
vim.o.relativenumber  = false

vim.o.signcolumn      = "yes"
vim.o.winborder       = "rounded"
vim.o.conceallevel    = 0

vim.o.wrap            = false
vim.wo.linebreak      = true
vim.wo.breakindent    = true
vim.wo.breakindentopt = "shift:2,sbr"
vim.wo.showbreak      = "↳ "

vim.o.lazyredraw      = true

vim.o.ttyfast         = true
-- Version control
vim.o.swapfile        = false  -- Don't use swap files. We can rely on undo history
vim.o.undofile        = true

-- Tabs vs spaces
vim.o.tabstop         = 4
vim.o.shiftwidth      = 4
vim.o.softtabstop     = 4
vim.o.expandtab       = true

vim.o.autoindent      = true
vim.o.smartindent     = true  -- for c-like programming languages which consider brackets when indenting
vim.o.cindent         = true  -- for c-like programming languages which consider brackets when indenting

-- Search settings
vim.o.ignorecase      = true
vim.o.smartcase       = true
vim.o.hlsearch        = false
vim.o.inccommand      = "split"  -- Show file changes from command mode in a new window (does not work in neovide??)
-- Buffers
vim.o.hidden          = true
vim.o.switchbuf       = "useopen"  -- Don't switch window when switching buffer
-- Windows
vim.o.splitright      = true
vim.o.splitbelow      = true

-- Basic Code completion TODO: I believe Blink overrides these
vim.o.complete        = ".,w,b,i"
vim.o.completeopt     = "menuone,popup,noinsert,noselect"
vim.o.omnifunc        = "v:lua.vim.lsp.omnifunc"
vim.o.wildmenu        = true
vim.o.wildmode        = "longest:full,full"

vim.o.cmdheight = 1
vim.opt.shortmess:append("I") -- no intro spam
vim.opt.shortmess:append("c") -- no completion spam

vim.o.smoothscroll = true
vim.o.scrolloff = 8

vim.o.sessionoptions = "buffers,curdir,folds,help,tabpages,winsize,winpos,terminal"

local function toggle_bg() -- Toggle between light and dark background
  vim.o.background = (vim.o.bg == "dark") and 'light' or 'dark'
end

local function toggle_read_only()
  vim.bo.readonly = not vim.bo.readonly
  print("READ-ONLY IS " .. (vim.bo.readonly and "ENABLED" or "DISABLED"))
end

local function toggle_wrap()
  vim.wo.wrap = not vim.wo.wrap
  print("Wrapping of text " .. (vim.wo.wrap and "ENABLED" or "DISABLED"))
end

vim.keymap.set("n", "<leader>B", toggle_bg,           { desc = "Toggle editor background" })
vim.keymap.set("n", "<leader>W", toggle_wrap,         { desc = "Toggle whitespace"        })
vim.keymap.set("n", "<leader>r", toggle_read_only,    { desc = "Toggle read-only"         })
vim.keymap.set("n", "<leader>O", ":e!<CR>",           { desc = "Reload file"              })
vim.keymap.set("n", "<leader>;", ":write<CR>",        { desc = "Save file"                })
vim.keymap.set("n", "<leader>R", ":restart<CR>",      { desc = "Restart Neovim"           })

vim.keymap.set({"i", "c", "t"}, "<C-h>", "<Left>")
vim.keymap.set({"i", "c", "t"}, "<C-j>", "<Down>")
vim.keymap.set({"i", "c", "t"}, "<C-k>", "<Up>")
vim.keymap.set({"i", "c", "t"}, "<C-l>", "<Right>")

-- Toggle search highlight when entering command mode
vim.api.nvim_create_autocmd("CmdLineEnter", {
  desc     = "Enable search highlighting when entering command mode",
  group    = vim.api.nvim_create_augroup('highlight-command-search', { clear = true }),
  callback = function() vim.o.hlsearch = true end,
})
vim.api.nvim_create_autocmd("CmdLineLeave", {
  desc     = "Disable search highlighting when exiting command mode",
  group    = "highlight-command-search",
  callback = function() vim.o.hlsearch = false end,
})
-- Highlight yanked area
vim.api.nvim_create_autocmd("TextYankPost", {
  desc     = "Highlight text when yanking",
  group    = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
  callback = function() vim.hl.on_yank() end,
})
-----------------------------------------------------------------------------------------------------------------------
-- Edit configs settings
-----------------------------------------------------------------------------------------------------------------------
function _G.ReloadConfig()
  local ok, err = pcall(function()
    -- clear cached lua modules (so changes actually reload)
    for name,_ in pairs(package.loaded) do
      if name:match("^user") or name:match("^config") then
        package.loaded[name] = nil
      end
    end
    -- reload your config (adjust if needed)
    dofile(vim.env.MYVIMRC)
    vim.cmd("doautocmd <nomodeline> FileType")
  end)

  if ok then
    vim.notify("Config reloaded ✅", vim.log.levels.INFO)
  else
    vim.notify("Reload failed ❌:\n" .. err, vim.log.levels.ERROR)
  end
end

local function edit_ftp()
  local ftp_dir      = vim.fn.stdpath("config") .. "/ftplugin"
  local ftp_cfg_file = ftp_dir .. "/" .. vim.bo.filetype .. ".lua"
  vim.fn.mkdir(ftp_dir, "p")
  vim.cmd.tabnew(vim.fn.fnameescape(ftp_cfg_file))
end

local function edit_cfg()
  local cfg_file = vim.fn.stdpath("config") .. "/init.lua"
  print(cfg_file)
  vim.cmd.tabnew(vim.fn.fnameescape(cfg_file))
end

local function check_msg()
  vim.cmd.enew()
  vim.cmd("put =execute('messages')")
end

vim.keymap.set("n", "<leader>o",  ReloadConfig,                        { desc = "Reload config"                 })
vim.keymap.set("n", "<leader>C",  edit_cfg,                            { desc = "Edit Nvim config"              })
vim.keymap.set("n", "<leader>mm", check_msg,                           { desc = "check error log"               })
vim.keymap.set("n", "<leader>L",  edit_ftp,                            { desc = "check error log"               })
-----------------------------------------------------------------------------------------------------------------------
-- Working with wrapped text
-----------------------------------------------------------------------------------------------------------------------
vim.keymap.set({ "n", "x", "v" }, "j", "gj")
vim.keymap.set({ "n", "x", "v" }, "k", "gk")
vim.keymap.set({ "n", "x", "v" }, "0", "g0")
vim.keymap.set({ "n", "x", "v" }, "$", "g$")
vim.keymap.set({ "n", "x", "v" }, "^", "g^")
-----------------------------------------------------------------------------------------------------------------------
-- System clipboard
-----------------------------------------------------------------------------------------------------------------------
vim.keymap.set({ "n", "v", "x"      }, "<leader>y", '"+y<CR>', { desc = "Yank to clipboard"    })
vim.keymap.set({ "n", "v", "x"      }, "<leader>d", '"+d<CR>', { desc = "Delete to clipboard"  })
vim.keymap.set({ "n", "v", "x"      }, "<leader>p", '"+p<CR>', { desc = "Paste from clipboard" })
vim.keymap.set({ "n", "v", "x"      }, "<leader>P", '"+P<CR>', { desc = "Paste from clipboard" })
vim.keymap.set({ "n", "v", "x"      }, "<D-v>",     '"+p<CR>', { desc = "paste with cmd+v"     })
vim.keymap.set({ "i", "c"           }, "<D-v>",     '<C-r>+',  { desc = "paste with cmd+v"     })
vim.keymap.set({ "n", "v", "x", "c" }, "<D-c>",     '"+y<CR>', { desc = "copy with cmd+c"      })
vim.keymap.set({ "n", "v", "x", "c" }, "<D-x>",     '"+d<CR>', { desc = "cut with cmd+x"       })
-----------------------------------------------------------------------------------------------------------------------
-- LSP 
-----------------------------------------------------------------------------------------------------------------------
vim.keymap.set({ "n", "x", "v" }, "gd",  vim.lsp.buf.definition, { desc = "Go to definition"  })
vim.keymap.set({ "n", "x", "v" }, "grn", vim.lsp.buf.rename,     { desc = "Rename a variable" })

vim.diagnostic.config({
  virtual_text     = true,
  signs            = true,
  underline        = true,
  update_in_insert = false,
  severity_sort    = true,
  severity         = {
    min = vim.diagnostic.severity.ERROR,
  },
})

vim.diagnostic.enable(false)
vim.keymap.set("n", "<leader>T", function()
  local enabled = vim.diagnostic.is_enabled()
  enabled = not enabled
  vim.diagnostic.enable(enabled)
  print("DIAGNOSTICS " .. (enabled and "ENABLED" or "DISABLED"))
end)

-- TODO: temporary fix for treesitter markdown errors
vim.lsp.util.open_floating_preview = (function(orig)
  return function(contents, syntax, opts, ...)
    if syntax == "markdown" then
      syntax = "text"
    end
    return orig(contents, syntax, opts, ...)
  end
end)(vim.lsp.util.open_floating_preview)

-----------------------------------------------------------------------------------------------------------------------
-- TERMINAL 
-----------------------------------------------------------------------------------------------------------------------
vim.api.nvim_create_autocmd("TermOpen", {
  callback = function(args)
    vim.wo.list = false
    vim.opt_local.number         = false
    vim.opt_local.relativenumber = false
    vim.opt_local.signcolumn     = "no"
    vim.opt_local.foldcolumn     = "0"
    TermBuf                      = args.buf
    vim.bo[args.buf].buflisted   = false  -- Keep a private buffer
  end,
})


-- TODO find a nicer way to organise this code
-- Finds if a buf exists and if it is assigned to any window currently
local function buff_win_find(buf)
  if not buf or not vim.api.nvim_buf_is_valid(buf) then
    return nil
  end
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_is_valid(win)
        and vim.api.nvim_win_get_buf(win) == buf then
      return win
    end
  end
  return nil
end

local TermWin = nil
if TermBuf then
  TermWin = buff_win_find(TermBuf)
end

local function term_win_close()

  if TermBuf and not vim.api.nvim_buf_is_valid(TermBuf) then
    TermBuf = nil
  end

  if TermWin and vim.api.nvim_win_is_valid(TermWin) then
    vim.api.nvim_win_close(TermWin, true)
    TermWin = nil
    return true
  end
end

local function term_win_open()
  if TermWin and vim.api.nvim_win_is_valid(TermWin) then
    vim.api.nvim_set_current_win(TermWin)
    return
  end

  -- Start a new window bottom of the screen
  vim.cmd("botright 10split")
  TermWin = vim.api.nvim_get_current_win()
  -- reuse existing terminal if buffer exists
  if TermBuf and vim.api.nvim_buf_is_valid(TermBuf) then
    vim.api.nvim_win_set_buf(TermWin, TermBuf)
  else -- open new buffer if does not exist
    vim.cmd("terminal")
    TermBuf = vim.api.nvim_get_current_buf()
    vim.schedule(function()
       if vim.api.nvim_buf_is_valid(TermBuf) then
         local chan = vim.bo[TermBuf].channel

         vim.api.nvim_chan_send(
           chan,
           "tmux attach-session -t 0 || tmux\n"
         )
       end
     end)
  end
end

local function term_win_preview()
  -- save curent window and buffer to switch back
  local cur_win = vim.api.nvim_get_current_win()
  -- make a split
  term_win_open()
  -- go back to where you came from
  vim.api.nvim_set_current_win(cur_win)
end

local function term_win_toggle()
  -- if window open, close and do nothing
  if term_win_close() then
    return
  end
  term_win_preview()
end

local function term_win_insert()
  term_win_open()
  vim.cmd("startinsert")
end

local function term_win_exit_insert()
  vim.cmd("stopinsert")
end

local function term_win_leave()
  vim.cmd("stopinsert")
  vim.cmd("wincmd k")
end

local function term_win_insert_or_leave()

  local cur_win = vim.api.nvim_get_current_win()

  if cur_win == TermWin then
    term_win_leave()
  else
    term_win_insert()
  end
end

_G.Terminal = {
  open          = term_win_open,
  close         = term_win_close,
  preview       = term_win_preview,
  toggle        = term_win_toggle,
  toggle_insert = term_win_insert_or_leave,
  exit_insert   = term_win_exit_insert,
}

vim.keymap.set({"n", "t"}, M.o, Terminal.toggle,        { desc = "Toggle terminal preview"                    })
vim.keymap.set({"n", "t"}, M.p, Terminal.toggle_insert, { desc = "Toggle terminal mode (leaves preview open)" })
vim.keymap.set({"t"     }, M.a, Terminal.exit_insert,   { desc = "Exit insert mode (stays in terminal window" })

-----------------------------------------------------------------------------------------------------------------------
-- BUFFERS
-----------------------------------------------------------------------------------------------------------------------
local function buffer_delete()
  local buf = vim.api.nvim_get_current_buf()
  local name = vim.api.nvim_buf_get_name(buf)
  local ft   = vim.bo[buf].filetype
  local bt   = vim.bo[buf].buftype
  local force =
    name == ""
    or name:match("/local_queries/")
    or name:match("fq")
    or ft == "dbui"
    or ft == "dbout"
    or bt == "terminal"
    or bt == "nofile"

  term_win_close()
  vim.cmd((force and "bdelete! " or "bdelete ") .. buf)
end

local function open_vis_in_new_buff()
  local ft = vim.bo.filetype
  vim.cmd("normal! y")
  vim.cmd("enew")
  vim.bo.filetype = ft
  vim.cmd("put")
end

vim.keymap.set({ "v", "x"      }, "<leader>e",  open_vis_in_new_buff, { desc = "edit visual selection in new buffer" })
vim.keymap.set({ "n", "v"      }, "<C-J>",      ":bnext<CR>",         { desc = "Go to next buffer"                   })
vim.keymap.set({ "n", "v"      }, "<C-K>",      ":bprevious<CR>",     { desc = "Go to previous buffer"               })
vim.keymap.set({ "n"           }, "<leader>q",  buffer_delete,        { desc = "Del buffer but keep layout"          })
-- Windows
vim.keymap.set({ "n", "x", "v" }, "<leader>w",  "<C-W>",              { desc = "Window command"                      })
-- Tabs
vim.keymap.set({ "n"           }, "<leader>tn",  ":tabnext<CR>",      { desc = "Go to next tab"                      })
vim.keymap.set({ "n"           }, "<leader>tN", ":tabnew<CR>",        { desc = "Make a new buffer in new tab"        })
vim.keymap.set({ "n"           }, "<leader>tp", ":tabprevious<CR>",   { desc = "Go to prev tab"                      })
vim.keymap.set({ "n"           }, "<leader>tq", ":tabclose<CR>",      { desc = "Close current tab"                   })

-----------------------------------------------------------------------------------------------------------------------
-- NEOVIDE
-----------------------------------------------------------------------------------------------------------------------
if vim.g.neovide then

  local default_scale_factor = 1.1

  vim.o.inccommand   = "nosplit"
  vim.o.smoothscroll = false
  vim.o.lazyredraw   = false

  vim.g.neovide_theme = "auto"

  vim.g.neovide_cursor_animation_length   = 0
  vim.g.neovide_cursor_trail_size         = 0
  vim.g.neovide_cursor_antialiasing       = false
  vim.g.neovide_cursor_animation_length   = 0

  vim.g.neovide_floating_blur_amount_x    = 0
  vim.g.neovide_floating_blur_amount_y    = 0
  vim.g.neovide_position_animation_length = 0
  vim.g.neovide_scroll_animation_length   = 0 -- .1

  vim.g.neovide_refresh_rate              = 300
  vim.g.neovide_refresh_rate_idle         = 5
  vim.g.neovide_no_idle                   = false

  vim.g.neovide_scale_factor              = default_scale_factor
  vim.g.neovide_fullscreen                = true

  local function upscale()
    vim.g.neovide_scale_factor = (vim.g.neovide_scale_factor or 1.0) + 0.1
  end

  local function downscale()
    vim.g.neovide_scale_factor = (vim.g.neovide_scale_factor or 1.0) - 0.1
  end

  local function restart_neovide()

    Terminal.close()

    local session = vim.fn.stdpath("state") .. "/neovide-restart-session.vim"

    vim.cmd("mksession! " .. vim.fn.fnameescape(session))

    local job = vim.fn.jobstart({
      "open", "-n", "-a", "Neovide",
      "--args",
      "--", "-S", session,
    }, { detach = true })

    if job <= 0 then
      vim.notify("Failed to restart Neovide", vim.log.levels.ERROR)
    return
    end

    vim.cmd("qa!")
  end

  local function reset_scale()
    vim.g.neovide_scale_factor = default_scale_factor
  end
  -- TODO: think of other common mac os shortcuts. What about windw management?
  -- TODO: Perhaps some way of moving external buffers into new windows?
  vim.keymap.set({ "n", "v", "x", "i", "c", "t" }, "<D-s>",  vim.cmd.write,      { desc = "Save file"                 })

  vim.keymap.set({ "n", "v", "x", "i", "c", "t" }, "<D-=>",  upscale,            { desc = "Scale up Neovide"          })
  vim.keymap.set({ "n", "v", "x", "i", "c", "t" }, "<D-->",  downscale,          { desc = "Scale down Neovide"        })
  vim.keymap.set({ "n", "v", "x", "i", "c", "t" }, "<D-0>",  reset_scale,        { desc = "Reset zoom"                })
  vim.keymap.set({ "n", "v", "x", "i", "c", "t" }, "<D-R>",  restart_neovide,    { desc = "Restart Neovide"           })

  vim.keymap.set({ "n", "v", "x", "i", "c", "t" }, "<D-h>",  "<C-W>h",           { desc = "Go to right window"        })
  vim.keymap.set({ "n", "v", "x", "i", "c", "t" }, "<D-j>",  "<C-W>j",           { desc = "Go to window below"        })
  vim.keymap.set({ "n", "v", "x", "i", "c", "t" }, "<D-k>",  "<C-W>k",           { desc = "Go to window above"        })
  vim.keymap.set({ "n", "v", "x", "i", "c", "t" }, "<D-l>",  "<C-W>l",           { desc = "Go to window to the right" })
  vim.keymap.set({ "n", "v", "x", "i", "c", "t" }, "<D-H>",  "<C-W>H",           { desc = "Move window to the left"   })
  vim.keymap.set({ "n", "v", "x", "i", "c", "t" }, "<D-J>",  "<C-W>J",           { desc = "Move window below"         })
  vim.keymap.set({ "n", "v", "x", "i", "c", "t" }, "<D-K>",  "<C-W>K",           { desc = "Move window above"         })
  vim.keymap.set({ "n", "v", "x", "i", "c", "t" }, "<D-L>",  "<C-W>L",           { desc = "Move window to the right"  })
  vim.keymap.set({ "n", "v", "x", "i", "c", "t" }, "<D-_>",  "<C-W>=",           { desc = "Equalize windows"          })

  vim.keymap.set({ "n", "v", "x", "i", "c", "t" }, "<D-t>",  vim.cmd.tabnew,     { desc = "Open new tab"              })
  vim.keymap.set({ "n", "v", "x", "i", "c", "t" }, "<D-w>",  vim.cmd.tabclose,   { desc = "Close a tab"               })
  vim.keymap.set({ "n", "v", "x", "i", "c", "t" }, "<D-}>",  vim.cmd.tabnext,    { desc = "Go to next tab"            })
  vim.keymap.set({ "n", "v", "x", "i", "c", "t" }, "<D-{>",  vim.cmd.tabprev,    { desc = "Go to previous tab"        })
  vim.keymap.set({ "n", "v", "x", "i", "c", "t" }, "<D-1>",  ":1tabn<CR>",       { desc = "Go to tab 1"               })
  vim.keymap.set({ "n", "v", "x", "i", "c", "t" }, "<D-2>",  ":2tabn<CR>",       { desc = "Go to tab 2"               })
  vim.keymap.set({ "n", "v", "x", "i", "c", "t" }, "<D-3>",  ":3tabn<CR>",       { desc = "Go to tab 3"               })
  vim.keymap.set({ "n", "v", "x", "i", "c", "t" }, "<D-4>",  ":4tabn<CR>",       { desc = "Go to tab 4"               })
  vim.keymap.set({ "n", "v", "x", "i", "c", "t" }, "<D-5>",  ":5tabn<CR>",       { desc = "Go to tab 5"               })
  vim.keymap.set({ "n", "v", "x", "i", "c", "t" }, "<D-6>",  ":6tabn<CR>",       { desc = "Go to tab 6"               })
  vim.keymap.set({ "n", "v", "x", "i", "c", "t" }, "<D-7>",  ":7tabn<CR>",       { desc = "Go to tab 7"               })
  vim.keymap.set({ "n", "v", "x", "i", "c", "t" }, "<D-8>",  ":8tabn<CR>",       { desc = "Go to tab 8"               })
  vim.keymap.set({ "n", "v", "x", "i", "c", "t" }, "<D-9>",  ":9tabn<CR>",       { desc = "Go to tab 9"               })

  local function tab_view()
    -- TODO the logic is incomplete here. It needs to track the original source
    -- e.g. if there is a buffer open
    local tab = vim.api.nvim_get_current_tabpage()
    local buf = vim.api.nvim_get_current_buf()
    local name = vim.api.nvim_buf_get_name(buf)
    local n_windows = #vim.api.nvim_tabpage_list_wins(tab)
    if tab ~= 0 and n_windows < 2 then
      vim.cmd.tabclose()
      return
    elseif n_windows < 2 then
      return
    end
    -- Open the buffer in a new tab
    vim.cmd("tabedit " .. name)
    -- vim.api.nvim_set_current_buf(buf)
  end

  vim.keymap.set({ "n", "v", "x", "i", "c", "t" }, "<D-+>",tab_view,  { desc = "Maximize current window" })

  local function open_lazygit_float()

    local source_file = vim.api.nvim_buf_get_name(0)
    if vim.fn.filereadable(source_file) ~= 1 or vim.bo[0].buftype ~= "" then
      return
    end

    local source_dir = source_file ~= ""
        and vim.fn.fnamemodify(source_file, ":p:h")
        or vim.fn.getcwd()
    local root = vim.fn.systemlist({
      "git", "-C", source_dir, "rev-parse", "--show-toplevel"
    })[1]

    if vim.v.shell_error ~= 0 or not root or root == "" then
      root = source_dir
    end
    local width  = math.floor(vim.o.columns * 0.9)
    local height = math.floor(vim.o.lines * 0.9)
    LazyGitBuf = vim.api.nvim_create_buf(false, true)
    LazyGitWin = vim.api.nvim_open_win(LazyGitBuf, true, {
      relative = "editor",
      width = width,
      height = height,
      row = math.floor((vim.o.lines - height) / 2),
      col = math.floor((vim.o.columns - width) / 2),
      style = "minimal",
      border = "rounded",
    })
    vim.fn.termopen("lazygit", {
      cwd = root,
      on_exit = function()
        vim.schedule(function()
          if LazyGitWin and vim.api.nvim_win_is_valid(LazyGitWin) then
            vim.api.nvim_win_close(LazyGitWin, true)
          end
          if LazyGitBuf and vim.api.nvim_buf_is_valid(LazyGitBuf) then
            vim.api.nvim_buf_delete(LazyGitBuf, { force = true })
          end
          LazyGitWin = nil
          LazyGitBuf = nil
        end)
      end,
    })
    vim.cmd("startinsert")
  end
  vim.keymap.set({ "n" }, "<D-g>", open_lazygit_float, { desc = "Open lazygit floating terminal", })
end
-----------------------------------------------------------------------------------------------------------------------
-- PLUGINS <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
-----------------------------------------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------------------------------------
--- UNDOTREE
-----------------------------------------------------------------------------------------------------------------------
if vim.o.undofile then

  vim.cmd("packadd nvim.undotree")
  vim.keymap.set({"n"}, "<leader>u", function() require("undotree").open({command="8 split new"}) end, { desc = "toggle built-in Undotree" })

  vim.keymap.set("n", "<leader>uC", function()
    local undo = vim.fn.undofile(vim.fn.expand("%"))
    vim.opt.undolevels = -1
    vim.opt.undolevels = 1000
    vim.fn.delete(undo)
    print("Undo history cleared")
  end, { desc = "Clear undo history of a file" })

end
-----------------------------------------------------------------------------------------------------------------------
-- TREE-SITTER
-----------------------------------------------------------------------------------------------------------------------
vim.pack.add({ { src = "https://github.com/nvim-treesitter/nvim-treesitter" } })
require('nvim-treesitter.configs').setup({
  ensure_installed = { "python", "sql", "lua", "vim", "markdown", "c", "json" },
  highlight = { enable = true, additional_vim_regex_highlighting = false },
  indent = { enable = true, },
})

vim.o.foldexpr = "nvim_treesitter#foldexpr()"

-----------------------------------------------------------------------------------------------------------------------
-- GITSIGNS
-----------------------------------------------------------------------------------------------------------------------
vim.pack.add({{ src = "https://github.com/lewis6991/gitsigns.nvim", }})
require('gitsigns').setup {
  signs = {
    add          = { text = '┃' },
    change       = { text = '┃' },
    delete       = { text = '_' },
    topdelete    = { text = '‾' },
    changedelete = { text = '~' },
    untracked    = { text = '┆' },
  },
  signs_staged = {
    add          = { text = '┃' },
    change       = { text = '┃' },
    delete       = { text = '_' },
    topdelete    = { text = '‾' },
    changedelete = { text = '~' },
    untracked    = { text = '┆' },
  },
  signs_staged_enable = true,
  signcolumn = true,  -- Toggle with `:Gitsigns toggle_signs`
  numhl      = false, -- Toggle with `:Gitsigns toggle_numhl`
  linehl     = false, -- Toggle with `:Gitsigns toggle_linehl`
  word_diff  = false, -- Toggle with `:Gitsigns toggle_word_diff`
  watch_gitdir = {
    follow_files = true
  },
  auto_attach = true,
  attach_to_untracked = false,
  current_line_blame = false, -- Toggle with `:Gitsigns toggle_current_line_blame`
  current_line_blame_opts = {
    virt_text = true,
    virt_text_pos = 'eol', -- 'eol' | 'overlay' | 'right_align'
    delay = 1000,
    ignore_whitespace = false,
    virt_text_priority = 100,
    use_focus = true,
  },
  current_line_blame_formatter = '<author>, <author_time:%R> - <summary>',
  blame_formatter = nil, -- Use default
  sign_priority = 6,
  update_debounce = 100,
  status_formatter = nil, -- Use default
  max_file_length = 40000, -- Disable if file is longer than this (in lines)
  preview_config = {
    -- Options passed to nvim_open_win
    style = 'minimal',
    relative = 'cursor',
    row = 0,
    col = 1
  },
}
-----------------------------------------------------------------------------------------------------------------------
-- DADBOD
-----------------------------------------------------------------------------------------------------------------------
vim.pack.add({
  { src = 'https://github.com/tpope/vim-dadbod'                     },
  { src = 'https://github.com/kristijanhusak/vim-dadbod-completion' },
  { src = 'https://github.com/kristijanhusak/vim-dadbod-ui'         },
})

local helpers = {
  clickhouse =  {
    Columns   = "SELECT name, type FROM system.columns where database='{dbname}' AND table='{table}' FORMAT PrettyCompactMonoBlock",
    TableInfo = "SELECT name, uuid, engine, is_temporary, data_paths, metadata_path, metadata_modification_time, metadata_version, dependencies_table, create_table_query, engine_full, as_select, partition_key, sorting_key, primary_key, sampling_key, storage_policy, total_rows, formatReadableSize(total_bytes) AS total_size, formatReadableSize(total_bytes_uncompressed) AS total_size_uncompressed, parts, active_parts, total_marks, active_on_fly_data_mutations, active_on_fly_metadata_mutations, lifetime_rows, lifetime_bytes, comment, has_own_data, loading_dependencies_table, loading_dependent_table  FROM system.tables where database='{dbname}' AND table='{table}' FORMAT PrettyCompactMonoBlock",
    Count     = "SELECT Count() FROM `{dbname}`.`{table}` FORMAT PrettyCompactMonoBlock",
    Preview   = "SELECT * FROM `{dbname}`.`{table}` LIMIT 500 FORMAT PrettyCompactMonoBlock",
    List      = ""
  }
}
vim.g.db_ui_save_location              = query_path
vim.g.db_ui_table_helpers              = helpers
vim.g.db_ui_use_nerd_fonts             = 1  -- Nerd Fonts in the picker
vim.g.db_ui_execute_on_save            = 0  -- Don't run query on save
vim.g.db_ui_use_nvim_notify            = 1  -- Use native notifications (no pop-up)
vim.g.db_ui_auto_execute_table_helpers = 1  -- Run helpers on Enter press

local function toggle_dbui()
  if (vim.bo.filetype == "dbui") then
    vim.cmd.DBUIClose()
  else
    vim.cmd.DBUI()
  end
end

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

-- TODO we can improve this?
local function fix_dbout_errors(args)
  vim.schedule(function()

    if not vim.api.nvim_buf_is_valid(args.buf) then return end
    if vim.bo[args.buf].filetype ~= "dbout" then return end
    vim.bo[args.buf].modifiable  = true
    vim.bo[args.buf].readonly    = false

    local first = vim.api.nvim_buf_get_lines(args.buf, 0, 1, false)[1] or ""
    if first:match("^Error") or first:match("^Received") then
      local win = vim.fn.bufwinid(args.buf)
      if win ~= -1 then
        vim.api.nvim_win_call(win, function()
          vim.cmd("normal! gww")
        end)
      end
    end
  end)
end

vim.api.nvim_create_autocmd({ "FileType", "BufEnter", "BufWinEnter" }, {
  pattern = "dbout",
  callback = fix_dbout_errors,
})


local function make_dbout_editable(args)
  vim.schedule(function()
    if vim.api.nvim_buf_is_valid(args.buf) and vim.bo[args.buf].filetype == "dbout" then
      vim.bo[args.buf].modifiable = true
      vim.bo[args.buf].readonly = false
    end
  end)
end

vim.api.nvim_create_autocmd({ "FileType", "BufEnter", "BufWinEnter" }, {
  pattern = "dbout",
  callback = make_dbout_editable,
})

vim.keymap.set("n", "<leader>d", toggle_dbui,           { desc = "toggle dadbod"         })
vim.keymap.set("n", "<leader>s", assign_to_dbui,        { desc = "Assign buffer to dbui" })
-----------------------------------------------------------------------------------------------------------------------
-- TELESCOPE
-----------------------------------------------------------------------------------------------------------------------

vim.pack.add({
  { src = "https://github.com/nvim-lua/plenary.nvim" },
  { src = "https://github.com/nvim-telescope/telescope-fzf-native.nvim" },
  { src = "https://github.com/nvim-telescope/telescope.nvim" },
})

require("telescope").setup({
  defaults = {
    path_display = { "smart" },
    layout_strategy = "vertical",
    layout_config = {
      width           = 0.99,
      height          = 0.99,
      preview_height  = 0.6, -- preview on top
      prompt_position = "bottom",
    },
  },
    extensions = {fzf = {}}
})
pcall(vim.system, { "make" }, { cwd = vim.fn.stdpath("data") .. "/site/pack/core/opt/telescope-fzf-native.nvim" })
require("telescope").load_extension("fzf")

local builtin      = require('telescope.builtin'      )
local pickers      = require("telescope.pickers"      )
local finders      = require("telescope.finders"      )
local conf         = require("telescope.config"       ).values
local actions      = require("telescope.actions"      )
local action_state = require("telescope.actions.state")


-- TODO see if we can actually move to fff?
local function fzf_all_files()
  local lines = {}
  -- collect all listed buffers
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(bufnr) and vim.bo[bufnr].buflisted then
      -- local name = vim.api.nvim_buf_get_name(bufnr)
      local name = vim.fn.fnamemodify( vim.api.nvim_buf_get_name(bufnr), ":t")
      local buf_lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
      for i, line in ipairs(buf_lines) do
        table.insert(lines, {
          text = string.format("%s:%d: %s", name, i, line),
          bufnr = bufnr,
          lnum = i,
        })
      end
    end
  end

  pickers.new({}, {
    prompt_title = "All Buffers (virtual)",
    finder = finders.new_table({
      results = lines,
      entry_maker = function(entry)
        return {
          value = entry,
          display = entry.text,
          ordinal = entry.text,
        }
      end,
    }),
    sorter = conf.generic_sorter({}),
    previewer = nil, -- conf.grep_previewer({}),
    attach_mappings = function(_, map)
      map("i", "<CR>", function(prompt_bufnr)
        local selection = action_state.get_selected_entry().value
        actions.close(prompt_bufnr)
        vim.api.nvim_set_current_buf(selection.bufnr)
        vim.api.nvim_win_set_cursor(0, { selection.lnum, 0 })
      end)
      return true
    end,
  }):find()
end


local function git_root_for_file(file)
  local dir = vim.fn.fnamemodify(file, ":p:h")
  local root = vim.fn.systemlist({ "git", "-C", dir, "rev-parse", "--show-toplevel" })[1]

  if vim.v.shell_error ~= 0 or not root or root == "" then
    return nil
  end

  return vim.fs.normalize(root)
end

local function git_relpath(root, file)
  file = vim.fs.normalize(vim.fn.fnamemodify(file, ":p"))

  local rel = vim.fs.relpath(root, file)
  if rel then
    return rel
  end

  return file:sub(#root + 2)
end

local function git_commit_from_entry(entry)
  local text = entry.value or entry.ordinal or entry.display
  if type(text) == "table" then
    text = text.value or text.ordinal or text.display
  end
  return tostring(text):match("^%S+")
end

local function git_diff_selected_commit(prompt_bufnr)
  local entry = action_state.get_selected_entry()
  actions.close(prompt_bufnr)

  local commit = git_commit_from_entry(entry)
  local file   = vim.fn.expand("%:p")
  local ft     = vim.bo.filetype

  local root = git_root_for_file(file)
  if not root then
    vim.notify("Not inside a git repo", vim.log.levels.WARN)
    return
  end

  local rel = git_relpath(root, file)

  local old = vim.fn.systemlist({
    "git", "-C", root, "show", commit .. ":" .. rel
  })

  if vim.v.shell_error ~= 0 then
    vim.notify("Could not load " .. rel .. " at " .. commit, vim.log.levels.ERROR)
    return
  end

  vim.cmd("tabnew " .. vim.fn.fnameescape(file))
  vim.cmd("diffthis")

  vim.cmd("vnew")
  local commit_buf = vim.api.nvim_get_current_buf()

  vim.api.nvim_buf_set_lines(commit_buf, 0, -1, false, old)
  vim.api.nvim_buf_set_name(commit_buf, commit .. ":" .. rel)

  vim.bo[commit_buf].buftype    = "nofile"
  vim.bo[commit_buf].bufhidden  = "wipe"
  vim.bo[commit_buf].swapfile   = false
  vim.bo[commit_buf].modifiable = false
  vim.bo[commit_buf].readonly   = true
  vim.bo[commit_buf].filetype   = ft

  vim.cmd("diffthis")
  vim.cmd("wincmd h")
end

local git_cmd = { "git", "log", "--pretty=%h %s || %ae (%ad)", "--abbrev-commit", "--date=format:%Y-%m-%d %H:%M", }

local function git_opts_for_current_file()
  local file = vim.fn.expand("%:p")
  local root = git_root_for_file(file)

  return {
    cwd = root,
    use_git_root = false,
    use_file_path = true,
    git_command = git_cmd,
    attach_mappings = function(prompt_bufnr, map)
      map("i", "<CR>", git_diff_selected_commit)
      map("n", "<CR>", git_diff_selected_commit)
      return true
    end,
  }
end

local function browse_git_repo() builtin.git_commits(git_opts_for_current_file())           end
local function browse_git_file() builtin.git_bcommits(git_opts_for_current_file())          end
local function fzf_buffer()      builtin.current_buffer_fuzzy_find({skip_empty_lines=true}) end

vim.keymap.set('n', '<leader>fh',       builtin.help_tags,         { desc = 'vim help'                                })
vim.keymap.set('n', '<leader><leader>', builtin.buffers,           { desc = 'Telescope buffers'                       })
vim.keymap.set('n', '<leader>"',        builtin.registers,         { desc = 'Search vim registers'                    })
vim.keymap.set('n', '<leader>h',        builtin.command_history,   { desc = 'Search vim command history'              })
vim.keymap.set("n", "<leader>/",        fzf_buffer,                { desc = 'fzf in current buffer'                   })
vim.keymap.set("n", "<leader>G",        browse_git_repo,           { desc = 'Browse git commit history of repo'       })
vim.keymap.set("n", "<leader>g",        browse_git_file,           { desc = 'Browse git commit history of file'       })
vim.keymap.set("n", "<leader>,",        fzf_all_files,             { desc = 'combine all open files into one and fzf' })
vim.keymap.set("n", "<leader>cs",       builtin.colorscheme,       { desc = 'Pick a colorscheme'                      })

-----------------------------------------------------------------------------------------------------------------------
-- FFF
-----------------------------------------------------------------------------------------------------------------------

vim.pack.add({ 'https://github.com/dmtrKovalenko/fff.nvim' })

vim.api.nvim_create_autocmd('PackChanged', {
  callback = function(ev)
    local name, kind = ev.data.spec.name, ev.data.kind
    if name == 'fff.nvim' and (kind == 'install' or kind == 'update') then
      if not ev.data.active then vim.cmd.packadd('fff.nvim') end
      require('fff.download').download_or_build_binary()
    end
  end,
})

vim.g.fff = {
  lazy_sync = true,
  debug = { enabled = true, show_scores = true },
  layout = { height = 0.99, width = 0.99, prompt_position = 'bottom', preview_position = "top", preview_size=0.6 },
}
local fff = require("fff")

local function fff_files(opts)
  opts = opts or {}
  if opts.cwd then
    fff.find_files_in_dir(opts.cwd)
  else
    fff.find_files()
  end
end

local function cfg_files()     fff_files({ cwd = cfg_path      }) end
local function sql_files()     fff_files({ cwd = query_path    }) end
local function project_files() fff_files({ cwd = projects_path }) end

vim.keymap.set("n", "<leader>ff", function() fff.find_files() end, { desc = "fff files in local dir" })
vim.keymap.set("n", "<leader>fp", project_files,                   { desc = "fff files in Projects"  })
vim.keymap.set("n", "<leader>fq", sql_files,                       { desc = "fff queries"            })
vim.keymap.set("n", "<leader>cc", cfg_files,                       { desc = "fff configs"            })
vim.keymap.set("n", "<leader>fg", function() fff.live_grep() end,  { desc = "fff live grep"          })

-----------------------------------------------------------------------------------------------------------------------
-- Indentation lines MINI and INDENT-BLANKLINE
-----------------------------------------------------------------------------------------------------------------------
vim.pack.add({
  { src = "https://github.com/nvim-mini/mini.indentscope" },
  { src = 'https://github.com/lukas-reineke/indent-blankline.nvim' }
})
require("mini.indentscope").setup({
  draw = {delay = 0, animation = require('mini.indentscope').gen_animation.none()},
  mappings = { object_scope = '', object_scope_with_border = '', goto_top = '', goto_bottom = '', },
})
require("ibl").setup()
-----------------------------------------------------------------------------------------------------------------------
-- BLINK (AUTO-COMPLETE)
-----------------------------------------------------------------------------------------------------------------------
vim.pack.add({"https://github.com/Saghen/blink.lib"})
vim.pack.add({"https://github.com/Saghen/blink.cmp"})
-- require('blink.cmp').build():pwait()

vim.pack.add({ { src = "https://github.com/Saghen/blink.cmp", version = vim.version.range("*") } })
require("blink.cmp").setup({
  sources = {
    default = {
      "lsp",
      "path",
      "buffer",
      "dadbod",
    },
    providers = {
      dadbod = {
        name = "Dadbod",
        module = "vim_dadbod_completion.blink",
      },
    },
  },
  fuzzy = { implementation = "prefer_rust_with_warning" } ,
  completion = {
    documentation = {
    auto_show = true,
    treesitter_highlighting = false,
  },
},
  keymap = {
  preset = "default",

  ["<C-g>"] = {
    function(cmp)
      cmp.hide()
      vim.schedule(function()
        vim.cmd.stopinsert()
        vim.lsp.buf.definition()
      end)
      return true
    end,
    "fallback",
  },
},
})

-- TODO: is this even required?
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "sql", "mysql", "plsql", "python" },
  callback = function()
    vim.bo.omnifunc = "vim_dadbod_completion#omni"
  end,
})

-----------------------------------------------------------------------------------------------------------------------
-- REPL (VIM-SLIME + VIM-IPYTHON-CELL) local
-----------------------------------------------------------------------------------------------------------------------
vim.pack.add({
  { src = 'https://github.com/jpalardy/vim-slime' },
  { src = 'https://github.com/hanschen/vim-ipython-cell' },
})
vim.g.slime_target           = "tmux"
vim.g.slime_default_config   = { socket_name = "default", target_pane= "1" }
vim.g.slime_dont_ask_default = 1
vim.g.slime_python_ipython   = 1
vim.g.slime_no_mappings      = 1
vim.g.slime_cell_delimiter   = "# %%"

local function send_visual_selection()
  local keys = vim.api.nvim_replace_termcodes("<Plug>SlimeRegionSend", true, false, true)
  vim.api.nvim_feedkeys(keys, "m", false)
  vim.schedule(Terminal.preview)
end

vim.keymap.set({ "v", "x" }, M.a,  send_visual_selection, { desc = "Send visual selection to shell", remap = true })

-----------------------------------------------------------------------------------------------------------------------
-- FileTree with Oil
-----------------------------------------------------------------------------------------------------------------------
vim.pack.add({
  { src = 'https://github.com/stevearc/oil.nvim'   },
  { src = 'https://github.com/nvim-mini/mini.icons' },
  { src = 'https://github.com/nvim-tree/nvim-web-devicons'},
  { src = 'https://github.com/benomahony/oil-git.nvim'},
})

-- Declare a global function to retrieve the current directory
function _G.get_oil_winbar()
  local bufnr = vim.api.nvim_win_get_buf(vim.g.statusline_winid)
  local dir = require("oil").get_current_dir(bufnr)
  if dir then
    return vim.fn.fnamemodify(dir, ":~")
  else
    -- If there is no current directory (e.g. over ssh), just show the buffer name
    return vim.api.nvim_buf_get_name(0)
  end
end

require("oil").setup({
  win_options = {
    winbar = "%!v:lua.get_oil_winbar()",
  },
})


vim.keymap.set("n", "<D-o>", "<CMD>Oil<CR>", { desc = "Open parent directory" })
vim.keymap.set("n", "<leader>e", "<CMD>Oil<CR>", { desc = "Open parent directory" })


-----------------------------------------------------------------------------------------------------------------------
-- Colorscheme(s)
-----------------------------------------------------------------------------------------------------------------------
vim.pack.add({
   
  { src = 'https://github.com/rebelot/kanagawa.nvim'   },
  { src = 'https://github.com/neanias/everforest-nvim' },
  { src = 'https://github.com/rose-pine/neovim'        },
})
 
-- Disable italic formatting from all custom color schemes
require("rose-pine").setup({ styles = { italic = false } })
require("everforest").setup({ italics = false, disable_italic_comments = true, background = 'hard' })
require("kanagawa").setup({keywordStyle = { italic = false},  commentStyle = { italic = false } })

vim.cmd("colorscheme rose-pine")
