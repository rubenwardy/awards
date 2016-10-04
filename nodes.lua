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

local S
if (intllib) then
	dofile(minetest.get_modpath("intllib").."/intllib.lua")
	S = intllib.Getter(minetest.get_current_modname())
else
	S = function ( s ) return s end
end

local board_img = "signs_wall_sign.png^[colorize:red:120^awards_trophy_icon.png"

minetest.register_node("awards:board", {
  	description = S("Awards Board")..S("\n  right-clic to open \n  left-clic to display in chat"),
	drawtype = "nodebox",
	tiles = {board_img},
	inventory_image = board_img,
	wield_image = board_img,
	paramtype = "light",
	paramtype2 = "wallmounted",
	sunlight_propagates = true,
	is_ground_content = false,
	walkable = false,
	node_box = {
		type = "wallmounted",
		wall_top    = {-0.4375, 0.4375, -0.3125, 0.4375, 0.5, 0.3125},
		wall_bottom = {-0.4375, -0.5, -0.3125, 0.4375, -0.4375, 0.3125},
		wall_side   = {-0.5, -0.3125, -0.4375, -0.4375, 0.3125, 0.4375},
	},
	groups = {choppy=2,dig_immediate=2,attached_node=1},
	legacy_wallmounted = true,
	sounds = default.node_sound_defaults(),

   after_place_node = function(pos, placer)
		local meta = minetest.get_meta(pos)
		meta:set_string("owner", placer:get_player_name() or "")
		meta:set_string("infotext", S("Consult").." "..
				meta:get_string("owner")..S("'s Awards")..S("\n  right-clic to open \n  left-clic to display in chat"))
	end,
	
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("infotext", S("Consult Awards"))
		meta:set_string("owner", "")
	end,
	
  	on_punch = function(pos, node, puncher)
		local meta = minetest.get_meta(pos)
		awards.show_to(meta:get_string("owner"),puncher:get_player_name(), nil, true)
	end,
	
	on_rightclick = function(pos, node, clicker)
		local meta = minetest.get_meta(pos)
		awards.show_to(meta:get_string("owner"),clicker:get_player_name(), nil, false)
	end,

})


minetest.register_craft({
   output = "awards:board",
   recipe = { 
              { "wool:red","default:glass","wool:red " },
              { "default:sign_wall_wood","default:gold_lump","default:sign_wall_wood" },
             }
});

minetest.register_craft({
   output = "awards:board",
   recipe = { 
              { "wool:red","group:glass","wool:red " },
              { "group:sign_wall","default:gold_lump","group:sign_wall" },
             }
});

