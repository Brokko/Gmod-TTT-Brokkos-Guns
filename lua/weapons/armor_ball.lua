SWEP.Base                   = "weapon_tttbase"
SWEP.PrintName              = "Ball Armor"

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

SWEP.UseHands	= true
SWEP.ViewModel      = "models/weapons/c_slam.mdl"
SWEP.WorldModel      = "models/weapons/w_slam.mdl"

SWEP.Kind = WEAPON_EQUIP1
SWEP.CanBuy = { ROLE_TRAITOR, ROLE_DETECTIVE}
SWEP.LimitedStock = false

function SWEP:PrimaryAttack()
    local owner = self:GetOwner()
    if ( not owner:IsValid() ) then return end

    -- At a var to player specific object. Will be used by weapon_thrower on PrimaryAttack
    owner:NetworkVar("Bool", 0, "BallProtected", { KeyName = "ballProtected", Edit = { type = "Bool", order = false } })
    owner:SetBallProtected(true)

    -- Single use item
    self:Remove()
end