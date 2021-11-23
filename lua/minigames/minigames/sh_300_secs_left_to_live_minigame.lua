if SERVER then
    AddCSLuaFile()

    util.AddNetworkString("ttt2mg_time_attack_hud_timer")
    util.AddNetworkString("ttt2mg_time_attack_stop_timer")
end

MINIGAME.author = "aPythagorion"
MINIGAME.contact = "TTT2 Discord => aPythagorion"

MINIGAME.conVarData = {
    ttt2_minigames_seconds_left = {
        slider = true,
        min = 1,
        max = 500,
        desc = "ttt2_minigames_seconds_left (Def. 300)"
    },
    ttt2_minigames_t_attack_theme = {
        checkbox = true,
        desc = "ttt2_minigames_t_attack_theme (Def. 1)"
    },
    ttt2_minigames_theme_delay = {
        slider = true,
        min = 0.1,
        max = 500,
        decimal = 1,
        desc = "ttt2_minigames_theme_delay (Def. 300)"
    }
}

sound.Add({
    name = "t_attack",
    channel = CHAN_AUTO,
    volume = 1.0,
    soundlevel = SNDLVL_NONE,
    sound = "time_attack_game/t_attack.wav"
})

local LoadedSounds
if CLIENT then
	LoadedSounds = {}
end

local function ReadSound( FileName )
	local sound
	local filter
	if SERVER then
		filter = RecipientFilter()
		filter:AddAllPlayers()
	end
	if SERVER or !LoadedSounds[FileName] then
		sound = CreateSound( game.GetWorld(), FileName, filter )
		if sound then
			sound:SetSoundLevel( 0 )
			if CLIENT then
				LoadedSounds[FileName] = { sound, filter }
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
			en = "Speedy-Comet inbound!",
			de = "Zeitangriff-Komet im Anflug!"
		},
		desc = {
			en = "What will happen to Life, when the timer reaches zero?",
			de = "Was wird nur mit all den Lebenden passieren, wenn die Uhr 0 erreicht?"
		}
	}
else
    local ttt2_minigames_seconds_left = CreateConVar("ttt2_minigames_seconds_left", "300", {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Seconds left to live")
    local ttt2_minigames_t_attack_theme = CreateConVar("ttt2_minigames_t_attack_theme", "1", {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Play the Super Mario Galaxy Time Attack Theme, while the clock is ticking")
    local ttt2_minigames_theme_delay = CreateConVar("ttt2_minigames_theme_delay", "0.1", {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Set a delay, when the theme begins to play")
    local t_attack_th_runs = nil

    function MINIGAME:OnActivation()
        if GetRoundState() ~= ROUND_ACTIVE then return end

        -- tell that the timer was started
        SetGlobalBool("timer_runs", true)
        SetGlobalInt("timer_dur", ttt2_minigames_seconds_left:GetInt())

        -- start displaying timer on player's screen
        net.Start("ttt2mg_time_attack_hud_timer")
        net.Broadcast()

        if ttt2_minigames_t_attack_theme:GetBool() then
            timer.Create("AttackThemeDelayTimer", ttt2_minigames_theme_delay:GetFloat(), 1, function()
                t_attack_theme = ReadSound("time_attack_game/t_attack.wav")
                t_attack_theme:Play()
                t_attack_th_runs = true
            end)
        end

        -- set timer starting time and duration
        SetGlobalInt("timer_start_time", CurTime())
        SetGlobalInt("timer_dur_time", ttt2_minigames_seconds_left:GetInt())

        timer.Create("SecondsLeftMGTimer", ttt2_minigames_seconds_left:GetInt(), 1, function()
            if GetRoundState() ~= ROUND_ACTIVE then timer.Remove("SecondsLeftMGTimer") end
            local plys = player.GetAll()

            for i=1, #plys do
                if plys[i]:IsActive() then
                    plys[i]:Kill()
                end
            end   

            SetGlobalBool("timer_runs", false)

            hook.Add("TTTCheckForWin", "ttt2_SoSWinMG", function()
                return TEAM_NONE
            end)
        end)
    end
    
    function MINIGAME:OnDeactivation()
        if t_attack_th_runs then
            t_attack_theme:Stop()
            timer.Remove("AttackThemeDelayTimer")
        end

        timer.Remove("SecondsLeftMGTimer")
        hook.Remove("TTTCheckForWin", "ttt2_SoSWinMG")

        net.Start("ttt2mg_time_attack_stop_timer")
        net.Broadcast()
    end
end

if CLIENT then
    local seconds_left = GetConVar("ttt2_minigames_seconds_left"):GetInt()

    net.Receive("ttt2mg_time_attack_hud_timer", function()
        timer.Create("ttt2mg_time_attack_hud_timer", seconds_left, 1, function() end)
    end)

    net.Receive("ttt2mg_time_attack_stop_timer", function()
        timer.Remove("ttt2mg_time_attack_hud_timer")
    end)
end