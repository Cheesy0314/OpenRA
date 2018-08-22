WorldLoaded = function()
	GDI = Player.GetPlayer("Spain")
	Germany = Player.GetPlayer("Germany")
	KillObj = GDI.AddPrimaryObjective("Destroy Enemy Forces")
	Utils.Do(Germany.GetActorsByType("ca"), function(boat) 
		boat.Attack(Actor274)
		Trigger.OnIdle(boat, function() boat.Hunt() end)
	end)
	Trigger.OnKilled(Actor274, function() 
		Reinforcements.ReinforceWithTransport(GDI, "lst", {"2tnk","2tnk","jeep","mcv","4tnk"}, {CPos.New(35, 128), Actor299.Location - CVec.New(0,2)},{CPos.New(35, 128)})
		Trigger.AfterDelay(DateTime.Minutes(2), function()
			TurnOnAI()
		end)
	end)
end

TurnOnAI = function()
	print("AI is on")
end
