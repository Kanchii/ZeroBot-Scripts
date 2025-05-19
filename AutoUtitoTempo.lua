local UTITO_TEMPO_ID = 133
local PZ_STATE = 14
local PLAYER_INITIAL_CLUB_SKILL = Player.getSkills()["club"]
local CLUB_SKILL_THRESHOLD = PLAYER_INITIAL_CLUB_SKILL * 1.1

function updateCooldown()
  for _, timer in ipairs(Timers.list) do
      -- Procura o timer do portable sell loot
      if timer:name():lower() == "utito tempo" then
          timer:update(3000)
          return
      end
  end
end

Timer.new("Utito Tempo", function()
  if Player.getState(PZ_STATE) then
    return
  end

  local currentPlayerClubSkill = Player.getSkills()["club"]
  if currentPlayerClubSkill <= CLUB_SKILL_THRESHOLD then
    if Spells.isInCooldown(UTITO_TEMPO_ID) then
      wait(Spells.getLeftCooldownTime(UTITO_TEMPO_ID) + 15)
    end

    Game.talk("Utito Tempo", Enums.TalkTypes.TALKTYPE_SAY)
    updateCooldown()
  end
end, 1000, true)