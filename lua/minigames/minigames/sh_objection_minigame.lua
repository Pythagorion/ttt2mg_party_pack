if SERVER then
    AddCSLuaFile()
    util.AddNetworkString("ttt2_mg_objection_draw_phoenix")
    util.PrecacheSound("phoenix_minigame/minigame_objection.wav")
    resource.AddFile("materials/ttt2mg_objection/phoenix_objection.vmt")
end

MINIGAME.author = "aPythagorion"
MINIGAME.contact = "TTT2 Discord => aPythagorion"

MINIGAME.conVarData = {
    ttt2_minigames_objection_duration = {
        slider = true, 
        min = 0,
        max = 500,
        desc = "ttt2_minigames_objection_duration (def. 5)"
    }
}

-- configuring sounds for later purpose
local LoadedSounds = {}

local function ReadSound(FileName)
	local sound, filter

	if SERVER then
		filter = RecipientFilter()
		filter:AddAllPlayers()
	end

	if SERVER or not LoadedSounds[FileName] then
		sound = CreateSound(game.GetWorld(), FileName, filter)

		if sound then
			sound:SetSoundLevel(0)

			if CLIENT then
				LoadedSounds[FileName] = {sound, filter}
			end
		end
	else
		sound = LoadedSounds[FileName][1]
		filter = LoadedSounds[FileName][2]
	end

	if sound then
		if CLIENT then
			sound:Stop()
		end

		sound:Play()
	end

	return sound
end

if CLIENT then
    MINIGAME.lang = {
        name = {
			en = "OBJECTION!",
			de = "EINSPRUCH!"
		},
		desc = {
			en = "Player 'Phoenix Wright' joined the lobby",
			de = "Player 'Phoenix Wright' ist dem Spiel beigetreten"
		}
    }
else -- SERVER
    local ttt2_minigames_objection_duration = CreateConVar("ttt2_minigames_objection_duration", "5", {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Duration Phoenix stays on the screen.")

    function MINIGAME:OnActivation()
        hook.Add("TTT2CalledPolicingRole", "ttt2_mg_objection_call", function(policingPlys, finder, ragdoll, deadply)

            if finder:GetBaseRole() == ROLE_DETECTIVE then return end

            local dete_available = 0
            local traitor_available = 0

            -- search for living policing role and switch position with finder
            for i=1, #policingPlys do
                local possible_ply = policingPlys[i]
                if possible_ply:Alive() and possible_ply:GetBaseRole() == ROLE_DETECTIVE then

                    -- Switch positions
                    local finder_pos = finder:GetPos()
                    finder:SetPos(possible_ply:GetPos())
                    possible_ply:SetPos(finder_pos)

                    dete_available = dete_available + 1
                    break
                end
            end

            -- if all policing player are dead, switch finder with a traitor instead
            local plys = player.GetAll()
            for i=1, #plys do
                local possible_tr = plys[i]
                if possible_tr:GetTeam() == TEAM_TRAITOR and possible_tr:Alive() then

                    -- Switch positions
                    local tr_pos = possible_tr:GetPos()
                    local finder_pos = finder:GetPos()

                    possible_tr:SetPos(finder_pos)
                    finder:SetPos(tr_pos)

                    traitor_available = traitor_available + 1
                    break
                end
            end

            if dete_available == 1 then
                net.Start("ttt2_mg_objection_draw_phoenix")
                net.Broadcast()
                ReadSound("phoenix_minigame/minigame_objection.wav")
            elseif traitor_available == 1 then
                net.Start("ttt2_mg_objection_draw_phoenix")
                net.Broadcast()
                ReadSound("phoenix_minigame/minigame_objection.wav")
            end          
        end)
    end

    function MINIGAME:OnDeactivation()
        hook.Remove("TTT2CalledPolicingRole", "ttt2_mg_objection_call")
    end
end

if CLIENT then
    local objection_dur = GetConVar("ttt2_minigames_objection_duration"):GetInt()

    net.Receive("ttt2_mg_objection_draw_phoenix", function()
        hook.Add("RenderScreenspaceEffects", "ttt2_mg_objection_draw_phoenix_w", function()
            DrawMaterialOverlay("ttt2mg_objection/phoenix_objection", 0)
        end)

        timer.Simple(objection_dur, function()
            hook.Remove("RenderScreenspaceEffects", "ttt2_mg_objection_draw_phoenix_w")
        end)
    end)
end