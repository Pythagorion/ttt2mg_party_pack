if SERVER then
    AddCSLuaFile()
    util.AddNetworkString("ttt2_mg_lottery_go")
end

MINIGAME.author = "aPythagorion"
MINIGAME.contact = "TTT2 Discord => aPythagorion"

if CLIENT then
    MINIGAME.lang = {
		name = {
			en = "Jump too high or not jump at all, that is the question",
			de = "Zu hoch springen oder gar nicht springen, das ist hier die Frage"
		},
		desc = {
			en = "",
			de = ""
		}
	}

    MINIGAME.conVarData = {
        ttt2_minigames_jump_velocity = {
            slider = true, 
            min = 250,
            max = 1000,
            desc = "ttt2_minigames_jump_velocity (def. 500)"
        }
    }

else -- SERVER
    local ttt2_minigames_jump_velocity = CreateConVar("ttt2_minigames_jump_velocity", "500", {FCVAR_ARCHIVE}, "Sets the Velocity for the players that can jump.")

    function MINIGAME:OnActivation()

        local group_1 = {}
        local group_2 = {}

        local plys = player.GetAll()

        for i=1, #plys do
            local ply = plys[i]
            local coin = math.random(1, 2)

            if coin == 1 then
                table.insert(group_1, ply)
            else
                table.insert(group_2, ply)
            end
        end

        for i = 1, #group_1 do
            local ply_1 = group_1[i]

            print(ply_1:GetJumpPower())

            if ply_1:Alive() and not ply_1:IsSpec() then
                ply_1:SetJumpPower(ttt2_minigames_jump_velocity:GetInt())
            end
        end

        for i = 1, #group_2 do
            local ply_2 = group_2[i]

            if ply_2:Alive() and not ply_2:IsSpec() then
                ply_2:SetJumpPower(0)
            end
        end
    end

    function MINIGAME:OnDeactivation()
        local plys = player.GetAll()
        for i = 1, #plys do
            local ply = plys[i]
            ply:SetJumpPower(160)
        end
    end
end