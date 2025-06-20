-- Fuzzy finder
return {
  -- https://github.com/nvim-telescope/telescope.nvim
  'nvim-telescope/telescope.nvim',
  lazy = true,
  dependencies = {
    -- https://github.com/nvim-lua/plenary.nvim
    { 'nvim-lua/plenary.nvim' },
    {
      -- https://github.com/nvim-telescope/telescope-fzf-native.nvim
      'nvim-telescope/telescope-fzf-native.nvim',
      build = 'make',
      cond = function()
        return vim.fn.executable 'make' == 1
      end,
    },
    {
      'debugloop/telescope-undo.nvim'
    }
  },

  config = function()
    -- Setup Telescope
    require("telescope").setup({
      defaults = {
        layout_config = {
          vertical = {
            width = 0.75
          }
        },
        path_display = {
          filename_first = {
            reverse_directories = true
          }
        },
      },
      extensions = {
        undo = {
          -- You can configure undo extension here if needed
        },
      },
    })

    -- Enable Telescope extensions
    require("telescope").load_extension("fzf")
    require("telescope").load_extension("undo")

  end,
}

