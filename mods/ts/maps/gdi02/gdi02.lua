SAMSites = { SAM1, SAM2, SAM3, SAM4, SAM5, SAM6, SAM7 }

BaseBuildings = { ConstructionYard, Power1, Power2, Power3, Power4, WarFactor, HandOfNod, Radar, LaserTurret1, LaserTurret2, Silo1, Silo2, Refinery }

InitObjectives = function()
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
	local flyer = Reinforcements.Reinforce(Creeps, { 'orcatran' }, { Actor370.Location, Actor367.Location }, 30)
	Trigger.AfterDelay(30, function()
	Trigger.OnPassengerEntered(flyer, function(trans, pass)
		if trans.PassengerCount() == 5 then
			Trigger.OnEnteredProximityTrigger(Actor370.CenterPosition, WDist.FromCells(3), function(actor, tid)
				if (actor.Type == "orcatran") then
					actor.Destroy()
					Trigger.RemoveProximityTrigger(tid)
				end
			end)
			Trigger.AfterDelay(DateTime.Seconds(1), function() trans.Move(Actor370.Location()) end)
		end
	end)
	Trigger.OnEnteredProximityTrigger(Actor367.CenterPosition, WDist.FromCells(1), function(actor, id)
		if actor.Type == 'orcatran' and actor.Owner == Creeps then
			Reinforcements.Reinforce(Creeps, Civilians, { "slav", "civ1", "civ2", "e1", "e1" }, 30, function(person)
				person.EnterTransport(flyer)
			end)
			Trigger.RemoveProximityTrigger(id)
		end
	end)
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
	--InitAI(Nod)
	Creeps = Player.GetPlayer("Creeps")
        local transports = Reinforcements.Reinforce(Creeps, { "orcatran", "orcatran" }, { Actor370.Location, Actor367.Location }, 15)
	Trigger.AfterDelay(DateTime.Seconds(20), function()
		Utils.Do(SAMSites, function(site) site.Kill() end)
	end)
        Trigger.OnAllKilled(transports, function() 
		InitObjectives()
		Trigger.AfterDelay(DateTime.Seconds(3), function()
			Media.PlaySpeechNotification(GDI, "ReinforcementsArrived")
			Reinforcements.Reinforce(GDI, { "mcv", "smech", "smech", "e1", "e1", "e1" }, { Actor370.Location + CVec.New(3,0), CPos.New(61, 42) }, 15)
		end)
	end)

end
