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

function awards.register_onDig(func)
	table.insert(awards.onDig,func);
end

-- List a player's achievements
minetest.register_chatcommand("list_awards", {
	params = "",
	description = "list_awards: list your awards",
	func = function(name, param)
		minetest.chat_send_player(name, "Your awards:");

		for i=1,# player_data[name]['unlocked'] do
			print(player_data[name]['unlocked'][i])
			minetest.chat_send_player(name, ">> "..player_data[name]['unlocked'][i]);
		end
	end,
})


-- Example Achievements
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