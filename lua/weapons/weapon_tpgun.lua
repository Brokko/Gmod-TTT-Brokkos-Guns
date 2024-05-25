SWEP.Base                  = "weapon_tttbase"
SWEP.PrintName             = "TP Gun"

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

SWEP.UseHands           = true
SWEP.HoldType           = "pistol"
SWEP.ViewModel          = "models/weapons/v_pistol.mdl"
SWEP.WorldModel			= "models/weapons/w_pistol.mdl"

SWEP.Kind = WEAPON_EQUIP1
SWEP.CanBuy = { ROLE_TRAITOR }
SWEP.LimitedStock = true

function SWEP:SetupDataTables()

	self:NetworkVar( "Entity", 0, "PointedTarget", { KeyName = "target", Edit = { type = "Entity", order = 1 } } )
   self:NetworkVar( "Bool", 0, "Ironsights", { KeyName = "Ironsights", Edit = { type = "Bool", order = 1 } } )
end

function SWEP:PrimaryAttack()
	if ( self.Weapon:Clip1() <= 0 ) then
		self:EmitSound( "Weapon_Pistol.Empty" )
		self:SetNextPrimaryFire( CurTime() + 0.2 )
		return 
	end

   local owner = self:GetOwner()
   if ( not owner:IsValid() ) then return end

   if ( CLIENT ) then return end

   local bullet = {}
   bullet.Num    = num
   bullet.Src    = self.Owner:GetShootPos()
   bullet.Dir    = self.Owner:GetAimVector()
   bullet.Spread = Vector( cone, cone, 0 )
   bullet.Tracer = 1
   bullet.Force	= 1
   bullet.Damage = 0
   bullet.TracerName = "PhyscannonImpact"

   bullet.Callback = function( att, tr )
      local target = self:GetPointedTarget() 
      if ( not target:IsValid() ) then 
         self:SetPointedTarget( tr.Entity )
   
      else 
         // We need to reposition the entity, else it'll be stuck in a wall
         target:SetPos( tr.HitPos + (0.10 * (tr.StartPos - tr.HitPos)) )
         target:PhysWake()

         if CLIENT then 
            return
         end

         if self.TakePrimaryAmmo ~= nil then
            self:TakePrimaryAmmo( 1 )
         else 
            self.Weapon:SetClip1( self.Weapon:Clip1() - 1 )	
         end
      end
   end

   self.Owner:FireBullets( bullet )
end

function SWEP:SecondaryAttack()
   bIronsights = not self:GetIronsights()

   self:SetIronsights( bIronsights )

   if SERVER then
      self:SetZoom( bIronsights )
   end

   self.Weapon:SetNextSecondaryFire(CurTime() + 0.5)
end

function SWEP:SetZoom( state )
   local owner = self.Owner;
   if CLIENT then 
      return

   elseif owner:IsValid() and owner:IsPlayer() then
      if state then
         owner:SetFOV( 20, 0.3 )
      else
         owner:SetFOV( 0, 0.2 )
      end
   end
end

if CLIENT then
   function SWEP:DrawHUD()
      local x = ScrW() / 2.0
      local y = ScrH() / 2.0

      // Target name
      local name = "none"
      local target = self:GetPointedTarget()
      if( target:IsValid() ) then
         if( target:IsPlayer() ) then
            name = target:GetName()
         else
            name = "Object"
         end
      end

      local content = "Current target: " .. name 
      local width, height = surface.GetTextSize( content )
      surface.SetTextPos( x - ( width / 2), ScrH() - height - 100 )
      surface.SetTextColor( 255, 255, 255, 255 )
      surface.DrawText( content )

      if self:GetIronsights() then
         surface.SetDrawColor( 0, 0, 0, 255 )

         local x = ScrW() / 2.0
         local y = ScrH() / 2.0
         local scope_size = ScrH()

         -- Crosshair
         local gap = 80
         local length = scope_size
         surface.DrawLine( x - length, y, x - gap, y )
         surface.DrawLine( x + length, y, x + gap, y )
         surface.DrawLine( x, y - length, x, y - gap )
         surface.DrawLine( x, y + length, x, y + gap )

         gap = 0
         length = 50
         surface.DrawLine( x - length, y, x - gap, y )
         surface.DrawLine( x + length, y, x + gap, y )
         surface.DrawLine( x, y - length, x, y - gap )
         surface.DrawLine( x, y + length, x, y + gap )

         -- Cover edges
         local sh = scope_size / 2
         local w = ( x - sh ) + 2
         surface.DrawRect( 0, 0, w, scope_size )
         surface.DrawRect( x + sh - 2, 0, w, scope_size )

         surface.SetDrawColor( 255, 0, 0, 255 )
         surface.DrawLine( x, y, x + 1, y + 1 )


      end
     

   end
end

function SWEP:AdjustMouseSensitivity()
   return ( self:GetIronsights() and 0.2 ) or nil
end
