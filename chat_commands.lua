minetest.register_chatcommand("list_awards", {
	params = "obsolete",
	description = "list_awards: obsolete. Use /awards",
	func = function(name, param)
		minetest.chat_send_player(name, "This command has been made obsolete. Use /awards instead.")
		awards.showto(name, name, nil, false)
	end
})

minetest.register_chatcommand("awards", {
	params = "",
	description = "awards: list awards",
	func = function(name, param)
		awards.showto(name, name, nil, false)
	end
})

minetest.register_chatcommand("cawards", {
	params = "",
	description = "awards: list awards in chat",
	func = function(name, param)
		awards.showto(name, name, nil, true)
	end
})

minetest.register_chatcommand("awd", {
	params = "award name",
	description = "awd: Details of awd gotten",
	func = function(name, param)
		local def = awards.def[param]
		if def then
			minetest.chat_send_player(name,def.title..": "..def.description)
		else
			minetest.chat_send_player(name,"Award not found.")
		end
	end
})
