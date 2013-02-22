--	AWARDS
--	   by Rubenwardy, CC-BY-SA
-------------------------------------------------------
-- this is the api definition file for the awards mod
-------------------------------------------------------

-- Table Save Load Functions
local function save_playerD()
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

-- API Functions
function awards.register_achievement(name,data_table)
	awards['def'][name] = data_table
end

function awards.register_onDig(func)
	table.insert(awards.onDig,func);
end

function awards.register_onPlace(func)
	table.insert(awards.onPlace,func);
end

function awards.give_achievement(name,award)
	local data=player_data[name]

	if not data['unlocked'] then
		data['unlocked']={}
	end
	
	if not data['unlocked'][award] or data['unlocked'][award]~=award then
		-- set player_data table
		data['unlocked'][award]=award

		-- define local award data
		local title = award
		local desc = ""

		-- check definition table
		if awards['def'][award] and awards['def'][award]['title'] then
			title=awards['def'][award]['title']
		end
		
		if awards['def'][award] and awards['def'][award]['description'] then
			desc=awards['def'][award]['description']
		end

		-- send award header
		minetest.chat_send_player(name, "Achievement Unlocked: "..title)
		
		-- send award content
		if desc~="" then
			minetest.chat_send_player(name, desc)
		end
		
		-- save player_data table
		save_playerD()
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

awards.register_onPlace(function(player,data)
	if not data['place']['default'] or not data['place']['default']['mese'] then
		return
	end

	if data['place']['default']['mese'] > 0 then
		return "award_meseplace"
	end
end)