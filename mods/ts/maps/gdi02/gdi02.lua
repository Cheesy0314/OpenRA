InitObjective = function()

end

WorldLoaded = function()
	GDI = Player.GetPlayer("GDI")
	Nod = Player.GetPlayer("Nod")
	Creeps = Player.GetPlayer("Creeps")
        local transports = Reinforcements.Reinforce(GDI, { "orcatran", "orcatran" }, { Actor370.Location, Actor367.Location }, function(actor)
		Trigger.OnDamaged(actor, function(self, attacker)
			Trigger.AfterDelay(DateTime.Seconds(1), function() self.Kill() end)
		end)
	end)

        Trigger.OnAllKilled(transports, function() 
		SAMObjective = GDI.AddPrimaryObjective("Destroy SAM sites")
		Trigger.AfterDelay(DateTime.Seconds(1), function()
			Reinforcements.Reinforce(GDI, { "mcv", "smech", "smech", "e1", "e1", "e1" }, { Actor370.Location, CPos.New(61, 42) })
		end)
	end)
       
end
