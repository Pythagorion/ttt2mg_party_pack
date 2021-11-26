if SERVER then
    AddCSLuaFile()
end

MINIGAME.author = "aPythagorion"
MINIGAME.contact = "TTT2 Discord => aPythagorion"

MINIGAME.conVarData = {
    ttt2_minigames_avoid_water_speed_modifier = {
        slider = true,
        min = 0,
        max = 1,
        decimal = 1,
        desc = "ttt2_minigames_avoid_water_speed_modifier (def. 0.1)"
    },

    ttt2_minigames_avoid_water_damage_tick = {
        slider = true,
        min = 0,
        max = 10,
        decimal = 1,
        desc = "ttt2_minigames_avoid_water_damage_tick (def. 1.0)"
    },

    ttt2_minigames_avoid_water_damage_amount = {
        slider = true,
        min = 1,
        max = 999,
        desc = "ttt2_minigames_avoid_water_damage_amount (def. 10)"
    }
}

if CLIENT then
    MINIGAME.lang = {
		name = {
			en = "Better avoid the Water!",
			de = "Meidet das Wasser!"
		},
		desc = {
			en = "The lifeguard is on vacation, so stay away from the water. This can be deadly.",
			de = "Der Bademeister hat Urlaub, also halte dich vom Wasser fern. Das kann tödlich sein."
		}
	}
else -- SERVER
    local ttt2_minigames_avoid_water_speed_modifier = CreateConVar("ttt2_minigames_avoid_water_speed_modifier", "0.1", {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Change the player's speed in water")
    local ttt2_minigames_avoid_water_damage_tick = CreateConVar("ttt2_minigames_avoid_water_damage_tick", "1.0", {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Change the damage tickrate")
    local ttt2_minigames_avoid_water_damage_amount = CreateConVar("ttt2_minigames_avoid_water_damage_amount", "10", {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Amount of damage, players will receive in water")

    function MINIGAME:OnActivation()
        hook.Add("TTTPlayerSpeedModifier", "ttt2_mg_drowning_plys", function(ply, _, _, speedMultiplierModifier)
            if ply:Alive() and ply:WaterLevel() > 0 then
                speedMultiplierModifier[1] = speedMultiplierModifier[1] * ttt2_minigames_avoid_water_speed_modifier:GetFloat()
            end
        end)    

        local possible_think = 0

        hook.Add("Think", "ttt2_mg_drowning_ply_tk", function()
            if CurTime() < possible_think then return end

            possible_think = CurTime() + ttt2_minigames_avoid_water_damage_tick:GetFloat()

            local plys = player.GetAll()

            for i=1, #plys do
                local ply = plys[i]

                if ply:Alive() and ply:WaterLevel() > 0 then
                    ply:TakeDamage( ttt2_minigames_avoid_water_damage_amount:GetInt() )
                end
            end
        end)
    end

    function MINIGAME:OnDeactivation()
        hook.Remove("TTTPlayerSpeedModifier", "ttt2_mg_drowning_plys")
        hook.Remove("Think", "ttt2_mg_drowning_ply_tk")
    end
end