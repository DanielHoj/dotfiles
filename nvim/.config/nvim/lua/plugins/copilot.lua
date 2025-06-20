return {
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    priority = 100,
    config = function()
      require("copilot").setup(
        {
          suggestion = {
            enabled = true,
            auto_trigger = true,
            debounce = 75,
            keymap = {
              accept = "<M-l>",
              next = "<M-n>",
              prev = "<M-p>",
              dismiss = "<M-h>",
            },
          },
          panel = {
            enabled = false, -- Disable the panel
          },
          filetypes = {
            yaml = true,
            markdown = true,
            gitcommit = true,
            gitrebase = true,
          },
        }
      )
    end,
  },
}

