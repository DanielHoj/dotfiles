vim.g.mapleader = " "
vim.g.localmapleader = " "

require("config.lazy")
require("options")
require("keymaps")

vim.lsp.enable({
  "basedpyright",
  "ruff",
  "sqlls",
  "lua_ls",
})


vim.api.nvim_create_autocmd("User", {
  pattern = "LazyLoad",
  callback = function(event)
    -- Only run for copilot.lua plugin
    if event.data == "copilot.lua" then
      -- Check if Copilot needs authentication
      vim.defer_fn(function()
        local copilot_auth_status = vim.fn.system("ls -la " .. 
          vim.fn.expand("~/.config/github-copilot/hosts.json") .. 
          " 2>/dev/null || ls -la " .. 
          vim.fn.expand("~/.config/github-copilot/apps.json") .. 
          " 2>/dev/null")
          
        if copilot_auth_status == "" then
          -- No auth files found, prompt for authentication
          vim.cmd("Copilot auth")
          print("Please authenticate Copilot before using Avante with Copilot provider")
        end
      end, 500)
    end
  end
})
