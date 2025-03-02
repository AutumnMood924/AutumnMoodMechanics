-- oh fucking god
-- aspects
-- extra playing card layer like
-- enhancements/seals/editions

-- basically just Seals 2

AMM.Aspects = {}
AMM.Aspect = SMODS.GameObject:extend {
    obj_table = AMM.Aspects,
    obj_buffer = {},
    rng_buffer = {},
    badge_to_key = {},
    set = 'Aspect',
    atlas = 'centers',
    pos = { x = 0, y = 0 },
    discovered = false,
    colour = HEX('FFFFFF'),
    badge_colour = HEX('FFFFFF'),
    badge_text_colour = HEX('000000'),
    required_params = {
        'key',
        'pos',
    },
    inject = function(self)
        G.P_ASPECTS[self.key] = self
        G.shared_aspects[self.key] = Sprite(0, 0, G.CARD_W, G.CARD_H,
            G.ASSET_ATLAS[self.atlas] or G.ASSET_ATLAS['centers'], self.pos)
        self.badge_to_key[self.key:lower() .. '_aspect'] = self.key
        SMODS.insert_pool(G.P_CENTER_POOLS[self.set], self)
        self.rng_buffer[#self.rng_buffer + 1] = self.key
    end,
    process_loc_text = function(self)
        SMODS.process_loc_text(G.localization.misc.labels, self.key:lower() .. '_aspect', self.loc_txt, 'label')
        G.localization.descriptions.Aspect = G.localization.descriptions.Aspect or {}
        SMODS.process_loc_text(G.localization.descriptions.Other, self.key:lower() .. '_aspect', self.loc_txt, 'description')
        SMODS.process_loc_text(G.localization.descriptions.Aspect, self.key:lower() .. '_aspect', self.loc_txt, 'description')
    end,
    get_obj = function(self, key) return G.P_ASPECTS[key] end,
    generate_ui = function(self, info_queue, card, desc_nodes, specific_vars, full_UI_table)
        local target = {
            type = 'other',
            set = 'Other',
            key = self.key:lower()..'_aspect',
            nodes = desc_nodes,
            vars = specific_vars or {},
        }
        local res = {}
        if self.loc_vars and type(self.loc_vars) == 'function' then
            res = self:loc_vars(info_queue, card) or {}
            target.vars = res.vars or target.vars
            target.key = res.key or target.key
            if res.set then
                target.type = 'descriptions'
                target.set = res.set
            end
            target.scale = res.scale
            target.text_colour = res.text_colour
        end
        if desc_nodes == full_UI_table.main and not full_UI_table.name then
            full_UI_table.name = localize { type = 'name', set = target.set, key = res.name_key or target.key, nodes = full_UI_table.name, vars = res.name_vars or target.vars or {} }
        elseif desc_nodes ~= full_UI_table.main and not desc_nodes.name then
            desc_nodes.name = localize{type = 'name_text', key = res.name_key or target.key, set = target.set }
        end
        if res.main_start then
            desc_nodes[#desc_nodes + 1] = res.main_start
        end
        localize(target)
        if res.main_end then
            desc_nodes[#desc_nodes + 1] = res.main_end
        end
        desc_nodes.background_colour = res.background_colour
    end,
}

function Card:set_aspect(_aspect, silent, immediate)
    --print("setting aspect to " .. _aspect)
    self.aspect = nil
    if _aspect then
        self.aspect = _aspect
        if not silent then 
        G.CONTROLLER.locks.aspect = true
            if immediate then 
                self:juice_up(0.3, 11.11)
                play_sound('gold_seal', 0.612, 0.413)
                G.CONTROLLER.locks.aspect = false
            else
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.3,
                    func = function()
                        self:juice_up(0.3, 11.11)
                        play_sound('gold_seal', 0.612, 0.413)
                    return true
                    end
                }))
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.15,
                    func = function()
                        G.CONTROLLER.locks.aspect = false
                    return true
                    end
                }))
            end
        end
    end
    self:set_cost()
end
function Card:get_aspect(bypass_debuff)
    if self.debuff and not bypass_debuff then return end
    return self.aspect
end
function Card:calculate_aspect(context)
    if self.debuff then return nil end
    local obj = G.P_ASPECTS[self.aspect] or {}
    if obj.calculate and type(obj.calculate) == 'function' then
    	local o = obj:calculate(self, context)
    	if o then
            if not o.card then o.card = self end
            return o
        end
    end
end

G.FUNCS.your_collection_aspects = function(e)
    G.SETTINGS.paused = true
    G.FUNCS.overlay_menu{
      definition = create_UIBox_your_collection_aspects(),
    }
end

function create_UIBox_your_collection_aspects(exit)
    local deck_tables = {}
  
    local size = G.P_CENTER_POOLS['Aspect'] and #G.P_CENTER_POOLS['Aspect'] or 1

    G.your_collection = CardArea(
        G.ROOM.T.x + 0.2*G.ROOM.T.w/2,G.ROOM.T.h,
        5.3*G.CARD_W,
        1.03*G.CARD_H,
        {card_limit = size, type = 'title', highlight_limit = 0})
      table.insert(deck_tables, 
      {n=G.UIT.R, config={align = "cm", padding = 0, no_fill = true}, nodes={
        {n=G.UIT.O, config={object = G.your_collection}}
      }}
      )
  
    for k, v in ipairs(G.P_CENTER_POOLS['Aspect']) do
      local center = G.P_CENTERS.c_base
      --sendDebugMessage(inspect(SMODS.Stamps))
      local card = Card(G.your_collection.T.x + G.your_collection.T.w/2, G.your_collection.T.y, G.CARD_W, G.CARD_H, G.P_CARDS.empty, center)
      card:set_aspect(v.key, true)
      G.your_collection:emplace(card)
    end
    
    local t = create_UIBox_generic_options({ infotip = localize('ml_edition_seal_enhancement_explanation'), back_func = exit or 'your_collection', snap_back = true, contents = {
              {n=G.UIT.R, config={align = "cm", minw = 2.5, padding = 0.1, r = 0.1, colour = G.C.BLACK, emboss = 0.05}, nodes=deck_tables},
            }})
    return t
end

local alias__Card_generate_UIBox_ability_table = Card.generate_UIBox_ability_table

function Card:generate_UIBox_ability_table()
    local ret = alias__Card_generate_UIBox_ability_table(self)
    if self.aspect then 
        generate_card_ui({key = self.aspect.."_aspect", set = 'Aspect'}, ret)
    end
    return ret
end
----- WHAT THE UFCK HELP
SMODS.DrawStep {
    key = "Aspect",
    order = 52,
    func = function(self)
        if self.aspect then
            G.shared_aspects[self.aspect].role.draw_major = self
            G.shared_aspects[self.aspect]:draw_shader('dissolve', nil, nil, nil, self.children.center)
        end
    end,
    conditions = { vortex = false, facing = 'front' },
}