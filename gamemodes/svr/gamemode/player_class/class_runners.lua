local CLASS = {}

CLASS.DisplayName			= "Runner"
CLASS.WalkSpeed 			= 275
CLASS.RunSpeed				= 300
CLASS.JumpPower				= 250
CLASS.DrawTeamRing			= true
CLASS.TeammateNoCollide 	= true
CLASS.AvoidPlayers			= false
CLASS.DropWeaponOnDie		= true

function CLASS:OnSpawn( pl )
	pl:StripWeapons() -- Super cheap double check if the player still has their weapons from last round
end

function CLASS:OnDeath( pl, attacker, dmginfo )
		pl:SetTeam(2)
		pl:Give("weapon_cs_awp")
		//pl:ChatPrint("You've become a Sniper!") Commenting out because we handle this in the timer now
		pl:Spawn()
		
		if attacker:IsPlayer() and SVR.PointsPerKill then
			attacker:PS_GivePoints(SVR.PointsGivenPerKill)
			attacker:ChatPrint("You killed a Runner and got "..SVR.PointsGivenPerKill.." points for it.")
		end
end

function CLASS:Loadout( pl )
end


player_class.Register( "Runner", CLASS )