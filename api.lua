-- AWARDS
--    by Rubenwardy
-------------------------------------------------------
-- this is api function file
-------------------------------------------------------

-- The global award namespace
awards = {
	show_mode = "hud"
}

-- Table Save Load Functions
function awards.save()
	local file = io.open(minetest.get_worldpath().."/awards.txt", "w")
	if file then
		file:write(minetest.serialize(awards.players))
		file:close()
	end
end

function awards.init()
	awards.players = awards.load()
	awards.def = {}
	awards.trigger_types = {}
	awards.on = {}
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

awards.init()

function awards.register_trigger(name, func)
	awards.trigger_types[name] = func
	awards.on[name] = {}
	awards['register_on_'..name] = function(func)
		table.insert(awards.on[name], func)
	end
end

-- API Functions
function awards._additional_triggers(name, def)
	-- Depreciated!
end

function awards.register_achievement(name, def)
	-- Add Triggers
	if def.trigger and def.trigger.type then
		local func = awards.trigger_types[def.trigger.type]

		if func then
			func(name, def)
		else
			awards._additional_triggers(name, def)
		end
	end

	-- check icon, background and custom_announce data
	if not def.icon or def.icon == "" then
		def.icon = "unknown.png"
	end
	if not def.background or def.background == "" then
		def.background = "bg_default.png"
	end
	if not def.custom_announce or def.custom_announce == "" then
		def.custom_announce = "Achievement Unlocked:"
	end

	-- add the achievement to the definition table
	def.name = name
	awards.def[name] = def
end

-- run a function when an item is crafted
function awards.register_onCraft(func)
	table.insert(awards.onCraft,func)
end

-- This function is called whenever a target condition is met.
-- It checks if a player already has that achievement, and if they do not,
-- it gives it to them
----------------------------------------------
--awards.give_achievement(name,award)
-- name - the name of the player
-- award - the name of the award to give
function awards.give_achievement(name, award)
	-- Access Player Data
	local data = awards.players[name]

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

		-- Give Prizes
		if awards.def[award] and awards.def[award].prizes then
			for i = 1, #awards.def[award].prizes do
				local itemstack = ItemStack(awards.def[award].prizes[i])
				if itemstack:is_empty() or not itemstack:is_known() then
					return
				end
				local receiverref = core.get_player_by_name(name)
				if receiverref == nil then
					return
				end
				receiverref:get_inventory():add_item("main", itemstack)
			end
		end

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
		if awards.show_mode == "formspec" then
			-- use a formspec to send it
			minetest.show_formspec(name, "achievements:unlocked", "size[4,2]"..
					"image_button_exit[0,0;4,2;"..background..";close1; ]"..
					"image_button_exit[0.2,0.8;1,1;"..icon..";close2; ]"..
					"label[1.1,1;"..title.."]"..
					"label[0.3,0.1;"..custom_announce.."]")
		elseif awards.show_mode == "chat" then
			-- use the chat console to send it
			minetest.chat_send_player(name, "Achievement Unlocked: "..title)
			if desc~="" then
				minetest.chat_send_player(name, desc)
			end
		else
			local player = minetest.get_player_by_name(name)
			local one = player:hud_add({
				hud_elem_type = "image",
				name = "award_bg",
				scale = {x = 1, y = 1},
				text = background,
				position = {x = 0.5, y = 0},
				offset = {x = 0, y = 138},
				alignment = {x = 0, y = -1}
			})
			local two = player:hud_add({
				hud_elem_type = "text",
				name = "award_au",
				number = 0xFFFFFF,
				scale = {x = 100, y = 20},
				text = "Achievement Unlocked!",
				position = {x = 0.5, y = 0},
				offset = {x = 0, y = 40},
				alignment = {x = 0, y = -1}
			})
			local three = player:hud_add({
				hud_elem_type = "text",
				name = "award_title",
				number = 0xFFFFFF,
				scale = {x = 100, y = 20},
				text = title,
				position = {x = 0.5, y = 0},
				offset = {x = 30, y = 100},
				alignment = {x = 0, y = -1}
			})
			local four = player:hud_add({
				hud_elem_type = "image",
				name = "award_icon",
				scale = {x = 4, y = 4},
				text = icon,
				position = {x = 0.5, y = 0},
				offset = {x = -81.5, y = 126},
				alignment = {x = 0, y = -1}
			})
			minetest.after(3, function()
				player:hud_remove(one)
				player:hud_remove(two)
				player:hud_remove(three)
				player:hud_remove(four)
			end)
		end

		-- record this in the log
		minetest.log("action", name.." has unlocked award "..title)

		-- save playertable
		awards.save()
	end
