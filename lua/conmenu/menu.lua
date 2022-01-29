local utf8 = require('.utf8'):init()
local utils = require('conmenu.utils')
local filters = require('conmenu.filters')

-- State of the currently opened menu
local state = {
  activeCommands = {},
  currentlySelected = 1,
  maxLength = 0,
  bufh = nil,
  winId = nil,
  size = 0,
}

local function isCommand(commandOrMenu)
  return type(commandOrMenu) == "string"
end

local function isSubmenu(commandOrMenu)
  return type(commandOrMenu) == "table"
end

local function isDivider(commandOrMenu)
  return commandOrMenu == nil or commandOrMenu == vim.NIL
end

-- Populates the buffer with text
local function updateRender()
  local options = {}

  local currentIndex = 1;
  for index, v in ipairs(state.activeCommands) do
    local key = v[1]
    local commandOrMenu = v[2]

    if isDivider(commandOrMenu) then
      table.insert(options, string.sub(key, 1, 3) .. key)
    elseif (currentIndex == state.currentlySelected) then
      table.insert(options, vim.g['conmenu#cursor_character'] .. " " .. key)
    else
      table.insert(options, "  " .. key)
    end

    currentIndex = currentIndex + 1
  end

  vim.api.nvim_buf_set_lines(state.bufh, 0, -1, true, options)
end

