-- BY AZYHU

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

----------------------------------------------RECOMENDO NÂO ALTERAR O CÓDIGO ABAIXO-------------------------------------------------------

-- Caminho da pasta sounds do zerobot
local soundsPath = Engine.getScriptsDirectory() .. "/Sounds/"

-- Definir os sons e seus caminhos.
local sounds = {
    ["road"] = (soundsPath .. "AlarmBeam.wav"),         -- BEAM
    ["cracks"] = (soundsPath .. "AlarmExplosion.wav"),  -- EXPLOSION
    ["destruction"] = (soundsPath .. "AlarmStorm.wav"), -- STORM
}

local attacks = { "road", "cracks", "destruction" }

function onAttackMessage(authorName, authorLevel, _, _, _, _, attackMessage)
    if authorLevel > 0 and (authorName:lower() ~= Player.getName():lower()) then
        return
    end
    for i = 1, #attacks do
        local attackType = attacks[i]
        local found = string.find(attackMessage:lower(), attackType:lower())
        if found then
            -- Toca o som correspondente ao tipo de ataque.
            Sound.play(sounds[attackType])
            break
        end
    end
end

Game.registerEvent(Game.Events.TALK, onAttackMessage)
