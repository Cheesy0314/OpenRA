InitialTeam = {}
Reinforcements = {}
ScienceTeam = {}
AlliedForces = {}
SovietForces = {}
Infected = {}

SendHorde = function()

end

FoundScienceTeam = function()

end

AlliesTurn = function()

end

Win = function()

end

Lose = function() 

end

InitNeeful = function()

end

WorldLoaded = function()
        Spain = Player.GetPlayer("Spain")
        Germany = Player.GetPlayer("Germany")
        Zombies = Player.GetPlayer("BadGuy")
        Civilian = Player.GetPlayer("Civilians")
	SovietForces = Player.GetPlayer("Soviet")
        InitNeedful()

end
