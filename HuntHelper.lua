Enums.DustConvertOption = {
  DUST_CONVERT_OPTION_SLIVER = 0,
  DUST_CONVERT_OPTION_EXALTED = 1,
  DUST_CONVERT_OPTION_MAX_DUST = 2,
}

local DUST_ID = 37160
local SLIVER_ID = 37109
local EXALTED_ID = 37110

isGearing = false
dustConverterOption = Enums.DustConvertOption.DUST_CONVERT_OPTION_SLIVER

local function getHUDX(hud)
    return hud:getMargins().x
end

local function getHUDY(hud)
    return hud:getMargins().y
end

local hudFundo = HUD.new(-200, -200, 23714, true)
hudFundo:setScale(1.7)
hudFundo:setHorizontalAlignment(Enums.HorizontalAlign.Center)
hudFundo:setVerticalAlignment(Enums.VerticalAlign.Center)

local hudHuntHelper = HUD.new(-200, -200, 35285, true)
hudHuntHelper:setDraggable(true)
hudHuntHelper:setScale(1.4)
hudHuntHelper:setHorizontalAlignment(Enums.HorizontalAlign.Center)
hudHuntHelper:setVerticalAlignment(Enums.VerticalAlign.Center)

local isOn = false

local hudHuntHelperText = HUD.new(-200, -170, "-s", true)
if isOn then
  hudHuntHelperText:setText("Ready")
  hudHuntHelperText:setColor(0, 255, 0)
else
  hudHuntHelperText:setText("OFF")
  hudHuntHelperText:setColor(255, 0, 0)
end
hudHuntHelperText:setFontSize(12)
hudHuntHelperText:setHorizontalAlignment(Enums.HorizontalAlign.Center)
hudHuntHelperText:setVerticalAlignment(Enums.VerticalAlign.Center)

hudHuntHelper:setCallback(function()
    isOn = not isOn
    if isOn then
        hudHuntHelperText:setText("Ready")
        hudHuntHelperText:setColor(0, 255, 0)
    else
        hudHuntHelperText:setText("OFF")
        hudHuntHelperText:setColor(255, 0, 0)
    end
end)

