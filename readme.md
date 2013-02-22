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
* awards.register_onDig(func)
	* -- return true if the medal should be rewarded
	* -- there will be built in versions of this function


Player Data
===========

A list of data referenced/hashed by the player's name.

* name [string]
* getNodeCount('node_name') [function]
* count [table]
	* modname [table]
		*itemname [int]