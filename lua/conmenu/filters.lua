local utils = require('conmenu.utils');

local function IsInGitWorktree()
  local command = "git rev-parse --is-inside-work-tree 2>&1"
  local handle = io.popen(command)
  local result = vim.fn.trim(handle:read("*a"))
  handle:close()
  -- It returns error message if we are not in git repositroy
  local r = result == "true"
  return r
end

local function IsInGitRepository()
  return vim.fn.finddir('.git', ';') ~= "" or IsInGitWorktree();
end

local function IsInNodeProject()
  return vim.fn.findfile('package.json', ';') ~= "";
end

return {
  IsInGitRepository = IsInGitRepository,
  IsInNodeProject = IsInNodeProject
}
