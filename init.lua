-- Copyright (c) 2013-18 rubenwardy. MIT.

-- The global award namespace
awards = {
	show_mode = "hud",
	registered_triggers = {},
}

-- Internationalization support.
awards.gettext, awards.ngettext = dofile(minetest.get_modpath("awards").."/intllib.lua")

-- Load files
dofile(minetest.get_modpath("awards").."/api.lua")
dofile(minetest.get_modpath("awards").."/chat_commands.lua")
dofile(minetest.get_modpath("awards").."/gui.lua")
dofile(minetest.get_modpath("awards").."/triggers.lua")
dofile(minetest.get_modpath("awards").."/awards.lua")

-- Backwards compatibility
awards.give_achievement     = awards.unlock
awards.getFormspec          = awards.get_formspec
awards.showto               = awards.show_to
awards.register_onDig       = awards.register_on_dig
awards.register_onPlace     = awards.register_on_place
awards.register_onDeath     = awards.register_on_death
awards.register_onChat      = awards.register_on_chat
awards.register_onJoin      = awards.register_on_join
awards.register_onCraft     = awards.register_on_craft
awards.def                  = awards.registered_awards
awards.register_achievement = awards.register_award
