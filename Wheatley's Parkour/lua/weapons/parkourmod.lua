--[[ Apache License --
	Copyright 2015 Wheatley
	 
	Licensed under the Apache License, Version 2.0 (the 'License'); you may not use this file except
	in compliance with the License. You may obtain a copy of the License at
	 
	http://www.apache.org/licenses/LICENSE-2.0
	 
	Unless required by applicable law or agreed to in writing, software distributed under the License
	is distributed on an 'AS IS' BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express
	or implied. See the License for the specific language governing permissions and limitations under
	the License.
	 
	The right to upload this project to the Steam Workshop (which is operated by Valve Corporation)
	is reserved by the original copyright holder, regardless of any modifications made to the code,
	resources or related content. The original copyright holder is not affiliated with Valve Corporation
	in any way, nor claims to be so.
]]

AddCSLuaFile()

if CLIENT then
	pm_drawkeys = CreateClientConVar( 'pm_drawkeys', '1', true )
	pm_drawadvice = CreateClientConVar( 'pm_drawadvice', '1', true )
	pm_drawadrenaline = CreateClientConVar( 'pm_drawadrenaline', '1', true )
	pm_drawhud = CreateClientConVar( 'pm_drawhud', '1', true )
	pm_disableadrenalinepp = CreateClientConVar( 'pm_disableadrenalinepp', '0', true )
	pm_disablemotionpp = CreateClientConVar( 'pm_disablemotionpp', '0', true )
	
	pm_hudpos = CreateClientConVar( 'pm_hudpos', '0', true )
end

pm_sv_disableadr = CreateConVar( 'pm_sv_disableadr', '0', { FCVAR_REPLICATED, FCVAR_ARCHIVE } )
pm_sv_disablehud = CreateConVar( 'pm_sv_disablehud', '0', { FCVAR_REPLICATED, FCVAR_ARCHIVE } )
pm_sv_disableturn = CreateConVar( 'pm_sv_disableturn', '0', { FCVAR_REPLICATED, FCVAR_ARCHIVE } )
pm_sv_maxspeed = CreateConVar( 'pm_sv_maxspeed', '500', { FCVAR_REPLICATED, FCVAR_ARCHIVE } )
pm_sv_maxjump = CreateConVar( 'pm_sv_maxjump', '650', { FCVAR_REPLICATED, FCVAR_ARCHIVE } )
pm_sv_maxastabdist = CreateConVar( 'pm_sv_maxastabdist', '500', { FCVAR_REPLICATED, FCVAR_ARCHIVE } )
pm_sv_climbvel = CreateConVar( 'pm_sv_climbvel', '160', { FCVAR_REPLICATED, FCVAR_ARCHIVE } )
pm_sv_disabledoorbust = CreateConVar( 'pm_sv_disabledoorbust', '0', { FCVAR_REPLICATED, FCVAR_ARCHIVE } )
pm_sv_disablestabing = CreateConVar( 'pm_sv_disablestabing', '0', { FCVAR_REPLICATED, FCVAR_ARCHIVE } )
pm_sv_disablehealthregen = CreateConVar( 'pm_sv_disablehealthregen', '0', { FCVAR_REPLICATED, FCVAR_ARCHIVE } )
pm_viewbob = CreateConVar( 'pm_viewbob', '1', { FCVAR_REPLICATED, FCVAR_ARCHIVE } )

SWEP.PrintName			= 'Parkour SWEP'
SWEP.Category			= "Wheatley's SWEPs"
SWEP.Purpose			= "Used to make tricks. Cool tricks."
SWEP.Author				= 'Wheatley'
SWEP.ViewModel			= 'models/weapons/c_parkour_hands.mdl'
SWEP.WorldModel			= ''
SWEP.UseHands			= true
SWEP.Spawnable			= true
SWEP.DrawCrosshair		= false
SWEP.ViewModelFlip 		= false
SWEP.ViewModelFOV		= 75
SWEP.Slot				= 5
SWEP.SlotPos			= 3
SWEP.Mode				= 0
SWEP.LastMode			= 0
SWEP.NextReverse		= 0
SWEP.DrawAmmo 			= false

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= true
SWEP.Secondary.Ammo			= "none"

SWEP.Weight				= 100
SWEP.AutoSwitchTo		= true
SWEP.AutoSwitchFrom		= false

local pipeProps = {
	'models/props_docks/dock02_pole02a.mdl',
	'models/props_docks/dock01_pole01a_256.mdl',
	'models/props_docks/dock01_pole01a_128.mdl',
	'models/props_docks/dock02_pole02a_256.mdl',
	'models/props_docks/dock03_pole01a.mdl',
	'models/props_pipes/gutterlarge_512_001a.mdl',
	'models/props_pipes/gutterlarge_640_001a.mdl',
	'models/props_c17/utilitypole01d.mdl',
	'models/props_c17/utilitypole02b.mdl',
	'models/props_c17/utilitypole03a.mdl',
	'models/props_c17/utilitypole02b.mdl',
	'models/props_c17/lamppost03a_off.mdl',
	'models/props_c17/lamppost03a_off_dynamic.mdl'
}
local parkourmod_OnEdgeMaxTurn = 45

if SERVER then
	util.AddNetworkString( 'PARKOUR_UPDATE_ANIMATION' )
else
	net.Receive( 'PARKOUR_UPDATE_ANIMATION', function()
		local target = net.ReadEntity()
		local slot = net.ReadFloat()
		local anim = net.ReadFloat()
		local loop = ( net.ReadFloat() == 1 ) and true or false
		local cycle = net.ReadFloat()
		
		if cycle == -1 then
			target:AnimRestartGesture( slot, anim, loop )
		else
			target:AddVCDSequenceToGestureSlot( slot, anim, cycle, loop )
		end
	end )
	
	local wpn_ico = Material( 'entities/parkourmod.png' )
	function SWEP:DrawWeaponSelection( x, y, w, h, alpha )
		surface.SetDrawColor( 255, 255, 255, alpha )
		surface.SetMaterial( wpn_ico )
		surface.DrawTexturedRect( x + w / 4, y + h / 4, w / 2, h / 2 )
		surface.DrawOutlinedRect( x + w / 4, y + h / 4, w / 2, h / 2 )
		surface.DrawOutlinedRect( x, y, w, h / 6 )
		surface.SetDrawColor( 255, 200, 0, alpha )
		surface.DrawRect( x + 2, y + 2, ( w - 4 ) * self.Owner:GetNWInt( 'ParkourAdrenaline' ) / 100, h / 6 - 4 )
		
		surface.SetDrawColor( 0, 0, 0, alpha / 1.5 )
		surface.DrawRect( x + w + 5, y, w - 4, 50 )
		
		surface.SetFont( 'DermaDefaultBold' )
		surface.SetTextColor( 255, 255, 255, alpha )
		surface.SetTextPos( x + w + 9, y + 2 )
		surface.DrawText( 'Parkour SWEP' )
		
		surface.SetTextPos( x + w + 9, y + 13 )
		surface.DrawText( 'Author:' )
		surface.SetTextColor( 150, 150, 255, alpha )
		surface.DrawText( ' Wheatley' )
		surface.SetTextPos( x + w + 9, y + 23 )
		surface.SetTextColor( 255, 255, 255, alpha )
		surface.DrawText( 'Purpose:' )
		surface.SetTextColor( 150, 150, 255, alpha )
		surface.DrawText( ' Used to make tricks' )
		surface.SetTextPos( x + w + 9, y + 33 )
		surface.SetTextColor( 255, 255, 255, alpha )
		surface.DrawText( 'Adrenaline:' )
		surface.SetTextColor( 255, 200, 0, alpha )
		surface.DrawText( ' ' .. tostring( self.Owner:GetNWInt( 'ParkourAdrenaline' ) ) )
		//self:PrintWeaponInfo( x + w, y + h, alpha )
	end
end

function SWEP:Initialize()
	local ply = self.Owner
	if !IsValid( ply ) or !ply:IsPlayer() then return end
		
	ply.Adrenaline = 0
	ply.ParkourInAdrenaline = false
	self:SetHoldType( 'fist' )
end

function SWEP:Holster( ent )
	if SERVER then
		local ply = self.Owner
		if !IsValid( ply ) then return end
		ply:SetWalkSpeed( 250 )
		ply:SetRunSpeed( 500 )
		ply.WalkAcceleration = 0
		self:SetHoldType( 'fist' )
	end
	
	return true
end

function SWEP:UpdateParkourAnimation( slot, anim, loop, cycle )
	loop = loop or 1
	cycle = cycle or -1
	if SERVER then
		net.Start( 'PARKOUR_UPDATE_ANIMATION' )
			net.WriteEntity( self.Owner )
			net.WriteFloat( slot )
			net.WriteFloat( anim )
			net.WriteFloat( loop )
			net.WriteFloat( cycle )
		net.Send( player.GetAll() )
	end
end

function SWEP:PrimaryAttack()
	local ply = self.Owner
	if !IsValid( ply ) or ply.OnEdge or ply.OnPipe or !ply:IsOnGround() then return end
	
	self.NextPrimaryAttack = self.NextPrimaryAttack or 0
	if self.NextPrimaryAttack > CurTime() then return end
	self.NextPrimaryAttack = CurTime() + 0.5
	ply:EmitSound( 'weapons/slam/throw.wav' )
	self.HoldenWeapon = nil
	local tr = util.TraceLine( { start = ply:GetShootPos(), endpos = ply:GetShootPos() + ply:GetAimVector() * 48, filter = ply } )
	
	if !IsValid( tr.Entity ) then 
		tr = util.TraceHull( { start = ply:GetShootPos(), endpos = ply:GetShootPos() + self.Owner:GetAimVector() * 48, filter = ply, mins = Vector( -10, -10, -8 ), maxs = Vector( 10, 10, 8 ) } )
	end

	ply:ViewPunch( Angle( 6, 6, -6 ) )
	self:UpdateParkourAnimation( GESTURE_SLOT_VCD, ACT_HL2MP_GESTURE_RANGE_ATTACK_FIST, 1 )
	if tr.Hit and SERVER then
		ply:EmitSound( 'parkourmod/floorslide_hit_hard' .. math.random( 1, 6 ) .. '.wav' )
		if tr.Entity:IsWorld() then ply:TakeDamage( 1, ply, self ) end
		if IsValid( tr.Entity ) and ( tr.Entity:IsNPC() || tr.Entity:IsPlayer() || tr.Entity:Health() > 0 ) then
			timer.Simple( 0.1, function() if !IsValid( self ) or !IsValid( ply ) or !IsValid( tr.Entity ) then return end tr.Entity:TakeDamage( math.random( 12, 24 ), ply, self ) end )
		end
		self:SendWeaponAnim( ACT_VM_HITCENTER )
		return true
	end
	self:SendWeaponAnim( ACT_VM_MISSCENTER )
	return true
end

function SWEP:SecondaryAttack()
	local ply = self.Owner
	if !IsValid( ply ) or ply.OnEdge then return end
	
	self.NextSecondaryAttack = self.NextSecondaryAttack or 0
	if self.NextSecondaryAttack > CurTime() then return end
	
	if !pm_sv_disableadr:GetBool() then
		if ply.Adrenaline == 100 then ply.ParkourInAdrenaline = true else ply.ParkourInAdrenaline = false end
		if ply.ParkourInAdrenaline then
			hook.Add( 'Think', 'AdrenalineThink', function()
				if !IsValid( ply ) or ply.OnEdge or !ply:Alive() then return end
				if ply.ParkourInAdrenaline and ply.Adrenaline > 0 then
					if game.GetTimeScale() != 0.5 then game.SetTimeScale( 0.5 ) end
					ply.Adrenaline = math.Max( ply.Adrenaline - 0.2, 0 )
				elseif ( !ply.ParkourInAdrenaline or ply.Adrenaline <= 0 ) and game.GetTimeScale() != 1 then
					game.SetTimeScale( 1 )
				end
				
				ply:SetNWInt( 'ParkourAdrenaline', ply.Adrenaline )
				ply:SetNWBool( 'ParkourInAdrenaline', ply.ParkourInAdrenaline )
			end )
		end
	end
	
	self.NextSecondaryAttack = CurTime() + 0.5
end

function SWEP:GetOperatingPoint()
	return ( self.Owner:GetPos() + Vector( 0, 0, 45 ) )
