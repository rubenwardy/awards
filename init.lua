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

dofile(minetest.get_modpath("awards").."/api.lua")
dofile(minetest.get_modpath("awards").."/chat_commands.lua")
dofile(minetest.get_modpath("awards").."/triggers.lua")
awards.set_intllib(S)

-- Light it up
awards.register_achievement("award_lightitup",{
	title = S("Light It Up"),
	description = S("Place 100 torches."),
	icon = "novicebuilder.png",
	trigger = {
		type = "place",
		node = "default:torch",
		target = 100
	}
})

-- Light ALL the things!
awards.register_achievement("award_well_lit",{
	title = S("Well Lit"),
	description = S("Place 1,000 torches."),
	icon = "novicebuilder.png",
	trigger = {
		type = "place",
		node = "default:torch",
		target = 1000
	}
})


-- Saint-Maclou
if minetest.get_modpath("moreblocks") then
	awards.register_achievement("award_saint_maclou",{
		title = S("Saint-Maclou"),
		description = S("Place 20 coal checkers."),
		icon = "novicebuilder.png",
		trigger = {
			type = "place",
			node = "moreblocks:coal_checker",
			target = 20
		}
	})

	-- Castorama
	awards.register_achievement("award_castorama",{
		title = S("Castorama"),
		description = S("Place 20 iron checkers."),
		icon = "novicebuilder.png",
		trigger = {
			type = "place",
			node = "moreblocks:iron_checker",
			target = 20
		}
	})

	-- Sam the Trapper
	awards.register_achievement("award_sam_the_trapper",{
		title = S("Sam the Trapper"),
		description = S("Place 2 trap stones."),
		icon = "novicebuilder.png",
		trigger = {
			type = "place",
			node = "moreblocks:trap_stone",
			target = 2
		}
	})
end


awards.register_achievement("awards_stonebrick", {
	title = S("Home Improvement"),
	description = S("Craft 200 stone bricks."),
	icon = "default_stone_brick.png",
	trigger = {
		type = "craft",
		item = "default:stonebrick",
		target = 200
	}
})

awards.register_achievement("awards_desert_stonebrick", {
	title = S("Desert Dweller"),
	description = S("Craft 400 desert stone bricks."),
	icon = "default_desert_stone_brick.png",
	trigger = {
		type = "craft",
		item = "default:desert_stonebrick",
		target = 400
	}
})

awards.register_achievement("awards_desertstonebrick", {
	title = S("Pharaoh"),
	description = S("Craft 100 sandstone bricks."),
	icon = "default_sandstone_brick.png",
	trigger = {
		type = "craft",
		item = "default:sandstonebrick",
		target = 100
	}
})

awards.register_achievement("awards_bookshelf", {
	title = S("Little Library"),
	description = S("Craft 7 bookshelves."),
	icon = "default_bookshelf.png",
	trigger = {
		type = "craft",
		item = "default:bookshelf",
		target = 7
	}
})

awards.register_achievement("awards_obsidian", {
	title = S("Lava and Water"),
	description = S("Mine your first obsidian."),
	icon = "default_obsidian.png",
	trigger = {
		type = "dig",
		node = "default:obsidian",
		target = 1
	}
})

-- Obsessed with Obsidian
awards.register_achievement("award_obsessed_with_obsidian",{
	title = S("Obsessed with Obsidian"),
	description = S("Mine 50 obsidian."),
	icon = "miniminer.png",
	background = "bg_mining.png",
	trigger = {
		type = "dig",
		node = "default:obsidian",
		target = 50
	}
})

-- On the way
awards.register_achievement("award_on_the_way", {
	title = S("On The Way"),
	description = S("Place 100 rails."),
	icon = "novicebuilder.png",
	trigger = {
		type = "place",
		node = "default:rail",
		target = 100
	}
})

-- Lumberjack
awards.register_achievement("award_lumberjack", {
	title = S("Lumberjack"),
	description = S("Dig 100 tree blocks."),
	icon = "default_tree.png",
	trigger = {
		type = "dig",
		node = "default:tree",
		target = 100
	}
})

