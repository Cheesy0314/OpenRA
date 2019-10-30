ticks = 1
passengers = 0
MissionStarted = false
MissionCompleted = false
HordeLight = {"zombie","zombie","zombie","zombie","zombie","zombie","zombie","zombie","zombie","zombie"}
HordeHeavy = {"zombie","zombie","zombie","zombie","zombie","zombie","zombie","zombie","zombie","zombie","zombie","zombie","zombie","zombie","zombie","zombie","zombie","zombie","zombie","zombie","zombie","zombie","zombie","zombie","zombie","zombie","zombie"}
HordeSuperHeavy = {"zombie","zombie","zombie","zombie","zombie","zombie","zombie","zombie","zombie","zombie","zombie","zombie","zombie","zombie","zombie","zombie","zombie","zombie","zombie","zombie","zombie","zombie","zombie","zombie","zombie","zombie","zombie","zombie","zombie","zombie","zombie","zombie","zombie","zombie","zombie","zombie","zombie","zombie","zombie","zombie","zombie","zombie"}
BeginWaves = function()
	Trigger.AfterDelay(DateTime.Minutes(1), function()
		MissionStarted = true
	end)

end

SendNavy = function()
	Reinforcements.Reinforce(Civilian,{"pt"}, {CPos.New(1,14), CPos.New(5,14)},25,function(actor) actor.Hunt() end)
	Reinforcements.Reinforce(Civilian,{"pt"}, {CPos.New(1,26), CPos.New(5,26)},25,function(actor) actor.Hunt() end)
	Trigger.AfterDelay(50, function()
		Reinforcements.Reinforce(Civilian,{"dd"}, {CPos.New(1,18), CPos.New(6,18)},25,function(actor) actor.Hunt() Trigger.OnIdle(actor, function() actor.Move(CPos.New(6,18)) end) end)
		Reinforcements.Reinforce(Civilian,{"dd"}, {CPos.New(1,22), CPos.New(6,22)},25,function(actor) actor.Hunt() Trigger.OnIdle(actor, function() actor.Move(CPos.New(6,22)) end)end)
	end)
	
	Trigger.AfterDelay(75, function()
		Reinforcements.Reinforce(Civilian,{"ca"}, {CPos.New(1,16), CPos.New(4,16)},50,function(actor) Trigger.OnIdle(actor, function() actor.Hunt() end) end)
		Reinforcements.Reinforce(Civilian,{"ca"}, {CPos.New(1,24), CPos.New(4,24)},50,function(actor) Trigger.OnIdle(actor, function() actor.Hunt() end) end)
		Reinforcements.Reinforce(Civilian,{"ca"}, {CPos.New(1,20), CPos.New(4,20)},50,function(actor) Trigger.OnIdle(actor, function() actor.Hunt() end) end)
	end)

	Trigger.AfterDelay(100, function()
		mig1 = Actor.Create("mig", true, {Owner = Zombies, Location = CPos.New(30,2)})
		Trigger.OnAddedToWorld(mig1,function()
			local dest = Civilian.GetActorsByType("dd")[1]
			Trigger.OnIdle(mig1, function() mig1.Attack(dest) end)
			Trigger.OnDamaged(mig1, function() mig1.Kill() end)
		end)
	end)

	Trigger.AfterDelay(200, function() 
		mig2 = Actor.Create("mig", true, {Owner = Zombies, Location = CPos.New(30,33)})
		Trigger.OnAddedToWorld(mig2,function()
			local dest = Civilian.GetActorsByType("dd")[2]
			Trigger.OnIdle(mig2, function() mig2.Attack(dest) end)
			Trigger.OnDamaged(mig2, function() mig2.Kill() end)
		end)
	end)
end

Tick = function()
	if MissionStarted then
		SendZombies()
		ticks = ticks + 1
	end
end

