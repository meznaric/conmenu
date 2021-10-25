-- Checks if item is inside a list
local function listIncludes(list, item)
  for i, v in ipairs(list) do
    if v == item then
      return true
    end
  end
  return false
end

return {
  listIncludes = listIncludes
}
