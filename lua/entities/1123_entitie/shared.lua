ENT.Type = "anim"
ENT.Base = "base_gmodentity"

ENT.PrintName = "SCP-1123"
ENT.Category = "SCP"
ENT.Author = "BIBI"
ENT.Spawnable = true
ENT.Range = 50

local HandledLanguage = {
    "fr",
    "en"
}

-- Name of all net message
ImageToPlayerNet = "ImageToPlayerNet"
PersonnalityNet = "PersonnalityNet"
MusicNearByNet = "MusicNearByNet"
ResetScreenClientEffect = "ResetScreenClientEffect"

-- Get the cirrent language of the user
langUser = GetConVar("gmod_language"):GetString()
cvars.AddChangeCallback("gmod_language", function(name, old, new)
    langUser = new
end)
if (langUser) then
    if !table.HasValue(HandledLanguage, langUser) then
        langUser = "en"
    end
else
    langUser = "en"
end