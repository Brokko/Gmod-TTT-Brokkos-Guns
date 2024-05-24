SWEP.Base 					= "weapon_tttbase"
SWEP.PrintName          	= "Ball Thrower"

if CLIENT then
   SWEP.Author				= "Brokko"
   SWEP.Instructions		= "Throw da ball"
   SWEP.Slot               = 6

   SWEP.ViewModelFlip      = false
   SWEP.ViewModelFOV       = 54
   
   SWEP.EquipMenuData = {
      type = "item_weapon",
      desc = "Fire a massive boucing ball."
   };

   SWEP.Icon = "vgui/ttt/icon_throwerblue.png"
end

SWEP.Kind                  = WEAPON_PISTOL
SWEP.WeaponID              = AMMO_PISTOL

SWEP.Primary.Recoil        = 3
SWEP.Primary.Damage        = 1
SWEP.Primary.Delay         = 0.5
SWEP.Primary.Cone          = 0.01
SWEP.Primary.ClipSize      = 3
SWEP.Primary.Automatic     = false
SWEP.Primary.DefaultClip   = 3
SWEP.Primary.ClipMax       = 3
SWEP.Primary.Ammo          = "none"
SWEP.AmmoEnt               = "none"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= false

SWEP.UseHands              = true
SWEP.HoldType              = "pistol"
SWEP.ViewModel			= "models/weapons/v_pistol.mdl"
SWEP.WorldModel			= "models/weapons/w_pistol.mdl"

SWEP.Kind = WEAPON_EQUIP1
SWEP.CanBuy = {ROLE_TRAITOR}
SWEP.LimitedStock = true

function SWEP:PrimaryAttack()
	-- Check if weapon is out of ammo
	if (self.Weapon:Clip1() <= 0) then
		self:EmitSound("Weapon_Pistol.Empty")
		self:SetNextPrimaryFire(CurTime() + 0.2)
		self:Reload()
		return false
	end

	if (CLIENT) then return end

	local owner = self:GetOwner()
	if (not owner:IsValid()) then return end

	-- Create a new ball entity and check if its valid
	local ent = ents.Create("ball")   
	if (not ent:IsValid()) then return end

	-- Calculate ball position based on aim vector and player's eye position
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

	-- Apply force to the ball's physics object
	aimvec:Mul(100000)
	phys:ApplyForceCenter(aimvec)

	-- Check if active gamemode is "sandbox" and allow unlimited ammo if 
	if (engine.ActiveGamemode() == "sandbox") then
		undo.Create("Thrown_ball")
		undo.AddEntity(ent)
		undo.SetPlayer(owner)
		undo.Finish()	
	elseif SERVER then
		-- TakePrimaryAmmo does not work every time for some reason
		if self.TakePrimaryAmmo ~= nil then
			self:TakePrimaryAmmo( 1 )
		else 
			self.Weapon:SetClip1( self.Weapon:Clip1() - 1 )	
		end
	end
end

function SWEP:SecondaryAttack()
	self:PrimaryAttack()
end