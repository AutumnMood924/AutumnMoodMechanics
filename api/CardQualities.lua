local retapi = {}

local qualities = {
	"face", face = function(card)
		return card:is_face()
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
	"even", odd = function(card)
		if SMODS.has_no_rank(card) then return false end
		local face = card:is_face()
		local ace = card.base.value == "Ace"
		return not (face or ace) and card:get_id() <= 10 and card:get_id() > 0 and (card:get_id() % 2 == 0)
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
	"unsealed", sealed = function(card)
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