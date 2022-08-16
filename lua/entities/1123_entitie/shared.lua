ENT.Type = "anim"
ENT.Base = "base_gmodentity"

ENT.PrintName = "SCP-1123"
ENT.Category = "BIBI entities"
ENT.Author = "BIBI"
ENT.Spawnable = true
ENT.Range = 50
ENT.NextPersonality = math.random(1,5)

local ImageToPlayerNet = "ImageToPlayerNet"
local PersonnalityNet = "PersonnalityNet"
local MusicNearByNet = "MusicNearByNet"
local ResetScreenClientEffect = "ResetScreenClientEffect"
local langUser = GetConVar("gmod_language"):GetString()
cvars.AddChangeCallback("gmod_language", function(name, old, new)
    langUser = new
end)