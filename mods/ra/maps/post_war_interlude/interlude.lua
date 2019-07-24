SendMCV = function() 
	Camera.Position = gdibase.CenterPosition
	Trigger.AfterDelay(25, function()
		Media.PlaySpeechNotification(player, 'AlliedReinforcementsArrived')
     		Reinforcements.Reinforce(Italy, { "mcv" }, { mcvstart.Location, gdibase.Location }, 25, function(mcv)
			mcv.Owner = player
                	mcv.Deploy()
        	end)
	end)
end

WorldLoaded = function()
        player = Player.GetPlayer("Spain")
        Italy = Player.GetPlayer("Creeps")
        Nod = Player.GetPlayer("Terrorists")
	SendMCV()
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

        Trigger.OnPlayerWon(player, function()
                Media.PlaySpeechNotification(player, "MissionAccomplished")
        end)

        Trigger.OnPlayerLost(player, function()
                Media.PlaySpeechNotification(player, "MissionFailed")
        end)
end

