--	AWARDS
--		by Rubenwardy, CC-BY-SA
-------------------------------------------------------
-- this is the init file for the award mod
-------------------------------------------------------

local S
if (intllib) then
	dofile(minetest.get_modpath("intllib").."/intllib.lua")
	S = intllib.Getter(minetest.get_current_modname())
else
	S = function ( s ) return s end
end

dofile(minetest.get_modpath("awards").."/api.lua")

-- Light it up
awards.register_achievement("award_lightitup",{
	title = S("Light It Up"),
	description = S("Place 100 torches"),
	icon = "novicebuilder.png",
	trigger = {
		type = "place",
		node = "default:torch",
		target = 100
	}
})

-- Lumber Jack
awards.register_achievement("award_lumberjack",{
	title = S("Lumber Jack"),
	description = S("Dig 100 tree blocks"),
	trigger = {
		type = "dig",
		node = "default:tree",
		target = 100
	}
})

-- Found some Mese!
awards.register_achievement("award_mesefind",{
	title = S("First Mese Find"),
	description = S("Found some Mese!"),
	icon = "mese.png",
	background = "bg_mining.png",
	trigger = {
		type = "dig",
		node = "default:mese",
		target = 1
	}
})

-- Found a Nyan cat!
awards.register_achievement("award_nyanfind",{
	title = S("OMG, Nyan Cat!"),
	description = S("Find a nyan cat"),
	trigger = {
		type = "dig",
		node = "default:nyancat",
		target = 1
	}
})

-- Just entered the mine
awards.register_achievement("award_mine1",{
	title = S("Entering the mine"),
	description = S("You have dug 10 stone blocks"),
	icon = "miniminer.png",
	background = "bg_mining.png",
	trigger = {
		type = "dig",
		node = "default:stone",
		target = 10
	}
})

-- Mini Miner
awards.register_achievement("award_mine2",{
	title = S("Mini Miner"),
	description = S("You have dug 100 stone blocks"),
	icon = "miniminer.png",
	background = "bg_mining.png",
	trigger = {
		type = "dig",
		node = "default:stone",
		target = 100
	}
})

-- Hardened Miner
awards.register_achievement("award_mine3",{
	title = S("Hardened Miner"),
	description = S("You have dug 1000 stone blocks"),
	icon = "miniminer.png",
	background = "bg_mining.png",
	trigger = {
		type = "dig",
		node = "default:stone",
		target = 1000
	}
})

-- Master Miner
awards.register_achievement("award_mine4",{
	title = S("Master Miner"),
	description = S("You have dug 10000 stone blocks"),
	icon = "miniminer.png",
	background = "bg_mining.png",
	trigger = {
		type = "dig",
		node = "default:stone",
		target = 10000
	}
})

-- First Death
awards.register_achievement("award_death1",{
	title = S("First Death"),
	description = S("You have more lives than a cat!"),
	trigger = {
		type = "death",
		target = 1
	}
})

-- Burned to death
awards.register_achievement("award_burn",{
	title = S("You're a witch!"),
	description = S("Burn to death in a fire")
})

-- 1 sentence
awards.register_achievement("award_chat1",{
	title = S("First Word"),
	description = S("Use the chat to talk to players"),
	trigger = {
		type = "chat",
		target = 1
	}
})


-- Join
awards.register_achievement("award_join1",{
	title = S("Welcome!"),
	description = S("Connect to the server"),
	trigger = {
		type = "join",
		target = 1
	}
})

awards.register_onDeath(function(player,data)
	local pos = player:getpos()
	if pos and minetest.find_node_near(pos, 1, "fire:basic_flame") ~= nil then
		return "award_burn"
	end	
	return nil
end)