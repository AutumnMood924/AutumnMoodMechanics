AMM = {}
AMM.mod = SMODS.current_mod

-- todo
AMM.config = {
	suit_levels = {
		chips = 5,
		mult = 1,
	},
}

SMODS.Atlas {
	key = "modicon",
	path = "OddityTag.png",
	px = 34,
	py = 34,
}

AMM.api = {}
AMM.api.stamp = NFS.load(AMM.mod.path.."api/Stamps.lua")()
AMM.api.oddity = NFS.load(AMM.mod.path.."api/Oddity.lua")()
AMM.api.aspect = NFS.load(AMM.mod.path.."api/Aspect.lua")()


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
    G.GAME.amm_data.suit_levels[suit].mult = math.max(AMM.config.suit_levels.mult*(G.GAME.amm_data.suit_levels[suit].level - 1), 0)
    G.GAME.amm_data.suit_levels[suit].chips = math.max(AMM.config.suit_levels.chips*(G.GAME.amm_data.suit_levels[suit].level - 1), 0)
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

-- subtitles
local alias__Card_generate_UIBox_ability_table = Card.generate_UIBox_ability_table;
function Card:generate_UIBox_ability_table()
	local ret = alias__Card_generate_UIBox_ability_table(self)
	
	local center_obj = self.config.center
	
	if center_obj and center_obj.discovered and center_obj.subtitle then
	
		if ret.name and ret.name ~= true then
			local text = ret.name
			
			text[1].config.object.text_offset.y = text[1].config.object.text_offset.y - 14
			ret.name = {{n=G.UIT.R, config={align = "cm"},nodes={
				{n=G.UIT.R, config={align = "cm"}, nodes=text},
				{n=G.UIT.R, config={align = "cm"}, nodes={
					{n=G.UIT.O, config={object = DynaText({string = center_obj.subtitle, colours = {G.C.WHITE},float = true, shadow = true, offset_y = 0.1, silent = true, spacing = 1, scale = 0.33*0.7})}}
				}}
			}}}
		end
	
	end
	
	return ret
end

-- extra perma bonuses

local alias__Card_get_chip_bonus = Card.get_chip_bonus;
function Card:get_chip_bonus()
    if self.debuff then return 0 end
    local ret = alias__Card_get_chip_bonus(self)
	if G.GAME.amm_data.suit_levels[self.base.suit] and self.ability.effect ~= 'Stone Card' and (not self.config.center.no_suit) then
		ret = ret + G.GAME.amm_data.suit_levels[self.base.suit].chips
	end
	return ret
end

local alias__Card_get_chip_mult = Card.get_chip_mult;
function Card:get_chip_mult()
    if self.debuff then return 0 end
    local ret = alias__Card_get_chip_mult(self) + (self.ability.perma_mult or 0)
	if G.GAME.amm_data.suit_levels[self.base.suit] and self.ability.effect ~= 'Stone Card' and (not self.config.center.no_suit) then
		ret = ret + G.GAME.amm_data.suit_levels[self.base.suit].mult
	end
	return ret
end

local alias__Card_get_chip_x_mult = Card.get_chip_x_mult;
function Card:get_chip_x_mult()
    if self.debuff then return 0 end
	local ret = math.max(alias__Card_get_chip_x_mult(self), 1) * (self.ability.perma_xmult or 1)
    return (ret > 1) and ret or 0
end

local alias__Card_get_chip_h_mult = Card.get_chip_h_mult;
function Card:get_chip_h_mult()
    if self.debuff then return 0 end
    return alias__Card_get_chip_h_mult(self) + (self.ability.perma_hmult or 0)
end

local alias__Card_get_chip_h_x_mult = Card.get_chip_h_x_mult;
function Card:get_chip_h_x_mult()
    if self.debuff then return 0 end
    local ret = math.max(alias__Card_get_chip_h_x_mult(self), 1) * (self.ability.perma_hxmult or 1)
    return (ret > 1) and ret or 0
end
-- end extra perma bonuses

SMODS.current_mod.custom_collection_tabs = function()
    return { UIBox_button {
        button = 'your_collection_stamps', label = {localize("b_stamps")}, minw = 5, id = 'your_collection_stamps'
    }, UIBox_button {
        button = 'your_collection_aspects', label = {localize("b_aspects")}, minw = 5, id = 'your_collection_aspects'
    }}
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
		}
	end
	return ret
