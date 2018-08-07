BaseIsBuilt = false
SendWaves = true
ticks = 0
NodInfAttack = { }
ValidForces = { 'e1', 'e3', 'cyborg', 'nahand', 'napowr', 'bggy' }
startCounting = false

SendReinforcements = function()
	Trigger.AfterDelay(DateTime.Seconds(5), function()
		Media.PlaySpeechNotification(GDI, 'ReinforcementsArrived')
		Reinforcements.ReinforceWithTransport(GDI, 'dshp', {'e1','e1','e1','e1','e1','e2','e2'}, {CPos.New(27,5), Landing.Location},{Landing.Location, CPos.New(27,5)})
		Trigger.AfterDelay(25, function() startCounting = true end)
	end)
end

SendEnemies = function()
	local TransAndSoldiers = Reinforcements.ReinforceWithTransport(Nod, 'sapc', {'cyborg', 'e1', 'e1', 'e1'}, {CPos.New(52,-19), CPos.New(50,17)}, {CPos.New(52,-19)})
	local troops = TransAndSoldiers[2]
	Utils.Do(troops, function(soldier)
		Trigger.OnIdle(soldier, function() soldier.Hunt() end)
	end)
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
	Trigger.AfterDelay(DateTime.Seconds(18), function()
		Media.PlaySpeechNotification(GDI, 'BuildABarracks')
	end)

	Trigger.AfterDelay(DateTime.Seconds(25), function()
		Media.PlaySpeechNotification(GDI, 'BuildATiberiumRefineryToHarvestTiberium')
	end)
	Trigger.AfterDelay(DateTime.Seconds(3), function()
		Media.PlaySpeechNotification(GDI, 'WhereTheHellAreThoseReinforcements');
		SendReinforcements()
	end)
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
	Utils.Do(ValidForces, function(actorType)
		unitCount = unitCount + #Nod.GetActorsByType(actorType)
	end)

	if unitCount == 0 then
		Media.PlaySpeechNotification(GDI, 'SiteSecureObjectiveComplete')
		GDI.MarkCompletedObjective(KillEnemy)
	end
end

InitSpeechTriggers = function()
	Trigger.OnPlayerWon(GDI, function()
		Trigger.AfterDelay(DateTime.Seconds(2), function() Media.PlaySpeechNotification(GDI, 'CongratulationsOnYourSuccess') end)
	end)

end

WorldLoaded = function()
	GDI = Player.GetPlayer("GDI")
	Nod = Player.GetPlayer("Nod")
	InitSpeechTriggers()
	InitObjectives()
	if SendWaves and startCounting then
		BuildInfantry()
	end
end

Tick = function()
	if startCounting then
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
end
