--	AWARDS
--	   by Rubenwardy, CC-BY-SA
-------------------------------------------------------
-- this is the init file for the award mod
-------------------------------------------------------

dofile(minetest.get_modpath("awards").."/api.lua")

-- Found some Mese!
awards.register_achievement("award_mesefind",{
	title = "First Mese Find",
	description = "Found some Mese!",
})

awards.register_onDig(function(player,data)
	if not data['count']['default'] or not data['count']['default']['mese'] then
		return
	end

	if data['count']['default']['mese'] > 0 then
		return "award_mesefind"
	end
end)


-- First Wood Placed!
awards.register_achievement("award_foundations",{
	title = "Foundations",
	description = "Every house starts from its foundations!",
})

awards.register_onPlace(function(player,data)
	if not data['place']['default'] or not data['place']['default']['brick'] then
		return
	end

	if data['place']['default']['brick'] > 0 then
		return "award_foundations"
	end
end)