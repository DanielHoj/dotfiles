local keymap = vim.keymap

-- Telescope
-- add dropdown theme for all pickers
local CallTelescope = function(input)
  local theme = require('telescope.themes').get_dropdown({})
  input(theme)
end

keymap.set('n', '<leader>ff', function() CallTelescope(require('telescope.builtin').find_files) end)
keymap.set('n', '<leader>fg', function() CallTelescope(require('telescope.builtin').live_grep) end)
keymap.set('n', '<leader>fb', function() CallTelescope(require('telescope.builtin').buffers) end)
keymap.set('n', '<leader>fh', function() CallTelescope(require('telescope.builtin').help_tags) end)
keymap.set('n', '<leader>fs', function() CallTelescope(require('telescope.builtin').current_buffer_fuzzy_find) end)
keymap.set('n', '<leader>fi', function() CallTelescope(require('telescope.builtin').lsp_incoming_calls) end)
keymap.set('n', '<leader>fd', function() CallTelescope(require('telescope.builtin').diagnostics) end)
keymap.set('n', '<leader>fo', function()
  local telescope = require('telescope.builtin')
  local theme = require('telescope.themes').get_dropdown({})
  telescope.lsp_document_symbols(vim.tbl_extend('force', theme, {
    symbols = {
      'class',
      'function',
      'method',
      'constructor',
      'interface',
      'module',
      'struct',
      'trait',
      'field',
      'property',
    }
  }))
end)

-- Yazi
keymap.set("n", "<leader>y", "<cmd>Yazi<cr>")