end

function SWEP:InitWallRun()
	local ply = self.Owner
	if !IsValid( ply ) or ply:GetVelocity():Length() < 400 then return end
	
	local dir_left = ply:EyeAngles():Right() * -25
	local dir_right = ply:EyeAngles():Right() * 25
	local pos = self:GetOperatingPoint()
	local trl = util.TraceLine( { start = pos, endpos = pos + dir_left, filter = ply } )
	local trr = util.TraceLine( { start = pos, endpos = pos + dir_right, filter = ply } )
	
	ply.NextWallRunSound = ply.NextWallRunSound or 0
	ply.WalkAcceleration = ( ply:GetVelocity():Length() / 1000 ) * 250
	
	local angleSin = math.sin( CurTime() * 15 ) * 0.2
	if trl.Hit and ( trl.Entity:IsWorld() or trl.Entity:GetClass() == 'prop_physics' ) then
		ply:ViewPunch( Angle( angleSin, -0.3, 1 ) )
		ply:SetVelocity( Vector( 0, 0, 6 ) )
		if ply.NextWallRunSound < CurTime() then
			local snd = 'parkourmod/wallrun' .. math.random( 1, 4 ) .. '.wav'
			ply.NextWallRunSound = CurTime() + 0.3
			ply:EmitSound( snd )
		end
		
		if ply:KeyDown( IN_MOVERIGHT ) then 
			ply:SetVelocity( ply:EyeAngles():Right() * 100 + Vector( 0, 0, 50 ) )
			ply:ViewPunch( Angle( 0, 10, 5 ) )
			ply.Adrenaline = ply.Adrenaline + 1
			//timer.Create( 'wallrun_headRot_' .. ply:EntIndex(), 0.01, 8, function() if !IsValid( ply ) then return end ply:SetEyeAngles( ply:EyeAngles() - Angle( 0, 5, 0 ) ) end )
		end
		ply.ParkourWallRun = -1
		ply.Adrenaline = ply.Adrenaline + 0.02
	elseif trr.Hit and ( trr.Entity:IsWorld() or trr.Entity:GetClass() == 'prop_physics' ) then
		ply:ViewPunch( Angle( angleSin, 0.3, -1 ) )
		ply:SetVelocity( Vector( 0, 0, 6 ) )
		if ply.NextWallRunSound < CurTime() then
			local snd = 'parkourmod/wallrun' .. math.random( 1, 4 ) .. '.wav'
			ply.NextWallRunSound = CurTime() + 0.3
			ply:EmitSound( snd )
		end
		
		if ply:KeyDown( IN_MOVELEFT ) then 
			ply:SetVelocity( ply:EyeAngles():Right() * -100 + Vector( 0, 0, 50 ) )
			ply:ViewPunch( Angle( 0, -10, -5 ) )
			ply.Adrenaline = ply.Adrenaline + 1
			//timer.Create( 'wallrun_headRot_' .. ply:EntIndex(), 0.01, 8, function() if !IsValid( ply ) then return end ply:SetEyeAngles( ply:EyeAngles() + Angle( 0, 5, 0 ) ) end )
		end
		ply.ParkourWallRun = 1
		ply.Adrenaline = ply.Adrenaline + 0.02
	else
		ply.ParkourWallRun = 0
	end
end

function SWEP:AttemptOBSJump()
	local ply = self.Owner
	if !IsValid( ply ) or !ply:IsOnGround() then return end
	
	local velLength = math.Clamp( ply:GetVelocity():Length() / 500, 0, 1 )
	local dir = Angle( 0, ply:EyeAngles().y, ply:EyeAngles().r ):Forward() * ( 150 * velLength )
	local pos = self:GetOperatingPoint()
	
	local tr = util.TraceLine( { start = pos, endpos = pos + dir - Vector( 0, 0, 15 ), filter = ply } )
	local tr_ramp = util.TraceLine( { start = pos + Vector( 0, 0, 25 ), endpos = pos + dir * 1.2 - Vector( 0, 0, 15 ), filter = ply } )
	
	local tr_fwrd = util.TraceLine( { start = pos, endpos = pos + dir * 1.5, filter = ply } )
	local tr_up = util.TraceLine( { start = pos + dir * 0.5 + Vector( 0, 0, 15 ), endpos = pos + dir * 1.2, filter = ply } )
	local tr_up_fwrd = util.TraceLine( { start = pos + dir * 2 + Vector( 0, 0, 5 ), endpos = pos + Vector( 0, 0, 5 ), filter = { ply } } )

	ply.NextOBSJump = ply.NextOBSJump or CurTime()
	ply.OBSJumpMode = 0
	
	if tr.Hit and ( tr.Entity:IsWorld() or tr.Entity:GetClass() == 'prop_physics' or ( tr.Entity:IsPlayer() and tr.Entity:KeyDown( IN_DUCK ) ) ) and ply:IsOnGround() and !tr_fwrd.Hit and ply.NextOBSJump < CurTime() then
		ply.NextOBSJump = CurTime() + 0.8
		ply:ViewPunch( Angle( 14, -12, 5 ) )
		ply:SetVelocity( Vector( 0, 0, math.Clamp( 650 * velLength, 0, pm_sv_maxjump:GetInt() ) ) )
		ply:EmitSound( 'parkourmod/impact_soft6.wav' )
		timer.Simple( 0.3, function() if !IsValid( ply ) then return end ply:EmitSound( 'parkourmod/impact_soft2.wav' ) ply:ViewPunch( Angle( -15, -12, 5 ) ) end )
		ply.Adrenaline = ply.Adrenaline + 0.5
		self:UpdateParkourAnimation( GESTURE_SLOT_CUSTOM, ACT_HL2MP_JUMP_MELEE, 1 )
		return
	end
	
	if tr.Hit and !tr_up_fwrd.Hit and ( tr.Entity:IsWorld() or tr.Entity:GetClass() == 'prop_physics' ) and ply:IsOnGround() and !tr_up.Hit and ply.NextOBSJump < CurTime() then
		ply.NextOBSJump = CurTime() + 0.5
		ply.OBSJumpMode = 1
		local leanDir = ( ply:GetPos() - tr.HitPos ):Angle()
		leanDir = Angle( 0, leanDir.y, leanDir.r )
		leanDir = leanDir:Forward()
		local leanVelocity = ply:GetVelocity()
		ply:ViewPunch( Angle( 4, 4, -5 ) )
		ply:EmitSound( 'parkourmod/floorrolling_01.wav', 75, 100, 0.4 )
		ply:EmitSound( 'parkourmod/impact_soft2.wav' )
		timer.Simple( 0.2, function() ply:ViewPunch( Angle( -6, 2, -6 ) ) ply:EmitSound( 'parkourmod/impact_soft6.wav' ) end )
		timer.Create( 'ParkourLeanPlayerThroughOBS_' .. tostring( ply:EntIndex() ), 0.001, 25, function()
			if !IsValid( ply ) or !ply:Alive() then return end
			ply:SetPos( ply:GetPos() - leanDir * 5 )
		end )
		ply.Adrenaline = ply.Adrenaline + 0.5
		self:UpdateParkourAnimation( GESTURE_SLOT_CUSTOM, 118, 0, 0.2 )
		timer.Simple( 0.4, function() if !IsValid( self ) then return end self:UpdateParkourAnimation( GESTURE_SLOT_CUSTOM, 118, 1, 1 ) end )
		ply:SetCycle( 0.6 )
	end
end

function SWEP:InitFloorSlide()
	local ply = self.Owner
	if !IsValid( ply ) then return end
	local pos = self:GetOperatingPoint()
	
	ply.SlidingSound = ply.SlidingSound or CreateSound( ply, 'parkourmod/floorslide.wav' )
	
	if ply:GetVelocity():Length() < 150 then if ply.SlidingSound:IsPlaying() then ply.SlidingSound:Stop() end return end
	
	ply.SlideVelocity = ply.SlideVelocity or 0
	if ply.SlideVelocity == 0 then ply.SlideVelocity = 70 * ( math.Clamp( ply:GetVelocity():Length() / 500, 0, 1 ) ) end
	
	local dir = Angle( 0, ply:EyeAngles().y, 0 ):Forward()
	local tr = util.TraceLine( { start = pos, endpos = pos + dir * 35, filter = ply } )
	local tr_up = util.TraceLine( { start = pos - Vector( 0, 0, 40 ), endpos = pos - Vector( 0, 0, 43 ) + dir * 25, filter = ply } )
	local tr_down = util.TraceLine( { start = pos - Vector( 0, 0, 40 ), endpos = pos - Vector( 0, 0, 48 ) + dir * 25, filter = ply } )
	
	if !tr_down.Hit then ply.SlideVelocity = math.Approach( ply.SlideVelocity, 100, 0.5 ) else ply.SlideVelocity = math.Approach( ply.SlideVelocity, 0, 0.5 ) end
	
	if tr_up.Hit then ply.SlideVelocity = math.Approach( ply.SlideVelocity, 0, 2 ) end
	if tr.Hit and ply.SlideVelocity > 0 then
		if IsValid( tr.Entity ) and ( tr.Entity:IsPlayer() or tr.Entity:IsNPC() ) then tr.Entity:TakeDamage( 70 * ( math.Clamp( ply:GetVelocity():Length() / 1000, 0, 1 ) ), self.Owner, self ) end
		ply:ViewPunch( Angle( ply.SlideVelocity / 5, 0.3, -1 ) )
		ply.SlideVelocity = 0
		ply.Adrenaline = ply.Adrenaline + 0.5
		if ply.SlidingSound:IsPlaying() then ply.SlidingSound:Stop() ply:EmitSound( 'parkourmod/floorslide_hit_hard' .. math.random( 1, 6 ) .. '.wav' ) end
		return
	end
	
	self:UpdateParkourAnimation( GESTURE_SLOT_VCD, 83, 1, 0.1 )
	ply.Adrenaline = ply.Adrenaline + 0.01
	ply:ViewPunch( Angle( 0, 0.3, -1 ) )
	ply:SetVelocity( dir * ply.SlideVelocity )
	if !ply.SlidingSound:IsPlaying() then ply.SlidingSound:Play() end
end

local function AngleDiff( a1, a2 )
	local p, r =
		math.abs( a1.p - a2.p ),
		math.abs( a1.r - a1.r )
		
	return math.max( p, r )
end

