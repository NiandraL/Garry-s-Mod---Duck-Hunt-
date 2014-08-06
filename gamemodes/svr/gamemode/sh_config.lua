print("Config file loaded!")
SVR = {}

//Rewards
SVR.PointShopMode = false -- If you don't plan to use _Undefined's Pointshop, then return false and the players will be rewarded frags/in-game points for winning, as opposed to Pointshop points.

//Death's points
SVR.PointsPerKill = false -- Should Death's receive points for every individual kill? Pointshop mode only!
SVR.PointsGivenPerKill = "1" -- How many Pointshop points should Death recieve for each kill?

//Runner's points
SVR.FirstRunnersPoints = "20" -- How many points should the runner who gets across the finish line get?
SVR.OtherRunnersPoints = "5" -- How many points should all the other runners still alive get?

//Misc
SVR.AddToDeaths = true -- When runners die, should they then be placed on Death's team? (Returning false will probably break shit actually)
SVR.DeathsWeapon = "weapon_cs_awp" -- Folder name of the swep you want Death to have. Change this if you have a different sniper in mind
--When I first started working on this, I was calling Snipers 'Death'but changed it so it's not so Deathrun-y. 