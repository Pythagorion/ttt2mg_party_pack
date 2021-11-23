if SERVER then
  AddCSLuaFile()
end

MINIGAME.author = "Sirzento"
MINIGAME.contact = "Sirzento | Nico on TTT2 Discord"

function MINIGAME:AddToSettingsMenu(parent)
  local form = vgui.CreateTTT2Form(parent, "header_minigames_extra_settings")

  form:MakeSlider({
      serverConvar = "ttt2_minigames_dmgboost_max",
      label = "label_minigames_dmgboost_max",
      min = 1000,
      max = 200000,
      decimal = 0
  })
end

if CLIENT then
  MINIGAME.lang = {
    name = {
      English = "Heavy Weapons"
    },
    desc = {
      English = "Those weapons have quite the impact"
    }
  }
end

if SERVER then
  local ttt2_minigames_dmgboost_max = CreateConVar("ttt2_minigames_dmgboost_max", "150000", {FCVAR_ARCHIVE}, "ttt2_minigames_dmgboost_max")
  function MINIGAME:OnActivation()
    hook.Add("PlayerTakeDamage", "MinigameDmgBoost", function(ent, infl, att, amount, dmginfo)
      if not ent:IsPlayer() then return end

      local dmgForce = dmginfo:GetDamageForce()
      local velocity = dmgForce * math.exp(tonumber(math.pow(amount / 2, 1 / 2))) * 10
      if velocity:Length() > ttt2_minigames_dmgboost_max:GetInt() then
        velocity = (velocity / velocity:Length()) * ttt2_minigames_dmgboost_max:GetInt()
      end
      print(velocity)
      ent:SetVelocity(velocity)
    end)
  end

  function MINIGAME:OnDeactivation()
    hook.Remove("PlayerTakeDamage", "MinigameDmgBoost")
  end
end