if SERVER then
    AddCSLuaFile()
end

MINIGAME.author = "Sirzento"
MINIGAME.contact = "Sirzento | Nico on TTT2 Discord"

if CLIENT then
MINIGAME.lang = {
    name = {
        en = "To the last bullet...",
        de = "Bis zur letzten Patrone..."
    },
    desc = {
        en = "Bullets cost money, after all",
        de = "Patronen kosten nun mal Geld"
    }
}
end


function MINIGAME:OnActivation()
    function AddNoReloadWhenNotEmpty(weapon)
        if not weapon.OldReload then
            weapon.OldReload = weapon.Reload
            weapon.Reload = function(slf, ...)
                if slf:Clip1() == 0 then
                    weapon:OldReload(...)
                end
            end
        end
    end

    function RemoveNoReloadWhenNotEmpty(weapon)
        if weapon.OldReload then
            weapon.Reload = weapon.OldReload
            weapon.OldReload = nil
        end
    end

    function AddNoReloadWhenNotEmptyFromPlayers()
        local plys = player.GetAll()
        for i = 1, #plys do
            local weapon = plys[i]:GetActiveWeapon()
            AddNoReloadWhenNotEmpty(weapon)
        end
    end

    function RemoveNoReloadWhenNotEmptyFromPlayers()
        local plys = player.GetAll()
        for i = 1, #plys do
            local weapon = plys[i]:GetActiveWeapon()
            RemoveNoReloadWhenNotEmpty(weapon)
        end
    end

    AddNoReloadWhenNotEmptyFromPlayers()
    hook.Add("PlayerSwitchWeapon", "MinigameNoReload", function(ply, oldWeap, newWeap)
        RemoveNoReloadWhenNotEmpty(oldWeap)
        AddNoReloadWhenNotEmpty(newWeap)
    end)
end

function MINIGAME:OnDeactivation()
    hook.Remove("PlayerSwitchWeapon", "MinigameNoReload")
    RemoveNoReloadWhenNotEmptyFromPlayers()
end
