DeriveGamemode( "fretta13" )
IncludePlayerClasses()	

GM.Name 	= "Duck Hunt"
GM.Author 	= "Niandra Lades"
GM.Email 	= "niandraletur@gmail.com"
GM.Website 	= "empyreangaming.co.uk"
GM.Help		= "One team are snipers, while the others are runners who must reach the white patch at the end of each map to win. When the runners die, they become snipers and will lose if all are wiped out before reaching the finish line."


GM.TeamBased = true				
GM.AllowAutoTeam = true 
GM.AllowSpectating = true			
GM.SecondsBetweenTeamSwitches = 0	

GM.GameLength = 15			
GM.RoundLimit = 5
GM.RoundLength = 60 * 3						
GM.VotingDelay = 5		

GM.NoAutomaticSpawning = true	
GM.RoundBased = true				
GM.RoundPreStartTime = 5			
GM.RoundPostLength = 4		
GM.RoundEndsWhenOneTeamAlive = true		

GM.NoPlayerSuicide = true
GM.NoPlayerDamage = false			
GM.NoPlayerSelfDamage = false		
GM.NoPlayerTeamDamage = true		
GM.NoPlayerPlayerDamage = false 	
GM.NoNonPlayerPlayerDamage = false 	
GM.NoPlayerFootsteps = false		
GM.PlayerCanNoClip = false			

GM.MaximumDeathLength = 0
GM.MinimumDeathLength = 0			
GM.AutomaticTeamBalance = false     
GM.ForceJoinBalancedTeams = false	
GM.RealisticFallDamage = false		
GM.AddFragsToTeamScore = true
GM.TakeFragOnSuicide = false	

GM.SelectModel = true // I always thought this was broken but apparently I just wasn't doing it right
GM.SelectColor = true // idk if this works, I think this might geninuely be broken

GM.ValidSpectatorModes = { OBS_MODE_CHASE, OBS_MODE_IN_EYE }
GM.ValidSpectatorEntities = { "player" }	
GM.CanOnlySpectateOwnTeam = false

TEAM_RUNNER = 1
TEAM_SNIPER = 2

function GM:CreateTeams()  	
    team.SetUp( TEAM_RUNNER, "The Runners", Color( 52, 152, 219 ), true )  
    team.SetSpawnPoint( TEAM_RUNNER, { "info_player_counterterrorist", "info_player_rebel" } )  
    team.SetClass( TEAM_RUNNER, { "Runner" } )
	
    team.SetUp( TEAM_SNIPER, "The Snipers", Color( 231, 76, 60 ), false )
    team.SetSpawnPoint( TEAM_SNIPER, { "info_player_terrorist", "info_player_combine" } )
    team.SetClass( TEAM_SNIPER, { "Sniper" } ) 
	
    team.SetUp( TEAM_SPECTATOR, "Spectators", Color( 200, 200, 200 ), true )  
    team.SetSpawnPoint( TEAM_SPECTATOR, { "info_player_start", "info_player_terrorist", "info_player_counterterrorist" } )
end

if CLIENT then
    function GM:OnEntityCreated( ent )
       	if LocalPlayer() == ent then
            ent:SetCustomCollisionCheck(true)
	end
    end
end

hook.Add("PlayerInitialSpawn","CollideCheck",function(ply)
	ply:SetCustomCollisionCheck(true)
end)

hook.Add( "ShouldCollide", "CollideCheck2", function(ent1,ent2) -- I originally wrote this but Panda rewrote it
		if ( ent1:IsPlayer() and ent2:IsPlayer() and ent1:Team() == ent2:Team() ) then // that was correct, but this is nicer :)
			return false
		end
end)
