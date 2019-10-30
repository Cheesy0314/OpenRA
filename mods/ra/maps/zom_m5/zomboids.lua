LargeHorde = {"zombie","zombie","zombie","zombie","zombie","zombie","zombie","zombie","zombie","zombie","zombie","zombie","zombie","zombie","zombie","zombie","zombie","zombie","zombie","zombie","zombie","zombie","zombie","zombie","zombie","zombie","zombie"}
SmallHorde = {"zombie","zombie","zombie","zombie","zombie"}
ticks = 1

Tick = function()
	ticks = ticks + 1
	if ticks == DateTime.Seconds(60) then
		ticks = 1
		SendHordeWest()
		SendHordeEast()	
		SendHordeSouth()
	end
end

SendHordeSouth = function()
	Reinforcements.Reinforce(Zombies, LargeHorde, {ZSpawn1.Location, CPos.New(14,29)}, 25, function(actor)
		actor.AttackMove(Exit.Location)
	end)
end

SendHordeWest = function()
        Reinforcements.Reinforce(Zombies, SmallHorde, {MapEdge.Location, Entry.Location}, 25, function(actor)
                actor.AttackMove(Exit.Location)
        end)
end

SendHordeEast = function()
	Reinforcements.Reinforce(Zombies, {"zombie"}, {Exit.Location, MainTrigger.Location})
end

SpawnPillbox = function()
	Actor.Create("pbox", true, {Owner = Civilians})
end

InitNeedful = function()
        Trigger.OnObjectiveAdded(Spain, function(p, id)
                Media.DisplayMessage(p.GetObjectiveDescription(id), "New " .. string.lower(p.GetObjectiveType(id)) .. " objective")
        end)

        Trigger.OnObjectiveCompleted(Spain, function(p, id)
                Media.DisplayMessage(p.GetObjectiveDescription(id), "Objective completed")
        end)
        Trigger.OnObjectiveFailed(Spain, function(p, id)
                Media.DisplayMessage(p.GetObjectiveDescription(id), "Objective failed")
        end)

        Trigger.OnPlayerLost(Spain, function()
                Media.PlaySpeechNotification(Spain, "MissionFailed")
        end)

        Trigger.OnPlayerWon(Spain, function()
                Trigger.AfterDelay(DateTime.Seconds(1), function() Media.PlaySpeechNotification(Spain, "MissionAccomplished")  end)
        end)
end

WorldLoaded = function()
        Spain = Player.GetPlayer("Spain")
        Germany = Player.GetPlayer("Germany")
        Zombies = Player.GetPlayer("BadGuy")
        Civilian = Player.GetPlayer("Civilians")
	GDI = Player.GetPlayer("GDI")
        Soviet = Player.GetPlayer("Soviet")

	Escape = Spain.AddPrimaryObjective("Escape")
	forces = Reinforcements.Reinforce(Spain, {"rmbo"}, {MapEdge.Location, Entry.Location})
	Trigger.OnKilled(forces[1], function()
		Spain.MarkFailedObjective(Escape)
	end)
	Trigger.OnEnteredProximityTrigger(Exit.CenterPosition, WDist.New(3), function(actor, id)
		if actor.Owner == Spain then
			Trigger.RemoveProximityTrigger(id)
			Spain.MarkObjectiveCompleted(Escape)
		end
	end)
        Trigger.OnEnteredProximityTrigger(PBTerminal.CenterPosition, WDist.New(1), function(actor, id)
                if actor.Owner == Spain then
			SpawnPillbox()
			Trigger.RemoveProximityTrigger(id)
			Media.DisplayMessage("AUTOMATED DEFENSE TURRET ACTIVATED", "Speaker System", Civilian.Color)
                end
        end)
	Media.DisplayMessage("Commander, the team is down the corridor, we will cover your retreat. GO NOW!", "Soldier Heinrich", Germany.Color)
	Trigger.AfterDelay(DateTime.Seconds(10), function()
		SendHordeWest()
		SendHordeEast()
	end)
end
