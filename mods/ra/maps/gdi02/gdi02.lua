ExperimentsHaveNotBegun = true
BeginTransport = false
BioLabNotCaptured = true
CurrentTruckLocation = "prison"
MovementCounter = 0

SouthEastToPrison = { Actor266.Location, Actor265.Location, Actor264.Location, Actor255.Location, Actor254.Location, Actor123.Location, Actor401.Location }

EnemyStrikeForce = {
	{ structure = WarFactory1, units = {'1tnk', '1tnk', '2tnk', 'apc', 'jeep'}, delay = 4, attackPath = {Actor274.Location, Actor256.Location} },
	{ structure = WarFactory2, units = {'3tnk', 'jeep'}, delay = 2, attackPath = {Actor274.Location, Actor256.Location} },
	{ structure = AirField1, units = {'mig'}, delay = 6, attackPath = {Actor255.Location, Actor256.Location} }
}

ReinforcePoints = {
	{ Actor266.Location, Actor265.Location },
	{ Actor270.Location, Actor269.Location },
	{ Actor263.Location, Actor262.Location }
}

ForcesLeaveMap = {
	{ Actor275.Location, Actor274.Location, Actor273.Location, Actor272.Location, Actor256.Location, Actor255.Location, Actor254.Location, Actor267.Location, Actor268.Location, Actor269.Location, Actor402.Location },
	{ Actor275.Location, Actor274.Location, Actor273.Location, Actor272.Location, Actor260.Location, Actor261.Location, Actor262.Location, Actor263.Location }
}

PoisonTownPath = {
	{ Actor401.Location, Actor123.Location, Actor254.Location, Actor267.Location, Actor268.Location, Actor269.Location, Actor271.Location },
	{ Actor401.Location, Actor123.Location, Actor254.Location, Actor255.Location, Actor264.Location, Actor265.Location, Actor402.Location }
}

ForcesToSend = {
	{ "2tnk", "jeep", "truk" },
	{ "1tnk", "jeep", "jeep" },
	{ "apc", "apc", "3tnk" },
	{ "4tnk", "2tnk", "1tnk"}
}

ShipmentsLeaveMap = {
	{ Actor401.Location, Actor123.Location, Actor254.Location, Actor267.Location, Actor268.Location, Actor269.Location, Actor270.Location },
	{ Actor401.Location, Actor123.Location, Actor254.Location, Actor255.Location, Actor264.Location, Actor265.Location, Actor266.Location },
	{ Actor401.Location, Actor123.Location, Actor254.Location, Actor255.Location, Actor264.Location, Actor265.Location, Actor402.Location, Actor262.Location, Actor263.Location }
}

ShippmentPaths = {
	prison = { Actor401.Location, Actor123.Location, Actor254.Location, Actor255.Location, Actor256.Location, Actor257.Location, Actor258.Location, Actor259.Location },
	radar = { Actor259.Location, Actor258.Location, Actor257.Location, Actor272.Location, Actor273.Location, Actor274.Location, Actor275.Location },
	base = { Actor275.Location, Actor274.Location, Actor273.Location, Actor272.Location, Actor256.Location, Actor255.Location, Actor254.Location, Actor123.Location, Actor401.Location }
}

NextLocation = {
	prison = "radar",
	radar = "base",
	base = "prison"
}

ActivateShipments = function()
	local forces = Reinforcements.Reinforce(Soviet, { "truk" }, SouthEastToPrison, 30, function(truck)
		BeginTransport = true
		CurrentTruckLocation = "prison"
		MoveShippment()
	end)
	ConvoyTruck = forces[1]
	Trigger.OnKilled(ConvoyTruck, function(truck, killer)
		BeginTransport = false
		if BioLabNotCaptured then
			local newTruck = Reinforcements.Reinforce(Soviet, { "truk" }, SouthEastToPrison, 30, function(trans) 
				BeginTransport = true 
				CurrentTruckLocation = "prison"
				MoveShippment()
			end)
			ConvoyTruck = newTruck[1]
		end

		if not killer.IsDead() then
			SendStrikeTeam(killer)
		end
	end)

	Trigger.AfterDelay(DateTime.Minutes(3), function()
		ExportShipments()
	end)
end

