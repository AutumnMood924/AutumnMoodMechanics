SMODS.Atlas {
	key = "bottle",
	path = "bottle.png",
	px = 71,
	py = 95,
}

local alias__SMODS_injectItems = SMODS.injectItems
function SMODS.injectItems()
    alias__SMODS_injectItems()
    G.shared_bottle = Sprite(0, 0, G.CARD_W, G.CARD_H,
        G.ASSET_ATLAS['amm_bottle'], {x = 0, y = 0})
end

local alias__Card_generate_UIBox_ability_table = Card.generate_UIBox_ability_table

function Card:generate_UIBox_ability_table()
    local ret = alias__Card_generate_UIBox_ability_table(self)
    if self.bottle then 
        generate_card_ui({key = "bottle", set = 'Other'}, ret)
    end
    return ret
end

-- the meat and potatoes of the Bottled functionality right here:

local alias__CardArea_shuffle = CardArea.shuffle 

function CardArea:shuffle(seed)
    alias__CardArea_shuffle(self, seed)
    -- iterate over all cards in deck; separate bottled and non-bottled into two tables
    -- add the two tables back together and set self.cards to that table
    local bottled = {}
    local other = {}
    for k,v in ipairs(self.cards) do
        if v.bottle then
            bottled[#bottled+1] = v 
        else
            other[#other+1] = v 
        end
    end
    for k,v in ipairs(bottled) do
        other[#other+1] = v
    end
    self.cards = other
end
----- WHAT THE UFCK HELP
SMODS.DrawStep {
    key = "Bottle",
    order = 53,
    func = function(self)
        if self.bottle then
            G.shared_bottle.role.draw_major = self
            G.shared_bottle:draw_shader('dissolve', nil, nil, nil, self.children.center)
        end
    end,
}