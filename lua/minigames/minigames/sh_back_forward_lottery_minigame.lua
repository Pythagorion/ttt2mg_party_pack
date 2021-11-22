if SERVER then
    AddCSLuaFile()
    util.AddNetworkString("ttt2_mg_lottery_go")
end

MINIGAME.author = "aPythagorion"
MINIGAME.contact = "TTT2 Discord => aPythagorion"

MINIGAME.conVarData = {
    ttt2_minigames_lottery_intervall = {
        slider = true, 
        min = 0,
        max = 500,
        desc = "ttt2_minigames_lottery_intervall (def. 15)"
    }
}

if CLIENT then
    MINIGAME.lang = {
		name = {
			en = "Movement-Lottery",
			de = "Steuerungs-Lotterie"
		},
		desc = {
			en = "Fate decides which players, move how. This will always change from time to time",
			de = "Das Schicksal entscheidet, welche Spieler, sich wie fortbewegen. Dies wird sich von Zeit zu Zeit immer wieder ändern."
		}
	}
else -- SERVER
    local ttt2_minigames_lottery_intervall = CreateConVar("ttt2_minigames_lottery_intervall", "15", {FCVAR_ARCHIVE}, "The Intervall the Controls change.")

    function MINIGAME:OnActivation()
        local group_a = {}
        local group_b = {}

        local plys = player.GetAll()

        for i=1, #plys do
            local ply = plys[i]
            local coin = math.random(1, 2)

            if coin == 1 then
                table.insert(group_a, ply)
            else
                table.insert(group_b, ply)
            end
        end

        local next_tick = 0

        hook.Add("Think", "ttt2_mg_new_tick", function()
            if CurTime() < next_tick then return end

            next_tick = CurTime() + ttt2_minigames_lottery_intervall:GetInt()

            net.Start("ttt2_mg_lottery_go")
            net.Broadcast()

            for i=1, #group_a do
                local ply_a = group_a[i]
                local ticket = math.random(1, 2)

                if ply_a:Alive() and not ply_a:IsSpec() then
                    if ticket == 1 then
                        ply_a:ConCommand("+forward")
                        ply_a:ConCommand("-back")
                    else
                        ply_a:ConCommand("-forward")
                        ply_a:ConCommand("+back")
                    end
                end

                if not ply_a.MgExcept and ticket == 1 then
                    ply_a:ConCommand("-forward")
                    ply_a.MgExcept = true
                elseif not ply_a.MgExcept and ticket == 2 then
                    ply_a:ConCommand("-back")
                    ply_a.MgExcept = true
                end
            end

            for i=1, #group_b do
                local ply_b = group_b[i]
                local ticket = math.random(1, 2)

                if ply_b:Alive() and not ply_b:IsSpec() then
                    if ticket == 1 then
                        ply_b:ConCommand("+moveleft")
                        ply_b:ConCommand("-moveright")
                    else
                        ply_b:ConCommand("-moveleft")
                        ply_b:ConCommand("+moveright")
                    end
                end

                if not ply_b.MgExcept and ticket == 1 then
                    ply_b:ConCommand("-moveleft")
                    ply_b.MgExcept = true
                elseif not ply_b.MgExcept and ticket == 2 then
                    ply_b:ConCommand("-moveright")
                    ply_b.MgExcept = true
                end
            end
        end)
    end

    function MINIGAME:OnDeactivation()
        hook.Remove("Think", "ttt2_mg_new_tick")
        local plys = player.GetAll()
        for i=1, #plys do
            plys[i]:ConCommand("-forward")
            plys[i]:ConCommand("-back")
            plys[i]:ConCommand("-moveright")
            plys[i]:ConCommand("-moveleft")

            plys[i].MgExcept = nil
        end
    end
end

if CLIENT then
    net.Receive("ttt2_mg_lottery_go", function()
        EPOP:AddMessage({
            text = LANG.TryTranslation("ttt2_mg_lottery_intervall_epop"),
            color = COLOR_ORANGE},
            nil,
            4,
            nil,
            true
        )
    end)
end
