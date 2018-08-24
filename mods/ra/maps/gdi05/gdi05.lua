WorldLoaded = function()
	GDI = Player.GetPlayer("Spain")
	Iraq = Player.GetPlayer("Ukraine")
	Civilians = Player.GetPlayer("Neutral")
	AssassinateObj = GDI.AddPrimaryObjective("Assassinate Saddam Hussein")
	UserInterface.SetMissionText("Assassinate Saddam", GDI.Color)
	Reinforcements.Reinforce(GDI, { 'sniper' }, { CPos.New(23,32), CPos.New(23,29) }, 20, function(actor)
		Trigger.OnKilled(actor, function()
			GDI.MarkFailedObjective(AssassinateObj)
		end)
	end)

	ActivateTriggers()
end

ActivateTriggers = function()
	Trigger.OnPassengerEntered(EscapeAPC, function(apc,passenger)
		if passenger == SaddamHussein then
			EscapeAPC.Move(CPos.New(1,5))
			Trigger.AfterDelay(25, function()
				EscapeAPC.Destroy()
				Trigger.AfterDelay(15, function() GDI.MarkCompletedObjective(AssassinateObj) end)
			end)
		end
	end)

	Trigger.OnDamaged(SaddamHussein, function(saddam, assassin)
		saddam.EnterTransport(EscapeAPC)
	end)
end

InitNotifications = function()
	Trigger.OnObjectiveAdded(GDI, function(p, id)
		Media.DisplayMessage(p.GetObjectiveDescription(id), "New " .. string.lower(p.GetObjectiveType(id)) .. " objective")
	end)

	Trigger.OnObjectiveCompleted(GDI, function(p, id)
		Media.DisplayMessage(p.GetObjectiveDescription(id), "Objective completed")
	end)
	Trigger.OnObjectiveFailed(GDI, function(p, id)
		Media.DisplayMessage(p.GetObjectiveDescription(id), "Objective failed")
	end)
 	Trigger.OnPlayerLost(GDI, function()
		Media.PlaySpeechNotification(GDI, "MissionFailed")
	end)
 	Trigger.OnPlayerWon(GDI, function()
		Trigger.AfterDelay(DateTime.Seconds(1), function() Media.PlaySpeechNotification(GDI, "MissionAccomplished")  end)
	end)
end
