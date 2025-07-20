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

      -- Function to handle whitespace according to both scenarios
      local function normalize_whitespace(text)
        local lines = vim.split(text, '\n', { plain = true })

        -- Skip empty lines at the start
        local first_line_idx = 1
        while first_line_idx <= #lines and lines[first_line_idx]:match("^%s*$") do
          first_line_idx = first_line_idx + 1
        end

        if first_line_idx > #lines then
          return text     -- All lines are empty
        end

        -- Find first non-empty line's indentation
        local first_line = lines[first_line_idx]
        local first_indent = first_line:match("^(%s*)")
        local first_indent_len = #first_indent

        -- Find second non-empty line and its indentation
        local second_line_idx = first_line_idx + 1
        while second_line_idx <= #lines and lines[second_line_idx]:match("^%s*$") do
          second_line_idx = second_line_idx + 1
        end

        local indent_to_remove = first_indent

        -- Scenario 2: If second non-blank line has significant additional indentation
        if second_line_idx <= #lines then
          local second_line = lines[second_line_idx]
          local second_indent = second_line:match("^(%s*)")
          local second_indent_len = #second_indent

          -- Check if second line has significantly more indentation (tab or 4+ spaces)
          if second_indent_len > first_indent_len + 3 then
            -- Use the first line indentation as baseline
            -- We keep indent_to_remove as first_indent
          end
        end

        -- Process each line to remove the determined whitespace
        local processed_lines = {}
        for i, line in ipairs(lines) do
          if line:match("^%s") then     -- Only process lines with whitespace
            if line:sub(1, #indent_to_remove) == indent_to_remove then
              processed_lines[i] = line:sub(#indent_to_remove + 1)
            else
              -- If the line doesn't start with our exact indent pattern,
              -- do our best to remove equivalent whitespace
              local line_indent = line:match("^(%s*)")
              local common_len = math.min(#line_indent, #indent_to_remove)
              processed_lines[i] = line:sub(common_len + 1)
            end
          else
            processed_lines[i] = line       -- Keep lines without leading whitespace as is
          end
        end
        return table.concat(processed_lines, '\n')
      end

      -- Apply the whitespace normalization
      -- local function get_text()
      --   local mode = vim.fn.mode()
      --   if mode == 'V' then
      --     local start_line = vim.fn.getpos("v")[2]
      --     local end_line = vim.fn.getpos(".")[2]
      --     if start_line > end_line then
      --       start_line, end_line = end_line, start_line
      --     end
      --     local lines = vim.fn.getline(start_line, end_line)
      --     local indent = lines[1]:match("^%s*"):len()
      --     if type(lines) == "table" then
      --       for i, line in ipairs(lines) do
      --         lines[i] = line:sub(indent + 1)
      --       end
      --       return table.concat(lines, "\n")
      --     elseif type(lines) == "string" then
      --       return lines:sub(indent + 1)
      --     end
      --   elseif mode == 'v' then
      --     vim.cmd('normal! "ay')
      --     local selected_text = vim.fn.getreg('a')
      --     local lines = vim.split(selected_text, '\n', { plain = true })
      --     local indent = lines[1]:match("^%s*"):len()
      --     if type(lines) == "table" then
      --       dd(lines)
      --       for i, line in ipairs(lines) do
      --         lines[i] = line:sub(indent + 1)
      --       end
      --       return table.concat(lines, "\n")
      --     elseif type(lines) == "string" then
      --       return lines:sub(indent + 1)
      --     end
      --   elseif mode == 'n' then
      --     local line = vim.fn.getline('.')
      --     return line
      --   else
      --     return ''
      --   end
      -- end


      local function get_text()
        local mode = vim.fn.mode()
        if mode == 'V' then
          local start_line = vim.fn.getpos("v")[2]
          local end_line = vim.fn.getpos(".")[2]
          if start_line > end_line then
            start_line, end_line = end_line, start_line
          end
          local lines = vim.fn.getline(start_line, end_line)

          -- Handle case when lines is a single string (one line selected)
          if type(lines) == "string" then
            return lines -- For a single line, return as is
          end

          -- Find first non-blank line
          local first_line_idx = 1
          while first_line_idx <= #lines and lines[first_line_idx]:match("^%s*$") do
            first_line_idx = first_line_idx + 1
          end

          -- If all lines are blank, return as is
          if first_line_idx > #lines then
            return table.concat(lines, "\n")
          end

          -- Get indentation of first non-blank line
          local first_line_indent = lines[first_line_idx]:match("^%s*"):len()
          local first_line_has_whitespace = first_line_indent > 0

          -- Find second non-blank line
          local second_line_idx = first_line_idx + 1
          while second_line_idx <= #lines and lines[second_line_idx]:match("^%s*$") do
            second_line_idx = second_line_idx + 1
          end

          -- Check if we have scenario 2 (Python-style indentation)
          local is_scenario_2 = false
          local indent_to_remove = first_line_indent

          if second_line_idx <= #lines then
            local second_line_indent = lines[second_line_idx]:match("^%s*"):len()
            if second_line_indent >= first_line_indent + 4 then
              -- Scenario 2: Python-style indentation
              is_scenario_2 = true
              -- Calculate how much to remove from lines after the first non-blank line
              indent_to_remove = first_line_indent + (second_line_indent - first_line_indent - 4)
            end
          end

          -- Apply the whitespace removal
          if is_scenario_2 then
            -- Scenario 2: For first non-blank line, remove whitespace only if it has any
            for i, line in ipairs(lines) do
              if i == first_line_idx then
                -- For first line, only remove whitespace if it has any
                if first_line_has_whitespace then
                  if line:len() >= first_line_indent then
                    lines[i] = line:sub(first_line_indent + 1)
                  else
                    lines[i] = line:gsub("^%s*", "")
                  end
                end
                -- If first line doesn't have whitespace, leave it unchanged
              else
                -- For other lines, apply the standard indentation removal
                if line:len() >= indent_to_remove then
                  lines[i] = line:sub(indent_to_remove + 1)
                else
                  lines[i] = line:gsub("^%s*", "")
                end
              end
            end
          else
            -- Scenario 1: Remove consistent indentation from all lines
            for i, line in ipairs(lines) do
              if line:len() >= indent_to_remove then
                lines[i] = line:sub(indent_to_remove + 1)
              else
                lines[i] = line:gsub("^%s*", "")
              end
            end
          end

          return table.concat(lines, "\n")
        elseif mode == 'v' then
          vim.cmd('normal! "ay')
          local selected_text = vim.fn.getreg('a')
          local lines = vim.split(selected_text, '\n', { plain = true })

          -- Find first non-blank line
          local first_line_idx = 1
          while first_line_idx <= #lines and lines[first_line_idx]:match("^%s*$") do
            first_line_idx = first_line_idx + 1
          end

          -- If all lines are blank, return as is
          if first_line_idx > #lines then
            return selected_text
          end

          -- Get indentation of first non-blank line
          local first_line_indent = lines[first_line_idx]:match("^%s*"):len()
          local first_line_has_whitespace = first_line_indent > 0

          -- Find second non-blank line
          local second_line_idx = first_line_idx + 1
          while second_line_idx <= #lines and lines[second_line_idx]:match("^%s*$") do
            second_line_idx = second_line_idx + 1
          end

          -- Check if we have scenario 2 (Python-style indentation)
          local is_scenario_2 = false
          local indent_to_remove = first_line_indent

          if second_line_idx <= #lines then
            local second_line_indent = lines[second_line_idx]:match("^%s*"):len()
            if second_line_indent >= first_line_indent + 4 then
              -- Scenario 2: Python-style indentation
              is_scenario_2 = true
              -- Calculate how much to remove from lines after the first non-blank line
              indent_to_remove = first_line_indent + (second_line_indent - first_line_indent - 4)
            end
          end

          -- Apply the whitespace removal
          if is_scenario_2 then
            -- Scenario 2: For first non-blank line, remove whitespace only if it has any
            for i, line in ipairs(lines) do
              if i == first_line_idx then
                -- For first line, only remove whitespace if it has any
                if first_line_has_whitespace then
                  if line:len() >= first_line_indent then
                    lines[i] = line:sub(first_line_indent + 1)
                  else
                    lines[i] = line:gsub("^%s*", "")
                  end
                end
                -- If first line doesn't have whitespace, leave it unchanged
              else
                -- For other lines, apply the standard indentation removal
                if line:len() >= indent_to_remove then
                  lines[i] = line:sub(indent_to_remove + 1)
                else
                  lines[i] = line:gsub("^%s*", "")
                end
              end
            end
          else
            -- Scenario 1: Remove consistent indentation from all lines
            for i, line in ipairs(lines) do
              if line:len() >= indent_to_remove then
                lines[i] = line:sub(indent_to_remove + 1)
              else
                lines[i] = line:gsub("^%s*", "")
              end
            end
          end

          return table.concat(lines, "\n")
        elseif mode == 'n' then
          local line = vim.fn.getline('.')
          return line
        else
          return ''
        end
      end
      local parser = require('reptile.parser')

      keymap.set({ "n", "x" }, "<M-CR>", function()
        local lines = parser.get_text()
        dap.repl.open()
        dap.repl.execute(lines)
      end)
    end,
  }
}
