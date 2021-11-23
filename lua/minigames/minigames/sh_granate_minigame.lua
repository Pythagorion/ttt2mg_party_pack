if SERVER then
    AddCSLuaFile()
end

MINIGAME.author = "Sirzento"
MINIGAME.contact = "Sirzento | Nico on TTT2 Discord"

function MINIGAME:AddToSettingsMenu(parent)
    local form = vgui.CreateTTT2Form(parent, "header_minigames_extra_settings")
  
    form:MakeSlider({
        serverConvar = "ttt2_minigames_granate_timer",
        label = "label_minigames_granate_timer",
        min = 1,
        max = 10,
        decimal = 0
    })
  end

if CLIENT then
    MINIGAME.lang = {
        name = {
            English = "GRANATE!"
        },
        desc = {
            English = "I can't speak german but I think that doesn't mean anything good.."
        }
    }
end

if SERVER then
    local ttt2_minigames_granate_timer = CreateConVar("ttt2_minigames_granate_timer", "3", {FCVAR_ARCHIVE},
        "ttt2_minigames_granate_timer")
    local function BetterWeaponStrip(ply)
        if not ply or not IsValid(ply) or not ply:IsPlayer() then
            return
        end

        local weps = ply:GetWeapons()
        for i = 1, #weps do
            
            local wep = weps[i]
            local wep_class = wep:GetClass()
            if wep.Kind ~= WEAPON_NADE then
                print("strip weapon")
                ply:StripWeapon(wep_class)
            end
        end
    end

    function MINIGAME:OnActivation()
        timer.Create("GranateMinigame", ttt2_minigames_granate_timer:GetInt(), 0, function()
            if GetRoundState() ~= ROUND_ACTIVE then
                timer.Remove("GranateMinigame")
                return
            end
            local plys = player.GetAll()
            for i = 1, #plys do
                print("for loop")
                local ply = plys[i]
                if not ply:Alive() or ply:IsSpec() then continue end

                BetterWeaponStrip(ply)
                if ply:HasWeapon("weapon_tttbasegrenade") then continue end
                print("give nade")
                ply:Give("weapon_tttbasegrenade")
                ply:SelectWeapon("weapon_tttbasegrenade")

            end
        end)
    end

    function MINIGAME:OnDeactivation()
        timer.Remove("GranateMinigame")
    end

end
