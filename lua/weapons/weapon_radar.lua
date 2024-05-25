SWEP.Base                   = "weapon_tttbase"
SWEP.PrintName              = "Player Radar"

if CLIENT then
    SWEP.Author              = "Brokko"
    SWEP.Instructions        = "The Radar is a special weapon that allows the Traitor to track the positions of innocent players."
    SWEP.Slot                = -1

    SWEP.ViewModelFlip       = false
    SWEP.ViewModelFOV        = 60

    SWEP.EquipMenuData = {
        type = "item_weapon",
        desc = "The Radar is a special weapon that allows the Traitor to track the positions of innocent players."
    };

    SWEP.Icon = "vgui/ttt/icon_radar.vtf"
end

SWEP.Kind                  = ROLE
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
SWEP.CanBuy = { ROLE_TRAITOR }
SWEP.LimitedStock = true

-- Settings
local updateCooldown = 30 -- In seconds
local minDistance = 25

local instances = 0
local positions = {}

-- client side var
local owner

function SWEP:Deploy()
    -- Keep track of existing instances
    instances = instances +  1

    -- Inititate timer only if no other instance is already active
    if(instances == 1) then
        timer.Create("UpdatePositions", updateCooldown, 0, OnPositionUpdate)

        -- Initiate first update
        OnPositionUpdate()
    end

    -- Hook is only added on weapon owners client, so the HUD is only updated on his client
    if CLIENT then
        owner = self:GetOwner() 
        if( not owner:IsValid() ) then return end

        if ( not LocalPlayer() == owner ) then return end

        hook.Add("HUDPaint", "DrawPositions", OnUpdateHUD) 
    end
end

function SWEP:OnRemove()
    instances = instances - 1
    if(instances == 0) then
        timer.Remove("UpdatePositions")
    end

    if CLIENT then 
        if ( not owner:IsValid() ) then return end

        if ( not LocalPlayer() == owner ) then return end

        hook.Remove("DrawPositions")
    end
end

function OnPositionUpdate() 
    -- Reallocate table so no old entries or dead players remain
    positions = {}

    local players = player.GetAll()
    for i = 1, #players do
        local ply = players[i]

        -- Dont show the position of the owner
        if (ply == owner) then return end

        -- Dont show position of dead players
        if (not ply:Alive()) then continue end

        -- Check if the GetRole method is available for compatibility with non TTT2 gamemodes
        if (ply.GetRole ~= nil) then
            -- Dont show position of other traitors
            if ply:GetRole() == ROLE_TRAITOR then 
                continue 
            end
        end

        positions[i] = ply:GetPos()
    end
end

function OnUpdateHUD() 
    local ownPos = owner:GetPos()

    for _, pos in ipairs(positions) do
        -- Calculate the distance between the owner and the position, divide by 10, and convert it to an integer
        local distance = math.floor(ownPos:Distance(pos) / 10)

        -- Dont show a mark if the distance is too close
        if distance < minDistance then continue end

        local displayPos = pos:ToScreen()

        draw.RoundedBox(16,  displayPos.x - 18, displayPos.y - 18, 36, 36, Color(0, 0, 0, 112))
        draw.RoundedBox(16,  displayPos.x - 16, displayPos.y - 16, 32, 32, Color(58, 104, 52, 50))
        draw.SimpleText(distance, "Trebuchet18", displayPos.x, displayPos.y, Color(27, 21, 21), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

end