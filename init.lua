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
awards.register_achievement("award_woodplace",{
	title = "Foundations",
	description = "First Wood Placed!",
})

awards.register_onPlace(function(player,data)
	if not data['place']['default'] or not data['place']['default']['wood'] then
		return
	end

	if data['place']['default']['wood'] > 0 then
		return "award_woodplace"
	end
end)