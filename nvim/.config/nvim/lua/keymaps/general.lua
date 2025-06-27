local keymap = vim.keymap

-- General keymaps
keymap.set("n", "<leader>wq", ":wq<CR>", { desc = "Save and quit" })
keymap.set("n", "<leader>qq", ":q!<CR>", { desc = "Force quit" })
keymap.set("n", "<leader>ww", ":w<CR>", { desc = "Save file" })
keymap.set("n", "gx", ":!open <c-r><c-a><CR>", { desc = "Open URL under cursor" })
keymap.set("i", "jj", "<Esc>", { desc = "Exit insert mode" })
keymap.set("n", "<space><space>", "<cmd>set nohlsearch<CR>", { desc = "Clear search highlighting" })
keymap.set("n", "<leader><CR>", "o<Esc>", { desc = "Create a new line in normal mode" })
keymap.set("v", "p", '"_dP', { desc = "Paste without overwriting register" })
keymap.set("v", "P", '"_dP', { desc = "Paste without overwriting register" })
keymap.set('t', '<Esc>', [[<C-\><C-n>]], { desc = "Exit terminal mode" })
keymap.set("n", "<A-a>", "ggVG", { desc = "Select entire buffer" })

-- Splits
keymap.set('n', '<A-h>', require('smart-splits').resize_left, { desc = "Resize split to the left" })
keymap.set('n', '<A-j>', require('smart-splits').resize_down, { desc = "Resize split downwards" })
keymap.set('n', '<A-k>', require('smart-splits').resize_up, { desc = "Resize split upwards" })
keymap.set('n', '<A-l>', require('smart-splits').resize_right, { desc = "Resize split to the right" })
keymap.set('n', '<C-h>', require('smart-splits').move_cursor_left, { desc = "Move cursor to the left split" })
keymap.set('n', '<C-j>', require('smart-splits').move_cursor_down, { desc = "Move cursor to the down split" })
keymap.set('n', '<C-k>', require('smart-splits').move_cursor_up, { desc = "Move cursor to the up split" })
keymap.set('n', '<C-l>', require('smart-splits').move_cursor_right, { desc = "Move cursor to the right split" })

-- Indent stuff
keymap.set('v', '<', '<gv', { desc = "Indent left and keep selection" })
keymap.set('v', '>', '>gv', { desc = "Indent right and keep selection" })
keymap.set('n', '>', '>>', { desc = "Indent line to the right" })
keymap.set('n', '<', '<<', { desc = "Indent line to the left" })

-- Quickfix keymaps
keymap.set("n", "<leader>qo", ":copen<CR>", { desc = "Open quickfix list" })
keymap.set("n", "<leader>qf", ":cfirst<CR>", { desc = "Jump to first quickfix list item" })
keymap.set("n", "<leader>qn", ":cnext<CR>", { desc = "Jump to next quickfix list item" })
keymap.set("n", "<leader>qp", ":cprev<CR>", { desc = "Jump to previous quickfix list item" })
keymap.set("n", "<leader>ql", ":clast<CR>", { desc = "Jump to last quickfix list item" })
keymap.set("n", "<leader>qc", ":cclose<CR>", { desc = "Close quickfix list" })

keymap.set(
    {"n", "x"},
    "<leader>rr",
    function() require('refactoring').select_refactor() end,
    { desc = "Trigger refactoring options" }
)

-- lsp keymaps
keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Trigger code actions" })
keymap.set("n", "<leader>dd", vim.diagnostic.open_float, { desc = "Show diagnostics in a floating window" })

keymap.set("n", "<leader>dn", function() vim.diagnostic.jump({ count = 1, float = true }) end, { desc = "Jump to next diagnostic" })
keymap.set("n", "<leader>dp", function() vim.diagnostic.jump({ count = -1, float = true }) end, { desc = "Jump to previous diagnostic" })
