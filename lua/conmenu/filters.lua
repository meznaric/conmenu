local utils = require('conmenu.utils');

local function IsInGitWorktree()
  local command = "git rev-parse --is-inside-work-tree 2>&1"
  local handle = io.popen(command)
  local result = vim.fn.trim(handle:read("*a"))
  handle:close()
  -- It returns error message if we are not in git repositroy
  local r = result == "true" or result == "false"
  return r
end

local function IsInNodeProject()
  local file = utils.FindFileRecursively('package.json')
  if file ~= "" then
    return true
  else
    return false
  end
end

return {
  IsInGitWorktree = IsInGitWorktree,
  IsInNodeProject = IsInNodeProject
}
