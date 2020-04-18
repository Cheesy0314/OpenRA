CanParadrop = false
TookOver = false
Ticked = 0

ParadropUnits = function()
	Media.PlaySpeechNotification(allies,"EnemyAirArmadaDetected")
	local lz = CPos.New(36,-12)
	local start = Map.CenterOfCell(Map.RandomEdgeCell()) + WVec.New(0, 0, Actor.CruiseAltitude("pdplane"))
	local transport = Actor.Create("pdplane", true, { CenterPosition = start, Owner = soviet, Facing = (Map.CenterOfCell(lz) - start).Facing })
        local ParadropUnitTypes = {"e2", "e2", "e2","e2", "e2", "e2","e2", "e2", "e2","e2", "e2", "e2","e2", "e2", "e2"}
	Trigger.OnPassengerExited(transport, function(plane, troop)
		Trigger.AfterDelay(DateTime.Seconds(5), function()
			if not troop.IsDead then
				troop.AttackMove(ConYard.Location)
			end
		end)
	end)
	Utils.Do(ParadropUnitTypes, function(type)
		local a = Actor.Create(type, false, { Owner = soviet })
		transport.LoadPassenger(a)
	end)

	transport.Paradrop(lz)

end

Tick = function()
	if Ticked == DateTime.Minutes(1) then
		if CanParadrop then
			ParadropUnits()
		end
		if not TookOver then
			TookOver = true
               		Media.PlaySpeechNotification(allies, "AllianceFormed")
      			Utils.Do(FortBragg.GetActors(), function(a)
             		        a.Owner = allies
			end)
		end
		Ticked = 0
	end

	Ticked = Ticked + 1
end

WorldLoaded = function() 
	allies = Player.GetPlayer('Allies')
	Trigger.OnObjectiveAdded(allies, function(p, id)
                Media.DisplayMessage(p.GetObjectiveDescription(id), "New " .. string.lower(p.GetObjectiveType(id)) .. " objective")
        end)
        Trigger.OnObjectiveCompleted(allies, function(p, id)
                Media.DisplayMessage(p.GetObjectiveDescription(id), "Objective completed")
        end)
        Trigger.OnObjectiveFailed(allies, function(p, id)
                Media.DisplayMessage(p.GetObjectiveDescription(id), "Objective failed")
        end)
	Camera.Position = CptParker.CenterPosition

	Trigger.AfterDelay(12, function()
		allies.AddPrimaryObjective("Destroy the carriers")
		allies.AddPrimaryObjective("Reach Fort Bradley")
		allies.AddSecondaryObjective("Link up with National Guard units")
		Trigger.AfterDelay(2, function()
			CptParker.Move(CPos.New(63,50))
			Trigger.AfterDelay(DateTime.Seconds(2), function() Camera.Position = CptParker.CenterPosition end)
		end)
	end)

	soviet = Player.GetPlayer('Soviet')
	FortBragg = Player.GetPlayer('Fort')
	NatGuard = Player.GetPlayer('NatGuard')
	Trigger.AfterDelay(15, function()
		Utils.Do(soviet.GetActorsByTypes({'e2', 'htnk', 'carrier'}), function(a) 
			a.Hunt()
		end)
		Utils.Do(soviet.GetActorsByType('carrier'), function(d)
			d.AttackMove(StatueOfLib.Location)
		end)
	end)

	Trigger.OnEnteredProximityTrigger(Actor178.CenterPosition, WDist.FromCells(8), function(interloper, trigID)
		if interloper.Owner == allies then
			Actor177.Owner = allies
			Actor178.Owner = allies
			Actor179.Owner = allies
			Trigger.RemoveProximityTrigger(trigID)
		end
	end)

	Trigger.OnAllKilled(soviet.GetActorsByType('carrier'), function()
		CanParadrop = true
		Media.DisplayMessage('Goodwork on the carriers, we have info that the Reds are preparing a staging area for their paratroops!', "Command", NatGuard.Color)
		Media.DisplayMessage('Get Cpt. Parker there and defend the square, goodluck.', "Command", NatGuard.Color)
		Reinforcements.Reinforce(NatGuard, {'e1','e1','e1'}, {CPos.New(36,-12), CPos.New(38,-12)})

		Media.PlaySpeechNotification(allies, 'NewTerrainDiscovered')
	end)
end
