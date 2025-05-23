dofile("_lib/helper.lua")

local PZ_STATE = 14
local CHECK_RANGE = 4
local MAX_SELL_COUNT = 100
local ITEM_TO_SELL_FILE_PATH = Engine.getScriptsDirectory() .. "/items_to_sell.json"

local itemsList = JSON.decode(ReadFile(ITEM_TO_SELL_FILE_PATH))

local function IsItemSellable(id)
  for _, item in ipairs(itemsList) do
    if item["id"] == id then
      return true
    end
  end
  return false
end

local function SellItems()
  if Player.getState(PZ_STATE) and FindNearbyNpc("jimo rico", CHECK_RANGE) then
    gameTalk("hi", 1)
    wait(500)
    gameTalk("trade", 12)
    wait(1000)
		for _, item in ipairs(itemsList) do
      local id = item["id"]
      local playerItems = Game.getInventoryItems()
      for _, playerItem in ipairs(playerItems) do
        if IsItemSellable(playerItem.id) then
          for i = 1, math.ceil(Game.getItemCount(id) / MAX_SELL_COUNT) do
            Npc.sell(id, MAX_SELL_COUNT, true)
            wait(650)
          end
        end
      end
    end

    WriteFile(ITEM_TO_SELL_FILE_PATH, JSON.encode(itemsList))
    Client.showMessage("\n\n\nTodos os items foram vendidos :)")
  end
end

BindHotkey("ctrl+shift+V", "Sell Items", SellItems)
BindHotkey("ctrl+shift+B", "Check Items", function() print(Dump(itemsList)) end)

local defaultCommandWhite = "/wl" -- altere aqui o comando que vc quer que seja usado para adicionar itens na whitelist, Exemplo de uso: /wl 3003 3012
local function onInternalTalk(authorName, authorLevel, type, x, y, z, text, channelId)
  if authorName then 
    if authorName:lower() == Player.getName() then
      if type == Enums.TalkTypes.TALKTYPE_WHISPER or type == Enums.TalkTypes.TALKTYPE_SAY or type == Enums.TalkTypes.TALKTYPE_PRIVATE_PN then
        local whiteCommand = string.sub(text, 1, #defaultCommandWhite)
        if whiteCommand:lower() == defaultCommandWhite:lower() then
          for itemId in string.gmatch(text, "(%d+)") do
            local itemIdAsInt = tonumber(itemId)
        
            if not IsItemSellable(itemIdAsInt) then
              table.insert(itemsList, { id = itemIdAsInt })
              wait(100)
            end
          end
          Client.showMessage("\n\n\nTodos os items foram adicionados!")
        end
      end
    end
  end
end

Game.registerEvent(Game.Events.TALK, onInternalTalk)