BuildUnits = function(weap)
	if not weap.IsDead then
		weap.Produce('htnk')
		weap.Produce('htnk')
		weap.Produce('htnk')
		Trigger.AfterDelay(DateTime.Seconds(1), function() Utils.Do(soviet.GetActorsByType('htnk'), function(tnk) tnk.AttackMove(SOL.Location) end) end)
		Trigger.AfterDelay(DateTime.Minutes(5), function() BuildUnits(weap) end)
	end
end
SendGuard = function()
	Trigger.AfterDelay(DateTime.Minutes(5), function()
		Reinforcements.Reinforce(guard, {'e1','e1','mtnk', 'e1','e1'}, {Actor657.Location, Actor629.Location}, 25, function(a) 
			a.AttackMove(Actor608.Location)
		end)
	end)
	Trigger.AfterDelay(DateTime.Minutes(15), function() SendGuard() end)
end

WorldLoaded = function()
	soviet = Player.GetPlayer('Soviet')
	terror = Player.GetPlayer('Fort')
	guard = Player.GetPlayer('NatGuard')
	
	Trigger.AfterDelay(DateTime.Minutes(1), function() 
		Utils.Do(guard.GetActorsByType('e1'), function(g)
			g.Guard(SOL)
		end)
		Utils.Do(terror.GetActorsByType('terror'), function(t)
			t.Hunt()
		end)

		Utils.Do(soviet.GetActorsByTypes({ 'dred', 'e2', 'htnk' }), function(act)
			act.Hunt()
		end)
		Utils.Do(soviet.GetActorsByType('naweap'), function(weap)
			BuildUnits(weap)
		end)
		SendGuard()
	end)
end
