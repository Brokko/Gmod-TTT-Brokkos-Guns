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

    SWEP.Icon = "vgui/ttt/icon_thrower_radio.png"
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

SWEP.UseHands	= true
SWEP.ViewModel      = "models/weapons/c_slam.mdl"
SWEP.WorldModel      = "models/weapons/w_slam.mdl"

SWEP.Kind = WEAPON_EQUIP1
SWEP.CanBuy = { ROLE_TRAITOR, ROLE_DETECTIVE}
SWEP.LimitedStock = false

-- Define the cooldown (in seconds) 
local cooldown = 5
-- Number of available sound tables
local tableCount = 2

-- Client-side variable to store the current sound table name
local tableName = "Death"

function SWEP:SetupDataTables()
    self:NetworkVar("Int", 0, "Sound", { KeyName = "sound", Edit = { type = "Int", order = 2 } })
    self:NetworkVar("Entity", 1, "Radio", { KeyName = "entity", Edit = { type = "Bool", order = 1 } })
end

function SWEP:PrimaryAttack()
    -- Check if the weapon is out of ammo
    if (self.Weapon:Clip1() <= 0) then
        self:EmitSound("Weapon_Pistol.Empty")
        self:SetNextPrimaryFire(CurTime() + 0.2)
        return
    end

    if CLIENT then return end

    local owner = self:GetOwner()
    if (not owner:IsValid()) then return end

    -- Create a new radio entity and check if it is valid
    local ent = ents.Create("entity_radio")
    if (not ent:IsValid()) then return end

    local aimvec = owner:GetAimVector()
    local pos = aimvec * 48
    pos:Add(owner:EyePos())

    -- Set entity properties
    ent.SetOwner(self:GetOwner())
    ent:SetPos(pos)
    ent:SetAngles(owner:EyeAngles())
    ent:SetSoundTable(self:GetSound())
    ent:Spawn()

    local phys = ent:GetPhysicsObject()

    -- Remove the entity if the physics object is invalid
    if (not phys:IsValid()) then
        ent:Remove()
        return
    end

    -- Hold a reference to the created entity
    self:SetRadio(ent)

    -- Decrease the primary ammo count
    if self.TakePrimaryAmmo ~= nil then
        self:TakePrimaryAmmo(1)
    else
        self.Weapon:SetClip1(self.Weapon:Clip1() - 1)
    end
end

function SWEP:SecondaryAttack()
    -- Check if the weapon is out of ammo
    if (self.Weapon:Clip1() <= 0) then
        local radio = self:GetRadio()
        radio:SetPlay(radio:GetPlay() + 1)

        self:SetNextSecondaryFire(CurTime() + cooldown)
    else
        -- Increment the sound type counter
        local current = self:GetSound() + 1
        if (current == tableCount) then current = 0 end

        self:SetSound(current)
        self:SetNextSecondaryFire(CurTime() + 0.5)

        -- Since the HUD can only be drawn on the client side, set tableName only on the client side
        if CLIENT or game.SinglePlayer() then
            if current == 0 then
                tableName = "Death"
            elseif current == 1 then
                tableName = "Shoot"
            end
        end
    end
end

if CLIENT then
    function SWEP:DrawHUD()
        local x = ScrW() / 2.0
        local y = ScrH() / 2.0

        -- Text content displaying the current sound type
        local content = "Sound type: " .. tableName
        local width, height = surface.GetTextSize(content)

        -- Position the text in the center of the screen
        surface.SetTextPos(x - (width / 2), ScrH() - height - 100)
        surface.SetTextColor(255, 255, 255, 255)
        surface.DrawText(content)
    end
end
