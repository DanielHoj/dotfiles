return {
  -- https://github.com/rebelot/kanagawa.nvim
  'rebelot/kanagawa.nvim',
  lazy = false,
  priority = 1000,
  opts = {
    background = {
      dark = "wave", -- "wave, dragon"
    },
  },
  config = function(_, opts)
    require('kanagawa').setup(opts)
    vim.cmd("colorscheme kanagawa")
  end
}
