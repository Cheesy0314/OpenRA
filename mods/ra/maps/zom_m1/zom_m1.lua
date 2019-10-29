LandingForce = {"4tnk", "4tnk", "4tnk", "4tnk", "4tnk"}
ParadropUnitTypes = {"rmbo","e1r1","e1r1"}
ParadropUnitTypes2 = {"jeep","jeep","jeep","1tnk","1tnk"}
AABase = {radar, SAM1, SAM2, SAM3, SAM4, SAM5, SAM6, AA1, AA2 }
Beachhead = {Actor140,Actor141,Actor142,Actor143}
MainBase = {Actor40,Actor41,Actor42,Actor43,Actor44,Actor45,Actor46,Actor47,Actor48,Actor49,Actor50,Actor51}

SendReinforcements = function() 
	Spain.MarkCompletedObjective(ClearAAPost)
	Media.PlaySpeechNotification(Spain, "ObjectiveMet")
	Media.DisplayMessage("Good work, AirCommand is sending in a strike to clear the beach for you.", "Misson Command", Civilian.Color)
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
	Spain.MarkCompletedObjective(NavalYard)
	Media.PlaySpeechNotification(Spain, "ObjectiveMet")
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
	NavalYard = Spain.AddPrimaryObjective("Destroy naval yard")
	
	Trigger.OnAllKilled(AABase, function() SendReinforcements() end)
	Trigger.OnAllKilled(MainBase, function() Win() end)
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
