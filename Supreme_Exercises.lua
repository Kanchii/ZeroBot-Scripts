local DistanceisCloseToDummy = 1 -- configure a distância que será considerado 'perto' do dummy, em SQMs, para evitar tentar andar novamente até o dummy.

local Dummys = {
    { ItemId = 60292, Name = "Aquele diamond dummy" },
    { ItemId = 60293, Name = "Aquele diamond dummy" },
    { ItemId = 60294, Name = "Aquele golden dummy" },
    { ItemId = 60295, Name = "Aquele golden dummy" },
    { ItemId = 28562, Name = "Demon Exercise Dummy" },
    { ItemId = 28558, Name = "Exercise Dummy" },
    { ItemId = 28565, Name = "Exercise Dummy" },
    { ItemId = 28559, Name = "Ferumbras Exercise Dummy" },
    { ItemId = 28560, Name = "Ferumbras Exercise Dummy" },
    { ItemId = 28563, Name = "Monk Exercise Dummy" },
    { ItemId = 28564, Name = "Monk Exercise Dummy" }
}

local Exercises = {
    ["magicPercent"] = {
        { ItemId = 35289, Name = "Lasting Exercise Rod" },  -- Prioridade alta
        { ItemId = 35284, Name = "Durable Exercise Wand" }, -- Prioridade alta
        { ItemId = 35283, Name = "Durable Exercise Rod" },  -- Prioridade média
        { ItemId = 35290, Name = "Lasting Exercise Wand" }, -- Prioridade média
        { ItemId = 28556, Name = "Exercise Rod" },          -- Prioridade baixa
        { ItemId = 28557, Name = "Exercise Wand" },         -- Prioridade baixa
    },
    ["clubPercent"] = {
        { ItemId = 35287, Name = "Lasting Exercise Club" }, -- Prioridade alta
        { ItemId = 35281, Name = "Durable Exercise Club" }, -- Prioridade média
        { ItemId = 28554, Name = "Exercise Club" },         -- Prioridade baixa
    },
    ["swordPercent"] = {
        { ItemId = 35285, Name = "Lasting Exercise Sword" }, -- Prioridade alta
        { ItemId = 35279, Name = "Durable Exercise Sword" }, -- Prioridade média
        { ItemId = 28552, Name = "Exercise Sword" },         -- Prioridade baixa
    },
    ["axePercent"] = {
        { ItemId = 35286, Name = "Lasting Exercise Axe" }, -- Prioridade alta
        { ItemId = 35280, Name = "Durable Exercise Axe" }, -- Prioridade média
        { ItemId = 28553, Name = "Exercise Axe" },         -- Prioridade baixa
    },
    ["distancePercent"] = {
        { ItemId = 35288, Name = "Lasting Exercise Bow" }, -- Prioridade alta
        { ItemId = 35282, Name = "Durable Exercise Bow" }, -- Prioridade média
        { ItemId = 28555, Name = "Exercise Bow" },         -- Prioridade baixa
    },
    ["shieldPercent"] = {
        { ItemId = 44067, Name = "Lasting Exercise Shield" }, -- Prioridade alta
        { ItemId = 44066, Name = "Durable Exercise Shield" }, -- Prioridade média
        { ItemId = 44065, Name = "Exercise Shield" },         -- Prioridade baixa
    }
}

local DelayCheckTraining = 1000
local delayForSkillVariation = 10000
local trainingHUD = HUD.new(120, 60, "Treino (Off)")
trainingHUD:setColor(255, 0, 0)
local training = true
local moveToDummy = true -- moveToDummy = true o char vai andar até o dummy, caso esteja como false o char fica parado
local lastSkillCheck = nil
local currentTrainingSkill = nil
local lastDummyPosition = nil
local lastPlayerPosition = { pos = Creature(Player.getId()):getPosition(), time = os.time() }
local occupiedDummy = {} -- Tabela para armazenar os dummy ocupados
local skillVariation = { -- Checar a maior variação da skill
    ["magicPercent"] = 0,
    ["clubPercent"] = 0,
    ["swordPercent"] = 0,
    ["axePercent"] = 0,
    ["distancePercent"] = 0,
    ["shieldPercent"] = 0,
}


local function checkDummyOccupied(position)
    for _, pos in ipairs(occupiedDummy) do
        if pos.x == position.x and pos.y == position.y and pos.z == position.z then
            return true -- Dummy já foi marcado como ocupado
        end
    end
    return false
end

local function checkPlayerPos()
    local playerPos = Creature(Player.getId()):getPosition()

    -- Se a posição do player mudou, atualiza a posição e o tempo da última posição
    if playerPos.x ~= lastPlayerPosition.pos.x or playerPos.y ~= lastPlayerPosition.pos.y or playerPos.z ~= lastPlayerPosition.pos.z then
        lastPlayerPosition.pos = playerPos
        lastPlayerPosition.time = os.time()
        return false
    end

    -- Se passou mais de 1 segundo sem se mover, então está parado
    return os.time() - lastPlayerPosition.time > 1
end

local function isCloseTo(dummyPosition)
    local playerPos = Creature(Player.getId()):getPosition()
    local dx = math.abs(playerPos.x - dummyPosition.x)
    local dy = math.abs(playerPos.y - dummyPosition.y)
    return dx <= DistanceisCloseToDummy and dy <= DistanceisCloseToDummy
end

