if SERVER then
    AddCSLuaFile()
end

MINIGAME.author = "aPythagorion"
MINIGAME.contact = "TTT2 Discord => aPythagorion"

if CLIENT then
    MINIGAME.lang = {
		name = {
			en = "More Discord, less Trust",
			de = "Mehr Zwietracht, weniger Vertrauen"
		},
		desc = {
			en = "Having a Detective is so a big advantage for the Innocents, isn't it? Let's flip a coin!",
			de = "Einen Detektiv zu haben, ist also ein großer Vorteil für die Unschuldigen, nicht wahr? Lasst uns eine Münze werfen!"
		}
	}
else -- SERVER
    function CheckForDetective() -- function comes from Wasted's jesters-minigame
        local d = 0
        local plys = util.GetAlivePlayers()
        
        for i=1, #plys do
            if plys[i]:GetSubRoleData().isPolicingRole and plys[i]:GetSubRoleData().isPublicRole then
                d = 1
                return true
            end
        end

        if d > 0 then
            return true
        else
            return false
        end
    end

    function MINIGAME:OnActivation()
        if not CheckForDetective() then
            print("[TTT2][MINIGAMES][sh_trust_and_discord_minigame] ERROR OCCURED: NO DETECTIVE AVAILABLE!")
            return false
        end
        
        local plys = util.GetAlivePlayers()

        for i=1, #plys do
            local ply = plys[i]

            if roles.DEFECTIVE then
                if ply:GetSubRole() == ROLE_DEFECTIVE then  
                    ply:SetRole(ROLE_TRAITOR)
                end
            end

            if ply:GetSubRoleData().isPolicingRole and ply:GetSubRoleData().isPublicRole then
                local coin = math.random(1, 2)

                if coin == 1 then
                    ply:SetRole(ROLE_TRAITOR)
                else
                    ply:SetRole(ROLE_INNOCENT)
                end
            end
        end                    
        SendFullStateUpdate()
    end

    function MINIGAME:OnDeactivation()

    end
end