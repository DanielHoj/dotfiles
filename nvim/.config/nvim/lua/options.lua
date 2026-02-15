-- Set highlight on search
vim.o.hlsearch = true

vim.opt.clipboard = "unnamedplus"

-- Remove swapfiles
vim.o.swapfile = false

-- Make line numbers default
vim.wo.number = true
vim.o.relativenumber = true

-- Set center cursor
vim.o.scrolloff = 999

-- Enable break indent
vim.o.breakindent = true

-- Save undo history
vim.o.undofile = true

-- Case insensitive searching UNLESS /C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true

-- Decrease update time
vim.o.updatetime = 250
vim.wo.signcolumn = 'yes'

-- Set completeopt to have a better completion experience
vim.o.completeopt = 'menuone,noselect'

local opt = vim.opt

-- Session Management
opt.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"

-- Line Numbers
opt.relativenumber = true
opt.number = true

-- Tabs & Indentation
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.autoindent = true
vim.bo.softtabstop = 2

-- Line Wrapping
opt.wrap = false

-- Search Settings
opt.ignorecase = true
opt.smartcase = true

-- Cursor Line
opt.cursorline = true

-- Appearance
opt.termguicolors = true
opt.background = "dark"
opt.signcolumn = "yes"
vim.diagnostic.config {
  float = { border = "rounded" }, -- add border to diagnostic popups
}

-- Backspace
opt.backspace = "indent,eol,start"


-- Split Windows
opt.splitright = true
opt.splitbelow = true

-- Consider - as part of keyword
opt.iskeyword:append("-")

-- Disable the mouse while in nvim
opt.mouse = ""

vim.api.nvim_create_user_command('CdHere', function()
  vim.cmd('cd %:p:h')
  print('Changed directory to: ' .. vim.fn.getcwd())
end, {})

vim.api.nvim_create_user_command('ActivateEnv', function()
  -- Get the current directory
  local cwd = vim.fn.getcwd()

  -- Check if this is a Python project (has pyproject.toml)
  local has_pyproject = vim.fn.filereadable(cwd .. "/pyproject.toml") == 1

  -- Common venv directory names to check
  local venv_dirs = { ".venv", "venv", "env" }
  local found_venv = nil

  -- Look for virtual environment directories
  for _, dir in ipairs(venv_dirs) do
    local venv_path = cwd .. "/" .. dir
    if vim.fn.isdirectory(venv_path) == 1 then
      found_venv = venv_path
      break
    end
  end

  if has_pyproject and found_venv then
    -- Open a terminal with the virtual environment activated
    local activate_script = found_venv .. "/bin/activate"
    if vim.fn.filereadable(activate_script) == 1 then
      vim.cmd("!source " .. activate_script)
    end
  else
    local msg = not has_pyproject and "No pyproject.toml found" or "No virtual environment found"
    vim.cmd('split | terminal echo "' .. msg .. '" && zsh')
  end
end, {})

-- vim.g.python3_host_prog = "/usr/bin/uv-run-python"
