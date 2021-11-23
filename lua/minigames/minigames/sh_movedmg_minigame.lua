if SERVER then
  AddCSLuaFile()
end

MINIGAME.author = "Sirzento"
MINIGAME.contact = "Sirzento | Nico on TTT2 Discord"

function MINIGAME:AddToSettingsMenu(parent)
  local form = vgui.CreateTTT2Form(parent, "header_minigames_extra_settings")

  form:MakeSlider({
      serverConvar = "ttt2_minigames_moveDamage_maxDmgAt",
      label = "label_minigames_moveDamage_maxDmgAt",
      min = 200,
      max = 5000,
      decimal = 0
  })

  form:MakeSlider({
    serverConvar = "ttt2_minigames_moveDamage_fullDmgAt",
    label = "label_minigames_moveDamage_fullDmgAt",
    min = 100,
    max = 500,
    decimal = 0
})
end

if CLIENT then
  MINIGAME.lang = {
    name = {
      en = "Run'n Gun",
      de = "Laufen & Schießen"
    },
    desc = {
      en = "More speed = more damage",
      de = "Mehr Geschwindikeit = Mehr Schaden"
    }
  }
end

if SERVER then
  local ttt2_minigames_moveDamage_maxDmgAt = CreateConVar("ttt2_minigames_moveDamage_maxDmgAt", "5000", {FCVAR_ARCHIVE}, "ttt2_minigames_moveDamage_maxDmgAt")
  local ttt2_minigames_moveDamage_fullDmgAt = CreateConVar("ttt2_minigames_moveDamage_fullDmgAt", "220", {FCVAR_ARCHIVE}, "ttt2_minigames_moveDamage_fullDmgAt")
  function MINIGAME:OnActivation()
    hook.Add("PlayerTakeDamage", "MinigameMoveDamage", function(ent, infl, att, amount, dmginfo)
      if not ent:IsPlayer() then return end

      local playerSpeed = infl:GetVelocity():Length()
      print(playerSpeed)
      if(playerSpeed > ttt2_minigames_moveDamage_maxDmgAt:GetInt()) then
          playerSpeed = ttt2_minigames_moveDamage_maxDmgAt:GetInt()
      end
      local scaleFactor;
      if(playerSpeed <= ttt2_minigames_moveDamage_fullDmgAt:GetInt()) then
          scaleFactor = ((playerSpeed - ttt2_minigames_moveDamage_fullDmgAt:GetInt()) / ttt2_minigames_moveDamage_fullDmgAt:GetInt()) + 1;
      else
          scaleFactor = (playerSpeed - ttt2_minigames_moveDamage_fullDmgAt:GetInt()) * 0.005 + 1
      end
      dmginfo:ScaleDamage(scaleFactor)
    end)
  end

  function MINIGAME:OnDeactivation()
    hook.Remove("EntityFireBullets", "MinigameMoveDamage")
  end
end