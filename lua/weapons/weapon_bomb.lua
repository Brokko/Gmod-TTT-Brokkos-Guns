SWEP.Base                   = "weapon_tttbase"
SWEP.PrintName              = "Suicide bomb"

if CLIENT then
    SWEP.Author              = "Brokko"
    SWEP.Instructions        = "Stop da Ball"
    SWEP.Slot                = -1

    SWEP.ViewModelFlip       = false
    SWEP.ViewModelFOV        = 60

    SWEP.EquipMenuData = {
        type = "item_weapon",
        desc = "They lump? No problem (I know the name doesn't suggest it, but you're immune...)"
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

-- Definiere den Radius der Explosion (in Units)
local explosionRadius = 300 
-- Definiere die Stärke der Explosion (Schaden)
local explosionDamage = 100 

local running = false; 

function SWEP:PrimaryAttack()
    if (running) then return end

    running = true

    local owner = self:GetOwner()
    if ( not owner:IsValid() ) then return end

    sound.Play("weapons/suicide_bomb/monkelonte.wav", owner:GetPos(), 80, 100, 1, 0)

    timer.Simple(2, function()
        hook.Add("EntityTakeDamage", owner:GetName() .. "ExplosionProtection", onExplosionDmg)

        local explosionPos = owner:GetPos()

        -- Löse die Explosion aus
        util.BlastDamage(owner, owner, explosionPos, explosionRadius, explosionDamage)
        sound.Play("weapons/suicide_bomb/explosion.wav", explosionPos, 80, 100, 1, 0)

        -- Definiere den Effekt
        local effectData = EffectData()
        effectData:SetOrigin(explosionPos)
        effectData:SetScale(explosionRadius)

        -- Erzeuge den Explosions-Effekt
        util.Effect("Explosion", effectData)
    
        -- Remove the hook
        hook.Remove( "EntityTakeDamage", owner:GetName() .. "ExplosionProtection" )
    
        -- Single use item
        self:Remove()    
        
        running = false
    end )
end

function onExplosionDmg(target, dmgInfo)
    -- Überprüfe, ob die Entität immun gegen Explosionschaden ist
    if target:IsPlayer() then
        if target == dmgInfo:GetAttacker() then
            -- Entität ist immun gegen Explosionschaden
            return true
        end
    end
end