function SWEP:HoldOnEdge( parent )
	local ply = self.Owner
	if !IsValid( ply ) or ply.OnEdge then return end
	local pos = self:GetOperatingPoint()
	
	local catchAngle = ( IsValid( parent ) and parent:GetAngles() or Angle( 0, 0, 0 ) )
	local catchPos = ( IsValid( parent ) and parent:WorldToLocal( ply:GetPos() ) or pos )
	local posDiff = ply:GetPos().z
	local handsPos = ply.OnEdgeHandsPos
	
	ply.NextAllowedWallClimb = ply.NextAllowedWallClimb or 0
	ply.NextAllowedWallClimbKey = ply.NextAllowedWallClimbKey or 0
	if ply.NextAllowedWallClimb > CurTime() then return end
	
	local dir = Angle( 0, ply:EyeAngles().y, ply:EyeAngles().r ):Forward()
	local tr = util.TraceLine( { start = pos, endpos = pos + dir * 25, filter = ply } )

	local dclmb = util.TraceLine( { start = pos + Vector( 0, 0, 36 ), endpos = pos - Vector( 0, 0, 72 ), filter = ply } )
	local fclmb = util.TraceLine( { start = dclmb.HitPos + dir * 25 + Vector( 0, 0, 128 ), endpos = dclmb.HitPos + dir * 25 , filter = ply } )
	
	if IsValid( tr.Entity ) and table.HasValue( pipeProps, tr.Entity:GetModel() ) then return end
	
	if !tr.Hit then return end
	
	ply:EmitSound( 'parkourmod/impact_soft' .. math.random( 3, 5 ) .. '.wav' )
	
	ply.EdgeNormal = tr.HitNormal
	
	ply.OnEdge = true
	ply:SetMoveType( MOVETYPE_NONE )
	ply.NextAllowedWallClimbKey = CurTime() + 0.5
	
	hook.Add( 'Tick', 'Parkour_EdgeHolding_' .. ply:EntIndex(), function()
		if !ply:Alive() or ply:KeyPressed( IN_DUCK ) then ply:SetMoveType( MOVETYPE_WALK ) ply:SetVelocity( -ply:GetVelocity() ) hook.Remove( 'Tick', 'Parkour_EdgeHolding_' .. ply:EntIndex() ) ply.OnEdge = false return end
		if ply:GetMoveType() != MOVETYPE_NONE then ply.OnEdge = false hook.Remove( 'Tick', 'Parkour_EdgeHolding_' .. ply:EntIndex() )  end
		
		-- hold on moving objects
		if IsValid( parent ) and !parent:IsWorld() then
			if AngleDiff( catchAngle, parent:GetAngles() ) > 30 then
				ply:SetMoveType( MOVETYPE_WALK ) ply:SetVelocity( -ply:GetVelocity() ) hook.Remove( 'Tick', 'Parkour_EdgeHolding_' .. ply:EntIndex() ) ply.OnEdge = false
			end

			local pos = parent:LocalToWorld( catchPos )
			ply.OnEdgeHandsPos = handsPos + Vector( 0, 0, ply:GetPos().z - posDiff )
			ply:SetPos( pos )
			local ang = parent:GetAngles()
			local rot = Angle( catchAngle.p - ang.p, catchAngle.y - ang.y, catchAngle.r - ang.r )
			ply.EdgeNormal:Rotate( rot )
		end
		--
		
		if ply:KeyDown( IN_MOVELEFT ) and ply.NextWallClimbing < CurTime() then
			ply:SetMoveType( MOVETYPE_WALK )
			ply:SetVelocity( -ply:GetVelocity() + ply.EdgeNormal:Angle():Right() * 200 + Vector( 0, 0, 170 ) )
			hook.Remove( 'Tick', 'Parkour_EdgeHolding_' .. ply:EntIndex() ) 
			ply.OnEdge = false
			ply.NextAllowedWallClimb = CurTime() + 0.4
		end
		if ply:KeyDown( IN_MOVERIGHT ) and ply.NextWallClimbing < CurTime() then
			ply:SetMoveType( MOVETYPE_WALK )
			ply:SetVelocity( -ply:GetVelocity() - ply.EdgeNormal:Angle():Right() * 200 + Vector( 0, 0, 170 ) )
			hook.Remove( 'Tick', 'Parkour_EdgeHolding_' .. ply:EntIndex() ) 
			ply.OnEdge = false
			ply.NextAllowedWallClimb = CurTime() + 0.4
		end
		if fclmb.Fraction >= 0.5 then
			ply:SetMoveType( MOVETYPE_WALK )
			ply:SetVelocity( -ply:GetVelocity() + ply:GetAimVector() * 200 + Vector( 0, 0, 320 ) )
			ply:ViewPunch( Angle( 15, 15, -15 ) )
			hook.Remove( 'Tick', 'Parkour_EdgeHolding_' .. ply:EntIndex() ) 
			ply.OnEdge = false
			ply.NextAllowedWallClimb = CurTime() + 0.4
		end
		if ply:KeyDown( IN_JUMP ) and ply.NextAllowedWallClimbKey < CurTime() then 
			ply:SetMoveType( MOVETYPE_WALK )
			local aim = ply:GetAimVector()
			aim.z = 0
			ply:SetVelocity( -ply:GetVelocity() + aim * 200 + Vector( 0, 0, 260 ) )
			ply:SetPos( ply:GetPos() + Vector( 0, 0, 45 ) )
			ply:ViewPunch( Angle( 15, 5, 5 ) ) 
			hook.Remove( 'Tick', 'Parkour_EdgeHolding_' .. ply:EntIndex() ) 
			ply.OnEdge = false
			ply.NextAllowedWallClimb = CurTime() + 1
		end
		self:UpdateParkourAnimation( GESTURE_SLOT_VCD, 170, 1, 0.99 )
	end )
end

function SWEP:InitClimbing()
	local ply = self.Owner
	if !IsValid( ply ) then return end
	local pos = self:GetOperatingPoint()
	
	local dir = Angle( 0, ply:EyeAngles().y, ply:EyeAngles().r ):Forward()
	local tr = util.TraceLine( { start = pos, endpos = pos + dir * 25, filter = ply } )
	local tr_catch = util.TraceLine( { start = pos + Vector( 0, 0, 35 ), endpos = pos + Vector( 0, 0, 35 ) + dir * 30, filter = ply } )
	local heightTr = util.TraceLine( { start = tr_catch.HitPos, endpos = tr_catch.HitPos - Vector( 0, 0, 45 ), filter = ply } )
	
	ply.OnEdgeHandsPos = heightTr.HitPos
	ply.NextWallClimbing = ply.NextWallClimbing or CurTime()
	
	if tr.Hit and ( tr.Entity:IsWorld() or tr.Entity:GetClass() == 'prop_physics' ) and ply.ParkourWallRun == 0 then
		if ply:KeyDown( IN_USE ) and !ply.OnEdge then
			ply.ParkourWallClimbingRotationStep = ply.ParkourWallClimbingRotationStep or 0
			timer.Create( 'wallclimbJump_headRot_' .. ply:EntIndex(), 0.001, 20, function()
				ply.NextWallClimbing = CurTime() + 0.3
				ply.ParkourWallClimbingRotationStep = ply.ParkourWallClimbingRotationStep + 1
				if !IsValid( ply ) then return end ply:SetEyeAngles( Angle( ply:EyeAngles().p, math.ApproachAngle( ply:EyeAngles().y, tr.HitNormal:Angle().y, FrameTime() * 800 ), ply:EyeAngles().r ) )
				if ply.ParkourWallClimbingRotationStep == 20 then 
					ply:SetVelocity( -ply:GetVelocity() + tr.HitNormal:Angle():Forward() * 220 + Vector( 0, 0, 210 ) ) 
					ply:ViewPunch( Angle( 15, 0, 0 ) ) 
					ply.ParkourWallClimbingRotationStep = 0
					ply.ParkourWallClimbing = 0
				end
			end )
		end
		
		if !tr_catch.Hit then
			if IsValid( tr.Entity ) and table.HasValue( pipeProps, tr.Entity:GetModel() ) then return end
			self:HoldOnEdge( tr.Entity )
			ply.WalkAcceleration = 0
		end
		
		if ply.NextWallClimbing < CurTime() then	
			ply.NextWallClimbing = CurTime() + 0.4
			ply:SetVelocity( Vector( 0, 0, pm_sv_climbvel:GetInt() ) )
			ply:ViewPunch( Angle( -7, 0, 0 ) )
			ply:EmitSound( 'parkourmod/impact_soft' .. math.random( 1, 6 ) .. '.wav' )
			ply.ParkourWallClimbing = CurTime() + 0.6
		end
	end
end

function SWEP:InitFloorRolling()
	local ply = self.Owner
	if !IsValid( ply ) or ply:GetVelocity():Length() < 500 then return end
	local pos = self:GetOperatingPoint()
	
	local dir = Angle( 0, ply:EyeAngles().y, ply:EyeAngles().r ):Forward()
	local tr = util.TraceLine( { start = pos, endpos = pos - Vector( 0, 0, 60 ), filter = ply } )
	
	ply.ParkourNextFloorRolling = ply.ParkourNextFloorRolling or CurTime()
	
	if tr.Hit and ( tr.Entity:IsWorld() or tr.Entity:GetClass() == 'prop_physics' ) and !ply.ParkourRolling and ply.ParkourNextFloorRolling < CurTime() then
		ply.ParkourNextFloorRolling = CurTime() + 1.5
		ply.ParkourRolling = true
		local count = 0
		local pitchToSet = 0
		ply:SetVelocity( ( dir - Vector( 0, 0, -0.2 ) ) * 800 )
		ply:EmitSound( 'parkourmod/floorrolling_0' .. math.random( 1, 2 ) .. '.wav' )
		timer.Create( 'rolling_headRot_' .. ply:EntIndex(), 0.0001, 35, function() 
			if !IsValid( ply ) then return end 
			if ply:IsOnGround() then ply:SetVelocity( ( dir - Vector( 0, 0, -0.2 ) ) * 70 ) end
			pitchToSet = pitchToSet + 15
			if pitchToSet > 80 then pitchToSet = -80 end
			ply:SetEyeAngles( Angle( pitchToSet, ply:EyeAngles().y, ply:EyeAngles().r ) ) 
			count = count + 1
			if count == 35 then
				ply:SetEyeAngles( Angle( 0, ply:EyeAngles().y, ply:EyeAngles().r ) ) 
				ply.ParkourRolling = false
			end
		end )
		ply.Adrenaline = ply.Adrenaline + 1
		timer.Simple( 1.5, function() if IsValid( ply ) then ply.ParkourRolling = false end end )
	end
end

function SWEP:Init180Turn()
	local ply = self.Owner
	ply.Next180Turn = ply.Next180Turn or CurTime()
	if !IsValid( ply ) or ply.Next180Turn > CurTime() then return end
	ply.Next180Turn = CurTime() + 1
	ply:SetEyeAngles( Angle( ply:EyeAngles().p, ply:EyeAngles().y - 180, ply:EyeAngles().r ) )
	ply:ViewPunch( Angle( 0, -180, 0 ) )
end

