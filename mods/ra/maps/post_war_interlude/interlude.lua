flareLocation = AlliedTent.Location - CPos.New(3,0)

entryPath = {CPos.New(115,2), CPos.New(50,110)}
exitPath = { CPos.New(49,109), CPos.New(15,2) }


AttackAllies = function()
        Media.PlaySpeechNotification(player, "SovietReinforcementsArrived")
        Reinforcements.ReinforceWithTransport(Nod, "badr", {"jeep", "e1r1", "e1r1", "e3r1", "e3r1"}, entryPath, exitPath, nil, nil, 5)
end



SendMCV = function() 
	Camera.Position = gdibase.CenterPosition
	Trigger.AfterDelay(25, function()
		Media.PlaySpeechNotification(player, "AlliedReinforcementsArrived")
     		Reinforcements.Reinforce(Italy, { "mcv" }, { mcvstart.Location, gdibase.Location }, 25, function(mcv)
			mcv.Owner = player
                	mcv.Deploy()
        	end)
	end)
end

WereAlliesAttacked = function()
	Utils.Do(Italy.GetActors(), function(a) 
		Trigger.OnDamaged(a, function(self, attacker)
			if attacker.Owner == Nod and not IsUnderAttack then
				IsUnderAttack = true
				Media.PlaySoundNotification(player, "AlertBleep")
				Media.DisplayMessage("Our allies are under attack!")
				Trigger.AfterDelay(10, function() Media.PlaySpeechNotification(player,"SignalFlareWest") 
					Actor.Create("flare", true, {Location = CPos.New(flareLocation), Owner = player})
				end)
			end
		end)
	end)
	
end

WorldLoaded = function()
        player = Player.GetPlayer("Spain")
        Italy = Player.GetPlayer("Creeps")
        Nod = Player.GetPlayer("USSR")
	SendMCV()
	IsUnderAttack = false
	WereAlliesAttacked()

	Trigger.AfterDelay(1000, function() AttackAllies() end)

        Trigger.OnObjectiveAdded(player, function(p, id)
                Media.DisplayMessage(p.GetObjectiveDescription(id), "New " .. string.lower(p.GetObjectiveType(id)) .. " objective")
        end)
        Trigger.OnObjectiveCompleted(player, function(p, id)
                Media.DisplayMessage(p.GetObjectiveDescription(id), "Objective completed")
        end)
        Trigger.OnObjectiveFailed(player, function(p, id)
                Media.DisplayMessage(p.GetObjectiveDescription(id), "Objective failed")
        end)

        VillageRaidObjective = player.AddPrimaryObjective("Destroy all former Soviet forces")
	protectAllies = player.AddSecondaryObjective("Protect Allied forces in area")
	Trigger.AfterDelay(10, function() Media.DisplayMessage("We've provided you with our new missile system for your Destroyers, do not waste them", "Command") end)

        Trigger.OnPlayerWon(player, function()
                Media.PlaySpeechNotification(player, "MissionAccomplished")
        end)

        Trigger.OnPlayerLost(player, function()
                Media.PlaySpeechNotification(player, "MissionFailed")
        end)
end

Tick = function()
	if (Nod.HasNoRequiredUnits()) then
		Media.PlaySpeechNotification(player, "SovietForcesFallen")
		Trigger.AfterDelay(30, function() 
			player.MarkCompletedObjective(VillageRaidObjective)
			player.MarkCompletedObjective(protectAllies)
		end)
	end

	if (Italy.HasNoRequiredUnits()) then
		Media.PlaySpeechNotification(player, "AlliedForcesFallen")
		Trigger.AfterDelay(40, function()
			player.MarkFailedObjective(protectAllies)
		end)
	end

	if (player.HasNoRequiredUnits()) then
		player.MarkFailedObjective(VillageRaidObjective)
	end
end
