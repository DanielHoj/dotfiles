return {
  "NeogitOrg/neogit",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "sindrets/diffview.nvim",
    {
      "lewis6991/gitsigns.nvim",
      config = function ()
        require("gitsigns").setup()
      end
    }
  },
  config = true
}
