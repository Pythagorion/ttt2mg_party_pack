if SERVER then
	AddCSLuaFile()
end

ENT.Type = "anim"
ENT.Base = "base_ammo_ttt"
ENT.AmmoType = "delay_ammo"
ENT.AmmoAmount = 20
ENT.AmmoMax = 60
ENT.AutoSpawnable = false
ENT.spawnType = AMMO_TYPE_PISTOL