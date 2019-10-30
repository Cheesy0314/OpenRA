LandingForce = {"4tnk", "4tnk", "4tnk", "4tnk", "4tnk"}
ParadropUnitTypes = {"rmbo","e1r1","e1r1"}
ParadropUnitTypes2 = {"jeep","jeep","jeep","1tnk","1tnk"}
AABase = {radar, SAM1, SAM2, SAM3, SAM4, SAM5, SAM6, AA1, AA2 }
Beachhead = {Actor140,Actor141,Actor142,Actor143}
MainBase = {Actor40,Actor41,Actor42,Actor43,Actor44,Actor45,Actor46,Actor47,Actor48,Actor49,Actor50,Actor51}

SendSabetourTeam = function()
	Spain.MarkCompletedObjective(ClearAAPost)
	local lz = BadgerDropPoint3.Location
        Camera.Position = BadgerDropPoint3.CenterPosition
	Actor.Create("flare",true,{Owner = Spain, Location = BadgerDropPoint3.Location})
	Media.DisplayMessage("Next objective: disable power to base defenses", "Mission Command", Civilian.Color)
        Trigger.AfterDelay(45, function()
                local transport = Actor.Create("badr", true, { CenterPosition = BadgerStartPoint.CenterPosition, Owner = Spain})
                Utils.Do({"spy"}, function(type)
                        local a = Actor.Create(type, false, { Owner = Spain })
                        transport.LoadPassenger(a)
		end)
	end)
	transport.Paradrop(lz)
	Trigger.OnInfiltrated(PowerBaseControl, function()
		DestroyPowerbase()
	end)
end

SendReinforcements = function() 
	Media.PlaySpeechNotification(Spain, "ObjectiveMet")
	Media.DisplayMessage("Good work the defenses have been lowered. AirCommand is sending in a strike to clear the beach for you.", "Misson Command", Civilian.Color)
	Utils.Do(Beachhead, function(target) 
		SendAirstrike(target)
	end)
	Camera.Position = EndPointLST.CenterPosition
	Trigger.OnAllKilled(Beachhead, function()
		GiveAirstrike()
		Media.PlaySpeechNotification(Spain, "ReinforcementsArrived")
		Reinforcements.ReinforceWithTransport(Spain, "lst", LandingForce, {StartPointLST.Location, EndPointLST.Location},nil)
	end)
end

DestroyedPowerbase = function()
	Utils.Do(BadGuy.GetActorsByType("apwr"), function(actor)
		actor.Kill()
	end)
	Trigger.AfterDelay(100, function()
		Media.PlaySpeechNotification(Spain,"ObjectiveMet")
		Spain.MarkCompletedObjective(Inflitrate)
		Utils.Do(BadGuy.GetActorsByType("tsla"), function(actor)
			actor.Kill()
		end)
		Trigger.AfterDelay(30, function()
			SendReinforcements()
		end)
	end)
end

GiveAirstrike = function()
        Strike = Actor.Create("powerproxy.napalmstrike", true, {Owner = Spain})
end

SendAirstrike = function(actor)
        local location = actor.Location
        Trigger.AfterDelay(25, function()
                local proxy = Actor.Create("powerproxy.napalmstrike", false, { Owner = Germany })
                proxy.SendAirstrikeFrom(StartPointLST.Location, actor.Location)
                Trigger.AfterDelay(25, function()
                        proxy.SendAirstrikeFrom(StartPointLST.Location, actor.Location)
                        proxy.Destroy()
                end)
        end)
end


Win = function() 
	Media.PlaySpeechNotification(Spain, "ObjectiveMet")
	Trigger.AfterDelay(DateTime.Seconds(1), function()
		Spain.MarkCompletedObjective(NavalYard)
	end)
end

InitNeedful = function()
        Trigger.OnObjectiveAdded(Spain, function(p, id)
                Media.DisplayMessage(p.GetObjectiveDescription(id), "New " .. string.lower(p.GetObjectiveType(id)) .. " objective")
        end)

        Trigger.OnObjectiveCompleted(Spain, function(p, id)
                Media.DisplayMessage(p.GetObjectiveDescription(id), "Objective completed")
        end)

        Trigger.OnObjectiveFailed(Spain, function(p, id)
                Media.DisplayMessage(p.GetObjectiveDescription(id), "Objective failed")
        end)

        Trigger.OnPlayerLost(Spain, function()
                Media.PlaySpeechNotification(Spain, "MissionFailed")
        end)

        Trigger.OnPlayerWon(Spain, function()
                Trigger.AfterDelay(DateTime.Seconds(1), function() Media.PlaySpeechNotification(Spain, "MissionAccomplished")  end)
        end)

	ClearAAPost = Spain.AddPrimaryObjective("Destroy air defense")
	Inflitrate = Spain.AddPrimaryObjective("Disable power to defeses")
	NavalYard = Spain.AddPrimaryObjective("Destroy naval yard")
	
	Trigger.OnAllKilled(AABase, function() SendSabetourTeam() end)
	Trigger.OnAllKilled(MainBase, function() Win() end)
	Trigger.OnDiscovered(Actor253.CenterPosition,function(discoverer) 
		if discoverer.Owner == Spain then
			GDI = Player.GetPlayer("GDI")
			Reinforcements.ReinforceWithTransport(GDI, "tran", {"e1r1", "e1r1", "chan", "chan", "gnrl"}, {CPos.New(1,1), CPos.New(7,11)})
			Trigger.AfterDelay(100, function()
				Media.DisplayMessage("What the hell are UNBWC Choppers doing here?", "Cpl. Thompson", Spain.Color)
			end)
		end
	end)
end

WorldLoaded = function()
        Spain = Player.GetPlayer("Spain")
        Germany = Player.GetPlayer("Germany")
        Zombies = Player.GetPlayer("BadGuy")
        Civilian = Player.GetPlayer("Civilians")
	InitNeedful()
		
	local lz = BadgerDropPoint1.Location
	Camera.Position = BadgerDropPoint1.CenterPosition
	Trigger.AfterDelay(45, function()
		local transport = Actor.Create("badr", true, { CenterPosition = BadgerStartPoint.CenterPosition, Owner = Spain})
		Utils.Do(ParadropUnitTypes, function(type)
			local a = Actor.Create(type, false, { Owner = Spain })
			transport.LoadPassenger(a)
		end)

		transport.Paradrop(lz)
	end)
end
