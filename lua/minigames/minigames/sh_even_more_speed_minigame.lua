if SERVER then
    AddCSLuaFile()
end

MINIGAME.author = "aPythagorion"
MINIGAME.contact = "TTT2 Discord => aPythagorion"

MINIGAME.conVarData = {
    ttt2_minigames_flash_walk_speed = {
        slider = true,
        min = 0,
        max = 10,
        decimal = 1,
        desc = "ttt2_minigames_flash_walk_speed (def. 2.0)"
    },

    ttt2_minigames_flash_run_speed = {
        slider = true,
        min = 0,
        max = 10,
        decimal = 1,
        desc = "ttt2_minigames_flash_run_speed (def. 2.0)"
    },

    ttt2_minigames_flash_nopropdmg_item = {
        checkbox = true,
        desc = "ttt2_minigames_flash_nopropdmg_item (def. 1)"
    }
}

if CLIENT then
    MINIGAME.lang = {
		name = {
			en = "Even more Speeeeeeed!",
			de = "Noch mehr Geschwindigkeit!"
		},
		desc = {
			en = "Let's Play Trouble in Flash-Town",
			de = "Lasst uns Trouble in Flash-Town spielen"
		}
	}
else -- SERVER
    local ttt2_minigames_flash_walk_speed = CreateConVar("ttt2_minigames_flash_walk_speed", "2.0", {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Change the walk speed of all players.")
    local ttt2_minigames_flash_run_speed = CreateConVar("ttt2_minigames_flash_run_speed", "2.0", {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Change the walk speed of all players.")
    local ttt2_minigames_flash_nopropdmg_item = CreateConVar("ttt2_minigames_flash_nopropdmg_item", "1", {FCVAR_ARCHIVE}, "If enabled, everyone will receive the no prop damage item.")

    function MINIGAME:OnActivation()
        if ttt2_minigames_flash_nopropdmg_item:GetBool() then
            local plys = player.GetAll()

            for i=1, #plys do
                plys[i]:GiveEquipmentItem("item_ttt_nopropdmg")
            end
        end

        hook.Add("TTTPlayerSpeedModifier", "ttt2_mg_flash_w_speed", function(ply, _, _, speedMultiplierModifier)
            if ply:Alive() then
                speedMultiplierModifier[1] = speedMultiplierModifier[1] * ttt2_minigames_flash_walk_speed:GetFloat()
            end
        end)

        hook.Add("TTT2PlayerSprintMultiplier", "ttt2_mg_flash_spr_speed", function(ply, sprintMultiplierModifier)
            if ply:Alive() then
                sprintMultiplierModifier[1] = sprintMultiplierModifier[1] * ttt2_minigames_flash_run_speed:GetFloat()
            end
        end)
    end
    
    function MINIGAME:OnDeactivation()
       hook.Remove("TTT2PlayerSprintMultiplier", "ttt2_mg_flash_spr_speed")
       hook.Remove("TTTPlayerSpeedModifier", "ttt2_mg_flash_w_speed")
    end
end
