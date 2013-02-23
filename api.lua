
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
		end
	end

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

