-- BY AZYHU
-- Aceito doações de agradecimento em TC (Aquele OT) ou nessa chave pix: bf58aeb7-f9f7-466e-8da7-b278d5be3afd

---------------------------------------------------------CONFIG----------------------------------------------------------------------------
-- PARA MELHOR EFICIÊNCIA INICIE O SCRIPT SEM ITENS PARA VENDER NA LOOT POUCH

local percentageCapForAutoSell = 90 -- Define o cap mínimo (em porcentagem) pra usar o portable sell loot, por exemplo: 90 = 90% do cap máximo

local safeHealthPercent = 85 -- Define uma porcentagem segura da vida pra usar o portable sell loot, por exemplo: 85 = 85% do HP máximo

local maxMobsAround = 10     -- Define a quantidade limite de mobs ao seu redor, isso garante que o portable sell loot só será
-- utilizado quando houver uma quantidade de mobs ao seu redor menor ou igual ao valor de maxMobsAround que você definiu

local percentCapAlarm = 10   -- Define a porcentagem de cap para ativar o alarm de cap baixo, por exemplo: 10 = 10% do cap máximo

local keyForceSell = "h"     -- Hotkey usada apenas para forçar o script a vender o loot que você esqueceu de vender antes de dar load

local PZ_STATE = 14

-------------------------------------------------------------------------------------------------------------------------------------------
--
--                  ___                _______________     _____        _____      ____      ____       ____      ____
--                 /   \              |              /     \    \      /    /     |    |    |    |     |    |    |    |
--                /     \             |_______      /       \    \    /    /      |    |    |    |     |    |    |    |
--               /   _   \                   /     /         \    \  /    /       |    |    |    |     |    |    |    |
--              /   / \   \                 /     /           \    \/    /        |    |____|    |     |    |    |    |
--             /   /___\   \               /     /             \        /         |              |     |    |    |    |
--            /             \             /     /               \      /          |     ____     |     |    |    |    |
--           /    _______    \           /     /                 |    |           |    |    |    |     |    |    |    |
--          /    /       \    \         /     /______            |    |           |    |    |    |     |    |____|    |
--         /    /         \    \       /             |           |    |           |    |    |    |     |              |
--        /____/           \____\     /______________|           |____|           |____|    |____|     |______________|
--
-------------------------------------------------------------------------------------------------------------------------------------------

----------------------------------------------RECOMENDO NÂO ALTERAR O CÓDIGO ABAIXO--------------------------------------------------------

-- Caminho da pasta sounds do zerobot
local soundsPath = Engine.getScriptsDirectory() .. "/Sounds/"
local isSelling = false -- boolean pra identificar trade ativo
local lootPouchID = 60042
local capMax = Player.getCapacity() / 100
local lootPouchVazia = false
local forceSellLoot = false
local alarmTriggered = false -- boolean pra ativar o alarme de cap baixo

-- Converter as porcentagens
percentageCapForAutoSell = (percentageCapForAutoSell / 100)
safeHealthPercent = (safeHealthPercent / 100)
percentCapAlarm = (percentCapAlarm / 100)

-- Definir os sons e seus caminhos.
local sounds = {
    ["start"] = (soundsPath .. "AlarmStartSell.wav"),   -- Start Auto Sell Loot
    ["finish"] = (soundsPath .. "AlarmFinishSell.wav"), -- Finish Auto Sell Loot
    ["lowCap"] = (soundsPath .. "AlarmLowCap.wav"),     -- Low Cap
}

function checkLootPouchVazia(message)
    local finishedSellMessage = "you have no items in your loot pouch"
    local findMessage = string.find(message.text:lower(), finishedSellMessage) or 0
    if isSelling and findMessage > 0 then
        lootPouchVazia = true
    end
end

function findCreatureInRange(creature, sqmRange)
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

function findNpcTrembo()
    local creatures = Map.getCreatureIds(true, false) or {}
    for i = 1, #creatures do
        local cid = creatures[i]
        local creature = Creature(cid)
        local name = creature:getName()

        if name == "trembo" then
            if findCreatureInRange(creature, 4) then -- Verifica se está perto do NPC
                return true
            end
        end
    end
end

