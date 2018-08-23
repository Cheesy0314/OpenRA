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

Terminus = {
	prison = Actor401.CenterPosition,
	base = Actor275.CenterPosition,
	radar = Actor259.CenterPosition
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
	BuildTruck()
end

BuildTruck = function()
	Reinforcements.Reinforce(Soviet, { "truk" }, SouthEastToPrison, 30, function(truck)
		ConvoyTuck = truck
		BeginTransport = true
		CurrentTruckLocation = "prison"
		MoveShippment(truck)
		Trigger.OnKilled(truck, function(actor, killer)
			BeginTransport = false
			if BioLabNotCaptured then
				BuildTruck()
			end

			if not killer.IsDead() then
				SendStrikeTeam(killer)
			end
		end)
	end)
end

MoveShippment = function(truck)
	if truck ~= nil then
		ConvoyTruck = truck
	else
		return
	end
	if not ConvoyTruck.IsDead then
		if CurrentTruckLocation == "prison" and MovementCounter > 5 then
			local attackPath = Utils.Random(PoisonTownPath)
                        Utils.Do(attackPath, function(waypoint)
                        	ConvoyTruck.Move(waypoint, 1)
                        end)
			Trigger.AfterDelay(DateTime.Seconds(120), function() ConvoyTruck.Kill() end )
		else
			Trigger.AfterDelay(DateTime.Seconds(5), function()
				if not ConvoyTruck.IsDead then
				Utils.Do(ShippmentPaths[CurrentTruckLocation], function(waypoint)
					if not ConvoyTruck.IsDead then
						ConvoyTruck.Move(waypoint, 1)
					end
				end)
				end
				local nextTruckLocation = NextLocation[CurrentTruckLocation]
				CurrentTruckLocation = nextTruckLocation
				Trigger.OnEnteredProximityTrigger(Terminus[nextTruckLocation], WDist.FromCells(3), function(transport, id)
					if transport == ConvoyTruck then
						Trigger.AfterDelay(DateTime.Minutes(2), function() MoveShippment(ConvoyTruck) end)
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

SendFireMission = function(target)
	Media.DisplayMessage("Hold tight, I'll knock that out for you.", "Pilot", Coalition.Color)
	local fighter = Actor.Create("phant", true, {Owner = Coalition, Location = EnglishBaseEntry.Location })
	Trigger.AfterDelay(DateTime.Seconds(1), function()
	--fighter.Move(target.Location)
	fighter.Attack(target)
	Trigger.OnKilled(target, function()
		fighter.Move(EnglishBaseEntry.Location)
		Trigger.AfterDelay(DateTime.Seconds(1), function() Trigger.OnIdle(fighter, function() fighter.Destroy() end) end)
	end)
	end)
end

SendAlliedForces = function()
	local ChopperTeam = { "sniper" }
	local InsertionPath = { EnglishBaseEntry.Location, EnglishHPad.Location, Beach.Location }
	local ExitPath = { EnglishBaseEntry.Location }
	local InsertionHelicopterType = 'tran'
	Reinforcements.ReinforceWithTransport(Coalition, InsertionHelicopterType, ChopperTeam, InsertionPath, ExitPath)
	
	Trigger.AfterDelay(DateTime.Seconds(1), function()
		local chopper =  Coalition.GetActorsByType("tran")
		Trigger.OnPassengerExited(chopper[1], function(trans, sniper) 
			sniper.Owner = GDI
			Media.PlaySpeechNotification(GDI, "ReinforcementsArrived")
			Trigger.OnEnteredProximityTrigger(Actor359.CenterPosition, WDist.FromCells(10), function(target, id)
				if (target == sniper and not Actor359.IsDead) then
					Trigger.RemoveProximityTrigger(id)
					SendFireMission(Actor359)
				end
			end)
			
			Trigger.OnEnteredProximityTrigger(Actor360.CenterPosition, WDist.FromCells(10), function(target, id)
				if (target == sniper and not Actor360.IsDead ) then
					Trigger.RemoveProximityTrigger(id)
					SendFireMission(Actor360)
				end
			end)
			
			Trigger.OnEnteredProximityTrigger(Actor362.CenterPosition, WDist.FromCells(10), function(target, id)
				if (target == sniper and not Actor362.IsDead) then
					Trigger.RemoveProximityTrigger(id)
					SendFireMission(Actor362)
				end
			end)
		end)
	end)
	
	Trigger.OnEnteredProximityTrigger(Actor402.CenterPosition, WDist.FromCells(3), function(actor, id)
		if (actor.Owner == GDI) then
			Media.PlaySpeechNotification(GDI, "ReinforcementsArrived")
			Reinforcements.Reinforce(GDI, { "2tnk", "2tnk", "jeep", "4tnk", "apc", "e6", "e1r1", "e1r1", "e2", "e6" }, {CPos.New(1,52), Actor402.Location}, 10)
			RadarObj = GDI.AddPrimaryObjective("Capture radar base.")
			Trigger.AfterDelay(15, function() GDI.MarkCompletedObjective(ReconObj) end)
			Trigger.RemoveProximityTrigger(id)
		end
	end)

	Trigger.OnCapture(Actor139, function()
		Reinforcements.Reinforce(GDI, { "2tnk", "2tnk", "mcv" }, { CPos.New(1,52), CPos.New(6,52) },30)
		Media.PlaySpeechNotification(GDI, "ReinforcementsArrived")
		DestroyObj = GDI.AddPrimaryObjective("Destroy all enemy forces.")
		Trigger.AfterDelay(15, function() GDI.MarkCompletedObjective(RadarObj) end)
	end)
	
	Trigger.OnKilled(Actor139, function()
		GDI.MarkFailedObjective(RadarObj)
	end)
end

MissionAccomplished = function()
	Media.PlaySpeechNotification(GDI, "MissionAccomplished")
end

MissionFailed = function()
	Media.PlaySpeechNotification(GDI, "MissionFailed")
end

WorldLoaded = function()
	GDI = Player.GetPlayer("Spain")
	Soviet = Player.GetPlayer("USSR")
	Coalition = Player.GetPlayer("England")
	Creeps = Player.GetPlayer("Creeps")
	Civilians = Player.GetPlayer("Neutral")
	
	
	Trigger.OnObjectiveAdded(GDI, function(p, id)
		Media.DisplayMessage(GDI.GetObjectiveDescription(id), "New " .. string.lower(GDI.GetObjectiveType(id)) .. " objective")
	end)
	Trigger.OnObjectiveCompleted(GDI, function(p, id)
		Media.DisplayMessage(GDI.GetObjectiveDescription(id), "Objective completed")
	end)
	Trigger.OnObjectiveFailed(GDI, function(p, id)
		Media.DisplayMessage(GDI.GetObjectiveDescription(id), "Objective failed")
	end)

	Trigger.OnPlayerLost(GDI, MissionFailed)
	Trigger.OnPlayerWon(GDI, MissionAccomplished)
	
	ActivateShipments()
	ActivateTriggers()
	SendAlliedForces()
	Camera.Position = EnglishHPad.CenterPosition
	ReconObj = GDI.AddPrimaryObjective("Find allied operative in south western town.")
	Media.DisplayMessage("Commander, air assets will assist you until more forces can arrive.", "Command", Coalition.Color)

end