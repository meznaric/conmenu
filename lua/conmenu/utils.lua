local globs = require('lua-glob-pattern');

-- Checks if item is inside a list
local function listIncludes(list, item)
  for i, v in ipairs(list) do
    if v == item then
      return true
    end
  end
  return false
end

local function GlobsMatch(patterns, path)
  for i, v in ipairs(patterns) do
    if(path:match(globs.globtopattern(v))) then
      return true
    end
  end
  return false
end

local function Split(s, delimiter)
    result = {};
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match);
    end
    return result;
end

function FileExists(name)
   local f=io.open(name,"r")
   if f~=nil then io.close(f) return true else return false end
end


return {
  listIncludes = listIncludes,
  FileExists = FileExists,
  Split = Split,
  GlobsMatch = GlobsMatch
}
