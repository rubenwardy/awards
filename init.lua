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
	trigger={
		type="dig",
		node="default:mese",
		target=1,
	},
})

awards.register_onDig(function(player,data)
	return nil
end)

-- First Brick Placed!
awards.register_achievement("award_foundations",{
	title = "Foundations",
	description = "Every house starts from its foundations!",
	trigger={
		type="place",
		node="default:brick",
		target=1,
	},
})