-- Returns {key, newAvailableBindings, position }
-- These 3 pieces of data can be used for:
--  - key - key to bind to
--  - newAvailableBindings - original availableBindings without key (as it's been used)
--  - position - position to in the line to highlight
local function getBinding(name, availableBindings)
  -- We need to count unicode characters if we want to return correct highlightPosition
  local preceedingUtfChars = 0
  for i = 1, #name do
    local char = utf8.sub(name, i,i)
    local lowerChar = string.lower(char)
    -- Not sure 256 is correct?... But it seems to work for my use case. Icons seems to have giant numbers.
    if (utf8.codepoint(name, i, i) > 256) then
      preceedingUtfChars = preceedingUtfChars + 1
    end
    -- Can we find `char` in availableBindings?
    for n = 1, #availableBindings do
      if (lowerChar == availableBindings:sub(n,n)) then
        local highlightPosition = i + 2 + (preceedingUtfChars * 2)
        local newAvailableBindings = availableBindings:sub(1, n-1)..availableBindings:sub(n+1, #availableBindings)
        return {
          lowerChar,
          newAvailableBindings,
          highlightPosition
        }
      end
    end
  end
  return {}
end

local function showMenu()
  local currentIndex = 1;
  state.maxLength = 0 -- Longest name is used for window width
  state.size = 0 -- Number of items (size) is used for height
  state.currentlySelected = 1 -- Select the first item

  -- Determine the size of the menu
  for index, v in ipairs(state.activeCommands) do
    local key = v[1]
    local commandOrMenu = v[2]
    if (#key > state.maxLength and (commandOrMenu ~= nil) and commandOrMenu ~= vim.NIL) then
      state.maxLength = #key
    end
    state.size = state.size + 1
  end

  if (state.size == 0) then
    print("No menu options available")
    return
  end

  -- Open floating window & prepare empty buffer
  local window = vim.api.nvim_get_current_win()
  state.bufh = vim.api.nvim_create_buf(false, true)
  local winId = vim.api.nvim_open_win(state.bufh, true, {
    relative="cursor",
    row=0,
    col=0,
    width=state.maxLength + 3,
    height=state.size,
    style='minimal',
    border=vim.g['conmenu#borders']
  })

  -- We need a name, otherwise some autocommands don't work
  vim.api.nvim_buf_set_name(state.bufh, 'conmenu')
  vim.api.nvim_buf_set_option(state.bufh, 'buftype', 'nofile')
  vim.api.nvim_buf_set_option(state.bufh, 'filetype', 'conmenu')

  -- Fill in the buffer
  updateRender()
  local availableBindings = vim.g["conmenu#available_bindings"]
  for index, v in ipairs(state.activeCommands) do
    local name = v[1]
    local commandOrMenu = v[2]
    -- Bind onlyTypes non-dividers
    if (commandOrMenu ~= nil) then
      local result = getBinding(name, availableBindings)
      -- Did finding a bind succeed?
      if (result[1] ~= nil) then
        vim.cmd("nnoremap <silent> <buffer> "..result[1].." :lua require('conmenu').executeItemNum("..index..")<CR>")
        availableBindings = result[2]
        vim.fn.matchaddpos(vim.g["conmenu#shortcut_highlight_group"], {{index, result[3] }})
      end
    end
  end
end

-- Filters current menu commands based on provided options. Currently you can filter by:
local function filterActiveCommands()
  local t = {}
  for i, v in ipairs(state.activeCommands) do
    local options = v[3]
    -- We have no options - always include
    if (options == nil) then
      table.insert(t, v)
    else
      local filterValid = true
      -- Filter is a globally defined function
      if (options.filter) then
        -- 1st Check for global *lua* function
        -- 2nd Check for global *vim* function
        -- 3rd Check for conmenu filter function
        if (_G[options.filter]) then
          filterValid = _G[options.filter]()
        elseif (vim.fn.exists('*'..options.filter) == 1) then
          filterValid = vim.fn[options.filter]()
        elseif (filters[options.filter]) then
          filterValid = filters[options.filter]()
        end
      end
      local filetypeValid = not options.onlyTypes and true or utils.listIncludes(options.onlyTypes, vim.bo.filetype);

      local onlyBufferPathsMatches = true;
      if (options.onlyBufferPaths) then
        onlyBufferPathsMatches = utils.GlobsMatch(options.onlyBufferPaths, vim.fn.expand('%:p'))
      end

      local onlyWorkingDirectoriesMatches = true
      if (options.onlyWorkingDirectories) then
        onlyWorkingDirectoriesMatches = utils.GlobsMatch(options.onlyWorkingDirectories, vim.fn.getcwd());
      end

      if (filetypeValid and filterValid and onlyBufferPathsMatches and onlyWorkingDirectoriesMatches) then
        table.insert(t, v)
      end
    end
  end
  state.activeCommands = t
end

-- Closes window & wipes menu buffer.
local function close()
  -- Restore Cursor blend
  if (state.bufh ~= nil) then
    vim.cmd("bw " .. state.bufh)
  end
  state.bufh = nil
  state.winId = nil
end


-- Shows default menu based on global variable
local function open()
  if (state.bufh ~= nil) then
    close()
  end
  state.activeCommands = vim.g["conmenu#default_menu"]
  filterActiveCommands()
  showMenu()
end

-- This let's you open custom menu from your lua/vim script
local function openCustom(menu)
  if (state.bufh ~= nil) then
    close()
  end
  state.activeCommands = menu
  filterActiveCommands()
  showMenu()
end

-- Executes currently selected item
local function executeItem()
    -- Am I dumb, can you make this easier? Do we have to loop?
  local item = state.activeCommands[state.currentlySelected];
  local name = item[1]
  local commandOrMenu = item[2]
  if (isCommand(commandOrMenu)) then
    close()
    vim.cmd(commandOrMenu)
  elseif isSubmenu(commandOrMenu) then
    close()
    state.activeCommands = commandOrMenu
    showMenu()
  end
end

local function executeItemNum(index)
  state.currentlySelected = index
  executeItem()
end

-- Moves the selection up/down
local function switchItem(change)
  -- Did we press up when first item was selected? Go to end.
  if (state.currentlySelected == 1 and change == -1) then
    state.currentlySelected = state.size
  -- Did we press down when last item was selected? Go to beginning.
  elseif (state.currentlySelected == state.size and change == 1) then
    state.currentlySelected = 1
  else
    -- Default case
    state.currentlySelected = state.currentlySelected + change
    -- Repeat command if it'sa divider
    if isDivider(state.activeCommands[state.currentlySelected][2]) then
      switchItem(change)
    end
  end
  updateRender()
end

return {
  -- User configured
  open = open,
  openCustom = openCustom,
  close = close,

  executeItem = executeItem,
  switchItem = switchItem,

  -- Used by bindings generated by this script
  executeItemNum = executeItemNum,
  updateRender = updateRender
}
