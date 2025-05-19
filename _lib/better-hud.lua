--[[
Script criado por JhonnyBn
Disponibilizado gratuitamente no Discord do ZeroBot
Caso te ajude e queira fazer uma doacao via pix, agradeco
Chave: 234e58b2-1748-4d2b-a17c-5cd864158836
--]]

-- Auxiliary function to count how many items are in a dict
-- @param dict a dictionary table { a = 1, b = 2 }
-- @return number of items in dict
local function dictLen(dict)
    local qtdItems = 0
    for i, v in pairs(dict) do
        qtdItems = qtdItems + 1
    end
    return qtdItems
end

-- Get a HUD object by the hud ID
-- @param hudId the HUD id
-- @return a HUD object
function HUD.getItemHUD(hudId)
    return HUDList[hudId]
end

-- Create an Item HUD (default HUD)
-- @param x coordinate of the game window on the x-axis
-- @param y coordinate of the game window on the y-axis
-- @param value the text or itemid to draw on the screen
-- @return HUD Item object ID
function HUD.createItemHUD(x, y, value)
    hud = HUD.new(x, y, value)
    return hud:getId()
end

-- Update an Item HUD, see options
function HUD.updateItemHUD(hudId, options)
    local hud = HUD.getItemHUD(hudId)
    local x = options.x
    local y = options.y
    local value = options.value
    local callbackFunction = options.callbackFunction
    local draggable = options.draggable
    local color = options.color
    local size = options.size
    if x or y then
        -- Guarantee that if x or y is set, the other one will be set as well
        x = x or hud:getPos().x
        y = y or hud:getPos().y
        hud:setPos(x, y)
    end
    if value then
        if type(value) == "string" then
            hud:setText(value)
        elseif type(value) == "number" then
            hud:setItemId(value)
        end
    end
    if callbackFunction then
        hud:setCallback(callbackFunction)
    end
    if draggable ~= nil then
        hud:setDraggable(draggable)
    end
    if size and size.width and size.height then
        hud:setSize(size.width, size.height)
    end
    if color and #color == 3 and hud.isItem ~= nil and not hud.isItem then
        hud:setColor(color)
    end
end

-- Destroy an Item HUD
function HUD.destroyItemHUD(hudId)
    return HUD.getItemHUD(hudId):destroy()
end

-- Table to represent a HUDgroup
-- A HUDgroup is a list of HUDitems, the last one may be a HUDtext
HUDgroupList = {}
HUDgroupCount = 0

-- Get a HUD group object by the hud group ID
-- @param hudGroupId the HUD group id
-- @return a HUD group object
function HUD.getHUD(hudGroupId)
    return HUDgroupList[hudGroupId]
end

--- Create a HUD group with a list of icons, label and callback
-- @param x coordinate of the game window on the x-axis
-- @param y coordinate of the game window on the y-axis
-- @param items the text or itemid to draw on the screen. It can be a list of items, and the last item on the list may be a text.
-- @param callbackFunction optional function to call if the element is clicked
-- @param options object with shape { color, labelDeltaY }. color is a RGB color in {R, G, B} format. labelDeltaY is the distance between item icons and the text
-- @return A HUD group ID
function HUD.createHUD(x, y, items, callbackFunction, options)
    -- options
    local text = ""
    local itemType = type(items)
    if itemType == "number" then
        items = { items }
    elseif itemType == "string" then
        text = items
        items = {}
    elseif itemType == "table" then
        if #items and type(items[#items]) == "string" then
            text = table.remove(items)
        end
    end
    options = options or {}
    local color = options.color or {255, 255, 255}
    local labelDeltaY = options.labelDeltaY or 15
    
    -- add in table
    HUDgroupCount = HUDgroupCount + 1
    local selfId = HUDgroupCount
    HUDgroupList[selfId] = {}
    
    -- create HUDs
    for i, itemId in ipairs(items) do
        local item = HUD.createItemHUD(x, y, itemId)
        item = HUD.getItemHUD(item)
        if callbackFunction then
            item:setCallback(callbackFunction)
        end
        table.insert(HUDgroupList[selfId], item:getId())
    end
    if text ~= "" then
        local deltaY = #items and labelDeltaY or 0
        local label = HUD.createItemHUD(x, y + deltaY, text)
        label = HUD.getItemHUD(label)
        label:setColor(color[1], color[2], color[3])
        if callbackFunction then
            label:setCallback(callbackFunction)
        end
        table.insert(HUDgroupList[selfId], label:getId())
    end
    return selfId
end

