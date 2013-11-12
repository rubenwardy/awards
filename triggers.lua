--	AWARDS
--	   by Rubenwardy, CC-BY-SA
-------------------------------------------------------
-- this is the trigger handler file for the awards mod
-------------------------------------------------------

-- Function and table holders for Triggers
awards.onDig={}
awards.onPlace={}
awards.onTick={}
awards.onDeath={}

-- Trigger Handles
minetest.register_on_dignode(function(pos, oldnode, digger)
	if not digger or not pos or not oldnode then
		return
	end
	local nodedug = string.split(oldnode.name, ":")
	if #nodedug ~= 2 then
		print(oldnode.name.." is in wrong format!")
		return
	end
	local mod=nodedug[1]
	local item=nodedug[2]
	local playern = digger:get_player_name()

	if (not playern or not nodedug or not mod or not item) then
		return
	end
	awards.assertPlayer(playern)
	awards.tbv(awards.players[playern].count,                mod)
        awards.tbv(awards.players[playern].count[mod],        item,                0        )

	-- Increment counder
	awards.players[playern].count[mod][item]=awards.players[playern].count[mod][item]+1
	print(" - "..mod..":"..item.." 's count is now "..(awards.players[playern].count[mod][item]))

	-- Run callbacks and triggers
	local player=digger
	local data=awards.players[playern]

	for i=1,# awards.onDig do
		local res = nil
		if type(awards.onDig[i]) == "function" then
			-- Run trigger callback
			res = awards.onDig[i](player,data)
		elseif type(awards.onDig[i]) == "table" then
			-- Handle table trigger
			if not awards.onDig[i].node or not awards.onDig[i].target or not awards.onDig[i].award then
				-- table running failed!
				print("[ERROR] awards - onDig trigger "..i.." is invalid!")
			else
				-- run the table
				local tnodedug = string.split(awards.onDig[i].node, ":")
				local tmod=tnodedug[1]
				local titem=tnodedug[2]
				if tmod==nil or titem==nil or not data.count[tmod] or not data.count[tmod][titem] then
					-- table running failed!
				elseif data.count[tmod][titem] > awards.onDig[i].target-1 then
					res=awards.onDig[i].award
				end
			end
		end

		if res then
			awards.give_achievement(playern,res)
		end
	end
end)

minetest.register_on_placenode(function(pos,node,digger)
	if not digger or not pos or not node or not digger:get_player_name() or digger:get_player_name()=="" then
		return
	end
	local nodedug = string.split(node.name, ":")
	if #nodedug ~= 2 then
		print(oldnode.name.." is in wrong format!")
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
	awards.tbv(awards.players[playern].place,                mod)
        awards.tbv(awards.players[playern].place[mod],        item,                0        )

	-- Increment counder
	awards.players[playern].place[mod][item] = awards.players[playern].place[mod][item]+1
	print(" - "..mod..":"..item.." 's place count is now "..(awards.players[playern].place[mod][item]))

	-- Run callbacks and triggers
	local player = digger
	local data = awards.players[playern]
	for i=1,# awards.onPlace do
		local res = nil
		if type(awards.onPlace[i]) == "function" then
			-- Run trigger callback
			res = awards.onPlace[i](player,data)
		elseif type(awards.onPlace[i]) == "table" then
			-- Handle table trigger
			if not awards.onPlace[i].node or not awards.onPlace[i].target or not awards.onPlace[i].award then
				-- table running failed!
				print("[ERROR] awards - onPlace trigger "..i.." is invalid!")
			else
				-- run the table
				local tnodedug = string.split(awards.onPlace[i].node, ":")
				local tmod = tnodedug[1]
				local titem = tnodedug[2]
				if tmod==nil or titem==nil or not data.place[tmod] or not data.place[tmod][titem] then
					-- table running failed!
				elseif data.place[tmod][titem] > awards.onPlace[i].target-1 then
					res = awards.onPlace[i].award
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
	if not player or not player:get_player_name() or player:get_player_name()=="" then
		return
	end
	local playern = player:get_player_name()
	awards.assertPlayer(playern)


	-- Increment counter
        awards.players[player:get_player_name()].deaths = awards.players[player:get_player_name()].deaths + 1
	
	-- Run callbacks and triggers
	local data=awards.players[playern]
	for i=1,# awards.onDeath do
		local res=nil
		if type(awards.onDeath[i]) == "function" then
			-- Run trigger callback
			res=awards.onDeath[i](player,data)
		elseif type(awards.onDeath[i]) == "table" then
			-- handle table here
			if not awards.onDeath[i].target or not awards.onDeath[i].award then
				-- table running failed!
				print("[ERROR] awards - onDeath trigger "..i.." is invalid!")
			else
				-- run the table
				if not data.deaths then
					-- table running failed!
				elseif data.deaths > awards.onDeath[i].target-1 then
					res=awards.onDeath[i].award
				end
			end
		end

		if res~=nil then
			awards.give_achievement(playern,res)
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