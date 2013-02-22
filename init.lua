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

-- Table Save Load Functions
local function save(table, file)
	local file = io:open(file, "w")
	if file then
		file:write(minetest.serialize(table))
		file:close()
	end
end
 
local function load(file)
	local file = io:open(file, "r")
	if file then
		local table = minetest.deserialize(file:read("*all"))
		if type(table) == "table" then
			return table
		end
	end
	return {}
end


-- API Functions
function awards.register_achievement(name,data_table)
	data_table["name"] = name
	table.insert(awards.def,data_table);
end

function awards.register_onDig(func)
	table.insert(awards.onDig,func);
end

function awards.give_achievement(name,award)
	local data=player_data[name]

	if not data['unlocked'] then
		data['unlocked']={}
	end
	
	if not data['unlocked'][award] or data['unlocked'][award]~=award then
		data['unlocked'][award]=award
		minetest.chat_send_player(name, "Achievement Unlocked: "..award)
	end
end

-- List a player's achievements
minetest.register_chatcommand("list_awards", {
	params = "",
	description = "list_awards: list your awards",
	func = function(name, param)
		minetest.chat_send_player(name, "Your awards:");

		for _, str in pairs(player_data[name].unlocked) do
			minetest.chat_send_player(name, str);
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