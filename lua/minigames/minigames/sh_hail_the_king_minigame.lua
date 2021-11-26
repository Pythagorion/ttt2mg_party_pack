if SERVER then
    AddCSLuaFile()
    util.AddNetworkString("ttt2_hail_the_king_chosen")
    util.AddNetworkString("ttt2_traitor_instruct")
    util.AddNetworkString("ttt2_king_dead")
    util.AddNetworkString("ttt2_denounce_tr")
end

MINIGAME.author = "aPythagorion"
MINIGAME.contact = "TTT2 Discord => aPythagorion"

MINIGAME.conVarData = {
    ttt2_minigames_king_kill_time = {
        slider = true,
        min = 1,
        max = 600,
        desc = "ttt2_minigames_king_kill_time (def. 150)"
    },

    ttt2_minigames_kings_health = {
        slider = true,
        min = 1,
        max = 400,
        desc = "ttt2_minigames_kings_health (def. 150)"
    },

    ttt2_minigames_innos_max_health = {
        slider = true,
        min = 1,
        max = 75,
        desc = "ttt2_minigames_innos_max_health (def. 75)"
    },

    ttt2_minigames_traitors_max_health = {
        slider = true,
        min = 100,
        max = 500,
        desc = "ttt2_minigames_traitors_max_health (def. 150)"
    }
}

if CLIENT then
   
     -- message when the king was chosen
     net.Receive("ttt2_hail_the_king_chosen", function()
        local king = net.ReadEntity()
        EPOP:AddMessage({text = LANG.GetParamTranslation("ttt2_mg_htk_desc"),
        color = Color(209, 177, 19,255)},
        nil,
        10,
        nil,
        true
    )
    end)

    -- message with the instructions for the traitors
    net.Receive("ttt2_traitor_instruct", function()
        local ttk = net.ReadInt(11)
        chat.AddText(Color(87, 87, 255), LANG.GetParamTranslation("ttt2_tr_instructor"), Color(255, 87, 87), LANG.GetParamTranslation("ttt2_tr_instruct_msg"))
    end)

    -- message when the king is dead
    net.Receive("ttt2_king_dead", function()
        EPOP:AddMessage({text = LANG.GetParamTranslation("ttt2_king_death_title"), color = Color(255, 81, 33)}, LANG.GetParamTranslation("ttt2_king_death_subtitle"), 10)
    end)

    -- message when the traitors failed
    net.Receive("ttt2_denounce_tr", function()
        local denouncedOne = net.ReadEntity()
        EPOP:AddMessage({text = LANG.GetParamTranslation("ttt2_denounce_tr_title"), color = Color(163, 2, 39)}, LANG.GetParamTranslation("ttt2_denounce_tr_subtitle"), 10)
    end)

    MINIGAME.lang = {
		name = {
			en = "LONG LIVE THE KING!",
			de = "LANG LEBE DER KÖNIG!"
		}, 

        desc = {
            en = "",
            de = ""
        }
	}
else -- SERVER
    local kings = {}
    local enemies = {}

    local ttt2_minigames_king_kill_time = CreateConVar("ttt2_minigames_king_kill_time", "150", {FCVAR_ARCHIVE}, "Determine the time to kill the king.")
    local ttt2_minigames_kings_health = CreateConVar("ttt2_minigames_kings_health", "150", {FCVAR_ARCHIVE}, "Determine the amount of HP, the king will receive.")
    local ttt2_minigames_innos_max_health = CreateConVar("ttt2_minigames_innos_max_health", "75", {FCVAR_ARCHIVE}, "Define the max health of Innocents, when the Traitors kill the king.")
    local ttt2_minigames_traitors_max_health = CreateConVar("ttt2_minigames_traitors_max_health", "150", {FCVAR_ARCHIVE}, "Define the max health of Traitors, when they kill the king.")

    function MINIGAME:OnActivation()
        
        local plys = util.GetAlivePlayers()

        for i=1, #plys do
            local ply = plys[i]
            if ply:GetBaseRole() == ROLE_INNOCENT then
                table.insert(kings, ply)
            elseif ply:GetBaseRole() == ROLE_TRAITOR then
                table.insert(enemies, ply)
            end
        end

        local chosenKing = kings[math.random(1, #kings)]

        net.Start("ttt2_hail_the_king_chosen")
        net.WriteEntity(chosenKing)
        net.Broadcast()

        chosenKing:SetRole(ROLE_DETECTIVE)
        chosenKing:SetHealth(ttt2_minigames_kings_health:GetInt())
        chosenKing:SetModel("models/player/riot.mdl")

        net.Start("ttt2_traitor_instruct")
        net.WriteInt(ttt2_minigames_king_kill_time:GetInt(), 11)
        net.Send(enemies)

        SendFullStateUpdate()

        timer.Simple(ttt2_minigames_king_kill_time:GetInt(), function()
            if not chosenKing:Alive() then
                net.Start("ttt2_king_dead")
                net.Broadcast()

                local alivePlys = util.GetAlivePlayers()

                for i=1, #alivePlys do
                    local ply = alivePlys[i]

                    if ply:GetBaseRole() == ROLE_INNOCENT then -- Set alle special inno roles to innocent

                        //above or equals setted-max health set it to maxhealth
                        if ply:GetMaxHealth() >= ttt2_minigames_innos_max_health:GetInt() or ply:Health() >= ttt2_minigames_innos_max_health:GetInt() then

                            ply:SetMaxHealth(ttt2_minigames_innos_max_health:GetInt())
                            ply:SetHealth(ttt2_minigames_innos_max_health:GetInt())

                        //below setted-max health set it to their maxhealth if its not zero    
                        elseif ply:GetMaxHealth() < ttt2_minigames_innos_max_health:GetInt() and (ply:GetMaxHealth() - 25) > 25 then

                            ply:SetMaxHealth(ply:GetMaxHealth() - 25)

                        //else set maxhealth to current health    
                        else 

                            ply:SetMaxHealth(ply:Health())

                        end

                    elseif ply:GetBaseRole() == ROLE_TRAITOR then

                        ply:SetHealth(ttt2_minigames_traitors_max_health:GetInt())
                        ply:SetMaxHealth(ttt2_minigames_traitors_max_health:GetInt())
                    
                    elseif ply:GetBaseRole() == ROLE_DETECTIVE then

                        ply:SetRole(ROLE_INNOCENT)
                        
                    else return end
                end
            else
                local denouncedTraitor = enemies[math.random(1, #enemies)]
                net.Start("ttt2_denounce_tr")
                net.WriteEntity(denouncedTraitor)
                net.Broadcast()
            end  
            
            SendFullStateUpdate()
        end)
    end

    function MINIGAME:OnDeactivation()
        local plys = player.GetAll()

        for i=1, #plys do
            plys[i]:SetHealth(100)
            plys[i]:SetMaxHealth(100)
        end

        kings = nil
        enemies = nil
    end
end