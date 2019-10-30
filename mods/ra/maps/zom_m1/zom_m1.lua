LandingForce = {"4tnk", "4tnk", "4tnk", "4tnk", "4tnk"}
EnemyForces = {"e1r1","e1r1","e3","e3","e3","e3","gnrl"}
ParadropUnitTypes = {"rmbo","e1r1","e1r1", "e3r1","e3r1"}
ParadropUnitTypes2 = {"jeep","jeep","jeep","1tnk","1tnk"}
AABase = {radar, SAM1, SAM2, SAM3, SAM4, SAM5, SAM6, AA1, AA2 }
Beachhead = {Actor140,Actor141,Actor142,Actor143}
MainBase = {Actor40,Actor41,Actor42,Actor43,Actor44,Actor45,Actor46,Actor47,Actor48,Actor49,Actor50,Actor51}
FlareType = "flare"

SendHelo = function()
	Spain.MarkCompletedObjective(ClearAAPost)
	Spain.GetActorsByTypes({"rmbo", "e1r1", "e3r1"}, function(a)
		a.Owner = Civilian
	end)

	Actor.Create(FlareType, true, { Owner = Spain, Location = BadgerDropPoint3.Location })
        Trigger.AfterDelay(45, function()
                local transport = Actor.Create("badr", true, { CenterPosition = WPos.New(0,0,210), Owner = Zombies})
		Utils.Do(EnemyForces, function(soldier)
			local a = Actor.Create(soldier, false, {Owner = Zombies})
			transport.LoadPassenger(a)
		end)
		transport.Paradrop(CPos.New(44,16))
	end)
	transAndRef = Reinforcements.ReinforceWithTransport(Spain, "tran", {"rmbo", "e3r1","e3r1","e3r1","medi"}, {BadgerStartPoint.Location, BadgerDropPoint3.Location})
			
	Trigger.OnAllKilled(transAndRef[2], function()
		if not Spain.IsObjectiveCompleted(Infiltrate) then
			Spain.MarkFailedObjective(Infiltrate)
		end
	end)

	Media.DisplayMessage("We have sent you a strike team use them to destroy that powerbase.", "Mission Command", Civilian.Color)
	Camera.Position = BadgerDropPoint3.CenterPosition
	Trigger.OnKilled(PowerBaseControl, function()
                DestroyPowerbase()
        end)
end

SendReinforcements = function() 
	Media.PlaySpeechNotification(Spain, "ObjectiveMet")
	Media.DisplayMessage("Good work the defenses have been lowered. AirCommand is sending in a strike to clear the beach for you.", "Misson Command", Civilian.Color)
	Actor.Create(FlareType, true, { Owner = Spain, Location = EndPointLST.Location })	
	Utils.Do(Beachhead, function(target) 
		SendAirstrike(target)
	end)
	Camera.Position = EndPointLST.CenterPosition
	Trigger.OnAllKilled(Beachhead, function()
		GiveParatroopers()
		Media.PlaySpeechNotification(Spain, "ReinforcementsArrived")
		Reinforcements.ReinforceWithTransport(Spain, "lst", LandingForce, {StartPointLST.Location, EndPointLST.Location},nil)
	end)
end

DestroyPowerbase = function()
	Utils.Do(Zombies.GetActorsByType("apwr"), function(actor)
		actor.Kill()
	end)
	Trigger.AfterDelay(100, function()
		Media.PlaySpeechNotification(Spain,"ObjectiveMet")
		Spain.MarkCompletedObjective(Infiltrate)
		Utils.Do(Zombies.GetActorsByType("tsla"), function(actor)
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

GiveParatroopers = function()
	Para = Actor.Create("powerproxy.paratroopers", true, {Owner = Spain})
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
	Infiltrate = Spain.AddPrimaryObjective("Disable power to defeses")
	NavalYard = Spain.AddPrimaryObjective("Destroy naval yard")
	
	Trigger.OnAllKilled(AABase, function() SendHelo() end)
	Trigger.OnAllKilled(MainBase, function() Win() end)
	Trigger.OnEnteredProximityTrigger(Actor253.CenterPosition, WDist.New(22), function(discoverer, trigID)
		if discoverer.Owner == Spain then
			Trigger.RemoveProximityTrigger(trigID)
			Reinforcements.ReinforceWithTransport(GDI, "tran", {"e1r1", "e1r1", "chan", "chan", "gnrl"}, {CPos.New(1,1), CPos.New(7,11)}, { CPos.New(7,11), CPos.New(1,1)})
			Media.DisplayMessage("What the hell are BWC Troops doing here?", "Cpl. Thompson", Spain.Color)
			Trigger.AfterDelay(100, function() Media.DisplayMessage("They're supposed to be on our side, why are they attacking us!", "Cpl. Thompson", Spain.Color)  end)
		end
	end)
	Trigger.OnKilled(radar, function()
		Media.DisplayMessage("We've lost communications with the island, send more troops to primary installation.", "Enemy Comms Officer", Zombies.Color)
		Reinforcements.ReinforceWithTransport(BadGuys, "apc", {"e3r1","e3r1", "e3r1", "e1r1","e1r1"}, {CPos.New(1,60), CPos.New(20,60)}, {CPos.New(20,60),CPos.New(1,60)})
	end)
end

WorldLoaded = function()
        Spain = Player.GetPlayer("Spain")
        Germany = Player.GetPlayer("Germany")
        Zombies = Player.GetPlayer("BadGuy")
        Civilian = Player.GetPlayer("Civilians")
	GDI = Player.GetPlayer("GDI")
	InitNeedful()
		
	local lz = BadgerDropPoint1.Location
	Camera.Position = BadgerDropPoint1.CenterPosition
	Trigger.AfterDelay(45, function()
		local transport = Actor.Create("badr", true, { CenterPosition = BadgerStartPoint.CenterPosition, Owner = Spain})
		Utils.Do(ParadropUnitTypes, function(type)
			local a = Actor.Create(type, false, { Owner = Spain })
			if a.Type == "rmbo" then
				Trigger.OnKilled(a, function()
					if not Spain.IsObjectiveCompleted(ClearAAPost) then
						Spain.MarkFailedObjective(ClearAAPost)
					end
				end)
			end
			transport.LoadPassenger(a)
		end)

		transport.Paradrop(lz)
		end)
end
