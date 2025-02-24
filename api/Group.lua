-- wip
-- still 

local return_API = {}

AMM.Groups = {}
AMM.Group = SMODS.GameObject:extend {
    obj_table = AMM.Groups,
    obj_buffer = {},
    required_params = {
        'key',
        'cards',
    },
    prefix_config = { key = false },
    inject = function(self)
        -- this space intentionally left
    end,
    process_loc_text = function(self)
        -- this space should probably contain something but i havent decided yet
    end,
    get_obj = function(self, key)
        return AMM.Groups[key]
    end,
    get_cards = function(self)
        local ret = {}
        for _,k in ipairs(self.cards) do
            ret[k]=G.P_CENTERS[k]
        end
        print(inspect(ret))
        return ret
    end,
    filter_cards = function(self, f)
        if f and type(f) == "function" then
            local new_cards = {}
            for k,v in ipairs(self:get_cards()) do
                if f(v) then new_cards[#new_cards+1] = v end
            end
            return new_cards
        elseif f and type(f) == "table" then
            local new_cards = {}
            for k,v in ipairs(self:get_cards()) do
                local allow = true
                for fk,fv in ipairs(f) do
                    if v[fk] and v[fk] ~= fv then allow = false end
                end
                if allow then new_cards[#new_cards+1] = v end
            end
            return new_cards
        else
            return {}
        end
    end,
    pseudorandom_key = function(self, seed)
        local cards = self.cards
        return pseudorandom_element(cards, seed)
    end,
    pseudorandom_card = function(self, seed)
        local cards = self:get_cards()
        return pseudorandom_element(cards, seed)
    end,
    pseudorandom_filter_card = function(self, seed, f)
        local cards = self:filter_cards(f)
        return pseudorandom_element(cards, seed)
    end,
    pseudorandom_filter_key = function(self, seed, f)
        return self:pseudorandom_filter_card(seed, f).key
    end,
    register = function(self)
        if not AMM.Groups[self.key] then
            AMM.Group.super.register(self)
        else
            local card_set = {}
            for _,v in ipairs(AMM.Groups[self.key].cards) do
                card_set[v] = true
            end
            for _,v in ipairs(self.cards) do
                if not card_set[v] then
                    print(v)
                    table.insert(AMM.Groups[self.key].cards, v)
                    card_set[v] = true
                end
            end
        end
    end,
    -- Duplicate registers of Groups are handled above.
    check_duplicate_register = function(self) return false end,
    check_duplicate_key = function(self) return false end,
}

AMM.Group {
    key = "food",
    cards = {
		"j_ice_cream",
		"j_popcorn",
		"j_gros_michel",
		"j_cavendish",
    },
}
AMM.Group {
    key = "food",
    cards = {
		"j_egg",
		"j_turtle_bean",
		"j_diet_cola",
		"j_ramen",
		"j_selzer",
    },
}

AMM.Group {
    key = "stone",
    cards = {
		"j_marble",
		"j_mystic_summit",
		"j_stone",
		"j_rough_gem",
		"j_bloodstone",
		"j_arrowhead",
		"j_onyx_agate",
		"j_ancient",
		"j_obelisk",
        "m_stone",
    },
}

-- eval G.jokers:emplace(SMODS.create_card{area = G.jokers, card = AMM.Groups.food:pseudorandom_filter_key(pseudoseed("seed"), function(v) return true end)})

return return_API
