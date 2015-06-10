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

function awards.tbv(tb,value,default)
	if not default then
		default = {}
	end
	if not tb or type(tb) ~= "table" then
		if not value then
			value = "[NULL]"
		end
		minetest.log("error", "awards.tbv - table "..dump(value).." is null, or not a table! Dump: "..dump(tb))
		return
	end
	if not value then
		error("[ERROR] awards.tbv was not used correctly!\n"..
			"Value: '"..dump(value).."'\n"..
			"Dump:"..dump(tb))
		return
	end
	if not tb[value] then
		tb[value] = default
	end
end

function awards.assertPlayer(playern)
	awards.tbv(awards.players, playern)
	awards.tbv(awards.players[playern], "name", playern)
	awards.tbv(awards.players[playern], "unlocked")
	awards.tbv(awards.players[playern], "place")
	awards.tbv(awards.players[playern], "count")
	awards.tbv(awards.players[playern], "deaths", 0)
	awards.tbv(awards.players[playern], "joins", 0)
	awards.tbv(awards.players[playern], "chats", 0)
end

function awards.player(name)
	return awards.players[name]
end

function awards._order_awards(name)
	local done = {}
	local retval = {}
	local player = awards.player(name)
	if player and player.unlocked then
		for _,got in pairs(player.unlocked) do
			if awards.def[got] then
				done[got] = true
				table.insert(retval,{name=got,got=true})
			end
		end
	end
	for _,def in pairs(awards.def) do
		if not done[def.name] then
			table.insert(retval,{name=def.name,got=false})
		end
	end
	return retval
end