local hudsGear = {}
local hudGear = HUD.new(-160, -212, 8775, true)
hudGear:setScale(.6)
hudGear:setHorizontalAlignment(Enums.HorizontalAlign.Center)
hudGear:setVerticalAlignment(Enums.VerticalAlign.Center)
hudGear:setDraggable(true)
hudGear:setCallback(function()
    isGearing = not isGearing

    if isGearing then
      hudHuntHelper:setDraggable(false)
        hudGear:setDraggable(false)

        local status1, hudGearPosX = pcall(getHUDX, hudGear)
        local status2, hudGearPosY = pcall(getHUDY, hudGear)

        if status1 and status2 then
            hudsGear["fundo0"] = HUD.new(hudGearPosX + 185, hudGearPosY + 153, 32822, true)
            hudsGear["fundo0"]:setScale(10.25)
            hudsGear["fundo0"]:setHorizontalAlignment(Enums.HorizontalAlign.Center)
            hudsGear["fundo0"]:setVerticalAlignment(Enums.VerticalAlign.Center)
            
            hudsGear["fundo"] = HUD.new(hudGearPosX + 185, hudGearPosY + 153, 30933, true)
            hudsGear["fundo"]:setScale(10)
            hudsGear["fundo"]:setHorizontalAlignment(Enums.HorizontalAlign.Center)
            hudsGear["fundo"]:setVerticalAlignment(Enums.VerticalAlign.Center)


            --- Criaturas em volta Min
            hudsGear["ConfigTitle"] = HUD.new(hudGearPosX + 185, hudGearPosY + 20, "Helper Config", true)
            hudsGear["ConfigTitle"]:setColor(255, 255, 255)
            hudsGear["ConfigTitle"]:setFontSize(12)
            hudsGear["ConfigTitle"]:setHorizontalAlignment(Enums.HorizontalAlign.Center)
            hudsGear["ConfigTitle"]:setVerticalAlignment(Enums.VerticalAlign.Center)

            hudsGear['DustConverter'] = HUD.new(hudGearPosX + 120, hudGearPosY + 60, "Convert Dust Into:", true)
            hudsGear['DustConverter']:setColor(255, 255, 255)
            hudsGear['DustConverter']:setFontSize(12)
            hudsGear['DustConverter']:setHorizontalAlignment(Enums.HorizontalAlign.Center)
            hudsGear['DustConverter']:setVerticalAlignment(Enums.VerticalAlign.Center)

            hudsGear["dustConverterOptionTitle"] = HUD.new(hudGearPosX + 275, hudGearPosY + 60, "Sliver", true)
            hudsGear["dustConverterOptionTitle"]:setColor(255, 255, 255)
            hudsGear["dustConverterOptionTitle"]:setFontSize(12)
            hudsGear["dustConverterOptionTitle"]:setHorizontalAlignment(Enums.HorizontalAlign.Center)
            hudsGear["dustConverterOptionTitle"]:setVerticalAlignment(Enums.VerticalAlign.Center)

            -- toggle em volta min
            hudsGear["dustConverterOption"] = HUD.new(hudGearPosX + 220, hudGearPosY + 60, 37109, true)
            hudsGear["dustConverterOption"]:setColor(255, 255, 255)
            hudsGear["dustConverterOption"]:setFontSize(12)
            hudsGear["dustConverterOption"]:setHorizontalAlignment(Enums.HorizontalAlign.Center)
            hudsGear["dustConverterOption"]:setVerticalAlignment(Enums.VerticalAlign.Center)
            hudsGear["dustConverterOption"]:setCallback(function()
                if dustConverterOption == Enums.DustConvertOption.DUST_CONVERT_OPTION_SLIVER then
                    dustConverterOption = Enums.DustConvertOption.DUST_CONVERT_OPTION_MAX_DUST
                    hudsGear["dustConverterOption"]:setItemId(37160)
                    hudsGear["dustConverterOptionTitle"]:setText("Dust Cap")
                elseif dustConverterOption == Enums.DustConvertOption.DUST_CONVERT_OPTION_MAX_DUST then
                    dustConverterOption = Enums.DustConvertOption.DUST_CONVERT_OPTION_SLIVER
                    hudsGear["dustConverterOption"]:setItemId(37109)
                    hudsGear["dustConverterOptionTitle"]:setText("Sliver")
                end
            end)
        end
    else
        for k, v in pairs(hudsGear) do
            v:destroy()
            hudsGear[k] = nil
        end
        hudGear:setDraggable(true)
        hudHuntHelper:setDraggable(true)
    end
end)

Timer.new("ConvertDust", function()
  if not isOn then
    return
  end
  
  local totalDust = Player.getDusts()
  if dustConverterOption == Enums.DustConvertOption.DUST_CONVERT_OPTION_SLIVER then
    if totalDust >= 60 then
      Game.forgeConvertDust()
    end
  else
    if Player.getDustsMaximum() - 75 <= totalDust then
      Game.forgeIncreaseLimit()
    end
  end
end, 30000, true)

local timerUpdateHUD = Timer("updateHud", function()
    if not Client.isConnected() then
        return
    end

    local status1, hudHuntHelperPosX = pcall(getHUDX, hudHuntHelper)
    local status2, hudHuntHelperPosY = pcall(getHUDY, hudHuntHelper)

    local status3, hudGearPosX = pcall(getHUDX, hudGear)
    local status4, hudGearPosY = pcall(getHUDY, hudGear)

    local status5, hudFundoPosX = pcall(getHUDX, hudFundo)
    local status6, hudFundoPosY = pcall(getHUDY, hudFundo)

    if status1 and status2 and status3 and status4 and status5 and status6 then
        if hudFundoPosX ~= hudHuntHelperPosX or hudFundoPosY ~= hudHuntHelperPosY then
            hudFundo:setPos(hudHuntHelperPosX, hudHuntHelperPosY)

            hudGear:setPos(hudHuntHelperPosX + 40, hudHuntHelperPosY - 12)

            hudHuntHelperText:setPos(hudHuntHelperPosX, hudHuntHelperPosY + 30)
        end
    else
        print("Error: " .. hudHuntHelperPosX .. " " .. hudHuntHelperPosY .. " " .. hudGearPosX .. " " .. hudGearPosY .. " " .. hudFundoPosX .. " " .. hudFundoPosY)
    end
end, 3000)