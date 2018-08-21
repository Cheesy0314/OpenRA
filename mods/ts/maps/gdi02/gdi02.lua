SAMSites = { SAM1, SAM2, SAM3, SAM4, SAM5, SAM6, SAM7 }

BaseBuildings = { ConstructionYard, Power1, Power2, Power3, Power4, WarFactor, HandOfNod, Radar, LaserTurret1, LaserTurret2, Silo1, Silo2, Refinery }

InitObjectives = function()
	SAMObjective = GDI.AddPrimaryObjective("Destroy SAM sites")


	Trigger.OnAllKilled(SAMSites, function() 

		Trigger.AfterDelay(DateTime.Seconds(2), function()
			Media.PlaySpeechNotification(GDI, "NodSamSitesDestroyed")
			SendRescueMission()
		end)

		Trigger.AfterDelay(DateTime.Seconds(5), function()
			Media.PlaySpeechNotification(GDI, "DestroyAllNodForcesInTheArea")
			InitKillEnemy()
			Trigger.AfterDelay(15, function() GDI.MarkCompletedObjective(SAMObjective) end)
		end)
	end)
end

SendRescueMission = function()
	local flyer = Actor.Create("orcatran", true, {Owner = GDI, Location = Actor370.Location + CVec.New(4,0)})
	flyer.Move(Actor367.Location - CVec.New(1,0))
	flyer.Land(Actor367)
	
	Trigger.OnPassengerEntered(flyer, function(trans, pass)
		if trans.PassengerCount == 5 then
			Trigger.OnEnteredProximityTrigger(Actor370.CenterPosition, WDist.FromCells(3), function(actor, tid)
				if (actor.Type == "orcatran") then
					actor.Destroy()
					Trigger.RemoveProximityTrigger(tid)
				end
			end)
			Trigger.AfterDelay(DateTime.Seconds(1), function() trans.Move(Actor370.Location()) end)
		end
	end)
	Trigger.OnEnteredProximityTrigger(Actor367.CenterPosition, WDist.FromCells(5), function(actor, id)
		if actor.Type == 'orcatran' then
			Trigger.AfterDelay(DateTime.Seconds(5), function()
				Reinforcements.Reinforce(Creeps, { "slav", "civ1", "civ2", "e1", "e1" }, { Actor375.Location + CVec.New(0,1), Actor380.Location }, 30, function(person)
					Trigger.AfterDelay(15,  function() person.EnterTransport(actor) end)
				end)
			end)
			Trigger.RemoveProximityTrigger(id)
		end
	end)
end

InitKillEnemy = function()
	KillEnemy = GDI.AddPrimaryObjective("Destroy all Nod forces.")
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
