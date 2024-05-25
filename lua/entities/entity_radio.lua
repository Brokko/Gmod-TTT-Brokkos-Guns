DEFINE_BASECLASS("base_gmodentity")

ENT.PrintName = "Hungry Ball"
ENT.Author = "Brokko"

ENT.Spawnable = false
ENT.AdminOnly = false
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

AddCSLuaFile()

local deathSounds = {
    Sound("vo/npc/male01/pain07.wav"),
    Sound("vo/npc/male01/pain08.wav"),
    Sound("vo/npc/male01/pain09.wav"),
    Sound("vo/npc/male01/pain04.wav"),
    Sound("vo/npc/male01/no02.wav")
}

local gunSounds = {
    Sound("Weapon_Shotgun.Single")
}

function ENT:SetupDataTables()
    -- Set by weapon_thrower_radio, defines the table to use
    self:NetworkVar( "Int", 1, "SoundTable", { KeyName = "SoundTable", Edit = { type = "Int", order = 2 } } )

    -- Set by weapon_thrower_radio, the value is ignored, on change OnSoundPlay() is fired on server side
    self:NetworkVar( "Int", 0, "Play", { KeyName = "play", Edit = { type = "Int", order = 2 } } )

	if ( SERVER ) then
		self:NetworkVarNotify( "Play", function()
            OnSoundPlay(self)
        end) 
	end
end

function ENT:Initialize()
	if ( CLIENT ) then return end

    -- Setup model
    self:SetModel("models/props_lab/citizenradio.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)

    local phys = self:GetPhysicsObject()
    if phys:IsValid() then
        phys:Wake()
    end
end

function OnSoundPlay(ent)
    local tab = ent:GetSoundTable()

    local val
    if tab == 0 then 
        val = deathSounds
    elseif tab == 1 then 
        val = gunSounds
    end

    -- Choose a random entry from table 
    local s = table.Random(val)

    ent:EmitSound(s)
end