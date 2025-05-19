-- Refactored AutoFishing Script

-- Constants
local MAX_SELL_COUNT = 100
local CHECK_RANGE = 4
local PZ_STATE = 14
local HUD_COLOR = {200, 200, 200}
local HOTKEY_INTERVAL = 50
local DELAY_BETWEEN_FISHING = 1100 -- 1.1s
local WORM_ID = 3492
local PLAYER_LOW_CAP = 50

-- Water tile IDs
local WaterIds = {
  ["629"] = true, ["4597"] = true, ["4598"] = true, ["4599"] = true,
  ["4600"] = true, ["4601"] = true, ["4602"] = true, ["4609"] = true,
  ["4610"] = true, ["4611"] = true, ["4612"] = true, ["4613"] = true,
  ["4614"] = true,
}

-- Fishable items configuration
local ItemsThatCanBeCaught = {
  ["281"] = { name = "giant shimmering pearl", price = 4000 },
  ["282"] = { name = "giant shimmering pearl", price = 5000 },
  ["901"] = { name = "marlin", price = 1000 },
  ["3578"] = { name = "fish", price = 0 },
  ["3579"] = { name = "salmon", price = 500 },
  ["3580"] = { name = "northern pike", price = 10000 },
  ["3581"] = { name = "shrimp", price = 150 },
  ["7158"] = { name = "rainbow trout", price = 12500 },
  ["7159"] = { name = "green perch", price = 5500 },
  ["12557"] = { name = "shimmering swimmer", price = 4500 },
  ["20063"] = { name = "dream matter", price = 20000 },
  ["24439"] = { name = "shell", price = 50 },
  ["30202"] = { name = "winterberry liquor", price = 0 },
  ["32043"] = { name = "bass", price = 200 },
  ["32044"] = { name = "small bass", price = 100 },
  ["34237"] = { name = "dead frog", price = 125 },
  ["45002"] = { name = "emerald flame fish", price = 5000 },
  ["45003"] = { name = "sunfire fish", price = 30000 },
  ["45004"] = { name = "emerald scale fish", price = 3500 },
  ["45005"] = { name = "amethyst goldfish", price = 500 },
  ["45006"] = { name = "crimson bluefish", price = 3100 },
  ["45007"] = { name = "emerald silverfish", price = 1200 },
  ["45008"] = { name = "lavender stonefish", price = 3300 },
  ["45009"] = { name = "midnight fish", price = 4500 },
  ["45010"] = { name = "cerulean fish", price = 4000 },
  ["45011"] = { name = "sunlit stonefish", price = 50000 },
  ["45012"] = { name = "scarlet fish", price = 1000 },
  ["45013"] = { name = "crimson squid", price = 25000 },
}
-- local posturado = Creature(Player.getId()):getPosition()
-- Client.showMessage("\n\n\n\n\n\n" .. tostring(posturado.x) .. " " .. tostring(posturado.y) .. " " .. tostring(posturado.z))

local FishingSpots = {
  [1] = { x = 1155, y = 730, z = 7 },
  [2] = { x = 1175, y = 729, z = 7 },
  [3] = { x = 1196, y = 729, z = 7 },
  [4] = { x = 1214, y = 730, z = 7 },
  [5] = { x = 1233, y = 729, z = 7 },
}

local RefilSpots = {
  [1] = { x = 1196, y = 679, z = 7}, -- Escada pra vender peixe
  [2] = { x = 1203, y = 670, z = 8}, -- Vender peixe
  [3] = { x = 1196, y = 679, z = 8}, -- Escada pro andar de cima
  [4] = { x = 1174, y = 683, z = 7}, -- Comprar minhoca
  [5] = { x = 1176, y = 676, z = 7}, -- Andar de cima
  [6] = { x = 1173, y = 676, z = 6}, -- Comprar minhoca
  [7] = { x = 1176, y = 676, z = 6}, -- Comprar minhoca
}

-- Runtime variables
local totalFishValue = 0
local startTime = nil
local waterPositions = {}
local currentSpot = 0
local currentWaterTile = 1

-- HUD Setup
local X, Y = 630, 10
local TEXT_DIST = 30
local totalFishValueHUD = HUD.new(X, Y + TEXT_DIST, "Total: $0")
totalFishValueHUD:setColor(unpack(HUD_COLOR))
local meanFishValueHUD = HUD.new(X, Y + 2 * TEXT_DIST, "Profit/H: $0")
meanFishValueHUD:setColor(unpack(HUD_COLOR))

