--	AWARDS
--	   by Rubenwardy, CC-BY-SA
-------------------------------------------------------
-- this is the trigger handler file for the awards mod
-------------------------------------------------------

-- Function for Triggers
awards.onDig={}
awards.onTick={}

-- Player functions

-- Trigger Handles
minetest.register_on_dignode(function(pos, oldnode, digger)
	local nodedug = string.split(oldnode.name, ":")

	local mod=nodedug[1]
	local item=nodedug[2]


	print (mod)
	print (item)

	local player = digger:get_player_name()

	print("Awards [Event] - "..player.." has dug a node")

	if (player~=nil and nodedug~=nil and mod~=nil and item~=nil) then
		if not player_data[player] then
        		player_data[player]={}
			player_data[player]['count']={}
			player_data[player]['count']['default']={}
			player_data[player]['count']['default']['dirt']=0
			player_data[player]['name']=player
	        end

		if not player_data[player]['count'][mod] then
        		player_data[player]['count'][mod]={}
	        end

	        if not player_data[player]['count'][mod][item] then
        		player_data[player]['count'][mod][item]=0
	        end

		player_data[player]['count'][mod][item]=player_data[player]['count'][mod][item]+1
		
		print(mod..":"..item.." 's count is now "..(player_data[player]['count'][mod][item]))
	else
		print(player.."'s dig event has been skipped")
	end
end)

minetest.register_on_newplayer(function(player)
	player_data[player:get_player_name()]={}
	player_data[player:get_player_name()]['count']={}
	player_data[player:get_player_name()]['count']['default']={}
	player_data[player:get_player_name()]['count']['default']['dirt']=0
	player_data[player:get_player_name()]['name']=player:get_player_name()
end)