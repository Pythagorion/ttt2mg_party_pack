if SERVER then
    AddCSLuaFile()
end

MINIGAME.author = "aPythagorion & Zetros"
MINIGAME.contact = "TTT2 Discord => aPythagorion"

MINIGAME.conVarData = {
    ttt2_minigames_sound_on_second_ger_memes = {
        checkbox = true,
        desc = "ttt2_minigames_sound_on_second_german_memes (def. 1)"
    }
}

if CLIENT then 
    MINIGAME.lang = {
		name = {
			en = "It's not what it sounds like...",
			de = "Es ist nicht das, wonach es sich anhört..."
		},
		desc = {
			en = "The brand new weapon collection now has a sound-(on)-board.",
			de = "Die neue Waffenkollektion hat nun ein Sound-mit-an-Board."
		}
	}
else -- SERVER
    local ttt2_minigames_sound_on_second_ger_memes = CreateConVar("ttt2_minigames_sound_on_second_ger_memes", "1", {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Add german memes to the sound pool")
    local chosen_sounds = {}

    function ChooseSound()
        local sound

        if ttt2_minigames_sound_on_second_ger_memes then
            sound = ( "sos_minigame/german_memes/meme" .. math.random( 1, 49 ) .. ".mp3" )
        else
            sound = ( "sos_minigame/only_international/meme" .. math.random( 1, 14 ) .. ".mp3" )
        end

        return sound
    end

    function PlayRandomSound(ent)
        local sound = ChooseSound()

        ent:EmitSound( sound )
    end

    function MINIGAME:OnActivation()
        hook.Add("PlayerSwitchWeapon", "ttt2_sos_switching", function(ply, old, new)
            if ply:IsValid() then
                PlayRandomSound(ply)
            end
        end)
    end

    function MINIGAME:OnDeactivation()
        hook.Remove("PlayerSwitchWeapon", "ttt2_sos_switching")
    end
end