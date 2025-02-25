-- 	TODO: select & use button from packs (e.g. how shops let you buy & use)
-- TODO: oddity usage statistics (lazy)

OddityAPI = {
	config = {
		enable_packs = true,
		enable_tags = true,
		base_shop_rate = 3,
		
		-- rate of common oddities - default: 65
		base_common_rate = 65,
		-- rate of uncommon oddities - default: 30
		base_uncommon_rate = 30,
		-- rate of rare oddities - default: 5
		base_rare_rate = 5,
		-- rate of legendary oddities - default: 0
		base_legendary_rate = 0,
	}
}

G.C.SET.Oddity = HEX("826390")
G.C.SECONDARY_SET.Oddity = HEX("826390")
loc_colour("mult", nil)
G.ARGS.LOC_COLOURS["oddity"] = G.C.SECONDARY_SET.Oddity

SMODS.Atlas {
	key = "Oddity",
	path = "Oddity.png",
	px = 71,
	py = 95,
}

SMODS.ConsumableType {
	key = 'Oddity',
	collection_rows = { 5, 5, 5 },
	primary_colour = G.C.SET.Oddity,
	secondary_colour = G.C.SECONDARY_SET.Oddity,
	loc_txt = {
		name = "Oddity",
		collection = "Oddities",
		label = "Oddity",
		undiscovered = {
			name = "Not Discovered",
			text = {
				"Purchase or use",
				"this oddity in an",
				"unseeded run to",
				"learn what it does"
			},
		},
	},
	inject_card = function(self, center)
		if not self.default then self.default = center.key end
		center.rarity = center.rarity and math.min(center.rarity, center.rarity*-1) or -1
		SMODS.ConsumableType.inject_card(self, center)
		table.insert(self.rarity_pools[center.rarity], center)
	end,
	set_card_type_badge = function(self,_c,card,badges)
		table.insert(badges, create_badge(localize('k_oddity'), G.C.SECONDARY_SET.Oddity, nil, 1.2))
		if _c.discovered then
			local rarity_names = {localize('k_common'), localize('k_uncommon'), localize('k_rare'), localize('k_legendary')}
			local rarity_name = rarity_names[-1*_c.rarity]
			local rarity_color = G.C.RARITY[-1*_c.rarity]
			table.insert(badges, create_badge(rarity_name, rarity_color, nil, 1.0))
		end
	end,
	rarities = {{key = -1, weight = OddityAPI.config.base_common_rate}, {key = -2, weight = OddityAPI.config.base_uncommon_rate}, {key = -3, weight = OddityAPI.config.base_rare_rate}, {key = -4, weight = OddityAPI.config.base_legendary_rate}},
	shop_rate = OddityAPI.config.base_shop_rate,
}

SMODS.UndiscoveredSprite {
	key = "Oddity",
	atlas = "Oddity",
	pos = {
		x = 0,
		y = 1,
	}
}

local normalPack = {
    name = "Oddity Pack",
    text = {
        "Choose {C:attention}1{} of up to",
        "{C:attention}3{C:oddity} Oddities{} to add",
        "to your consumables"
    }
}
local jumboPack = {
    name = "Jumbo Oddity Pack",
    text = {
        "Choose {C:attention}1{} of up to",
        "{C:attention}5{C:oddity} Oddities{} to add",
        "to your consumables"
    }
}
local megaPack = {
    name = "Mega Oddity Pack",
    text = {
        "Choose {C:attention}2{} of up to",
        "{C:attention}5{C:oddity} Oddities{} to add",
        "to your consumables"
    }
}

local oddity_create_card = function(self, card)
        return create_card("Oddity", G.pack_cards, nil, nil, true, true, nil, 'odd')
end
local oddity_pack_particles = function(self)
    G.booster_pack_sparkles = Particles(1, 1, 0,0, {
        timer = 0.015,
        scale = 0.3,
        initialize = true,
        lifespan = 3,
        speed = 0.2,
        padding = -1,
        attach = G.ROOM_ATTACH,
        colours = {G.C.RED, G.C.BLUE, G.C.PURPLE, G.C.GREEN, G.C.GOLD},
        fill = true
    })
    G.booster_pack_sparkles.fade_alpha = 1
    G.booster_pack_sparkles:fade(1, 0)