-- Semi-pro Lumberjack
awards.register_achievement("award_lumberjack_semipro", {
	title = S("Semi-pro Lumberjack"),
	description = S("Dig 1,000 tree blocks."),
	icon = "default_tree.png",
	trigger = {
		type = "dig",
		node = "default:tree",
		target = 1000
	}
})

-- Professional Lumberjack
awards.register_achievement("award_lumberjack_professional", {
	title = S("Professional Lumberjack"),
	description = S("Dig 10,000 tree blocks."),
	icon = "default_tree.png",
	trigger = {
		type = "dig",
		node = "default:tree",
		target = 10000
	}
})

-- L33T Lumberjack
awards.register_achievement("award_lumberjack_leet", {
	title = S("L33T Lumberjack"),
	description = S("Dig 100,000 tree blocks."),
	icon = "default_tree.png",
	trigger = {
		type = "dig",
		node = "default:tree",
		target = 100000
	}
})

-- Junglebaby
awards.register_achievement("award_junglebaby", {
	title = S("Junglebaby"),
	description = S("Dig 100 jungle tree blocks."),
	icon = "default_jungletree.png",
	trigger = {
		type = "dig",
		node = "default:jungletree",
		target = 100
	}
})

-- Jungleman
awards.register_achievement("award_jungleman", {
	title = S("Jungleman"),
	description = S("Dig 1,000 jungle tree blocks."),
	icon = "default_jungletree.png",
	trigger = {
		type = "dig",
		node = "default:jungletree",
		target = 1000
	}
})

-- Found some Mese!
awards.register_achievement("award_mesefind", {
	title = S("First Mese Find"),
	description = S("Mine your first mese ore."),
	icon = "default_stone.png^default_mineral_mese.png",
	background = "bg_mining.png",
	trigger = {
		type = "dig",
		node = "default:stone_with_mese",
		target = 1
	}
})

-- Mese Block
awards.register_achievement("award_meseblock", {
	secret = true,
	title = S("Mese Mastery"),
	description = S("Mine a mese block."),
	icon = "default_mese_block.png",
	background = "bg_mining.png",
	trigger = {
		type = "dig",
		node = "default:mese",
		target = 1
	}
})



-- You're a copper
awards.register_achievement("award_youre_a_copper", {
	title = S("You're a copper"),
	description = S("Dig 1,000 copper ores."),
	icon = "miniminer.png",
	background = "bg_mining.png",
	trigger = {
		type = "dig",
		node = "default:stone_with_copper",
		target = 1000
	}
})

-- Found a Nyan cat!
awards.register_achievement("award_nyanfind", {
	secret = true,
	title = S("A Cat in a Pop-Tart?!"),
	description = S("Mine a nyan cat."),
	icon = "nyancat_front.png",
	trigger = {
		type = "dig",
		node = "default:nyancat",
		target = 1
	}
})

-- Mini Miner
awards.register_achievement("award_mine2", {
	title = S("Mini Miner"),
	description = S("Dig 100 stone blocks."),
	icon = "miniminer.png",
	background = "bg_mining.png",
	trigger = {
		type = "dig",
		node = "default:stone",
		target = 100
	}
})

-- Hardened Miner
awards.register_achievement("award_mine3", {
	title = S("Hardened Miner"),
	description = S("Dig 1,000 stone blocks."),
	icon = "miniminer.png",
	background = "bg_mining.png",
	trigger = {
		type = "dig",
		node = "default:stone",
		target = 1000
	}
})

-- Master Miner
awards.register_achievement("award_mine4", {
	title = S("Master Miner"),
	description = S("Dig 10,000 stone blocks."),
	icon = "miniminer.png",
	background = "bg_mining.png",
	trigger = {
		type = "dig",
		node = "default:stone",
		target = 10000
	}
})

-- Marchand de sable
awards.register_achievement("award_marchand_de_sable", {
	title = S("Marchand De Sable"),
	description = S("Dig 1,000 sand."),
	icon = "default_sand.png",
	background = "bg_mining.png",
	trigger = {
		type = "dig",
		node = "default:sand",
		target = 1000
	}
})