-- Helpers
local function isWaterTile(x, y, z)
  for _, thing in pairs(Map.getThings(x, y, z)) do
    if WaterIds[tostring(thing.id)] then return true end
  end
  return false
end

local function IsNear(posA, posB, MAX_DISTANCE)
  local distanceX = math.abs(posA.x - posB.x)
  local distanceY = math.abs(posA.y - posB.y)

  return math.max(distanceX, distanceY) <= MAX_DISTANCE and posA.z == posB.z
end

local function findNearbyNpc(name)
  for _, cid in ipairs(Map.getCreatureIds(true, false) or {}) do
    local creature = Creature(cid)
    if creature:getName() == name and IsNear(Creature(Player.getId()):getPosition(), creature:getPosition(), CHECK_RANGE) then
      return creature
    end
  end
  return nil
end

local function updateHUD()
  totalFishValueHUD:setText("Total: $" .. totalFishValue)
  local elapsed = math.max(os.difftime(os.time(), startTime), 1)
  meanFishValueHUD:setText("Profit/H: $" .. math.floor((totalFishValue / elapsed) * 3600))
end

local function GetPlayerCurrentCap()
  return math.floor(Player.getCapacity() / 100)
end

local function PlayerHasCap()
  return GetPlayerCurrentCap() > PLAYER_LOW_CAP
end

local function caughtAFish()
  for id, info in pairs(ItemsThatCanBeCaught) do
    local newQty = Game.getItemCount(id)
    info.quantity = info.quantity or 0
    if newQty ~= info.quantity then
      totalFishValue = totalFishValue + info.price
      info.quantity = newQty
      updateHUD()
      if PlayerHasCap() == false then
        Sound.play(Engine.getScriptsDirectory() .. "/sounds/AlarmLowCap.wav")
      end
      return true
    end
  end
  return false
end

local function buildWaterPositions()
  local pos = Creature(Player.getId()):getPosition()
  waterPositions = {}
  for dx = -7, 7 do
    for dy = -5, 5 do
      local x, y, z = pos.x + dx, pos.y + dy, pos.z
      if isWaterTile(x, y, z) then
        table.insert(waterPositions, {x = x, y = y, z = z})
      end
    end
  end
end

local function fishAt(idx)
  local pos = waterPositions[idx]
  if pos then
    Game.useItemOnGround(3483, pos.x, pos.y, pos.z)
    wait(DELAY_BETWEEN_FISHING)
  end
end

local function setupInitialStock()
  for id in pairs(ItemsThatCanBeCaught) do
    ItemsThatCanBeCaught[id].quantity = Game.getItemCount(id)
  end
end

local function hasAnyFishToSell()
  for id, info in pairs(ItemsThatCanBeCaught) do
    if info.name == "winterberry liquor" then
      goto next
    end
    local count = Game.getItemCount(id)
    if count > 0 then
      return true
    end
    ::next::
  end
  return false
end

local function sellItems()
  while hasAnyFishToSell() do
    for id, info in pairs(ItemsThatCanBeCaught) do
      local count = Game.getItemCount(id)
      if count > 0 then
        for i = 1, math.ceil(count / MAX_SELL_COUNT) do
          Npc.sell(id, MAX_SELL_COUNT, true)
          wait(650)
        end
      end
    end
  end
end

local function SellFishes()
  if Player.getState(PZ_STATE) and findNearbyNpc("fisherman") then
    Client.showMessage("Vendendo todo o loot...")
    gameTalk("hi", 1)
    wait(500)
    gameTalk("trade", 12)
    wait(1000)
    sellItems()
    Client.showMessage("\n\n\n\n\n\nItems vendidos com sucesso :)")
  end
end

local function depositAllGold()
  if Player.getState(PZ_STATE) and findNearbyNpc("muzir") then
    Client.showMessage("Depositando todo o gold...")
    gameTalk("hi", 1)
    wait(500)
    gameTalk("deposit all", 12)
    wait(1000)
    gameTalk("yes", 12)
    Client.showMessage("\n\n\n\n\n\nGold depositado com sucesso :)")
  end
end

local function buyItems(itemId, itemQuantity)
  local totalItemCount = Game.getItemCount(itemId)
  local totalToBuy = math.max(0, itemQuantity - totalItemCount)
  if totalToBuy > 0 then
    Npc.buy(itemId, totalToBuy, false, false)
  end
end

