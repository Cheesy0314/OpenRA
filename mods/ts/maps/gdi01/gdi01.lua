BaseIsBuilt = false
SendWaves = true
ticks = 0
NodInfAttack = { };
ValidForces = { 'e1', 'e3', 'cyborg', 'nahand', 'napower', 'buggy' }

SendReinforcements = function()
	Reinforcements.ReinforceWithTransport(GDI, 'dshp', {'e1','e1','e1','e1','e1','e2','e2'}, {CPos.New(44,10), Landing.Location},{Landing.Location, CPos.New(44,10)})
end

SendEnemies = function()
	Reinforcements.ReinforceWithTransport(Nod, 'sapc', {'cyborg', 'e1', 'e1', 'e1'}, {CPos.New(44,1), CPos.New(50,17)}, {CPos.New(44,1)})
end

BuildInfantry = function()
	if NodHand.IsDead or not SendWaves then
		return
	end

	local delay = Utils.RandomInteger(DateTime.Seconds(3), DateTime.Seconds(9))
	local toBuild = { 'e1','e1','e1','e3','e3' }
	Nod.Build(toBuild, function(unit)
		NodInfAttack[#NodInfAttack + 1] = unit[1]
		if #NodInfAttack >= 5 then
			SendUnits(NodInfAttack, {CPos.New(44,1)})
			NodInfAttack = { }
			--Trigger.AfterDelay(DateTime.Minutes(2), BuildInfantry)
		else
			--Trigger.AfterDelay(delay, BuildInfantry)
		end
	end)
end

SendUnits = function(units, waypoints)
	Utils.Do(units, function(unit)
		if not unit.IsDead then
			Utils.Do(waypoints, function(waypoint)
				unit.AttackMove(waypoint.Location)
			end)
			Trigger.OnIdle(unit, function() unit.Hunt() end)
		end
	end)
	SendWaves = false
end

InitObjectives = function()
	BuildBase = GDI.AddPrimaryObjective("Build Base")
	KillEnemy = GDI.AddPrimaryObjective("Destroy All Nod Forces")
	SendReinforcements()
end

CheckBaseRequirements = function()
	local barr = #GDI.GetActorsByType("gapile")
	local refinery = #GDI.GetActorsByType("proc")

	if barr > 0 and refinery > 0 then
		GDI.MarkCompletedObjective(BuildBase)
		BaseIsBuilt = true
	end
end

CheckEnemyUnitsRemaining = function()
	local unitCount = 0
	Utils.Do(validForces, function(actor) 
		unitCount = unitCount + #Nod.GetActorsByType(actor)
	end)

	if unitCount == 0 then
		GDI.MarkCompletedObjective(KillEnemy)
	end
end

WorldLoaded = function()
	GDI = Player.GetPlayer("GDI")
	Nod = Player.GetPlayer("Nod")
	InitObjectives()
	if SendWaves then
		BuildInfantry()
	end
end

Tick = function()
	if ticks > 25 then
		if not BaseIsBuilt then
			CheckBaseRequirements()
			if ticks % DateTime.Seconds(60) == 0 then 
				SendEnemies()
			end
		else 
			CheckEnemyUnitsRemaining()
		end
	end

	ticks = ticks + 1

end
