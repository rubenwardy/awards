-- AWARDS
--
-- Copyright (C) 2013-2015 rubenwardy
-- This program is free software; you can redistribute it and/or modify
-- it under the terms of the GNU Lesser General Public License as published by
-- the Free Software Foundation; either version 2.1 of the License, or
-- (at your option) any later version.
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU Lesser General Public License for more details.
-- You should have received a copy of the GNU Lesser General Public License along
-- with this program; if not, write to the Free Software Foundation, Inc.,
-- 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
--

local S, NS = awards.gettext, awards.ngettext

awards.def = {}
awards.on = {}
awards.on_unlock = {}

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
			awards.players = table
		end
	end
	awards.players = {}
end
--
-- local function make_on_reg_wrapper()
-- 	return function(def)
-- 		local tmp = {
-- 			award  = def.name,
-- 			key    = def.trigger.node,
-- 			target = def.trigger.target,
-- 		}
-- 		table.insert(awards.on.dig, tmp)
--
-- 		function def:getProgress(data)
-- 			local itemcount
-- 			if tmp.key then
-- 				itemcount = data["dig"][tmp.key] or 0
-- 			else
-- 				itemcount = awards.get_total_keyed_count(data, "dig")
-- 			end
-- 			return {
-- 				perc = itemcount / tmp.target,
-- 				label = S("@1/@2 dug", itemcount, tmp.target),
-- 			}
-- 		end
--
-- 		function def:getDefaultDescription()
-- 			local n = self.trigger.target
-- 			if self.trigger.node then
-- 				local nname = minetest.registered_nodes[self.trigger.node].description
-- 				if nname == nil then
-- 					nname = self.trigger.node
-- 				end
-- 				-- Translators: @1 is count, @2 is description.
-- 				return NS("Mine: @2", "Mine: @1×@2", n, n, nname)
-- 			else
-- 				return NS("Mine @1 block.", "Mine @1 blocks.", n, n)
-- 			end
-- 		end
-- 	end
-- end

local function run_trigger_callbacks(self, player, data, table_func)
	for i = 1, #self.on do
		local res = nil
		local entry = self.on[i]
		if type(entry) == "function" then
			res = entry(player, data)
		elseif type(entry) == "table" and entry.award then
			res = table_func(entry)
		end

		if res then
			awards.unlock(player:get_player_name(), res)
		end
	end
end

function awards.register_trigger(tname, tdef)
	assert(type(tdef) == "table",
			"Passing a callback to register_trigger is not supported in 3.0")

	tdef.name = tname
	tdef.run_callbacks = run_trigger_callbacks

	if tdef.type == "counted" then
		local datakey = tname .. "s"
		local old_reg = tdef.on_register

		function tdef:on_register(def)
			local tmp = {
				award  = def.name,
				target = def.trigger.target,
			}
			tdef.register(tmp)

			function def.getProgress(_, data)
				local done = data[datakey] or 0
				return {
					perc = done / tmp.target,
					label = S(tdef.progress, done, tmp.target),
				}
			end

			function def.getDefaultDescription(_)
				local n = self.trigger.target
				return NS(tdef.auto_description[1], tdef.auto_description[2], n, n)
			end

			if old_reg then
				return old_reg(tdef, def)
			end
		end

		function tdef.notify(player)
			assert(player and player.is_player and player:is_player())
			local name = player:get_player_name()
			local data = awards.player(name)
			print(dump(data))

			-- Increment counter
			local currentVal = (data[datakey] or 0) + 1
			data[datakey] = currentVal

			tdef:run_callbacks(player, data, function(entry)
				if entry.target and entry.award and currentVal and
						currentVal >= entry.target then
					return entry.award
				end
			end)
		end

		awards["notify_" .. tname] = tdef.notify
	end

	awards.registered_triggers[tname] = tdef

	tdef.on = {}
	tdef.register = function(func)
		table.insert(tdef.on, func)
	end

	-- Backwards compat
	awards.on[tname] = tdef.on
	awards['register_on_' .. tname] = tdef.register
end

function awards.increment_item_counter(data, field, itemname, count)
	itemname = minetest.registered_aliases[itemname] or itemname
	data[field][itemname] = (data[field][itemname] or 0) + 1
end

function awards.get_item_count(data, field, itemname)
	itemname = minetest.registered_aliases[itemname] or itemname
	return data[field][itemname] or 0
