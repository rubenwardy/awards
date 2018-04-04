function awards.player(name)
	local data = awards.players[name] or {}
	awards.players[name] = data
	data.name = data.name or name
	data.unlocked = data.unlocked or {}
	return data
end

function awards.player_or_nil(name)
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