function SWEP:InitPipeClimb()
	local ply = self.Owner
	if !IsValid( ply ) then return end
	
	ply.NextAllowedPipeClimb = ply.NextAllowedPipeClimb or 0
	
	if ply.NextAllowedPipeClimb > CurTime() then return end
	
	local pos = self:GetOperatingPoint()
	
	local dir = Angle( 0, ply:EyeAngles().y, ply:EyeAngles().r ):Forward()
	local tr = util.TraceLine( { start = pos, endpos = pos + dir * 25, filter = ply } )
	local pipe = tr.Entity
	
	ply.PipeSlidingSound = ply.PipeSlidingSound or CreateSound( ply, 'parkourmod/floorslide.wav' )
	ply.PipeNextMoveSound = ply.PipeNextMoveSound or 0
	
	if IsValid( pipe ) and pipe:GetClass() == 'prop_physics' and table.HasValue( pipeProps, pipe:GetModel() ) and !ply.OnPipe then
		ply.OnPipe = true
		local startPos = ply:GetPos()
		ply.PipeNormal = ply:EyeAngles()
		ply.OnPipeHandsPos = startPos + Vector( 0, 0, 60 )
		ply:SetMoveType( MOVETYPE_NONE )
		--ply:ViewPunch( Angle( -7, 0, 0 ) )
		ply:SetNWVector( 'ParkourPipePos', pipe:GetPos() )
		
		hook.Add( 'Tick', 'Parkour_OnPipeTick_' .. ply:EntIndex(), function()
			if !ply:Alive() then hook.Remove( 'Tick', 'Parkour_OnPipeTick_' .. ply:EntIndex() ) ply.OnPipe = false return end
			if ply:GetMoveType() != MOVETYPE_NONE then ply.OnPipe = false hook.Remove( 'Tick', 'Parkour_OnPipeTick_' .. ply:EntIndex() ) return end
			
			local tr_up = util.TraceLine( { start = startPos + Vector( 0, 0, 65 ), endpos = startPos + dir * 25 + Vector( 0, 0, 65 ), filter = ply } ).Entity
			local tr_dn = util.TraceLine( { start = startPos - Vector( 0, 0, 15 ), endpos = startPos + dir * 25 - Vector( 0, 0, 15 ), filter = ply } ).Entity
			
			ply.OnPipeHandsPos = startPos + Vector( 0, 0, 60 )
			ply:SetPos( startPos )
			
			if ply:KeyDown( IN_FORWARD ) and IsValid( tr_up ) and table.HasValue( pipeProps, tr_up:GetModel() ) then
				startPos = startPos + Vector( 0, 0, 3 )
				ply.ParkourPipeHoldMoveUp = CurTime() + 0.1
				local curSnd = 'parkourmod/impact_soft' .. math.random( 1, 6 ) .. '.wav'
				if ply.PipeNextMoveSound < CurTime() then ply:EmitSound( curSnd ) ply.PipeNextMoveSound = CurTime() + 0.43 end
			end
			
			if ply:KeyDown( IN_BACK ) and IsValid( tr_dn ) and table.HasValue( pipeProps, tr_dn:GetModel() ) then
				startPos = startPos - Vector( 0, 0, 3 )
				if ply:KeyDown( IN_SPEED ) then
					startPos = startPos - Vector( 0, 0, 6 )
					if !ply.PipeSlidingSound:IsPlaying() then ply.PipeSlidingSound:Play() end
				else
					ply.ParkourPipeHoldMoveDown = CurTime() + 0.1
					if ply.PipeSlidingSound:IsPlaying() then ply.PipeSlidingSound:Stop() end
					local curSnd = 'parkourmod/impact_soft' .. math.random( 1, 6 ) .. '.wav'
					if ply.PipeNextMoveSound < CurTime() then ply:EmitSound( curSnd ) ply.PipeNextMoveSound = CurTime() + 0.43 end
				end
			else
				if ply.PipeSlidingSound:IsPlaying() then ply.PipeSlidingSound:Stop() end
			end
			
			if ply:KeyDown( IN_DUCK ) or ply:KeyDown( IN_USE ) or ply:GetMoveType() != MOVETYPE_NONE or !IsValid( pipe ) then 
				ply:SetVelocity( -ply:GetVelocity() )
				ply:SetMoveType( MOVETYPE_WALK )
				ply.NextPipeClimp = CurTime() + 0.4
				hook.Remove( 'Tick', 'Parkour_OnPipeTick_' .. ply:EntIndex() ) 
				ply.OnPipe = false
				ply.NextAllowedPipeClimb = CurTime() + 1
				return
			end
			
			if ply:KeyDown( IN_MOVELEFT ) and ply:KeyPressed( IN_JUMP ) then
				ply:SetMoveType( MOVETYPE_WALK )
				ply:SetVelocity( -ply:GetVelocity() - ply.PipeNormal:Right() * 200 + Vector( 0, 0, 170 ) )
				ply:SetEyeAngles( ply.PipeNormal )
				ply:ViewPunch( Angle( -7, 0, -13 ) )
				ply:EmitSound( 'parkourmod/impact_soft' .. math.random( 1, 6 ) .. '.wav' )
				hook.Remove( 'Tick', 'Parkour_OnPipeTick_' .. ply:EntIndex() ) 
				ply.OnPipe = false
				ply.NextAllowedPipeClimb = CurTime() + 1
				return
			end
			
			if ply:KeyDown( IN_MOVERIGHT ) and ply:KeyPressed( IN_JUMP ) then
				ply:SetMoveType( MOVETYPE_WALK )
				ply:SetVelocity( -ply:GetVelocity() + ply.PipeNormal:Right() * 200 + Vector( 0, 0, 170 ) )
				ply:ViewPunch( Angle( -7, 0, 13 ) )
				ply:EmitSound( 'parkourmod/impact_soft' .. math.random( 1, 6 ) .. '.wav' )
				hook.Remove( 'Tick', 'Parkour_OnPipeTick_' .. ply:EntIndex() ) 
				ply.OnPipe = false
				ply.NextAllowedPipeClimb = CurTime() + 1
				return
			end
			
			if ply:KeyPressed( IN_JUMP ) and ply:KeyDown( IN_BACK ) then
				ply:SetMoveType( MOVETYPE_WALK )
				ply:SetVelocity( -ply:GetVelocity() - ply:EyeAngles():Forward() * 200 + Vector( 0, 0, 170 ) )
				ply:ViewPunch( Angle( -7, 0, 0 ) )
				hook.Remove( 'Tick', 'Parkour_OnPipeTick_' .. ply:EntIndex() ) 
				ply:EmitSound( 'parkourmod/impact_soft' .. math.random( 1, 6 ) .. '.wav' )
				ply.OnPipe = false
				ply.NextAllowedPipeClimb = CurTime() + 1
				return
			end
		end )
	end
end

function SWEP:InitLegHit()
	local ply = self.Owner
	if !IsValid( ply ) then return end
	
	local pos = self:GetOperatingPoint()
	
	local dir = Angle( 0, ply:EyeAngles().y, ply:EyeAngles().r ):Forward()
	local tr = util.TraceLine( { start = pos, endpos = pos + dir * 50 - Vector( 0, 0, 25 ), filter = ply } )
	local trg = tr.Entity
	
	if IsValid( trg ) and ( trg:IsPlayer() or trg:IsNPC() ) or trg:IsWorld() then
		local force = math.Clamp( ply:GetVelocity():Length() / 1200, 0, 1 )
		ply.NextLegHit = CurTime() + 1
		if trg:IsWorld() then
			ply:EmitSound( 'parkourmod/floorslide_hit_hard' .. math.random( 1, 6 ) .. '.wav' )
			ply:ViewPunch( Angle( 70 * force, 0, 0 ) )
			return
		end
		trg:TakeDamage( 95 * force, ply, self )
		if trg:IsPlayer() then trg:SetVelocity( dir * ( 1400 * force ) ) trg:ViewPunch( Angle( -70 * force, 0, 0 ) ) end
		ply:ViewPunch( Angle( 70 * force, 0, 0 ) )
		ply:EmitSound( 'parkourmod/floorslide_hit_hard' .. math.random( 1, 6 ) .. '.wav' )
	end
end

function SWEP:InitHeadTurn()
	local ply = self.Owner
	if !IsValid( ply ) or pm_sv_disableturn:GetBool() then return end
	if table.Count( player.GetAll() ) > 1 then
		ply:SetNWBool( 'PARKOUR_HEADTURN', true )
	else
		ply:ViewPunch( Angle( 0, 8, 0 ) )
	end
end

function SWEP:AdjustMouseSensitivity()
	local ply = self.Owner
	if !IsValid( ply ) then return end
	
	return ( ply:GetNWBool( 'ParkourIsSliding' ) ) and 0.1 or 1
end

function SWEP:InitAirStab()
	local ply = self.Owner
	if !IsValid( ply ) then return end
	ply.NextAirStab = ply.NextAirStab or 0
	local tr = ply:GetEyeTraceNoCursor()
	local tre = tr.Entity
	if !IsValid( tre ) then return end
	local trepos2D, plypos2D = tre:GetPos(), ply:GetPos()
	trepos2D.z = 0
	plypos2D.z = 0
	
	if IsValid( tre ) and ( tre:IsPlayer() or tre:IsNPC() ) and tre:GetPos().z + 160 < ply:GetPos().z and ply.NextAirStab < CurTime() and plypos2D:Distance( trepos2D + Vector( 0, 0, 45 ) ) < pm_sv_maxastabdist:GetInt() then
		ply:SetNWFloat( 'ParkourAirStabHint', CurTime() + 0.2 )
		if ply:KeyDown( IN_USE ) then
			ply.AirStabAnimTimer = CurTime() + 4
			ply.NextAirStab = CurTime() + 1
			self:SendWeaponAnim( ACT_VM_IDLE_EMPTY )
			local dir = ply:EyeAngles():Forward()
			dir.z = 0
			ply:SetVelocity( Vector( 0, 0, 350 ) + dir * 80 )
			ply:ViewPunch( Angle( 12, 0, 0 ) )
			timer.Simple( 0.3, function() if !IsValid( ply ) then return end ply:SetVelocity( ( tre:GetPos() - ply:GetPos() ) * 2 + Vector( 0, 0, 100 ) ) end )
			hook.Add( 'Think', 'ParkourThinkOnStabTarget_' .. ply:EntIndex(), function()
				local target = tre
				if !IsValid( target ) or !IsValid( ply ) or !ply:Alive() then hook.Remove( 'Think', 'ParkourThinkOnStabTarget_' .. ply:EntIndex() ) return end
				if ply:GetPos():Distance( target:GetPos() + Vector( 0, 0, 45 ) ) < 80 then
					target:TakeDamage( 1000, ply, self )
					ply:SetVelocity( -ply:GetVelocity() * 0.5 )
					ply:ViewPunch( Angle( 16, 16, -16 ) )
					self:SendWeaponAnim( ACT_VM_IDLE_DEPLOYED_EMPTY )
					ply:EmitSound( 'parkourmod/floorslide_hit_hard' .. math.random( 1, 6 ) .. '.wav' )
					ply:EmitSound( 'parkourmod/die_body_break_0' .. math.random( 1, 3 ) .. '.wav' )
					ply.AirStabAnimTimer = CurTime() + 0.3
					hook.Remove( 'Think', 'ParkourThinkOnStabTarget_' .. ply:EntIndex() )
				end
			end )
		end
	end
end

function SWEP:InitStab()
	local ply = self.Owner
	if !IsValid( ply ) then return end
	ply.NextStab = ply.NextStab or 0
	
	local pos = self:GetOperatingPoint()
	local tr = util.TraceLine( { start = pos, endpos = pos + ply:EyeAngles():Forward() * 35, filter = ply } )
	local tre = tr.Entity
	
	function CanStab()
		return tre:GetForward():DotProduct( ( ply:GetPos() - tre:GetPos() ):GetNormalized() ) < -0.6
	end
	
	if IsValid( tre ) and ( tre:IsPlayer() or tre:IsNPC() ) and CanStab() then
		ply:SetNWFloat( 'ParkourAirStabHint', CurTime() + 0.2 )
		if ply:KeyDown( IN_USE ) and ply.NextStab < CurTime() then
			ply.NextStab = CurTime() + 1
			ply.ParkourPlayingStabAnim = CurTime() + 1
			self:SendWeaponAnim( ACT_VM_HITCENTER2 )
			ply:SetEyeAngles( Angle( 0, ply:EyeAngles().y, ply:EyeAngles().r ) )
			ply:ViewPunch( Angle( 3, -3, -3 ) )
			ply:EmitSound( 'parkourmod/impact_soft' .. math.random( 1, 7 ) .. '.wav', 75, 100, 0.5 )
			timer.Simple( 0.27, function()
				if !IsValid( tre ) then return end
				if tre:LookupBone( 'ValveBiped.Bip01_Head1' ) then tre:ManipulateBoneAngles( tre:LookupBone( 'ValveBiped.Bip01_Head1' ), Angle( 0, 0, -90 ) ) end
				ply:ViewPunch( Angle( 6, -16, -8 ) )
				tre:EmitSound( 'parkourmod/necksnap.wav', 75, 150, 0.5 )
			end )
			timer.Simple( 0.6, function() 
				if !IsValid( tre ) then return end
				if !tre:IsPlayer() then
					local doll = ents.Create( 'prop_ragdoll' )
					doll:SetPos( tre:GetPos() )
					doll:SetAngles( tre:GetAngles() )
					doll:SetModel( tre:GetModel() )
					doll:Spawn()
					doll:Activate()
					doll:SetCollisionGroup( COLLISION_GROUP_DEBRIS )
					doll:ResetSequence( 1 )
					if doll:LookupBone( 'ValveBiped.Bip01_Head1' ) then doll:ManipulateBoneAngles( doll:LookupBone( 'ValveBiped.Bip01_Head1' ), Angle( 0, 0, 90 ) ) end
					timer.Simple( 30, function() if !IsValid( doll ) then return end SafeRemoveEntity( doll ) end )
				end
				if tre:LookupBone( 'ValveBiped.Bip01_Head1' ) then tre:ManipulateBoneAngles( tre:LookupBone( 'ValveBiped.Bip01_Head1' ), Angle( 0, 0, 0 ) ) end
				ply:EmitSound( 'parkourmod/impact_soft' .. math.random( 1, 7 ) .. '.wav', 75, 100, 0.5 )
				if !tre:IsPlayer() then tre:Remove() else tre:TakeDamage( 10000, ply, self ) end
				ply:ViewPunch( Angle( -6, 0, 0 ) )
			end )
		end
	end
	//ply:SetNWFloat( 'ParkourAirStabHint', CurTime() + 0.2 )
end

