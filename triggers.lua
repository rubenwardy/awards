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

-- Player functions

-- Trigger Handles
minetest.register_on_dignode(function(pos, oldnode, digger)
	local nodedug = string.split(oldnode.name, ":")

	local mod=nodedug[1]
	local item=nodedug[2]

	local playern = digger:get_player_name()

	if (playern~=nil and nodedug~=nil and mod~=nil and item~=nil) then
		--check the player's directory
		if not player_data[playern] then
        		player_data[playern]={}
			player_data[playern]['name']=playern
	        end
	        if not player_data[playern]['count'] then
	        	player_data[playern]['count']={}
		end

                --check player.count.mod
		if not player_data[playern].count[mod] then
        		player_data[playern]['count'][mod]={}
	        end

		--check player.count.mod.item
	        if not player_data[playern]['count'][mod][item] then
        		player_data[playern]['count'][mod][item]=0
	        end

		player_data[playern]['count'][mod][item]=player_data[playern]['count'][mod][item]+1

		print(" - "..mod..":"..item.." 's count is now "..(player_data[playern]['count'][mod][item]))
		
		-- Roll through the onDig functions
		local player=digger
		local data=player_data[playern]

		for i=1,# awards.onDig do
			local res=nil
			
			if type(awards.onDig[i]) == "function" then
				-- run the function
				print(i.." is a function")
				res=awards.onDig[i](player,data)
			elseif type(awards.onDig[i]) == "table" then
				-- handle table here
				print(i.." is a table")
				if not awards.onDig[i]['node'] or not awards.onDig[i]['target'] or not awards.onDig[i]['award'] then
					-- table running failed!
				else
					-- run the table
					local tnodedug = string.split(awards.onDig[i]['node'], ":")

					local tmod=tnodedug[1]
					local titem=tnodedug[2]

					if tmod==nil or titem==nil or not data['count'][tmod] or not data['count'][tmod][titem] then
						-- table running failed!
					elseif data['count'][tmod][titem] > awards.onDig[i]['target']-1 then
						res=awards.onDig[i]['award']
					end
				end
			end

			if res~=nil then
				awards.give_achievement(playern,res)
			end
		end
	end
end)

minetest.register_on_placenode(function(pos, newnode, placer)
	local nodedug = string.split(newnode.name, ":")

	local mod=nodedug[1]
	local item=nodedug[2]

	local playern = placer:get_player_name()

	if (playern~=nil and nodedug~=nil and mod~=nil and item~=nil) then
		--check the player's directory
		if not player_data[playern] then
        		player_data[playern]={}
			player_data[playern].place=playern
	        end
	        if not player_data[playern].place then
	        	player_data[playern]['place']={}
		end

                --check player.count.mod
		if not player_data[playern].place[mod] then
        		player_data[playern].place[mod]={}
	        end

		--check player.count.mod.item
	        if not player_data[playern].place[mod][item] then
        		player_data[playern].place[mod][item]=0
	        end

		player_data[playern].place[mod][item]=player_data[playern].place[mod][item]+1

		print(" - "..mod..":"..item.." 's place is now "..(player_data[playern].place[mod][item]))
		
		-- Roll through the onDig functions
		local player=placer
		local data=player_data[playern]

		for i=1,# awards.onPlace do
			local res=nil

			if type(awards.onPlace[i]) == "function" then
				-- run the function
				print(i.." is a function")
				res=awards.onPlace[i](player,data)
			elseif type(awards.onPlace[i]) == "table" then
				-- handle table here
				print(i.." is a table")
				if not awards.onPlace[i]['node'] or not awards.onPlace[i].target or not awards.onPlace[i].award then
					-- table running failed!
				else
					-- run the table
					local tnodedug = string.split(awards.onPlace[i]['node'], ":")

					local tmod=tnodedug[1]
					local titem=tnodedug[2]

					if tmod==nil or titem==nil or not data.place[tmod] or not data.place[tmod][titem] then
						-- table running failed!
					elseif data['place'][tmod][titem] > awards.onPlace[i]['target']-1 then
						res=awards.onPlace[i]['award']
					end
				end
			end

			if res~=nil then
				awards.give_achievement(playern,res)
			end
		end
	end
end)

minetest.register_on_dieplayer(function(player)
        player_data[player:get_player_name()]['deaths']=player_data[player:get_player_name()]['deaths']+1
	
	-- Set up the variables
	local playern=player:get_player_name()
	local data=player_data[playern]
	
	-- Roll through the onDeath functions
	for i=1,# awards.onDeath do
		local res=nil
		if type(awards.onDeath[i]) == "function" then
			-- run the function
			print(i.." is a function")
			res=awards.onDeath[i](player,data)
		elseif type(awards.onDeath[i]) == "table" then
			-- handle table here
			print(i.." is a table")
			if not awards.onDeath[i]['target'] or not awards.onDeath[i]['award'] then
				-- table running failed!
			else
				-- run the table

				if not data['deaths'] then
					-- table running failed!
				elseif data['deaths'] > awards.onDeath[i]['target']-1 then
					res=awards.onDeath[i]['award']
				end
			end
		end

		if res~=nil then
			awards.give_achievement(playern,res)
		end
	end
end)

minetest.register_on_newplayer(function(player)
	--Player data root
	player_data[player:get_player_name()]={}
	player_data[player:get_player_name()]['name']=player:get_player_name()
	player_data[player:get_player_name()]['deaths']=0
	
	--The player counter
	player_data[player:get_player_name()]['count']={}
	player_data[player:get_player_name()]['place']={}

	--Table to contain achievement records
	player_data[player:get_player_name()]['unlocked']={}
end)

minetest.register_on_shutdown(function()
    save_playerD()
end)