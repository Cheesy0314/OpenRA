Points = { 
	{ units = { "1tnk", "jeep", "jeep" }, point = CPos.New(1,69), withTrans = false },
	{ units = { "2tnk", "1tnk", "1tnk" }, point = CPos.New(24,1), withTrans = false }, 
	{ units = { "1tnk", "1tnk" }, point = CPos.New(1,127), withTrans = true, trans = "lst", landing = Actor301.Location },
	{ units = { "e1r1", "e1r1", "e3r1", "e3r1", "e1r1" }, point = CPos.New(64,67), withTrans = true, trans = "tran", landing = Actor307.Location }
}

ProducedUnitTypes =
	{
		{ factory = SovietBarracks3, types = { "e1", "e4", "e4", "e1", "e1" }, delay = 1 },
		{ factory = SovietWarFactory1, types = { "jeep", "jeep", "1tnk", "1tnk", "jeep" }, delay = 2 },
		{ factory = SovietHeliPad2, types = { "hind", "hind" }, delay = 6}
	}

WorldLoaded = function()
	GDI = Player.GetPlayer("Spain")
	Coalition = Player.GetPlayer("Germany")
	Turkey = Player.GetPlayer("Turkey")
	KillObj = GDI.AddPrimaryObjective("Destroy Enemy Forces")
	Camera.Position = Actor274.CenterPosition
	FirstStrike = Actor.Create("powerproxy.napalmstrike", true, {Owner = GDI})
	Media.DisplayMessage("Airstrike the enemy base to begin invasion")

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
		ProduceUnits(production)
	end)
	SendRandomForces()
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

SendRandomForces = function()
	local attackData = Utils.Random(Points)
	if attackData.withTrans then 
		local reinf = Reinforcements.ReinforceWithTransport(Turkey, attackData.trans, attackData.units, { attackData.point, attackData.landing }, { attackData.point })
		local units = reinf[2]
		Trigger.AfterDelay(14, function()
			Utils.Do(units, function(unit)
				Trigger.OnAddedToWorld(unit, function(self)
					unit.AttackMove(Actor309.Location)
				end)
				Trigger.OnIdle(unit, function() unit.Hunt() end)
			end)
		end)
	else
		Reinforcements.Reinforce(Turkey, attackData.units, { attackData.point, Actor309.Location }, 30, function(actor)
			Trigger.OnIdle(actor, function() actor.Hunt() end)
		end)
	end

	Trigger.AfterDelay(DateTime.Minutes(3), SendRandomForces)
end
