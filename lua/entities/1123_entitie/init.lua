AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

local TextPersonality = {
	["fr"] = {
		"Vous êtes un Arménien de 1915, vous parlez l'arménien à présent. Vous avez été bruler par les soldats de l'Empire Ottoman. Vous devez être craintif et terrorisé face aux membres du personnels.",
		"Vous êtes une Polonaise juive ayant vécu en 1942, vous avez été gazé dans les chambres à gaz en allemagne nazi, vous entrez dans un état de dépression et de désespoir.",
		"Vous êtes un Chinois des années 1960, vous parlez chinois à présent. Vous avez subi une des grandes famines dues au 'Grand bond en Avant',vous vous recroquevillez sur vous-même, vous avez des difficultés à communiquer.",
		"Vous êtes un Rwandais des années 1990, vous parlez le rwandais à présent. Vous avez été tuez à la machette, vous entendez une radio appelant à faire tomber les grands arbre, vous sentez vos membres se faire découper.",
		"Vous êtes un Cambodgien des années 1970, vous parlez le cambodgien à présent. Vous êtes morts en prison, la famine et la maladie vous entouraient. vous criez, vous êtes terrorisé."
	},
	["en"] = {
		"You are an Armenian from 1915, you speak Armenian now. You were burned by the soldiers of the Ottoman Empire. You must be fearful and terrified of the staff",
		"You are a Polish Jew who lived in 1942, you were gassed in the gas chambers in Nazi Germany, you are entering a state of depression and despair.",
		"You are a Chinese person from the 1960s, you speak Chinese now. You have suffered one of the great famines due to the 'Great Leap Forward', you curl up, you have difficulty communicating.",
		"You are a Rwandan from the 1990s, you speak Rwandan now. You have been killed with a machete, you hear a radio calling for the fall of tall trees, you feel your limbs being cut off",
		"You are a Cambodian from the 1970s, you speak Cambodian now. You died in prison, famine and disease surrounded you. you scream, you are terrorized."
	}
}

local TextSmell = {
	["fr"] = {
		"Il y a une odeur de viande brulée dans l'air.",
		"Vous sentez une fumée qui vous irrite les yeux.",
		"Il y a une odeur de métaux brulés dans l'air.",
		"Il y a une odeur de viande avariée et pourrie dans l'air.",
		"Il y a une odeur de putréfaction et de mort dans l'air."
	},
	["en"] = {
		"There is a smell of burning meat in the air.",
		"You smell smoke that irritates your eyes.",
		"There is a smell of burnt metal in the air.",
		"There is a smell of rotten meat in the air.",
		"There is a smell of rotting and death in the air."
	}
}

local TextFarFrom = {
	["fr"] = {
		"Vous ne voyez plus l'inscription sur le crâne et les évènements ésotériques se sont tu."
	},
	["en"] = {
		"You no longer see the inscription on the skull and the esoteric events have fallen silent."
	}
}

local TextOldPersonality = {
	["fr"] = {
		" commence à retrouver ses esprits et ses anciens souvenir tout en gardant sa nouvelle personnalité et ses souvenirs en même temps."
	},
	["en"] = {
		" begins to regain her mind and her old memories while keeping her new personality and her memories at the same time."
	}
}

local TextNearBy = {
	["fr"] = {
		" entend des cris et des bruits indescriptibles, des odeurs se mélangent, le souffre, les cendres, et le brulé."
	},
	["en"] = {
		" hears screams and indescribable noises, smells are mixed, sulfur, ashes, and burnt."
	}
}

local TextOnUse = {
	["fr"] = {
		"Vous oubliez tout de votre ancienne personnalité, vos souvenirs ainsi que votre langue."
	},
	["en"] = {
		"You forget everything about your old personality, your memories and your language."
	}
}

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
	net.Start(MusicNearByNet)
	net.WriteBool(true)
	net.Send(victim)
end

-- To display the scrolling images on the client side.
local function HorrorImage(victim)
	net.Start(ImageToPlayerNet)
	net.WriteBool(true)
	net.Send(victim)
end

-- To remove all the effects on the client side.
local function SendResetScreenClientEffect(victim)
	net.Start(ResetScreenClientEffect)
	net.WriteBool(true)
	net.Send(victim)
end

-- Checks if a player is close to the entity, if it moves away, mutes it and displays a message.
function ENT:NearBy1123(victim)
	timer.Create("near_by_1123_"..victim:SteamID(),( 1 / 100 ),1,function()
		if !IsValid(victim) then return end
		if !IsValid(self) then return end
		if (self:CheckDistance(victim)) then
			self:NearBy1123(victim)
		else
			victim:StopSound( "scp_1123/screamshorror.mp3" )
			victim.NearBy_1123 = false
			if (!victim.PersonnalityAcquired) then
				victim:PrintMessage(HUD_PRINTTALK, TextFarFrom[langUser][1])
			end
		end
	end)
end

-- Timer to show the player after a certain time that he has recovered the memory.
function ENT:RememberOldPersonality(victim)
	timer.Create("new_personality_"..victim:SteamID(),math.random(180,360),1,function()
		if !IsValid(victim) then return end
		victim:Say("/me"..TextOldPersonality[langUser][1])
	end)
end

-- Return true if the player is close from the entitie.
function ENT:CheckDistance(ply)
	local tracePly = ply:GetPos()
	local entsSpherePly = ents.FindInSphere(tracePly, self.Range + 10)
	for k,v in pairs(entsSpherePly) do
		if v == self then
			return true
		end
	end
	return false
end

function ENT:Initialize()
	self:SetModel( "models/scp_1123/scp_1123_real.mdl" )
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
		if !IsValid(self) then return end
		for k,v in pairs(ents.FindInSphere(self:GetPos(), self.Range)) do
			if v:IsPlayer() and v:Alive() then
				if timer.Exists("new_personality_"..v:SteamID()) then return end
				if (v.NearBy_1123) then return end
				if (v.PersonnalityAcquired) then return end
				v:Say("/me"..TextNearBy[langUser][1])
				v:PrintMessage(HUD_PRINTTALK, TextSmell[langUser][self.NextPersonality])
				v.NearBy_1123 = true
				SendMusicNearBy(v)
				self:NearBy1123(v)
			end
		end
	end)
end

-- When you touch the entity, it affects the player's personality and activates different effects.
function ENT:Use( ply )
	if timer.Exists("new_personality_"..ply:SteamID()) then return end
	if (ply.PersonnalityAcquired) then return end
	ply:PrintMessage(HUD_PRINTTALK, TextOnUse[langUser][1])
	ply:PrintMessage(HUD_PRINTTALK, TextPersonality[langUser][self.NextPersonality])
	ply.PersonnalityAcquired = self.NextPersonality
	ply:StopSound( "scp_1123/screamshorror.mp3" )
	SendPersonnalityAcquired(ply)
	HorrorImage(ply)
	self:RememberOldPersonality(ply)
	self.NextPersonality = math.random(1,5)
end

function ENT:OnRemove()
	if timer.Exists("check_distance_scp1123") then
		timer.Remove("check_distance_scp1123")
	end
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