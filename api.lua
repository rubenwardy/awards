-- Copyright (c) 2013-18 rubenwardy. MIT.

local S, NS = awards.gettext, awards.ngettext

awards.registered_awards = {}
awards.on = {}
awards.on_unlock = {}

local storage = minetest.get_mod_storage()

-- Table Save Load Functions
function awards.save()
	storage:set_string("player_data", minetest.write_json(awards.players))
end

local function convert_data()
	minetest.log("warning", "Importing awards data from previous version")

	local old_players = awards.players
	awards.players = {}
	for name, data in pairs(old_players) do
		while name.name do
			name = name.name
		end
		data.name = name
		print("Converting data for " .. name)

		-- Just rename counted
		local counted = {
			chats  = "chat",
			deaths = "death",
			joins  = "join",
		}
		for from, to in pairs(counted) do
			data[to]   = data[from]
			data[from] = nil
		end

		data.death = {
			unknown = data.death,
			__total = data.death,
		}

		-- Convert item db to new format
		local counted_items = {
			count = "dig",
			place = "place",
			craft = "craft",
		}
		for from, to in pairs(counted_items) do
			local ret = {}

			local count = 0
			if data[from] then
				for modname, items in pairs(data[from]) do
					for itemname, value in pairs(items) do
						itemname = modname .. ":" .. itemname
						local key = minetest.registered_aliases[itemname] or itemname
						ret[key] = value
						count = count + value
					end
				end
			end

			ret.__total = count
			data[from] = nil
			data[to] = ret
		end

		awards.players[name] = data
	end
end

function awards.load()
	local old_save_path = minetest.get_worldpath().."/awards.txt"
	local file = io.open(old_save_path, "r")
	if file then
		local table = minetest.deserialize(file:read("*all"))
		if type(table) == "table" then
			awards.players = table
			convert_data()
		else
			awards.players = {}
		end
		file:close()
		os.rename(old_save_path, minetest.get_worldpath().."/awards.bk.txt")
		awards.save()
	else
		awards.players = minetest.parse_json(storage:get_string("player_data")) or {}
	end
end

function awards.player(name)
	assert(type(name) == "string")
	local data = awards.players[name] or {}
	awards.players[name] = data
	data.name = data.name or name
	data.unlocked = data.unlocked or {}
	return data
end

function awards.player_or_nil(name)
	return awards.players[name]
end

local default_def = {}

