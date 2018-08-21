SAMSites = { SAM1, SAM2, SAM3, SAM4, SAM5, SAM6, SAM7 }

BaseBuildings = { ConstructionYard, Power1, Power2, Power3, Power4, WarFactor, HandOfNod, Radar, LaserTurret1, LaserTurret2, Silo1, Silo2, Refinery }

InitObjective = function()
	Media.PlaySpeechNotification(GDI, "AllSamSitesMustBeDestroyedBeforeDropshipsCanBeDeployed")
	SAMObjective = GDI.AddPrimaryObjective("Destroy SAM sites")

	Utils.Do(SAMSites, function(sam) 
		Trigger.OnKilled(sam, function()
			Media.PlaySpeechNotification(GDI, "NodSamSitesDestroyed")
		end)
	end)

	Trigger.OnAllKilled(SAMSites, function() 

		Trigger.AfterDelay(DateTime.Seconds(2), function()
			Media.PlaySpeechNotification(GDI, "SamSitesDestroyedDropshipsInbound")
			SendRescueMission()
		end)

		Trigger.AfterDelay(DateTime.Seconds(5), function()
			Media.PlaySpeechNotification(GDI, "DestroyAllNodForcesInTheArea")
			Trigger.AfterDelay(15, function() GDI.MarkCompletedObjective(SAMObjective) end)
		end)
	end)
end

SendRescueMission = function()
	OrcaTran = Actor.Create('orcatran.mission', true, {Owner = GDI, Location = Actor370.Location})
	Trigger.OnAddedToWorld(OrcaTran, function()
		OrcaTran.Move(Actor367.Location)
	end)
end

InitKillEnemy = function()
	KillEnemy = GDI.AddPrimaryObjective("Destroy all Nod forces.")
	local units = Nod.GetGroundAttackers()
	for i,v in pairs(BaseBuildings) do
		table.insert(units, v)
	end

	Trigger.OnAllKilled(units, function() 
		Trigger.AfterDelay(DateTime.Seconds(3), function()
			GDI.MarkCompletedObjective(KillEnemy) 
		end)
	end)
end


WorldLoaded = function()
	GDI = Player.GetPlayer("GDI")
	Nod = Player.GetPlayer("Nod")
	InitAI(Nod)
	Creeps = Player.GetPlayer("Creeps")
        local transports = Reinforcements.Reinforce(GDI, { "orcatran.mission", "orcatran.mission" }, { Actor370.Location, Actor367.Location }, function(actor)
		Trigger.OnDamaged(actor, function(self, attacker)
			Trigger.AfterDelay(10, function() self.Kill() end)
		end)
	end)

        Trigger.OnAllKilled(transports, function() 
		InitObjectives()
		Trigger.AfterDelay(DateTime.Seconds(3), function()
			Media.PlaySpeechNotification(GDI, "ReinforcementsArrived")
			Reinforcements.Reinforce(GDI, { "mcv", "smech", "smech", "e1", "e1", "e1" }, { Actor370.Location, CPos.New(61, 42) })
		end)
	end)

end
