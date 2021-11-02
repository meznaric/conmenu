-- Checks if item is inside a list
local function listIncludes(list, item)
  for i, v in ipairs(list) do
    if v == item then
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

-- Finds package.json recursively
local function FindFileRecursively(file)
  local fullPath = vim.fn.expand('%:p')
  if (fullPath == "") then
    fullPath = vim.fn.getcwd() .. "/doesntMatter.txt"
  end
  local pathParts = Split(fullPath, '/');

  for i = 1, #pathParts - 1, 1 do
    local currentParts = {unpack(pathParts, 2, #pathParts - i)}
    local filePath = table.concat(currentParts, '/')
    filePath = "/" .. filePath .. "/" .. file
    if FileExists(filePath) then
      return filePath
    end
  end
  return ""
end


return {
  listIncludes = listIncludes,
  FileExists = FileExists,
  Split = Split,
  FindFileRecursively = FindFileRecursively
}
