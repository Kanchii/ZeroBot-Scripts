function Read_File(path)
  local file = io.open(path)
  if not file then return nil end
  local content = file:read "*a"
  file:close()
  return content
end

function Write_File(path, content)
  local file = io.open(path, "w")
  file:write(content)
  file:close()
end