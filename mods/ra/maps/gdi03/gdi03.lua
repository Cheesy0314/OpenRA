WorldLoaded = function()
	GDI = Player.GetPlayer("Spain")
	France = Player.GetPlayer("France")
	Creeps = Player.GetPlayer("Creeps")
	Civilians = Player.GetPlayer("Neutral")
	FindBaseObj = GDI.AddPrimaryObjective("Find Allied Base.")
	InitTriggers()
end

InitTriggers = function()
	Trigger.OnEnteredProximityTrigger(HelpfulChopper.CenterPosition, WDist.FromCells(2), function(actor, id)
		if (actor.Type == "gnrl") then
			HelpfulChopper.Owner = GDI
			Trigger.RemoveProximityTrigger(id)
		end
	end)

	
Trigger.OnEnteredProximityTrigger(Tents.CenterPosition, WDist.FromCells(7), function(actor, id)
		if (actor.Owner == GDI) then
			Trigger.RemoveProximityTrigger(id)
			Utils.Do(France.GetActors(), function(building)
				building.Owner = GDI
			end)
		end
	end)
end
