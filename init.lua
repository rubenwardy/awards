--	AWARDS
--	   by Rubenwardy, CC-BY-SA
-------------------------------------------------------
-- this is the init file for the award mod
-------------------------------------------------------

dofile(minetest.get_modpath("awards").."/api.lua")

-- Light it up
awards.register_achievement("award_lightitup",{
	title = "Light It Up",
	description = "You have placed 100 torches",
	trigger={
		type="dig",
		node="default:tree",
		target=100,
	},
})

-- Lumber Jack
awards.register_achievement("award_lumberjack",{
	title = "Lumber Jack",
	description = "You have dug 100 tree blocks",
	trigger={
		type="dig",
		node="default:torch",
		target=100,
	},
})

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

-- Just entered the mine
awards.register_achievement("award_mine1",{
	title = "Just Entered the mine",
	description = "You have dug 10 stone blocks",
	trigger={
		type="dig",
		node="default:stone",
		target=10,
	},
})

-- Mini Miner
awards.register_achievement("award_mine2",{
	title = "Mini Miner",
	description = "You have dug 100 stone blocks",
	trigger={
		type="dig",
		node="default:stone",
		target=100,
	},
})

-- Hardened Miner
awards.register_achievement("award_mine3",{
	title = "Hardened Miner",
	description = "You have dug 1000 stone blocks",
	trigger={
		type="dig",
		node="default:stone",
		target=1000,
	},
})

-- Master Miner
awards.register_achievement("award_mine4",{
	title = "Master Miner",
	description = "You have dug 10000 stone blocks",
	trigger={
		type="dig",
		node="default:stone",
		target=10000,
	},
})