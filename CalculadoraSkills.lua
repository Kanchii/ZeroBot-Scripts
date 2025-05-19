local hudx, hudy = 540, 20
local skillsToCheck = {"axe", "club", "sword", "distance", "magic"}
local findSkill = true -- escolher skill automaticamente {sim = true / não = false}
local skillTrainer = "club" -- escolher entre esses: {"axe", "club", "sword", "distance", "magic"} -- use somente se findSkill estiver FALSE
local cargas = 57600 -- quantidade de cargas da sua varinha.


------------------- NÃO MEXER

local highestSkill = 0
local highestSkillName = skillTrainer

function secondsToTime(seconds)
    local hours = math.floor(seconds / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    local remainingSeconds = seconds % 60

    return hours, minutes, remainingSeconds
end

local function updateHighestSkill()
    local playerSkills = Player.getSkills()
    if findSkill then

        for _, skill in ipairs(skillsToCheck) do
            local currentSkillValue = playerSkills[skill]

            if currentSkillValue > highestSkill then
                highestSkillName = skill
                highestSkill = currentSkillValue
            end
        end
    else
        highestSkill = playerSkills[skillTrainer]
    end
end

function calcularMedia(tabela)
    local soma = 0

    for _, valor in ipairs(tabela) do
        soma = soma + valor
    end

    local media = soma / #tabela
    return media
end

-- Chame a função inicialmente para configurar os valores iniciais
updateHighestSkill()

local inicialSkill = highestSkill
local startTime = os.clock()  -- Tempo inicial
local skillPercentInicial = Player.getSkills()[highestSkillName .. "Percent"]
local tempo = {}
local pegou = false

Timer("highskill", function()
    updateHighestSkill()

    if highestSkillName ~= "" then
        local skillPercent = Player.getSkills()[highestSkillName .. "Percent"]

        if skillPercent ~= skillPercentInicial and not pegou then
            local elapsedTime = os.clock() - startTime
            local dif = skillPercent - skillPercentInicial
            table.insert(tempo, elapsedTime / dif)
            pegou = true
        end
    else
        print("Nenhuma skill encontrada para verificar.")
    end

    if pegou then
        startTime = os.clock()  -- Reseta o tempo inicial
        skillPercentInicial = Player.getSkills()[highestSkillName .. "Percent"]
        pegou = false
    -- Calcular o tempo médio para 1% de aumento baseado nos dados coletados
    media = calcularMedia(tempo)

    -- Calcular a porcentagem restante até 100%
    percentualRestante = 100 - Player.getSkills()[highestSkillName .. "Percent"]
    -- Calcular o tempo restante usando o tempo médio (media) para o percentual restante
    demora = percentualRestante * media
    hours, minutes, remainingSeconds = secondsToTime(demora) 
    end
end, 100)

media = 0
demora = 0

--------------- HUD        

local function createHUD(x, y, icon, text, callback)
    local hudName = HUD.new(x, y, text)
    local hudItem = HUD.new(x, y-10, icon)

    hudName:setColor(255, 255, 255)
    hudItem:setDraggable(false)
    hudName:setPos(x, y)

    hudItem:setCallback(callback)
    hudName:setCallback(callback)

    return hudItem, hudName
end

if highestSkillName == "axe" then
ICON_ID = 35286
elseif highestSkillName == "sword" then
ICON_ID = 35285
elseif highestSkillName == "club" then
ICON_ID = 35287
elseif highestSkillName == "distance" then
ICON_ID = 35288
elseif highestSkillName == "magic" then
ICON_ID = 35290
end

local entries = {
{ x = hudx, y = hudy, icon = 26117, text = ""},
{ x = hudx+25, y = hudy, icon = 26117, text = ""},
{ x = hudx+50, y = hudy, icon = 26117, text = ""},
{ x = hudx+75, y = hudy, icon = 26117, text = ""},
{ x = hudx+100, y = hudy, icon = 26117, text = ""},
{ x = hudx+125, y = hudy, icon = 26117, text = ""},
{ x = hudx+150, y = hudy, icon = 26117, text = ""},
{ x = hudx+175, y = hudy, icon = 26117, text = ""},

{ x = hudx, y = hudy+25, icon = 26117, text = ""},
{ x = hudx+25, y = hudy+25, icon = 26117, text = ""},
{ x = hudx+50, y = hudy+25, icon = 26117, text = ""},
{ x = hudx+75, y = hudy+25, icon = 26117, text = ""},
{ x = hudx+100, y = hudy+25, icon = 26117, text = ""},
{ x = hudx+125, y = hudy+25, icon = 26117, text = ""},
{ x = hudx+150, y = hudy+25, icon = 26117, text = ""},
{ x = hudx+175, y = hudy+25, icon = 26117, text = ""},

{ x = hudx, y = hudy+50, icon = 26117, text = ""},
{ x = hudx+25, y = hudy+50, icon = 26117, text = ""},
{ x = hudx+50, y = hudy+50, icon = 26117, text = ""},
{ x = hudx+75, y = hudy+50, icon = 26117, text = ""},
{ x = hudx+100, y = hudy+50, icon = 26117, text = ""},
{ x = hudx+125, y = hudy+50, icon = 26117, text = ""},
{ x = hudx+150, y = hudy+50, icon = 26117, text = ""},
{ x = hudx+175, y = hudy+50, icon = 26117, text = ""},

{ x = hudx, y = hudy+75, icon = 9115, text = ""},
{ x = hudx+25, y = hudy+75, icon = 9115, text = ""},
{ x = hudx+50, y = hudy+75, icon = 9115, text = ""},
{ x = hudx+75, y = hudy+75, icon = 9115, text = ""},
{ x = hudx+100, y = hudy+75, icon = 9115, text = ""},
{ x = hudx+125, y = hudy+75, icon = 9115, text = ""},
{ x = hudx+150, y = hudy+75, icon = 9115, text = ""},
{ x = hudx+175, y = hudy+75, icon = 9115, text = ""},

{ x = hudx, y = hudy, icon = 9115, text = ""},
{ x = hudx+25, y = hudy, icon = 9115, text = ""},
{ x = hudx+50, y = hudy, icon = 9115, text = ""},
{ x = hudx+75, y = hudy, icon = 9115, text = ""},
{ x = hudx+100, y = hudy, icon = 9115, text = ""},
{ x = hudx+125, y = hudy, icon = 9115, text = ""},
{ x = hudx+150, y = hudy, icon = 9115, text = ""},
{ x = hudx+175, y = hudy, icon = 9115, text = ""},

{ x = hudx+200, y = hudy, icon = 5774, text = ""},
{ x = hudx+200, y = hudy+25, icon = 5774, text = ""},
{ x = hudx+200, y = hudy+50, icon = 5774, text = ""},

{ x = hudx, y = hudy, icon = 5774, text = ""},
{ x = hudx, y = hudy+25, icon = 5774, text = ""},
{ x = hudx, y = hudy+50, icon = 5774, text = ""},

{ x = hudx+160, y = hudy+7, icon = ICON_ID, text = ""},

}

local huds = {}

for i, entry in ipairs(entries) do
    local x = entry.x
    local y = entry.y
    local icon = entry.icon
    local text = entry.text
    local action = entry.action
    local hudItem, hudName = createHUD(x, y, icon, text, action)
    
end

local X = hudx + 90
local Y = hudy - 10
local TEXT_DIST = 30 

text = HUD.new(X, Y + TEXT_DIST, "Skills inicial: " .. inicialSkill .. "\nSkills atual: " .. highestSkill .. "\nProximo em: 00:00:00h\nExercises necessarias: 0")
text:setColor(200, 200, 200)

tempo = Timer("HUD-CONTROLLER", function()
        demora = demora - 1
        if demora >= 0 then
            hours, minutes, remainingSeconds = secondsToTime(demora) 
        else
            hours, minutes, remainingSeconds = secondsToTime(0) 
        end
        
        -- Calcula o tempo restante em segundos
        local tempoRestanteSegundos = hours * 3600 + minutes * 60 + remainingSeconds
        
        -- Calcula o número de exercícios necessários
        local exerciciosNecessarios = math.ceil(tempoRestanteSegundos / cargas) --Aqui você muda quantas cargas, por default está contando em Exercises de 5k
        
        -- Atualiza o texto da HUD
        text:setText("Skills inicial: " .. inicialSkill .. "\nSkills atual: " .. highestSkill .. "\nProximo em: "..string.format("%02d:%02d:%02dh", hours, minutes, remainingSeconds).."\nExercises necessarias: " .. exerciciosNecessarios)

end, 1000)