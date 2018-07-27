TentBuilt = false
DeployedMCV = false

WorldLoaded = function()
	Allies = Player.GetPlayer("Spain")
	BadGuy = Player.GetPlayer("BadGuy")
	USSR = Player.GetPlayer("USSR")
	England = Player.GetPlayer("England")
	Camera.Position = DefaultCameraPosition.CenterPosition
	InitObjectives()
end
HiveWaypoints = {waypoint60, waypoint58, waypoint64, waypoint52, waypoint56, waypoint62, waypoint54}
IsHiveGased = { 
	NorthEast = false,
	East = false,
	SouthEast = false,
	Middle = false,
	South = false,
	NorthWest = false,
	SouthEast = false
}

HiveNameMap = {}

InitObjectives = function()
	GasAllHives = Allies.AddPrimaryObjective("Destroy all ant hives!")
	InitHiveMap()
	InitTriggers()
end

InitHiveMap = function()
	HiveNameMap[waypoint60] = "NorthEast"
	HiveNameMap[waypoint58] = "East"
	HiveNameMap[waypoint64] = "SouthEast"
	HiveNameMap[waypoint52] = "Middle"
	HiveNameMap[waypoint56] = "South"
	HiveNameMap[waypoint62] = "NorthWest"
	HiveNameMap[waypoint54] = "SouthWest"
end

InitTriggers = function()
	--Reinforce with 2 APCs (when base power built, or when 30 seconds pass?)
	--Reinforce with scientist (When first proc built, or 60 seconds pass?)
	Utils.Do(HiveWaypoints, function(actor) 
		Trigger.OnEnteredProximityTrigger(actor.CenterPosition, WDist.FromCells(1), function(interloper, id)
			if (interloper.Owner == Allies and interloper.Type == "sci") then
				local hiveName = HiveNameMap[actor]
				IsHiveGased[hiveName] = true
				SpawnPoisonGas(actor.Location)
				Trigger.RemoveProximityTrigger(id)
			end
		end)
	end)
	--When gas hive: spawn 5-7 ants that die after 2 seconds, spawn some green flares. Then, if ants enter area kill them! (Area: 5-8 cells?) NOTE: don't stop spawning there, just kill the spawn.
	--Every 15-60 seconds send ant wave to base (1-5 ants?)
	--Place protective ants, when all dead spawn new batch? (5-10 ants?)
	--Mostly warrior ants, some scout is ok two. Use fire in defense places only?
	--If all scientists die, send 3 more. If they die then mission fail.
	--Bonus scientist if we cap soviet base? (Or canister troop?)
	--Spawn money crate from destroyed church
	--Limit units: e1,e2,e3,engi,medi  --  2tnk,apc,jeep,harv,v2,mine
	Trigger.OnCapture(Actor80, function(actor, captor, oldOwner, newOwner) 
		SpawnSpecialUnit(newOwner, oldOwner)
	end)
	Trigger.OnEnteredProximityTrigger(waypoint11.CenterPosition, WDist.FromCells(7), function(actor, id)
		if (actor.Owner == Allies) then
			Trigger.RemoveProximityTrigger(id)
			Trigger.AfterDelay(5, function()
				AddCamera()
				SpawnAntAttack({'ant','ant','ant','ant','ant'},{waypoint56.Location})
			end)
		end
	end)

	
end

SpawnPoisonGas = function(location) 
	local Gas = Actor.Create("poisongas",true, {Owner = England, Location = location})
	
	Trigger.AfterDelay(3, function()
		Trigger.OnEnteredProximityTrigger(Gas.CenterPosition, WDist.FromCells(8), function(individual, id)
			if (individual.Type == "ant" or individual.Type == "fireant" or individual.Type == "scoutant") then
				Trigger.AfterDelay(DateTime.Seconds(2), function() individual.Kill() end)
			end
		end)

		Trigger.AfterDelay(DateTime.Seconds(5), function()
			SpawnAntAttack({"ant","ant","ant","ant"}, {location})
		end)
	end)
	CheckRemainingHives()
end

CheckRemainingHives = function()
	local alive = false
	for hive, gased in pairs(IsHiveGased) do
		if not gased then
			alive = true
		end
	end
	
	if not alive then
		KillEverything = Allies.AddPrimaryObjective("Destroy all remaining ants.")
		Trigger.AfterDelay(2, function()
			if #USSR.GetActors() > 0 then
				Trigger.OnAllKilled(USSR.GetActors(), function() Allies.MarkCompletedObjective(KillEverything) end)
			else 
				Allies.MarkCompletedObjective(KillEverything)
			end
		end)
		Trigger.AfterDelay(10, function() Allies.MarkCompletedObjective(GasAllHives) end)

	end