function SWEP:InitDoorBrust()
	if pm_sv_disabledoorbust:GetBool() then return end
	local ply = self.Owner
	if !IsValid( ply ) then return end
	ply.NextDoorBrust = ply.NextDoorBrust or 0
	if ply.NextDoorBrust > CurTime() or ply:GetVelocity():Length() < 350 then return end
	
	local pos = self:GetOperatingPoint()
	local tr = util.TraceLine( { start = pos, endpos = pos + ply:EyeAngles():Forward() * 65, filter = ply } )
	local tre = tr.Entity
	
	if IsValid( tre ) and tre:GetClass() == 'prop_door_rotating' and !tre:HasSpawnFlags( 2048 ) then
		local door = ents.Create( 'prop_physics' )
		door:SetPos( tre:GetPos() )
		door:SetAngles( tre:GetAngles() )
		door:SetModel( tre:GetModel() )
		door:SetSkin( tre:GetSkin() )
		door:SetBodyGroups( tre:GetBodyGroups() )
		door:Spawn()
		door:Activate()
		door:SetCollisionGroup( COLLISION_GROUP_DEBRIS )
		local phy = door:GetPhysicsObject()
		if IsValid( phy ) then phy:SetVelocity( ply:EyeAngles():Forward() * 420 ) end
		tre:Remove()
		ply:ViewPunch( Angle( 35, 35, 35 ) )
		self:SendWeaponAnim( ACT_VM_HITCENTER )
		ply:EmitSound( 'parkourmod/door_brust.wav', 75, 90 )
	end
end

function SWEP:InitPoleRot()
	local ply = self.Owner
	if !IsValid( ply ) then return end
	if ply.OnPipe or ply.NextAllowedPipeClimb > CurTime() or ply.OnEdge then return end
	
	local pole = ply:GetNWEntity( 'PARKOUR_POLE' )
	
	if !IsValid( pole ) then
		for i, v in pairs( ents.FindInSphere( ply:GetPos(), 64 ) ) do
			if !IsValid( v ) or !table.HasValue( pipeProps, v:GetModel() ) then continue end

			ply:SetNWEntity( 'PARKOUR_POLE', v )
			pole = v
			local ps = ( ply:GetPos() - pole:GetPos() ):GetNormalized()
			ps.z = ply:GetPos().z
			ply:SetNWVector( 'PARKOUR_POLE_POS', ps )
			local vel = ply:GetVelocity()
			local side = ( pole:GetPos() - ply:GetPos() ):Dot( ply:EyeAngles():Right() ) > 0
			ply:SetNWVector( 'PARKOUR_POLE_VEL', Vector( vel.x, vel.y, 0 ) )
			ply:SetNWBool( 'PARKOUR_POLE_SIDE', side )
			ply.PoleRotationVelocityLength = vel:Length() * ( side and -1 or 1 )
			break
		end
	end
	
	local attachPos = ply:GetNWVector( 'PARKOUR_POLE_POS' )
	local newPos = attachPos
	local vel = ply:GetNWVector( 'PARKOUR_POLE_VEL' )
	local side = ply:GetNWBool( 'PARKOUR_POLE_SIDE' )

	if IsValid( pole ) then
		ply.OnPole = true
		ply.PoleRotationVelocityLength = math.Approach( ply.PoleRotationVelocityLength, 0, 5 )
		--ply:SetNWVector( 'PARKOUR_POLE_VEL', vel * 0.99 )
		
		if math.abs( ply.PoleRotationVelocityLength ) < 100 then 
			ply.NextAllowedWallClimb = CurTime() + 1
			ply.NextAllowedPipeClimb = CurTime() + 1 
			ply:ViewPunch( Angle( -15, 0, 0 ) ) 
			ply:EmitSound( 'parkourmod/impact_soft' .. math.random( 1, 7 ) .. '.wav', 75, 100, 0.5 ) 
			ply:SetVelocity( -ply:GetVelocity() )
			return 
		end
		
		newPos:Rotate( Angle( 0, ply.PoleRotationVelocityLength / 100, 0 ) )
		
		vel:Rotate( Angle( 0, ply.PoleRotationVelocityLength / 100, 0 ) )
		
		local newAngle = newPos:Angle():Right():Angle()
		newAngle:RotateAroundAxis( Vector( 0, 0, 1 ), ( side and 0 or 180 ) )
		newAngle.y = newAngle.y + ( side and -60 or 60 )
		ply:SetEyeAngles( newAngle )
		
		local ps = pole:GetPos() + ply:EyeAngles():Forward() * 15 + newPos * 120
		ps.z = attachPos.z
		ply:SetPos( ps )
		ply:SetVelocity( -ply:GetVelocity() + vel )
		
		local tr = util.TraceLine( { start = ply:EyePos(), endpos = ply:EyePos() + ply:EyeAngles():Forward() * 50, filter = { ply, self } } )
		if tr.Hit then ply.NextAllowedPipeClimb = CurTime() + 1 ply:ViewPunch( Angle( -15, 0, 0 ) ) ply:EmitSound( 'parkourmod/impact_soft' .. math.random( 1, 7 ) .. '.wav', 75, 100, 0.5 ) return end
	end
end

function SWEP:Think()
	if CLIENT then return end
	local ply = self.Owner
	if !IsValid( ply ) then return end
	
	if ply:EyeAngles().p > 60 and ply:WaterLevel() < 2 then ply:SetEyeAngles( Angle( 60, ply:EyeAngles().y, ply:EyeAngles().r ) ) end
	
	ply.Adrenaline = ply.Adrenaline or 0
	ply.ParkourInAdrenaline = ply.ParkourInAdrenaline or false
	
	if ply:GetVelocity():Length() > 1400 and ply:GetMoveType() == MOVETYPE_WALK and ply.AirStabAnimTimer < CurTime() and !ply.ParkourRolling then
		self:UpdateParkourAnimation( GESTURE_SLOT_VCD, ACT_GMOD_GESTURE_RANGE_FRENZY, 1 )
		ply:ViewPunch( Angle( math.cos( CurTime() * 26 ) * 1, math.sin( CurTime() * 26 ) * 1, math.cos( CurTime() * 26 ) * math.random( -1, 1 ) ) )
		if self:GetSequence() != 9 then
			if string.find( ply:GetModel(), 'combine' ) or string.find( ply:GetModel(), 'police' ) then
				ply:EmitSound( 'parkourmod/die_combine_0' .. math.random( 1, 3 ) .. '.wav', 75, 90 )
			elseif string.find( ply:GetModel(), 'female' ) then
				ply:EmitSound( 'parkourmod/die_female_0' .. math.random( 1, 2 ) .. '.wav', 75, 90 )
			elseif string.find( ply:GetModel(), 'male' ) then
				ply:EmitSound( 'parkourmod/die_male_0' .. math.random( 1, 2 ) .. '.wav', 75, 90 )
			end
			self:SendWeaponAnim( ACT_VM_FIDGET )
		end
		ply.Adrenaline = math.Clamp( ply.Adrenaline + 1, 0, 100 )
		ply:SetNWInt( 'ParkourAdrenaline', ply.Adrenaline )
		return
	end

	ply.InAirTime = ply.InAirTime or 0
	if ply.Adrenaline <= 0 then ply.ParkourInAdrenaline = false end
	if !ply:IsOnGround() and ply:GetMoveType() != MOVETYPE_NOCLIP and ply:WaterLevel() == 0 and !ply.OnEdge and !ply.OnPipe then ply.InAirTime = ply.InAirTime + 0.05 ply.Adrenaline = ply.Adrenaline + 0.01 * ply.InAirTime else ply.InAirTime = 0 end
	
	ply.NextOBSJump = ply.NextOBSJump or 0
	ply.OBSJumpMode = ply.OBSJumpMode or 0
	ply.LastDealedDamage = ply.LastDealedDamage or 0
	ply.HealthRegenValue = ply.HealthRegenValue or 1
	ply.NextHealthRegen = ply.NextHealthRegen or 0
	ply.NextLegHit = ply.NextLegHit or 0
	ply.AirStabAnimTimer = ply.AirStabAnimTimer or 0
	ply.NextSwimmingSound = ply.NextSwimmingSound or 0
	ply.ParkourPlayingStabAnim = ply.ParkourPlayingStabAnim or 0
	
	if ply.NextHealthRegen < CurTime() and ply:Health() < ply:GetMaxHealth() and ply.LastDealedDamage < CurTime() and !pm_sv_disablehealthregen:GetBool() then
		ply:SetHealth( math.Clamp( ply:Health() + 1, 0, ply:GetMaxHealth() ) )
		ply.HealthRegenValue = ply.HealthRegenValue + 1
		if ply.ParkourInAdrenaline then ply.NextHealthRegen = CurTime() + 0.02 else ply.NextHealthRegen = CurTime() + ( 2 - ( 1.4 * ( math.Clamp( ply.HealthRegenValue / 5, 0, 1 ) ) ) - ( 0.4 * ( ply.Adrenaline / 100 ) ) ) end
	elseif ply:Health() >= ply:GetMaxHealth() or ply.LastDealedDamage > CurTime() then
		ply.HealthRegenValue = 0
	end
	
	if !ply:IsOnGround() then ply.NextOBSJump = CurTime() + 1 end
	self.NextPrimaryAttack = self.NextPrimaryAttack or 0
	ply.NextPipeClimp = ply.NextPipeClimp or 0
	
	if ply:WaterLevel() <= 1 then
		if ply:KeyDown( IN_FORWARD ) and !ply:KeyDown( IN_DUCK ) and ply:KeyDown( IN_JUMP ) and !ply:IsOnGround() then self:InitWallRun() else ply.ParkourWallRun = 0 end
		if ply:KeyDown( IN_SPEED ) and ply:KeyDown( IN_FORWARD ) and !ply:KeyDown( IN_DUCK ) and ply:IsOnGround() then self:AttemptOBSJump() end
		if ply:KeyDown( IN_FORWARD ) and ply:KeyDown( IN_DUCK ) and ply:IsOnGround() then self:InitFloorSlide() else ply.SlideVelocity = 0 if ply.SlidingSound and ply.SlidingSound:IsPlaying() then ply.SlidingSound:Stop() end end
		if ply:KeyDown( IN_FORWARD ) and !ply:KeyDown( IN_DUCK ) and ply:KeyDown( IN_JUMP ) and ply:GetMoveType() == MOVETYPE_WALK and ply.ParkourWallRun < CurTime() and !ply.OnEdge and !ply.OnPipe then self:InitClimbing() end
		if ply:KeyDown( IN_SPEED ) and ply:KeyDown( IN_DUCK ) and !ply:KeyDown( IN_FORWARD ) and !ply.OnEdge and !ply.OnPipe then self:InitFloorRolling() end
		if ply:KeyDown( IN_FORWARD ) and ply:KeyDown( IN_RELOAD ) and !ply.OnEdge and ply:IsOnGround() then self:Init180Turn() end
		if ply:KeyDown( IN_FORWARD ) and ply:KeyDown( IN_USE ) and !ply.OnEdge and !ply.OnPipe and ply:IsOnGround() then self:InitHeadTurn() else ply:SetNWBool( 'PARKOUR_HEADTURN', false ) end
		if ply:GetMoveType() == MOVETYPE_WALK and ply.NextPipeClimp < CurTime() and !ply:IsOnGround() and !ply.OnPipe and ply:GetMoveType() == MOVETYPE_WALK then self:InitPipeClimb() end
		if ply:KeyDown( IN_ATTACK ) and ply:GetMoveType() == MOVETYPE_WALK and !ply:IsOnGround() and ply.NextLegHit < CurTime() then self:InitLegHit() end
		if ply:IsOnGround() and !pm_sv_disablestabing:GetBool() then self:InitStab() self:InitAirStab() elseif ( ply.OnPipe or ply.OnEdge ) and !pm_sv_disablestabing:GetBool() then self:InitAirStab() end
		if ply:KeyDown( IN_SPEED ) and !pm_sv_disabledoorbust:GetBool() then self:InitDoorBrust() end
		if ply:KeyDown( IN_JUMP ) then self:InitPoleRot() elseif IsValid( ply:GetNWEntity( 'PARKOUR_POLE' ) ) then 
			ply.NextAllowedPipeClimb = CurTime() + 1 ply:SetNWEntity( 'PARKOUR_POLE', NULL ) self.poleRotation = 0 ply.OnPole = false end
	elseif ply:WaterLevel() >= 2 then
		if ply:KeyDown( IN_MOVELEFT ) and self:GetSequence() != 18 then
			self:SendWeaponAnim( ACT_VM_DEPLOY_6 )
		elseif ply:KeyDown( IN_MOVERIGHT ) and self:GetSequence() != 17 then
			self:SendWeaponAnim( ACT_VM_DEPLOY_7 )
		elseif !ply:KeyDown( IN_MOVELEFT ) and !ply:KeyDown( IN_MOVERIGHT ) and self:GetSequence() != 16 then
			self:SendWeaponAnim( ACT_VM_DEPLOY_8 )
		end
		if ply.NextSwimmingSound < CurTime() then
			ply.NextSwimmingSound = CurTime() + 0.8
			ply:EmitSound( 'parkourmod/swimming_wade' .. math.random( 1, 8 ) .. '.wav' )
		end
		ply.SlideVelocity = 0
		if ply.SlidingSound and ply.SlidingSound:IsPlaying() then ply.SlidingSound:Stop() end
	end
	
	ply.WalkAcceleration = ply.WalkAcceleration or 0
	ply.ParkourWallClimbing = ply.ParkourWallClimbing or 0
	
	if ply.OBSJumpMode == 1 and ply.NextOBSJump > CurTime() and self:GetSequence() != 12 then self:SendWeaponAnim( ACT_VM_RECOIL1 ) end
	if ply:KeyDown( IN_FORWARD ) and ply:WaterLevel() < 2 and ply:GetVelocity():Length() > 150 then ply.WalkAcceleration = math.Approach( ply.WalkAcceleration, 250, 2 ) else ply.WalkAcceleration = math.Approach( ply.WalkAcceleration, 0, 15 ) end
	ply:SetWalkSpeed( math.Clamp( 250 + ply.WalkAcceleration, 250, pm_sv_maxspeed:GetInt() ) )
	ply:SetRunSpeed( math.Clamp( 250 + ply.WalkAcceleration, 250, pm_sv_maxspeed:GetInt() ) )
	if ply.WalkAcceleration > 0 and self.NextPrimaryAttack < CurTime() and ply.ParkourWallRun == 0 and ply:WaterLevel() < 3 then
		if self:GetSequence() != 3 and ply.ParkourWallClimbing < CurTime() and !ply.OnPipe then self:SendWeaponAnim( ACT_VM_PULLBACK ) end
		if pm_viewbob:GetBool() then
			local viewBob = math.sin( CurTime() * 15 ) * ( ply.WalkAcceleration / 250 )
			ply:ViewPunch( Angle( viewBob * 0.05, 0, viewBob * -0.1 ) )
		end
	end
	
	ply.Adrenaline = math.Clamp( ply.Adrenaline, 0, 100 )
	ply:SetNWInt( 'ParkourAdrenaline', ply.Adrenaline )
	ply:SetNWBool( 'ParkourInAdrenaline', ply.ParkourInAdrenaline )
	ply:SetNWInt( 'ParkourNextPrimaryAttack', self.NextPrimaryAttack )
	ply:SetNWBool( 'ParkourRolling', ply.ParkourRolling )
	ply:SetNWBool( 'ParkourOnEdge', ply.OnEdge ) 
	ply:SetNWBool( 'ParkourOnPipe', ply.OnPipe )
	ply:SetNWBool( 'ParkourIsSliding', ( ply.SlideVelocity != 0 ) and true or false )
	if ply.OnEdge then ply:SetNWVector( 'ParkourOnEdgeNormal', ply.EdgeNormal ) ply:SetNWVector( 'ParkourOnEdgePos', ply.OnEdgeHandsPos ) end
	if ply.OnPipe then ply:SetNWAngle( 'ParkourOnPipeNormal', ply.PipeNormal ) ply:SetNWVector( 'ParkourOnPipePos', ply.OnPipeHandsPos ) end
	
	ply.ParkourPipeHoldMoveUp = ply.ParkourPipeHoldMoveUp or 0
	ply.ParkourPipeHoldMoveDown = ply.ParkourPipeHoldMoveDown or 0

	if ply.OnPole then
		if !ply:GetNWBool( 'PARKOUR_POLE_SIDE' ) and self:GetActivity() != ACT_VM_RECOIL2 then
			self:SendWeaponAnim( ACT_VM_SPRINT_ENTER )
		elseif ply:GetNWBool( 'PARKOUR_POLE_SIDE' ) and self:GetActivity() != ACT_VM_RECOIL2 then
			self:SendWeaponAnim( ACT_VM_SPRINT_LEAVE )
		end
	end
	
	if ply.OnPipe and ply.ParkourPipeHoldMoveUp < CurTime() and ply.ParkourPipeHoldMoveDown < CurTime() and self:GetActivity() != ACT_VM_RECOIL2 then self:SendWeaponAnim( ACT_VM_RECOIL2 ) end
	if ply.OnPipe and ply.ParkourPipeHoldMoveUp > CurTime() and ply.ParkourPipeHoldMoveDown < CurTime() and self:GetActivity() != ACT_VM_DETACH_SILENCER then self:SendWeaponAnim( ACT_VM_DETACH_SILENCER ) end
	if ply.OnPipe and ply.ParkourPipeHoldMoveUp < CurTime() and ply.ParkourPipeHoldMoveDown > CurTime() and self:GetActivity() != ACT_VM_ATTACH_SILENCER then self:SendWeaponAnim( ACT_VM_ATTACH_SILENCER ) end
	
	if ply.ParkourRolling and self:GetSequence() != 6 then self:SendWeaponAnim( ACT_VM_PULLBACK_HIGH ) end
	if ply.OnEdge and self:GetSequence() != 2 then self:SendWeaponAnim( ACT_VM_HOLSTER ) end
	if ply.SlideVelocity != 0 and self.NextPrimaryAttack < CurTime() and self:GetSequence() != 7 then self:SendWeaponAnim( ACT_VM_PULLBACK_LOW ) end
	if ply.ParkourWallRun != 0 then 
		if ply.ParkourWallRun == 1 and self:GetSequence() != 4 then 
			self:SendWeaponAnim( ACT_VM_PULLPIN ) 
		elseif ply.ParkourWallRun == -1 and self:GetSequence() != 8 then 
			self:SendWeaponAnim( ACT_VM_THROW )
		end
	end
	
	if ply.ParkourWallClimbing > CurTime() and !ply.OnEdge and !ply.OnPipe then if self:GetSequence() != 5 then self:SendWeaponAnim( ACT_VM_SWINGMISS ) end end
	
	if ply.ParkourPlayingStabAnim < CurTime() and ply.AirStabAnimTimer < CurTime() and ply.ParkourWallClimbing < CurTime() and ply.WalkAcceleration == 0 and !ply.OnEdge and !ply.OnPipe and ply.SlideVelocity == 0 and ply.ParkourWallRun <= 0 and !ply.ParkourRolling and !ply.OnPole and self.NextPrimaryAttack < CurTime() and ( ply.NextOBSJump < CurTime() or ply.OBSJumpMode != 1 ) and self:GetSequence() != 0 and ply:WaterLevel() < 2 then self:SendWeaponAnim( ACT_VM_IDLE ) end
