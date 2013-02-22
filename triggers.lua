--	AWARDS
--	   by Rubenwardy, CC-BY-SA
-------------------------------------------------------
-- this is the trigger handler file for the awards mod
-------------------------------------------------------

-- Function for Triggers
awards.onDig={}
awards.onPlace={}
awards.onTick={}

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
			player_data[playern]['count']={}
			player_data[playern]['name']=playern
	        end

                --check player.count.mod
		if not player_data[playern]['count'][mod] then
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
			local res=awards.onDig[i](player,data)

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
			player_data[playern]['place']={}
			player_data[playern]['name']=playern
	        end

                --check player.count.mod
		if not player_data[playern]['place'][mod] then
        		player_data[playern]['place'][mod]={}
	        end

		--check player.count.mod.item
	        if not player_data[playern]['place'][mod][item] then
        		player_data[playern]['place'][mod][item]=0
	        end

		player_data[playern]['place'][mod][item]=player_data[playern]['place'][mod][item]+1

		print(" - "..mod..":"..item.." 's place is now "..(player_data[playern]['place'][mod][item]))
		
		-- Roll through the onDig functions
		local player=placer
		local data=player_data[playern]

		for i=1,# awards.onPlace do
			local res=awards.onPlace[i](player,data)

			if res~=nil then
				awards.give_achievement(playern,res)
			end
		end
	end
end)

minetest.register_on_newplayer(function(player)
	minetest.chat_send_player(player:get_player_name(),"[Awards] Registering you now...")
	
	--Player data root
	player_data[player:get_player_name()]={}
	player_data[player:get_player_name()]['name']=player:get_player_name()
	
	--The player counter
	player_data[player:get_player_name()]['count']={}
	player_data[player:get_player_name()]['place']={}

	--Table to contain achievement records
	player_data[player:get_player_name()]['unlocked']={}
end)

minetest.register_on_shutdown(function()
    save_playerD()
end)