end
local oddity_pack_bg = function(self)
    ease_colour(G.C.DYN_UI.MAIN, mix_colours(G.C.SECONDARY_SET.Oddity, G.C.BLACK, 0.9))
    ease_background_colour{new_colour = mix_colours(G.C.SECONDARY_SET.Oddity, G.C.BLACK, 0.6), special_colour = G.C.BLACK, contrast = 2}
end

SMODS.Booster{
    name = "Oddity Pack",
    key = "oddity_normal_1",
    kind = "Oddity",
    atlas = "Oddity",
    pos = { x = 1, y = 0 },
    config = { extra = 3, choose = 1 },
    cost = 4,
    order = 1,
    weight = 1,
    draw_hand = false,
    unlocked = true,
    discovered = true,
    loc_txt = normalPack,
    create_card = oddity_create_card,
    particles = oddity_pack_particles,
    ease_background_colour = oddity_pack_bg,
    group_key = "k_amm_oddity_pack",
    in_pool = function()
        return #G.P_CENTER_POOLS.Oddity > 0
    end,
}
SMODS.Booster{
    name = "Oddity Pack",
    key = "oddity_normal_2",
    kind = "Oddity",
    atlas = "Oddity",
    pos = { x = 2, y = 0 },
    config = { extra = 3, choose = 1 },
    cost = 4,
    order = 2,
    weight = 1,
    draw_hand = false,
    unlocked = true,
    discovered = true,
    loc_txt = normalPack,
    create_card = oddity_create_card,
    particles = oddity_pack_particles,
    ease_background_colour = oddity_pack_bg,
    group_key = "k_amm_oddity_pack",
    in_pool = function()
        return #G.P_CENTER_POOLS.Oddity > 0
    end,
}
SMODS.Booster{
    name = "Oddity Pack",
    key = "oddity_normal_3",
    kind = "Oddity",
    atlas = "Oddity",
    pos = { x = 3, y = 0 },
    config = { extra = 3, choose = 1 },
    cost = 4,
    order = 3,
    weight = 1,
    draw_hand = false,
    unlocked = true,
    discovered = true,
    loc_txt = normalPack,
    create_card = oddity_create_card,
    particles = oddity_pack_particles,
    ease_background_colour = oddity_pack_bg,
    group_key = "k_amm_oddity_pack",
    in_pool = function()
        return #G.P_CENTER_POOLS.Oddity > 0
    end,
}
SMODS.Booster{
    name = "Oddity Pack",
    key = "oddity_normal_4",
    kind = "Oddity",
    atlas = "Oddity",
    pos = { x = 4, y = 0 },
    config = { extra = 3, choose = 1 },
    cost = 4,
    order = 4,
    weight = 1,
    draw_hand = false,
    unlocked = true,
    discovered = true,
    loc_txt = normalPack,
    create_card = oddity_create_card,
    particles = oddity_pack_particles,
    ease_background_colour = oddity_pack_bg,
    group_key = "k_amm_oddity_pack",
    in_pool = function()
        return #G.P_CENTER_POOLS.Oddity > 0
    end,
}
SMODS.Booster{
    name = "Jumbo Oddity Pack",
    key = "oddity_jumbo_1",
    kind = "Oddity",
    atlas = "Oddity",
    pos = { x = 1, y = 1 },
    config = { extra = 5, choose = 1 },
    cost = 6,
    order = 5,
    weight = 1,
    draw_hand = false,
    unlocked = true,
    discovered = true,
    loc_txt = jumboPack,
    create_card = oddity_create_card,
    particles = oddity_pack_particles,
    ease_background_colour = oddity_pack_bg,
    group_key = "k_amm_oddity_pack",
    in_pool = function()
        return #G.P_CENTER_POOLS.Oddity > 0
    end,
}
SMODS.Booster{
    name = "Jumbo Oddity Pack",
    key = "oddity_jumbo_2",
    kind = "Oddity",
    atlas = "Oddity",
    pos = { x = 2, y = 1 },
    config = { extra = 5, choose = 1 },
    cost = 6,
    order = 6,
    weight = 1,
    draw_hand = false,
    unlocked = true,
    discovered = true,
    loc_txt = jumboPack,
    create_card = oddity_create_card,
    particles = oddity_pack_particles,
    ease_background_colour = oddity_pack_bg,
    group_key = "k_amm_oddity_pack",
    in_pool = function()
        return #G.P_CENTER_POOLS.Oddity > 0
    end,
}
SMODS.Booster{
    name = "Mega Oddity Pack",
    key = "oddity_mega_1",
    kind = "Oddity",
    atlas = "Oddity",
    pos = { x = 3, y = 1 },
    config = { extra = 5, choose = 2 },
    cost = 8,
    order = 7,
    weight = 0.25,
    draw_hand = false,
    unlocked = true,
    discovered = true,
    loc_txt = megaPack,
    create_card = oddity_create_card,
    particles = oddity_pack_particles,
    ease_background_colour = oddity_pack_bg,
    group_key = "k_amm_oddity_pack",
    in_pool = function()
        return #G.P_CENTER_POOLS.Oddity > 0
    end,
}
SMODS.Booster{
    name = "Mega Oddity Pack",
    key = "oddity_mega_2",
    kind = "Oddity",
    atlas = "Oddity",
    pos = { x = 4, y = 1 },
    config = { extra = 5, choose = 2 },
    cost = 8,
    order = 8,
    weight = 0.25,
    draw_hand = false,
    unlocked = true,
    discovered = true,
    loc_txt = megaPack,
    create_card = oddity_create_card,
    particles = oddity_pack_particles,
    ease_background_colour = oddity_pack_bg,
    group_key = "k_amm_oddity_pack",
    in_pool = function()
        return #G.P_CENTER_POOLS.Oddity > 0
    end,
}