end

if CLIENT then
	local color_inactive = Color( 150, 150, 150, 255 )
	local color_active = Color( 100, 255, 100, 255 )
	local drawPos = { x = 25, y = ScrH() - 200 }

	local function DrawButtonIcon( key, title, x, y, w, h )
		surface.SetDrawColor( ( LocalPlayer():KeyDown( key ) ) and color_active or color_inactive )
		surface.DrawOutlinedRect( drawPos.x + x, drawPos.y + y, w, h )
		surface.SetDrawColor( ( LocalPlayer():KeyDown( key ) ) and Color( 0, 200, 0, 150 ) or Color( 0, 0, 0, 0 ) )
		surface.DrawRect( drawPos.x + x + 2, drawPos.y + y + 2, w - 4, h - 4 )
		surface.SetTextColor( ( LocalPlayer():KeyDown( key ) ) and color_active or color_inactive )
		surface.SetFont( 'DermaDefault' )
		surface.SetTextPos( drawPos.x + x + 4, drawPos.y + y + 2 )
		surface.DrawText( title )
	end
	
	local function DrawComboString( x, y, w, h )
		local hasCombo = false
		local text = ''
		local ply = LocalPlayer()
		/*
		if ply:KeyDown( IN_FORWARD ) and !ply:KeyDown( IN_DUCK ) and ply:KeyDown( IN_JUMP ) and !ply:IsOnGround() then self:InitWallRun() else ply.ParkourWallRun = 0 end
		if ply:KeyDown( IN_SPEED ) and ply:KeyDown( IN_FORWARD ) and !ply:KeyDown( IN_DUCK ) and ply:IsOnGround() then self:AttemptOBSJump() end
		if ply:KeyDown( IN_SPEED ) and ply:KeyDown( IN_FORWARD ) and ply:KeyDown( IN_DUCK ) and ply:IsOnGround() then self:InitFloorSlide() else ply.SlideVelocity = 0 if ply.SlidingSound and ply.SlidingSound:IsPlaying() then ply.SlidingSound:Stop() end end
		if ply:KeyDown( IN_FORWARD ) and !ply:KeyDown( IN_DUCK ) and ply:KeyDown( IN_JUMP ) and ply:GetMoveType() == MOVETYPE_WALK and ply.ParkourWallRun < CurTime() and !ply.OnEdge and !ply.OnPipe then self:InitClimbing() else ply.ParkourWallClimbing = 0 end
		if ply:KeyDown( IN_SPEED ) and ply:KeyDown( IN_DUCK ) and !ply:KeyDown( IN_FORWARD ) and !ply.OnEdge then self:InitFloorRolling() end
		if ply:KeyDown( IN_FORWARD ) and ply:KeyDown( IN_RELOAD ) and !ply.OnEdge and ply:IsOnGround() then self:Init180Turn() end
		if ply:GetMoveType() == MOVETYPE_WALK and ply.NextPipeClimp < CurTime() and !ply:IsOnGround() and !ply.OnPipe and ply:GetMoveType() == MOVETYPE_WALK then self:InitPipeClimb() end
		if ply:KeyDown( IN_ATTACK ) and ply:KeyDown( IN_SPEED ) and ply:GetMoveType() == MOVETYPE_WALK and !ply:IsOnGround() and ply.NextLegHit < CurTime() then self:InitLegHit() end
		*/
		
		if ply:KeyDown( IN_FORWARD ) then hasCombo = true text = text .. ' + ' .. 'Walk/Run' end
		if ply:KeyDown( IN_SPEED ) then hasCombo = true text = text .. ' + ' .. 'Parkour Key' end
		if ply:KeyDown( IN_JUMP ) then hasCombo = true text = text .. ' + ' .. 'Jump' end
		if ply:KeyDown( IN_SPEED ) and ply:KeyDown( IN_FORWARD ) and !ply:KeyDown( IN_DUCK ) and ply:IsOnGround() then hasCombo = true text = '   Obstruction Jump/Skip' end
		if ply:KeyDown( IN_FORWARD ) and ply:KeyDown( IN_DUCK ) and ply:IsOnGround() then hasCombo = true text = '   Floor Slide' end
		if ply:KeyDown( IN_FORWARD ) and !ply:KeyDown( IN_DUCK ) and ply:KeyDown( IN_JUMP ) and ply:GetMoveType() == MOVETYPE_WALK and !ply:GetNWBool( 'ParkourOnEdge' ) then hasCombo = true text = '   Wall Climbing | Jumping | Wall Run' end
		if ply:KeyDown( IN_USE ) and ply:GetNWBool( 'ParkourOnEdge' ) then hasCombo = true text = '   Wall Drop' end
		if ply:KeyDown( IN_DUCK ) and ply:KeyDown( IN_JUMP ) and ply:GetNWBool( 'ParkourOnEdge' ) then hasCombo = true text = '   ' end
		if ply:KeyDown( IN_FORWARD ) and ply:KeyDown( IN_SPEED ) and ply:KeyDown( IN_JUMP ) and !ply:IsOnGround() and ( ply:KeyDown( IN_MOVELEFT ) or ply:KeyDown( IN_MOVERIGHT ) ) then hasCombo = true text = '   Side Wall Jump' end
		if !ply:KeyDown( IN_FORWARD ) and ply:KeyDown( IN_SPEED ) and ply:KeyDown( IN_DUCK ) and !ply:IsOnGround() then hasCombo = true text = '   Floor Roll' end
		if ply:KeyDown( IN_FORWARD ) and ply:KeyDown( IN_RELOAD ) and ply:IsOnGround() then hasCombo = true text = '   180 deg. turn' end
		if ply:KeyDown( IN_FORWARD ) and ply:KeyDown( IN_USE ) and ply:IsOnGround() then hasCombo = true text = '   Head turn' end
		if ply:GetNWBool( 'ParkourOnEdge' ) then hasCombo = true text = '   Holding on wall' end 
		if ( ply:KeyDown( IN_ATTACK ) and ply:KeyDown( IN_SPEED ) and ply:GetMoveType() == MOVETYPE_WALK and !ply:IsOnGround() ) and !ply:KeyDown( IN_DUCK ) then hasCombo = true text = '   Air Hit' end
		text = string.sub( text, 4 )
		
		surface.SetDrawColor( ( hasCombo ) and color_active or color_inactive )
		surface.DrawOutlinedRect( drawPos.x + x, drawPos.y + y, w, h )
		
		surface.SetTextColor( ( hasCombo ) and color_active or color_inactive )
		surface.SetFont( 'DermaDefault' )
		surface.SetTextPos( drawPos.x + x + 4, drawPos.y + y + 3 )
		surface.DrawText( text )
	end
	
	local function DrawAdvice( x, y )
		local keys = {
			[IN_JUMP] = {
				'Jump Key + Move Forward (along the wall) = Wall Run', 
				'Jump Key + Move Forward + Move Left OR Move Right (along the wall) = Wall Rebound (Side Jump)',
				'Jump Key + Move Forward (in front of the wall) = Wall Climbing',
				'You MUST hold Jump and Move Forward until you "catch" ledge',
				'Jump Key + Move Forward (on ledge) = Ledge Climb',
				'Jump Key + Move Left or Move Right (on pipe) = Pipe Jump',
				'Jump Key + Move Back (on pipe) = Pipe Jump Back'
			},
			
			[IN_FORWARD] = {
				'Move Forward + Sprint Key = Obstruction Over-Jump|Ramp-Jump',
				'Move Forward + Sprint Key + Crouch = Floor Slide',
				'Move Forward + Reload Key = 180 degree turn',
				'Move Forward + Jump Key (along the wall) = Wall Run', 
				'Move Forward + Jump Key + Move Left OR Move Right (along the wall) = Wall Rebound (Side Jump)',
				'Move Forward + Jump Key (in front of the wall) = Wall Climbing',
				'You MUST hold Jump and Move Forward until you "catch" ledge'
			},
			
			[IN_SPEED] = {
				'Sprint Key + Move Forward = Obstruction Over-Jump|Ramp-Jump', 
				'Sprint Key + Move Forward + Crouch = Floor Slide',
				'Sprint Key + Move Forward + Primary Attack [hold all] = Air Hit',
				'Sprint Key + Crouch (in air) = Floor Roll'
			},
			
			[IN_DUCK] = {
				'Crouch + Sprint Key + Move Forward = Floor Slide', 
				'Crouch + Sprint Key (in air) = Floor Roll',
				'Crouch (on pipe) = Drop'
			},
			
			[IN_RELOAD] = {
				'Reload Key + Move Forward = 180 degree turn', 
			},
			
			[IN_USE] = {
				'Use Key (on ledge) = Drop',
				'Use Key + Move Forward + Jump = Wall Climb Rebound (180 turn while climbing)'
			}
		}
		local advices = {}
		local ply = LocalPlayer()
		/*
		if ply:KeyDown( IN_SPEED ) then 
			if !ply:KeyDown( IN_FORWARD ) then table.insert( advices, 'Sprint Key + Move Forward = Obstruction Jump/Skip' ) end
			if !ply:KeyDown( IN_DUCK ) and !ply:KeyDown( IN_JUMP ) then table.insert( advices, 'This key + Move Forward + Crouch [hold all] = Floor Slide' ) end
			if ( ply:KeyDown( IN_FORWARD ) or !ply:KeyDown( IN_SPEED ) or !ply:KeyDown( IN_DUCK ) or ply:IsOnGround() ) and !ply:KeyDown( IN_DUCK ) then table.insert( advices, 'This key + Crouch [hold all|in air] = Floor Roll' ) end
			if ( !ply:KeyDown( IN_ATTACK ) or !ply:KeyDown( IN_SPEED ) or ply:GetMoveType() != MOVETYPE_WALK or ply:IsOnGround() ) and !ply:KeyDown( IN_DUCK ) then table.insert( advices, 'This key + Primary Attack [hold all|in air] = Air Hit' ) end
		end
		
		if ply:GetNWBool( 'ParkourOnEdge' ) then
			table.insert( advices, 'Crouch + Jump + Move Forward [hold Crouch] = Climb' )
			table.insert( advices, 'E = Drop' )
			table.insert( advices, 'Move Left OR Move Right = Side jump' )
			table.insert( advices, 'REMEMBER:' )
			table.insert( advices, 'Then doing Side jump hold Move Forward and Jump keys to "catch" edge' )
		end
		*/
		for i, v in pairs( keys ) do
			if ply:KeyDown( i ) then
				for _, k in pairs( v ) do
					table.insert( advices, k )
				end
			end
		end
		
		surface.SetTextColor( color_white )
		surface.SetFont( 'DermaDefault' )
		for i = 0, #advices do
			surface.SetTextPos( drawPos.x + x + 4, drawPos.y + y + 3 + ( i * 15 ) )
			surface.DrawText( advices[i + 1] or '' )
		end
	end
	
	local function DrawAdrenalineBar( adr, x, y, w, h, isIn )
		if pm_sv_disableadr:GetBool() then return end
		IsAdrenalineBarFull = IsAdrenalineBarFull or false
		OldArenalineState = OldArenalineState or IsAdrenalineBarFull
		AdrenalineAnimation = AdrenalineAnimation or 0
		
		adr = math.Max( adr, 0 )
		
		if adr != 100 then IsAdrenalineBarFull = false else IsAdrenalineBarFull = true end
		
		if OldArenalineState != IsAdrenalineBarFull then
			OldArenalineState = IsAdrenalineBarFull
			AdrenalineAnimation = CurTime() * 5 + 1
		end
		
		if !IsAdrenalineBarFull and ( !isIn or adr == 0 ) then
			surface.SetDrawColor( color_inactive )
			surface.DrawOutlinedRect( drawPos.x + x, drawPos.y + y, w, h )
			
			surface.SetDrawColor( 200, 150, 5, 255 )
			surface.DrawRect( drawPos.x + x + 2, drawPos.y + y + 2, ( w - 4 ) * ( adr / 100 ), h - 4 )
			local mult = ( math.random( -2, 2 ) > 0 ) and 1 or 0.8
			surface.SetDrawColor( 255 * mult, 200 * mult, 5, 255 )
			surface.DrawLine( drawPos.x + x + 2 + ( w - 4 ) * ( adr / 100 ), drawPos.y + y + 2, drawPos.x + x + 2 + ( w - 4 ) * ( adr / 100 ), drawPos.y + y + 2 + h - 4 )
		elseif isIn and adr > 0 then
			local anim = math.Max( AdrenalineAnimation - CurTime() * 5, 0 )
			surface.SetDrawColor( 255, 200, 5, 255 )
			local size = ScrH() / 4
			local x1, y1, w1, h1 = 0, h * 1.1, w, h * 1.1
			surface.DrawOutlinedRect( drawPos.x + x - x1, drawPos.y + y - y1, w + w1, h + h1 )
			surface.SetDrawColor( 255, 200, 5, 255 * math.Max( math.cos( CurTime() * 14 ), 0.5 ) )
			surface.DrawRect( drawPos.x + x + 2 - x1, drawPos.y + y + 2 - y1, ( w - 4 + w1 ) * ( adr / 100 ), h - 4 + h1 )
		elseif IsAdrenalineBarFull then
			local anim = math.Max( AdrenalineAnimation - CurTime() * 5, 0 )
			surface.SetDrawColor( 255, 200, 5, 255 * ( 1 - anim ) )
			surface.DrawRect( drawPos.x + x + 2, drawPos.y + y + 2, ( w - 4 ) * ( adr / 100 ), h - 4 )
			local size = ScrH() / 4
			local x1, y1, w1, h1 = size * anim, size * anim, size * anim * 2, size * anim * 2
			surface.DrawOutlinedRect( drawPos.x + x - x1, drawPos.y + y - y1, w + w1, h + h1 )
		end
	end

	function SWEP:DrawHUD()
		if !pm_drawhud:GetBool() or pm_sv_disablehud:GetBool() then return end
		if pm_hudpos:GetInt() == 0 then drawPos = { x = 25, y = ScrH() - 200 } end
		if pm_hudpos:GetInt() == 1 then drawPos = { x = 25, y = 70 } end
		
		if LocalPlayer():GetNWFloat( 'ParkourAirStabHint' ) > CurTime() then
			local text = 'PRESS |' .. string.upper( input.LookupBinding( '+use' ) ) .. '| TO KILL'
			surface.SetTextColor( 255, 100, 100, 255 )
			surface.SetFont( 'DermaDefaultBold' )
			surface.SetTextPos( ScrW() / 2 - surface.GetTextSize( text ) / 2, ScrH() / 2 + 15 )
			for i, v in pairs( string.Explode( '|', text ) ) do
				if i == 2 then surface.SetTextColor( 255, 0, 0, 255 ) else surface.SetTextColor( 255, 200, 0, 255 ) end
				surface.DrawText( v )
			end
		end
		
		if pm_drawkeys:GetBool() then
			surface.SetDrawColor( 0, 0, 0, 130 )
			surface.DrawRect( drawPos.x, drawPos.y, 250, 65 )
			
			DrawButtonIcon( IN_SPEED, 'Shift', 0, 0, 75, 30 )
			DrawButtonIcon( IN_FORWARD, 'W', 80, 0, 30, 30 )
			DrawButtonIcon( IN_BACK, 'S', 115, 0, 30, 30 )
			DrawButtonIcon( IN_MOVELEFT, 'A', 150, 0, 30, 30 )
			DrawButtonIcon( IN_MOVERIGHT, 'D', 185, 0, 30, 30 )
			DrawButtonIcon( IN_USE, 'E', 220, 0, 30, 30 )
			DrawButtonIcon( IN_DUCK, 'Ctrl', 0, 35, 75, 30 )
			DrawButtonIcon( IN_JUMP, 'Space', 80, 35, 135, 30 )
			DrawButtonIcon( IN_RELOAD, 'R', 220, 35, 30, 30 )
			
			DrawComboString( 0, 70, 250, 20 )
		end
		
		if pm_drawadrenaline:GetBool() then DrawAdrenalineBar( self.Owner:GetNWInt( 'ParkourAdrenaline' ), 0, -25, 250, 20, self.Owner:GetNWBool( 'ParkourInAdrenaline' ) ) end
		if pm_drawadvice:GetBool() then DrawAdvice( 255, -25 ) end
	end
	
	hook.Add( 'RenderScreenspaceEffects', 'DrawAdrenalineEffects', function()
		local ply = LocalPlayer()
		if !ply:IsPlayer() or !IsValid( ply:GetActiveWeapon() ) or IsValid( ply:GetActiveWeapon() ) and ply:GetActiveWeapon():GetClass() != 'parkourmod' then return end
		if !ply:Alive() then return end
		ParkourAdrenalineEffects = ParkourAdrenalineEffects or 0
		
		if !ply:GetNWBool( 'ParkourInAdrenaline' ) or ply:GetNWInt( 'ParkourAdrenaline' ) <= 0 then ParkourAdrenalineEffects = math.Approach( ParkourAdrenalineEffects, 0, FrameTime() * 2 ) end
		if ply:GetNWBool( 'ParkourInAdrenaline' ) and ply:GetNWInt( 'ParkourAdrenaline' ) > 0 then ParkourAdrenalineEffects = math.Approach( ParkourAdrenalineEffects, 1, FrameTime() * 2 ) end
		
		local ppcc = {
			[ "$pp_colour_addr" ] = 0.1 * ParkourAdrenalineEffects, 
			[ "$pp_colour_addg" ] = 0.1 * ParkourAdrenalineEffects, 
			[ "$pp_colour_addb" ] = 0.1 * ParkourAdrenalineEffects, 
			[ "$pp_colour_brightness" ] = 0 * ParkourAdrenalineEffects, 
			[ "$pp_colour_contrast" ] = 1, 
			[ "$pp_colour_colour" ] = 1 + 2 * ParkourAdrenalineEffects, 
			[ "$pp_colour_mulr" ] = 1 * ParkourAdrenalineEffects, 
			[ "$pp_colour_mulg" ] = 1 * ParkourAdrenalineEffects, 
			[ "$pp_colour_mulb" ] = 1 * ParkourAdrenalineEffects
		}
		
		if !pm_disableadrenalinepp:GetBool() then
			DrawBloom( 0.55 + 0.45 * ( 1 - ParkourAdrenalineEffects ), 2, 12, 12, 1, 1, 1, 1, 3 )
			DrawColorModify( ppcc )
		end
		
		if ply:GetVelocity():Length() > 450 and !pm_disablemotionpp:GetBool() then
			DrawMotionBlur( 0.2, 0.35, 0.001 )
		end
	end )