function sellAllLoot(forceSell)
    local cap = Player.getCapacity() / 100

    if forceSell then
        cap = -1
    end

    if Player.getState(PZ_STATE) then -- Checa se está em pz
        if findNpcTrembo() then
            if cap < capMax then
                if not isSelling then
                    -- Sound.play(sounds["start"])
                    Client.showMessage("Vendendo todo o loot")
                    isSelling = true
                    gameTalk("hi", 1)
                    wait(500)
                    gameTalk("trade", 12)
                    wait(500)
                end
            end
            if isSelling then
                if lootPouchVazia then
                    isSelling = false
                    forceSellLoot = false
                    alarmTriggered = false
                    lootPouchVazia = false
                    -- Sound.play(sounds["finish"])
                    Client.showMessage("Venda finalizada")
                    capMax = Player.getCapacity() / 100
                    return
                end
                Npc.sell(lootPouchID, 1, true)
                wait(500)
            end
        else
            if isSelling then
                isSelling = false
                forceSellLoot = false
                alarmTriggered = false
                lootPouchVazia = false
                -- Sound.play(sounds["finish"])
                Client.showMessage("Venda finalizada")
                capMax = Player.getCapacity() / 100
            end
        end
    -- else
    --     -- Checa se o cap atual é menor ou igual a 5% do cap máximo
    --     local checkLowCap = cap <= (capMax * percentCapAlarm)
    --     if checkLowCap and not alarmTriggered and cap ~= -1 then
    --         -- Sound.play(sounds["lowCap"])
    --         wait(2000)
    --         alarmTriggered = true
    --     end
    end
end

function countCreaturesAround()
    local creatures = Map.getCreatureIds(true, false) or {}
    local count = 0

    for i = 1, #creatures do
        local cid = creatures[i]
        local creature = Creature(cid)
        local type = creature:getType()

        if type == 1 then -- Verifica se é um mob
            if findCreatureInRange(creature, 7) then
                count = count + 1
            end
        end
    end
    return count
end

-- Funções do portable sell loot
local portableSellLoot = 60078                      -- ID do Item que será usado
local upgradedPortableSellLoot = 60903              -- ID do upgraded portable sell loot para verificação
local cooldownSellLoot = 2000                       -- Cooldown do item em milissegundos, começa em 2s porque o item ainda não foi utilizado
if Game.getItemCount(portableSellLoot, 0) == 0 then -- Procura o portable sell loot no char
    portableSellLoot = 0
end
if Game.getItemCount(upgradedPortableSellLoot, 0) > 0 then -- Procura o upgraded portable sell loot no char
    portableSellLoot = upgradedPortableSellLoot
end

function updateCooldownSellLoot()
    for _, timer in ipairs(Timers.list) do
        -- Procura o timer do portable sell loot
        if timer:name() == "UsePortableSellItem" then
            timer._delay = cooldownSellLoot
            timer:update(cooldownSellLoot)
            return
        end
    end
end

function checkCooldownSellLoot(message)
    if message.text:match("Aguarde (%d+)min para usar novamente.") ~= nil then
        cooldownSellLoot = message.text:match("Aguarde (%d+)min para usar novamente.") * 60000
        updateCooldownSellLoot()
        return
    elseif message.text:match("Aguarde (%d+)s para usar novamente.") ~= nil then
        cooldownSellLoot = message.text:match("Aguarde (%d+)s para usar novamente.") * 1000
        updateCooldownSellLoot()
        return
    elseif string.find(message.text:lower(), "using the last portable sell loot...") then
        if portableSellLoot == upgradedPortableSellLoot then
            cooldownSellLoot = 120000 -- Cooldown padrão de 2 minutos
        else
            cooldownSellLoot = 600000 -- Cooldown padrão de 10 minutos
        end
        updateCooldownSellLoot()
        return
    end
end

Game.registerEvent(Game.Events.TEXT_MESSAGE, checkLootPouchVazia)
-- Game.registerEvent(Game.Events.TEXT_MESSAGE, checkCooldownSellLoot)

-- Timer.new("UsePortableSellItem", function()
--     if portableSellLoot ~= 0 then -- Só chama a função se existir o portable sell loot
--         usePortableSellItem()
--     end
-- end, cooldownSellLoot, not isSelling)

-- function usePortableSellItem()
--     local playerCap = Player.getCapacity() / 100
--     if countCreaturesAround() <= maxMobsAround and Player.getHealthPercent() >= safeHealthPercent then
--         if playerCap < (capMax * percentageCapForAutoSell) then
--             Game.useItem(portableSellLoot)
--             -- Sound.play(sounds["finish"])
--             Client.showMessage("Loot vendido")
--             return true
--         end
--     else
--         cooldownSellLoot = 2000 -- Reseta para o cd padrão de 2s
--         updateCooldownSellLoot()
--     end
-- end

Timer("SellAllLoot", function()
    if forceSellLoot then
        sellAllLoot(true) -- Venda de loot forçada
    else
        sellAllLoot(false)
    end
end, 1000, true)

Timer("Key", function()
    local keyPressed, modifiers, key = HotkeyManager.parseKeyCombination(keyForceSell)
    if keyPressed then
        if Client.isKeyPressed(key, modifiers) then
            if not isSelling then
                forceSellLoot = true
            end
        end
    end
end, 50)
