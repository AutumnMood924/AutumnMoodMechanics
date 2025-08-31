--[[
SMODS.Scoring_Parameter({
	key = 'plusmult',
	default_value = 0,
	colour = G.C.UI_MULT,
	calculation_keys = {'plusmult', 'h_plusmult', 'plusmult_mod','x_plusmult', 'Xplusmult', 'xplusmult', 'x_plusmult_mod', 'Xplusmult_mod'},
	flame_handler = function(self)
		return nil
	end,
	calc_effect = function(self, effect, scored_card, key, amount, from_edition)
		if not SMODS.Calculation_Controls.mult then return end
		if (key == 'plusmult' or key == 'h_plusmult' or key == 'plusmult_mod') and amount then
			if effect.card and effect.card ~= scored_card then juice_card(effect.card) end
			self:modify(amount)
			if not effect.remove_default_message then
				if from_edition then
					card_eval_status_text(scored_card, 'jokers', nil, percent, nil, {message = localize{type = 'variable', key = amount > 0 and 'a_amm_plusmult' or 'a_amm_plusmult_minus', vars = {amount}}, mult_mod = amount, colour = G.C.DARK_EDITION, edition = true})
				else
					if key ~= 'mult_mod' then
						if effect.mult_message then
							card_eval_status_text(effect.message_card or effect.juice_card or scored_card or effect.card or effect.focus, 'extra', nil, percent, nil, effect.mult_message)
						else
							card_eval_status_text(effect.message_card or effect.juice_card or scored_card or effect.card or effect.focus, 'plusmult', amount, percent)
						end
					end
				end
			end
			return true
		end
		if (key == 'x_plusmult' or key == 'xplusmult' or key == 'Xplusmult' or key == 'x_plusmult_mod' or key == 'Xplusmult_mod') and amount ~= 1 then
			if effect.card and effect.card ~= scored_card then juice_card(effect.card) end
			self:modify(self.current * (amount - 1))
			if not effect.remove_default_message then
				if from_edition then
					card_eval_status_text(scored_card, 'jokers', nil, percent, nil, {message = localize{type='variable',key= amount > 0 and 'a_amm_xplusmult' or 'a_amm_xplusmult_minus',vars={amount}}, Xmult_mod =  amount, colour =  G.C.EDITION, edition = true})
				else
					if key ~= 'Xplusmult_mod' then
						if effect.xmult_message then
							card_eval_status_text(effect.message_card or effect.juice_card or scored_card or effect.card or effect.focus, 'extra', nil, percent, nil, effect.xmult_message)
						else
							card_eval_status_text(effect.message_card or effect.juice_card or scored_card or effect.card or effect.focus, 'x_plusmult', amount, percent)
						end
					end
				end
			end
			return true
		end
	end,
	modify = function(self, amount)
		--mult = mod_mult(mult + amount)
		self.current = self.current + amount
		update_hand_text({delay = 0}, {amm_plusmult = self.current})
	end
})


SMODS.Sound{
	key = "plusmult",
	path = "plusmult.ogg",
	volume = 0.55,
}
SMODS.Sound{
	key = "xplusmult",
	path = "xplusmult.ogg",
	volume = 0.55,
}

--[[ show plusmult

-- CURRENTLY THIS IS BREAKING THE UI
-- I KNOW HOW TO FIX IT
-- IT SUCKS AND I DO NOT WANT TO
-- PLEASE HAVE PATIENCE
local alias__update_hand_text = update_hand_text
function update_hand_text(thing1, thing2)
        if vals.mult and G.GAME.current_round.current_hand.mult ~= vals.mult then
            local delta = (type(vals.mult) == 'number' and type(G.GAME.current_round.current_hand.mult) == 'number')and (vals.mult - G.GAME.current_round.current_hand.mult) or 0
            if delta < 0 then delta = ''..delta; col = G.C.RED
            elseif delta > 0 then delta = '+'..delta
            else delta = ''..delta
            end
            if type(vals.mult) == 'string' then delta = vals.mult end
            G.GAME.current_round.current_hand.mult = vals.mult
            G.hand_text_area.mult:update(0)
            if vals.StatusText then 
                attention_text({
                    text =delta,
                    scale = 0.8, 
                    hold = 1,
                    cover = G.hand_text_area.mult.parent,
                    cover_colour = mix_colours(G.C.MULT, col, 0.1),
                    emboss = 0.05,
                    align = 'cm',
                    cover_align = 'cl'
                })
            end
            if not G.TAROT_INTERRUPT then G.hand_text_area.mult:juice_up() end
        end
	return alias__update_hand_text(thing1, thing2)
end

function SMODS.GUI.mult_container(scale)
    return 
    {n=G.UIT.C, config={align = 'br', id = 'hand_mult_container'}, nodes = {
        SMODS.GUI.score_container({
            type = 'mult', h = SMODS.optional_features.amm_plusmult and 0.65 or nil--, scale = 0.3
        }),
		(SMODS.optional_features.amm_plusmult == true) and {
		n = G.UIT.R, config = {align = 'bl', minw = 2/1.5, minh = 0.35, id = 'hand_plusmult_area_area'}, nodes = {
			{n=G.UIT.C, config={align = 'cm', minw = 0.35, maxh = 0.25, id = 'plusmult_operator_container', can_collide = false}, nodes = {
				{n=G.UIT.O, config={id = 'hand_amm_plusmult_plus', text = "+", no_role = true, type = "amm_plusmult_plus", scale = 0, object = DynaText({
					string = "+",
					colours = {G.C.UI.TEXT_LIGHT}, font = G.LANGUAGES['en-us'].font, scale = 0.4*1.2
				})}},
				--{n=G.UIT.T, config={text = "+", lang = G.LANGUAGES['en-us'], scale = 0.4, colour = G.C.UI.TEXT_LIGHT, shadow = true}},
			}},
			{n=G.UIT.R, config={align = 'br', minw = 2-0.35, minh = 0.35, r = 0.06, colour = SMODS.Scoring_Parameters['mult'].colour, id = 'hand_plusmult_area', emboss = 0.05}, nodes={
				
				--{n=G.UIT.O, config={func = 'flame_handler', no_role = true, id = 'flame_amm_plusmult', object = Moveable(0,0,0,0), w = 0, h = 0, _w = 2 * 1.25, _h = 1 * 1.5}},
				{n=G.UIT.O, config={id = 'hand_amm_plusmult', func = 'hand_type_UI_set', text = "current", type = "amm_plusmult", scale = 0.4*1.4, object = DynaText({
					string = {{ref_table = G.GAME.current_round.current_hand, ref_value = "amm_plusmult"}},
					colours = {G.C.UI.TEXT_LIGHT}, font = G.LANGUAGES['en-us'].font, shadow = true, float = true, scale = 0.4*1.2
				})}},
				{n=G.UIT.B, config={w = 0.1, h = 0.1}},
			}}

		}} or nil,
    }}
end

-- apply plusmult
local alias__SMODS_get_scoring_parameter = SMODS.get_scoring_parameter
function SMODS.get_scoring_parameter(key, flames)
	if key == "mult" and type(SMODS.Scoring_Parameters["amm_plusmult"].current) == "number" and SMODS.Scoring_Parameters["amm_plusmult"].current ~= "?" then
		local ret = alias__SMODS_get_scoring_parameter(key,flames)
		if type(ret) == "number" then
			ret = ret + (flames and G.GAME.current_round.current_hand.amm_plusmult or SMODS.Scoring_Parameters["amm_plusmult"].current)
		end
		return ret
	else
		return alias__SMODS_get_scoring_parameter(key,flames)
	end
end
--]]