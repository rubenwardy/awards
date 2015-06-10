# Awards

by Andrew "Rubenwardy" Ward, LGPL 2.1 or later.

This mod adds achievements to Minetest.

Majority of awards are back ported from Calinou's
old fork in Carbone, under same license.


# Basic API

* awards.register_achievement(name, def)
	* name
	* desciption
	* sound [optional]
	* image [optional] - texture name, eg: award_one.png
	* background [optional] - texture name, eg: award_one.png
	* trigger [optional] [table]
		* type - "dig", "place", "craft", "death", "chat" or "join"
		* (for dig/place type) node - the nodes name
		* (for craft type) item - the items name
		* (for all types) target - how many to dig / place
		* See Triggers
	* secret [optional] - if true, then player needs to unlock to find out what it is.
* awards.register_trigger(name, func(awardname, def))
	* Note: awards.on[name] is automatically created for triggers
* awards.give_achievement(name,award)
	* -- gives an award to a player

# Included in the Mod

## Triggers

* awards.register_on_dig(func(player, data))
	* -- return award name or null
* awards.register_on_place(func(player, data))
	* -- return award name or null
* awards.register_on_death(func(player, data))
	* -- return award name or null
* awards.register_on_chat(func(player, data))
	* -- return award name or null
* awards.register_on_join(func(player, data))
	* -- return award name or null
* awards.register_onCraft(func(player,data))
	* -- return award name or null


# Player Data

A list of data referenced/hashed by the player's name.
* player name
	* name [string]
	* count [table] - dig counter
		* modname [table]
			* itemname [int]
	* place [table] - place counter
		* modname [table]
			* itemname [int]
	* craft [table] - craft counter
		* modname [table]
			* itemname [int]
	* deaths
	* chats
	* joins