end

--[[minetest.register_chatcommand("gawd", {
	params = "award name",
	description = "gawd: give award to self",
	func = function(name, param)
		awards.give_achievement(name,param)
	end
})]]--

function awards.showto(name, to, sid, text)
	if name == "" or name == nil then
		name = to
	end
	if text then
		if not awards.players[name] or not awards.players[name].unlocked  then
			minetest.chat_send_player(to, "You have not unlocked any awards")
			return
		end
		minetest.chat_send_player(to, name.."'s awards:")

		for _, str in pairs(awards.players[name].unlocked) do
			local def = awards.def[str]
			if def then
				if def.title then
					if def.description then
						minetest.chat_send_player(to, def.title..": "..def.description)
					else
						minetest.chat_send_player(to, def.title)
					end
				else
					minetest.chat_send_player(to, str)
				end
			end
		end
	else
		if sid == nil or sid < 1 then
			sid = 1
		end
		local formspec = "size[11,5]"
		local listofawards = awards._order_awards(name)

		-- Sidebar
		if sid then
			local item = listofawards[sid+0]
			local def = awards.def[item.name]
			if def and def.secret and not item.got then
				formspec = formspec .. "label[1,2.75;Secret Award]"..
									"image[1,0;3,3;unknown.png]"
				if def and def.description then
					formspec = formspec	.. "label[0,3.25;Unlock this award to find out what it is]"
				end
			else
				local title = item.name
				if def and def.title then
					title = def.title
				end
				local status = ""
				if item.got then
					status = " (got)"
				end
				local icon = ""
				if def and def.icon then
					icon = def.icon
				end
				formspec = formspec .. "label[1,2.75;"..title..status.."]"..
									"image[1,0;3,3;"..icon.."]"
				if def and def.description then
					formspec = formspec	.. "label[0,3.25;"..def.description.."]"
				end
			end
		end

		-- Create list box
		formspec = formspec .. "textlist[4.75,0;6,5;awards;"
		local first = true
		for _,award in pairs(listofawards) do
			local def = awards.def[award.name]
			if def then
				if not first then
					formspec = formspec .. ","
				end
				first = false

				if def.secret and not award.got then
					formspec = formspec .. "#ACACACSecret Award"
				else
					local title = award.name
					if def and def.title then
						title = def.title
					end
					if award.got then
						formspec = formspec .. minetest.formspec_escape(title)
					else
						formspec = formspec .. "#ACACAC".. minetest.formspec_escape(title)
					end
				end
			end
		end
		formspec = formspec .. ";"..sid.."]"

		-- Show formspec to user
		minetest.show_formspec(to,"awards:awards",formspec)
	end
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname~="awards:awards" then
		return false
	end
	if fields.quit then
		return true
	end
	local name = player:get_player_name()
	if fields.awards then
		local event = minetest.explode_textlist_event(fields.awards)
		if event.type == "CHG" then
			awards.showto(name,name,event.index,false)
		end
	end

	return true
end)




-- Load files
dofile(minetest.get_modpath("awards").."/helpers.lua")
dofile(minetest.get_modpath("awards").."/triggers.lua")
