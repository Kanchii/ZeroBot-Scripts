local file = io.open(Engine.getScriptsDirectory() .. "/login.json")
if not file then return nil end
local content = file:read "*a"
file:close()
print(JSON.decode(content)["login"])