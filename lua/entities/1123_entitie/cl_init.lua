include("shared.lua")

local timerImage = 0.08
local PlayerPersonnality
local ImageObject

-- Effect on the player's screen of black shading.
local function TransitionHorrorImage(image, ply, saturation)
    timer.Create("transition_horror_image_"..ply:SteamID(),0.5,1,function()
        if !IsValid(ply) then return end
        saturation = saturation - 3
        image:SetImageColor(Color(0, 0, 0, saturation))
        if (saturation > 0) then
            TransitionHorrorImage(image, ply, saturation)
        end
    end)
end

-- Plays a sound to the player according to the defined personality.
local function PlaySoundPersonnality(ply)
    if(PlayerPersonnality == 1) then
        ply:EmitSound("scp_1123/sound_armenian.mp3")
    end
    if(PlayerPersonnality == 2) then
        ply:EmitSound("scp_1123/speech_juden.mp3")
    end
    if(PlayerPersonnality == 3) then
        ply:EmitSound("scp_1123/sound_chinese.mp3")
    end
    if(PlayerPersonnality == 4) then
        ply:EmitSound("scp_1123/sound_rwanda.mp3")
    end
    if(PlayerPersonnality == 5) then
        ply:EmitSound("scp_1123/sound_cambodge.mp3")
    end
end

-- Function that displays several images in a row on the player's screen.
local function ForeachHorrorImage(ImageObject, ply, i, images)
    timer.Create("foreach_horror_image_"..ply:SteamID(),timerImage,1,function()
        if !IsValid(ply) then return end
        ImageObject:SetImage("scp_1123/"..images[i])
        if (i < #images) then
            ForeachHorrorImage(ImageObject, ply, i + 1, images)
        else
            timer.Create("foreach_horror_image_"..ply:SteamID(),timerImage,1,function()
                if !IsValid(ply) then return end
                util.ScreenShake( ply:GetPos(), 20, 20, 10, 40 )
                PlaySoundPersonnality(ply)
                ImageObject:SetImageColor(Color(0, 0, 0, 250))
                TransitionHorrorImage(ImageObject, ply, 250)
            end )
        end
    end )
end

if CLIENT then
    print('yo')
    net.Receive(ImageToPlayerNet, function ( )
        ply = net.ReadEntity()
        ply:EmitSound("scp_1123/use_1123.wav")
        ImageObject = vgui.Create("DImage")
        ImageObject:SetSize(ScrW(), ScrH())

        local images = file.Find("materials/scp_1123/*.jpg", "GAME")
        ForeachHorrorImage(ImageObject, ply, 1, images)
    end)

    net.Receive(PersonnalityNet, function ( )
        PlayerPersonnality = net.ReadInt(4)
    end)

    net.Receive(MusicNearByNet, function ( )
        Check = net.ReadBool()
        print('oui')
        local ply = LocalPlayer()
        if !IsValid(ply) then return end
        if (Check) then
            ply:StartLoopingSound( "scp_1123/screamshorror.mp3" )
        end
    end)

    net.Receive(ResetScreenClientEffect, function ( )
        Check = net.ReadBool()
        local ply = LocalPlayer()
        if !IsValid(ply) then return end
        if (Check) then
            if timer.Exists("foreach_horror_image_"..ply:SteamID()) then
                timer.Remove("foreach_horror_image_"..ply:SteamID())
            end
            if timer.Exists("transition_horror_image_"..ply:SteamID()) then
                timer.Remove("transition_horror_image_"..ply:SteamID())
            end
            if ImageObject then
                ImageObject:SetImageColor(Color(0, 0, 0, 0))
            end
        end
    end)
end

function ENT:Draw()
    self:DrawModel() 
end