end

function SWEP:CalcViewModelView( vm, pos, ang, _, _ )
	local ply = self.Owner
	if !IsValid( ply ) then return end
	
	if ply:WaterLevel() > 2 then return pos, ang end
	
	if !ply:GetNWBool( 'ParkourRolling' ) then ang.p = math.Clamp( ang.p, -89, 15 ) else ang.p = ang.p - 35 end
	
	if ply:GetNWBool( 'ParkourOnEdge' ) then
		ang.p = 0
		ang.y = ply:GetNWVector( 'ParkourOnEdgeNormal' ):Angle().y - 180
		pos.z = ply:GetNWVector( 'ParkourOnEdgePos' ).z
	end
	
	if ply:GetNWBool( 'PARKOUR_HEADTURN' ) then
		pos.z = EyePos().z - 50
	end
	
	if ply:GetNWBool( 'ParkourOnPipe' ) then
		ang.p = 0
		ang.y = ( ply:GetNWVector( 'ParkourPipePos' ) - ply:GetPos() ):Angle().y
		pos.z = math.Approach( pos.z, ply:GetNWVector( 'ParkourOnPipePos' ).z, 	RealFrameTime() * 50 )
	end
	
	return pos, ang
end

function SWEP:CalcView( ply, pos, ang, fov )
	if GetViewEntity() != ply then return pos, ang, fov end
	if ply:WaterLevel() > 2 then return pos, ang, fov end
	
	ang.p = ( ang.p > 60 and !ply:GetNWBool( 'ParkourRolling' ) ) and 60 or ang.p
	if ply:GetNWBool( 'ParkourOnEdge' ) then
		local normal = ply:GetNWVector( 'ParkourOnEdgeNormal' )
		local cosine = math.abs( math.cos( math.rad( math.Remap( ang.y + normal:Angle().y + 90, -180, 180, 0, 360 ) ) ) )
		ang.p = math.Clamp( ang.p, -90, 15 - cosine * 15 )
		local zTarget = ply:GetNWVector( 'ParkourOnEdgePos' ).z
		ply.OnEdgeZPos = ply.OnEdgeZPos or pos.z
		ply.OnEdgeZPos = zTarget
		pos.z = zTarget
	elseif ply:GetNWBool( 'ParkourOnPipe' ) then
		local normal = ( ply:GetNWVector( 'ParkourPipePos' ) - ply:GetPos() ):Angle().y
		local cosine = math.abs( math.cos( math.rad( math.Remap( ang.y + normal + 90, -180, 180, 0, 360 ) ) ) )
		ang.p = math.Clamp( ang.p, -90, 15 - cosine * 15 )
	else
		ply.OnEdgeZPos = pos.z
	end
	
	if ply:GetNWBool( 'PARKOUR_HEADTURN' ) and ply.HeadTurn != 145 then
		ply.HeadTurn = ply.HeadTurn or 0
		ply.HeadTurn = math.Approach( ply.HeadTurn, 145, RealFrameTime() * 500 )
	elseif !ply:GetNWBool( 'PARKOUR_HEADTURN' ) and ply.HeadTurn != 0 then
		ply.HeadTurn = ply.HeadTurn or 0
		ply.HeadTurn = math.Approach( ply.HeadTurn, 0, RealFrameTime() * 500 )
	end
	
	if ply.HeadTurn and ply.HeadTurn > 0 then
		ang.y = ang.y + ply.HeadTurn
	end
	
	return pos, ang, fov
