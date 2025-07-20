return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "rcarriga/nvim-dap-ui",
      "mfussenegger/nvim-dap-python",
    },
    config = function()
      local dap = require('dap')
      local dapui = require('dapui')
      local dap_python = require('dap-python')

      -- Python setup
      dap_python.setup('python')

      -- Add Python configurations
      dap.configurations.python = {
        {
          -- The default configuration for Python
          type = 'python',
          request = 'launch',
          name = "Launch file",
          program = "${file}", -- This will use the current file open in Neovim
          pythonPath = function()
            -- Use the Python executable in the current environment
            return 'python'
          end,
          console = "integratedTerminal",
        },
        {
          -- Configuration for debugging a module
          type = 'python',
          request = 'launch',
          name = 'Launch Module',
          module = function()
            return vim.fn.input('Module name: ')
          end,
          pythonPath = function()
            return 'python'
          end,
          console = "integratedTerminal",
        },
        {
          -- Configuration for attaching to a running process
          type = 'python',
          request = 'attach',
          name = 'Attach to running process',
          connect = function()
            local host = vim.fn.input('Host [127.0.0.1]: ', '127.0.0.1')
            local port = tonumber(vim.fn.input('Port [5678]: ', '5678')) or 5678
            return { host = host, port = port }
          end,
          console = "integratedTerminal",
        }
      }

      -- Set up Python test configurations
      dap_python.test_runner = 'pytest'

      -- Configure DAP UI
      dapui.setup({
        icons = { expanded = "▾", collapsed = "▸", current_frame = "▸" },
        mappings = {
          expand = { "<CR>", "<2-LeftMouse>" },
          open = "o",
          remove = "d",
          edit = "e",
          repl = "r",
          toggle = "t",
        },
        layouts = {
          {
            elements = {
              { id = "scopes", size = 0.25 },
              "breakpoints",
              "stacks",
              "watches",
            },
            size = 40,
            position = "left",
          },
          {
            elements = {
              "repl",
              "console",
            },
            size = 0.25,
            position = "bottom",
          },
        },
        floating = {
          max_height = nil,
          max_width = nil,
          border = "single",
          mappings = {
            close = { "q", "<Esc>" },
          },
        },
        windows = { indent = 1 },
        render = {
          max_type_length = nil,
          max_value_lines = 100,
        }
      })

      local keymap = vim.keymap

      keymap.set('n', '<M-d>c', function() dap.continue() end, { desc = "DAP: [c]ontinue" })
      keymap.set('n', '<M-d>o', function() dap.step_over() end, { desc = "DAP: Step [o]ver" })
      keymap.set('n', '<M-d>O', function() dap.step_out() end, { desc = "DAP: Step [O]ut" })
      keymap.set('n', '<M-d>i', function() dap.step_into() end, { desc = "DAP: Step [i]nto" })
      keymap.set('n', '<M-d>b', function() dap.toggle_breakpoint() end, { desc = "DAP: Toggle [b]reakpoint" })
      keymap.set('n', '<M-d>r', function() dap.repl.toggle() end, { desc = "DAP: toggle [r]EPL" })
      keymap.set('n', '<M-d>u', function() dapui.toggle() end, { desc = "DAP: toggle [u]i" })
      keymap.set('n', '<M-d>h', function() dapui.eval(nil, { enter = true }) end, { desc = "DAP: [h]over" })

      -- Python specific keymaps
      keymap.set('n', '<M-d>tm', function() dap_python.test_method() end, { desc = "DAP-Python: Test Method" })
      keymap.set('n', '<M-d>tc', function() dap_python.test_class() end, { desc = "DAP-Python: Test Class" })
      keymap.set('n', '<M-d>ts', function() dap_python.debug_selection() end, { desc = "DAP-Python: Debug Selection" })

      local parser = require('reptile.parser')

      keymap.set({ "n", "x" }, "<M-CR>", function()
        local lines = parser.get_text()
        dap.repl.open()
        dap.repl.execute(lines)
      end)
    end,
  }
}
