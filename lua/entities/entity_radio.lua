DEFINE_BASECLASS("base_gmodentity")

ENT.PrintName = "Hungry Ball"
ENT.Author = "Brokko"

ENT.Spawnable = false
ENT.AdminOnly = false
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

AddCSLuaFile()

function ENT:SetupDataTables()
    self:NetworkVar( "Int", 0, "Sound", { KeyName = "sound", Edit = { type = "Int", order = 2 } } )
    self:NetworkVar( "Int", 0, "Play", { KeyName = "play", Edit = { type = "Int", order = 2 } } )

	if ( SERVER ) then
		self:NetworkVarNotify( "Play", function()
            OnSoundPlay(self)
        end) 
	end
end

function ENT:Initialize()
	-- We do NOT want to execute anything below in this FUNCTION on CLIENT
	if ( CLIENT ) then return end

    -- 
    self:SetModel("models/props_lab/citizenradio.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)

    local phys = self:GetPhysicsObject()
    if phys:IsValid() then
        phys:Wake()
    end    

    -- Setze einen Standardwert für die NetworkVar
    self:SetPlay(0)
end

function OnSoundPlay(ent)
    -- Liste der möglichen Sterbesounds
    local deathSounds = {
        "vo/npc/male01/pain07.wav",
        "vo/npc/male01/death1.wav",
        "vo/npc/male01/death2.wav",
        "vo/npc/male01/death3.wav",
        "vo/npc/male01/death4.wav"
    }
        
    -- Wähle einen zufälligen Sound aus der Liste
    local randomSound = table.Random(deathSounds)

    ent:EmitSound(randomSound)
end