MoveShippment = function()
	if not ConvoyTruck.IsDead() then
		if CurrentTruckLocation == "prison" and MovementCounter > 5 then
			local attackPath = Utils.Random(PoisonTownPath)
                        Utils.Do(attackPath, function(waypoint)
                        	ConvoyTruck.Move(waypoint, 1)
                        end)
			Trigger.OnEnteredProximityTrigger(attackPath[#attackPath], WDist.FromCells(3), function(truck, id)
				if truck == ConvoyTruck then
					truck.Kill()
					MovementCounter = 0
					if attackPath[#attackPath] == Actor402.Location then
						PoisonTown("south")
					else
						PoisonTown("north")
					end
				end
			end)
		else
			Trigger.AfterDelay(DateTime.Seconds(5), function()
				Utils.Do(ShippmentPaths[CurrentTruckLocation], function(waypoint)
					ConvoyTruck.Move(waypoint, 1)
				end)
				local nextTruckLocation = NextLocation[CurrentTruckLocation]
				CurrentTruckLocation = nextTruckLocation
				Trigger.OnEnteredProximityTrigger(Terminus[nextTruckLocation], WDist.FromCells(3), function(transport, id)
					if transport == ConvoyTruck then
						Trigger.AfterDelay(DateTime.Minutes(2), function() MoveShippment() end)
						Trigger.RemoveProximityTrigger(id)
					end
				end)
			end)
		end
	end
end

SendMercs = function()
	local units = Utils.Random(ForcesToSend)
	local sendPath = Utils.Random(ForcesLeaveMap)
	local productionStructure = Utils.Random({ WarFactory1, WarFactory2 })
	productionStructure.Build(units, function(builtUnits) 
		SendOutForces(builtUnits, sendPath)
		Trigger.AfterDelay(DateTime.Minutes(7), SendMercs())
	end)
end

SendAttack = function()
	local attackParameters = Utils.Random(EnemyStrikeForce)
	local units = attackParameters.types
	local attackPath = attackParameters.path
	local attackDelay = attackParameters.delay
	local productionStructure = attackParameters.structure

	productionStructure.Build(units, function(builtUnits)
		Utils.Do(builtUnits, function(unit)
			unit.Move(attackPath[1])
			unit.AttackMove(attackPath[2])
			unit.Hunt()
			Trigger.OnIdle(unit, function() unit.Hunt() end)
		end)
		
		Trigger.AfterDelay(DateTime.Minutes(attackDelay), function()
			SendAttack()
		end)
	end)

end

SendOutForces = function(forces, pathing)
	Utils.Do(forces,function(actor) 
		Utils.Do(pathing, function(waypoint)
			actor.AttackMove(waypoint, 3)
		end)
	end)
end

SendResponseTeam = function(target)
	local path = Utils.Random(ReinforcePoints)
	Reinforcements.Reinforce(Soviet, { "1tnk", "jeep", "jeep" }, path, 10, function(actor) 
		actor.Attack(target)
		Trigger.OnIdle(actor, function()
			actor.Hunt()
		end)
	end)
end

ActivateTriggers = function()
	Trigger.OnKilledOrCaptured(ResearchLab, function()
		BioLabNotCaptured = false
	end)

	Trigger.OnEnteredProximityTrigger(Actor263.CenterPosition, WDist.FromCells(1), function(actor, triggerID)
		if actor.Owner == Soviet then
			actor.Destroy()
		end
	end)

        Trigger.OnEnteredProximityTrigger(Actor270.CenterPosition, WDist.FromCells(1), function(actor, triggerID)
                if actor.Owner == Soviet then
                        actor.Destroy()
                end
        end)

        Trigger.OnEnteredProximityTrigger(Actor266.CenterPosition, WDist.FromCells(1), function(actor, triggerID)
                if actor.Owner == Soviet then
                        actor.Destroy()
                end
        end)
end

SendAlliedForces = function()
	Reinforcements.ReinforceWithTransport(Coalition, "tran", { "sniper" }, { GermanBaseEntry.Location, Beach.Location }, { GermanBaseEntry.Location }, function(chopper, snipers) 
		local sniper = snipers[1]
		AfterDelay(10, function() sniper.Owner = GDI end)
	end)
end


WorldLoaded = function()
	GDI = Player.GetPlayer("Spain")
	Soviet = Player.GetPlayer("Russia")
	Coalition = Player.GetPlayer("Germany")
	Creeps = Player.GetPlayer("Creeps")
	Civilians = Player.GetPlayer("Neutral")
	ActivateShipments()
	ActivateTriggers()
	SendAlliedForces()
	ReconObj = GDI.AddPrimaryObjective("Find allied operative in south western town.")
end