SMODS.Tag {
    name = "Oddity Tag",
    key = "oddity",
    set = "Tag",
    config = {type = "new_blind_choice"},
    pos = {x = 0, y = 0},
    atlas = "modicon",
    loc_txt = {
        name = "Oddity Tag",
        text = {
            "Gives a free",
            "{C:oddity}Mega Oddity Pack",
        }
    },
    discovered = false,
    apply = function(self, tag, context)
        --print("yo")
        if context.type == 'new_blind_choice' then
            local lock = tag.ID
            G.CONTROLLER.locks[lock] = true
            tag:yep('+', G.C.SECONDARY_SET.Oddity, function() 
                local key = 'p_amm_oddity_mega_'..(math.random(1,2))
                local card = Card(G.play.T.x + G.play.T.w/2 - G.CARD_W*1.27/2,
                G.play.T.y + G.play.T.h/2-G.CARD_H*1.27/2, G.CARD_W*1.27, G.CARD_H*1.27, G.P_CARDS.empty, G.P_CENTERS[key], {bypass_discovery_center = true, bypass_discovery_ui = true})
                card.cost = 0
                card.from_tag = true
                G.FUNCS.use_card({config = {ref_table = card}})
                card:start_materialize()
                G.CONTROLLER.locks[lock] = nil
                return true
            end)
            tag.triggered = true
            return true
        end
    end,
    loc_vars = function() return {vars = {}} end,
    in_pool = function()
        return #G.P_CENTER_POOLS.Oddity > 0
    end,
}

SMODS.Tag {
    name = "Heirloom Tag",
    key = "heirloom",
    set = "Tag",
    config = {type = "immediate", spawn_oddities = 1},
    pos = {x = 1, y = 0},
    atlas = "modicon",
    loc_txt = {
        name = "Heirloom Tag",
        text = {
            "Create a",
            "{C:legendary,E:1}Legendary{} {C:oddity}Oddity{}",
            "{C:inactive}(Must have room)"
        }
    },
    discovered = false,
    apply = function(self, tag, context)
        --print("yo")
        if context.type == 'immediate' then
            local lock = tag.ID
            G.CONTROLLER.locks[lock] = true
            tag:yep('+', G.C.PURPLE,function() 
                for i = 1, tag.config.spawn_oddities do
                    if G.consumeables and #G.consumeables.cards < G.consumeables.config.card_limit then
                        local card = create_card('Oddity', G.consumeables, true, nil, nil, nil, nil, 'heirloomtag')
                        card:add_to_deck()
                        G.consumeables:emplace(card)
                    end
                end
                G.CONTROLLER.locks[lock] = nil
                return true
            end)
            tag.triggered = true
            return true
        end
    end,
    loc_vars = function() return {vars = {}} end,
    in_pool = function()
        return #G.P_CENTER_POOLS.Oddity > 0
    end,
}

return OddityAPI