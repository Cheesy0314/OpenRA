HasBeenShot = false

Transports = {
	{ "truk", "truk" },
	{ "truk", "jeep2" },
	{ "jeep2", "5tnk" }
}

Paths = {
	{ Actor191.Location, Actor194.Location },
	{ Actor190.Location, Actor193.Location },
	{ Actor194.Location, Actor191.Location },
	{ Actor193.Location, Actor190.Location }
}

WorldLoaded = function()
	GDI = Player.GetPlayer("Spain")
	Iraq = Player.GetPlayer("Ukraine")
	Allies = Player.GetPlayer("Allies")
	Civilians = Player.GetPlayer("Neutral")
	AssassinateObj = GDI.AddPrimaryObjective("Assassinate Saddam Hussein")
	UserInterface.SetMissionText("Assassinate Saddam", GDI.Color)
	Reinforcements.Reinforce(GDI, { 'sniper', "medi" }, { CPos.New(23,32), CPos.New(23,29) }, 20, function(actor)
		if actor.Type == "sniper" then
			Trigger.OnKilled(actor, function()
				if not HasBeenShot then
					GDI.MarkFailedObjective(AssassinateObj)
				end
			end)
		end
	end)

	ActivateTriggers()
end

ActivateTriggers = function()
	Trigger.OnPassengerEntered(EscapeAPC, function(apc,passenger)
		if passenger == SaddamHussein then
			EscapeAPC.Move(CPos.New(1,5))
			Trigger.AfterDelay(10, function()
				EscapeAPC.Destroy()
			end)
		end
	end)

	Trigger.OnDamaged(SaddamHussein, function(saddam, assassin)
		saddam.EnterTransport(EscapeAPC)
		HasBeenShot = true
		Trigger.OnEnteredProximityTrigger(Actor191.CenterPosition, WDist.FromCells(1), function(actor, tid)
			if actor.Owner == Allies then
				actor.Destroy()
				if actor.Type == "sniper" then
					Trigger.AfterDelay(10, function() GDI.MarkCompletedObjective(AssassinateObj) end)
				end
			end
		end)
		Retreat()
	end)
	Trigger.AfterDelay(DateTime.Seconds(20), SendShippment)
end

Retreat = function()
	local sniper = GDI.GetActorsByType("sniper")[1]
	local medic = GDI.GetActorsByType("medi")[1]

	if medic ~= nil and not medic.IsDead then
		medic.Owner = Allies
		medic.Move(Actor191.Location)
	end

	if not sniper.IsDead then
		sniper.Owner = Allies
		sniper.Move(Actor191.Location)
	end

	
end

SendShippment = function()
	Reinforcements.Reinforce(Iraq, Utils.Random(Transports), Utils.Random(Paths), 30, function(actor)
		Trigger.AfterDelay(10, function() actor.Destroy() end)
	end)

	Trigger.AfterDelay(DateTime.Seconds(20), SendShippment)
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
