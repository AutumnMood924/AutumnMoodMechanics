AMM = {}
AMM.mod = SMODS.current_mod

AMM.mod.optional_features = function()
	return {
        --[[
		amm_suit_levels = false,
        amm_graveyard = false,
		amm_plusmult = false,
		--]]
	}
end

-- todo
AMM.config = {
	suit_levels = {
		chips = 5,
		mult = 1,
		asc = 1,
	},
}

-- actual config
AMM.mod.config_tab = function()
    return {n = G.UIT.ROOT, config = {align = "m", r = 0.1, padding = 0.1, colour = G.C.BLACK, minw = 8, minh = 6}, nodes = {
        {n = G.UIT.R, config = {align = "cl", padding = 0, minh = 0.1}, nodes = {}},

        {n = G.UIT.R, config = {align = "cl", padding = 0}, nodes = {
            {n = G.UIT.C, config = { align = "cl", padding = 0.05 }, nodes = {
                create_toggle{ col = true, label = "", scale = 1, w = 0, shadow = true, ref_table = AMM.mod.config, ref_value = "joyousspringify" },
            }},
            {n = G.UIT.C, config = { align = "c", padding = 0 }, nodes = {
                { n = G.UIT.T, config = { text = "JoyousSpringify many Jokers", scale = 0.45, colour = G.C.UI.TEXT_LIGHT }},
            }},
        }},
        {n = G.UIT.R, config = {align = "cl", padding = 0}, nodes = {
            {n = G.UIT.C, config = { align = "cl", padding = 0.05 }, nodes = {
                create_toggle{ col = true, label = "", scale = 1, w = 0, shadow = true, ref_table = AMM.mod.config, ref_value = "fieldspells" },
            }},
            {n = G.UIT.C, config = { align = "c", padding = 0 }, nodes = {
                { n = G.UIT.T, config = { text = "Also Field Spells? ", scale = 0.45, colour = G.C.UI.TEXT_LIGHT }},
                { n = G.UIT.T, config = { text = "(They will not go in Joker Slots)", scale = 0.30, colour = G.C.JOKER_GREY }},
            }},
        }},
		--[[
        {n = G.UIT.R, config = {align = "cl", padding = 0}, nodes = {
            {n = G.UIT.C, config = { align = "cl", padding = 0.05 }, nodes = {
                create_toggle{ col = true, label = "", scale = 1, w = 0, shadow = true, ref_table = AMM.mod.config, ref_value = "forceunlocknone" },
            }},
            {n = G.UIT.C, config = { align = "c", padding = 0 }, nodes = {
                { n = G.UIT.T, config = { text = "Force Unlock 'None' poker hand (Cryptid)", scale = 0.45, colour = G.C.UI.TEXT_LIGHT }},
            }},
        }},
		--]]
        {n = G.UIT.R, config = {align = "cl", padding = 0}, nodes = {
            {n = G.UIT.C, config = { align = "cl", padding = 0.05 }, nodes = {
                create_toggle{ col = true, label = "", scale = 1, w = 0, shadow = true, ref_table = AMM.mod.config, ref_value = "nonocollection" },
            }},
            {n = G.UIT.C, config = { align = "c", padding = 0 }, nodes = {
                { n = G.UIT.T, config = { text = "No 'no_collection' - all cards visible", scale = 0.45, colour = G.C.UI.TEXT_LIGHT }},
            }},
        }},
    }}
end

SMODS.Atlas {
	key = "modicon",
	path = "OddityTag.png",
	px = 34,
	py = 34,
}

AMM.api = {}
--AMM.api.group = NFS.load(AMM.mod.path.."api/Group.lua")()
AMM.api.stamp = NFS.load(AMM.mod.path.."api/Stamps.lua")()
AMM.api.oddity = NFS.load(AMM.mod.path.."api/Oddity.lua")()
AMM.api.aspect = NFS.load(AMM.mod.path.."api/Aspect.lua")()
AMM.api.bottle = NFS.load(AMM.mod.path.."api/Bottle.lua")()
AMM.api.graveyard = NFS.load(AMM.mod.path.."api/Graveyard.lua")()
AMM.api.petting = NFS.load(AMM.mod.path.."api/Petting.lua")()
AMM.api.plusmult = NFS.load(AMM.mod.path.."api/PlusMult.lua")()
AMM.api.cardqualities = NFS.load(AMM.mod.path.."api/CardQualities.lua")()


local alias__Game_init_game_object = Game.init_game_object
function Game:init_game_object()
    local ret = alias__Game_init_game_object(self)
    if #G.P_CENTER_POOLS.Oddity == 0 then
		ret.oddity_rate = 0
	end
    return ret
end

--[[
local alias__Game_update = Game.update
function Game:update(dt)
	local ret = alias__Game_update(self, dt)
	G.PROFILES[G.SETTINGS.profile].cry_none = G.PROFILES[G.SETTINGS.profile].cry_none or AMM.mod.config.forceunlocknone
	return ret
end
--]]

