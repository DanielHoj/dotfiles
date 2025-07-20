---@class utils.python_parser
local M = {}

---@param lines table|string Lines to process
---@return string Processed text with proper indentation
local function process_indentation(lines)
  -- Handle case when lines is a single string (one line selected)
  if type(lines) == "string" then
    local result = lines:gsub("^%s*", "")
    return result
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

  -- Determine indentation scenario
  local is_python_style = false
  local indent_to_remove = first_line_indent

  if second_line_idx <= #lines then
    local second_line_indent = lines[second_line_idx]:match("^%s*"):len()
    if second_line_indent >= first_line_indent + 4 then
      -- Scenario 2: Python-style indentation
      is_python_style = true
      indent_to_remove = first_line_indent + (second_line_indent - first_line_indent - 4)
    end
  end

  -- Apply the whitespace removal
  local result = {}
  for i, line in ipairs(lines) do
    if is_python_style and i == first_line_idx then
      -- For first line in Python style, only remove whitespace if it has any
      if first_line_has_whitespace then
        result[i] = line:len() >= first_line_indent
            and line:sub(first_line_indent + 1)
            or line:gsub("^%s*", "")
      else
        result[i] = line -- Leave unchanged if no whitespace
      end
    else
      -- Standard indentation removal for all other cases
      result[i] = line:len() >= indent_to_remove
          and line:sub(indent_to_remove + 1)
          or line:gsub("^%s*", "")
    end
  end

  return table.concat(result, "\n")
end

---@return table|string Text from visual line selection
local function get_visual_line_text()
  local start_line = vim.fn.getpos("v")[2]
  local end_line = vim.fn.getpos(".")[2]
  if start_line > end_line then
    start_line, end_line = end_line, start_line
  end
  return vim.fn.getline(start_line, end_line)
end

---@return table Text from visual character selection
local function get_visual_char_text()
  vim.cmd('normal! "ay')
  local selected_text = vim.fn.getreg('a')
  return vim.split(selected_text, '\n', { plain = true })
end

---@return string Selected or current line text based on Vim mode
function M.get_text()
  local mode = vim.fn.mode()
  if mode == 'V' then     -- Visual line mode
    return process_indentation(get_visual_line_text())
  elseif mode == 'v' then -- Visual character mode
    return process_indentation(get_visual_char_text())
  elseif mode == 'n' then -- Normal mode
    return process_indentation(vim.fn.getline('.'))
  else
    return ''
  end
end

return M