end

hook.Add( 'EntityTakeDamage', 'ScaleRollingDamage', function( ent, dmg )
	if !ent:IsPlayer() or !IsValid( ent:GetActiveWeapon() ) or IsValid( ent:GetActiveWeapon() ) and ent:GetActiveWeapon():GetClass() != 'parkourmod' then return end
	ent.LastDealedDamage = CurTime() + 1.2
	ent.Adrenaline = ent.Adrenaline + 0.4
	if dmg:GetDamageType() == 32 and ( ent:IsPlayer() ) then
		if IsValid( ent:GetGroundEntity() ) and ( ent:GetGroundEntity():GetModel() == 'models/props_gameplay/haybale.mdl' or ent:GetGroundEntity():GetModel() == 'models/props_junk/wood_pallet001a.mdl' ) then dmg:SetDamage( 0 ) return false end
		if ent:GetGroundEntity():IsPlayer() or ent:GetGroundEntity():IsNPC() then if ent:GetGroundEntity():GetMoveType() == MOVETYPE_NOCLIP then dmg:SetDamage( dmg:GetDamage() * 60 ) return end ent:GetGroundEntity():TakeDamage( dmg:GetDamage(), ent, ent ) dmg:SetDamage( 0 ) return false end
		ent:ViewPunch( Angle( dmg:GetDamage(), 0, 0 ) )
		if ent:GetVelocity():Length() > 1400 then dmg:SetDamage( dmg:GetDamage() * 10 ) ent:EmitSound( 'parkourmod/die_body_break_0' .. math.random( 1, 3 ) .. '.wav', 75, 100 ) end
		if ent.ParkourRolling then
			dmg:SetDamage( math.Clamp( ent:GetVelocity():Length() / 3000, 0, 1 ) * 60 )
		else
			ent:EmitSound( 'parkourmod/floorslide_hit_hard' .. math.random( 1, 4 ) .. '.wav', 75, 100 )
			dmg:SetDamage( math.Clamp( ent:GetVelocity():Length() / 1800, 0, 1 ) * 100 )
		end
	end
end )

hook.Add( 'PlayerDeath', 'RemoveOneLifeVars', function( ply )
	if ply.ParkourInAdrenaline and SERVER then game.SetTimeScale( 1 ) end
	ply.Adrenaline = 0
	ply.ParkourInAdrenaline = false
	ply:SetNWInt( 'ParkourAdrenaline', 0 )
	ply:SetNWBool( 'ParkourInAdrenaline', false )
end )

if CLIENT then
	concommand.Add( 'pm_openbugreport', function()
		gui.OpenURL( 'http://steamcommunity.com/workshop/filedetails/discussion/410645074/618456760267154983/' )
	end )
	concommand.Add( 'pm_opentutorial', function()
		gui.OpenURL( 'http://steamcommunity.com/sharedfiles/filedetails/?id=413285922' )
	end )
	
	language.Add( "parkourmod", "Parkour Trick" )
	killicon.Add( 'parkourmod', 'hud/parkourmod_killicon', color_white )
	
	local cv = { 'pm_disableadrenalinepp', 'pm_disablemotionpp', 'pm_drawadrenaline', 'pm_drawadvice', 'pm_drawhud', 'pm_drawkeys', 'pm_sv_disableturn' }
	local def = { pm_disableadrenalinepp = 0, pm_disablemotionpp = 0, pm_drawadrenaline = 1, pm_drawadvice = 1, pm_drawhud = 1, pm_drawkeys = 1, pm_sv_disableturn = 0 }

	local function CreateConfigurationMenu( f )
		f:AddControl( 'ComboBox', {
			Options = { ['default'] = def },
			CVars = cv,
			Label = '',
			MenuButton = '1',
			Folder = 'parkourmod'
		} ) 
		
		f:AddControl( 'Label', {
			Text = 'Just download and don\'t know how it works? Read tutorial!' } )
			
		f:AddControl( 'Button', {
			Label = 'Open Tutorial',
			Command = 'pm_opentutorial' } )
		
		f:AddControl( 'CheckBox', {
			Label = 'Draw HUD',
			Command = 'pm_drawhud', } )
			
		f:AddControl( 'CheckBox', {
			Label = 'Disable Adrenaline Post-Processing',
			Command = 'pm_disableadrenalinepp', } )
			
		f:AddControl( 'CheckBox', {
			Label = 'Disable Motion Blur',
			Command = 'pm_disablemotionpp', } )
			
		f:AddControl( 'CheckBox', {
			Label = 'Draw Adrenaline Bar',
			Command = 'pm_drawadrenaline', } )
			
		f:AddControl( 'CheckBox', {
			Label = 'Draw Advices',
			Command = 'pm_drawadvice', } )
			
		f:AddControl( 'CheckBox', {
			Label = 'Draw Keys',
			Command = 'pm_drawkeys', } )
			
		f:AddControl( 'CheckBox', {
			Label = 'Enable View Bob',
			Command = 'pm_viewbob', } )
			
		f:AddControl( 'Slider', {
			Label = 'HUD Orientation',
			Command = 'pm_hudpos',
			Type = 'Integer',
			Min = "0",
			Max = "1", } )
			
		f:AddControl( 'Label', {
			Text = 'Next controls is only for SERVER usage. Only admin with full permissions may override this options.' } )
			
		f:AddControl( 'CheckBox', {
			Label = 'Disable Adrenaline Mod',
			Command = 'pm_sv_disableadr', } )
			
		f:AddControl( 'CheckBox', {
			Label = 'Override HUD (disable on all clients)',
			Command = 'pm_sv_disablehud', } )
			
		f:AddControl( 'CheckBox', {
			Label = 'Disable Head Turn',
			Command = 'pm_sv_disableturn', } )
			
		f:AddControl( 'CheckBox', {
			Label = 'Disable Door Bust',
			Command = 'pm_sv_disabledoorbust', } )
			
		f:AddControl( 'CheckBox', {
			Label = 'Disable Stabing',
			Command = 'pm_sv_disablestabing', } )
			
		f:AddControl( 'CheckBox', {
			Label = 'Disable Health Regeneration',
			Command = 'pm_sv_disablehealthregen', } )
			
		f:AddControl( 'Slider', {
			Label = 'Maximum Movement Speed',
			Command = 'pm_sv_maxspeed',
			Type = 'Integer',
			Min = "250",
			Max = "500", } )
			
		f:AddControl( 'Slider', {
			Label = 'Maximum Jump Height',
			Command = 'pm_sv_maxjump',
			Type = 'Integer',
			Min = "100",
			Max = "650", } )
			
		f:AddControl( 'Slider', {
			Label = 'Wall Climb Velocity',
			Command = 'pm_sv_climbvel',
			Type = 'Integer',
			Min = "0",
			Max = "300", } )
		
		f:AddControl( 'Slider', {
			Label = 'Air Stab Distance',
			Command = 'pm_sv_maxastabdist',
			Type = 'Integer',
			Min = "200",
			Max = "1000", } )
			
		f:AddControl( 'Label', {
			Text = 'Discovered a bug or script error? Report it to Bug Report thread!' } )
			
		f:AddControl( 'Button', {
			Label = 'Report Bug',
			Command = 'pm_openbugreport' } )
	end
	
	function OnPopulateToolMenu()
		spawnmenu.AddToolMenuOption( 'Options', 'Player', 'ParkourModSettings', 'Parkour Mod', '', '', CreateConfigurationMenu, { SwitchConVar = 'pm_drawhud' } )
	end

	hook.Add( 'PopulateToolMenu', 'CreateParkourConfigurationMenu', OnPopulateToolMenu )
end

hook.Add( 'ShutDown', 'ResetParkour', function()
	for _, ply in pairs( player.GetAll() ) do
		if !IsValid( ply ) then return end
		ply.NextOBSJump = 0
		ply.OBSJumpMode = 0
		ply.LastDealedDamage = 0
		ply.HealthRegenValue = 0
		ply.NextHealthRegen = 0
		ply.NextLegHit = 0
		ply.AirStabAnimTimer = 0
		ply.NextSwimmingSound = 0
		ply.ParkourPlayingStabAnim = 0
	end
	
	for _, wep in pairs( ents.FindByClass( 'parkourmod' ) ) do
		if IsValid( wep ) then wep:Remove() end
	end
end )