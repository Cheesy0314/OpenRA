SupplyTruckDead = false

WorldLoaded = function()
	player = Player.GetPlayer("Greece")
	ussr = Player.GetPlayer("USSR")
	russia = Player.GetPlayer("BadGuy")
	Attacker1.Move(Church.Location, 3)
	Attacker1.Attack(Church, true, true)
	Attacker2.Move(Church.Location, 3)
	Attacker2.Attack(Church, true, true)
	ExtractBoatUSSR.Move(BadGuyLZ1.Location,1)
	BridgeDefender1.Attack(BridgeSE,true, true)
	BridgeDefender2.Attack(BridgeSE,true, true)
	BridgeDefender3.Attack(BridgeSE,true, true)
	triggerID = Trigger.OnPassengerEntered(ExtractBoatUSSR, function(trans, pass) 
		if trans.PassengerCount == 2 then
			ExtractBoatUSSR.Move(BadGuyLZ2.Location,1)
		elseif trans.PassengerCount == 3 then
			ExtractBoatUSSR.Move(OffMapNW.Location, 3)
			Trigger.OnEnteredProximityTrigger(OffMapNW.CenterPosition, WDist.New(3), function(actor, id)
				Trigger.RemoveProximityTrigger(id)
				Trigger.ClearAll(ExtractBoatUSSR)
				Trigger.AfterDelay(3, function() ExtractBoatUSSR.Destroy() end)
			end)
		end
	end)


	triggerID2 = Trigger.OnEnteredProximityTrigger(BadGuyLZ2.CenterPosition, WDist.New(2), function(actor, id)
		if actor == ExtractBoatUSSR then
			if SupplyTruckDead then
				ExtractBoatUSSR.Move(OffMapNW.Location, 3)
				Trigger.OnEnteredProximityTrigger(OffMapNW.CenterPosition, WDist.New(3), function(actor, id)
					Trigger.RemoveProximityTrigger(id)
					Trigger.ClearAll(ExtractBoatUSSR)
					Trigger.AfterDelay(3, function() ExtractBoatUSSR.Destroy() end)
				end)
			else
				SupplyTruck.Stop()
				SupplyTruck.EnterTransport(ExtractBoatUSSR)
				Trigger.RemoveProximityTrigger(id)
			end
		end
	end)

	Trigger.OnKilled(SupplyTruck, function(truck, killer) 
		Trigger.RemoveProximityTrigger(triggerID)
		Trigger.RemoveProximityTrigger(triggerID2)
		Trigger.ClearAll(ExtractBoatUSSR)
		SupplyTruckDead = true
		ExtractBoatUSSR.Move(OffMapNW.Location, 3)
		Trigger.OnEnteredProximityTrigger(OffMapNW.CenterPosition, WDist.New(3), function(actor, id)
			Trigger.RemoveProximityTrigger(id)
			Trigger.ClearAll(ExtractBoatUSSR)
			Trigger.AfterDelay(3, function() ExtractBoatUSSR.Destroy() end)
		end)
	end)

	Trigger.OnDamaged(Church, function() 
		SupplyTruck.Move(waypoint13.Location,0)
		Reinforcements.Reinforce(player, { "ctnk" }, { Teleport0.Location })
		Reinforcements.Reinforce(player, { "ctnk" }, { Teleport1.Location })
		Actor.Create("camera", true, { Owner = player, Location = RevealWP1.Location })
		Trigger.OnEnteredProximityTrigger(BadGuyLZ1.CenterPosition, WDist.New(3), function(actor,id) 
			if actor == ExtractBoatUSSR then
				Attacker1.Stop()
				Attacker2.Stop()
				Attacker1.EnterTransport(ExtractBoatUSSR)
				Attacker2.EnterTransport(ExtractBoatUSSR)		
				Trigger.RemoveProximityTrigger(id)
			end
		end)
		Trigger.ClearAll(Church)
	end)

	
	Camera.Position = Church.CenterPosition
end
