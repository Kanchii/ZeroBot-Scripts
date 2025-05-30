-- AutoFishing refactored using class-based structure

-- Load dependencies
dofile("_lib/helper.lua")

-- Constants
local MAX_SELL_COUNT = 100
local CHECK_RANGE = 4
local PZ_STATE = 14
local DELAY_BETWEEN_FISHING = 1100
local MAXIMUM_TRIES_TO_CATCH_FISH = 6
local WORM_ID = 3492
local WORM_QUANTITY = nil
local PLAYER_LOW_CAP = 50
local FISH_ID = 3578
local LIQUOUR_ID = 30202
local HUD_COLOR = {200, 200, 200}
local HUD_X = 630
local HUD_Y_START = 30
local HUD_TEXT_DIST = 20
local FISHING_ROD_ID = 3483

-- Water tile IDs
local WaterIds = { ["629"] = true, ["4597"] = true, ["4598"] = true, ["4599"] = true,
  ["4600"] = true, ["4601"] = true, ["4602"] = true, ["4609"] = true,
  ["4610"] = true, ["4611"] = true, ["4612"] = true, ["4613"] = true,
  ["4614"] = true }

local FishIdList = {
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

-- Fishing spots
local FishingSpots = {
  {x = 1155, y = 730, z = 7},
  {x = 1175, y = 729, z = 7},
  {x = 1196, y = 729, z = 7},
  {x = 1214, y = 730, z = 7},
  {x = 1233, y = 729, z = 7},
}

-- Utility function to iterate caught items
local function ForEachFishId(callback)
  local result = false
  for id, item in pairs(FishIdList) do
    result = result or callback(id, item)
  end
  return result
end

-- Refil steps
local function SellFishes()
  if Player.getState(PZ_STATE) and FindNearbyNpc("fisherman", CHECK_RANGE) then
    gameTalk("hi", 1)
    wait(500)
    gameTalk("trade", 12)
    wait(1000)
    ForEachFishId(function(id, item)
      if item.name ~= "winterberry liquor" and Game.getItemCount(id) > 0 then
        for i = 1, math.ceil(Game.getItemCount(id) / MAX_SELL_COUNT) do
          Npc.sell(id, MAX_SELL_COUNT, true)
          wait(650)
        end
      end
    end)
  end
end

local function DepositAllGold()
  if Player.getState(PZ_STATE) then
    gameTalk("!deposit all", 1)
  end
end

local function BuyWorms()
  if Player.getState(PZ_STATE) and FindNearbyNpc("lubo", CHECK_RANGE) then
    if WORM_QUANTITY == nil then
      WORM_QUANTITY = math.ceil(GetPlayerCapacity() * 0.40)
    end
    gameTalk("hi", 1)
    wait(500)
    gameTalk("trade", 12)
    wait(1000)
    BuyItems(WORM_ID, WORM_QUANTITY)
  end
end

local RefilSpots = {}

-- FishingBot class
local FishingBot = {}
FishingBot.__index = FishingBot

function FishingBot:LoadFishingSpots(area, region)
  self.fishingSpotObject = JSON.decode(ReadFile(Engine.getScriptsDirectory() .. "/fishing_spots.json"))
  local choosenArea = self.fishingSpotObject[area]
  FishingSpots = choosenArea[region]["coords"]
  RefilSpots = self.fishingSpotObject[area]["refil"]
  self.currentSpot = choosenArea[region]["last_spot"].spot
  self.currentWaterTile = choosenArea[region]["last_spot"].water_spot
end

function FishingBot:new()
  local self = setmetatable({}, FishingBot)
end

function TurnOnOffDefaultUtilities()
  if Engine.isTargetingEnabled() then
    Engine.enableTargeting(false)
  end
  if Engine.isMagicShooterEnabled() then
    Engine.enableMagicShooter(false)
  end
  if not Engine.isTimerEnabled() then
    Engine.enableTimer(true)
  end
end

function FishingBot:new(area, region)
  TurnOnOffDefaultUtilities()

  local self = setmetatable({}, FishingBot)
  self.area = area
  self.region = region
  self.totalFishValue = 0
  self:LoadFishingSpots(area, region)
  self.waterPositions = {}
  self.startTime = nil
  self.stop = false
  self.tries = 0
  self.totalFishesCatched = 0
  self.totalFishValueHUD = HUD.new(HUD_X, HUD_Y_START, "Total: $0")
  self.totalFishValueHUD:setColor(unpack(HUD_COLOR))
  self.meanFishValueHUD = HUD.new(HUD_X, HUD_Y_START + HUD_TEXT_DIST, "Profit/H: $0")
  self.meanFishValueHUD:setColor(unpack(HUD_COLOR))
  self.meanTriesToCatchHUD = HUD.new(HUD_X, HUD_Y_START + 2 * HUD_TEXT_DIST, "Tentativas médias: 0")
  self.meanTriesToCatchHUD:setColor(unpack(HUD_COLOR))
  return self
end

function FishingBot:SaveCoords()
  self.fishingSpotObject[self.area][self.region]["last_spot"] = {
    spot = self.currentSpot,
    water_spot = self.currentWaterTile
  }
  WriteFile(Engine.getScriptsDirectory() .. "/fishing_spots.json", JSON.encode(self.fishingSpotObject))
end

function FishingBot:PlayerNeedRefil()
  return math.floor(Player.getCapacity() / 100) <= PLAYER_LOW_CAP or Game.getItemCount(WORM_ID) <= 0
end

function FishingBot:BuildWaterPositions()
  local pos = Creature(Player.getId()):getPosition()
  self.waterPositions = {}
  for dx = -7, 7 do
    for dy = -5, 5 do
      local x, y, z = pos.x + dx, pos.y + dy, pos.z
      for _, thing in pairs(Map.getThings(x, y, z)) do
        if WaterIds[tostring(thing.id)] then
          table.insert(self.waterPositions, {x = x, y = y, z = z})
          break
        end
      end
    end
  end
end

function FishingBot:FishAt(idx)
  local pos = self.waterPositions[idx]
  if pos then
    Game.useItemOnGround(FISHING_ROD_ID, pos.x, pos.y, pos.z)
    wait(DELAY_BETWEEN_FISHING)
  end
end

function FishingBot:UpdateHUD()
  self.totalFishValueHUD:setText("Total: $" .. self.totalFishValue)
  local elapsed = math.max(os.difftime(os.time(), self.startTime), 1)
  self.meanFishValueHUD:setText("Profit/H: $" .. math.floor((self.totalFishValue / elapsed) * 3600))
  local meanTriesToCatchFish = self.totalFishesCatched > 0 and self.tries / self.totalFishesCatched or 0
  self.meanTriesToCatchHUD:setText("Tentativas médias: " .. string.format("%.2f", meanTriesToCatchFish))
end

function FishingBot:TrackCatch()
  return ForEachFishId(function(id, info)
    local newQty = Game.getItemCount(id)
    info.quantity = info.quantity or 0
    if newQty ~= info.quantity then
      self.totalFishValue = self.totalFishValue + info.price
      info.quantity = newQty
      return true
    end
    return false
  end)
end

function FishingBot:SetupInitialStock()
  ForEachFishId(function(id, info)
    info.quantity = Game.getItemCount(id)
  end)
end

function FishingBot:DropTrash()
  local containers = Player.getContainers()
  for _, v in pairs(containers) do
    local container = Container(v)
    for i = #container:getItems(), 1, -1 do
      local item = container:getItems()[i]
      if item.id == FISH_ID or item.id == LIQUOUR_ID then
        container:moveItemToGround(i - 1, item.count, self.waterPositions[1].x, self.waterPositions[1].y, self.waterPositions[1].z)
        wait(250)
      end
    end
  end
end

function FishingBot:GoTo(x, y, z)
  repeat
    Map.goTo(x, y, z)
    wait(1500)
    local player = Creature(Player.getId())
    local pos = player:getPosition()
  until (pos.x == x and pos.y == y) or pos.z ~= z
end

function GetRefilFunction(refilName)
  if name == "sell fish" then
    return SellFishes
  else
    if name == "buy worm" then
      return BuyWorms
    else
      if name == "deposit gold" then
        return DepositAllGold
      end
    end
  end

  return nil
end

function FishingBot:Refil(stopping)
  stopping = stopping or false
  for _, step in ipairs(RefilSpots) do
    if step.x then self:GoTo(step.x, step.y, step.z) end
    if step.name == "sell fish" then
      SellFishes()
    else
      if step.name == "buy worm" then
        BuyWorms()
      else
        if step.name == "deposit gold" then
          DepositAllGold()
        end
      end
    end

    if stopping and step.name == "deposit gold" then
      break
    end
  end
end

function FishingBot:Stop()
  self:Refil(true)
end

function FishingBot:Start()
  while true do
    if self:PlayerNeedRefil() then self:Refil() end
    local spot = FishingSpots[self.currentSpot + 1]
    self:GoTo(spot.x, spot.y, spot.z)
    self.startTime = self.startTime or os.time()
    self:SetupInitialStock()
    self:BuildWaterPositions()

    local tries = 0
    while self.currentWaterTile <= #self.waterPositions and not self:PlayerNeedRefil() do
      self:FishAt(self.currentWaterTile)
      tries = tries + 1
      if self:TrackCatch() or tries >= MAXIMUM_TRIES_TO_CATCH_FISH then
        self.currentWaterTile = self.currentWaterTile + 1
        self:SaveCoords()
        self.tries = self.tries + tries
        self.totalFishesCatched = tries < MAXIMUM_TRIES_TO_CATCH_FISH and self.totalFishesCatched + 1 or self.totalFishesCatched
        tries = 0
        self:UpdateHUD()
      end
    end
    if self.currentWaterTile > #self.waterPositions then
      self.currentSpot = (self.currentSpot + 1) % #FishingSpots
      self.currentWaterTile = 1
    end
    self:SaveCoords()
    self:DropTrash()
  end
end

local cm = nil
local customModalButtons = {
  [1] = { area = "vip", region = "south", name = "VIP - South" },
  [2] = { area = "vip", region = "north", name = "VIP - North" },
  [3] = { area = "free", region = "north", name = "Free - North" },
}

local function ChooseAreaAndRegion()
  cm = CustomModalWindow("Fishing Spot", "Choose you fishing spot!")
  for _, item in ipairs(customModalButtons) do
    cm:addButton(item["name"])
  end
end

local bot = nil

-- Entry
function onAreaAndRegionChoice(modalId, buttonIndex)
  local choice = customModalButtons[buttonIndex + 1]
  cm:destroy()
  bot = FishingBot:new(choice.area, choice.region)
  bot:Start()
end

Game.registerEvent(Game.Events.CUSTOM_MODAL_WINDOW_BUTTON_CLICK, onAreaAndRegionChoice)

BindHotkey("ctrl+shift+K", "StartFishing", ChooseAreaAndRegion)
BindHotkey("ctrl+shift+J", "StopFishing", function() FishingBot:new("vip", "south"):Stop() end)
BindHotkey("ctrl+shift+B", "ShowPosition", function()
  local pos = Creature(Player.getId()):getPosition()
  Client.showMessage("x = " .. pos.x .. " y = " .. pos.y .. " z = " .. pos.z)
end)