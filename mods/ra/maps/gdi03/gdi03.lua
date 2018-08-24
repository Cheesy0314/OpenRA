PassengerEnterCount = 0
WorldLoaded = function()
	Transport = Player.GetPlayer("Transport")
	GDI = Player.GetPlayer("Spain")
	France = Player.GetPlayer("France")
	Creeps = Player.GetPlayer("Soviet")
	Germany = Player.GetPlayer("Germany")
	Civilians = Player.GetPlayer("Neutral")
	FindBaseObj = GDI.AddPrimaryObjective("Find Allied Base.")
	InitTriggers()
	Trigger.AfterDelay(25, function()
		Media.PlaySpeechNotification(GDI, "AirUnitLost")
		Media.DisplayMessage("I'm lucky to be alive, my men were not so lucky. Hmmm, I can see some buildings up ahead.", "Commander", GDI.Color)
	end)
	Camera.Position = Trooper.CenterPosition
end

InitTriggers = function()
	Trigger.OnEnteredProximityTrigger(HelpfulChopper.CenterPosition, WDist.FromCells(4), function(actor, id)
		if (actor.Type == "gnrl") then
			Actor409.Owner = GDI
			Actor396.Owner = GDI
			Actor516C.Owner = GDI
			Trigger.RemoveProximityTrigger(id)
			Media.DisplayMessage("Another Chinook, that is convienent!", "Commander", GDI.Color)
			HelpfulChopper.Owner = Transport
			Trigger.OnPassengerEntered(HelpfulChopper, function()
				HelpfulChopper.Owner = GDI
				if PassengerEnterCount == 0 then
					Media.DisplayMessage("Where is everyone? There seems to be a message about a nearby German research outpost; I should head there.", "Commander", GDI.Color)
					Trigger.AfterDelay(25, function() Camera.Position = Actor516C.CenterPosition end)
					HelpfulChopper.Move(Actor516C.Location - CVec.New(1,0))
					PassengerEnterCount = 1
				elseif PassengerEnterCount == 1 then
					PassengerEnterCount = 2
					Trigger.AfterDelay(25, function() Camera.Position = ZedCam.CenterPosition end)
					HelpfulChopper.Move(ZedCam.Location + CVec.New(4,0))
				elseif PassengerEnterCount == 2 then
					Trigger.AfterDelay(25, function() Camera.Position = Actor574.CenterPosition end)
					HelpfulChopper.Move(Actor574.Location - CVec.New(2,0))
					PassengerEnterCount = 42
					Actor.Create("camera", true, {Owner = GDI, Location = Actor574.Location - CVec.New(2,0)})
				end
			end)
		end
	end)

	Trigger.OnPassengerExited(HelpfulChopper, function()
		HelpfulChopper.Owner = Transport
		CheckOtherUnits()
		if (PassengerEnterCount == 1) then
			Media.DisplayMessage("Seems to be abandoned, but another outpost position is listed on the building's board.", "Commander", GDI.Color)
		elseif (PassengerEnterCount == 2) then
			Media.DisplayMessage("Another empty base. Wait, I hear something!", "Commander", GDI.Color)
		elseif (PassengerEnterCount == 42) then 
			Media.DisplayMessage("Christ... the base is decimated. I need to get to the Construction Yard", "Commander", GDI.Color)
			Actor.Create("camera", true, {Owner = GDI, Location = ConYard.Location - CVec.New(2,0)})
			PassengerEnterCount = 500
		end
	end)

	Trigger.OnEnteredProximityTrigger(Actor516C.CenterPosition, WDist.FromCells(4), function(actor, id)
		if (actor.Owner == GDI) then
			Trigger.RemoveProximityTrigger(id)
			ZedCam.Owner = GDI
		end
	end)

	
	Trigger.OnEnteredProximityTrigger(Tents.CenterPosition, WDist.FromCells(7), function(actor, id)
		if (actor.Owner == GDI and actor.Type == "gnrl") then
			Trigger.RemoveProximityTrigger(id)
			Utils.Do(France.GetActors(), function(building)
				if building.Type == "miss" then
					building.Owner = Germany
				else 
					building.Owner = GDI
				end
			end)
		end
	end)

	Trigger.OnEnteredProximityTrigger(Germany.GetActorsByType("e1")[1].CenterPosition, WDist.FromCells(5), function(finder, id)
		if (finder.Owner == GDI) then
			Germany.GetActorsByType("e1")[1].Owner = GDI
			Media.DisplayMessage("Thanks for finding me, I'm freezing out here", "Pilot")
			Trigger.RemoveProximityTrigger(id)
		end
	end)

	Trigger.OnKilled(FirstZed, function()
		Media.DisplayMessage("What the fuck was that thing! I need to get to that base now, here's the coordinates for the helipad there.", "Commander", GDI.Color)
		
	end)
end

CheckOtherUnits = function()
	local units = Transport.GetActors()
	Utils.Do(units, function(actor)
		if actor ~= HelpfulChopper and actor.Owner == Transport then
			actor.Owner = GDI
		end
	end)
end
