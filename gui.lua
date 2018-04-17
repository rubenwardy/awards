-- Copyright (c) 2013-18 rubenwardy. MIT.

local S = awards.gettext

local function order_awards(name)
	local hash_is_unlocked = {}
	local retval = {}

	local data = awards.player(name)
	if data and data.unlocked then
		for awardname, _ in pairs(data.unlocked) do
			local def = awards.registered_awards[awardname]
			if def then
				hash_is_unlocked[awardname] = true
				local score = -100000

				local difficulty = def.difficulty or 1
				if def.trigger and def.trigger.target then
					difficulty = difficulty * def.trigger.target
				end
				score = score + difficulty

				retval[#retval + 1] = {
					name     = awardname,
					def      = def,
					unlocked = true,
					started  = true,
					score    = score,
				}
			end
		end
	end

	for _, def in pairs(awards.registered_awards) do
		if not hash_is_unlocked[def.name] and def:can_unlock(data) then
			local started = false
			local score = def.difficulty or 1
			if def.secret then
				score = 1000000
			elseif def.trigger and def.trigger.target and def.getProgress then
				local progress = def:getProgress(data).perc
				score = score * (1 - progress) * def.trigger.target
				if progress < 0.001 then
					score = score + 100
				else
					started = true
				end
			else
				score = 100
			end

			retval[#retval + 1] = {
				name     = def.name,
				def      = def,
				unlocked = false,
				started  = started,
				score    = score,
			}
		end
	end

	table.sort(retval, function(a, b)
		return a.score < b.score
	end)
	return retval
end

function awards.get_formspec(name, to, sid)
	local formspec = ""
	local awards_list = order_awards(name)
	local data  = awards.player(name)

	if #awards_list == 0 then
		formspec = formspec .. "label[3.9,1.5;"..minetest.formspec_escape(S("Error: No achivements available.")).."]"
		formspec = formspec .. "button_exit[4.2,2.3;3,1;close;"..minetest.formspec_escape(S("OK")).."]"
		return formspec
	end

	-- Sidebar
	if sid then
		local item = awards_list[sid+0]
		local def  = item.def

		if def and def.secret and not item.unlocked then
			formspec = formspec .. "label[1,2.75;"..
					minetest.formspec_escape(S("(Secret Award)")).."]"..
					"image[1,0;3,3;awards_unknown.png]"
			if def and def.description then
				formspec = formspec	.. "textarea[0.25,3.25;4.8,1.7;;"..
						minetest.formspec_escape(
								S("Unlock this award to find out what it is."))..";]"
			end
		else
			local title = item.name
			if def and def.title then
				title = def.title
			end
			local status = "%s"
			if item.unlocked then
				status = S("%s (unlocked)")
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
			if def.getProgress and data then
				local res = def:getProgress(data)
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
	for _, award in pairs(awards_list) do
		local def = award.def
		if def then
			if not first then
				formspec = formspec .. ","
			end
			first = false

			if def.secret and not award.unlocked then
				formspec = formspec .. "#707070"..minetest.formspec_escape(S("(Secret Award)"))
			else
				local title = award.name
				if def and def.title then
					title = def.title
				end
				-- title = title .. " [" .. award.score .. "]"
				if award.unlocked then
					formspec = formspec .. minetest.formspec_escape(title)
				elseif award.started then
					formspec = formspec .. "#c0c0c0".. minetest.formspec_escape(title)
				else
					formspec = formspec .. "#a0a0a0".. minetest.formspec_escape(title)
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
		minetest.chat_send_player(name, S("You've disabled awards. Type /awards enable to reenable."))
		return
	end
	if text then
		local awards_list = order_awards(name)
		if #awards_list == 0 then
			minetest.chat_send_player(to, S("Error: No award available."))
			return
		elseif not data or not data.unlocked  then
			minetest.chat_send_player(to, S("You have not unlocked any awards."))
			return
		end
		minetest.chat_send_player(to, string.format(S("%s’s awards:"), name))

		for str, _ in pairs(data.unlocked) do
			local def = awards.registered_awards[str]
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
			awards.get_formspec(name, to, sid))
	end
end

if minetest.get_modpath("sfinv") then
	sfinv.register_page("awards:awards", {
		title = S("Awards"),
		on_enter = function(self, player, context)
			context.awards_idx = 1
		end,
		is_in_nav = function(self, player, context)
			local data = awards.player(player:get_player_name())
			return not data.disabled
		end,
		get = function(self, player, context)
			local name = player:get_player_name()
			return sfinv.make_formspec(player, context,
				awards.get_formspec(name, name, context.awards_idx or 1),
				false, "size[11,5]")
		end,
		on_player_receive_fields = function(self, player, context, fields)
			if fields.awards then
				local event = minetest.explode_textlist_event(fields.awards)
				if event.type == "CHG" then
					context.awards_idx = event.index
					sfinv.set_player_inventory_formspec(player, context)
				end
			end
		end
	})
end

if minetest.get_modpath("unified_inventory") ~= nil then
	unified_inventory.register_button("awards", {
		type = "image",
		image = "awards_ui_icon.png",
		tooltip = S("Awards"),
		action = function(player)
			local name = player:get_player_name()
			awards.show_to(name, name, nil, false)
		end,
	})
end
