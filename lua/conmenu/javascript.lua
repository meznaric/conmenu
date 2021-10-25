-- TODO: configure support for NPM/YARN
function fileExists(name)
   local f=io.open(name,"r")
   if f~=nil then io.close(f) return true else return false end
end

local function fromNpm(path)
  print(path)
  if (path == nil) then
    path = vim.fn.getcwd()
  end
  local jsonPath = path .. "/package.json";
  if (not fileExists(jsonPath)) then
    print("package.json not found in " .. jsonPath)
    return
  end
  command = "cat " .. path .."/package.json | jq -r '.scripts | to_entries[] | [.key, .value] | join(\"\n\")'"
  local handle = io.popen(command)
  local result = handle:read("*a")
  handle:close()

  local data = {}
  local count = 0

  local name = ""
  for s in result:gmatch("[^\r\n]+") do
    if (count % 2 == 1) then
      table.insert(data, {name, ":Dispatch! pushd " .. path .. " && yarn " .. name})
    else
      name = s
    end
    count = count + 1
  end

  require('conmenu').openCustom(data)
end

local function fromLerna()
  if (path == nil) then
    path = vim.fn.getcwd()
  end
  local jsonPath = path .. "/package.json";
  if (not fileExists(jsonPath)) then
    print("package.json not found in " .. jsonPath)
    return
  end


  local command = "yarn --silent lerna list --all --json | jq -r 'sort_by(.private) | reverse | to_entries[] | [.value.name, .value.location] | join(\"\n\")'"

  local handle = io.popen(command)
  local result = handle:read("*a")
  handle:close()

  local data = {}
  local count = 0

  local name = ""
  for s in result:gmatch("[^\r\n]+") do
    if (count % 2 == 1) then
      table.insert(data, {name, ":lua require('conmenu').fromNpm('".. s .. "')"})
    else
      name = s
    end
    count = count + 1
  end

  require('conmenu').openCustom(data)

end

return { fromNpm = fromNpm, fromLerna = fromLerna }
