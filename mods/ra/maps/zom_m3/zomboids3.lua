ScienceTeamUnits = {Scientist1,Scientist2,SciTeamLeader,SciLiason}
TeamFound = false
ticks = 1
AlliedForces = {Actor154,Actor155,Actor156,Actor157,Actor158,Actor159,Actor160,Actor161,Actor162,Actor163,Actor164,Actor165}
SovietForces = {"e4","e4", "e1r1"}
Group = {"zombie","zombie","zombie"}
Horde = {"zombie","zombie","zombie","zombie","zombie","zombie","zombie"}

SendSouthHorde = function()
	Reinforcements.Reinforce(BadGuy, Group, {ZedSpawn2.Location, CPos.New(30,50)}, 25, function(actor)
		actor.AttackMove(GermanLZ1.Location)
	end)
end

SendWestHorde = function()
        Reinforcements.Reinforce(BadGuy, Horde, {ZedSpawn1.Location, GermanConvoy.Location}, 25, function(actor)
		actor.Hunt()
        end)
end

CreateSovietFireteam = function()
	Reinforcements.Reinforce(Soviet, SovietForces, {SovBase.Location}, 25, function(actor)
		actor.AttackMove(ZedSpawn1.Location)
	end)
end

CreateZedTeam = function()
	Reinforcements.Reinforce(BadGuy, Horde, {ZedSpawn1.Location}, 25, function(zom) 
		zom.AttackMove(SovBase.Location)
	end)
end

FoundScienceTeam = function()
	SaveSciTeam = Spain.AddPrimaryObjective("Save Science Team")
        Trigger.OnAllKilled(ScienceTeamUnits, function() Lose() end)
	Utils.Do(ScienceTeamUnits, function(unit) 
		if not unit.IsDead() then
			unit.Owner = Spain
		end
	end)
        Media.DisplayMessage("You found the science team, clear the infected out and get them to the LZ!", "Mission Command", Civilian.Color)
	Media.PlaySpeechNotification(Spain, "AlliedForcesApproaching")
	TeamFound = true
        Trigger.AfterDelay(15, function() Spain.MarkCompletedObjective(FindSciTeam) end)
	Trigger.AfterDelay(65, function()
	Media.PlaySpeechNotification(Spain, "AlliedReinforcementsArrived")
	Reinforcements.ReinforceWithTransport(Germany, "tran", {"e1r1","e1r1","medi","e1r1","e3r1"}, {InsertionPoint.Location, ScienceTeam.Location},{ScienceTeam.Location, InsertionPoint.Location})
	Trigger.AfterDelay(50, function()
		Media.PlaySpeechNotification(Spain, "AlliedReinforcementsArrived")
		Reinforcements.Reinforce(Germany, {"tran"}, {CPos.New(1,1), GermanLZ2.Location}, 25, function(evac)
			eval.Move(GermanLZ1)
			Trigger.OnPassengerEntered(evac, function(trans, pass) 
				if  ScienceTeamUnits[pass] ~= nil then
					Win()
				end
			end)
		end)
	end)
	end)
end

Tick = function() 
	if TeamFound then
		ticks = ticks + 1
		if ticks == DateTime.Seconds(60) then
			SendWestHorde()
		elseif ticks == DateTime.Seconds(30) or ticks == DateTime.Seconds(120) then
			CreateSovietFireteam()
			CreateZedTeam()
		elseif ticks == DateTime.Seconds(160) then
			SendSouthHorde()
			ticks = 1
		end
	end
end

AlliesTurn = function()
	Utils.Do(Horde, function(zom) 
		Trigger.Delay(15, function()
			local a = Actor.Create(zom, true, { Owner = BadGuy })
			a.Hunt()
		end)
	end)
	Media.PlaySpeechNotification(Spain,"AlliedForcesFallen")
end

Win = function()
	Spain.MarkCompletedObjective(SaveSciTeam)
end

Lose = function() 
	Spain.MarkFailedObjective(SaveSciTeam)
end

FoundSovBase = function()
	Spain.MarkCompletedObjective(FindSovBase)
	Trigger.AfterDelay(110, function() Media.DisplayMessage("Good work, we found some documents about a bio research facility, destroy it") end)
	Trigger.AfterDelay(140, function()
		DestroyBioFact = Spain.AddSecondaryObjective("Destroy Bio-Research Facility")
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
	FindSciTeam = Spain.AddPrimaryObjective("Find Science Team")
	FindSovBase = Spain.AddSecondaryObjective("Find Enemy Base")
	Trigger.OnAllKilled({Actor51,Actor52,Actor53}, function()
		Media.PlaySpeechNotification(Spain, "SovietForcesFallen")
		Spain.MarkFailedObjective(FindSovBase)
	end)
        Trigger.OnEnteredProximityTrigger(ScienceTeam.CenterPosition, WDist.FromCells(1), function(actor, trigger1)
                if actor.Owner == Spain then
                        Trigger.RemoveProximityTrigger(trigger1)
			FoundScienceTeam()
                end
        end)
	Trigger.OnAnyKilled(AlliedForces, function(dead) 
		if dead == Actor160 then 
			AlliesTurn()
		else
			Actor.Create("zombie", true, {Owner = BadGuy, Location = dead.Location})
		end
	end)
end

WorldLoaded = function()
        Spain = Player.GetPlayer("Spain")
        Germany = Player.GetPlayer("Germany")
        BadGuy = Player.GetPlayer("BadGuy")
        Civilian = Player.GetPlayer("Civilians")
	SovietForces = Player.GetPlayer("Soviet")
        InitNeedful()
	Camera.Position = WPos.New(10,10,0)
	Trigger.AfterDelay(40, function()
		Media.PlaySpeechNotification(Spain,"ReinforcementsArrived")
		Reinforcements.Reinforce(Spain, {"mcv","1tnk","jeep","jeep"}, {InsertionPoint.Location, CPos.New(9,9)})
	end)
end
