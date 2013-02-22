Awards
------

by Andrew "Rubenwardy" Ward, CC-BY-SA.

This mod adds achievements to Minetest.


Code Reference
--------------

The API
=======
* awards.register_achievement(name,data_table)
	* name
	* desciption
	* sound [optional]
	* image [optional]
	* func [optional] - see below
* awards.give_achievement(name,award)
	* -- gives an award to a player
* awards.register_onDig(func)
	* -- return award name or null
	* -- there will be built in versions of this function
* awards.register_onPlace(func)
	* -- return award name or null
	* -- there will be built in versions of this function


Player Data
===========

A list of data referenced/hashed by the player's name.

* name [string]
* getNodeCount('node_name') [function]
* count [table] - dig counter
	* modname [table]
		* itemname [int]
* place [table] - place counter
	* modname [table]
		* itemname [int]