function default_def:run_callbacks(player, data, table_func)
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
	for key, value in pairs(default_def) do
		tdef[key] = value
	end

	if tdef.type == "counted" then
		local old_reg = tdef.on_register

		function tdef:on_register(def)
			local tmp = {
				award  = def.name,
				target = def.trigger.target,
			}
			tdef.register(tmp)

			function def.getProgress(_, data)
				local done = data[tname] or 0
				return {
					perc = done / tmp.target,
					label = S(tdef.progress, done, tmp.target),
				}
			end

			function def.getDefaultDescription(_)
				local n = def.trigger.target
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

			-- Increment counter
			local currentVal = (data[tname] or 0) + 1
			data[tname] = currentVal

			tdef:run_callbacks(player, data, function(entry)
				if entry.target and entry.award and currentVal and
						currentVal >= entry.target then
					return entry.award
				end
			end)
		end

		awards["notify_" .. tname] = tdef.notify

	elseif tdef.type == "counted_key" then
		if tdef.key_is_item then
			tdef.watched_groups = {}
		end

		-- On award register
		local old_reg = tdef.on_register
		function tdef:on_register(def)
			-- Register trigger
			local tmp = {
				award  = def.name,
				key    = tdef:get_key(def),
				target = def.trigger.target,
			}
			tdef.register(tmp)

			-- If group, add it to watch list
			if tdef.key_is_item and tmp.key and tmp.key:sub(1, 6) == "group:" then
				tdef.watched_groups[tmp.key:sub(7, #tmp.key)] = true
			end

			-- Called to get progress values and labels
			function def.getProgress(_, data)
				local done
				data[tname] = data[tname] or {}
				if tmp.key then
					done = data[tname][tmp.key] or 0
				else
					done = data[tname].__total or 0
				end
				return {
					perc = done / tmp.target,
					label = S(tdef.progress, done, tmp.target),
				}
			end

			-- Build description if none is specificed by the award
			function def.getDefaultDescription(_)
				local n = def.trigger.target
				if tmp.key then
					local nname = tmp.key
					return NS(tdef.auto_description[1],
							tdef.auto_description[2], n, n, nname)
				else
					return NS(tdef.auto_description_total[1],
							tdef.auto_description_total[2], n, n)
				end
			end

			-- Call on_register in trigger type definition
			if old_reg then
				return old_reg(tdef, def)
			end
		end

		function tdef.notify(player, key, n)
			n = n or 1

			if tdef.key_is_item and key:sub(1, 6) ~= "group:" then
				local itemdef = minetest.registered_items[key]
				if itemdef then
					for groupname, _ in pairs(itemdef.groups or {}) do
						if tdef.watched_groups[groupname] then
							tdef.notify(player, "group:" .. groupname, n)
						end
					end
				end
			end

			assert(player and player.is_player and player:is_player() and key)
			local name = player:get_player_name()
			local data = awards.player(name)

			-- Increment counter
			data[tname] = data[tname] or {}
			local currentVal = (data[tname][key] or 0) + n
			data[tname][key] = currentVal
			if key:sub(1, 6) ~= "group:" then
				data[tname].__total = (data[tname].__total or 0) + n
			end

			tdef:run_callbacks(player, data, function(entry)
				local current
				if entry.key == key then
					current = currentVal
				elseif entry.key == nil then
					current = data[tname].__total
				else
					return
				end

				if current >= entry.target then
					return entry.award
				end
			end)
		end

		awards["notify_" .. tname] = tdef.notify

	elseif tdef.type and tdef.type ~= "custom" then
		error("Unrecognised trigger type " .. tdef.type)
	end

	awards.registered_triggers[tname] = tdef

	tdef.on = {}
	tdef.register = function(func)
		table.insert(tdef.on, func)
	end

	-- Backwards compat
	awards.on[tname] = tdef.on
	awards['register_on_' .. tname] = tdef.register
	return tdef
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

function awards.register_award(name, def)
	def.name = name

	-- Add Triggers
	if def.trigger and def.trigger.type then
		local tdef = awards.registered_triggers[def.trigger.type]
		assert(tdef, "Trigger not found: " .. def.trigger.type)
		tdef:on_register(def)
	end

	function def:can_unlock(data)
		if not self.requires then
			return true
		end

		for i=1, #self.requires do
			if not data.unlocked[self.requires[i]] then
				return false
			end
		end
		return true
	end

	-- Add Award
	awards.registered_awards[name] = def

	local tdef = awards.registered_awards[name]
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
-- It checks if a player already has that award, and if they do not,
-- it gives it to them
----------------------------------------------
--awards.unlock(name, award)
-- name - the name of the player
-- award - the name of the award to give
function awards.unlock(name, award)
	-- Access Player Data
	local data  = awards.player(name)
	local awdef = awards.registered_awards[award]
	assert(awdef, "Unable to unlock an award which doesn't exist!")

	if data.disabled or
			(data.unlocked[award] and data.unlocked[award] == award) then
		return
	end

	if not awdef:can_unlock(data) then
		minetest.log("warning", "can_unlock returned false in unlock of " ..
				award .. " for " .. name)
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
		if awdef.secret then
			chat_announce = S("Secret Award Unlocked: %s")
		else
			chat_announce = S("Award Unlocked: %s")
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
			position = {x = 0.5, y = 0.05},
			offset = {x = 0, y = 138},
			alignment = {x = 0, y = -1}
		})
		local hud_announce
		if awdef.secret then
			hud_announce = S("Secret Award Unlocked!")
		else
			hud_announce = S("Award Unlocked!")
		end
		local two = player:hud_add({
			hud_elem_type = "text",
			name = "award_au",
			number = 0xFFFFFF,
			scale = {x = 100, y = 20},
			text = hud_announce,
			position = {x = 0.5, y = 0.05},
			offset = {x = 0, y = 45},
			alignment = {x = 0, y = -1}
		})
		local three = player:hud_add({
			hud_elem_type = "text",
			name = "award_title",
			number = 0xFFFFFF,
			scale = {x = 100, y = 20},
			text = title,
			position = {x = 0.5, y = 0.05},
			offset = {x = 0, y = 100},
			alignment = {x = 0, y = -1}
		})
		local four = player:hud_add({
			hud_elem_type = "image",
			name = "award_icon",
			scale = {x = 4, y = 4},
			text = icon,
			position = {x = 0.5, y = 0.05},
			offset = {x = -200.5, y = 126},
			alignment = {x = 0, y = -1}
		})
		minetest.after(4, function()
			local player2 = minetest.get_player_by_name(name)
			if player2 then
				player2:hud_remove(one)
				player2:hud_remove(two)
				player2:hud_remove(three)
				player2:hud_remove(four)
			end
		end)
	end
end

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
