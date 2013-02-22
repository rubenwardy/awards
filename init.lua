--	AWARDS
--	   by Rubenwardy, CC-BY-SA
-------------------------------------------------------
-- this is the api definition file for the awards mod
-------------------------------------------------------

-- The global award namespace
awards={}
player_data={}

-- A table of award definitions
awards.def={}

-- Load files
dofile(minetest.get_modpath("awards").."/triggers.lua")


-- API Functions
function awards.register_achievement(name,data_table)
	data_table["name"] = name
	table.insert(awards.def,data_table);
end

function awards.register_onDig(data)
	table.insert(awards.onDig,data);
end

function awards:getNodeCount(nodeName)
	return self.count[nodeName]
end


-- Example Achievements
awards.register_achievement("award_mesefind",{
	title = "First Mese Find",
	description = "Found some Mese!",
})

awards.register_onDig({
	award="",
	func=function(player)

	end
})