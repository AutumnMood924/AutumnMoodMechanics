-- Most of this code was done by Mysthaps!

-- Create tab in deck view
local create_tabsref = create_tabs
function create_tabs(args)
    if args.tabs then
        for _, v in ipairs(args.tabs) do
            if v.label == localize('b_full_deck') and SMODS.optional_features.amm.graveyard then
                args.tabs[#args.tabs+1] = {
                    label = localize("b_graveyard"),
                    tab_definition_function = G.UIDEF.view_graveyard
                }
            end
        end
    end
    return create_tabsref(args)
end

------ Helper functions ------

--- Move card from graveyard to hand
---@param specific_area table? Specific cardarea to add the card to, defaults to ``G.hand`` or ``G.deck`` (if ``G.hand`` isn't available)
function Card:move_from_graveyard(specific_area)
    if self.graveyard then
        G.graveyard_area:remove_card(self)

        for k, v in ipairs(G.graveyard) do
            if v == self then
                table.remove(G.graveyard, k)
                break
            end
        end
        for k, v in ipairs(G.graveyard) do
            v.playing_card = k
        end

        self.graveyard = false
        G.deck.config.card_limit = G.deck.config.card_limit + 1
        if specific_area then
            specific_area:emplace(self)
        else
            if not always_to_deck and G.hand then
                G.hand:emplace(self)
            else
                G.deck:emplace(self)
            end
        end

        self:remove_from_graveyard()
        G.playing_cards[#G.playing_cards+1] = self
        self.playing_card = #G.playing_cards
    end
end

--- Destroy a card without placing it in the graveyard
--- Effectively a higher tier destruction
--- Can also be used on cards already in the graveyard
--- To remove them permanently
function Card:remove_from_game(dissolve_colours, silent, dissolve_time_fac, no_juice)
    AMM.api.graveyard.active = false
    self:start_dissolve(dissolve_colours, silent, dissolve_time_fac, no_juice)
    AMM.api.graveyard.active = true
end

--- Move card to graveyard without destroying it
function Card:move_to_graveyard()
    for k, v in ipairs(G.playing_cards) do
        if v == self then
            table.remove(G.playing_cards, k)
            break
        end
    end
    for k, v in ipairs(G.playing_cards) do
        v.playing_card = k
    end

    if self.area then self.area:remove_card(self) end

    self.graveyard = true
    self.area = G.graveyard_area
    table.insert(G.graveyard, self)
    G.graveyard_area:emplace(self)
    self:add_to_graveyard()
    SMODS.calculate_context({amm_buried_card = true, other_card = self})
end

--- Function to be called whenever the card is added to the graveyard
function Card:add_to_graveyard()
    local obj = self.config.center
    if obj and obj.add_to_graveyard and type(obj.add_to_graveyard) == 'function' then
    	obj:add_to_graveyard(self)
    end
end

--- Function to be called whenever the card is removed from the graveyard
function Card:remove_from_graveyard()
    local obj = self.config.center
    if obj and obj.remove_from_graveyard and type(obj.remove_from_graveyard) == 'function' then
    	obj:remove_from_graveyard(self)
    end
end

sendInfoMessage("Loaded Graveyard~")

-- ^ the actual mod
---------------------------------------------------------------------------------------------------------------------
-- v mental illness

function G.UIDEF.view_graveyard()
    local deck_tables = {}
    remove_nils(G.graveyard)
    G.VIEWING_DECK = true
    table.sort(G.graveyard, function(a, b) return a:get_nominal('suit') > b:get_nominal('suit') end)
    local SUITS = {}
    local suit_map = {}
    for i = #SMODS.Suit.obj_buffer, 1, -1 do
        SUITS[SMODS.Suit.obj_buffer[i]] = {}
        suit_map[#suit_map + 1] = SMODS.Suit.obj_buffer[i]
    end
    for k, v in ipairs(G.graveyard) do
        table.insert(SUITS[v.base.suit], v)
    end
    local num_suits = 0
    for j = 1, #suit_map do
        if SUITS[suit_map[j]][1] then num_suits = num_suits + 1 end
    end
    for j = 1, #suit_map do
        if SUITS[suit_map[j]][1] then
            local view_deck = CardArea(
                G.ROOM.T.x + 0.2 * G.ROOM.T.w / 2, G.ROOM.T.h,
                6.5 * G.CARD_W,
                ((num_suits > 8) and 0.2 or (num_suits > 4) and (1 - 0.1 * num_suits) or 0.6) * G.CARD_H,
                { card_limit = #SUITS[suit_map[j]], type = 'title', view_deck = true, highlight_limit = 0, card_w = G.CARD_W * 0.7, draw_layers = { 'card' } })
            table.insert(deck_tables,
                {
                    n = G.UIT.R,
                    config = { align = "cm", padding = 0 },
                    nodes = {
                        { n = G.UIT.O, config = { object = view_deck } }
                    }
                }
            )

            for i = 1, #SUITS[suit_map[j]] do
                if SUITS[suit_map[j]][i] then
                    local _scale = 0.7
                    local copy = copy_card(SUITS[suit_map[j]][i], nil, _scale)
                    copy.greyed = nil
                    copy.T.x = view_deck.T.x + view_deck.T.w / 2
                    copy.T.y = view_deck.T.y

                    copy:hard_set_T()
                    view_deck:emplace(copy)
                end
            end
        end
    end

    if #deck_tables == 0 then
        deck_tables[1] = {
            n = G.UIT.R,
            config = { align = "cm", minh = 0.05, padding = 0.07 },
            nodes = {
                { n = G.UIT.O, config = { object = DynaText({ string = localize('k_empty_graveyard'), colours = { G.C.WHITE }, silent = true, scale = 0.4, pop_in_rate = 10, pop_delay = 4 }) } }
            }
        }
    end

    local flip_col = G.C.WHITE

    local suit_tallies = {}
    local mod_suit_tallies = {}
    for _, v in ipairs(suit_map) do
        suit_tallies[v] = 0
        mod_suit_tallies[v] = 0
    end
    local rank_tallies = {}
    local mod_rank_tallies = {}
    local rank_name_mapping = SMODS.Rank.obj_buffer
    for _, v in ipairs(rank_name_mapping) do
        rank_tallies[v] = 0
        mod_rank_tallies[v] = 0
    end
    local face_tally = 0
    local mod_face_tally = 0
    local num_tally = 0
    local mod_num_tally = 0
    local ace_tally = 0
    local mod_ace_tally = 0

    for k, v in ipairs(G.graveyard) do
        if v.ability.name ~= 'Stone Card' then
            --For the suits
            suit_tallies[v.base.suit] = (suit_tallies[v.base.suit] or 0) + 1
            for kk, vv in pairs(mod_suit_tallies) do
                mod_suit_tallies[kk] = (vv or 0) + (v:is_suit(kk) and 1 or 0)
            end

            --for face cards/numbered cards/aces
            local card_id = v:get_id()
            face_tally = face_tally + ((SMODS.Ranks[v.base.value].face) and 1 or 0)
            mod_face_tally = mod_face_tally + (v:is_face() and 1 or 0)
            if not SMODS.Ranks[v.base.value].face and card_id ~= 14 then
                num_tally = num_tally + 1
                if not v.debuff then mod_num_tally = mod_num_tally + 1 end
            end
            if card_id == 14 then
                ace_tally = ace_tally + 1
                if not v.debuff then mod_ace_tally = mod_ace_tally + 1 end
            end

            --ranks
            rank_tallies[v.base.value] = rank_tallies[v.base.value] + 1
            if not v.debuff then mod_rank_tallies[v.base.value] = mod_rank_tallies[v.base.value] + 1 end
        end
    end
    local modded = face_tally ~= mod_face_tally
    for kk, vv in pairs(mod_suit_tallies) do
        modded = modded or (vv ~= suit_tallies[kk])
        if modded then break end
    end

    local rank_cols = {}
    for i = #rank_name_mapping, 1, -1 do
        local mod_delta = mod_rank_tallies[i] ~= rank_tallies[i]
        rank_cols[#rank_cols+1] = {n=G.UIT.R, config={align = "cm", padding = 0.07}, nodes={
        {n=G.UIT.C, config={align = "cm", r = 0.1, padding = 0.04, emboss = 0.04, minw = 0.5, colour = G.C.L_BLACK}, nodes={
            {n=G.UIT.T, config={text = SMODS.Ranks[rank_name_mapping[i]].shorthand,colour = G.C.JOKER_GREY, scale = 0.35, shadow = true}},
        }},
        {n=G.UIT.C, config={align = "cr", minw = 0.4}, nodes={
            mod_delta and {n=G.UIT.O, config={object = DynaText({string = {{string = ''..rank_tallies[i], colour = flip_col},{string =''..mod_rank_tallies[i], colour = G.C.BLUE}}, colours = {G.C.RED}, scale = 0.4, y_offset = -2, silent = true, shadow = true, pop_in_rate = 10, pop_delay = 4})}} or
            {n=G.UIT.T, config={text = rank_tallies[rank_name_mapping[i]],colour = flip_col, scale = 0.45, shadow = true}},
        }}
    }}
    end

    local tally_ui = {
        -- base cards
        {
            n = G.UIT.R,
            config = { align = "cm", minh = 0.05, padding = 0.07 },
            nodes = {
                { n = G.UIT.O, config = { object = DynaText({ string = { { string = localize('k_base_cards'), colour = G.C.RED }, modded and { string = localize('k_effective'), colour = G.C.BLUE } or nil }, colours = { G.C.RED }, silent = true, scale = 0.4, pop_in_rate = 10, pop_delay = 4 }) } }
            }
        },
        -- aces, faces and numbered cards
        {
            n = G.UIT.R,
            config = { align = "cm", minh = 0.05, padding = 0.1 },
            nodes = {
                tally_sprite({ x = 1, y = 0 },
                    { { string = '' .. ace_tally, colour = flip_col }, { string = '' .. mod_ace_tally, colour = G.C.BLUE } },
                    { localize('k_aces') }), --Aces
                tally_sprite({ x = 2, y = 0 },
                    { { string = '' .. face_tally, colour = flip_col }, { string = '' .. mod_face_tally, colour = G.C.BLUE } },
                    { localize('k_face_cards') }), --Face
                tally_sprite({ x = 3, y = 0 },
                    { { string = '' .. num_tally, colour = flip_col }, { string = '' .. mod_num_tally, colour = G.C.BLUE } },
                    { localize('k_numbered_cards') }), --Numbers
            }
        },
    }
	-- add suit tallies
	local hidden_suits = {}
	for _, suit in ipairs(suit_map) do
		if suit_tallies[suit] == 0 and SMODS.Suits[suit].in_pool and not SMODS.Suits[suit]:in_pool({rank=''}) then
			hidden_suits[suit] = true
		end
	end
	local i = 1
	local num_suits_shown = 0
	for i = 1, #suit_map do
		if not hidden_suits[suit_map[i]] then
			num_suits_shown = num_suits_shown+1
		end
	end
	local suits_per_row = num_suits_shown > 6 and 4 or num_suits_shown > 4 and 3 or 2
	local n_nodes = {}
	while i <= #suit_map do
		while #n_nodes < suits_per_row and i <= #suit_map do
			if not hidden_suits[suit_map[i]] then
				table.insert(n_nodes, tally_sprite(
					SMODS.Suits[suit_map[i]].ui_pos,
					{
						{ string = '' .. suit_tallies[suit_map[i]], colour = flip_col },
						{ string = '' .. mod_suit_tallies[suit_map[i]], colour = G.C.BLUE }
					},
					{ localize(suit_map[i], 'suits_plural') },
					suit_map[i]
				))
			end
			i = i + 1
		end
		if #n_nodes > 0 then
			local n = {n = G.UIT.R, config = {align = "cm", minh = 0.05, padding = 0.1}, nodes = n_nodes}
			table.insert(tally_ui, n)
			n_nodes = {}
		end
	end
	local cardSleeveUI = nil
	if next(SMODS.find_mod('CardSleeves')) and G.GAME.selected_sleeve and G.GAME.selected_sleeve ~= "sleeve_casl_none" then
        if CardSleeves.config.sleeve_info_location == 1 or CardSleeves.config.sleeve_info_location == 3 then
            -- insert sleeve description UI element
            cardSleeveUI = {
                n = G.UIT.R,
                config = {align = "cm", r = 0.1, colour = G.C.L_BLACK, emboss = 0.05},
                nodes = {
                    {
                        n = G.UIT.R,
                        config = {align = "cm", r = 0.1, minw = 2.5, maxw = 4, minh = 1, colour = G.C.WHITE},
                        nodes = {
                            G.UIDEF.sleeve_description(G.GAME.selected_sleeve, 2.5, 0.05),
                        }
                    }
                }
            }
        end
	end
    local t = 
    {n=G.UIT.ROOT, config={align = "cm", colour = G.C.CLEAR}, nodes={
        {n=G.UIT.R, config={align = "cm", padding = 0.05}, nodes={}},
        {n=G.UIT.R, config={align = "cm"}, nodes={
        {n=G.UIT.C, config={align = "cm", minw = 1.5, minh = 2, r = 0.1, colour = G.C.BLACK, emboss = 0.05}, nodes={
            {n=G.UIT.C, config={align = "cm", padding = 0.1}, nodes={
            {n=G.UIT.R, config={align = "cm", r = 0.1, colour = G.C.L_BLACK, emboss = 0.05, padding = 0.15}, nodes={
                {n=G.UIT.R, config={align = "cm"}, nodes={
                {n=G.UIT.O, config={object = DynaText({string = G.GAME.selected_back.loc_name, colours = {G.C.WHITE}, bump = true, rotate = true, shadow = true, scale = 0.6 - string.len(G.GAME.selected_back.loc_name)*0.01})}},
                }},
                {n=G.UIT.R, config={align = "cm", r = 0.1, padding = 0.1, minw = 2.5, minh = 1.3, colour = G.C.WHITE, emboss = 0.05}, nodes={
                {n=G.UIT.O, config={object = UIBox{
                    definition = G.GAME.selected_back:generate_UI(nil,0.7, 0.5, G.GAME.challenge),
                    config = {offset = {x=0,y=0}}
                }}}
                }}
            }},
				cardSleeveUI,
            {n=G.UIT.R, config={align = "cm", r = 0.1, outline_colour = G.C.L_BLACK, line_emboss = 0.05, outline = 1.5}, nodes = tally_ui}        }},
            {n=G.UIT.C, config={align = "cm"}, nodes=rank_cols},
            {n=G.UIT.B, config={w = 0.1, h = 0.1}}
        }},
        {n=G.UIT.B, config={w = 0.2, h = 0.1}},
        {n=G.UIT.C, config={align = "cm", padding = 0.1, minw = 13, r = 0.1, colour = G.C.BLACK, emboss = 0.05}, nodes=deck_tables}
        }},
        {n=G.UIT.R, config={align = "cm", minh = 0.8, padding = 0.05}, nodes={
        modded and {n=G.UIT.R, config={align = "cm"}, nodes={
            {n=G.UIT.C, config={padding = 0.3, r = 0.1, colour = mix_colours(G.C.BLUE, G.C.WHITE,0.7)}, nodes = {}},
            {n=G.UIT.T, config={text =' '..localize('ph_deck_preview_effective'),colour = G.C.WHITE, scale =0.3}},
        }} or nil
        }}
    }}
    return t
end

-- idk
local alias__Game_start_run = Game.start_run
function Game:start_run(args)
    AMM.api.graveyard.active = false
    local ret = alias__Game_start_run(self,args)
    G.E_MANAGER:add_event(Event({
        trigger = 'after',
        func = function()
            AMM.api.graveyard.active = true
            return true
        end,
    }))
    return ret
end

-- amm api stuff (this part's still mental illness btw the above comment still applies)
local return_API = {}
return_API.get_cards = function()
    if G.STAGE == G.STAGES.RUN then
        return G.graveyard
    else
        return {}
    end
end
return_API.count_cards = function()
    return #(return_API.get_cards())
end
-- here, f is a function that takes one argument
-- the function should return true or false depending
-- on the card v supplied, where v is each card in GY
return_API.filter_cards = function(f)
    local cards = return_API.get_cards()
    if f and type(f) == "function" then
        local new_cards = {}
        for k,v in ipairs(cards) do
            if f(v) then new_cards[#new_cards+1] = v end
        end
        return new_cards
    else
        return {}
    end
end
return_API.filter_count = function(f)
    return #(return_API.filter_cards(f))
end
return_API.get_suit = function(suit)
    local cards = {}
    for k,v in ipairs(return_API.get_cards()) do
        if v:is_suit(suit, true) then cards[#cards+1] = v end
    end
    return cards
end
return_API.count_suit = function(suit)
    return #(return_API.get_suit(suit))
end
return_API.count_different_suits = function()
    local SUITS = {}
    local suitcount = 0
    local wilds = 0
    for k,v in ipairs(return_API.get_cards()) do
        if not SMODS.has_no_suit(v) then
            if SMODS.has_any_suit(v) then
                wilds = wilds + 1
            elseif not SUITS[v.base.suit] then
                SUITS[v.base.suit] = true
                suitcount = suitcount + 1
            else
                --do some jank shit to figure out what other suits this card is
                --obviously this code doesn't do this yet
            end
        end
    end
    if wilds > 0 and suitcount < #SMODS.Suit.obj_buffer then
        -- count hidden suits
        local hidden_suits = 0
        for k,v in pairs(SMODS.Suits) do
            if (not SUITS[k]) and v.in_pool and not v:in_pool({rank=''}) then hidden_suits = hidden_suits + 1 end
        end
        suitcount = math.min(#SMODS.Suit.obj_buffer - hidden_suits, suitcount + wilds)
    end
    return suitcount
end
return_API.get_rank = function(rank)
    local cards = {}
    for k,v in ipairs(return_API.get_cards()) do
        if v.base.value == rank and not SMODS.has_no_rank(v) then cards[#cards+1] = v end
    end
    return cards
end
return_API.count_rank = function(rank)
    return #(return_API.get_rank(rank))
end
return_API.count_different_ranks = function()
    local RANKS = {}
    local rankcount = 0
    for k,v in ipairs(return_API.get_cards()) do
        if not SMODS.has_no_rank(v) then
            if not RANKS[v.base.value] then
                RANKS[v.base.value] = true
                rankcount = rankcount + 1
            else
                --do some jank shit to figure out what other ranks this card is
                --obviously this code doesn't do this yet
            end
        end
    end
    if rankcount < #SMODS.Rank.obj_buffer then
        -- count hidden ranks
        local hidden_ranks = 0
        for k,v in pairs(SMODS.Ranks) do
            if (not RANKS[k]) and v.in_pool and not v:in_pool({suit=''}) then hidden_ranks = hidden_ranks + 1 end
        end
        rankcount = math.min(#SMODS.Rank.obj_buffer - hidden_ranks, rankcount)
    end
    return rankcount
end
return_API.get_faces = function()
    local faces = {}
    for k,v in ipairs(return_API.get_cards()) do
        if v:is_face() then faces[#faces+1] = v end
    end
    return faces
end
return_API.count_faces = function()
    return #(return_API.get_faces())
end
return_API.get_center = function(center)
    local cards = {}
    for k,v in ipairs(return_API.get_cards()) do
        if (v.config.center == center or v.config.center.key == center) then cards[#cards+1] = v end
    end
    return cards
end
return_API.count_center = function(center)
    return #(return_API.get_center(center))
end
return_API.active = true
return return_API