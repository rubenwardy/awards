-- AWARDS
--
-- Copyright (C) 2013-2015 rubenwardy
-- This program is free software; you can redistribute it and/or modify
-- it under the terms of the GNU Lesser General Public License as published by
-- the Free Software Foundation; either version 2.1 of the License, or
-- (at your option) any later version.
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU Lesser General Public License for more details.
-- You should have received a copy of the GNU Lesser General Public License along
-- with this program; if not, write to the Free Software Foundation, Inc.,
-- 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
--

-- The global award namespace
awards = {
	show_mode = "hud",
	registered_triggers = {},
}

-- Internationalization support.
awards.gettext, awards.ngettext = dofile(minetest.get_modpath("awards").."/intllib.lua")
dofile(minetest.get_modpath("awards").."/api_helpers.lua")
dofile(minetest.get_modpath("awards").."/api.lua")
dofile(minetest.get_modpath("awards").."/chat_commands.lua")
dofile(minetest.get_modpath("awards").."/gui.lua")
dofile(minetest.get_modpath("awards").."/triggers.lua")
-- dofile(minetest.get_modpath("awards").."/awards.lua")

-- Backwards compatibility
awards.give_achievement = awards.unlock
awards.getFormspec      = awards.get_formspec
awards.showto           = awards.show_to
awards.register_onDig   = awards.register_on_dig
awards.register_onPlace = awards.register_on_place
awards.register_onDeath = awards.register_on_death
awards.register_onChat  = awards.register_on_chat
awards.register_onJoin  = awards.register_on_join
awards.register_onCraft = awards.register_on_craft

awards.register_achievement("award_saint_maclou",{
	title = "Saint-Maclou",
	description = "Place 20 coal checkers.",
	icon = "awards_novicebuilder.png",
	trigger = {
		type = "chat",
		target = 3,
	},
})
