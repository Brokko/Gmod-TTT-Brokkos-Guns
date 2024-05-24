SWEP.Base                  = "weapon_tttbase"
SWEP.PrintName             = "BiniSmash"

if CLIENT then
   SWEP.Author				   = "Brokko"
   SWEP.Instructions		   = "Teleports a previously selected player (or other entity) to another location"
   SWEP.Slot               = 6

   SWEP.ViewModelFlip      = false
   SWEP.ViewModelFOV       = 54
   
   SWEP.EquipMenuData = {
      type = "item_weapon",
      desc = "Fire a massive boucing ball."
   };

   SWEP.Icon = "vgui/ttt/icon_tpgun.png"
end

SWEP.Kind                  = WEAPON_PISTOL
SWEP.WeaponID              = AMMO_PISTOL

SWEP.Primary.Recoil        = 3
SWEP.Primary.Damage        = 1
SWEP.Primary.Delay         = 0.5
SWEP.Primary.Cone          = 0.01
SWEP.Primary.ClipSize      = 1
SWEP.Primary.Automatic     = false
SWEP.Primary.DefaultClip   = 1
SWEP.Primary.ClipMax       = 1
SWEP.Primary.Ammo          = "none"
SWEP.AmmoEnt               = "none"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= false

SWEP.UseHands              = true
SWEP.HoldType              = "pistol"
SWEP.ViewModel			= "models/weapons/v_pistol.mdl"
SWEP.WorldModel			= "models/weapons/w_pistol.mdl"

SWEP.Kind = WEAPON_EQUIP1
SWEP.CanBuy = { ROLE_TRAITOR }
SWEP.LimitedStock = true

function SWEP:PrimaryAttack()

   --if not self:CanPrimaryAttack() then return end

   local owner = self:GetOwner()
   if ( not owner:IsValid() ) then return end

   if ( CLIENT ) then return end

   hook.Add("Think", "SprintHook", function()
      local forward = owner:EyeAngles():Forward() 
      forward.z = 0 
      forward:Normalize()
      local velocity = forward * 20 
      owner:SetLocalVelocity(velocity) 
   end)

   owner:AddCallback( "PhysicsCollide", PhysCallback ) -- Add Callback

end

   function PhysCallback( ent, data ) -- Function that will be called whenever collision happends
      print("MSIJAS")

   end