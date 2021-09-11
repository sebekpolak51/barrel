if SERVER then
    util.AddNetworkString( "PhaseData" )
end

GM.Phases = {
    [ "Waiting" ] = {
        --time = 60,
        time = 10,
        OnEnd = function()
            GAMEMODE:StartPhase( "Round" )

            local barrelSpawner = ents.FindByClass( "func_barrels" )[ 1 ]

            if not barrelSpawner then
                print( "Couldn't find barrel spawner!" )
                return
            end

            GAMEMODE.BarrelSpawner = barrelSpawner

            barrelSpawner:StartShootingBarrels()
        end
    },

    [ "Round" ] = {
        time = 60 * 2,
        OnEnd = function()
            GAMEMODE:StartPhase( "Round Ended" )

            if GAMEMODE.barrelSpawner then
                GAMEMODE.BarrelSpawner:StopShootingBarrels()
            end
        end
    },

    [ "Round Ended" ] = {
        time = 5,
        OnEnd = function()
            if SERVER then
                RunConsoleCommand( "changelevel", game.GetMap() )
            end
        end
    }
}
GM.Phase = {
    Name = "?",
    Time = 0
}

local function EndPhase( name )
    local phase = GAMEMODE.Phases[ name ]
    if phase then
        phase.OnEnd()
    end
end

local function NewPhase( name, time )
    print( name .. " initialized" )

    local phaseTime = time
    timer.Create( name .. "_timer", 1, time, function()
        phaseTime = phaseTime - 1
        GAMEMODE.Phase.Time = phaseTime
        if phaseTime == 0 then
            EndPhase( name )
        end
    end )
end

function GM:StartPhase( name, timeOverride )
    local phaseProperties = self.Phases[ name ]
    local phaseTime = timeOverride or phaseProperties.time

    self.Phase.Name = name
    self.Phase.Time = phaseTime

    NewPhase( name, phaseTime )
end

if SERVER then
    local roundStarted = false
    hook.Add( "PlayerInitialSpawn", "StartRound", function( ply )
        if not roundStarted then
            roundStarted = true

            GAMEMODE:StartPhase( "Waiting" )
        end

        -- send phase data
        net.Start( "PhaseData" )
        net.WriteString( GAMEMODE.Phase.Name )
        net.WriteUInt( GAMEMODE.Phase.Time, 16 )
        net.Send( ply )
    end )

    hook.Add( "PlayerDeath", "EndRound", function( ply )
        if GAMEMODE.Phase.Name != "Round" then return end

        for _, ply in pairs( team.GetPlayers( 1 ) ) do
            if ply:Alive() then return end
        end

        if ply:Team() == 1 then
            GAMEMODE:StartPhase( "Round Ended" )
        end
    end )
else -- CLIENT
    net.Receive( "PhaseData", function( len )
        local name = net.ReadString()
        local timeLeft = net.ReadUInt( 16 )

        GAMEMODE:StartPhase( name, timeLeft )
    end )
    
    local function ScreenX( arg )
        return arg * ScrW() / 1920
    end

    local function ScreenY( arg )
        return arg * ScrH() / 1080
    end

    surface.CreateFont( "BarrelHUD", {
        font = "Arial",
        size = ScreenY( 36 )
    })

    local COLOR_WHITE = Color( 255, 255, 255 )
    local COLOR_BLUE = Color( 0, 0, 255 )

    hook.Add( "HUDPaint", "DrawRoundState", function()
        -- Time
        local minutes = math.floor( GAMEMODE.Phase.Time / 60 )
        local seconds = GAMEMODE.Phase.Time % 60
        draw.DrawText( GAMEMODE.Phase.Name .. " - " .. minutes .. ":" .. ( seconds > 9 and seconds or "0" .. seconds ), "BarrelHUD", ScrW() / 2, ScreenY( 50 ), COLOR_WHITE, TEXT_ALIGN_CENTER )
    
        -- Players
        local players = team.GetPlayers( 1 )
        local nicks = ""

        for i = 1, #players do
            local ply = players[ i ]

            if ply:Alive() then
                nicks = nicks .. ply:Nick() .. "\n"
            end
        end

        draw.DrawText( nicks, "BarrelHUD", ScreenX( 100 ), ScreenY( 50 ), COLOR_BLUE )
    end )
end