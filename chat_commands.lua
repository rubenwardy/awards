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

minetest.register_chatcommand("awards", {
	params = "[c|clear|disable|enable]",
	description = "Show, clear, disable or enable your achievements.",
	func = function(name, param)
		if param == "clear" then
			awards.clear_player(name)
			minetest.chat_send_player(name, "All your awards and statistics " ..
					" have been cleared. You can now start again.")
		elseif param == "disable" then
			awards.disable(name)
			minetest.chat_send_player(name, "You have disabled your achievements.")
		elseif param == "enable" then
			awards.enable(name)
			minetest.chat_send_player(name, "You have enabled your achievements.")
		elseif param == "c" then
			awards.show_to(name, name, nil, true)
		else
			awards.show_to(name, name, nil, false)
		end
	end
})

minetest.register_chatcommand("cawards", {
	params = "",
	description = "List awards in chat (deprecated)",
	func = function(name, param)
		awards.show_to(name, name, nil, true)
		minetest.chat_send_player(name, "/cawards has been deprecated," ..
				" use /awards c instead")
	end
})

minetest.register_chatcommand("awd", {
	params = "<achievement name>",
	description = "Show details of an achievement you got",
	func = function(name, param)
		local def = awards.def[param]
		if def then
			minetest.chat_send_player(name,string.format("%s: %s", def.title, def.description))
		else
			minetest.chat_send_player(name,"Achievement not found.")
		end
	end
})

minetest.register_chatcommand("awpl", {
	privs = {
		server = true
	},
	param = "<player>",
	description = "Get the achievements statistics for the player given",
	func = function(name, param)
		if not param or param == "" then
			param = name
		end
		minetest.chat_send_player(name, param)
		local player = awards.player(param)
		minetest.chat_send_player(name, dump(player))
	end
})
