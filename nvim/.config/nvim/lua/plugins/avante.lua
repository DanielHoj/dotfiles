return {
  {
    "yetone/avante.nvim",
    event = "VeryLazy",  -- Make sure this loads after Copilot
    version = false,
    build = "make",
    config = function()
      -- Wait for Copilot to be ready before initializing Avante
      vim.defer_fn(function()
        require("avante").setup({
          system_prompt = function()
              local hub = require("mcphub").get_hub_instance()
              return hub and hub:get_active_servers_prompt() or ""
          end,
          -- Using function prevents requiring mcphub before it's loaded
          custom_tools = function()
              return {
                  require("mcphub.extensions.avante").mcp_tool(),
              }
          end,
          provider = "copilot",
          mappings = {
            --
            --- @class AvanteConflictMappings
            diff = {
              ours = "co",
              theirs = "ct",
              all_theirs = "ca",
              both = "cb",
              cursor = "cc",
              next = "]x",
              prev = "[x",
            },
            suggestion = {
              accept = "<M-l>",
              next = "<M-n>",
              prev = "<M-p>",
              dismiss = "<M-h>",
            },
            jump = {
              next = "]]",
              prev = "[[",
            },
            submit = {
              normal = "<CR>",
              insert = "<C-s>",
            },
            cancel = {
              normal = { "<C-c>", "<Esc>", "q" },
              insert = { "<C-c>" },
            },
            sidebar = {
              apply_all = "A",
              apply_cursor = "a",
              retry_user_request = "r",
              edit_user_request = "e",
              switch_windows = "<Tab>",
              reverse_switch_windows = "<S-Tab>",
              remove_file = "d",
              add_file = "@",
              close = { "<Esc>", "q" },
              close_from_input = nil,
            },
          },
        })
      end, 300)  -- Increased delay to improve stability
    end,
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "zbirenbaum/copilot.lua",
    },
  },
}