awards.register_achievement("awards_crafter_of_sticks", {
	title = S("Crafter of Sticks"),
	description = S("Craft 100 sticks."),
	icon = "default_stick.png",
	trigger = {
		type = "craft",
		item = "default:stick",
		target = 100
	}
})

awards.register_achievement("awards_junglegrass", {
	title = S("Jungle Discoverer"),
	description = S("Mine your first jungle grass."),
	icon = "default_junglegrass.png",
	trigger = {
		type = "dig",
		node = "default:junglegrass",
		target = 1
	}
})

awards.register_achievement("awards_grass", {
	title = S("Grasslands Discoverer"),
	description = S("Mine some grass."),
	icon = "default_grass_3.png",
	trigger = {
		type = "dig",
		node = "default:grass_1",
		target = 1
	}
})

awards.register_achievement("awards_dry_grass", {
	title = S("Savannah Discoverer"),
	description = S("Mine some dry grass."),
	icon = "default_dry_grass_3.png",
	trigger = {
		type = "dig",
		node = "default:dry_grass_3",
		target = 1
	}
})

awards.register_achievement("awards_cactus", {
	title = S("Desert Discoverer"),
	description = S("Mine your first cactus."),
	icon = "default_cactus_side.png",
	trigger = {
		type = "dig",
		node = "default:cactus",
		target = 1
	}
})

awards.register_achievement("awards_dry_shrub", {
	title = S("Far Lands"),
	description = S("Mine your first dry shrub."),
	icon = "default_dry_shrub.png",
	trigger = {
		type = "dig",
		node = "default:dry_shrub",
		target = 1
	}
})

awards.register_achievement("awards_farmer", {
	title = S("Farmer"),
	description = S("Dig a fully grown wheat plant."),
	icon = "farming_wheat_8.png",
	trigger = {
		type = "dig",
		node = "farming:wheat_8",
		target = 1
	}
})

awards.register_achievement("awards_ice", {
	title = S("Glacier Discoverer"),
	description = S("Mine your first ice."),
	icon = "default_ice.png",
	trigger = {
		type = "dig",
		node = "default:ice",
		target = 1
	}
})

awards.register_achievement("awards_gold_ore", {
	title = S("First Gold Find"),
	description = S("Mine your first gold ore."),
	icon = "default_stone.png^default_mineral_gold.png",
	trigger = {
		type = "dig",
		node = "default:stone_with_gold",
		target = 1
	}
})

awards.register_achievement("awards_gold_rush", {
	title = S("Gold Rush"),
	description = S("Mine 45 gold ores."),
	icon = "default_stone.png^default_mineral_gold.png",
	trigger = {
		type = "dig",
		node = "default:stone_with_gold",
		target = 45
	}
})

awards.register_achievement("awards_diamond_ore", {
	title = S("Wow, I am Diamonds!"),
	description = S("Mine your first diamond ore."),
	icon = "default_stone.png^default_mineral_diamond.png",
	trigger = {
		type = "dig",
		node = "default:stone_with_diamond",
		target = 1
	}
})

awards.register_achievement("awards_diamond_rush", {
	title = S("Girl's Best Friend"),
	description = S("Mine 18 diamond ores."),
	icon = "default_stone.png^default_mineral_diamond.png",
	trigger = {
		type = "dig",
		node = "default:stone_with_diamond",
		target = 18
	}
})

awards.register_achievement("awards_diamondblock", {
	title = S("Hardest Block on Earth"),
	description = S("Craft a diamond block."),
	icon = "default_diamond_block.png",
	trigger = {
		type = "craft",
		item = "default:diamondblock",
		target = 1
	}
})

awards.register_achievement("awards_mossycobble", {
	title = S("In the Dungeon"),
	description = S("Mine a mossy cobblestone."),
	icon = "default_mossycobble.png",
	trigger = {
		type = "dig",
		node = "default:mossycobble",
		target = 1
	}
})
