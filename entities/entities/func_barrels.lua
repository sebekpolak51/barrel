AddCSLuaFile()

ENT.Base = "base_brush"

ENT.ShootingBarrels = false

function ENT:Initialize()
end

function ENT:StartShootingBarrels()
    if self.ShootingBarrels then return end

    self.ShootingBarrels = true

    local mins = self:OBBMins()
    local maxs = self:OBBMaxs()

    timer.Create( self:EntIndex() .. "_timer", 0.1, 0, function()
        -- Shoot a barrel

        local barrel = ents.Create( "prop_physics" )
        barrel:SetModel( "models/props_c17/oildrum001_explosive.mdl" )
        barrel:SetPos( Vector( math.random( mins.x, maxs.x ), math.random( mins.y, maxs.y ), math.random( mins.z, maxs.z ) ) )
        barrel:Spawn()
        barrel:PhysWake()
        barrel:SetVelocity( Vector( 0, 0, -6000 ) )
        barrel:Ignite( 20 )
    end )
end

function ENT:StopShootingBarrels()
    self.ShootingBarrels = false
    timer.Remove( self:EntIndex() .. "_timer" )
end