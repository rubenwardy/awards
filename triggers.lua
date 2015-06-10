-- AWARDS
--    by Rubenwardy
-------------------------------------------------------
-- this is the trigger handler file for the awards mod
-------------------------------------------------------

awards.register_trigger("dig", function(name, def)
	local tmp = {
		award  = name,
		node   = def.trigger.node,
		target = def.trigger.target
	}
	table.insert(awards.on.dig, tmp)
end)

awards.register_trigger("place", function(name, def)
	local tmp = {
		award  = name,
		node   = def.trigger.node,
		target = def.trigger.target
	}
	table.insert(awards.on.place, tmp)
end)

awards.register_trigger("death", function(name, def)
	local tmp = {
		award  = name,
		target = def.trigger.target
	}
	table.insert(awards.on.death, tmp)
end)

awards.register_trigger("chat", function(name, def)
	local tmp = {
		award  = name,
		target = def.trigger.target
	}
	table.insert(awards.on.chat, tmp)
end)

awards.register_trigger("join", function(name, def)
	local tmp = {
		award  = name,
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
	awards.tbv(awards.players[playern].craft, mod)
	awards.tbv(awards.players[playern].craft[mod], item, 0)

	-- Increment counter
	awards.players[playern].craft[mod][item]=awards.players[playern].craft[mod][item] + 1

	-- Run callbacks and triggers
	local data=awards.players[playern]
	for i=1,# awards.onCraft do
		local res = nil
		if type(awards.onCraft[i]) == "function" then
			-- Run trigger callback
			res = awards.onDig[i](player,data)
		elseif type(awards.onCraft[i]) == "table" then
			-- Handle table trigger
			if not awards.onCraft[i].item or not awards.onCraft[i].target or not awards.onCraft[i].award then
				-- table running failed!
				print("[ERROR] awards - onCraft trigger "..i.." is invalid!")
			else
				-- run the table
				local titemcrafted = string.split(awards.onCraft[i].item, ":")
				local tmod=titemcrafted[1]
				local titem=titemcrafted[2]
				if tmod==nil or titem==nil or not data.craft[tmod] or not data.craft[tmod][titem] then
					-- table running failed!
				elseif data.craft[tmod][titem] > awards.onCraft[i].target-1 then
					res=awards.onCraft[i].award
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
