local retapi = {}

local qualities = {
	"face", face = function(card)
		return card:is_face()
	end,
	"nonface", nonface = function(card)
		return not card:is_face()
	end,
	"numbered", numbered = function(card)
		if SMODS.has_no_rank(card) then return false end
		local face = card:is_face()
		local ace = card.base.value == "Ace"
		return not (face or ace)
	end,
	"odd", odd = function(card)
		if SMODS.has_no_rank(card) then return false end
		local face = card:is_face()
		local ace = card.base.value == "Ace"
		return not (face) and card:get_id() <= 10 and card:get_id() > 0 and (card:get_id() % 2 == 1 or ace)
	end,
	"even", even = function(card)
		if SMODS.has_no_rank(card) then return false end
		local face = card:is_face()
		local ace = card.base.value == "Ace"
		return not (face or ace) and card:get_id() <= 10 and card:get_id() > 0 and (card:get_id() % 2 == 0)
	end,
	"prime", prime = function(card)
		if SMODS.has_no_rank(card) then return false end
		local face = card:is_face()
		local ace = card.base.value == "Ace"
		return not (face) and (
			card:get_id() == 2 or
			card:get_id() == 3 or
			card:get_id() == 5 or
			card:get_id() == 7 or
			ace
		)
	end,
	"suitless", suitless = function(card)
		return SMODS.has_no_suit(card)
	end,
	"rankless", rankless = function(card)
		return SMODS.has_no_rank(card)
	end,
	"unenhanced", unenhanced = function(card)
		return card.config.center.set == "Default"
	end,
	"enhanced", enhanced = function(card)
		return card.config.center.set == "Enhanced"
	end,
	"metal", metal = function(card)
		local k = card.config.center_key
		return (
			k == "m_steel" or k == "m_gold" or
			--k == "m_ortalab_rusty" or
			k == "m_mf_brass" or
			k == "m_toga_iron" or k == "m_toga_silver" or
			k == "m_toga_electrum" or k == "m_toga_copper" or
			k == "m_toga_tin" or k == "m_toga_bronze" or
			k == "m_toga_osmium" or k == "m_toga_signalum" or
			k == "m_toga_nickel" or k == "m_toga_invar" or
			k == "m_toga_lumium" or k == "m_toga_refinedglowstone" or
			k == "m_kino_sci_fi" -- ??? like technically but...
		)
	end,
	"materialenh", materialenh = function(card)
		local k = card.config.center_key
		return (
			k == "m_glass" or k == "m_stone" or
			k == "m_steel" or k == "m_gold" or
			--k == "m_ortalab_rusty" or
			k == "m_poke_hazard" or
			k == "m_gb_cake" or
			k == "m_mf_brass" or k == "m_mf_teal" or
			k == "m_mf_gemstone" or k == "m_mf_marigold" or
			k == "m_crv_bulletproofglass" or k == "m_crv_diamondcard" or
			k == "m_crv_mega" or k == "m_crv_honey" or k == "m_crv_shattered" or
			k == "m_crv_dirt" or k == "m_crv_brightest" or k == "m_crv_darkest" or
			k == "m_vis_brick" or k == "m_vis_plastic" or
			k == "m_artb_marble" or k == "m_artb_pinata" or k == "m_artb_wood" or
			k == "m_toga_coalcoke" or k == "m_toga_redstone" or
			k == "m_toga_glowstone" or
			k == "m_toga_iron" or k == "m_toga_silver" or
			k == "m_toga_electrum" or k == "m_toga_copper" or
			k == "m_toga_tin" or k == "m_toga_bronze" or
			k == "m_toga_osmium" or k == "m_toga_signalum" or
			k == "m_toga_nickel" or k == "m_toga_invar" or
			k == "m_toga_lumium" or k == "m_toga_refinedglowstone" or
			k == "m_thac_bone" or k == "m_thac_jewel" or
			k == "m_cry_light" or
			k == "m_entr_flesh" or k == "m_entr_dark" or k == "m_entr_ceramic" or
			k == "m_akyrs_brick_card" or k == "m_akyrs_ash_card" or
			k == "m_akyrs_hatena" or k == "m_akyrs_item_box" or
			k == "m_akyrs_thai_tea_card" or k == "m_akyrs_matcha" or
			k == "m_akyrs_earl_grey_tea_card" or
			k == "m_payasaka_ice" or 
			k == "m_kino_sci_fi" or
			k == "m_valk_mirrored"
		)
	end,
	"unsealed", unsealed = function(card)
		return card:get_seal() == nil
	end,
	"sealed", sealed = function(card)
		return card:get_seal() ~= nil
	end,
	"baseedition", baseedition = function(card)
		return card.edition == nil
	end,
	"editioned", editioned = function(card)
		return card.edition ~= nil
	end,
}

retapi.has = function(card, quality)
	if qualities[quality] then
		return qualities[quality](card)
	end
end

retapi.random = function(pseed)
	local tab = {}
	for i,key in ipairs(qualities) do
		tab[#tab+1] = key
	end
	return pseudorandom_element(tab, pseed)
end

retapi.localize = function(quality, mode)
	local prefix = "cq_"
	if mode == 1 then
		prefix = "Cq_"
	end
	return localize(prefix..quality)
end

return retapi