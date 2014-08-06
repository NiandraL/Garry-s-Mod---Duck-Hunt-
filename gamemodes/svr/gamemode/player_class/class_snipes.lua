local CLASS = {}

CLASS.DisplayName			= "Sniper"
CLASS.WalkSpeed 			= 300
CLASS.RunSpeed				= 425
CLASS.JumpPower				= 200
CLASS.DrawTeamRing			= true
CLASS.TeammateNoCollide 	= true
CLASS.AvoidPlayers			= false
CLASS.DropWeaponOnDie		= false

function CLASS:OnSpawn( pl )
end

function CLASS:Loadout( pl )
	//pl:Give( "weapon_cs_awp" ) -- We don't need to do this anymore as it's handled in init.lua
end

function CLASS:OnDeath( pl )
end

player_class.Register( "Sniper", CLASS )