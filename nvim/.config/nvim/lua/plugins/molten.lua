return {
  "benlubas/molten-nvim",
  dependencies = {
    "3rd/image.nvim",
    "klafyvel/vim-slime-cells",
  },
  build = ":UpdateRemotePlugins",
  init = function()
    -- Molten configuration
    vim.g.molten_image_provider = "image.nvim"
    vim.g.molten_output_win_max_height = 12
    vim.g.molten_auto_open_output = true
    vim.g.molten_wrap_output = true
    
    -- Fix for slime_cells
    vim.g.slime_cell_delimiter = "^\\s*%%"  -- Define the global cell delimiter
  end,
  config = function()
    -- This function runs after the plugin loads
    -- Create autocmd to set buffer-local delimiter for relevant filetypes
    vim.api.nvim_create_autocmd("FileType", {
      pattern = {"python", "julia", "r", "lua", "markdown"},
      callback = function()
        vim.b.slime_cell_delimiter = "^\\s*%%"  -- Set buffer-local delimiter
      end
    })
    
    -- Key mappings
    vim.keymap.set("n", "<localleader>mi", ":MoltenInit<CR>", { desc = "Initialize Molten for current buffer" })
    vim.keymap.set("n", "<localleader>mr", ":MoltenReevaluateCell<CR>", { desc = "Reevaluate current cell" })
    vim.keymap.set("n", "<localleader>md", ":MoltenDelete<CR>", { desc = "Delete current cell" })
    vim.keymap.set("n", "<localleader>mo", ":noautocmd MoltenEnterOutput<CR>", { desc = "Enter output window" })
  end,
}
