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


awards.register_trigger("death", {
	type = "counted_key",
	progress = "@1/@2 deaths",
	auto_description = { "Die once of @2", "Die @1 times of @2" },
	auto_description_total = { "Die @1 times.", "Mine @1 times" },
	get_key = function(self, def)
		return def.trigger.reason
	end,
})
minetest.register_on_dieplayer(function(player, reason)
	if reason then
		reason = reason.type
	else
		reason = "unknown"
	end
	awards.notify_death(player, reason)
end)


awards.register_trigger("dig", {
	type = "counted_key",
	progress = "@1/@2 dug",
	auto_description = { "Mine: @2", "Mine: @1×@2" },
	auto_description_total = { "Mine @1 block.", "Mine @1 blocks." },
	get_key = function(self, def)
		return minetest.registered_aliases[def.trigger.node] or def.trigger.node
	end
})
minetest.register_on_dignode(function(pos, node, player)
	if not player or not pos or not node then
		return
	end

	local node_name = node.name
	node_name = minetest.registered_aliases[node_name] or node_name
	awards.notify_dig(player, node_name)
end)


awards.register_trigger("place", {
	type = "counted_key",
	progress = "@1/@2 placed",
	auto_description = { "Place: @2", "Place: @1×@2" },
	auto_description_total = { "Place @1 block.", "Place @1 blocks." },
	get_key = function(self, def)
		return minetest.registered_aliases[def.trigger.node] or def.trigger.node
	end
})
minetest.register_on_placenode(function(pos, node, player)
	if not player or not pos or not node then
		return
	end

	local node_name = node.name
	node_name = minetest.registered_aliases[node_name] or node_name
	awards.notify_place(player, node_name)
end)


awards.register_trigger("craft", {
	type = "counted_key",
	progress = "@1/@2 crafted",
	auto_description = { "Craft: @2", "Craft: @1×@2" },
	auto_description_total = { "Craft @1 item", "Craft @1 items." },
	get_key = function(self, def)
		return minetest.registered_aliases[def.trigger.item] or def.trigger.item
	end
})
minetest.register_on_craft(function(itemstack, player, old_craft_grid, craft_inv)
	if not player or itemstack:is_empty() then
		return
	end

	local itemname = itemstack:get_name()
	itemname = minetest.registered_aliases[itemname] or itemname
	awards.notify_craft(player, itemname, itemstack:get_count())
end)


awards.register_trigger("eat", {
	type = "counted_key",
	progress = "@1/@2 eaten",
	auto_description = { "Eat @2", "Eat @1×@2" },
	auto_description_total = { "Eat @1 item", "Eat @1 items." },
	get_key = function(self, def)
		return minetest.registered_aliases[def.trigger.item] or def.trigger.item
	end
})
minetest.register_on_item_eat(function(_, _, itemstack, player, _)
	if not player or itemstack:is_empty() then
		return
	end

	local itemname = itemstack:get_name()
	itemname = minetest.registered_aliases[itemname] or itemname
	awards.notify_craft(player, itemname, itemstack:get_count())
end)

-- trigger for killing entities with more than 1 point of health
awards.register_trigger("kill_mob", {
	type = "counted_key",
	progress = "@1/@2 killed",
	auto_description = { "Kill @2", "Kill @1×@2" },
	auto_description_total = { "Kill @1 mob", "Kill @1 mobs." },
	get_key = function(self, def)
		return minetest.registered_aliases[def.trigger.mob] or def.trigger.mob
	end
})

-- wait for all mobs to be registered
minetest.after(0, function()
	local ents = minetest.registered_entities
	local mobs = {}
	for _, ent in pairs(ents) do
		if ent.hp_max ~= nil and ent.hp_max > 0 then
         		table.insert(mobs,ent)
      		end
	end
	for _, mob in pairs(mobs) do
		local old_func = mob.on_punch
		mob.on_punch = function(self, player, a, b, c, d)
			old_func(self, player, a, b, c, d)
			if player and player:is_player() then
				if self.health <= 0 then
					awards.notify_kill_mob(player, self.name)
				end
			end
		end
	end
end)

-- trigger for killing an entity
awards.register_trigger("punch_entity", {
	type = "counted_key",
	progress = "@1/@2 punched",
	auto_description = { "Punch @2", "Punch @1×@2" },
	auto_description_total = { "Punch @1 entity", "Punch @1 entities." },
	get_key = function(self, def)
		return minetest.registered_aliases[def.trigger.mob] or def.trigger.mob
	end
})

-- wait for all entities to be registered
minetest.after(0, function()
	local ents = minetest.registered_entities
	for _, ent in pairs(ents) do
		if ent.hp_max == nil then
			local old_func = ent.on_punch
			ent.on_punch = function(self, player, a, b, c, d)
				old_func(self, player, a, b, c, d)
				if player and player:is_player() then
					awards.notify_punch_entity(player, self.name)
				end
			end
		end
	end
end)
