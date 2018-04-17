# Awards

Adds awards/achievements to Minetest (plus a very good API).

by [rubenwardy](https://rubenwardy.com), licensed under MIT.
With thanks to Wuzzy, kaeza, and MrIbby.

Majority of awards are back ported from Calinou's old fork in Carbone, under same license.

# API

## Registering Awards

```lua
awards.register_award("mymod:myaward", {
	description = "The title of the award",

	-- Optional:

	difficulty = 1.0, -- Difficulty multipler

	requires = { "amod:an_award" }, -- don't show this award or allow it to be unlocked
									-- until required awards are unlocked

	sound = {}, -- SimpleSoundSpec or false to play no sound
	            -- if not provided, uses default sound

	image = "icon_image.png", -- uses default icon otherwise

	background = "background_image.png", -- uses default background otherwise


	trigger = { -- is only unlocked by direct calls to awards.unlock() otherwise
		type = "trigger_type",
		-- see specific docs on the trigger to see what else goes here
	},

	-- Callback. award_def is this table (plus some additional methods/members added by register_award)
	on_unlock = function(name, award_def) end,
})
```

If the award is counted, ie: there's a trigger.target property, then the difficulty
multipler is timesd by target to get the overal difficulty. If the award isn't a
counted type then the difficulty multiplier is used as the overal difficulty.
Award difficulty affects how awards are sorted in a list - more difficult awards
are further down the list.

Actual code used to calculate award difficulty:

```lua
local difficulty = def.difficulty or 1
if def.trigger and def.trigger.target then
	difficulty = difficulty * def.trigger.target
end
```

## Registering Trigger Types

```lua
local trigger = awards.register_trigger(name, {
	type = "", -- type of trigger, defaults to custom

	progress = "%2/%2"
	auto_description = { "Mine: @2", "Mine: @1×@2" },

	on_register = function(self, def) end,

	-- "counted_key" only, when no key is given (ie: a total)
	auto_description_total = { "Mine @1 block.", "Mine @1 blocks." },

	-- "counted_key" only, get key for particular award - return nil for a total
	get_key = function(self, def)
		return minetest.registered_aliases[def.trigger.node] or def.trigger.node
	end,
})
```

Types:

* "custom" requires you handle the calling of awards.unlock() yourself. You also
  need to implement on_register() yourself.
* "counted" stores a single counter for each player which is incremented by calling
  trigger:notify(player). Good for homogenous actions like number of chat messages,
  joins, and the like.
* "counted_key" stores a table of counters each indexed by a key. There is also
  a total field (`__total`) which stores the sum of all counters. A counter is
  incremented by calling trigger:notify(player, key). This is good for things like
  placing nodes or crafting items, where the key will be the item or node name.


## Helper Functions

* awards.register_on_unlock(func(name, def))
	* name is the player name
	* def is the award def.
	* return true to cancel HUD

* awards.unlock(name, award)
	* gives an award to a player
	* name is the player name

# Included in the Mod

The API, above, allows you to register awards
and triggers (things that look for events and unlock awards, they need
to be registered in order to get details from award_def.trigger).

However, all awards and triggers are separate from the API.
They can be found in init.lua and triggers.lua

## Triggers

Callbacks (register a function to be run)

"dig", "place", "craft", "death", "chat", "join" or "eat"
* dig type: Dig a node.
	* node: the dug node type. If nil, all dug nodes are counted
* place type: Place a node.
	* node: the placed node type. If nil, all placed nodes are counted
* eat type: Eat an item.
	* item: the eaten item type. If nil, all eaten items are counted
* craft type: Craft something.
	* item: the crafted item type. If nil, all crafted items are counted
* death type: Die.
	* reason: the death reason, one of the types in PlayerHPChangeReason (see lua_api.txt)
				or nil for total deaths.
* chat type: Write a chat message.
* join type: Join the server.
* (for all types) target - how many times to dig/place/craft/etc.
* See Triggers

### dig

	trigger = {
		type   = "dig",
		node   = "default:dirt",
		target = 50,
	}

### place

	trigger = {
		type   = "place",
		node   = "default:dirt",
		target = 50,
	}

### death

	trigger = {
		type   = "death",
		reason = "fall",
		target = 5,
	}

### chat

	trigger = {
		type   = "chat",
		target = 100,
	}

### join

	trigger = {
		type   = "join",
		target = 100,
	}

### eat

	trigger = {
		type   = "eat",
		item   = "default:apple",
		target = 100,
	}

## Callbacks relating to triggers

* awards.register_on_dig(func(player, data))
	* data is player data (see below)
	* return award name or null
* awards.register_on_place(func(player, data))
	* data is player data (see below)
	* return award name or null
* awards.register_on_eat(func(player, data))
	* data is player data (see below)
	* return award name or null
* awards.register_on_death(func(player, data))
	* data is player data (see below)
	* return award name or null
* awards.register_on_chat(func(player, data))
	* data is player data (see below)
	* return award name or null
* awards.register_on_join(func(player, data)
	* data is player data (see below)
	* return award name or null