end

------------------------------------------------------------------------
--- SUIT LEVEL PAGE

function create_UIBox_current_suits(simple)
	G.current_suits = {}
	local index = 0
	
	local counts = TheAutumnCircus.func.count_deck_suits()
	
	for i=#SMODS.Suit.obj_buffer,1,-1 do
		local v = SMODS.Suit.obj_buffer[i]
		local ui_element = create_UIBox_current_suit_row(v, simple, counts[v])
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
						opt_callback = 'your_suits_page',
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

G.FUNCS.your_suits_page = function(args)
	if not args or not args.cycle_config then return end
	G.current_suits = {}
	
	local counts = TheAutumnCircus.func.count_deck_suits()

	local index = 0
	for i=#SMODS.Suit.obj_buffer,1,-1 do
		local v = SMODS.Suit.obj_buffer[i]
		local ui_element = create_UIBox_current_suit_row(v, simple, counts[v])
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
						'your_suits_page',
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
  return (count > 0 or G.GAME.amm_data.suit_levels[suit].level > 1) and
  (not simple and
    {n=G.UIT.R, config={align = "cm", padding = 0.05, r = 0.1, colour = darken(G.C.SUITS[suit], 0.1), emboss = 0.05, hover = true, force_focus = true}, nodes={
      {n=G.UIT.C, config={align = "cl", padding = 0, minw = 5}, nodes={
        {n=G.UIT.C, config={align = "cm", padding = 0.01, r = 0.1, colour = G.C.HAND_LEVELS[math.min(7, G.GAME.amm_data.suit_levels[suit].level)], minw = 1.5, outline = 0.8, outline_colour = lighten(G.C.SUITS[suit], 0.4)}, nodes={
          {n=G.UIT.T, config={text = localize('k_level_prefix')..G.GAME.amm_data.suit_levels[suit].level, scale = 0.5, colour = G.C.UI.TEXT_DARK}}
        }},
        {n=G.UIT.C, config={align = "cm", minw = 4.5, maxw = 4.5}, nodes={
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
	G.localization.descriptions.Other["card_extra_mult"] = {
		text = {
			"{C:mult}+#1#{} extra Mult"
		}
	}
	G.localization.descriptions.Other["card_extra_xmult"] = {
		text = {
			"{C:mult}+{X:mult,C:white} X#1# {} extra Mult"
		}
	}
	G.localization.descriptions.Other["card_extra_hmult"] = {
		text = {
			"{C:mult}+#1#{} extra Mult",
			"while this card",
			"stays in hand"
		}
	}
	G.localization.descriptions.Other["card_extra_hxmult"] = {
		text = {
			"{C:mult}+{X:mult,C:white} X#1# {} extra Mult",
			"while this card",
			"stays in hand"
		}
	}
	G.localization.descriptions.Other["card_amm_suit_bonus"] = {
		text = {
			"{s:0.8,C:inactive}({s:0.8,V:2}#4# {s:0.8,V:1}lvl.#1#{s:0.8,C:inactive}) {s:0.8,C:white,X:chips}+#2#{s:0.4} {s:0.8}X{s:0.4} {C:white,X:mult,s:0.8}+#3#{s:0.8}",
		}
	}
	G.localization.misc.v_dictionary["a_blind"] = "Blind +#1#"
	G.localization.misc.v_dictionary["a_blind_percent"] = "Blind +#1#%"
	G.localization.misc.v_dictionary["a_blind_minus"] = "Blind -#1#"
	G.localization.misc.v_dictionary["a_blind_minus_percent"] = "Blind -#1#%"
	G.localization.misc.dictionary["b_suits"] = "Suits"
	-- below from feder's stamps port
    G.localization.misc.dictionary["ml_stamp_explanation"] = {
		"Jokers may each have one",
		"Edition and Stamp"
	}
    G.localization.misc.dictionary["ml_edition_seal_enhancement_explanation"][#G.localization.misc.dictionary["ml_edition_seal_enhancement_explanation"]+1] = "Playing cards may each have one Aspect"
	G.localization.misc.dictionary["k_amm_oddity_pack"] = "Oddity Pack"
    G.localization.misc.dictionary["b_stamps"] = "Stamps"
    G.localization.misc.dictionary["b_aspects"] = "Aspects"
end