-- Update a group HUD, see group HUD options
function HUD.updateHUD(hudId, options, value)
    local hudGroup = HUD.getHUD(hudId)
    
    -- update existing
    for i, hud in ipairs(hudGroup) do
        HUD.updateItemHUD(hud, options)
    end

    -- check if changing items
    if not value then
        return
    end

    local hudsInGroup = #hudGroup
    local itemType = type(value)
    if itemType == "number" then
        -- update only icon
        local hud = HUD.getItemHUD(#hudGroup)
        if hud.isItem ~= nil and not hud.isItem then
            -- the last hud is a HUDItem
            hud:setItemId(value)
        elseif hudsInGroup > 1 then
            -- the last hud is a HUDText, get last but one
            hud = HUD.getItemHUD(#hudGroup-1)
            hud:setItemId(value)
        end
    elseif itemType == "string" then
        -- update only text
        hud = HUD.getItemHUD(#hudGroup)
        if hud.isItem ~= nil and not hud.isItem then
            -- last hud is a HUDText
            hud:setText(value)
        else
            -- last hud is a HUDItem, create new HUD
            local pos = hud:getPos()
            local labelDeltaY = (options and options.labelDeltaY) or 10
            local hud = HUD.createItemHUD(pos.x, pos.y + labelDeltaY, value)
            local id = hud:getId()
            table.insert(hudGroup, id)
        end
    --[[ TODO: lidar com casos em que value eh uma lista
    else itemType == "table" then
        -- update last item + text
        if #items == 2 then
        end
        -- redo the HUD
        if #items > 0 then
            -- code
        end
    --]]
    end
end

-- Destroy a group HUD
function HUD.destroyHUD(hudId)
    local hudGroup = HUD.getHUD(hudId)
    for i, hudId in ipairs(hudGroup) do
        HUD.destroyItemHUD(hudId)
    end
end

-- Table to represent a Menu
-- A Menu is a list of HUD groups
HUDmenuList = {}
HUDmenuCount = 0

-- Get a HUD menu object by the hud menu ID
-- @param hudMenuId the HUD menu id
-- @return a HUD menu object
function HUD.getMenu(hudMenuId)
    return HUDmenuList[hudMenuId]
end

--- Create a menu of HUDs with a list of HUD (each one being a list of icons, label and callback)
-- @param x coordinate of the game window on the x-axis
-- @param y coordinate of the game window on the y-axis
-- @param hudsParams a list of HUD objects in the shape { items, callbackFunction }
-- @param menuParams optional object with shape { deltaX, deltaY, columnMode, itemsPerColumn, hudOptions }. All parameters are optional.
--        menuParams.deltaX being the distance between each HUD in game window on x-axis
--        menuParams.deltaY being the distance between each HUD in game window on y-axis
--        menuParams.columnMode being "rows" or "cols" (default cols) determine if the menu grows in lines or columns
--        menuParams.itemsPerColumn being the number of items in each row/col
--        menuParams.hudOptions being a HUD options object
-- @return A HUD Menu Id
function HUD.createMenu(inicioX, inicioY, hudsParams, menuParams)
    local menuParams = menuParams or {}
    local hudOptions = menuParams.hudOptions or {}
    hudOptions.color = hudOptions.color or {255, 255, 255}
    hudOptions.labelDeltaY = hudOptions.labelDeltaY or 15
    local deltaX = menuParams.deltaX or 65
    local deltaY = menuParams.deltaY or 60
    local columnMode = menuParams.columnMode or "cols"
    local itemsPerColumn = menuParams.itemsPerColumn or 2
    if columnMode ~= "cols" then
        itemsPerColumn = math.ceil(#hudsParams/itemsPerColumn)
    end
    
    -- add in table
    HUDmenuCount = HUDmenuCount + 1
    local selfId = HUDmenuCount
    HUDmenuList[selfId] = {}
    
    local line = 0
    local column = 0
    for i, params in ipairs(hudsParams) do
        local x = inicioX + column*deltaX
        local y = inicioY + line*deltaY
        local hud = HUD.createHUD(x, y, params[1], params[2], hudOptions)
        line = line + 1
        if line == itemsPerColumn then
            line = 0
            column = column + 1
        end
        table.insert(HUDmenuList[selfId], hud)
    end
    return selfId
end

-- Updates a menu, see group HUD options
function HUD.updateMenu(menuId, options)
    local menu = HUD.getMenu(menuId)
    for i, hudGroupId in ipairs(menu) do
        HUD.updateHUD(hudGroupId, options)
    end
end

-- Destroys a menu
function HUD.destroyMenu(menuId)
    local menu = HUD.getMenu(menuId)
    for i, hudGroupId in ipairs(menu) do
        HUD.destroyHUD(hudGroupId)
    end
end

-- Exemplo de uso
-- local menuX = 15
-- local menuY = 15
-- local backgroundItemId = 2656
-- local hudsParams = {
--     { { backgroundItemId, 3003, "Subir" }, function() print("rope") end },
--     { { backgroundItemId, 3457, "Cavar" }, function() print("shovel") end },
--     { { backgroundItemId, 1948, "Interagir" }, function() print("useGround") end },
--     { { backgroundItemId, 5257, "Avancar" }, function() print("move") end },
--     { { backgroundItemId, 3079, "Andar" }, function() print("goto") end },
--     { { backgroundItemId, 3485, "Travel" }, function() print("Travel") end },
--     { { backgroundItemId, 7643, "Supplies" }, function() print("buy") end },
--     { { backgroundItemId, 23721, "Sell All" }, function() print("sell") end },
--     { { backgroundItemId, 3043, "Deposit" }, function () print("talk") end },
--     { { backgroundItemId, 3308, "Machete" }, function() print("machete") end },
-- }
-- local menuOptions = {
--     hudOptions = {
--         color = {255, 255, 255},
--         labelDeltaY = 15,
--     },
--     deltaX = 65,
--     deltaY = 60,
--     columnMode = "cols",
--     itemsPerColumn = 2,
-- }

-- menuId = HUD.createMenu(menuX, menuY, hudsParams, menuOptions)