SendZombies = function()
	if ticks < DateTime.Seconds(61) then
		if ticks == DateTime.Seconds(30) or  ticks == DateTime.Seconds(60) then
			Reinforcements.Reinforce(Zombies, {"e1r1","e1r1","e3r1","e3r1","e1r1"}, { Actor156.Location, Actor205.Location},15, function(actor)

				actor.AttackMove(Actor208.Location)
				Trigger.OnIdle(actor,function() actor.Hunt() end)
				
			end)
		end

 		if ticks == DateTime.Seconds(55) then
			Media.DisplayMessage("Commander, mission parameters have changed... We are receiving odd reports from other landing sites. We are trying to make sense of the situation. Sit tight until we can figure out what is happening.", "Mission Command", Civilian.Color) 
			Trigger.AfterDelay(1, function() Survive = Spain.AddPrimaryObjective("Defend beachhead") end)
			Trigger.AfterDelay(3, function() Spain.MarkCompletedObjective(Defend) end)
			
		end
	elseif (ticks > DateTime.Seconds(60) and ticks < DateTime.Seconds(121)) then
		if (ticks == DateTime.Seconds(90) or ticks == DateTime.Seconds(120)) then
				Reinforcements.Reinforce(Zombies, {"2tnk","jeep","1tnk","1tnk","jeep"}, { Actor196.Location, Actor205.Location}, 10, function(actor)
					actor.AttackMove(Actor208.Location)
					Trigger.OnIdle(actor,function() actor.Hunt() end)
				end)
			if ticks == DateTime.Seconds(120) then
				Trigger.AfterDelay(DateTime.Seconds(12), function()
				Reinforcements.Reinforce(Zombies, {"zombie","zombie","zombie","zombie","zombie"}, { Actor162.Location - CVec.New(2,0), Actor205.Location}, 10, function(actor)
					actor.AttackMove(Actor208.Location)
					Trigger.OnIdle(actor,function() actor.Hunt() end)
				end)
				end)
				Trigger.AfterDelay(DateTime.Seconds(10), function()
					local LST = Spain.GetActorsByType("lst")[1]
					actors = Reinforcements.Reinforce(Germany, {"e1","gnrl","e1","chan","e1r1"}, {Actor162.Location,Actor205.Location},15, function(actor) 
						actor.EnterTransport(LST)
					end)
					passengers = #actors
					Media.DisplayMessage("WHAT THE HELL IS THAT?", "Staff Sgt. Muller", Germany.Color)
					Media.PlaySoundNotification(Spain, "ChatLine")
				end)
			end
		end
	elseif (ticks > DateTime.Seconds(120) and ticks < DateTime.Seconds(241)) then
		if (ticks == DateTime.Seconds(160)) then Media.DisplayMessage("German scientist believe the crazed troops are the result of some sort of infectous disease, be careful!", "Mission Command", Civilian.Color) 
				Media.PlaySoundNotification(Spain, "ChatLine") end
		if (ticks == DateTime.Seconds(150) or ticks == DateTime.Seconds(180) or ticks == DateTime.Seconds(210) or ticks == DateTime.Seconds(240)) then
			Reinforcements.Reinforce(Zombies, HordeLight, {  Actor196.Location - CVec.New(2,0), Actor205.Location}, 10, function(actor)
				actor.AttackMove(Actor208.Location)
				Trigger.OnIdle(actor,function() actor.Hunt() end)
			end)

			Reinforcements.Reinforce(Zombies, HordeLight, { Actor198.Location, Actor205.Location}, 10, function(actor)
				actor.AttackMove(Actor208.Location)
				Trigger.OnIdle(actor,function() actor.Hunt() end)
			end)
		end
	elseif (ticks > DateTime.Seconds(240) and ticks < DateTime.Seconds(361)) then
		 if (ticks == DateTime.Seconds(270) or ticks == DateTime.Seconds(300) or ticks == DateTime.Seconds(330) or ticks == DateTime.Seconds(360)) then
			Reinforcements.Reinforce(Zombies, HordeHeavy, {  Actor196.Location - CVec.New(2,0), Actor205.Location}, 10, function(actor)
				actor.AttackMove(Actor208.Location)
				Trigger.OnIdle(actor,function() actor.Hunt() end)
			end)

			Reinforcements.Reinforce(Zombies, HordeLight, { Actor198.Location, Actor205.Location}, 10, function(actor)
				actor.AttackMove(Actor208.Location)
				Trigger.OnIdle(actor,function() actor.Hunt() end)
			end)
		end

		if (ticks == DateTime.Seconds(340)) then
			Media.DisplayMessage("The tissue samples collected seem to confirm the disease theory, deploy medics to protect your troops Commander.", "Mission Command", Civilian.Color)
			Media.PlaySoundNotification(Spain, "ChatLine")
		end

	elseif (ticks > DateTime.Seconds(360) and ticks < DateTime.Seconds(481)) then
		if (ticks == DateTime.Seconds(362)) then
		
			Media.PlaySoundNotification(Spain, "ChatLine")
			Media.DisplayMessage("TO ALL OPERATIONAL UNITS: WE HAVE BEGUN NAPALMING INFECTED CIVILIAN CENTERS! REMOVE FORCES FROM FORESTED AREAS IMMEDIATELY!", "German AirCommand", Germany.Color)
			Trigger.AfterDelay(DateTime.Seconds(5), function()
				Media.PlaySpeechNotification(Spain, "AlliedReinforcementsArrived")
				SendAirstrike(Actor198)
				SendAirstrike(Actor156) 
				SendAirstrike(Actor157)
				SendAirstrike(Actor158)
				SendAirstrike(Actor159)
				SendAirstrike(Actor160)
				SendAirstrike(Actor161)
				SendAirstrike(Actor162)

			end)
		end
		if (ticks == DateTime.Seconds(400)) then GiveAirstrike() end
		if (ticks == DateTime.Seconds(390) or ticks == DateTime.Seconds(420) or ticks == DateTime.Seconds(450) or ticks == DateTime.Seconds(480)) then
			if (ticks == DateTime.Seconds(450)) then GiveAirstrike() end
			Reinforcements.Reinforce(Zombies, HordeHeavy, {  Actor196.Location - CVec.New(2,0), Actor205.Location}, 10, function(actor)
				actor.AttackMove(Actor208.Location)
				Trigger.OnIdle(actor,function() actor.Hunt() end)
			end)
			Reinforcements.Reinforce(Zombies, HordeSuperHeavy, {  Actor196.Location - CVec.New(2,0), Actor205.Location}, 10, function(actor)
				actor.AttackMove(Actor208.Location)
				Trigger.OnIdle(actor,function() actor.Hunt() end)
			end)
		end
	elseif ticks > DateTime.Seconds(480) then
		if (#Zombies.GetActorsByType("zombie")) == 0 and not MissionCompleted then
			MissionCompleted = true
			Media.DisplayMessage("Good job holding the fort Commander, this area seems to be under control for now.","Mission Command", Civilian.Color)
			Trigger.AfterDelay(DateTime.Seconds(10), function()
				Spain.MarkCompletedObjective(Survive);
			end)
		end
	end
end

SendAirstrike = function(actor)
	local location = actor.Location
	Trigger.AfterDelay(25, function()
		local proxy = Actor.Create("powerproxy.napalmstrike", false, { Owner = Germany })
		proxy.SendAirstrikeFrom(CPos.New(1,16), actor.Location)
		Trigger.AfterDelay(25, function()
			proxy.SendAirstrikeFrom(CPos.New(1,16), actor.Location)
			proxy.Destroy()
		end)
	end)
end

GiveAirstrike = function()
	Strike = Actor.Create("powerproxy.napalmstrike", false, {Owner = Spain})
end

NextObj = function()
	Trigger.AfterDelay(1, function() Defend = Spain.AddPrimaryObjective("Fortify base and wait for further orders.") end)
	Trigger.AfterDelay(8, function() Spain.MarkCompletedObjective(Beach) end)
	Trigger.AfterDelay(50, function() Trigger.OnAllKilled(Spain.GetActorsByType('fact'), function() Spain.MarkFailedObjective(Defend) end) end)
	Trigger.AfterDelay(50, function()
		Media.PlaySoundNotification(Spain, "ChatLine")
		Media.DisplayMessage("Good work Commander the LZ is ours, build your base quickly and prepare for a counter attack.", "Mission Command", Civilian.Color)
	end)
	Trigger.AfterDelay(DateTime.Minutes(1), function() 
		local reinf = Spain.GetActorsByType("lst")
		Trigger.OnPassengerEntered(reinf[1], function(trans, actor)
			passengers = passengers - 1
			if passengers == 0 then
				reinf[1].Move(CPos.New(2,30)) Trigger.AfterDelay(DateTime.Seconds(5), function()
					reinf[1].Destroy()
				end)
			end
		end)
		BeginWaves() 
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
end

WorldLoaded = function()
	Spain = Player.GetPlayer("Spain")
	Germany = Player.GetPlayer("Germany")
	Zombies = Player.GetPlayer("BadGuy")
	Civilian = Player.GetPlayer("Civilians")
	InitNeedful()
	Beach = Spain.AddPrimaryObjective("Secure beach, then build a forward base.")
	Camera.Position = Actor10.CenterPosition
	Trigger.AfterDelay(DateTime.Seconds(2), function() Media.PlaySpeechNotification(Spain,"AlliedReinforcementsArrived")
		firstWave = Reinforcements.ReinforceWithTransport(Civilian, "lst", {"2tnk","2tnk","jeep"}, {CPos.New(3,30), CPos.New(16,22)},nil)
		Trigger.OnKilled(firstWave[1], function()
			Media.DisplayMessage("Command, First wave ineffective. We do not hold the beach, repeat, we do not hold the beach.", "ATF Baker-3 Actual", Civilian.Color)
		end)
		Trigger.OnAllKilled(firstWave[2], function()
			Media.PlaySpeechNotification(Spain,"AlliedForcesFallen")
			Trigger.AfterDelay(85, function()
				Media.PlaySpeechNotification(Spain,"AlliedReinforcementsWest")
				SendNavy()
			end)

			Trigger.OnAllKilled(Zombies.GetActorsByType("gun"), function() 
				Media.PlaySpeechNotification(Spain, "ReinforcementsArrived")
				Media.DisplayMessage("Hotel-2, prepare to make landfall", "Lt Willits", Spain.Color)
				local reinf = Reinforcements.ReinforceWithTransport(Spain, "lst", {"mcv", "jeep", "jeep", "truk", "truk"}, {CPos.New(3,30), CPos.New(16,22)},nil)
				Utils.Do(reinf[2], function(actor)
					Trigger.OnAddedToWorld(actor, function(self) 
						self.Owner = Spain  
						if self.Type == "mcv" then
							self.Move(Actor208.Location)
							Civilian.GetActorsByType("flare")[1].Destroy()
							Trigger.OnEnteredFootprint({Actor208.Location}, function(mcv, id)
								mcv.Deploy()
								Trigger.RemoveFootprintTrigger(id)
								NextObj()
							end)
						else
							self.Move(CPos.New(26, 12))
						end
					end)
				end)
			end)
		end)
	end)
end
