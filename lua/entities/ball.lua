/*
 * Edited version of gmod bouncing balls 
 */

AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )

ENT.PrintName = "Hungry Ball"
ENT.Author = "Brokko"

ENT.Spawnable = false
ENT.AdminOnly = false
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

ENT.SpawnSize = 50
ENT.BouncingBoost = 20

function ENT:SetupDataTables()

	self:NetworkVar( "Float", 0, "BallSize", { KeyName = "ballsize", Edit = { type = "Float", order = 1 } } )
	self:NetworkVar( "Vector", 0, "BallColor", { KeyName = "ballcolor", Edit = { type = "VectorColor", order = 2 } } )

	if ( SERVER ) then
		self:NetworkVarNotify( "BallSize", self.OnBallSizeChanged )
	end

end

function ENT:Initialize()

	-- We do NOT want to execute anything below in this FUNCTION on CLIENT
	if ( CLIENT ) then return end

	-- Use the helibomb model just for the shadow (because it's about the same size)
	self:SetModel( "models/Combine_Helicopter/helicopter_bomb01.mdl" )

	-- We will put this here just in case, even though it should be called from OnBallSizeChanged in any case
	self:SetBallSize( self.SpawnSize )
	self:RebuildPhysics( self:GetBallSize() )

	self:GetPhysicsObject():SetBuoyancyRatio( 1.75 )

	-- Select a random color for the ball
	self:SetBallColor( table.Random( {
		Vector( 1, 0.3, 0.3 ),
		Vector( 0.3, 1, 0.3 ),
		Vector( 1, 1, 0.3 ),
		Vector( 0.2, 0.3, 1 ),
	} ) )

end

function ENT:RebuildPhysics( value )
	-- This is necessary so that the vphysics.dll will not crash when attaching constraints to the new PhysObj after old one was destroyed
	-- TODO: Somehow figure out why it happens and/or move this code/fix to the constraint library
	self.ConstraintSystem = nil

	local size = math.floor( value / 2.1 )
	self:PhysicsInitSphere( size, "metal_bouncy" )
	self:SetCollisionBounds( Vector( -size, -size, -size ), Vector( size, size, size ) ) 

	self:PhysWake()
end

if ( SERVER ) then
	function ENT:OnBallSizeChanged( varname, oldvalue, newvalue )

		-- Do not rebuild if the size wasn't changed
		if ( oldvalue == newvalue ) then return end

		self:RebuildPhysics( newvalue )

	end
end

local BounceSound = Sound( "garrysmod/balloon_pop_cute.wav" )

function ENT:PhysicsCollide( data, physobj )

	-- Play sound on bounce
	local pitch = 32 + 128 - self:GetBallSize()
	sound.Play( BounceSound, self:GetPos(), 75, 180, math.Clamp( data.Speed / 150, 0, 1 ) )

	-- Bounce like a crazy bitch
	local LastSpeed = math.max( data.OurOldVelocity:Length(), data.Speed ) 
	local NewVelocity = physobj:GetVelocity()
	NewVelocity:Normalize() 

	local TargetVelocity = NewVelocity * ( math.max( NewVelocity:Length(), LastSpeed ) + self.BouncingBoost ) 

	physobj:SetVelocity( TargetVelocity )

	local entity = data.HitEntity 
	if(entity.GetBallProtected) then
		if(entity:GetBallProtected()) then 
			return
		end
	end

	if (entity:IsNPC() or entity:IsPlayer()) then
		local d = DamageInfo()
		d:SetDamage( math.min( entity:Health(), LastSpeed / 10 ))
		d:SetAttacker( physobj:GetEntity() )
		d:SetDamageType( DMG_CRUSH ) 

		entity:TakeDamageInfo(d)

		--self:SetBallSize( self:GetBallSize() * 1.25 ) 
	end
end

function ENT:OnTakeDamage( dmginfo )
	-- React physically when shot/getting blown
	dmginfo:AddDamage(5000)
	self:TakePhysicsDamage( dmginfo )

end

if ( SERVER ) then return end -- We do NOT want to execute anything below in this FILE on SERVER

local matBall = Material( "sprites/sent_ball" )

function ENT:Draw()

	render.SetMaterial( matBall )

	local pos = self:GetPos()
	local lcolor = render.ComputeLighting( pos, Vector( 0, 0, 1 ) )
	local c = self:GetBallColor()

	lcolor.x = c.r * ( math.Clamp( lcolor.x, 0, 1 ) + 0.5 ) * 255
	lcolor.y = c.g * ( math.Clamp( lcolor.y, 0, 1 ) + 0.5 ) * 255
	lcolor.z = c.b * ( math.Clamp( lcolor.z, 0, 1 ) + 0.5 ) * 255

	local size = self:GetBallSize()
	render.DrawSprite( pos, size, size, Color( lcolor.x, lcolor.y, lcolor.z, 255 ) )
end

