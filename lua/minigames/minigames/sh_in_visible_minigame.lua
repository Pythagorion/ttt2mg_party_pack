if SERVER then
    AddCSLuaFile()
    util.AddNetworkString("ttt2_mg_inator_txt_pew")
    util.AddNetworkString("ttt2_mg_inator_sound_pew")
    resource.AddFile("sound/inator_minigame/pew.mp3")
end

sound.Add({
	name = "pew",
	channel = CHAN_AUTO,
	volume = 2.0,
	soundlevel = SNDLVL_NONE,
	sound = "inator_minigame/pew.mp3"
})

MINIGAME.author = "aPythagorion"
MINIGAME.contact = "TTT2 Discord => aPythagorion"

MINIGAME.conVarData = {
    ttt2_minigames_inator_intervall = {
        slider = true, 
        min = 0,
        max = 500,
        desc = "ttt2_minigames_inator_intervall (def. 30)"
    },

    ttt2_minigames_inator_switch_txt_indicator = {
        checkbox = true,
        desc = "ttt2_minigames_inator_switch_txt_indicator (def. 0)"
    },

    ttt2_minigames_inator_switch_sound_indicator = {
        checkbox = true,
        desc = "ttt2_minigames_inator_switch_sound_indicator (def. 0)"
    },

    ttt2_minigames_fully_invisible = {
        checkbox = true,
        desc = "ttt2_minigames_fully_invisible (def. 1)"
    }
}

if CLIENT then
    MINIGAME.lang = {
        name = {
            en = "In-Visible-I-nator",
            de = "Un-Sichtbar-I-nator"
        },
        desc = {
            en = "Seems like Agent P is fighting Dr. Doofenschmirtz again",
            de = "Sieht so aus als würde Agent P wieder gegen Dr. Doofenschmirtz kämpfen"
        }
    }

else -- SERVER
    local ttt2_minigames_inator_intervall = CreateConVar("ttt2_minigames_inator_intervall", "30", {FCVAR_ARCHIVE}, "The intervall the visibility changes.")
    local ttt2_minigames_inator_switch_txt_indicator = CreateConVar("ttt2_minigames_inator_switch_txt_indicator", "0", {FCVAR_ARCHIVE}, "Everytime the intervall switches, an indicator announces that. (text)")
    local ttt2_minigames_inator_switch_sound_indicator = CreateConVar("ttt2_minigames_inator_switch_sound_indicator", "0", {FCVAR_ARCHIVE}, "Everytime the intervall switches, an indicator announces that. (sound)")
    local ttt2_minigames_fully_invisible = CreateConVar("ttt2_minigames_fully_invisible", "1", {FCVAR_ARCHIVE}, "Sets the player fully invisible if activated.")

    local function MakeInvisibleInator(ply)
        ply.inatorPlyColor = ply:GetColor()
        ply.inatorPlyRenderMode = ply:GetRenderMode()
        ply.inatorPlyMat = ply:GetMaterial()

        local ply_inatorcolor = Color(255, 255, 255, 50)

        ply:SetColor(ply_inatorcolor)
        ply:SetMaterial("sprites/heatwave")
        if ttt2_minigames_fully_invisible:GetBool() then
            ply:SetRenderMode(RENDERMODE_NONE)
        else
            ply:SetRenderMode(RENDERMODE_TRANSALPHA)
        end
    end

    local function MakeVisibleInator(ply)
        ply:SetColor(ply.inatorPlyColor)
        ply:SetRenderMode(ply.inatorPlyRenderMode)
        ply:SetMaterial(ply.inatorPlyMat)
    end

    function MINIGAME:OnActivation()

        local invisible_setting = true

        timer.Create("ttt2_mg_inator_switch", ttt2_minigames_inator_intervall:GetInt(), 0, function()

            if ttt2_minigames_inator_switch_txt_indicator:GetBool() then
                net.Start("ttt2_mg_inator_txt_pew")
                net.Broadcast()
            end

            if ttt2_minigames_inator_switch_sound_indicator:GetBool() then
                net.Start("ttt2_mg_inator_sound_pew")
                net.WriteBool(true)
                net.Broadcast()
            end

            local plys = player.GetAll()

            for i = 1, #plys do
                local ply = plys[i]

                if ply:IsSpec() then continue end

                if invisible_setting then
                    MakeInvisibleInator(ply)
                else
                    MakeVisibleInator(ply)
                end
            end

            if invisible_setting then
                invisible_setting = false
            else
                invisible_setting = true
            end
        end)
    end

    function MINIGAME:OnDeactivation()
        local plys = player.GetAll()

        for i = 1, #plys do
            local ply = plys[i]

            if not ply:IsValid() then continue end

            if not invisible_setting then
                MakeVisibleInator(ply)
            else 
                continue 
            end
        end
        
        timer.Remove("ttt2_mg_inator_switch")
    end
end

if CLIENT then
    net.Receive("ttt2_mg_inator_txt_pew", function()

        EPOP:AddMessage({
            text = LANG.TryTranslation("ttt2mg_pew_epop"),
            color = COLOR_ORANGE},
            nil,
            2,
            nil,
            true
          )
    end)

    net.Receive("ttt2_mg_inator_sound_pew", function()

        local playpew = net.ReadBool()

        if playpew then
            surface.PlaySound("inator_minigame/pew.mp3")
        end
    end)
end