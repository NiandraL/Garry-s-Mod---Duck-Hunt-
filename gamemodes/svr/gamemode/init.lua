AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "sh_config.lua" )
AddCSLuaFile( "shared.lua" )

/*
While everything here should function correctly, a lot of the code is somewhat messy and I do apologise. I have however
written some comments to go along side this, which kinda explain why it's bad
*/

include( "shared.lua" )
include( "sh_config.lua" )

function GM:CanStartRound()
	if #team.GetPlayers( TEAM_RUNNER ) + #team.GetPlayers( TEAM_SNIPER ) >= 2 then return true end
	return false
end

function GM:OnPreRoundStart( num )
	game.CleanUpMap()
	
	UTIL_SpawnAllPlayers()
	UTIL_FreezeAllPlayers()
end

/* Multiple k, v pairs statements is bad, but fretta doesn't accept ply/pl on pre-round start functions and since players'll be
respawning at different times in the round (i.e preround, round start, when they're killed, etc) and we don't want chatprint to
post twice because that looks messy as fuck. Also I fucking hate that RoundStartTime + Curtime stuff and struggled to get my 
head around it, but I should probably re-write this to use that system
*/

function GM:OnRoundStart( num )
	UTIL_UnFreezeAllPlayers()
	
	for k, v in pairs(player.GetAll()) do -- I know this is icky, but it prevents it from printing twice
		v:ChatPrint("You're playing Duck Hunt, v1.3. Press F1 for information.")
		v:ChatPrint("Runners have 5 seconds of spawn protection!")
	end
	
	for k, v in pairs(player.GetAll()) do 
		if v:Team() == TEAM_RUNNER then 
			v:GodEnable()
		end
		timer.Simple(5, function()
			v:GodDisable() 
			v:ChatPrint("God-mode disabled!")
		end) 
	end	
end	

function GM:ResetTeams( )
	for k, v in pairs( team.GetPlayers( TEAM_SNIPER ) ) do
		v:SetTeam( TEAM_RUNNER )
		v:KillSilent()
	end
end

function GM:CheckRoundEnd()

	if ( !GAMEMODE:InRound() ) then return end

	if( team.NumPlayers( TEAM_RUNNER ) == 0 and team.NumPlayers( TEAM_SNIPER ) > 0 ) then
		BroadcastLua([[sound.Play("radio/terwin.wav",LocalPlayer():GetPos())]]) -- TERRORISTS WIN
		GAMEMODE:RoundEndWithResult( TEAM_SNIPER )
		
		GAMEMODE:ResetTeams()
	end
end

function GM:RoundTimerEnd()
	if (!GAMEMODE:InRound()) then return end
	
	GAMEMODE:RoundEndWithResult( 1001, "Time's up! No one wins this round." )
	GAMEMODE:ResetTeams()
	BroadcastLua([[sound.Play("radio/rounddraw.wav",LocalPlayer():GetPos())]])
end

/* Instead of doing what I did on Pictionary Box, i.e randomly pick someone on round start, I looked at the code for
Suicide Barrels and recreated that. Instead, we choose on player-spawn instead!
*/

function GM:PlayerSpawn( ply )
	
	self.BaseClass:PlayerSpawn(ply)
	
	if team.NumPlayers( TEAM_RUNNER ) >= 2 and team.NumPlayers( TEAM_SNIPER ) < 1 then
		local StartingSniper = table.Random( team.GetPlayers( TEAM_RUNNER ) )
		StartingSniper:SetTeam( TEAM_SNIPER )
		StartingSniper:KillSilent()
		StartingSniper:Spawn()
		StartingSniper:Give( SVR.DeathsWeapon )
	end
	
end

/*This code has been a fuckin pain to get right. Basically, the idea is that if there's no players on team runners, 
then we know to end the round and give credit to the snipers but obviously if people join late to the game then it would bork
since they'll join team runners but not be alive. If we choose them to spawn on team sniper if they join during the round then
what happens is that on the first round after map change, it ends up becoming 1 runner versus a million snipers, which while very
funny isn't really the intention!

If I chose to check if players were alive and end the round if no one was alive on team_runner then the GAMEMODE:ResetTeam()
WOULDN'T RUN PROPERLY AND I DIDN'T WANT TO DO ANOTHER K, V PAIRS STATEMENT AHHHHH

After looking at Fretta's round_controlller.lua file, we found out how to get the round time!
*/

function GM:PlayerJoinTeam(ply, teamid) 
	if (!GAMEMODE:InRound()) and ply:Team() == TEAM_UNASSIGNED and teamid == TEAM_RUNNER then 
		ply:SetTeam(1)
	end
	
	if (ply:Team() == TEAM_UNASSIGNED or TEAM_SPECTATOR) and ( GAMEMODE:InRound() ) and GetGlobalFloat("RoundStartTime",CurTime()) + 30 < CurTime() and teamid == TEAM_RUNNER then
		ply:SetTeam(2)
		ply:KillSilent() 
		ply:Spawn()
		ply:SetPlayerClass( "Sniper" )
		ply:Give( SVR.DeathsWeapon )	
		ply:ChatPrint("You've become a Sniper!")
	elseif (ply:Team() == TEAM_UNASSIGNED or TEAM_SPECTATOR) and ( GAMEMODE:InRound() ) and teamid == TEAM_RUNNER then
		ply:SetTeam(1)
		ply:Spawn()
		ply:SetPlayerClass( "Runner" )
	end
	
	if ply:Team() != TEAM_SPECTATOR and teamid == TEAM_SPECTATOR then
		ply:SetTeam(TEAM_SPECTATOR)
		ply:KillSilent()
	end	
end

/*
Technically, TEAM_RUNNER can never win this way, since they win by hitting the white patch and not by killing Snipers.
Because of this, I originally had the text be something like 'Something's gone wrong! All the snipers died??' but then I realized
That's a bit silly and players might find suitable maps where there's guns at the end or something (or I might do something like 
that myself in future) so I thought let's make it work!s
*/

function GM:ProcessResultText( result, resulttext )
	if ( resulttext == nil ) then resulttext = "" end
	
	if ( result == TEAM_RUNNER ) then
		resulttext = "All snipers are dead! The Runners win."
		GAMEMODE:ResetTeams()
	elseif ( result == TEAM_SNIPER ) then 
		resulttext = "All the Runners are dead! Snipers win."
		GAMEMODE:ResetTeams()
	end
	
	return resulttext
end

/* Ugh this is such a horrible way to things I'm so sorry. Basically, I couldn't get the respawning system to work via other
methods. Like it would give them the weapon and do the ChatPrint fine, but just not them. So instead, I gave up and a wrote this
timer to check every 2 seconds to respawn them. Actually wait, it did work on PlayerDeath/class, if I put it inside a timer but
then it would break fretta stuff and not give any errors (CUZ FRETTA SURE LOVES TO DO THAT!!). For some reason, it would end the
round fine, but not restart it properly, even if I placed in my own RoundEndWithResult checks. Because of this, I gave up and 
wrote a hacky work around. 
*/

timer.Create( "RespawnTheHumansAsSnipers", 2, 0, function() 
    for k, ply in pairs( player.GetAll() ) do 
		if (GAMEMODE:InRound()) and !ply:Alive() and ply:Team() == TEAM_SNIPER then
		ply:Spawn()
		ply:Give( SVR.DeathsWeapon )
		ply:ChatPrint("You've become a Sniper!") 
		end 
	end 
end) 