local function buyWorms()
  if Player.getState(PZ_STATE) and findNearbyNpc("lubo") then
    Client.showMessage("Comprando minhoca...")
    gameTalk("hi", 1)
    wait(500)
    gameTalk("trade", 12)
    wait(1000)
    buyItems(WORM_ID, 1000)
    Client.showMessage("\n\n\n\n\n\nMinhoca comprada com sucesso :)")
  end
end

local function IsPlayerInSpot(x, y, z)
  local playerPos = Creature(Player.getId()):getPosition()
  return (playerPos.x == x and playerPos.y == y) or playerPos.z ~= z
end

local function PlayerGoTo(x, y, z)
  Map.goTo(x, y, z)
  while IsPlayerInSpot(x, y, z) == false do
    wait(1500)
  end
end

local function Refil()
  local currentRefilStep = 1
  -- Move to stair
  PlayerGoTo(RefilSpots[currentRefilStep].x, RefilSpots[currentRefilStep].y, RefilSpots[currentRefilStep].z)
  currentRefilStep = currentRefilStep + 1

  -- Move close to NPC
  PlayerGoTo(RefilSpots[currentRefilStep].x, RefilSpots[currentRefilStep].y, RefilSpots[currentRefilStep].z)
  SellFishes()
  currentRefilStep = currentRefilStep + 1
  
  -- Move to stair
  PlayerGoTo(RefilSpots[currentRefilStep].x, RefilSpots[currentRefilStep].y, RefilSpots[currentRefilStep].z)
  currentRefilStep = currentRefilStep + 1

  -- Move to bank NPC
  PlayerGoTo(RefilSpots[currentRefilStep].x, RefilSpots[currentRefilStep].y, RefilSpots[currentRefilStep].z)
  currentRefilStep = currentRefilStep + 1
  depositAllGold()

  -- Move to stair
  PlayerGoTo(RefilSpots[currentRefilStep].x, RefilSpots[currentRefilStep].y, RefilSpots[currentRefilStep].z)
  currentRefilStep = currentRefilStep + 1

  -- Move to tools NPC
  PlayerGoTo(RefilSpots[currentRefilStep].x, RefilSpots[currentRefilStep].y, RefilSpots[currentRefilStep].z)
  currentRefilStep = currentRefilStep + 1
  buyWorms()

  -- Move to stair
  PlayerGoTo(RefilSpots[currentRefilStep].x, RefilSpots[currentRefilStep].y, RefilSpots[currentRefilStep].z)
end

local function StartFishing()
  while true do
    if PlayerHasCap() == false then
      Refil()
    end

    local fishingSpot = currentSpot + 1
    PlayerGoTo(FishingSpots[fishingSpot].x, FishingSpots[fishingSpot].y, FishingSpots[fishingSpot].z)
    startTime = startTime or os.time()
    setupInitialStock()
    buildWaterPositions()
    local tries = 0
    while currentWaterTile <= #waterPositions and PlayerHasCap() do
      fishAt(currentWaterTile)
      tries = tries + 1
      if caughtAFish() or tries >= 15 then
        currentWaterTile = currentWaterTile + 1
        tries = 0
      end
    end
    if currentWaterTile > #waterPositions then
      currentSpot = (currentSpot + 1) % 5
      currentWaterTile = 1
    end
    Client.showMessage("\n\n\n\n\n\nTodos os spots foram pescados :)")
    Sound.play(Engine.getScriptsDirectory() .. "/sounds/Alarm Clock.wav")
  end
end

local function ShowPosition()
  local playerPosition = Creature(Player.getId()):getPosition()
  Client.showMessage("x = " .. tostring(playerPosition.x) .. " y = " .. tostring(playerPosition.y) .. " z = " .. tostring(playerPosition.z))
end

-- Register hotkeys
local function bindHotkey(combo, name, callback)
  local ok, mods, key = HotkeyManager.parseKeyCombination(combo)
  if ok then
    Timer(name, function()
      if Client.isKeyPressed(key, mods) then callback() end
    end, HOTKEY_INTERVAL)
  else
    print("Combinação de teclas inválida para " .. name)
  end 
end

bindHotkey("ctrl+shift+K", "StartFishing", StartFishing)
bindHotkey("ctrl+shift+V", "SellFishes", SellFishes)
bindHotkey("ctrl+shift+B", "ShowPosition", ShowPosition)

-- Debug print message hook
-- Game.registerEvent(Game.Events.TEXT_MESSAGE, function(data)
--   print(data.text)
-- end)
