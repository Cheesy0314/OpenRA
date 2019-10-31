ticks = 1
spawned = false
attackVectors = {NorthSpawn.Location, NESpawn.Location,EastSpawn.Location, SESpawn.Location, SouthSpawn.Location, SWSpawn.Location, WestSpawn.Location, NWSpawn.Location}
AttackPoint = Actor154.Location
smallHorde = {"zombie","zombie","zombie","zombie","zombie"}
mediumHorde = {"zombie","zombie","zombie","zombie","zombie","zombie","zombie","zombie"}
largeHorde = {"zombie","zombie","zombie","zombie","zombie","zombie","zombie","zombie","zombie","zombie","zombie","zombie","zombie","zombie","zombie","zombie"}
massiveHorde = {"zombie","zombie","zombie","zombie","zombie","zombie","zombie","zombie","zombie","zombie","zombie","zombie","zombie","zombie","zombie","zombie","zombie","zombie","zombie","zombie","zombie","zombie","zombie","zombie","zombie","zombie","zombie","zombie","zombie","zombie","zombie","zombie","zombie","zombie","zombie","zombie","zombie","zombie"}

hordeSizes = {smallHorde, mediumHorde, largeHorde, largeHorde}
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

Escape = function()
	spawned = true
	Media.DisplayMessage("Sir, we need to get out of here! There's an escape tunnel under the command center, we need to get there now.", "Virologist Smith", Spain.Color)
	Reinforcements.Reinforce(Spain, {"chan","gnrl"}, {CPos.New(15,11) , CPos.New(20,10)}, 25, function(a)
		a.Destroy()
		if a.Type == "chan" then
			Spain.MarkObjectiveCompleted(Survive)
		end
	end)
end

SendAllZed = function()
	Reinforcements.Reinforce(Zombies, massiveHorde, {NorthSpawn.Location}, 25, function(a) a.AttackMove(AttackPoint) end)
	Reinforcements.Reinforce(Zombies, massiveHorde, {EastSpawn.Location}, 25, function(a) a.AttackMove(AttackPoint) end)
	Reinforcements.Reinforce(Zombies, massiveHorde, {WestSpawn.Location}, 25, function(a) a.AttackMove(AttackPoint) end)
	Reinforcements.Reinforce(Zombies, massiveHorde, {SouthSpawn.Location}, 25, function(a) a.AttackMove(AttackPoint) end)
end

Tick = function()
	ticks = ticks + 1
	if ticks > DateTime.Seconds(60) and (ticks % DateTime.Seconds(30)) == 0  and ticks < DateTime.Minutes(5) then
                local v = attackVectors[Utils.RandomInteger(1,8)]
		Reinforcements.Reinforce(Zombies, smallHorde, {v}, 25, function(a) a.AttackMove(AttackPoint) end)
	elseif ticks > DateTime.Seconds(60) and (ticks % DateTime.Seconds(30)) == 0  and ticks < DateTime.Minutes(10) then
                local v = attackVectors[Utils.RandomInteger(1,8)]
                local v2 = attackVectors[Utils.RandomInteger(1,8)]
		Reinforcements.Reinforce(Zombies, mediumHorde, {v2},  25,function(a) a.AttackMove(AttackPoint) end)
		Reinforcements.Reinforce(Zombies, smallHorde, {v}, 25, function(a) a.AttackMove(AttackPoint) end)
		
	elseif ticks > DateTime.Minutes(10) and (ticks % DateTime.Seconds(30)) == 0  and ticks < DateTime.Minutes(15) then
		local v = attackVectors[Utils.RandomInteger(1,8)]
		local v2 = attackVectors[Utils.RandomInteger(1,8)]
		local v3 = attackVectors[Utils.RandomInteger(1,8)]
		local h1  = hordeSizes[Utils.RandomInteger(1,4)]
		local h2  = hordeSizes[Utils.RandomInteger(1,4)]
		local h3  = hordeSizes[Utils.RandomInteger(1,4)]
		Reinforcements.Reinforce(Zombies, h1, {v}, 25, function(a) a.AttackMove(AttackPoint) end)
		Reinforcements.Reinforce(Zombies, h2, {v3}, 25, function(a) a.AttackMove(AttackPoint) end)
		Reinforcements.Reinforce(Zombies, h3, {v2}, 25, function(a) a.AttackMove(AttackPoint) end)
	elseif ticks > DateTime.Minutes(15) and not spawned then
		Escape()
		SendAllZed()
	end
end

WorldLoaded = function()
        Spain = Player.GetPlayer("Spain")
        Germany = Player.GetPlayer("Germany")
        Zombies = Player.GetPlayer("BadGuy")
        Civilian = Player.GetPlayer("Civilians")
        InitNeedful()
	Trigger.AfterDelay(25, function()
		Actor104.Kill()
		Actor98.Kill()
		Media.DisplayMessage("Sir, we couldn't repair the refinery. The reactor in the ConYard went critical and we lost that too.", "Engineer Stevens", Spain.Color)
	end)

end
