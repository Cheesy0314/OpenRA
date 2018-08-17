InitObjective = function()

end

WorldLoaded = function()
	GDI = Player.GetPlayer("GDI")
	Nod = Player.GetPlayer("Nod")
	Creeps = Player.GetPlayer("Creeps")
	Reinforcements.Reinforce(GDI, { "mcv", "smech", "smech", "e1", "e1", "e1" }, { Actor1.Location, Actor2.Location })
end