end

function awards.get_total_keyed_count(data, field)
	return data[field].__total or 0
end

function awards.register_on_unlock(func)
	table.insert(awards.on_unlock, func)
end

function awards.register_achievement(name, def)
	def.name = name

	-- Add Triggers
	if def.trigger and def.trigger.type then
		local tdef = awards.registered_triggers[def.trigger.type]
		assert(tdef, "Trigger not found: " .. def.trigger.type)
		tdef:on_register(def)
	end

	-- Add Award
	awards.def[name] = def

	local tdef = awards.def[name]
	if def.description == nil and tdef.getDefaultDescription then
		def.description = tdef:getDefaultDescription()
	end
end

function awards.enable(name)
	local data = awards.player(name)
	if data then
		data.disabled = nil
	end
end

function awards.disable(name)
	local data = awards.player(name)
	if data then
		data.disabled = true
	end
end

function awards.clear_player(name)
	awards.players[name] = {}
end

-- This function is called whenever a target condition is met.
-- It checks if a player already has that achievement, and if they do not,
-- it gives it to them
----------------------------------------------
--awards.unlock(name, award)
-- name - the name of the player
-- award - the name of the award to give
function awards.unlock(name, award)
	-- Access Player Data
	local data  = awards.player(name)
	local awdef = awards.def[award]
	assert(awdef, "Unable to unlock an award which doesn't exist!")

	if data.disabled or
			(data.unlocked[award] and data.unlocked[award] == award) then
		return
	end

	-- Unlock Award
	minetest.log("action", name.." has unlocked award "..name)
	data.unlocked[award] = award
	awards.save()

	-- Give Prizes
	if awdef and awdef.prizes then
		for i = 1, #awdef.prizes do
			local itemstack = ItemStack(awdef.prizes[i])
			if not itemstack:is_empty() then
				local receiverref = minetest.get_player_by_name(name)
				if receiverref then
					receiverref:get_inventory():add_item("main", itemstack)
				end
			end
		end
	end

	-- Run callbacks
	if awdef.on_unlock and awdef.on_unlock(name, awdef) then
		return
	end
	for _, callback in pairs(awards.on_unlock) do
		if callback(name, awdef) then
			return
		end
	end

	-- Get Notification Settings
	local title = awdef.title or award
	local desc = awdef.description or ""
	local background = awdef.background or "awards_bg_default.png"
	local icon = awdef.icon or "awards_unknown.png"
	local sound = awdef.sound
	if sound == nil then
		-- Explicit check for nil because sound could be `false` to disable it
		sound = {name="awards_got_generic", gain=0.25}
	end

	-- Do Notification
	if sound then
		-- Enforce sound delay to prevent sound spamming
		local lastsound = data.lastsound
		if lastsound == nil or os.difftime(os.time(), lastsound) >= 1 then
			minetest.sound_play(sound, {to_player=name})
			data.lastsound = os.time()
		end
	end

	if awards.show_mode == "chat" then
		local chat_announce
		if awdef.secret == true then
			chat_announce = S("Secret Achievement Unlocked: %s")
		else
			chat_announce = S("Achievement Unlocked: %s")
		end
		-- use the chat console to send it
		minetest.chat_send_player(name, string.format(chat_announce, title))
		if desc~="" then
			minetest.chat_send_player(name, desc)
		end
	else
		local player = minetest.get_player_by_name(name)
		local one = player:hud_add({
			hud_elem_type = "image",
			name = "award_bg",
			scale = {x = 2, y = 1},
			text = background,
			position = {x = 0.5, y = 0},
			offset = {x = 0, y = 138},
			alignment = {x = 0, y = -1}
		})
		local hud_announce
		if awdef.secret == true then
			hud_announce = S("Secret Achievement Unlocked!")
		else
			hud_announce = S("Achievement Unlocked!")
		end
		local two = player:hud_add({
			hud_elem_type = "text",
			name = "award_au",
			number = 0xFFFFFF,
			scale = {x = 100, y = 20},
			text = hud_announce,
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
			position = {x = 0.4, y = 0},
			offset = {x = -81.5, y = 126},
			alignment = {x = 0, y = -1}
		})
		minetest.after(4, function()
			player:hud_remove(one)
			player:hud_remove(two)
			player:hud_remove(three)
			player:hud_remove(four)
		end)
	end
