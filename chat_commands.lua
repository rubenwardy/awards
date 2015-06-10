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

minetest.register_chatcommand("list_awards", {
	params = "obsolete",
	description = "list_awards: obsolete. Use /awards",
	func = function(name, param)
		minetest.chat_send_player(name, "This command has been made obsolete. Use /awards instead.")
		awards.showto(name, name, nil, false)
	end
})

minetest.register_chatcommand("awards", {
	params = "",
	description = "awards: list awards",
	func = function(name, param)
		awards.showto(name, name, nil, false)
	end
})

minetest.register_chatcommand("cawards", {
	params = "",
	description = "awards: list awards in chat",
	func = function(name, param)
		awards.showto(name, name, nil, true)
	end
})

minetest.register_chatcommand("awd", {
	params = "award name",
	description = "awd: Details of awd gotten",
	func = function(name, param)
		local def = awards.def[param]
		if def then
			minetest.chat_send_player(name,def.title..": "..def.description)
		else
			minetest.chat_send_player(name,"Award not found.")
		end
	end
})

minetest.register_chatcommand("awpl", {
	privs = {
		server = true
	},
	description = "awpl: Get the statistics for the player given",
	func = function(name, param)
		if not param or param == "" then
			param = name
		end
		minetest.chat_send_player(name, param)
		local player = awards.player(param)
		minetest.chat_send_player(name, dump(player))
	end
})
