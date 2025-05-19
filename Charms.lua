-- NEXUS SCRIPTS / Charm/Tier Proc Tracker --
-- UPDATE By Mousquer

-- Icon only appears if you proc at least 1 charm --
-- Ícone só aparece se procar pelo menos 1 runa --

local ICON_CHARM_X_POSITION = 250
local ICON_CHARM_Y_POSITION = 350
local ICON_CHARM_ID = 36726
local ICON_TIER_X_POSITION = 400
local ICON_TIER_Y_POSITION = 450
local ICON_TIER_ID = 30278

-- DO NOT TOUCH BELOW THIS LINE // NÃO TOQUE ABAIXO DESTA LINHA --
-- ON HUD DRAG IT WILL SAVE THE NEW POSITION TO THE FILE --
-- APÓS MOVER O ÍCONE A NOVA POSIÇÃO SERÁ SALVA --
local charms = {}
local charmsFound = 0
local lowblowCooldown = 0.5
local lastLowblow = 0

local tiers = {}
local tiersFound = 0
local criticalCooldown = 0.5
local lastCritical = 0
local onslaughtCooldown = 0.5
local lastOnslaught = 0

local charmIcon = nil
local charmIconLastPos = nil
local tierIcon = nil
local tierIconLastPos = nil
local oneHourInSeconds = 3600

local function isTable(t)
    return type(t) == 'table'
end

local function createHud(x, y, text)
    local hud = HUD.new(x, y, text, true)
    hud:setColor(0, 250, 154)
    hud:setHorizontalAlignment(Enums.HorizontalAlign.Left)
    return hud
end

local function getOneHourEstimate(first, count)
    local timeDif = os.time() - first
    inAHour = math.floor(count / timeDif * oneHourInSeconds)
    return inAHour, first, count
end

local charmPatterns = {
    "charm '([^']+)'", "%[(.-)%s+charm%]", "%((.-)%s+charm%)"
}

local function findCharmsProc(text)
    local charm = nil
    for _, pattern in pairs(charmPatterns) do
        charm = text:match(pattern)
        if charm then break end
    end

    if not charm then return false end

    if not isTable(charmIcon) then
        charmIcon = HUD.new(ICON_CHARM_X_POSITION, ICON_CHARM_Y_POSITION, ICON_CHARM_ID, true)
        charmIcon:setDraggable(true)
        charmIcon:setHorizontalAlignment(Enums.HorizontalAlign.Left)
    end

    if charm == "Low Blow" and os.time() < lastLowblow then return end
    lastLowblow = os.time() + lowblowCooldown

    charms[charm] = charms[charm] or { count = 0, first = os.time(), inAHour = 0, hud = { text = nil } }
    charms[charm].count = charms[charm].count + 1
    local hudText = charm .. ": " .. charms[charm].count .. " > " .. charms[charm].inAHour .. "/h"

    if not charms[charm].hud.text then
        local x = ICON_CHARM_X_POSITION - 35
        local y = ICON_CHARM_Y_POSITION + 40 + (15 * charmsFound)
        charms[charm].hud.text = createHud(x, y, hudText)
        charmsFound = charmsFound + 1
    else
        charms[charm].hud.text:setText(hudText)
    end

    local inAHour, first, count = getOneHourEstimate(charms[charm].first, charms[charm].count, charms[charm].inAHour)
    charms[charm].inAHour = inAHour
    charms[charm].first = first
    charms[charm].count = count
    return true
end

local function findTiersProcs(tier)
    if not isTable(tierIcon) then
        tierIcon = HUD.new(ICON_TIER_X_POSITION, ICON_TIER_Y_POSITION, ICON_TIER_ID, true)
        tierIcon:setDraggable(true)
        tierIcon:setHorizontalAlignment(Enums.HorizontalAlign.Left)
    end

    if tier == "Critical" then
        if lastCritical > 0 and os.time() < lastCritical then
            return
        else
            lastCritical = os.time() + criticalCooldown
        end
    end

    if tier == "Fatal" then
        if lastOnslaught > 0 and os.time() < lastOnslaught then
            return
        else
            lastOnslaught = os.time() + onslaughtCooldown
        end
    end

    tiers[tier] = tiers[tier] or { count = 0, first = os.time(), inAHour = 0, hud = { text = nil } }
    tiers[tier].count = tiers[tier].count + 1
    tiers[tier].inAHour = getOneHourEstimate(tiers[tier].first, tiers[tier].count, tiers[tier].inAHour)
    local hudText = tier .. ": " .. tiers[tier].count .. " > " .. tiers[tier].inAHour .. "/h"

    if not tiers[tier].hud.text then
        local x = ICON_TIER_X_POSITION - 35
        local y = ICON_TIER_Y_POSITION + 40 + (15 * tiersFound)
        tiers[tier].hud.text = createHud(x, y, hudText)
        tiersFound = tiersFound + 1
    else
        tiers[tier].hud.text:setText(hudText)
    end
