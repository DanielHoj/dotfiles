local keymap = vim.keymap

-- General keymaps
keymap.set("n", "<leader>wq", ":wq<CR>")
keymap.set("n", "<leader>qq", ":q!<CR>")
keymap.set("n", "<leader>ww", ":w<CR>")
keymap.set("n", "gx", ":!open <c-r><c-a><CR>")
keymap.set("i", "jj", "<Esc>")
keymap.set("n", "<space><space>", "<cmd>set nohlsearch<CR>")
keymap.set("n", "<leader><CR>", "o<Esc>")
keymap.set("v", "p", '"_dP')
keymap.set("v", "P", '"_dP')
keymap.set('t', '<Esc>', [[<C-\><C-n>]])
keymap.set("n", "<A-a>", "ggVG")


-- Splits
keymap.set('n', '<A-h>', require('smart-splits').resize_left)
keymap.set('n', '<A-j>', require('smart-splits').resize_down)
keymap.set('n', '<A-k>', require('smart-splits').resize_up)
keymap.set('n', '<A-l>', require('smart-splits').resize_right)
keymap.set('n', '<C-h>', require('smart-splits').move_cursor_left)
keymap.set('n', '<C-j>', require('smart-splits').move_cursor_down)
keymap.set('n', '<C-k>', require('smart-splits').move_cursor_up)
keymap.set('n', '<C-l>', require('smart-splits').move_cursor_right)

-- Indent stuff
keymap.set('v', '<', '<gv')
keymap.set('v', '>', '>gv')
keymap.set('n', '>', '>>')
keymap.set('n', '<', '<<')


-- Quickfix keymaps
keymap.set("n", "<leader>qo", ":copen<CR>")  -- open quickfix list
keymap.set("n", "<leader>qf", ":cfirst<CR>") -- jump to first quickfix list item
keymap.set("n", "<leader>qn", ":cnext<CR>")  -- jump to next quickfix list item
keymap.set("n", "<leader>qp", ":cprev<CR>")  -- jump to prev quickfix list item
keymap.set("n", "<leader>ql", ":clast<CR>")  -- jump to last quickfix list item
keymap.set("n", "<leader>qc", ":cclose<CR>") -- close quickfix list

vim.keymap.set(
    {"n", "x"},
    "<leader>rr",
    function() require('refactoring').select_refactor() end
)
-- Note that not all refactor support both normal and visual mode
