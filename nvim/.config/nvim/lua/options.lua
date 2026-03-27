local opt = vim.opt

-- Search
opt.hlsearch = true
opt.ignorecase = true
opt.smartcase = true

-- Clipboard
opt.clipboard = "unnamedplus"

-- Swap / Undo
opt.swapfile = false
opt.undofile = true

-- Line Numbers
opt.number = true
opt.relativenumber = true

-- Scrolling
opt.scrolloff = 999

-- Tabs & Indentation
opt.tabstop = 2
opt.shiftwidth = 2
opt.softtabstop = 2
opt.expandtab = true
opt.autoindent = true
opt.breakindent = true

-- Line Wrapping
opt.wrap = true
opt.linebreak = true

-- Cursor
opt.cursorline = true

-- Appearance
opt.termguicolors = true
opt.background = "dark"
opt.signcolumn = "yes"
vim.diagnostic.config {
  float = { border = "rounded" },
}

-- Completion
opt.completeopt = "menuone,noselect"

-- Backspace
opt.backspace = "indent,eol,start"

-- Splits
opt.splitright = true
opt.splitbelow = true

-- Consider - as part of keyword
opt.iskeyword:append("-")

-- Disable mouse
opt.mouse = ""

-- Session Management
opt.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"

-- Update time
opt.updatetime = 250

-- Commands
vim.api.nvim_create_user_command('CdHere', function()
  vim.cmd('cd %:p:h')
  print('Changed directory to: ' .. vim.fn.getcwd())
end, {})

vim.api.nvim_create_user_command('ActivateEnv', function()
  local cwd = vim.fn.getcwd()
  local has_pyproject = vim.fn.filereadable(cwd .. "/pyproject.toml") == 1
  local venv_dirs = { ".venv", "venv", "env" }
  local found_venv = nil

  for _, dir in ipairs(venv_dirs) do
    local venv_path = cwd .. "/" .. dir
    if vim.fn.isdirectory(venv_path) == 1 then
      found_venv = venv_path
      break
    end
  end

  if has_pyproject and found_venv then
    local activate_script = found_venv .. "/bin/activate"
    if vim.fn.filereadable(activate_script) == 1 then
      vim.cmd("!source " .. activate_script)
    end
  else
    local msg = not has_pyproject and "No pyproject.toml found" or "No virtual environment found"
    vim.cmd('split | terminal echo "' .. msg .. '" && zsh')
  end
end, {})
