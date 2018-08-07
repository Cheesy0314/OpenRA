InitObjectives = function()
	GDI.AddPrimaryObjective("YEETUS")
end

WorldLoaded = function()
	GDI = Player.GetPlayer("GDI")
	Nod = Player.GetPlayer("Nod")
	InitObjectives()
end