end

Game.registerEvent(Game.Events.TEXT_MESSAGE, function(data)
    local procCharm = findCharmsProc(data.text)
    if procCharm then return end

    if getBotVersion() < 1712 then
        Client.showMessage(
            "Please update your zerobot version to 1.7.1.2 to get tiers metrics \nPor favor, atualize sua versao do zerobot para 1.7.1.2 para obter as metricas de tier")
        return
    end

    local myAttack = data.text:find("your")
    local ruse = data.text:find("Ruse") and "Ruse" or nil
    local dodge = data.text:find("You dodged") or data.text:find("You dodge") and "Dodge" or nil
    local momentum = data.text:find("Momentum") and "Momentum" or nil
    local transcendence = (data.text:find("Transcendance") or data.text:find("Transcendence")) and "Transcendence" or nil
    local onslaught = myAttack and data.text:find("Onslaught") and "Fatal" or nil
    local perfectShot = myAttack and data.text:find("Perfect Shot") and "Perfect Shot" or nil
    local runicMastery = myAttack and data.text:find("Runic Mastery") and "Runic Mastery" or nil
    local reflection = myAttack and data.text:find("damage reflection") and "Reflection" or nil
    local critical = myAttack and data.text:find("critical attack") and "Critical" or nil
    local amplify = data.text:find("Amplified") and "Amplified" or nil

    if critical then
        findTiersProcs("Critical")
    end

    if ruse or dodge then
        findTiersProcs("Ruse")
    end

    if amplify then
        findTiersProcs("Amplify")
    end

    local tier = momentum or onslaught or transcendence or perfectShot or runicMastery or reflection or amplify
    if not tier then return end
    findTiersProcs(tier)
end)

local function hasDragged(currentPos, lastPos)
    return currentPos.x ~= lastPos.x or currentPos.y ~= lastPos.y
end

local function setPos(hud, x, y)
    hud:setPos(x, y)
end

local function getThisFilename(f)
    local filename = debug.getinfo(f).source:gsub("Scripts/", "")
    return filename
end

local filename = getThisFilename(setPos)

local function openFile(path, mode)
    local file = io.open(path, mode)
    if not file then
        error("\nError on open file\nErro ao abrir o arquivo\n", path)
    end

    return file
end

local function saveIconPosition(name, value, which)
    local path = Engine.getScriptsDirectory() .. "/" .. name
    local file = openFile(path, "r")

    local content = file:read("*all")
    file:close()

    local X = which .. "_X_POSITION = "
    local Y = which .. "_Y_POSITION = "

    local currentXValue = content:match(X .. "(%d+)")
    local currentYValue = content:match(Y .. "(%d+)")
    local modifiedContent = content:gsub(X .. currentXValue, X .. value.x)
    modifiedContent = modifiedContent:gsub(Y .. currentYValue, Y .. value.y)

    file = openFile(path, "w")
    file:write(modifiedContent)
    file:close()
end

Timer.new("handle-charm-hud", function()
    if not charmIcon or not isTable(charmIcon) then return end
    if isTable(charmIcon) and not isTable(charmIconLastPos) then
        charmIconLastPos = charmIcon:getPos()
    end

    local currentIconPos = charmIcon:getPos()
    if hasDragged(currentIconPos, charmIconLastPos) then
        charmIconLastPos = currentIconPos
        local index = 0
        for _, charm in pairs(charms) do
            setPos(charm.hud.text, currentIconPos.x - 35, currentIconPos.y + 40 + (15 * index))
            index = index + 1
        end

        saveIconPosition(filename, currentIconPos, "ICON_CHARM")
        ICON_CHARM_X_POSITION = currentIconPos.x
        ICON_CHARM_Y_POSITION = currentIconPos.y
    end
end, 1000)

Timer.new("handle-tier-hud", function()
    if not tierIcon or not isTable(tierIcon) then return end
    if isTable(tierIcon) and not isTable(tierIconLastPos) then
        tierIconLastPos = tierIcon:getPos()
    end

    local currentIconPos = tierIcon:getPos()
    if hasDragged(currentIconPos, tierIconLastPos) then
        tierIconLastPos = currentIconPos
        local index = 0
        for _, tier in pairs(tiers) do
            setPos(tier.hud.text, currentIconPos.x - 35, currentIconPos.y + 40 + (15 * index))
            index = index + 1
        end

        saveIconPosition(filename, currentIconPos, "ICON_TIER")
        ICON_TIER_X_POSITION = currentIconPos.x
        ICON_TIER_Y_POSITION = currentIconPos.y
    end
end, 1000)
-- Nexus scripts / Charm/Tier Proc Tracker --


function getBotVersion()
    local s = Engine.getBotVersion() or ""
    local numbers = {}
    for number in s:gmatch("%d+") do
        table.insert(numbers, tonumber(number))
    end

    return tonumber(table.concat(numbers, "")) or 0
end