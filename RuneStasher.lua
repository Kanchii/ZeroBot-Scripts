dofile("_lib/container.lua")

Timer.new("Rune Stasher", function()
  local lockerContainer = Get_Container("locker")
  if not lockerContainer then
    return
  end
  local runeBackpack = Get_Container("fire rune backpack")
  if not runeBackpack then
    runeBackpack = Get_Container("purple backpack")
    if not runeBackpack then
      Client.showMessage("\n\n\n\n\n\n\nBackpack de runa não encontrada!!")
      return
    end
  end
  
  local runeBackpackItems = runeBackpack:getItems()
  
  if runeBackpackItems then  -- Verifica se a backpack de runas está aberta
      for slot, item in pairs(runeBackpackItems) do
          if item.id == 3193 or item.id == 3201 or item.id == 3167 or item.id == 3162 or item.id == 3185 or item.id == 3150 then -- Se for Great Firestorm ou Great Thunderstorm
            runeBackpack:moveItemToContainer(slot - 1, item.count, lockerContainer:getIndex(), 1)
            break
          end
      end
  end
end, 2500, true)