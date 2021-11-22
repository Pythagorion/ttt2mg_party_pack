if SERVER then
    AddCSLuaFile()
end

MINIGAME.author = "aPythagorion"
MINIGAME.contact = "TTT2 Discord => aPythagorion"

MINIGAME.conVarData = {
    ttt2_minigames_random_damage_minimum = {
        slider = true,
        min = 1, 
        max = 50,
        desc = "ttt2_minigames_random_damage_minimum (def. 1)"
    },

    ttt2_minigames_random_damage_maximum = {
        slider = true,
        min = 51,
        max = 999,
        desc = "ttt2_minigames_random_damage_maximum (def. 99)"
    }  
}

if CLIENT then
    MINIGAME.lang = {
		name = {
			en = "Random Damage for everyone!",
			de = "Schaden für jeden!"
		}
	}
else -- SERVER
    local ttt2_minigames_random_damage_minimum = CreateConVar("ttt2_minigames_random_damage_minimum", "1", {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Minimum amount of damage that may be chosen")
    local ttt2_minigames_random_damage_maximum = CreateConVar("ttt2_minigames_random_damage_maximum", "99", {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Maximum amount of damage that may be chosen")

    function MINIGAME:OnActivation()
        local plys = player.GetAll()

        for i=1, #plys do
            local ply = plys[i]

            if ply:Alive() then
                ply:TakeDamage( math.random( ttt2_minigames_random_damage_minimum:GetInt(), ttt2_minigames_random_damage_maximum:GetInt() ) )
            end
        end
    end

    function MINIGAME:OnDeactivation()

    end
end