end

AddCamera = function()
	RevealCamera = Actor.Create("camera",true,{Owner = Allies, Location = CPos.New(59,65)})
end

SpawnAntAttack = function(Ants, Path)
	Reinforcements.Reinforce(USSR, Ants, Path, DateTime.Seconds(1), function(actor)
		Trigger.OnIdle(actor, function(actor) actor.Hunt() end)
	end)
end

SpawnSpecialUnit = function(owner, loser)
	Reinforcements.ReinforceWithTransport(loser, "tran", {"extrm"}, {CPos.New(26,26), waypoint25.Location}, {CPos.New(42,26)}, function(transport, cargo)
		cargo[1].Flash(15)
		Trigger.AfterDelay(10, function() cargo[1].Owner = owner end)
	end)
end

SpawnAntDefense = function(Ants, Path, PatrolRoute, Hive)
	local created = Reinforcements.Reinforce(USSR, Ants, Path, DateTime.Seconds(1), function(actor)
		actor.Patrol(PatrolRoute)
	end)
	
	if not IsHiveGased[Hive] then
		Trigger.OnAllKilled(created, function()
			-- It's ok if we reach here at same time hive gets gased, they'll all die anyway
			SpawnAntDefense(Ants, Path, PatrolRoute, Hive)
		end)
	end
end

SpawnScientists = function()
	local cargo = Reinforcements.ReinforceWithTransport(England, "apc", {"sci","sci","sci","sci","sci","sci","sci"}, {CPos.New(102,92), waypoint32.Location},{CPos.New(102,92)})
	Media.PlaySpeechNotification(Allies, "AlliedReinforcementsEast")
	Trigger.AfterDelay(DateTime.Seconds(4), function() 
		Utils.Do(England.GetActorsByType("sci"), function(actor)
			actor.Owner = Allies
		
		end) 

		Trigger.AfterDelay(15, function() 
			Trigger.OnAllKilled(Allies.GetActorsByType("sci"), function()
				 SpawnReplacementScientist() 
			end) 
		end)
	end)	
end

SpawnReplacementScientist = function()
	local landingPoint = waypoint32.Location
	if (#Allies.GetActorsByType("fact") > 0) then
		local conYard = Allies.GetActorsByType("fact")[1]
		landingPoint = CPos.New(conYard.Location.X + 2, conYard.Location.Y + 2)
	end

	SendAlliedParatroops(landingPoint)
end

SendAlliedParatroops = function(location)
	local start = Map.CenterOfCell(Map.RandomEdgeCell()) + WVec.New(0, 0, Actor.CruiseAltitude("badr"))
	local transport = Actor.Create("badr", true, { CenterPosition = start, Owner = England, Facing = (Map.CenterOfCell(location) - start).Facing })

	Utils.Do({"sci","sci","sci","e1r1","e1r1"}, function(rocketman)
		local a = Actor.Create(rocketman, false, { Owner = Allies })
		transport.LoadPassenger(a)
	end)

	Media.PlaySpeechNotification(Allies, "ReinforcementsArrived")
	transport.Paradrop(location)
	Trigger.OnAllKilled(Allies.GetActorsByType("sci"), function() Allies.MarkFailedObjective(GasAllHives) end) 
end


Tick = function()
	if not DeployedMCV and #Allies.GetActorsByType("fact") == 1 then 
		DeployedMCV = true
		Media.PlaySpeechNotification(Allies, "ReinforcementsArrived")
		local conYard = Allies.GetActorsByType("fact")[1]
		Reinforcements.ReinforceWithTransport(Allies, "apc", {"e1","e1","e2","e2","e1"}, {CPos.New(102,92), conYard.Location}, {CPos.New(102,92)}, nil, function(transport) transport.Guard(conYard) end, 5)
		Reinforcements.ReinforceWithTransport(Allies, "apc", {"e3","e3","e3","e3","e3"}, {CPos.New(102,92), conYard.Location}, {CPos.New(102,92)}, nil, function(transport) transport.Guard(conYard) end, 5)
	end
	if (DeployedMCV and not TentBuilt and #Allies.GetActorsByType("tent") > 0) then
		TentBuilt = true
		SpawnScientists()
	end
	
	
end
