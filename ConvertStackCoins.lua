dofile("_lib/container.lua")

local botConvertCoins = {
	3031, -- gold coin
	3035, -- platinum coin
}

local scriptConvertCoins = {
	3043, -- crystal coin
	60047, -- emerald coin
}

local GOLD_BACKPACK_NAME = "gold pouch"

-- deve ser um pouco maior que a configuração do bot "Engine -> Move item delay"
local POST_CONVERT_DELAY = 350 -- ms

local function has_value(tab, val)
	for _, value in ipairs(tab) do
    if value == val then
      return true
    end
	end

	return false
end

-- se o bot ainda estiver convertendo coins, este script não pode executar, para evitar conflitos
local function canConvertCoins() 
	local goldContainer = Get_Container(GOLD_BACKPACK_NAME)
	if goldContainer == nil then
    return false
	end

	-- não da pra rodar o script, bag cheia
	if goldContainer:getItemCount() == goldContainer:getCapacity() then
    return false
	end

	local items = goldContainer:getItems()
	if items ~= nil then
    -- verifica todos os itens na bag
    for _, item in pairs(items) do
      -- foi encontrada uma stack completa de coin que o bot consegue converter
      if has_value(botConvertCoins, item["id"]) and item["count"] == 100 then
        return false
      end
    end
	end

	return true
end

local function convertInGoldContainer()
	::redo:: -- ponto de retorno para refazer scan da mesma bag

	-- checagem em cada loop, para não travar o script
	if not canConvertCoins() then
    return
	end

	local goldContainer = Get_Container(GOLD_BACKPACK_NAME)
	if goldContainer == nil then
    return
	end

	local items = goldContainer:getItems()
	if items == nil then
    return
	end
	-- verifica todos os itens na bag
	for itemIndex, item in pairs(items) do
    if has_value(scriptConvertCoins, item["id"]) and item["count"] == 100 then
      -- converte em emerald coin,
      -- o use aqui dará use na primeira stack dando prioridade para a bag principal
      goldContainer:useItem(itemIndex - 1, false)
      wait(POST_CONVERT_DELAY)

      goto redo -- refaz o scan da mesma bag, pois acabamos de remover um item da stack, alterando a ordem dos itens
    end
	end
end

local function convertCoins()
	if IsRunning or not canConvertCoins() then
    return
	end
	IsRunning = true
	convertInGoldContainer()
	IsRunning = false
end

Timer("goldConverter", convertCoins, 5000, true)