-- a helper function to destroy "random" jokers,
-- but prioritize those that are debuffed,
-- perishable, or rental before those with no
-- such downside effects
-- also properly ignores eternals
function AMM.destroy_random_jokers(cards, amt)
	local destroyable = {}
	local priority = {}
	for k, v in ipairs(cards) do
		if not v.ability.eternal then
			if v.ability.rental or v.ability.perishable or v.ability.perma_debuff then
				priority[#priority+1] = v
			else
				destroyable[#destroyable+1] = v
			end
		end
	end
	pseudoshuffle(destroyable, pseudoseed("AMM_drj"))
	pseudoshuffle(priority, pseudoseed("AMM_drj"))
	for m, n in ipairs(priority) do
		destroyable[#destroyable+1] = n
	end
	local size = math.max(#destroyable - amt, 0) + 1
	if #destroyable == 0 then return end
	for i = #destroyable, size, -1 do
		G.E_MANAGER:add_event(Event({
			trigger = 'before',
			delay = (i == size and 0.60) or 0.15,
			func = function() destroyable[i]:start_dissolve(nil); return true end
		}))
	end
end

function AMM.mod_blind(val, silent, percent_val, allow_end)
	if not G.GAME.blind then return end
	if percent_val then
		G.GAME.blind.chips = math.floor(G.GAME.blind.chips * val)
	else
		G.GAME.blind.chips = math.floor(G.GAME.blind.chips + val)
	end
	G.GAME.blind.chip_text = number_format(G.GAME.blind.chips)

	local chips_UI = G.hand_text_area.blind_chips
	G.FUNCS.blind_chip_UI_scale(G.hand_text_area.blind_chips)
	G.HUD_blind:recalculate() 
	chips_UI:juice_up()
	if not silent then play_sound('chips2') end
    if allow_end and G.GAME.chips - G.GAME.blind.chips >= 0 then
		G.STATE = G.STATES.NEW_ROUND
		G.STATE_COMPLETE = false
		--end_round()
	end
end

-- based on level_up_hand, but levels up a suit instead
function AMM.level_up_suit(card, suit, instant, amount)
    amount = amount or 1
	if not instant then
		update_hand_text({sound = 'button', volume = 0.7, pitch = 0.8, delay = 0.3}, {handname=localize(suit, 'suits_plural'),chips = G.GAME.amm_data.suit_levels[suit].chips, mult = G.GAME.amm_data.suit_levels[suit].mult, level=G.GAME.amm_data.suit_levels[suit].level})
	end
    G.GAME.amm_data.suit_levels[suit].level = math.max(0, G.GAME.amm_data.suit_levels[suit].level + amount)
	if suit == "gb_Eyes" then
		G.GAME.amm_data.suit_levels[suit].mult = math.max(AMM.config.suit_levels.chips*(G.GAME.amm_data.suit_levels[suit].level - 1), 0)
		G.GAME.amm_data.suit_levels[suit].chips = math.max(AMM.config.suit_levels.mult*(G.GAME.amm_data.suit_levels[suit].level - 1), 0)
	else
		G.GAME.amm_data.suit_levels[suit].mult = math.max(AMM.config.suit_levels.mult*(G.GAME.amm_data.suit_levels[suit].level - 1), 0)
		G.GAME.amm_data.suit_levels[suit].chips = math.max(AMM.config.suit_levels.chips*(G.GAME.amm_data.suit_levels[suit].level - 1), 0)
	end
    if not instant then 
        G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.2, func = function()
            play_sound('tarot1')
            if card then card:juice_up(0.8, 0.5) end
            G.TAROT_INTERRUPT_PULSE = true
            return true end }))
        update_hand_text({delay = 0}, {mult = G.GAME.amm_data.suit_levels[suit].mult, StatusText = true})
        G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.9, func = function()
            play_sound('tarot1')
            if card then card:juice_up(0.8, 0.5) end
            return true end }))
        update_hand_text({delay = 0}, {chips = G.GAME.amm_data.suit_levels[suit].chips, StatusText = true})
        G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.9, func = function()
            play_sound('tarot1')
            if card then card:juice_up(0.8, 0.5) end
            G.TAROT_INTERRUPT_PULSE = nil
            return true end }))
        update_hand_text({sound = 'button', volume = 0.7, pitch = 0.9, delay = 0}, {level=G.GAME.amm_data.suit_levels[suit].level})
        delay(1.3)
    end
	update_hand_text({sound = 'button', volume = 0.7, pitch = 1.1, delay = 0}, {mult = 0, chips = 0, handname = '', level = ''})
end

