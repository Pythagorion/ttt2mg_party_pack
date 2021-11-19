if SERVER then
    AddCSLuaFile()
end

MINIGAME.author = "Sirzento"
MINIGAME.contact = "Sirzento | Nico on TTT2 Discord"

MINIGAME.conVarData = {
    ttt2_minigames_delaydmg_delay = {
        slider = true,
        min = 1,
        max = 30,
        decimal = 0,
        desc = "ttt2_minigames_delaydmg_delay (Def. 10)"
    }
}

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
        
        print(game.GetAmmoID("delay_ammo"))
        print(dmginfo:GetAmmoType())
        if game.GetAmmoID("delay_ammo") ~= dmginfo:GetAmmoType() then
            print("start timer")
            dmginfo:SetDamage(0)
            local SteamID = ent:SteamID64()
            local SteamIDAtck = att:SteamID64()
            local id = "ttt2_minigames_delaydmg_" .. SteamID .. tostring(CurTime())
            timer.Create(id, ttt2_minigames_delaydmg_delay:GetInt(), 1, function()
                local p = player.GetBySteamID64(SteamIDAtck)
                dmginfo:SetDamage(amount)
                dmginfo:SetAttacker(p)
                dmginfo:SetAmmoType(game.GetAmmoID("delay_ammo"))
                print("Damaging player...")
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
