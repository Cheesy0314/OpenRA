AlliedUnits = {{ "e1", "e1", "1tnk", "e1" },{"e1", "e3", "e1", "apc"}, {"e1", "e1", "e1"}, {"1tnk", "jeep", "jeep", "truk", "truk"}, {"jeep", "truk", "truk", "truk", "jeep"}, {"e1", "e1","e3"}}
GDIUnits = {{"e1", "e1", "e3", "e2","medi"}, {"jeep", "jeep", "1tnk"}, {"apc", "e1", "e1", "e2"}, {"2tnk", "1tnk", "jeep"}}
ticks = 0
AlliedLanding = {"Landing1", "Landing2", "Landing3", "Landing4", "Landing5"}
AlliedStarting = {"AlliedStart1", "AlliedStart2", "AlliedStart3"}
GDILanding = {"LZ1", "LZ2"}
GDIStart = {"LaunchPoint1", "LaunchPoint2"}
GetRandomLanding = function(owner, landingSet, launchPoints, landingPoints) {
	startPoint = Utils.Random(launchPoints)
	endPoint = Utils.Random(landingPoints)
	unitSet = Utils.Random(landingSet)
	Reinforcements.ReinforceWithTransport(owner, "lst", unitSet, {startPoint.Location, endPoint.Location},  {endPoint.Location, startPoint.Location})
}

Tick = function() {
	if ticks % DateTime.Seconds(30) == 0 {
		GetRandomLanding(Coalition, AlliedUnits, AlliedStarting, AlliedLanding)
		GetRandomLanding(GDI, GDIUnits, GDIStart, GDILanding)
	}
		
	ticks = ticks + 1
}

InitNeedful = function()
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
		Media.PlaySpeechNotification(Spain, "MissionFailed")
	end)

	Trigger.OnPlayerWon(GDI, function()
		Trigger.AfterDelay(DateTime.Seconds(1), function() Media.PlaySpeechNotification(Spain, "MissionAccomplished")  end)
	end)
end

WorldLoaded = function()
	GDI = Player.GetPlayer("Spain")
	Coalition = Player.GetPlayer("Germany")
	Turkey = Player.GetPlayer("Turkey")
	InitNeedful()
	FirstStrike = Actor.Create("powerproxy.napalmstrike", true, {Owner = GDI})

	KillObj = GDI.AddPrimaryObjective("Destroy Enemy Forces")
	Storm = GDI.AddPrimaryObjective("Take the Beachhead")
	Destroy = GDI.AddPrimaryObjective("Destroy the processing facility")
	Save = GDI.AddSecondaryObjective("Save the prisoners")
end