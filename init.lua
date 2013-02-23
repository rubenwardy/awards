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
		type="place",
		node="default:torch",
		target=100,
	},
})

-- Lumber Jack
awards.register_achievement("award_lumberjack",{
	title = "Lumber Jack",
	description = "You have dug 100 tree blocks",
	trigger={
		type="dig",
		node="default:tree",
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

-- Found a Nyan cat!
awards.register_achievement("award_nyanfind",{
	title = "OMG, Nyan Cat!",
	description = "Find a nyan cat",
	trigger={
		type="dig",
		node="default:nyancat",
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

-- First Death
awards.register_achievement("award_death1",{
	title = "First Death",
	description = "Oh well, it does not matter you have more lives than a cat",
	trigger={
		type="death",
		target=1,
	},
})

-- Burned to death
awards.register_achievement("award_burn",{
	title = "you're a witch!",
	description = "Burn to death in a fire",
})

awards.register_onDeath(function(player,data)
	print ("running on death function")
	local pos=player:getpos()

	if pos and minetest.env:find_node_near(pos, 1, "fire:basic_flame")~=nil then
		return "award_burn"
	end
	
	return nil
end)