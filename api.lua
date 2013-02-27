-- Table Save Load Functions
function save_playerD()
	local file = io.open(minetest.get_worldpath().."/awards.txt", "w")
	if file then
		file:write(minetest.serialize(player_data))
		file:close()
	end
end

local function load_playerD()
	local file = io.open(minetest.get_worldpath().."/awards.txt", "r")
	if file then
		local table = minetest.deserialize(file:read("*all"))
		if type(table) == "table" then
			return table
		end
	end
	return {}
end

-- The global award namespace
awards={}
player_data=load_playerD()

-- A table of award definitions
awards.def={}

-- Load files
dofile(minetest.get_modpath("awards").."/triggers.lua")
dofile(minetest.get_modpath("awards").."/config.txt")

-- API Functions
function awards.register_achievement(name,data_table)
	-- see if a trigger is defined in the achievement definition
	if data_table['trigger'] and data_table['trigger']['type'] then
		if data_table['trigger']['type']=="dig" then
			local tmp={
				award=name,
			 	node=data_table['trigger']['node'],
			 	target=data_table['trigger']['target'],
			}
			table.insert(awards.onDig,tmp)
		elseif data_table['trigger']['type']=="place" then
			local tmp={
				award=name,
			 	node=data_table['trigger']['node'],
			 	target=data_table['trigger']['target'],
			}
			table.insert(awards.onPlace,tmp)
		elseif data_table['trigger']['type']=="death" then
			local tmp={
				award=name,
			 	target=data_table['trigger']['target'],
			}
			table.insert(awards.onDeath,tmp)
		end
	end

	-- check icon, background and custom_announce data
	if data_table['icon'] == nil or data_table['icon'] == "" then
		data_table['icon'] = "unknown.png"
	end
	if data_table['background'] == nil or data_table['background'] == "" then
		data_table['background'] = "bg_default.png"
	end
	if data_table['custom_announce'] == nil or data_table['custom_announce'] == "" then
		data_table['custom_announce'] = "Achievement Unlocked:"
	end
	
	-- add the achievement to the definition table
	awards['def'][name] = data_table
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
	-- load the player's data table
	local data=player_data[name]

	-- check if the table that holds a player's achievements exists
	if not data['unlocked'] then
		data['unlocked']={}
	end
	
	-- check to see if the player does not already have that achievement
	if not data['unlocked'][award] or data['unlocked'][award]~=award then
		-- save the achievement to the player_data table
		data['unlocked'][award]=award

		-- define local variables, so award data can be saved
		local title = award
		local desc = ""

		-- check definition table to get values
		if awards['def'][award] and awards['def'][award]['title'] and awards['def'][award]['custom_announce'] and awards['def'][award]['background'] and awards['def'][award]['icon'] then
			title=awards['def'][award]['title']
			background=awards['def'][award]['background']
			icon=awards['def'][award]['icon']
			custom_announce=awards['def'][award]['custom_announce']
		end
		
		-- check definition table to get description
		if awards['def'][award] and awards['def'][award]['description'] then
			desc=awards['def'][award]['description']
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
		save_playerD()
	end
end

-- List a player's achievements
minetest.register_chatcommand("list_awards", {
	params = "",
	description = "list_awards: list your awards",
	func = function(name, param)
		minetest.chat_send_player(name, name.."'s awards:");

		for _, str in pairs(player_data[name].unlocked) do
			minetest.chat_send_player(name, str);
		end
	end,
})

