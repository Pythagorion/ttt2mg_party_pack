if SERVER then
    AddCSLuaFile()
end

MINIGAME.author = "Sirzento"
MINIGAME.contact = "Sirzento | Nico on TTT2 Discord"


function MINIGAME:AddToSettingsMenu(parent)
  local form = vgui.CreateTTT2Form(parent, "header_minigames_extra_settings")

  form:MakeSlider({
      serverConvar = "ttt2_minigames_compulsivereloading_timer",
      label = "label_minigames_compulsivereloading_timer",
      min = 1,
      max = 10,
      decimal = 0
  })
end

if CLIENT then
  MINIGAME.lang = {
    name = {
      en = "Compulsive Reloading",
      de = "Zwanghaftes Nachladen"
    },
    desc = {
      en = "Where is my ammo?",
      de = "Wo ist meine Munition?"
    }
  }
end

if SERVER then
  local ttt2_minigames_compulsivereloading_timer = CreateConVar("ttt2_minigames_compulsivereloading_timer", "1", {FCVAR_ARCHIVE},
  "ttt2_minigames_compulsivereloading_timer")
  function MINIGAME:OnActivation()
      timer.Create("CompulsiveReloadingMinigame", ttt2_minigames_compulsivereloading_timer:GetInt(), 0, function()
          local plys = player.GetAll()
          for i = 1, #plys do
              local weapon = plys[i]:GetActiveWeapon()
              if weapon:Clip1() > 0 then
                  weapon:SetClip1(weapon:Clip1() - 1)
                  local ammoType = weapon:GetPrimaryAmmoType()
                  plys[i]:SetAmmo(plys[i]:GetAmmoCount(ammoType) + 1, ammoType)
              end
          end
      end)
  end

  function MINIGAME:OnDeactivation()
    hook.Remove("PlayerTakeDamage", "MinigameDmgBoost")
    timer.Remove("CompulsiveReloadingMinigame")
  end
end