LargeHorde = {"zombie","zombie","zombie","zombie","zombie","zombie","zombie","zombie","zombie","zombie","zombie","zombie","zombie","zombie","zombie","zombie","zombie","zombie","zombie","zombie","zombie","zombie","zombie","zombie","zombie","zombie","zombie"}
SmallHorde = {"zombie","zombie","zombie","zombie","zombie"}
ticks = 1
BeginMission = false

Tick = function()
	if BeginMission then
	ticks = ticks + 1
	if ticks == DateTime.Seconds(30) then
		ticks = 1
		SendHordeWest()
		SendHordeEast()	
		SendHordeSouth()
	end
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
	Actor.Create("pbox", true, {Owner = Civilians, Location = PillBoxSpawn.Location})
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
        Civilians = Player.GetPlayer("Civilians")
	GDI = Player.GetPlayer("GDI")
        Soviet = Player.GetPlayer("Soviet")
	Camera.Position = MainTrigger.CenterPosition
	Escape = Spain.AddPrimaryObjective("Escape")
	CivForDie = Reinforcements.Reinforce(Civilians, {"chan", "e3r1", "e1r1","e1r1", "e6"}, {MapEdge.Location, Exit.Location})
	Media.DisplayMessage("WE HAVE TO GET OUT OF HERE!", "Scientist", Civilians.Color)
	Trigger.OnAnyKilled(CivForDie, function(killed)
		Camera.Position = killed.CenterPosition
		Trigger.AfterDelay(DateTime.Seconds(5), function()
		Camera.Position = MainTrigger.CenterPosition
		forces = Reinforcements.Reinforce(Spain, {"rmbo", "chan"}, {MapEdge.Location, Entry.Location})
		Trigger.OnAnyKilled(forces, function()
			Spain.MarkFailedObjective(Escape)
		end)
      		Media.DisplayMessage("Commander, the team is down the corridor, we will cover your retreat. GO NOW!", "Soldier Heinrich", Germany.Color)
        		Trigger.AfterDelay(DateTime.Seconds(8), function()
				Reinforcements.Reinforce(Zombies, {"zombie","zombie","zombie"}, {MapEdge.Location,Entry.Location}, 25, function(a)
					a.AttackMove(PillBoxSpawn.Location)
				end)
                		SendHordeSouth()
	        	end)
		end)
	end)
	Trigger.OnEnteredProximityTrigger(MainTrigger.CenterPosition, WDist.New(7), function(actor, id)
		if actor.Owner == Spain then
			BeginMission = true
			Utils.Do(Zombies.GetUnitsByType("zombie"), function(z)
				z.Hunt()
			end)
		end
	end)
	Trigger.OnEnteredProximityTrigger(Exit.CenterPosition, WDist.New(5), function(actor, id)
		if actor.Owner == Spain then
			Spain.MarkObjectiveCompleted(Escape)
		end
	end)
        Trigger.OnEnteredProximityTrigger(PBTerminal.CenterPosition, WDist.New(1), function(actor, id)
                if actor.Owner == Spain then
			SpawnPillbox()
			Trigger.RemoveProximityTrigger(id)
			Media.DisplayMessage("AUTOMATED DEFENSE TURRET ACTIVATED", "Speaker System", Civilians.Color)
                end
	end)
end
