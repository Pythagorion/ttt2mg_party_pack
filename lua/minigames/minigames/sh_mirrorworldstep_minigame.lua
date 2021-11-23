if SERVER then
    AddCSLuaFile()
end

MINIGAME.author = "Sirzento"
MINIGAME.contact = "Sirzento | Nico on TTT2 Discord"
  
if CLIENT then
    MINIGAME.lang = {
        name = {
            en = "Mirror World: Step",
            de = "Gespiegelte Welt: Laufen"
        },
        desc = {
            en = "Am I drunk?",
            de = "Bin ich Betrunken?"
        }
    }
end
  

function MINIGAME:OnActivation()
    hook.Add("StartCommand", "MinigameMirrorWorldStep", function(ply, cmd)

        local forward = 0
        local right = 0
        local maxspeed = ply:GetMaxSpeed()

        if cmd:KeyDown(IN_FORWARD) then
            forward = forward + maxspeed
        end

        if cmd:KeyDown(IN_BACK) then
            forward = forward - maxspeed
        end

        if cmd:KeyDown(IN_MOVERIGHT) then
            right = right + maxspeed
        end

        if cmd:KeyDown(IN_MOVELEFT) then
            right = right - maxspeed
        end

        cmd:SetForwardMove(-forward)
        cmd:SetSideMove(-right)
    end)
end

function MINIGAME:OnDeactivation()
    hook.Remove("StartCommand", "MinigameMirrorWorldStep")
end

