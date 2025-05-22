WHITELIST_PATH = Engine.getScriptsDirectory() .. "/Whitelist_Sell_Loot.json"

PZ_STATE = 14
LOOT_POUCH_ID = 60042
PORTABLE_SELL_LOOT_ID = 60078

HasLootPouch = Game.getItemCount(LOOT_POUCH_ID, 0) > 0
HasPortableSellLoot = Game.getItemCount(PORTABLE_SELL_LOOT_ID, 0) > 0

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

local function ReadWhitelistSellLoot()
    local file = Read_File(WHITELIST_PATH)

    if not file then
        return {}
    end

    return JSON.decode(file)
end

local function WriteWhitelistSellLoot(whitelist)
    local file = Read_File(WHITELIST_PATH)

    local whitelistAsString = JSON.encode(whitelist)
    Write_File(WHITELIST_PATH, whitelistAsString)
end

local function RemoveFromWhitelistSellLoot(itemCountList, whitelist)
	removedItems = {}
	for i, item in pairs(itemCountList) do
		local actualItemCount = Game.getItemCount(item["id"])
		if actualItemCount > 0 then
			for j, v in pairs(whitelist) do
				if v["id"] == item["id"] then
					table.insert(removedItems, v["id"])
					table.remove(whitelist, j)
					break
				end
			end
		end
		if next(removedItems) ~= nil then
			Client.showMessage("Items removido da lista: " .. table.concat(removedItems, ", "))
		end
	end

	WriteWhitelistSellLoot(whitelist)
end

function FindCreatureInRange(creature, sqmRange)
    local playerPos = Creature(Player.getId()):getPosition()
    local creaturePos = creature:getPosition()

    -- Verifica se a criatura existe antes de tentar acessar sua posição
    if not creature or not creature:getPosition() then
        return false
    end

    -- Calcula a distância entre o jogador e o mob
    local distanceX = math.abs(playerPos.x - creaturePos.x)
    local distanceY = math.abs(playerPos.y - creaturePos.y)

    -- Checa se a criatura está dentro do sqmRange ao redor do jogador
    if distanceX <= sqmRange and distanceY <= sqmRange and playerPos.z == creaturePos.z then
        return true
    end
    return false
end

function FindNpcTrembo()
    local creatures = Map.getCreatureIds(true, false) or {}
    for i = 1, #creatures do
        local cid = creatures[i]
        local creature = Creature(cid)
        local name = creature:getName()

        if name == "trembo" then
            if FindCreatureInRange(creature, 4) then -- Verifica se está perto do NPC
                return true
            end
        end
    end
end

function SellFromBackpack()
	local toSellItemList = ReadWhitelistSellLoot()
			
	local itemsToSell = {}
	for i, item in pairs(toSellItemList) do
		local itemId = item["id"]
		local itemCount = Game.getItemCount(itemId)
		if itemCount > 0 then
			table.insert(itemsToSell, { id = itemId, count = itemCount })
		end
	end

	for i, item in pairs(itemsToSell) do
		local itemId = item["id"]
		local itemCount = item["count"]
		local loopCount = math.ceil(itemCount / 100)
		for i = 1, loopCount do
			local selled = Npc.sell(itemId, 100, true)
			wait(350)
		end
	end

	RemoveFromWhitelistSellLoot(itemsToSell, toSellItemList)
end

local lootPouchEmpty = false

function onTextEvent(message)
	print("Entrei aqui")
	local finishedSellMessage = "you have no items in your loot pouch."
	local findMessage = string.find(message.text:lower(), finishedSellMessage) or 0
	print("findMessage", tostring(findMessage))
	if findMessage > 0 then
		lootPouchEmpty = true
	end
end

Game.registerEvent(Game.Events.TEXT_MESSAGE, onTextEvent)

function SellFromLootPouch()
	-- lootPouchEmpty = false

	while lootPouchEmpty == false do
		print("lootPouchEmpty", tostring(lootPouchEmpty))
		Npc.sell(LOOT_POUCH_ID, 1, true)
		wait(500)
	end

	lootPouchEmpty = false
end

function SellItemsToNPC()
	if Player.getState(PZ_STATE) then -- Checa se está em pz
		if FindNpcTrembo() then
			Client.showMessage("Vendendo todo o loot...")
			gameTalk("hi", 1)
			wait(500)
			gameTalk("trade", 12)
			wait(500)

			if HasLootPouch == true then
				SellFromLootPouch()
			else
				SellFromBackpack()
			end

			Client.showMessage("\n\n\n\n\n\n\nItems vendidos com sucesso :)")
		end
	end
end

-- Tenta analisar a combinação de teclas
local success, modifiers, key = HotkeyManager.parseKeyCombination("ctrl+shift+K")

-- Verifica se a análise foi bem-sucedida
if success then
    
    -- Configura um temporizador para verificar se a combinação de teclas foi pressionada
    Timer("KeyTest", function()
        -- Usa a tecla e os modificadores analisados para verificar se a combinação especificada foi pressionada
        if Client.isKeyPressed(key, modifiers) then
            SellItemsToNPC()
        end
    end, 50)
else
    print("Combinação de teclas inválida.")
end

local function TableContains(whitelistTable, value)
    for _,v in pairs(whitelistTable) do
        if v["id"] == value then
            return true
        end
    end
    return false
end

local defaultCommandWhite = "/wl" -- altere aqui o comando que vc quer que seja usado para adicionar itens na whitelist, Exemplo de uso: /wl 3003

local function onInternalTalk(authorName, authorLevel, type, x, y, z, text, channelId)
    if authorName then 
        if authorName:lower() == Player.getName() then
            if type == Enums.TalkTypes.TALKTYPE_WHISPER or type == Enums.TalkTypes.TALKTYPE_SAY or type == Enums.TalkTypes.TALKTYPE_PRIVATE_PN then
                local whiteCommand = string.sub(text, 1, #defaultCommandWhite)
                if whiteCommand:lower() == defaultCommandWhite:lower() then
                    local whitelistTable = ReadWhitelistSellLoot()
										local addedItems = {}
                    for itemId in string.gmatch(text, "(%d+)") do
                        local itemIdAsInt = tonumber(itemId)
                        
                        if not TableContains(whitelistTable, itemIdAsInt) then
                            table.insert(whitelistTable, { id = itemIdAsInt })
														table.insert(addedItems, itemIdAsInt)
                            WriteWhitelistSellLoot(whitelistTable)
                            wait(100)
                        end
                    end
										if next(addedItems) ~= nil then
											Client.showMessage("\n\n\n\n\n\n\nNovos items adicionados a Whitelist!!!")
										else
											Client.showMessage("\n\n\n\n\n\n\nTodos os items já estão na Whitelist!!!")
										end
                end
            end
        end
    end
end

Game.registerEvent(Game.Events.TALK, onInternalTalk)