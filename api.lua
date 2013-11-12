-- AWARDS
-- by Rubenwardy, CC-BY-SA
-------------------------------------------------------
-- this is api function file
-------------------------------------------------------

-- The global award namespace
awards = {}

-- Table Save Load Functions
function awards.save()
	local file = io.open(minetest.get_worldpath().."/awards.txt", "w")
	if file then
		file:write(minetest.serialize(awards.players))
		file:close()
	end
end

function awards.load()
	local file = io.open(minetest.get_worldpath().."/awards.txt", "r")
	if file then
		local table = minetest.deserialize(file:read("*all"))
		if type(table) == "table" then
			return table
		end
	end
	return {}
end

awards.players = awards.load()
function awards.player(name)
	return awards.players[player]
end

-- A table of award definitions
awards.def = {}

function awards.tbv(tb,value,default)
	if not default then
		default = {}
	end
	if not tb or type(tb) ~= "table" then
		if not value then
			value = "[NULL]"
		end
		print("[ERROR] awards.tbv - table '"..value.."' is null, or not a table! Dump: "..dump(tb))
		return
	end
	if not value then
		print("[ERROR] awards.tbv was not used correctly!")
		print("Value: '"..dump(value).."'")
		print("Dump:"..dump(tb))
		return
	end
	if not tb[value] then
		tb[value] = default
	end
end

function awards.assertPlayer(playern)
	awards.tbv(awards.players, playern)
	awards.tbv(awards.players[playern], "name", playern)
	awards.tbv(awards.players[playern], "unlocked")
	awards.tbv(awards.players[playern], "place")
	awards.tbv(awards.players[playern], "count")
	awards.tbv(awards.players[playern], "deaths", 0)
end

-- Load files
dofile(minetest.get_modpath("awards").."/triggers.lua")
dofile(minetest.get_modpath("awards").."/config.txt")

-- API Functions
function awards.register_achievement(name,data_table)
	-- see if a trigger is defined in the achievement definition
	if data_table.trigger and data_table.trigger.type then
		if data_table.trigger.type=="dig" then
			local tmp={
				award=name,
			 	node=data_table.trigger.node,
			 	target=data_table.trigger.target,
			}
			table.insert(awards.onDig,tmp)
		elseif data_table.trigger.type=="place" then
			local tmp={
				award=name,
			 	node=data_table.trigger.node,
			 	target=data_table.trigger.target,
			}
			table.insert(awards.onPlace,tmp)
		elseif data_table.trigger.type=="death" then
			local tmp={
				award=name,
			 	target=data_table.trigger.target,
			}
			table.insert(awards.onDeath,tmp)
		end
	end

	-- check icon, background and custom_announce data
	if data_table.icon == nil or data_table.icon == "" then
		data_table.icon = "unknown.png"
	end
	if data_table.background == nil or data_table.background == "" then
		data_table.background = "bg_default.png"
	end
	if data_table.custom_announce == nil or data_table.custom_announce == "" then
		data_table.custom_announce = "Achievement Unlocked:"
	end
	
	-- add the achievement to the definition table
	awards.def[name] = data_table
end

-- this function adds a trigger function or table to the ondig table
function awards.register_onDig(func)
	table.insert(awards.onDig,func);
end

-- this function adds a trigger function or table to the ondig table
function awards.register_onPlace(func)
	table.insert(awards.onPlace,func);
end

-- this function adds a trigger function or table to the ondeath table
function awards.register_onDeath(func)
	table.insert(awards.onDeath,func);
end

-- This function is called whenever a target condition is met.
-- It checks if a player already has that achievement, and if they do not,
-- it gives it to them
----------------------------------------------
--awards.give_achievement(name,award)
-- name - the name of the player
-- award - the name of the award to give
function awards.give_achievement(name,award)
	-- Access Player Data
	local data=awards.players[name]
	
	-- Perform checks
	if not data then
		return
	end
	if not awards.def[award] then
			return
	end
	awards.tbv(data,"unlocked")

	-- check to see if the player does not already have that achievement
	if not data.unlocked[award] or data.unlocked[award]~=award then
		-- Set award flag
		data.unlocked[award]=award

		-- Get data from definition tables
		local title = award
		local desc = ""
		local background = ""
		local icon = ""
		local custom_announce = ""
		if awards.def[award].title then
			title = awards.def[award].title
		end
		if awards.def[award].custom_announce then
			custom_announce = awards.def[award].custom_announce
		end
		if awards.def[award].background then
			background = awards.def[award].background
		end
		if awards.def[award].icon then
			icon = awards.def[award].icon
		end
		if awards.def[award] and awards.def[award].description then
			desc = awards.def[award].description
		end

		-- send the won award message to the player
		if Use_Formspec == true then
			-- use a formspec to send it
			minetest.show_formspec(name, "achievements:unlocked", "size[4,2]"..
					"image_button_exit[0,0;4,2;"..background..";close1; ]"..
					"image_button_exit[0.2,0.8;1,1;"..icon..";close2; ]"..
					"label[1.1,1;"..title.."]"..
					"label[0.3,0.1;"..custom_announce.."]")
		else
			-- use the chat console to send it
			minetest.chat_send_player(name, "Achievement Unlocked: "..title)
			if desc~="" then
				minetest.chat_send_player(name, desc)
			end
		end
	
		-- record this in the log	
		print(name.." Has unlocked"..title..".")
		
		-- save playertable
		awards.save()
	end
end

-- List a player's achievements
minetest.register_chatcommand("list_awards", {
	params = "",
	description = "list_awards: list your awards",
	func = function(name, param)
		if not awards.players[name] or not awards.players[name].unlocked  then
			minetest.chat_send_player(name, "You do not have any awards")
			return
		end

		minetest.chat_send_player(name, name.."'s awards:")

		for _, str in pairs(awards.players[name].unlocked) do
			minetest.chat_send_player(name, str);
		end
	end,
})

