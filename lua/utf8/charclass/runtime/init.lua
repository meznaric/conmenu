return function(utf8)

local provided = utf8.config.runtime_charclasses

if provided then
  if type(provided) == "table" then
    return provided
  elseif type(provided) == "function" then
    return provided(utf8)
  else
    return utf8:require(provided)
  end
end

local ffi = pcall(require, "ffi")
if not ffi then
  return utf8:require "charclass.runtime.dummy"
else
  return utf8:require "charclass.runtime.native"
end

end
