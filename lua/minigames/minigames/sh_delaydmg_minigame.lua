if SERVER then
    AddCSLuaFile()
end

MINIGAME.author = "Sirzento"
MINIGAME.contact = "Sirzento | Nico on TTT2 Discord"

function MINIGAME:AddToSettingsMenu(parent)
    local form = vgui.CreateTTT2Form(parent, "header_minigames_extra_settings")

    form:MakeSlider({
        serverConvar = "ttt2_minigames_delaydmg_delay",
        label = "label_minigames_delaydmg_delay",
        min = 1,
        max = 30,
        decimal = 0
    })
end

hook.Add("Initialize", "AddDelayAmmo", function()
  game.AddAmmoType( {
    name = "delay_ammo",
    dmgtype = DMG_BULLET,
    tracer = TRACER_LINE,
    plydmg = 0,
    npcdmg = 0,
    force = 2000,
    minsplash = 10,
    maxsplash = 5
  } )
end)

if CLIENT then
    MINIGAME.lang = {
        name = {
            English = "First panic, then pain"
        },
        desc = {
            English = "I didn't even felt the pain until later"
        }
    }
end

if SERVER then
    local ttt2_minigames_delaydmg_delay = CreateConVar("ttt2_minigames_delaydmg_delay", "10", {FCVAR_ARCHIVE},
        "ttt2_minigames_delaydmg_delay")
    local timers = {}


    function MINIGAME:OnActivation()
      hook.Add("PlayerTakeDamage", "MinigameDelayDmg", function(ent, infl, att, amount, dmginfo)
        if not ent:IsPlayer() then return end
        
        if game.GetAmmoID("delay_ammo") ~= dmginfo:GetAmmoType() then
            dmginfo:SetDamage(0)
            local SteamID = ent:SteamID64()
            local SteamIDAtck = att:SteamID64()
            local originalAmmoType = dmginfo:GetAmmoType()
            local id = "ttt2_minigames_delaydmg_" .. SteamID .. tostring(CurTime())
            timer.Create(id, ttt2_minigames_delaydmg_delay:GetInt(), 1, function()
                local p = player.GetBySteamID64(SteamIDAtck)
                dmginfo:SetDamage(amount)
                dmginfo:SetAttacker(p)
                dmginfo:SetAmmoType(game.GetAmmoID("delay_ammo"))
                ent:TakeDamageInfo(dmginfo)
            end)
            timers[id] = true
        end 
      end)
    end

    function MINIGAME:OnDeactivation()
        hook.Remove("EntityFireBullets", "MinigameDelayDmg")
        for i, t in pairs(timers) do
            timer.Stop(i)
        end
    end
end