end

-- Backwards compatibility
awards.give_achievement = awards.unlock

--[[minetest.register_chatcommand("gawd", {
	params = "award name",
	description = "gawd: give award to self",
	func = function(name, param)
		awards.unlock(name,param)
	end
})]]--

function awards.getFormspec(name, to, sid)
	local formspec = ""
	local listofawards = awards._order_awards(name)
	local playerdata = awards.player(name)

	if #listofawards == 0 then
		formspec = formspec .. "label[3.9,1.5;"..minetest.formspec_escape(S("Error: No awards available.")).."]"
		formspec = formspec .. "button_exit[4.2,2.3;3,1;close;"..minetest.formspec_escape(S("OK")).."]"
		return formspec
	end

	-- Sidebar
	if sid then
		local item = listofawards[sid+0]
		local def = awards.def[item.name]

		if def and def.secret and not item.got then
			formspec = formspec .. "label[1,2.75;"..minetest.formspec_escape(S("(Secret Award)")).."]"..
								"image[1,0;3,3;awards_unknown.png]"
			if def and def.description then
				formspec = formspec	.. "textarea[0.25,3.25;4.8,1.7;;"..minetest.formspec_escape(S("Unlock this award to find out what it is."))..";]"
			end
		else
			local title = item.name
			if def and def.title then
				title = def.title
			end
			local status = "%s"
			if item.got then
				status = S("%s (got)")
			end

      formspec = formspec .. "textarea[0.5,2.7;4.8,1.45;;" ..
				string.format(status, minetest.formspec_escape(title)) ..
				";]"

			if def and def.icon then
				formspec = formspec .. "image[1,0;3,3;" .. def.icon .. "]"
			end
			local barwidth = 4.6
			local perc = nil
			local label = nil
			if def.getProgress and playerdata then
				local res = def:getProgress(playerdata)
				perc = res.perc
				label = res.label
			end
			if perc then
				if perc > 1 then
					perc = 1
				end
				formspec = formspec .. "background[0,4.80;" .. barwidth ..",0.25;awards_progress_gray.png;false]"
				formspec = formspec .. "background[0,4.80;" .. (barwidth * perc) ..",0.25;awards_progress_green.png;false]"
				if label then
					formspec = formspec .. "label[1.75,4.63;" .. minetest.formspec_escape(label) .. "]"
				end
			end
			if def and def.description then
				formspec = formspec	.. "textarea[0.25,3.75;4.8,1.7;;"..minetest.formspec_escape(def.description)..";]"
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
				formspec = formspec .. "#707070"..minetest.formspec_escape(S("(Secret Award)"))
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
	return formspec .. ";"..sid.."]"
end

function awards.show_to(name, to, sid, text)
	if name == "" or name == nil then
		name = to
	end
	local data = awards.player(to)
	if name == to and data.disabled then
		minetest.chat_send_player(S("You've disabled awards. Type /awards enable to reenable."))
		return
	end
	if text then
		local listofawards = awards._order_awards(name)
		if #listofawards == 0 then
			minetest.chat_send_player(to, S("Error: No awards available."))
			return
		elseif not data or not data.unlocked  then
			minetest.chat_send_player(to, S("You have not unlocked any awards."))
			return
		end
		minetest.chat_send_player(to, string.format(S("%s’s awards:"), name))

		for _, str in pairs(data.unlocked) do
			local def = awards.def[str]
			if def then
				if def.title then
					if def.description then
						minetest.chat_send_player(to, string.format(S("%s: %s"), def.title, def.description))
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
		local deco = ""
		if minetest.global_exists("default") then
			deco = default.gui_bg .. default.gui_bg_img
		end
		-- Show formspec to user
		minetest.show_formspec(to,"awards:awards",
			"size[11,5]" .. deco ..
			awards.getFormspec(name, to, sid))
	end
end
awards.showto = awards.show_to

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= "awards:awards" then
		return false
	end
	if fields.quit then
		return true
	end
	local name = player:get_player_name()
	if fields.awards then
		local event = minetest.explode_textlist_event(fields.awards)
		if event.type == "CHG" then
			awards.show_to(name, name, event.index, false)
		end
	end

	return true
end)

awards.load()

minetest.register_on_shutdown(function()
	awards.save()
end)
