GM.Name = "Barrel Gamemode"
GM.Author = "fiveone"

include( "sh_config.lua" )
include( "sh_round.lua" )

team.SetUp( 1, "Players", Color( 0, 0, 255 ) )
team.SetUp( 2, "Spectators", Color( 255, 255, 255 ) )

function GM:Initialize()
    self.BaseClass:Initialize()
end