-- ascending a suit ONLY has any function if Entropy is installed!!!!
-- also shoutouts to Ruby for like most of the animation stuff here
function AMM.ascend_suit(card, suit, instant, amount)
    amount = amount or 1
	if not instant then
		update_hand_text({sound = 'button', volume = 0.7, pitch = 0.8, delay = 0.3}, {handname=localize(suit, 'suits_plural'),chips = G.GAME.amm_data.suit_levels[suit].chips, mult = G.GAME.amm_data.suit_levels[suit].mult, level=G.GAME.amm_data.suit_levels[suit].level})
	end
    G.GAME.amm_data.suit_levels[suit].asc = math.max(0, G.GAME.amm_data.suit_levels[suit].asc + amount)
    if not instant then 
		G.E_MANAGER:add_event(Event({
			trigger = "after",
			delay = 0.2,
			func = function()
				local c = copy_table(G.C.UI_CHIPS)
				local m = copy_table(G.C.UI_MULT)
				play_sound("tarot1")
				ease_colour(G.C.UI_CHIPS, HEX("ffb400"), 0.1)
				ease_colour(G.C.UI_MULT, HEX("ffb400"), 0.1)
				--Cryptid.pulse_flame(0.01, sunlevel)
				if card.juice_up then card:juice_up(0.8, 0.5) end --?????
				G.E_MANAGER:add_event(Event({
					trigger = "after",
					blockable = false,
					blocking = false,
					delay = 1.2,
					func = function()
						ease_colour(G.C.UI_CHIPS, c, 1)
						ease_colour(G.C.UI_MULT, m, 1)
						return true
						end,
				}))
				return true
				end,
		}))
		update_hand_text({ sound = "button", volume = 0.7, pitch = 0.9, delay = 0 }, { level = (amount > 0 and "+" or "")..amount })
		delay(1.6)
		delay(2.6)
    end
	update_hand_text({sound = 'button', volume = 0.7, pitch = 1.1, delay = 0}, {mult = 0, chips = 0, handname = '', level = ''})
end

