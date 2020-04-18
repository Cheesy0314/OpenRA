WorldLoaded = function()
	Allies = Player.GetPlayer("Allies")
	Trigger.AfterDelay(50, function()
		Reinforcements.ReinforceWithTransport(Allies,"lcrf", {"amcv", "mtnk", "mtnk","tnkd"}, {Actor94.Location, Actor95.Location})
		Trigger.AfterDelay(200, function()
			Reinforcements.ReinforceWithTransport(Allies, "shad", {"ghost","ghost","ghost","ghost","ghost"}, {Actor94.Location, Actor95.Location})
		end)
	end)
end
