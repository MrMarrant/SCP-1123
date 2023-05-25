-- SCP-1123, A representation of a paranormal object on a fictional series on the game Garry's Mod.
-- Copyright (C) 2023  MrMarrant aka BIBI.

-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.

-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.

-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <https://www.gnu.org/licenses/>.

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