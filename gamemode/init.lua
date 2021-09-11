include( "shared.lua" )

AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "sh_config.lua" )
AddCSLuaFile( "sh_round.lua" )

function GM:PlayerInitialSpawn( ply )
end

function GM:PlayerSpawn( ply )
    if GAMEMODE.Phase.Name != "Waiting" then
        ply:SetTeam( 2 )
        ply:SetRenderMode( RENDERMODE_NONE )
        ply:SetMoveType( MOVETYPE_NOCLIP )
        ply:SetCollisionGroup( COLLISION_GROUP_NONE )
    else
        ply:SetTeam( 1 )
        ply:SetRenderMode( RENDERMODE_NORMAL )
        ply:SetHealth( self.Config.Health )
    end

    ply:SetModel( self.Config.Model )
end

function GM:PlayerNoClip( ply, desiredState )
    return false
end

function GM:PlayerShouldTakeDamage( ply, attacker )
    return ply:Team() == 1
end

function GM:AllowPlayerPickup( ply, ent )
    return ply:Team() == 1
end