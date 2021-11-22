if SERVER then
    AddCSLuaFile()
end

MINIGAME.author = "aPythagorion"
MINIGAME.contact = "TTT2 Discord => aPythagorion"

if CLIENT then
    MINIGAME.lang = {
		name = {
			en = "What a Crab Game",
			de = "Was für ein Crab Game"
		},
		desc = {
			en = "Did anyone say 2D is a good idea?",
			de = "Hat jemand gesagt, dass 2D eine gute Idee ist?"
		}
	}
else -- SERVER
    function MINIGAME:OnActivation()
        hook.Add("SetupMove", "ttt2_mg_no_forwarding", function(ply, mv, cmd)
            if ply:Alive() then
                mv:SetForwardSpeed(0)
            end
        end)
    end

    function MINIGAME:OnDeactivation()
        hook.Remove("SetupMove", "ttt2_mg_no_forwarding")
    end
end