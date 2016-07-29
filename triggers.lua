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

awards.register_trigger("dig", function(def)
	local tmp = {
		award  = def.name,
		node   = def.trigger.node,
		target = def.trigger.target
	}
	table.insert(awards.on.dig, tmp)
end)

awards.register_trigger("place", function(def)
	local tmp = {
		award  = def.name,
		node   = def.trigger.node,
		target = def.trigger.target
	}
	table.insert(awards.on.place, tmp)
end)

awards.register_trigger("death", function(def)
	local tmp = {
		award  = def.name,
		target = def.trigger.target
	}
	table.insert(awards.on.death, tmp)
end)

awards.register_trigger("chat", function(def)
	local tmp = {
		award  = def.name,
		target = def.trigger.target
	}
	table.insert(awards.on.chat, tmp)
end)

awards.register_trigger("join", function(def)
	local tmp = {
		award  = def.name,
		target = def.trigger.target
	}
	table.insert(awards.on.join, tmp)
end)

awards.register_trigger("craft", function(def)
	local tmp = {
		award  = def.name,
		item   = def.trigger.item,
		target = def.trigger.target
	}
	table.insert(awards.on.craft, tmp)
end)

-- Backwards compatibility
awards.register_onDig   = awards.register_on_dig
awards.register_onPlace = awards.register_on_place
awards.register_onDeath = awards.register_on_death
awards.register_onChat  = awards.register_on_chat
awards.register_onJoin  = awards.register_on_join
awards.register_onCraft = awards.register_on_craft

function awards.run_trigger_callbacks(player, data, trigger, table_func)
	for i = 1, #awards.on[trigger] do
		local res = nil
		local entry = awards.on[trigger][i]
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

-- Trigger Handles
minetest.register_on_dignode(function(pos, oldnode, digger)
	if not digger or not pos or not oldnode then
		return
	end
	local nodedug = string.split(oldnode.name, ":")
	if #nodedug ~= 2 then
		return
	end
	local mod = nodedug[1]
	local item = nodedug[2]
	local playern = digger:get_player_name()

	if (not playern or not nodedug or not mod or not item) then
		return
	end
	awards.assertPlayer(playern)
	awards.tbv(awards.players[playern].count, mod)
	awards.tbv(awards.players[playern].count[mod], item, 0)

	-- Increment counter
	awards.players[playern].count[mod][item]=awards.players[playern].count[mod][item] + 1

	-- Run callbacks and triggers
	local data = awards.players[playern]
	awards.run_trigger_callbacks(digger, data, "dig", function(entry)
		if entry.node and entry.target then
			local tnodedug = string.split(entry.node, ":")
			local tmod = tnodedug[1]
			local titem = tnodedug[2]
			if not tmod or not titem or not data.count[tmod] or not data.count[tmod][titem] then
				-- table running failed!
			elseif data.count[tmod][titem] > entry.target-1 then
				return entry.award
			end
		end
	end)
end)

minetest.register_on_placenode(function(pos, node, digger)
	if not digger or not pos or not node or not digger:get_player_name() or digger:get_player_name()=="" then
		return
	end
	local nodedug = string.split(node.name, ":")
	if #nodedug ~= 2 then
		return
	end
	local mod=nodedug[1]
	local item=nodedug[2]
	local playern = digger:get_player_name()

	-- Run checks
	if (not playern or not nodedug or not mod or not item) then
		return
	end
	awards.assertPlayer(playern)
	awards.tbv(awards.players[playern].place, mod)
	awards.tbv(awards.players[playern].place[mod], item, 0)

	-- Increment counter
	awards.players[playern].place[mod][item] = awards.players[playern].place[mod][item] + 1

	-- Run callbacks and triggers
	local data = awards.players[playern]
	awards.run_trigger_callbacks(digger, data, "place", function(entry)
		if entry.node and entry.target then
			local tnodedug = string.split(entry.node, ":")
			local tmod = tnodedug[1]
			local titem = tnodedug[2]
			if not tmod or not titem or not data.place[tmod] or not data.place[tmod][titem] then
				-- table running failed!
			elseif data.place[tmod][titem] > entry.target-1 then
				return entry.award
			end
		end
	end)
end)

minetest.register_on_craft(function(itemstack, player, old_craft_grid, craft_inv)
	if not player or not itemstack then
		return
	end
	local itemcrafted = string.split(itemstack:get_name(), ":")
	if #itemcrafted ~= 2 then
		--minetest.log("error","Awards mod: "..itemstack:get_name().." is in wrong format!")
		return
	end
	local mod = itemcrafted[1]
	local item = itemcrafted[2]
	local playern = player:get_player_name()

	if (not playern or not itemcrafted or not mod or not item) then
		return
	end
	awards.assertPlayer(playern)
	awards.tbv(awards.players[playern], "craft")
	awards.tbv(awards.players[playern].craft, mod)
	awards.tbv(awards.players[playern].craft[mod], item, 0)

	-- Increment counter
	awards.players[playern].craft[mod][item] = awards.players[playern].craft[mod][item] + 1

	-- Run callbacks and triggers
	local data = awards.players[playern]
	awards.run_trigger_callbacks(player, data, "craft", function(entry)
		if entry.item and entry.target then
			local titemcrafted = string.split(entry.item, ":")
			local tmod = titemcrafted[1]
			local titem = titemcrafted[2]
			if not tmod or not titem or not data.craft[tmod] or not data.craft[tmod][titem] then
				-- table running failed!
			elseif data.craft[tmod][titem] > entry.target-1 then
				return entry.award
			end
		end
	end)
end)

minetest.register_on_dieplayer(function(player)
	-- Run checks
	local name = player:get_player_name()
	if not player or not name or name=="" then
		return
	end

	-- Get player
	awards.assertPlayer(name)
	local data = awards.players[name]

	-- Increment counter
	data.deaths = data.deaths + 1

	awards.run_trigger_callbacks(player, data, "death", function(entry)
		if entry.target and entry.award and data.deaths and
				data.deaths >= entry.target then
			return entry.award
		end
	end)
end)

minetest.register_on_joinplayer(function(player)
	-- Run checks
	local name = player:get_player_name()
	if not player or not name or name=="" then
		return
	end

	-- Get player
	awards.assertPlayer(name)
	local data = awards.players[name]

	-- Increment counter
	data.joins = data.joins + 1

	awards.run_trigger_callbacks(player, data, "join", function(entry)
		if entry.target and entry.award and data.joins and
				data.joins >= entry.target then
			return entry.award
		end
	end)
end)

minetest.register_on_chat_message(function(name, message)
	-- Run checks
	local idx = string.find(message,"/")
	if not name or (idx ~= nil and idx <= 1)  then
		return
	end

	-- Get player
	awards.assertPlayer(name)
	local data = awards.players[name]
	local player = minetest.get_player_by_name(name)

	-- Increment counter
	data.chats = data.chats + 1

	awards.run_trigger_callbacks(player, data, "chat", function(entry)
		if entry.target and entry.award and data.chats and
				data.chats >= entry.target then
			return entry.award
		end
	end)
end)

minetest.register_on_newplayer(function(player)
	local playern = player:get_player_name()
	awards.assertPlayer(playern)
end)

minetest.register_on_shutdown(function()
	awards.save()
end)
