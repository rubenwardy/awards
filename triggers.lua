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

-- Backwards compatibility
awards.register_onDig   = awards.register_on_dig
awards.register_onPlace = awards.register_on_place
awards.register_onDeath = awards.register_on_death
awards.register_onChat  = awards.register_on_chat
awards.register_onJoin  = awards.register_on_join

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
	local player = digger
	local data = awards.players[playern]
	for i=1, #awards.on.dig do
		local res = nil
		if type(awards.on.dig[i]) == "function" then
			-- Run trigger callback
			res = awards.on.dig[i](player,data)
		elseif type(awards.on.dig[i]) == "table" then
			-- Handle table trigger
			if not awards.on.dig[i].node or not awards.on.dig[i].target or not awards.on.dig[i].award then
				-- table running failed!
				print("[ERROR] awards - on.dig trigger "..i.." is invalid!")
			else
				-- run the table
				local tnodedug = string.split(awards.on.dig[i].node, ":")
				local tmod=tnodedug[1]
				local titem=tnodedug[2]
				if tmod==nil or titem==nil or not data.count[tmod] or not data.count[tmod][titem] then
					-- table running failed!
				elseif data.count[tmod][titem] > awards.on.dig[i].target-1 then
					res=awards.on.dig[i].award
				end
			end
		end

		if res then
			awards.give_achievement(playern,res)
		end
	end
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
	local player = digger
	local data = awards.players[playern]
	for i=1,# awards.on.place do
		local res = nil
		if type(awards.on.place[i]) == "function" then
			-- Run trigger callback
			res = awards.on.place[i](player,data)
		elseif type(awards.on.place[i]) == "table" then
			-- Handle table trigger
			if not awards.on.place[i].node or not awards.on.place[i].target or not awards.on.place[i].award then
				print("[ERROR] awards - on.place trigger "..i.." is invalid!")
			else
				-- run the table
				local tnodedug = string.split(awards.on.place[i].node, ":")
				local tmod = tnodedug[1]
				local titem = tnodedug[2]
				if tmod==nil or titem==nil or not data.place[tmod] or not data.place[tmod][titem] then
					-- table running failed!
				elseif data.place[tmod][titem] > awards.on.place[i].target-1 then
					res = awards.on.place[i].award
				end
			end
		end

		if res then
			awards.give_achievement(playern,res)
		end
	end
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

	-- Run callbacks and triggers
	for _,trigger in pairs(awards.on.death) do
		local res = nil
		if type(trigger) == "function" then
			res = trigger(player,data)
		elseif type(trigger) == "table" then
			if trigger.target and trigger.award then
				if data.deaths and data.deaths >= trigger.target then
					res = trigger.award
				end
			end
		end
		if res ~= nil then
			awards.give_achievement(name,res)
		end
	end
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

	-- Run callbacks and triggers
	for _, trigger in pairs(awards.on.join) do
		local res = nil
		if type(trigger) == "function" then
			res = trigger(player,data)
		elseif type(trigger) == "table" then
			if trigger.target and trigger.award then
				if data.joins and data.joins >= trigger.target then
					res = trigger.award
				end
			end
		end
		if res ~= nil then
			awards.give_achievement(name,res)
		end
	end
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

	-- Run callbacks and triggers
	for _,trigger in pairs(awards.on.chat) do
		local res = nil
		if type(trigger) == "function" then
			res = trigger(player,data)
		elseif type(trigger) == "table" then
			if trigger.target and trigger.award then
				if data.chats and data.chats >= trigger.target then
					res = trigger.award
				end
			end
		end
		if res ~= nil then
			awards.give_achievement(name,res)
		end
	end
end)

minetest.register_on_newplayer(function(player)
	local playern = player:get_player_name()
	awards.assertPlayer(playern)
end)

minetest.register_on_shutdown(function()
	awards.save()
end)
