local function IsNear(posA, posB, MAX_DISTANCE)
  local distanceX = math.abs(posA.x - posB.x)
  local distanceY = math.abs(posA.y - posB.y)

  return math.max(distanceX, distanceY) <= MAX_DISTANCE and posA.z == posB.z
end

function FindNearbyNpc(name, range)
  for _, cid in ipairs(Map.getCreatureIds(true, false) or {}) do
    local creature = Creature(cid)
    if creature:getName() == name and IsNear(Creature(Player.getId()):getPosition(), creature:getPosition(), range) then
      return creature
    end
  end
  return nil
end

function GetPlayerCapacity()
  return math.floor(Player.getCapacity() / 100)
end

function BuyItems(itemId, itemQuantity)
  local totalItemCount = Game.getItemCount(itemId)
  local totalToBuy = math.max(0, itemQuantity - totalItemCount)
  if totalToBuy > 0 then
    Npc.buy(itemId, totalToBuy, false, false)
  end
end

function Dump(o)
	if type(o) == 'table' then
		local s = '{ '
		for k,v in pairs(o) do
			if type(k) ~= 'number' then k = '"'..k..'"' end
			s = s .. '['..k..'] = ' .. Dump(v) .. ','
		end
		return s .. '} '
	else
		return tostring(o)
	end
end

function ReadFile(path)
  local file = io.open(path)
  if not file then return nil end
  local content = file:read "*a"
  file:close()
  return content
end

function WriteFile(path, content)
  local file = io.open(path, "w")
  file:write(content)
  file:close()
end

local HOTKEY_INTERVAL = 50

function BindHotkey(combo, name, callback)
  local ok, mods, key = HotkeyManager.parseKeyCombination(combo)
  if ok then
    Timer(name, function()
      if Client.isKeyPressed(key, mods) then callback() end
    end, HOTKEY_INTERVAL)
  else
    print("Combinação de teclas inválida para " .. name)
  end
end