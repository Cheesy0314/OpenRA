AttackForceInfantry = {
	{ "e1", "e3", "e3" },
	{ "e1", "e1", "cyborg" },
}

AttackForceVehicle = {
	{ "bggy", "bggy" },
	{ "bike", "bggy" }
}

NodInf = { }
NodVeh = { }

InitAI = function(player)
	Nod = player
	InitAttacks()
end

InitAttacks = function()
	Trigger.AfterDelay(DateTime.Minutes(1), function()
		BuildInfantry()
	end)
	Trigger.AfterDelay(DateTime.Minutes(3), function()
		BuildVehicles()
	end)
end

BuildInfantry = function()
	if HandOfNod.IsDead then
		return
	end

	local delay = Utils.RandomInteger(DateTime.Seconds(3), DateTime.Seconds(9))
	local toBuild = Utils.Random(AttackForceInfantry)
	Nod.Build(toBuild, function(unit)
		NodInf[#NodInf + 1] = unit[1]
		if #NodInf >= 3 then
			SendUnits(NodInf, { CPos.New(61, 42) })
			NodInf = { }
			Trigger.AfterDelay(DateTime.Minutes(2), BuildInfantry)
		else
			Trigger.AfterDelay(delay, BuildInfantry)
		end
	end)
end

BuildVehicles = function()
        if WarFactory.IsDead then
                return
        end

        local delay = Utils.RandomInteger(DateTime.Seconds(9), DateTime.Seconds(18))
        local toBuild = Utils.Random(AttackForceVehicles)
        Nod.Build(toBuild, function(unit)
                NodVeh[#NodVeh + 1] = unit[1]
                if #NodVeh >= 2 then
                        SendUnits(NodVeh, { CPos.New(61, 42) })
                        NodVeh = { }
                        Trigger.AfterDelay(DateTime.Minutes(4), BuildVehicles)
                else
                        Trigger.AfterDelay(delay, BuildVehicles)
                end
        end)
end

SendUnits = function(units, waypoints)
	Utils.Do(units, function(unit)
		if not unit.IsDead then
			Utils.Do(waypoints, function(waypoint)
				unit.AttackMove(waypoint.Location)
			end)
			Trigger.OnIdle(unit, function() unit.Hunt() end)
		end
	end)
end


