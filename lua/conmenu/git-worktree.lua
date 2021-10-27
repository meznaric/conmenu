local menu = require('conmenu.menu')
local worktreeStatus, worktree = pcall(require, "git-worktree")

-- Returns a list of worktrees
local function getWorktrees()
    command = "git worktree list"
    local handle = io.popen(command)
    local results = {}

    local parse_line = function(line)
        local fields = vim.split(string.gsub(line, "%s+", " "), " ")
        local entry = {
            path = fields[1],
            sha = fields[2],
            branch = fields[3],
        }

        if entry.sha ~= "(bare)" then
            local index = #results + 1
            table.insert(results, index, entry)
        end
    end

    for line in handle:lines() do
        parse_line(line)
    end
    handle:close()
    return results
end


local function createWorktree()
  if not worktreeStatus then
    print("git-worktree.nvim not installed. Skipping.");
  end
  local name = vim.fn.input('Worktree name: ');
  worktree.create_worktree(name, name, "origin");
end

local function removeWorktree()
    if not worktreeStatus then
      print("git-worktree.nvim not installed. Skipping.");
    end
    local worktrees = getWorktrees()
    local results = {}
    for i, entry in ipairs(worktrees) do
        table.insert(results, i, {
          "Delete "..entry.branch,
          ":lua require('git-worktree').delete_worktree('".. entry.path .."')"
        })
    end

    if results ~= nil and #results ~= 0 then
      menu.openCustom(results)
    end
end

local function selectWorktree()
    if not worktreeStatus then
      print("git-worktree.nvim not installed. Skipping.");
    end
    local worktrees = getWorktrees()
    local results = {}
    for i, entry in ipairs(worktrees) do
        table.insert(results, i, {
          entry.branch,
          ":lua require('git-worktree').switch_worktree('".. entry.path .."')"
        })
    end

    if results ~= nil and #results ~= 0 then
      menu.openCustom(results)
    end
end


return {
  selectWorktree = selectWorktree,
  createWorktree = createWorktree,
  removeWorktree = removeWorktree
}
