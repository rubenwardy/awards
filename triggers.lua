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

awards.register_trigger("death", {
	type = "counted",
	progress = "@1/@2 deaths",
	auto_description = { "Die once", "Die @1 times" },
})
minetest.register_on_dieplayer(awards.notify_death)

awards.register_trigger("chat", {
	type = "counted",
	progress = "@1/@2 chat messages",
	auto_description = { "Send a chat message", "Chat @1 times" },
})
minetest.register_on_chat_message(function(name, message)
	local player = minetest.get_player_by_name(name)
	if not player or string.find(message, "/")  then
		return
	end

	awards.notify_chat(player)
end)

awards.register_trigger("join", {
	type = "counted",
	progress = "@1/@2 joins",
	auto_description = { "Join once", "Join @1 times" },
})
minetest.register_on_joinplayer(awards.notify_join)

--
-- awards.register_trigger("dig", {
-- 	type = "counted_key",
-- 	progress = "@1/@2 dug",
-- 	auto_description = { "Mine: @2", "Mine: @1×@2" },
-- 	auto_description_total = { "Mine @1 block.", "Mine @1 blocks." },
-- 	get_key = function(self, def)
-- 		return minetest.registered_aliases[def.trigger.node] or def.trigger.node
-- 	end
-- })
--
-- minetest.register_on_dignode(function(pos, oldnode, player)
-- 	if not player or not pos or not oldnode then
-- 		return
-- 	end
--
-- 	local node_name = oldnode.name
-- 	node_name = minetest.registered_aliases[node_name] or node_name
-- 	awards.notify_dig(player, node_name)
-- end)
--
-- awards.register_trigger("place", {
-- 	type = "counted_key",
-- 	progress = "@1/@2 placed",
-- 	auto_description = { "Place: @2", "Place: @1×@2" },
-- 	auto_description_total = { "Place @1 block.", "Place @1 blocks." },
-- 	get_key = function(self, def)
-- 		return minetest.registered_aliases[def.trigger.node] or def.trigger.node
-- 	end
-- })
--
-- awards.register_trigger("craft", {
-- 	type = "counted_key",
-- 	progress = "@1/@2 crafted",
-- 	auto_description = { "Craft: @2", "Craft: @1×@2" },
-- 	auto_description_total = { "Craft @1 item", "Craft @1 items." },
-- 	get_key = function(self, def)
-- 		return minetest.registered_aliases[def.trigger.item] or def.trigger.item
-- 	end
-- })


-- Backwards compatibility
awards.register_onDig   = awards.register_on_dig
awards.register_onPlace = awards.register_on_place
awards.register_onDeath = awards.register_on_death
awards.register_onChat  = awards.register_on_chat
awards.register_onJoin  = awards.register_on_join
awards.register_onCraft = awards.register_on_craft

-- Trigger Handles
--
-- minetest.register_on_placenode(function(pos, node, digger)
-- 	if not digger or not pos or not node or not digger:get_player_name() or digger:get_player_name()=="" then
-- 		return
-- 	end
-- 	local data = awards.players[digger:get_player_name()]
-- 	if not awards.increment_item_counter(data, "place", node.name) then
-- 		return
-- 	end
--
-- 	awards.run_trigger_callbacks(digger, data, "place", function(entry)
-- 		if entry.target then
-- 			if entry.node then
-- 				local tnodedug = string.split(entry.node, ":")
-- 				local tmod = tnodedug[1]
-- 				local titem = tnodedug[2]
-- 				if not (not tmod or not titem or not data.place[tmod] or
-- 							not data.place[tmod][titem]) and
-- 						data.place[tmod][titem] > entry.target-1 then
-- 					return entry.award
-- 				end
-- 			elseif awards.get_total_item_count(data, "place") > entry.target-1 then
-- 				return entry.award
-- 			end
-- 		end
-- 	end)
-- end)
--
-- minetest.register_on_item_eat(function(hp_change, replace_with_item, itemstack, user, pointed_thing)
-- 	if not user or not itemstack or not user:get_player_name() or user:get_player_name()=="" then
-- 		return
-- 	end
-- 	local data = awards.players[user:get_player_name()]
-- 	if not awards.increment_item_counter(data, "eat", itemstack:get_name()) then
-- 		return
-- 	end
-- 	awards.run_trigger_callbacks(user, data, "eat", function(entry)
-- 		if entry.target then
-- 			if entry.item then
-- 				local titemstring = string.split(entry.item, ":")
-- 				local tmod = titemstring[1]
-- 				local titem = titemstring[2]
-- 				if not (not tmod or not titem or not data.eat[tmod] or
-- 							not data.eat[tmod][titem]) and
-- 						data.eat[tmod][titem] > entry.target-1 then
-- 					return entry.award
-- 				end
-- 			elseif awards.get_total_item_count(data, "eat") > entry.target-1 then
-- 				return entry.award
-- 			end
-- 		end
-- 	end)
-- end)
--
-- minetest.register_on_craft(function(itemstack, player, old_craft_grid, craft_inv)
-- 	if not player or not itemstack then
-- 		return
-- 	end
--
-- 	local data = awards.players[player:get_player_name()]
-- 	if not awards.increment_item_counter(data, "craft", itemstack:get_name(), itemstack:get_count()) then
-- 		return
-- 	end
--
-- 	awards.run_trigger_callbacks(player, data, "craft", function(entry)
-- 		if entry.target then
-- 			if entry.item then
-- 				local titemcrafted = string.split(entry.item, ":")
-- 				local tmod = titemcrafted[1]
-- 				local titem = titemcrafted[2]
-- 				if not (not tmod or not titem or not data.craft[tmod] or
-- 							not data.craft[tmod][titem]) and
-- 						data.craft[tmod][titem] > entry.target-1 then
-- 					return entry.award
-- 				end
-- 			elseif awards.get_total_item_count(data, "craft") > entry.target-1 then
-- 				return entry.award
-- 			end
-- 		end
-- 	end)
-- end)
