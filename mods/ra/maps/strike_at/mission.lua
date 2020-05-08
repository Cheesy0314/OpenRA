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
	Soviet = Player.GetPlayer("Soviet")
	Reinforcements.Reinforce(Soviet, {'mcv', '1tnk' ,'1tnk'}, {CPos.New(23, 110) , CPos.New(23, 107)})
end
