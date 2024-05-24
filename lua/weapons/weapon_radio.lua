SWEP.Base                   = "weapon_tttbase"
SWEP.PrintName              = "Speaker"

if CLIENT then
    SWEP.Author              = "Brokko"
    SWEP.Instructions        = "Stop da Ball"
    SWEP.Slot                = -1

    SWEP.ViewModelFlip       = false
    SWEP.ViewModelFOV        = 60

    SWEP.EquipMenuData = {
        type = "item_weapon",
        desc = "Stop da Ball"
    };

    SWEP.Icon = "vgui/ttt/icon_armor_ball.png"
end

SWEP.Kind                  = WEAPON_PISTOL
SWEP.WeaponID              = AMMO_PISTOL

SWEP.Primary.Recoil        = 1
SWEP.Primary.Damage        = 1
SWEP.Primary.Cone          = 0.01
SWEP.Secondary.ClipSize      = 1
SWEP.Primary.Automatic     = false
SWEP.Primary.DefaultClip   = 1
SWEP.Primary.ClipMax       = 1
SWEP.Primary.Ammo          = "none"
SWEP.AmmoEnt               = "none"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= false

SWEP.UseHands	= true
SWEP.ViewModel      = "models/weapons/c_slam.mdl"
SWEP.WorldModel      = "models/weapons/w_slam.mdl"

SWEP.Kind = WEAPON_EQUIP1
SWEP.CanBuy = { ROLE_TRAITOR, ROLE_DETECTIVE}
SWEP.LimitedStock = false

local cooldown = 2; 

function SWEP:SetupDataTables()
	self:NetworkVar( "Entity", 0, "Radio", { KeyName = "entity", Edit = { type = "Bool", order = 1 } } )
end

function SWEP:PrimaryAttack()
    local owner = self:GetOwner()
    if ( not owner:IsValid() ) then return end

    if (self:GetRadio() ~= nil) then
        PlaySound(self:GetRadio())

        self:SetNextPrimaryFire(CurTime() + cooldown)
    else
        ChangeSound()

        self:SetNextPrimaryFire(CurTime() + 0.2)
    end
end

function ChangeSound()
    
end

function PlaySound(radio)
    radio:SetPlay(radio:GetPlay() + 1)
end

function SWEP:SecondaryAttack()
    local owner = self:GetOwner()
    if ( not owner:IsValid() ) then return end

	-- Create a new radio entity and check if its valid
	local ent = ents.Create("entity_radio")   
	if (not ent:IsValid()) then return end

	-- Calculate position based on aim vector and player's eye position
	local aimvec = owner:GetAimVector()
	local pos = aimvec * 48
	pos:Add(owner:EyePos()) 

	-- Set entity properties
	ent.SetOwner(self:GetOwner())
	ent:SetPos(pos)
	ent:SetAngles(owner:EyeAngles())
	ent:Spawn()

	local phys = ent:GetPhysicsObject()

	-- Remove entity if physics object is invalid
	if (not phys:IsValid()) then 
		ent:Remove() 
		return 
	end
    
    self:SetRadio(ent)

   -- self:TakeSecondaryAmmo(1)
end