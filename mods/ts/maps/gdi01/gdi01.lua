BaseIsBuilt = false
ticks = 0

SendReinforcements = function()
	Reinforcements.ReinforceWithTransport(GDI, 'dshp', {'e1','e1','e1','e1','e1','e2','e2'}, {CPos.New(44,10), Landing.Location},{Landing.Location, CPos.New(44,10)})
end

SendEnemies = function()
	Reinforcements.ReinforceWithTransport(Nod, 'sapc', {'e1', 'e1', 'e1', 'e1'}, {CPos.New(44,1), CPos.New(50,17)}, {CPos.New(44,1)})
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
	local unitCount = #Nod.GetActors()
	if unitCount == 0 then
		GDI.MarkCompletedObjective(KillEnemy)
	end
end

WorldLoaded = function()
	GDI = Player.GetPlayer("GDI")
	Nod = Player.GetPlayer("Nod")
	InitObjectives()
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
