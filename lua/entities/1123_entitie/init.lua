AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

local Personality = {
	"Vous êtes un Arménien de 1915, vous parlez l'arménien à présent. Vous avez été bruler par les soldats de l'Empire Ottoman. Vous devez être craintif et terrorisé face aux membres du personnels.",
	"Vous êtes une Polonaise juive ayant vécu en 1942, vous avez été gazé dans les chambres à gaz en allemagne nazi, vous entrez dans un état de dépression et de désespoir.",
	"Vous êtes un Chinois des années 1960, vous parlez chinois à présent. Vous avez subi une des grandes famines dues au 'Grand bond en Avant',vous vous recroquevillez sur vous-même, vous avez des difficultés à communiquer.",
	"Vous êtes un Rwandais des années 1990, vous parlez le rwandais à présent. Vous avez été tuez à la machette, vous entendez une radio appelant à faire tomber les grands arbre, vous sentez vos membres se faire découper.",
	"Vous êtes un Cambodgien des années 1970, vous parlez le cambodgien à présent. Vous êtes morts en prison, la famine et la maladie vous entouraient. vous criez, vous êtes terrorisé."
}

local Smell = {
	"Il y a une odeur de viande brulée dans l'air.",
	"Vous sentez une fumée qui vous irrite les yeux.",
	"Il y a une odeur de métaux brulés dans l'air.",
	"Il y a une odeur de viande avariée et pourrie dans l'air.",
	"Il y a une odeur de putréfaction et de mort dans l'air."
}

local ImageToPlayerNet = "ImageToPlayerNet"
local PersonnalityNet = "PersonnalityNet"
local MusicNearByNet = "MusicNearByNet"
local ResetScreenClientEffect = "ResetScreenClientEffect"

if (SERVER) then
	util.AddNetworkString( ImageToPlayerNet )
	util.AddNetworkString( PersonnalityNet )
	util.AddNetworkString( MusicNearByNet )
	util.AddNetworkString( ResetScreenClientEffect )
end

-- To send what personality is assigned to the player.
local function SendPersonnalityAcquired(victim)
	net.Start(PersonnalityNet)
	net.WriteInt(victim.PersonnalityAcquired, 4)
	net.Send(victim)
end

-- To play the music when you are close to the client-side entity.
local function SendMusicNearBy(victim)
	print(victim)
	net.Start(MusicNearByNet)
	net.WriteBool(true)
	net.Send(victim)
end

-- To display the scrolling images on the client side.
local function HorrorImage(victim)
	net.Start(ImageToPlayerNet)
	net.WriteEntity(victim)
	net.Send(victim)
end

-- To remove all the effects on the client side.
local function SendResetScreenClientEffect(victim)
	net.Start(ResetScreenClientEffect)
	net.WriteBool(true)
	net.Send(victim)
end

-- Checks if a player is close to the entity, if it moves away, mutes it and displays a message.
local function NearBy1123(victim, ent)
	timer.Create("near_by_1123_"..victim:SteamID(),( 1 / 100 ),1,function()
		if !IsValid(victim) then return end
		if (ent:CheckDistance(victim, ent, ent.Range + 10)) then
			NearBy1123(victim, ent)
		else
			victim:StopSound( "scp_1123/screamshorror.mp3" )
			victim.NearBy_1123 = false
			if (!victim.PersonnalityAcquired) then
				victim:PrintMessage(HUD_PRINTTALK, "Vous ne voyez plus l'inscription sur le crâne et les évènements ésotériques se sont tu.")
			end
		end
	end)
end

-- Timer to show the player after a certain time that he has recovered the memory.
local function RememberOldPersonality(victim)
	timer.Create("new_personality_"..victim:SteamID(),math.random(180,360),1,function()
		if !IsValid(victim) then return end
		victim:Say("/me commence à retrouver ses esprits et ses anciens souvenir tout en gardant sa nouvelle personnalité et ses souvenirs en même temps.")
	end)
end

-- Return true if the player is close from the entitie.
function ENT:CheckDistance(ply, ent, distance)
	local tracePly = ply:GetPos()
	local entsSpherePly = ents.FindInSphere(tracePly, distance)
	for k,v in pairs(entsSpherePly) do
		if v == ent then
			return true
		end
	end
	return false
end


function ENT:Initialize()
	self:SetModel( "models/scp_1123/scp1123.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS ) 
	self:SetMoveType( MOVETYPE_VPHYSICS ) 
	self:SetSolid( SOLID_VPHYSICS ) 
	self:SetUseType( SIMPLE_USE )
	self.NextPersonality = math.random(1,5)
	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end
	
	-- Check if a player is close to the entity to play a sound and display a message about the next personality.
	timer.Create("check_distance_scp1123", 1, 0, function ()
		for k,v in pairs(ents.FindInSphere(self:GetPos(), self.Range)) do
			if v:IsPlayer() and v:Alive() then
				if timer.Exists("new_personality_"..v:SteamID()) then return end
				if (v.NearBy_1123) then return end
				if (v.PersonnalityAcquired) then return end
				v:Say("/me entend des cris et des bruits indescriptibles, des odeurs se mélangent, le souffre, les cendres, et le brulé.")
				v:Say("/me voit apparaitre une inscription sur le crâne à mesure qu'il s'en approche.")
				v:PrintMessage(HUD_PRINTTALK, Smell[self.NextPersonality])
				v.NearBy_1123 = true
				SendMusicNearBy(v)
				NearBy1123(v, self)
			end
		end
	end)
end

-- When you touch the entity, it affects the player's personality and activates different effects.
function ENT:Use( ply )
	if timer.Exists("new_personality_"..ply:SteamID()) then return end
	if (ply.PersonnalityAcquired) then return end
	ply:Say("/me entre dans un état de fugue dissociative.")
	ply:PrintMessage(HUD_PRINTTALK, "Vous oubliez tout de votre ancienne personnalité, vos souvenirs ainsi que votre langue.")
	ply:PrintMessage(HUD_PRINTTALK, Personality[self.NextPersonality])
	ply.PersonnalityAcquired = self.NextPersonality
	ply:StopSound( "scp_1123/screamshorror.mp3" )
	SendPersonnalityAcquired(ply)
	HorrorImage(ply)
	RememberOldPersonality(ply)
	self.NextPersonality = math.random(1,5)
end

	-- Function called to remove all effect on death or changed team
	function RemoveEffect1123(victim)
		if timer.Exists("new_personality_"..victim:SteamID()) then
			timer.Remove("new_personality_"..victim:SteamID())
		end
		if timer.Exists("near_by_1123_"..victim:SteamID()) then
			timer.Remove("near_by_1123_"..victim:SteamID())
		end
		victim:StopSound( "scp_1123/speech_juden.mp3" )
		victim:StopSound( "scp_1123/sound_rwanda.mp3" )
		victim:StopSound( "scp_1123/sound_armenian.mp3" )
		victim:StopSound( "scp_1123/sound_chinese.mp3" )
		victim:StopSound( "scp_1123/sound_cambodge.mp3" )
		victim:StopSound( "scp_1123/screamshorror.mp3" )
		victim.PersonnalityAcquired = false
		victim.NearBy_1123 = false
		SendResetScreenClientEffect(victim)
	end

hook.Add( "PlayerDeath", "remove_effect_1123", RemoveEffect1123 )
hook.Add( "PlayerChangedTeam", "PlayerChangedTeam_remove_effect_1123", RemoveEffect1123 )