-- function to combine cards
-- todo: stickers
-- combined cards are REMOVED FROM GAME
-- returns the created card - it will be put into cardarea area if supplied,
-- or into G.hand if available, or into G.deck
function AMM.combine_cards(cards, pseed, area)
	local suits = {} local ranks = {}
	local enhancements = {} local seals = {} local editions = {}
	local aspects = {} local bottles = {}
	
	local paperclips = {}
	local hexes = {} local curses = {}
	local letters = {}
	local modes = {}
	if next(SMODS.find_mod("aikoyorisshenanigans")) then
		modes.akyrs = true
	end
	if next(SMODS.find_mod("paperback")) then
		modes.paperback = true
	end
	if next(SMODS.find_mod("GrabBag")) then
		modes.gb = true
	end
	if next(SMODS.find_mod("ortalab")) then
		modes.ortalab = true
	end
	local perma = {
		perma_bonus = 0,
		perma_mult = 0,
		perma_x_chips = 0,
		perma_x_mult = 0,
		perma_h_chips = 0,
		perma_h_mult = 0,
		perma_h_x_chips = 0,
		perma_h_x_mult = 0,
		perma_u_chips = 0,
		perma_u_mult = 0,
		perma_u_x_chips = 0,
		perma_u_x_mult = 0,
		perma_p_dollars = 0,
		perma_h_dollars = 0,
		akyrs_perma_score = 0,
		akyrs_perma_h_score = 0,
		perma_repetitions = 0,
		perma_e_chips = 0,
		perma_e_mult = 0,
		perma_h_e_chips = 0,
		perma_h_e_mult = 0,
		perma_balance = 0,
	}
	for k,v in ipairs(cards) do
		suits[#suits+1] = v.base.suit
		ranks[#ranks+1] = v.base.value
		if v.config.center.set == "Enhanced" then
			enhancements[#enhancements+1] = v.config.center.key
		end
		seals[#seals+1] = v:get_seal(true)
		editions[#editions+1] = v.edition
		aspects[#aspects+1] = v:get_aspect(true)
		bottles[#bottles+1] = v.bottle
		if modes.akyrs then letters[#letters+1] = v.ability.aikoyori_letters_stickers end
		if modes.paperback then
			local pain = false
			paperclips[#paperclips+1], pain = PB_UTIL.has_paperclip(v)
			if pain then
				paperclips[#paperclips] = string.sub(paperclips[#paperclips], 1+(#pain.mod.prefix+1), #paperclips[#paperclips] - 5)
			end
		end
		if modes.gb then
			local pain = false
			hexes[#hexes+1], pain = GB.get_hex(v)
			if pain then
				hexes[#hexes] = string.sub(hexes[#hexes], 1+(#pain.mod.prefix+1), #hexes[#hexes] - 4)
			end
		end
		if modes.ortalab and v.ability.curse then
			curses[#curses+1] = v.ability.curse.key
		end
		for key,value in pairs(perma) do
			if v.base.suit == "gb_Eyes" then
				if key == "perma_mult" then
					perma[key] = perma[key] + v.base.nominal
				end
			else
				if key == "perma_bonus" then
					perma[key] = perma[key] + v.base.nominal
				end
			end
			if v.ability[key] then
				perma[key] = perma[key] + v.ability[key]
			end
		end
	end
	-- generate the card
	
	local new_card = SMODS.create_card{
		set = "Playing Card",
		area = area or (#G.hand.cards > 0 and G.hand) or G.deck,
		suit = pseudorandom_element(suits, pseed),
		rank = pseudorandom_element(ranks, pseed),
		enhancement = pseudorandom_element(enhancements, pseed) or "c_base",
		seal = pseudorandom_element(seals, pseed),
		edition = pseudorandom_element(editions, pseed),
	}
	new_card:set_aspect(pseudorandom_element(aspects, pseed))
	new_card.bottle = pseudorandom_element(bottles, pseed)
	if modes.akyrs then
		if #suits == 0 then
			new_card.ability.akyrs_special_card_type = "rank"
		elseif #ranks == 0 then
			new_card.ability.akyrs_special_card_type = "suit"
		end
		new_card.ability.aikoyori_letters_stickers = pseudorandom_element(letters, pseed)
	end
	if modes.paperback then
		if #paperclips > 0 then
			PB_UTIL.set_paperclip(new_card, pseudorandom_element(paperclips, pseed))
		end
	end
	if modes.gb then
		if #hexes > 0 then
			GB.set_hex(new_card, pseudorandom_element(hexes, pseed))
		end
	end
	if modes.ortalab then
		if #curses > 0 then
			new_card:set_curse(pseudorandom_element(curses, pseed), true, true)
		end
	end
	
	new_card:set_sprites(new_card.config.center, new_card.config.card)
	
	for k,v in pairs(perma) do
		new_card.ability[k] = v
		if k == "perma_bonus" then new_card.ability[k] = new_card.ability[k] - new_card.base.nominal end
	end
	
	-- begone
	for i=#cards,1,-1 do
		cards[i]:remove_from_game(nil, true)
	end
	
	if area then
		new_card:add_to_deck()
		G.deck.config.card_limit = G.deck.config.card_limit + 1
		area:emplace(new_card)
		table.insert(G.playing_cards, new_card)
		playing_card_joker_effects({true})
	end
	
	return new_card
end

function amm_get_badge_text_colour(key)
    G.BADGE_TEXT_COL = G.BADGE_TEXT_COL or {
    }
    for _, v in ipairs(G.P_CENTER_POOLS.Edition) do
    	G.BADGE_TEXT_COL[v.key:sub(3)] = v.badge_text_colour
    end
    for k, v in pairs(SMODS.Seals) do
        G.BADGE_TEXT_COL[k:lower()..'_seal'] = v.badge_text_colour
    end
    for k, v in pairs(SMODS.Stickers) do
        G.BADGE_TEXT_COL[k] = v.badge_text_colour
    end
    for k, v in pairs(AMM.Aspects) do
    	G.BADGE_TEXT_COL[k:lower()..'_aspect'] = v.badge_text_colour
    end
    for k, v in pairs(SMODS.Stamps) do
    	G.BADGE_TEXT_COL[k:lower()..'_stamp'] = v.badge_text_colour
    end
    return G.BADGE_TEXT_COL[key] or {1, 1, 1, 1}
end

-- Counts how many cards of each suit are in the deck
-- Ignores wild cards and other effects
local function count_deck_suits()
  local suit_tallies = {}
  for k, v in ipairs(G.playing_cards) do
    if v.ability.name ~= 'Stone Card' then 
      suit_tallies[v.base.suit] = (suit_tallies[v.base.suit] or 0) + 1
    end
  end
  return suit_tallies
end

-- unscored perma bonuses???

function Card:get_chip_u_mult()
    if self.debuff then return 0 end
    local ret = (self.ability.u_mult or 0) + ((not self.ability.extra_enhancement and self.ability.perma_u_mult) or 0)
    -- TARGET: get_chip_u_mult
    return ret
end

function Card:get_chip_u_x_mult()
    if self.debuff then return 0 end
    local ret = SMODS.multiplicative_stacking(self.ability.u_x_mult or 1, (not self.ability.extra_enhancement and self.ability.perma_u_x_mult) or 0)
    -- TARGET: get_chip_u_x_mult
    return ret
end

function Card:get_chip_u_bonus()
    if self.debuff then return 0 end
    local ret = (self.ability.u_chips or 0) + ((not self.ability.extra_enhancement and self.ability.perma_u_chips) or 0)
    -- TARGET: get_chip_u_bonus
    return ret
end

function Card:get_chip_u_x_bonus()
    if self.debuff then return 0 end
    local ret = SMODS.multiplicative_stacking(self.ability.u_x_chips or 1, (not self.ability.extra_enhancement and self.ability.perma_u_x_chips) or 0)
    -- TARGET: get_chip_u_x_bonus
    return ret
end

local alias__SMODS_localize_perma_bonuses = SMODS.localize_perma_bonuses
function SMODS.localize_perma_bonuses(specific_vars, desc_nodes)
	local ret = alias__SMODS_localize_perma_bonuses(specific_vars, desc_nodes)
	
    if specific_vars and specific_vars.bonus_u_chips then
        localize{type = 'other', key = 'card_extra_u_chips', nodes = desc_nodes, vars = {SMODS.signed(specific_vars.bonus_u_chips)}}
    end
    if specific_vars and specific_vars.bonus_u_mult then
        localize{type = 'other', key = 'card_extra_u_mult', nodes = desc_nodes, vars = {SMODS.signed(specific_vars.bonus_u_mult)}}
    end
    if specific_vars and specific_vars.bonus_u_x_chips then
        localize{type = 'other', key = 'card_u_x_chips', nodes = desc_nodes, vars = {specific_vars.bonus_u_x_chips}}
    end
    if specific_vars and specific_vars.bonus_u_x_mult then
        localize{type = 'other', key = 'card_u_x_mult', nodes = desc_nodes, vars = {specific_vars.bonus_u_x_mult}}
    end
	
	return ret
end

-- suit levels

local alias__Card_get_chip_bonus = Card.get_chip_bonus;
function Card:get_chip_bonus()
    if self.debuff then return 0 end
    local ret = alias__Card_get_chip_bonus(self)
	if G.GAME.amm_data.suit_levels[self.base.suit] and not SMODS.has_no_suit(self) then
		ret = ret + G.GAME.amm_data.suit_levels[self.base.suit].chips
	end
	return ret
end

local alias__Card_get_chip_mult = Card.get_chip_mult;
function Card:get_chip_mult()
    if self.debuff then return 0 end
    local ret = alias__Card_get_chip_mult(self)
	if G.GAME.amm_data.suit_levels[self.base.suit] and not SMODS.has_no_suit(self) then
		ret = ret + G.GAME.amm_data.suit_levels[self.base.suit].mult
	end
	return ret
end

SMODS.current_mod.custom_collection_tabs = function()
	local ret = {}
	if G.P_CENTER_POOLS and G.P_CENTER_POOLS.Stamp then
		if #G.P_CENTER_POOLS.Stamp > 0 then ret[#ret+1] = UIBox_button {
			button = 'your_collection_stamps', label = {localize("b_stamps")}, minw = 5, id = 'your_collection_stamps'
		} end
	end
	if G.P_CENTER_POOLS and G.P_CENTER_POOLS.Aspect then
		if #G.P_CENTER_POOLS.Aspect > 0 then ret[#ret+1] = UIBox_button {
			button = 'your_collection_aspects', label = {localize("b_aspects")}, minw = 5, id = 'your_collection_aspects'
		} end
	end
	return ret
end

-- suit level stuff
local alias__Game_init_game_object = Game.init_game_object;
function Game:init_game_object()
	local ret = alias__Game_init_game_object(self)
	for _,suit in ipairs(SMODS.Suit.obj_buffer) do
		ret.amm_data.suit_levels[suit] = {
			level = 1,
			mult = 0,
			chips = 0,
			asc = 0, --ascension power. only works with Entropy
		}
	end
	return ret
end

------------------------------------------------------------------------
--- SUIT LEVEL PAGE

function create_UIBox_current_suits(simple)
	G.current_suits = {}
	local index = 0
	
	local counts = count_deck_suits()
	
	for i=#SMODS.Suit.obj_buffer,1,-1 do
		local v = SMODS.Suit.obj_buffer[i]
		local ui_element = create_UIBox_current_suit_row(v, not SMODS.optional_features.amm_suit_levels, counts[v])
		G.current_suits[index + 1] = ui_element
		if ui_element then
			index = index + 1
		end
		if index >= 10 then
			break
		end
	end

	local visible_suits = {}
	for i=#SMODS.Suit.obj_buffer,1,-1 do
		local v = SMODS.Suit.obj_buffer[i]
		if (counts[v] and counts[v] > 0) or (G.GAME.amm_data.suit_levels[suit] and G.GAME.amm_data.suit_levels[suit].level > 1) or (v == "Spades" or v == "Hearts" or v == "Clubs" or v == "Diamonds") then
			table.insert(visible_suits, v)
		end
	end

	local suit_options = {}
	for i = 1, math.ceil(#visible_suits / 10) do
		table.insert(suit_options,
			localize('k_page') .. ' ' .. tostring(i) .. '/' .. tostring(math.ceil(#visible_suits / 10)))
	end

	local object = {
		n = G.UIT.ROOT,
		config = { align = "cm", colour = G.C.CLEAR },
		nodes = {
			{
				n = G.UIT.R,
				config = { align = "cm", padding = 0.04 },
				nodes = G.current_suits
			},
			{
				n = G.UIT.R,
				config = { align = "cm", padding = 0 },
				nodes = {
					create_option_cycle({
						options = suit_options,
						w = 4.5,
						cycle_shoulders = true,
						opt_callback = 'amm_your_suits_page',
						focus_args = { snap_to = true, nav = 'wide' },
						current_option = 1,
						colour = G.C.RED,
						no_pips = true
					})
				}
			}
		}
	}

	local t = {
		n = G.UIT.ROOT,
		config = { align = "cm", minw = 3, padding = 0.1, r = 0.1, colour = G.C.CLEAR },
		nodes = {
			{
				n = G.UIT.O,
				config = {
					id = 'hand_list',
					object = UIBox {
						definition = object,
						config = { offset = { x = 0, y = 0 }, align = 'cm' }
					}
				}
			}
		}
	}
	return t
end

G.FUNCS.current_suits = function(e, simple)
  G.SETTINGS.paused = true
  G.FUNCS.overlay_menu{
    definition = create_UIBox_current_suits(simple),
  }
end

G.FUNCS.amm_your_suits_page = function(args)
	if not args or not args.cycle_config then return end
	G.current_suits = {}
	
	local counts = count_deck_suits()

	local index = 0
	for i=#SMODS.Suit.obj_buffer,1,-1 do
		local v = SMODS.Suit.obj_buffer[i]
		local ui_element = create_UIBox_current_suit_row(v, not SMODS.optional_features.amm_suit_levels, counts[v])
		if index >= (0 + 10 * (args.cycle_config.current_option - 1)) and index < 10 * args.cycle_config.current_option then
			G.current_suits[index - (10 * (args.cycle_config.current_option - 1)) + 1] = ui_element
		end

		if ui_element then
			index = index + 1
		end

		if index >= 10 * args.cycle_config.current_option then
			break
		end
	end

	local visible_suits = {}
	for i=#SMODS.Suit.obj_buffer,1,-1 do
		local v = SMODS.Suit.obj_buffer[i]
		if (counts[v] and counts[v] > 0) or (G.GAME.amm_data.suit_levels[suit] and G.GAME.amm_data.suit_levels[suit].level > 1) or (v == "Spades" or v == "Hearts" or v == "Clubs" or v == "Diamonds") then
			table.insert(visible_suits, v)
		end
	end

	local suit_options = {}
	for i = 1, math.ceil(#visible_suits / 10) do
		table.insert(suit_options,
			localize('k_page') .. ' ' .. tostring(i) .. '/' .. tostring(math.ceil(#visible_suits / 10)))
	end

	local object = {
		n = G.UIT.ROOT,
		config = { align = "cm", colour = G.C.CLEAR },
		nodes = {
			{
				n = G.UIT.R,
				config = { align = "cm", padding = 0.04 },
				nodes = G.current_suits
			},
			{
				n = G.UIT.R,
				config = { align = "cm", padding = 0 },
				nodes = {
					create_option_cycle({
						options = suit_options,
						w = 4.5,
						cycle_shoulders = true,
						opt_callback =
						'amm_your_suits_page',
						focus_args = { snap_to = true, nav = 'wide' },
						current_option = args.cycle_config.current_option,
						colour = G
							.C.RED,
						no_pips = true
					})
				}
			}
		}
	}

	-- dunno what any of this does but it doesn't break if i don't touch it so
	local hand_list = G.OVERLAY_MENU:get_UIE_by_ID('hand_list')
	if hand_list then
		if hand_list.config.object then
			hand_list.config.object:remove()
		end
		hand_list.config.object = UIBox {
			definition = object,
			config = { offset = { x = 0, y = 0 }, align = 'cm', parent = hand_list }
		}
	end
end

function create_UIBox_current_suit_row(suit, simple, count)
	count = count or 0
	
	local level_box = G.GAME.amm_data.suit_levels[suit].asc > 0 and 
		{n=G.UIT.C, config={align = "cm", padding = 0.05, colour = G.C.BLACK,r = 0.1}, nodes={
		{n=G.UIT.C, config={align = "cm", padding = 0.01, r = 0.1, colour = G.C.HAND_LEVELS[math.min(7, G.GAME.amm_data.suit_levels[suit].level)], minw = 1.1}, nodes={
			  {n=G.UIT.T, config={text = localize('k_level_prefix')..G.GAME.amm_data.suit_levels[suit].level, scale = 0.45, colour = G.C.UI.TEXT_DARK}},
		}},
				{n=G.UIT.T, config={text = "+", scale = 0.45, colour = G.C.GOLD}},
				{n=G.UIT.C, config={align = "cm", padding = 0.01, r = 0.1, colour = G.C.GOLD, minw = 0.7}, nodes={
				  {n=G.UIT.T, config={text = ""..G.GAME.amm_data.suit_levels[suit].asc, scale = 0.45, colour = G.C.UI.TEXT_LIGHT}}
				}},
	}}
	or {n=G.UIT.C, config={align = "cm", padding = 0.01, r = 0.1, colour = G.C.HAND_LEVELS[math.min(7, G.GAME.amm_data.suit_levels[suit].level)], minw = 1.5, outline = 0.8, outline_colour = lighten(G.C.SUITS[suit], 0.4)}, nodes={
	  {n=G.UIT.T, config={text = localize('k_level_prefix')..G.GAME.amm_data.suit_levels[suit].level, scale = G.GAME.amm_data.suit_levels[suit].asc > 0 and 0.45 or 0.5, colour = G.C.UI.TEXT_DARK}},
	}}
	
  return (count > 0 or G.GAME.amm_data.suit_levels[suit].level > 1) and
  (not simple and
    {n=G.UIT.R, config={align = "cm", padding = 0.05, r = 0.1, colour = darken(G.C.SUITS[suit], 0.1), emboss = 0.05, hover = true, force_focus = true}, nodes={
      {n=G.UIT.C, config={align = "cl", padding = 0, minw = 5}, nodes={
        level_box,
        {n=G.UIT.C, config={align = "cm", minw = G.GAME.amm_data.suit_levels[suit].asc > 0 and 3.8 or 4.5, maxw = G.GAME.amm_data.suit_levels[suit].asc > 0 and 3.8 or 4.5}, nodes={
          {n=G.UIT.T, config={text = ' '..localize(suit,'suits_plural'), scale = 0.45, colour = lighten(G.C.SUITS[suit], 0.8), shadow = true}}
        }}
      }},
      {n=G.UIT.C, config={align = "cm", padding = 0.05, colour = darken(G.C.SUITS[suit], 0.6),r = 0.1}, nodes={
        {n=G.UIT.C, config={align = "cr", padding = 0.01, r = 0.1, colour = G.C.CHIPS, minw = 1.1}, nodes={
          {n=G.UIT.T, config={text = G.GAME.amm_data.suit_levels[suit].chips, scale = 0.45, colour = G.C.UI.TEXT_LIGHT}},
          {n=G.UIT.B, config={w = 0.08, h = 0.01}}
        }},
        {n=G.UIT.T, config={text = "X", scale = 0.45, colour = G.C.SUITS[suit]}},
        {n=G.UIT.C, config={align = "cl", padding = 0.01, r = 0.1, colour = G.C.MULT, minw = 1.1}, nodes={
          {n=G.UIT.B, config={w = 0.08,h = 0.01}},
          {n=G.UIT.T, config={text = G.GAME.amm_data.suit_levels[suit].mult, scale = 0.45, colour = G.C.UI.TEXT_LIGHT}}
        }}
      }},
      {n=G.UIT.C, config={align = "cm"}, nodes={
          {n=G.UIT.T, config={text = '  #', scale = 0.45, colour = lighten(G.C.SUITS[suit],0.6), shadow = true}}
        }},
      {n=G.UIT.C, config={align = "cm", padding = 0.05, colour = darken(G.C.SUITS[suit],0.5),r = 0.1, minw = 0.9}, nodes={
        {n=G.UIT.T, config={text = ""..count, scale = 0.45, colour = lighten(G.C.SUITS[suit],0.4), shadow = true}},
      }}
    }}
  or {n=G.UIT.R, config={align = "cm", padding = 0.05, r = 0.1, colour = darken(G.C.SUITS[suit], 0.1), force_focus = true, emboss = 0.05, hover = true, focus_args = {snap_to = (simple and suit == SMODS.Suit.obj_buffer[#SMODS.Suit.obj_buffer])}}, nodes={
    {n=G.UIT.C, config={align = "cm", padding = 0, minw = 5}, nodes={
        {n=G.UIT.T, config={text = localize(suit,'suits_plural'), scale = 0.5, colour = lighten(G.C.SUITS[suit], 0.4), shadow = true}}
    }}
  }})
  or nil
end

-- literally just set localization ugh
function SMODS.current_mod.process_loc_text()
	G.localization.descriptions.Other["card_amm_suit_bonus"] = {
		text = {
			"{s:0.8,C:inactive}({s:0.8,V:2}#4# {s:0.8,V:1}lvl.#1#{s:0.8,C:inactive}) {s:0.8,C:white,X:chips}+#2#{s:0.4} {s:0.8}X{s:0.4} {C:white,X:mult,s:0.8}+#3#{s:0.8}",
		}
	}
	G.localization.descriptions.Other["card_extra_u_chips"] = {
		text = {
			"{C:chips}#1#{} chips when unscoring",
		}
	}
	G.localization.descriptions.Other["card_extra_u_mult"] = {
		text = {
			"{C:mult}#1#{} Mult when unscoring",
		}
	}
	G.localization.descriptions.Other["card_u_x_chips"] = {
		text = {
			"{C:white,X:chips}X#1#{} chips when unscoring",
		}
	}
	G.localization.descriptions.Other["card_u_x_mult"] = {
		text = {
			"{C:white,X:mult}X#1#{} Mult when unscoring",
		}
	}
	G.localization.misc.v_dictionary["a_blind"] = "Blind +#1#"
	G.localization.misc.v_dictionary["a_blind_percent"] = "Blind +#1#%"
	G.localization.misc.v_dictionary["a_blind_minus"] = "Blind -#1#"
	G.localization.misc.v_dictionary["a_blind_minus_percent"] = "Blind -#1#%"
	G.localization.misc.v_dictionary["a_amm_plusmult"] = "+#1# +Mult"
	G.localization.misc.v_dictionary["a_amm_plusmult_minus"] = "-#1# +Mult"
	G.localization.misc.v_dictionary["a_amm_xplusmult"] = "X#1# +Mult"
	G.localization.misc.v_dictionary["a_amm_xplusmult_minus"] = "X#1# +Mult"
	G.localization.misc.v_dictionary["a_plus_oddity"] = "+#1# Oddity"
	G.localization.misc.dictionary["b_suits"] = "Suits"
	
	-- card qualities
	G.localization.misc.dictionary["cq_face"] = "face"
	G.localization.misc.dictionary["Cq_face"] = "Face"
	G.localization.misc.dictionary["cq_nonface"] = "non-face"
	G.localization.misc.dictionary["Cq_nonface"] = "Non-Face"
	G.localization.misc.dictionary["cq_numbered"] = "numbered"
	G.localization.misc.dictionary["Cq_numbered"] = "Numbered"
	G.localization.misc.dictionary["cq_odd"] = "odd"
	G.localization.misc.dictionary["Cq_odd"] = "Odd"
	G.localization.misc.dictionary["cq_even"] = "even"
	G.localization.misc.dictionary["Cq_even"] = "Even"
	G.localization.misc.dictionary["cq_prime"] = "prime"
	G.localization.misc.dictionary["Cq_prime"] = "Prime"
	G.localization.misc.dictionary["cq_suitless"] = "suitless"
	G.localization.misc.dictionary["Cq_suitless"] = "Suitless"
	G.localization.misc.dictionary["cq_rankless"] = "rankless"
	G.localization.misc.dictionary["Cq_rankless"] = "Rankless"
	G.localization.misc.dictionary["cq_unenhanced"] = "unenhanced"
	G.localization.misc.dictionary["Cq_unenhanced"] = "Unenhanced"
	G.localization.misc.dictionary["cq_enhanced"] = "enhanced"
	G.localization.misc.dictionary["Cq_enhanced"] = "Enhanced"
	G.localization.misc.dictionary["cq_rock"] = "rock-enhanced"
	G.localization.misc.dictionary["Cq_rock"] = "Rock-Enhanced"
	G.localization.misc.dictionary["cq_metal"] = "metal-enhanced"
	G.localization.misc.dictionary["Cq_metal"] = "Metal-Enhanced"
	G.localization.misc.dictionary["cq_materialenh"] = "material-enhanced"
	G.localization.misc.dictionary["Cq_materialenh"] = "Material-Enhanced"
	G.localization.misc.dictionary["cq_nonmaterialenh"] = "nonmaterial-enhanced"
	G.localization.misc.dictionary["Cq_nonmaterialenh"] = "Nonmaterial-Enhanced"
	G.localization.misc.dictionary["cq_unsealed"] = "unsealed"
	G.localization.misc.dictionary["Cq_unsealed"] = "Unsealed"
	G.localization.misc.dictionary["cq_sealed"] = "sealed"
	G.localization.misc.dictionary["Cq_sealed"] = "Sealed"
	G.localization.misc.dictionary["cq_baseedition"] = "base edition"
	G.localization.misc.dictionary["Cq_baseedition"] = "Base Edition"
	G.localization.misc.dictionary["cq_editioned"] = "editioned"
	G.localization.misc.dictionary["Cq_editioned"] = "Editioned"
	G.localization.misc.dictionary["cq_hexed"] = "hexed"
	G.localization.misc.dictionary["Cq_hexed"] = "Hexed"
	G.localization.misc.dictionary["cq_unhexed"] = "unhexed"
	G.localization.misc.dictionary["Cq_unhexed"] = "Unhexed"
	G.localization.misc.dictionary["cq_clipped"] = "paperclipped"
	G.localization.misc.dictionary["Cq_clipped"] = "Paperclipped"
	G.localization.misc.dictionary["cq_unclipped"] = "unclipped"
	G.localization.misc.dictionary["Cq_unclipped"] = "Unclipped"
	G.localization.misc.dictionary["cq_cursed"] = "cursed"
	G.localization.misc.dictionary["Cq_cursed"] = "Cursed"
	G.localization.misc.dictionary["cq_uncursed"] = "uncursed"
	G.localization.misc.dictionary["Cq_uncursed"] = "Uncursed"
	G.localization.misc.dictionary["cq_vowel"] = "vowel"
	G.localization.misc.dictionary["Cq_vowel"] = "Vowel"
	G.localization.misc.dictionary["cq_consonant"] = "consonant"
	G.localization.misc.dictionary["Cq_consonant"] = "Consonant"
	G.localization.misc.dictionary["cq_ccd"] = "CCD"
	G.localization.misc.dictionary["Cq_ccd"] = "CCD"
	G.localization.misc.dictionary["cq_temporary"] = "temporary"
	G.localization.misc.dictionary["Cq_temporary"] = "Temporary"
	
	-- below from feder's stamps port
    G.localization.misc.dictionary["ml_stamp_explanation"] = {
		"Jokers may each have one",
		"Edition and Stamp"
	}
    G.localization.misc.dictionary["ml_edition_seal_enhancement_explanation"][#G.localization.misc.dictionary["ml_edition_seal_enhancement_explanation"]+1] = "Playing cards may each have one Aspect"
	G.localization.misc.dictionary["k_amm_oddity_pack"] = "Oddity Pack"
	G.localization.misc.dictionary["k_plus_oddity"] = "+1 Oddity"
    G.localization.misc.dictionary["b_stamps"] = "Stamps"
    G.localization.misc.dictionary["b_aspects"] = "Aspects"
    G.localization.misc.dictionary["k_empty_graveyard"] = "Graveyard is empty!"
        SMODS.process_loc_text(G.localization.descriptions.Other, 'graveyard', {name = "Graveyard", text = {"Each {C:attention}destroyed{} playing card","is put into your {C:attention}graveyard{}","{C:inactive}(Viewable from deck)"}})
        SMODS.process_loc_text(G.localization.misc.labels, 'bottle', "Bottled", 'label')
        SMODS.process_loc_text(G.localization.descriptions.Other, 'bottle', {name = "Bottled", text = {"This card will", "always be on top", "after shuffling"}})
		SMODS.process_loc_text(G.localization.misc.dictionary, "b_graveyard", "Graveyard")
        SMODS.process_loc_text(G.localization.descriptions.Other, 'petting', {
			name = "Petting",
			text = {
				"To {C:green}pet{} a card, rotate your",
				"cursor over it in a circular motion",
				"Some effects {C:attention}may{} differ if a card",
				"is {C:green}pet{C:attention} clockwise{} or {C:attention}counter-",
				"{C:attention}-clockwise{}, or may factor in {C:attention}speed{}",
				"{s:0.15} ",
				"{C:inactive}Oh yeah we got dexterity",
				"{C:inactive}challenges in Balatro",
			}})
end