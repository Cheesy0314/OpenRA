ProducedUnitTypes =
	{
		{ factory = SovietBarracks1, types = { "e1", "e4", "e4", "e1", "e1" }, delay = 3 },
		{ factory = SovietWarFactory1, types = { "jeep", "1tnk", "1tnk", "jeep" }, delay = 3 },
		{ factory = SovietHeliPad2, types = { "hind" }, delay = 6}
	}

WorldLoaded = function()
	GDI = Player.GetPlayer("Spain")
	Coalition = Player.GetPlayer("Germany")
	KillObj = GDI.AddPrimaryObjective("Destroy Enemy Forces")
	Camera.Position = Actor274.CenterPosition
	Trigger.AfterDelay(DateTime.Seconds(1), SendStrikeFighters)
	Trigger.OnKilled(Actor274, function() 
		Reinforcements.ReinforceWithTransport(GDI, "lst", {"2tnk","2tnk","jeep","mcv","4tnk"}, {CPos.New(35, 128), Actor302.Location},{CPos.New(35, 128)})
		Trigger.AfterDelay(DateTime.Minutes(2), function()
			TurnOnAI()
		end)
	end)
end

SendStrikeFighters = function()
	local fighter = Actor.Create("phant", true, {Owner = Coalition, Location =  CPos.New(35, 128)})
       	fighter.Attack(Actor274)
       	Trigger.OnKilled(Actor274, function()
	       	fighter.Move(CPos.New(35, 128))
	       	Trigger.AfterDelay(DateTime.Seconds(1), function() 
			Trigger.OnIdle(fighter, function() 
				fighter.Destroy() 
			end) 
		end)
	end)
end

BindActorTriggers = function(a)
	a.AttackMove(CPos.New(31,92))

	if a.HasProperty("Hunt") then
		Trigger.OnIdle(a, function(a)
			if a.IsInWorld then
		       		a.Hunt()
			end
		end)
	end

	if a.HasProperty("HasPassengers") then
		Trigger.OnDamaged(a, function()
			if a.HasPassengers then
				a.Stop()
				a.UnloadPassengers()
			end
		end)
	end
end

TurnOnAI = function()
	Utils.Do(ProducedUnitTypes, function(production)
		Trigger.OnProduction(production.factory, function(_, a) BindActorTriggers(a) end)
		Trigger.AfterDelay(DateTime.Minutes(production.delay), function()
			ProduceUnits(production)
		end)
	end)
end


ProduceUnits = function(t)
	local factory = t.factory
	if not factory.IsDead then
		Utils.Do(t.types, function(actorType) 
			factory.Wait(Actor.BuildTime(actorType))
			factory.Produce(actorType)
			factory.Wait(5)
		end)
		
		Trigger.AfterDelay(DateTime.Minutes(t.delay), function() ProduceUnits(t) end)
	end
end