local function findAndGoToDummy(searchSize)
    print("Procurando dummies no alcance...")
    if not Client.isConnected() or Player.getId() == 0 then
        print("Cliente desconectado.")
        return
    end

    local playerPos = Creature(Player.getId()):getPosition()
    for _, dummy in ipairs(Dummys) do -- Priorizar os melhores dummys
        for x = -searchSize, searchSize do
            for y = -searchSize, searchSize do
                local mapThing = Map.getThings(playerPos.x + x, playerPos.y + y, playerPos.z) or {}

                for _, item in ipairs(mapThing) do
                    if item and item.id and item.id == dummy.ItemId then
                        local dummyPosition = { x = playerPos.x + x, y = playerPos.y + y, z = playerPos.z }

                        if not checkDummyOccupied(dummyPosition) then
                            print("Dummy encontrado: " ..
                                dummy.Name .. " em " .. tostring(playerPos.x + x) .. ", " .. tostring(playerPos.y + y))
                            if moveToDummy and not isCloseTo(dummyPosition) then
                                Map.goTo(dummyPosition.x, dummyPosition.y, dummyPosition.z)
                            end
                            lastDummyPosition = dummyPosition
                            return dummyPosition
                        end
                    end
                end
            end
        end
    end
    print("Nenhum dummy encontrado.")
    return nil
end

local function getHighestSkillVariation()
    local highestSkill = nil
    local highestVariation = 0

    for skill, value in pairs(skillVariation) do
        if value > highestVariation then
            highestVariation = value
            highestSkill = skill
        end
    end
    currentTrainingSkill = highestSkill
end

local function hasSkillChanged()
    if not Client.isConnected() or Player.getId() == 0 then
        return
    end
    print("Verificando mudança de habilidade...")
    local newSkills = Player.getSkills()
    if lastSkillCheck then
        local variation = 0

        -- Checar se a variação de skill está normal
        if currentTrainingSkill then
            if math.abs(newSkills[currentTrainingSkill] - lastSkillCheck[currentTrainingSkill]) < skillVariation[currentTrainingSkill] * 0.5 then
                if delayForSkillVariation == 0 then
                    training = false
                end
            else
                if delayForSkillVariation < 7000 then
                    delayForSkillVariation = 10000
                    training = true
                end
            end
        end

        for skill, oldValue in pairs(lastSkillCheck) do
            if newSkills[skill] and oldValue ~= newSkills[skill] then
                variation = math.abs(newSkills[skill] - oldValue)
                if skillVariation[skill] then
                    if variation > skillVariation[skill] then
                        print("Habilidade alterada: " .. skill)
                        skillVariation[skill] = variation
                    end
                end

                lastSkillCheck = newSkills
            end
        end
        getHighestSkillVariation()
        return true
    else
        print("Armazenando estado inicial das habilidades.")
        lastSkillCheck = newSkills
    end
end

local function selectAndStartTraining()
    if not currentTrainingSkill or not Client.isConnected() or Player.getId() == 0 then
        return
    end
    for _, exercise in pairs(Exercises[currentTrainingSkill]) do
        if Game.getItemCount(exercise.ItemId) > 0 then
            print("Tentando usar o item de exercício: " .. exercise.Name)
            local dummyPosition = findAndGoToDummy(8)
            if dummyPosition then
                if not training and checkPlayerPos() then
                    Game.useItemOnGround(exercise.ItemId, dummyPosition.x, dummyPosition.y, dummyPosition.z)
                    trainingHUD:setText("Treino (ON): " .. exercise.Name)
                    trainingHUD:setColor(0, 255, 0)
                    print("Treinamento iniciado com sucesso com: " .. exercise.Name)
                    training = true
                    return
                end
            else
                print("Não foi possível chegar perto do dummy.")
                return
            end
        end
    end

    print("Nenhum exercise item ativo e disponível foi capaz de iniciar o treinamento.")
    trainingHUD:setText("Treino (Off)")
    trainingHUD:setColor(255, 0, 0)
    training = false
end

local function checkTrainingStatus()
    if not Client.isConnected() or Player.getId() == 0 then
        return
    end
    print("Checando status do treinamento...")
    hasSkillChanged()
    if not training then
        print("Skill parou de subir, tentando reiniciar o treinamento.")
        selectAndStartTraining()
    end
end

local function onTextMessage(messageData)
    if not Client.isConnected() or Player.getId() == 0 then
        return
    end
    local text = messageData.text
    if (text:match("That exercise dummy is busy") or text:match("There is no way") or text:match("You cannot throw there")) and lastDummyPosition then
        table.insert(occupiedDummy, lastDummyPosition)
    end
    if text:match("You have started training on an exercise dummy") then
        occupiedDummy = {}
        delayForSkillVariation = 10000
        training = true
    end
    if text:match("You have stopped training") then
        training = false
    end
end

Game.registerEvent(Game.Events.TEXT_MESSAGE, onTextMessage)

Timer("CheckTrainingStatusTimer", checkTrainingStatus, DelayCheckTraining, true)

Timer("ChangeDelayForSkillVariation", function()
    delayForSkillVariation = math.max(0, delayForSkillVariation - 100)
end, 100, true)

Timer("CheckIfIsConnected", function()
    if not Client.isConnected() then
        local file = io.open(Engine.getScriptsDirectory() .. "/login.json")
        if not file then return nil end
        local content = file:read "*a"
        local loginData = JSON.decode(content)
        file:close()
        Client.login(loginData["login"], loginData["password"], loginData["index"], false)
    end
end, 5000, true)