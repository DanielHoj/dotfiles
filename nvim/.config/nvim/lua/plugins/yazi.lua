---@type LazySpec
return {
  "mikavilpas/yazi.nvim",
  event = "VeryLazy",
  ---@type YaziConfig
  opts = {
    -- if you want to open yazi instead of netrw, see below for more info
    open_for_directories = false,
    show_hidden = true,
    keymaps = {
      show_help = '<f1>',
    },
  },
}
