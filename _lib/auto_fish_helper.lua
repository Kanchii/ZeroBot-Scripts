local function IsNear(posA, posB, MAX_DISTANCE)
  local distanceX = math.abs(posA.x - posB.x)
  local distanceY = math.abs(posA.y - posB.y)

  return math.max(distanceX, distanceY) <= MAX_DISTANCE and posA.z == posB.z
end

function FindNearbyNpc(name, range)
  for _, cid in ipairs(Map.getCreatureIds(true, false) or {}) do
    local creature = Creature(cid)
    if creature:getName() == name and IsNear(Creature(Player.getId()):getPosition(), creature:getPosition(), range) then
      return creature
    end
  end
  return nil
end

function BuyItems(itemId, itemQuantity)
  local totalItemCount = Game.getItemCount(itemId)
  local totalToBuy = math.max(0, itemQuantity - totalItemCount)
  if totalToBuy > 0 then
    Npc.buy(itemId, totalToBuy, false, false)
  end
end