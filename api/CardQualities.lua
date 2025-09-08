local retapi = {}

-- create functions should apply NO additional parameters to created cards
-- in cases where the parameter is vague and based on other parameters:
--  prioritize "special" effects that satisfy the parameter,
--  then suit/rank that satisfy the parameter,
--  then enhancement that satisfy the parameter,
--  then other things

-- if a card quality is reflected by any regular playing card,
-- it can omit a create function entirely and the created playing card will be
-- a base playing card with no special parameters
local default_create_key = "amm_cardquality_create"

local is_prime = function(number)
	return number == 2 or number == 3 or number == 5 or number == 7 or number == 11 or number == 13 or number == 17 or number == 19 or number == 23 or number == 29 or number == 31 or number == 37 or number == 41 or number == 43 or number == 47 or number == 53 or number == 61 or number == 67 or number == 71 or number == 73 or number == 79 or number == 83 or number == 89 or number == 97 or number == 101 or number == 103 or number == 107 or number == 109 or number == 113 or number == 127 or number == 131 or number == 137 or number == 139 or number == 149 or number == 151 or number == 157 or number == 163 or number == 167 or number == 173 or number == 179 or number == 181 or number == 191 or number == 193 or number == 197 or number == 199 or number == 211 or number == 223 or number == 227 or number == 229 or number == 233 or number == 239 or number == 241 or number == 251 or number == 257 or number == 263 or number == 269 or number == 271 or number == 277 or number == 281
end

local rocks = {
	"m_stone"
}

local metals = {
	"m_steel", "m_gold"
}

local materials = {
	"m_glass", "m_stone", "m_steel", "m_gold"
}

if next(SMODS.find_mod("aikoyorisshenanigans")) then
	rocks[#rocks+1] = "m_akyrs_brick_card"
	materials[#materials+1] = "m_akyrs_brick_card"
	materials[#materials+1] = "m_akyrs_ash_card"
	materials[#materials+1] = "m_akyrs_hatena"
	materials[#materials+1] = "m_akyrs_item_box"
	materials[#materials+1] = "m_akyrs_thai_tea_card"
	materials[#materials+1] = "m_akyrs_matcha"
	materials[#materials+1] = "m_akyrs_earl_grey_tea_card"
end

if next(SMODS.find_mod("artbox")) then
	rocks[#rocks+1] = "m_artb_marble"
	materials[#materials+1] = "m_artb_marble"
	materials[#materials+1] = "m_artb_pinata"
	materials[#materials+1] = "m_artb_wood"
end

if next(SMODS.find_mod("Cryptid")) then
	materials[#materials+1] = "m_cry_light"
end

if next(SMODS.find_mod("entr")) then
	rocks[#rocks+1] = "m_entr_ceramic"
	materials[#materials+1] = "m_entr_flesh"
	materials[#materials+1] = "m_entr_dark"
	materials[#materials+1] = "m_entr_ceramic"
end

if next(SMODS.find_mod("GrabBag")) then
	metals[#metals+1] = "m_gb_alloyed"
	materials[#materials+1] = "m_gb_alloyed"
	--materials[#materials+1] = "m_gb_cake"
end

if next(SMODS.find_mod("kino")) then
	metals[#metals+1] = "m_kino_sci_fi"
	materials[#materials+1] = "m_kino_crime"
	materials[#materials+1] = "m_kino_demonic"
	materials[#materials+1] = "m_kino_sci_fi"
	--materials[#materials+1] = "m_kino_horror"
	--materials[#materials+1] = "m_kino_monster"
	if next(SMODS.find_mod("MoreFluff")) then
		--materials[#materials+1] = "m_kino_error"
		--rocks[#rocks+1] = "m_kino_time"
		materials[#materials+1] = "m_kino_time"
	end
end

if next(SMODS.find_mod("LuckyRabbit")) then
	materials[#materials+1] = "m_fmod_raffle_card"
end

if next(SMODS.find_mod("MoreFluff")) then
	rocks[#rocks+1] = "m_mf_gemstone"
	metals[#metals+1] = "m_mf_brass"
	materials[#materials+1] = "m_mf_brass"
	materials[#materials+1] = "m_mf_teal"
	materials[#materials+1] = "m_mf_gemstone"
	materials[#materials+1] = "m_mf_marigold"
end

if next(SMODS.find_mod("ortalab")) then
	rocks[#rocks+1] = "m_ortalab_ore"
	metals[#metals+1] = "m_ortalab_rusty"
	materials[#materials+1] = "m_ortalab_rusty"
	materials[#materials+1] = "m_ortalab_sand"
	materials[#materials+1] = "m_ortalab_index"
	materials[#materials+1] = "m_ortalab_ore"
	materials[#materials+1] = "m_ortalab_recycled"
end

if next(SMODS.find_mod("paperback")) then
	rocks[#rocks+1] = "m_paperback_ceramic"
	materials[#materials+1] = "m_paperback_wrapped"
	materials[#materials+1] = "m_paperback_ceramic"
end

if next(SMODS.find_mod("pta_saka")) then
	materials[#materials+1] = "m_payasaka_ice"
end

if next(SMODS.find_mod("Pokermon")) then
	rocks[#rocks+1] = "m_poke_hazard"
	metals[#metals+1] = "m_poke_hazard"
	materials[#materials+1] = "m_poke_hazard"
end

if next(SMODS.find_mod("RevosVault")) then
	metals[#metals+1] = "m_crv_mega"
	rocks[#rocks+1] = "m_crv_diamondcard"
	materials[#materials+1] = "m_crv_bulletproofglass"
	materials[#materials+1] = "m_crv_diamondcard"
	materials[#materials+1] = "m_crv_mega"
	materials[#materials+1] = "m_crv_honey"
	materials[#materials+1] = "m_crv_shattered"
	materials[#materials+1] = "m_crv_dirt"
	if next(SMODS.find_mod("entr")) then
		materials[#materials+1] = "m_crv_brightest"
		materials[#materials+1] = "m_crv_darkest"
	end
end

if next(SMODS.find_mod("TheAutumnCircus")) then
	rocks[#rocks+1] = "m_thac_jewel"
	materials[#materials+1] = "m_thac_bone"
	materials[#materials+1] = "m_thac_jewel"
end

if next(SMODS.find_mod("TOGAPack")) then
	rocks[#rocks+1] = "m_toga_coalcoke"
	metals[#metals+1] = "m_toga_iron"
	metals[#metals+1] = "m_toga_silver"
	metals[#metals+1] = "m_toga_electrum"
	metals[#metals+1] = "m_toga_copper"
	metals[#metals+1] = "m_toga_tin"
	metals[#metals+1] = "m_toga_bronze"
	metals[#metals+1] = "m_toga_osmium"
	metals[#metals+1] = "m_toga_signalum"
	metals[#metals+1] = "m_toga_nickel"
	metals[#metals+1] = "m_toga_invar"
	metals[#metals+1] = "m_toga_lumium"
	metals[#metals+1] = "m_toga_refinedglowstone"
	materials[#materials+1] = "m_toga_notification"
	materials[#materials+1] = "m_toga_sms"
	materials[#materials+1] = "m_toga_coalcoke"
	materials[#materials+1] = "m_toga_redstone"
	materials[#materials+1] = "m_toga_glowstone"
	materials[#materials+1] = "m_toga_iron"
	materials[#materials+1] = "m_toga_silver"
	materials[#materials+1] = "m_toga_electrum"
	materials[#materials+1] = "m_toga_copper"
	materials[#materials+1] = "m_toga_tin"
	materials[#materials+1] = "m_toga_bronze"
	materials[#materials+1] = "m_toga_osmium"
	materials[#materials+1] = "m_toga_signalum"
	materials[#materials+1] = "m_toga_nickel"
	materials[#materials+1] = "m_toga_invar"
	materials[#materials+1] = "m_toga_lumium"
	materials[#materials+1] = "m_toga_refinedglowstone"
end

if next(SMODS.find_mod("valkarri")) then
	materials[#materials+1] = "m_valk_mirrored"
end

if next(SMODS.find_mod("VISIBILITY")) then
	rocks[#rocks+1] = "m_vis_brick"
	materials[#materials+1] = "m_vis_brick"
	materials[#materials+1] = "m_vis_notebook"
	materials[#materials+1] = "m_vis_plastic"
end

if next(SMODS.find_mod("zeroError")) then
	metals[#metals+1] = "m_zero_sunsteel"
	materials[#materials+1] = "m_zero_sunsteel"
end

AMM.qualities = {
	"face", face = {
		has = function(card)
			return card:is_face()
		end,
		value_mod = function(value)
			return value * 0.9
		end,
		create = function(area, pseed)
			local ranks = {}
			for _,k in ipairs(SMODS.Rank.obj_buffer) do
				local v = SMODS.Ranks[k]
				if type(v.in_pool) ~= "function" or v:in_pool() then
					if v.face then
						ranks[#ranks+1] = k
					end
				end
			end
			return {
				rank = pseudorandom_element(ranks, pseed),
			}
		end,
	},
	"nonface", nonface = {
		has = function(card)
			return not card:is_face()
		end,
		value_mod = function(value)
			return value ^ 0.9
		end,
		create = function(area, pseed)
			local ranks = {}
			for _,k in ipairs(SMODS.Rank.obj_buffer) do
				local v = SMODS.Ranks[k]
				if type(v.in_pool) ~= "function" or v:in_pool() then
					if not v.face then
						ranks[#ranks+1] = k
					end
				end
			end
			return {
				rank = pseudorandom_element(ranks, pseed),
			}
		end,
	},
	"numbered", numbered = {
		has = function(card)
			if SMODS.has_no_rank(card) then return false end
			local face = card:is_face()
			local ace = card.base.value == "Ace"
			return not (face or ace)
		end,
		value_mod = function(value)
			return (value - (math.min(value/2,1))) * 0.85
		end,
		create = function(area, pseed)
			local ranks = {}
			for _,k in ipairs(SMODS.Rank.obj_buffer) do
				local v = SMODS.Ranks[k]
				if type(v.in_pool) ~= "function" or v:in_pool() then
					if k ~= "Ace" and not v.face then
						ranks[#ranks+1] = k
					end
				end
			end
			return {
				rank = pseudorandom_element(ranks, pseed),
			}
		end,
	},
	"odd", odd = {
		has = function(card)
			if SMODS.has_no_rank(card) then return false end
			local face = card:is_face()
			local ace = card.base.value == "Ace"
			return ace or (not (face) and card:get_id() <= 10 and card:get_id() > 0 and (card:get_id() % 2 == 1))
		end,
		value_mod = function(value)
			return (value - (math.min(value/2,1)))
		end,
		create = function(area, pseed)
			local ranks = {}
			for _,k in ipairs(SMODS.Rank.obj_buffer) do
				local v = SMODS.Ranks[k]
				if type(v.in_pool) ~= "function" or v:in_pool() then
					if not v.face and v.nominal%2==1 then
						ranks[#ranks+1] = k
					end
				end
			end
			return {
				rank = pseudorandom_element(ranks, pseed),
			}
		end,
	},
	"even", even = {
		has = function(card)
			if SMODS.has_no_rank(card) then return false end
			local face = card:is_face()
			local ace = card.base.value == "Ace"
			return not (face or ace) and card:get_id() <= 10 and card:get_id() > 0 and (card:get_id() % 2 == 0)
		end,
		value_mod = function(value)
			return (value - (math.min(value/2,1)))
		end,
		create = function(area, pseed)
			local ranks = {}
			for _,k in ipairs(SMODS.Rank.obj_buffer) do
				local v = SMODS.Ranks[k]
				if type(v.in_pool) ~= "function" or v:in_pool() then
					if not v.face and v.nominal%2==0 then
						ranks[#ranks+1] = k
					end
				end
			end
			return {
				rank = pseudorandom_element(ranks, pseed),
			}
		end,
	},
	"prime", prime = {
		has = function(card)
			if SMODS.has_no_rank(card) then return false end
			local face = card:is_face()
			local ace = card.base.value == "Ace"
			return not (face) and (
				ace or is_prime(card:get_id())
			)
		end,
		value_mod = function(value)
			return (value - (math.min(value/2,1))) * 1.618
		end,
		create = function(area, pseed)
			local ranks = {}
			for _,k in ipairs(SMODS.Rank.obj_buffer) do
				local v = SMODS.Ranks[k]
				if type(v.in_pool) ~= "function" or v:in_pool() then
					if not v.face and (
						is_prime(v.nominal)
					) then
						ranks[#ranks+1] = k
					end
				end
			end
			return {
				rank = pseudorandom_element(ranks, pseed),
			}
		end,
	},
	"suitless", suitless = {
		has = function(card)
			return SMODS.has_no_suit(card)
		end,
		value_mod = function(value)
			return value * 1
		end,
		create = function(area, pseed)
			local suitlessmodes = {}
			
			if next(SMODS.find_mod("aikoyorisshenanigans")) then
				suitlessmodes[#suitlessmodes+1] = function()
					return {
						akyrs_special_card_type = "rank",
					}
				end
			end
			
			if #suitlessmodes == 0 then
				if next(SMODS.find_mod("pta_saka")) then
					suitlessmodes[#suitlessmodes+1] = function()
						return {
							suit = "payasaka_washed",
						}
					end
				end
				if next(SMODS.find_mod("entr")) then
					suitlessmodes[#suitlessmodes+1] = function()
						return {
							suit = "entr_nilsuit",
						}
					end
				end
			end
			
			if #suitlessmodes == 0 then
				suitlessmodes[#suitlessmodes+1] = function()
					local tableature = {}
					for k,v in ipairs(G.P_CENTER_POOLS.Enhanced) do
						if v.no_suit or v.key == "m_stone" then
							tableature[#tableature+1] = v.key
						end
					end
					return {
						key = pseudorandom_element(tableature, pseed),
						set = "Enhanced",
					}
				end
			end
			local ret = pseudorandom_element(suitlessmodes, pseed)
			return ret()
		end,
	},
	"rankless", rankless = {
		has = function(card)
			return SMODS.has_no_rank(card)
		end,
		value_mod = function(value)
			return value * 1
		end,
		create = function(area, pseed)
			local ranklessmodes = {}
			
			if next(SMODS.find_mod("aikoyorisshenanigans")) then
				ranklessmodes[#ranklessmodes+1] = function()
					return {
						akyrs_special_card_type = "suit",
					}
				end
			end
			
			if #ranklessmodes == 0 then
				if next(SMODS.find_mod("entr")) then
					ranklessmodes[#ranklessmodes+1] = function()
						return {
							rank = "entr_nilrank",
						}
					end
				end
			end
			
			if #ranklessmodes == 0 then
				ranklessmodes[#ranklessmodes+1] = function()
					local tableature = {}
					for k,v in ipairs(G.P_CENTER_POOLS.Enhanced) do
						if v.no_rank or v.key == "m_stone" then
							tableature[#tableature+1] = v.key
						end
					end
					return {
						key = pseudorandom_element(tableature, pseed),
						set = "Enhanced",
					}
				end
			end
			local ret = pseudorandom_element(ranklessmodes, pseed)
			return ret()
		end,
	},
	"unenhanced", unenhanced = {
		has = function(card)
			return card.config.center.set == "Default"
		end,
		value_mod = function(value)
			return value * 0.80
		end,
	},
	"enhanced", enhanced = {
		has = function(card)
			return card.config.center.set == "Enhanced"
		end,
		value_mod = function(value)
			return value * 1.25
		end,
		create = function(area, pseed)
			return {
				set = "Enhanced",
			}
		end,
	},
	"rock", rock = {
		has = function(card)
			local k = card.config.center_key
			for _, v in ipairs(rocks) do
				if k == v then return true end
			end
			return false
		end,
		value_mod = function(value)
			return (value + 1.5) * 0.70
		end,
		create = function(area, pseed)
			return {
				key = pseudorandom_element(rocks, pseed),
				set = "Enhanced",
			}
		end,
	},
	"metal", metal = {
		has = function(card)
			local k = card.config.center_key
			for _, v in ipairs(metals) do
				if k == v then return true end
			end
			return false
		end,
		value_mod = function(value)
			return (value + 0.5) ^ 1.11
		end,
		create = function(area, pseed)
			return {
				key = pseudorandom_element(metals, pseed),
				set = "Enhanced",
			}
		end,
	},
	"materialenh", materialenh = {
		has = function(card)
			local k = card.config.center_key
			for _, v in ipairs(materials) do
				if k == v then return true end
			end
			return false
		end,
		value_mod = function(value)
			return (value + 0.1) * 1.25
		end,
		create = function(area, pseed)
			return {
				key = pseudorandom_element(materials, pseed),
				set = "Enhanced",
			}
		end,
	},
	"nonmaterialenh", nonmaterialenh = {
		has = function(card)
			local k = card.config.center_key
			for _, v in ipairs(materials) do
				if k == v then return false end
			end
			return true
		end,
		value_mod = function(value)
			return (value + 0.5) ^ 0.89
		end,
		create = function(area, pseed)
			--todo do this better
			local nonmats = {}
			local function checker(k)
				for _, v in ipairs(materials) do
					if k == v then return false end
				end
				return true
			end
			for k,v in ipairs(G.P_CENTER_POOLS.Enhanced) do
				if checker(v.key) then nonmats[#nonmats+1] = v.key end
			end
			return {
				key = pseudorandom_element(nonmats, pseed),
				set = "Enhanced",
			}
		end,
	},
	"unsealed", unsealed = {
		has = function(card)
			return card:get_seal() == nil
		end,
		value_mod = function(value)
			return value ^ (value < 1 and (1/0.85) or 0.85)
		end,
	},
	"sealed", sealed = {
		has = function(card)
			return card:get_seal() ~= nil
		end,
		value_mod = function(value)
			return value ^ (value < 1 and (1/1.15) or 1.15)
		end,
		create = function(area, pseed)
			return {
				seal = SMODS.poll_seal({key = pseed, guaranteed = true}),
			}
		end,
	},
	"baseedition", baseedition = {
		has = function(card)
			return card.edition == nil
		end,
		value_mod = function(value)
			return value ^ (value < 1 and (1/0.75) or 0.75)
		end,
	},
	"editioned", editioned = {
		has = function(card)
			return card.edition ~= nil
		end,
		value_mod = function(value)
			return value ^ (value < 1 and (1/1.23) or 1.23)
		end,
		create = function(area, pseed)
			return {
				edition = poll_edition(pseed, nil, true, true, nil)
			}
		end,
	},
	"hexed", hexed = {
		has = function(card)
			return GB.get_hex(card) ~= nil
		end,
		value_mod = function(value)
			return (value / 1.3) ^ 1.3
		end,
		create = function(area, pseed)
			return {
				gb_hex = pseudorandom_element(GB.HEX_KEYS, pseed)
			}
		end,
		in_pool = function()
			return next(SMODS.find_mod("GrabBag"))
		end,
	},
	"unhexed", unhexed = {
		has = function(card)
			return GB.get_hex(card) == nil
		end,
		value_mod = function(value)
			return value * 0.90
		end,
		in_pool = function()
			return next(SMODS.find_mod("GrabBag"))
		end,
	},
	"clipped", clipped = {
		has = function(card)
			return PB_UTIL.has_paperclip(card)
		end,
		value_mod = function(value)
			return (value + 0.4) * 0.99
		end,
		create = function(area, pseed)
			return {
				paperback_clip = pseudorandom_element(PB_UTIL.ENABLED_PAPERCLIPS, pseed)
			}
		end,
		in_pool = function()
			return next(SMODS.find_mod("paperback"))
		end,
	},
	"unclipped", unclipped = {
		has = function(card)
			return not PB_UTIL.has_paperclip(card)
		end,
		value_mod = function(value)
			return math.max(0.01, (value/1.3)-2)
		end,
		in_pool = function()
			return next(SMODS.find_mod("paperback"))
		end,
	},
	"cursed", cursed = {
		has = function(card)
			return card.ability.curse
		end,
		value_mod = function(value)
			return (value ^ (value < 1 and (1/2) or 2)) * 0.75
		end,
		create = function(area, pseed)
			return {
				ortalab_curse = pseudorandom_element(Ortalab.Curse.obj_buffer, pseed)
			}
		end,
		in_pool = function()
			return next(SMODS.find_mod("ortalab"))
		end,
	},
	"uncursed", uncursed = {
		has = function(card)
			return not card.ability.curse
		end,
		value_mod = function(value)
			return (value ^ (value < 1 and (1/0.5) or 0.5)) * 1.3
		end,
		in_pool = function()
			return next(SMODS.find_mod("ortalab"))
		end,
	},
	"vowel", vowel = {
		has = function(card)
			local letters = card:get_letter_with_pretend()
			if type(letters) == "string" then
				letters = letters:upper()
				if letters == "A" or letters == "E" or letters == "I" or letters == "O" or letters == "U" or letters == "Y" then
					return true
				end
			end
		end,
		value_mod = function(value)
			return value ^ 1.02
		end,
		create = function(area, pseed)
			return {
				akyrs_letters = pseudorandom_element({
					"A", "E", "I", "O", "U", "Y",
					"a", "e", "i", "o", "u", "y"
				}, pseed)
			}
		end,
		in_pool = function()
			return next(SMODS.find_mod("aikoyorisshenanigans")) and G.GAME.akyrs_character_stickers_enabled
		end,
	},
	"consonant", consonant = {
		has = function(card)
			local letters = card:get_letter_with_pretend()
			if type(letters) == "string" then
				letters = letters:upper()
				if letters == "B" or letters == "C" or letters == "D" or
					letters == "F" or letters == "G" or letters == "H" or
					letters == "J" or letters == "K" or letters == "L" or
					letters == "M" or letters == "N" or letters == "P" or
					letters == "Q" or letters == "R" or letters == "S" or
					letters == "T" or letters == "V" or letters == "W" or
					letters == "X" or letters == "Y" or letters == "Z" then
					return true
				end
			end
		end,
		value_mod = function(value)
			return value ^ 0.98
		end,
		create = function(area, pseed)
			return {
				akyrs_letters = pseudorandom_element({
					"B", "C", "D", "F", "G", "H", "J", "K", "L", "M", "N",
					"P", "Q", "R", "S", "T", "V", "W", "X", "Y", "Z",
					"b", "c", "d", "f", "g", "h", "j", "k", "l", "m", "n",
					"p", "q", "r", "s", "t", "v", "w", "x", "y", "z"
				}, pseed)
			}
		end,
		in_pool = function()
			return next(SMODS.find_mod("aikoyorisshenanigans")) and G.GAME.akyrs_character_stickers_enabled
		end,
	},
}

retapi.has = function(card, quality)
	if AMM.qualities[quality] then
		return AMM.qualities[quality].has(card)
	end
end

retapi.random = function(pseed)
	local tab = {}
	for i,key in ipairs(AMM.qualities) do
		if type(AMM.qualities[key].in_pool) ~= "function" or AMM.qualities[key].in_pool() then
			tab[#tab+1] = key
		end
	end
	return pseudorandom_element(tab, pseed)
end

retapi.create = function(quality, amt, area, pseed)
	amt = amt or 1
	area = area or G.deck
	pseed = pseed or default_create_key
	
	local ret = {}
	if AMM.qualities[quality] then
		for i=1,amt do
			local struc = {}
			if type(AMM.qualities[quality].create) == "function" then
				-- "or struc" makes returning nil valid
				struc = AMM.qualities[quality].create(area, pseed) or struc
			end
			if not struc.set then struc.set = "Base" end
			if not struc.area then struc.area = area end
			
			local _card = SMODS.add_card(struc)
			if struc.akyrs_special_card_type then
				_card.ability.akyrs_special_card_type = struc.akyrs_special_card_type
			end
			if struc.akyrs_letters then
				_card:set_letters(struc.akyrs_letters)
			end
			if struc.gb_hex then
				GB.set_hex(_card, struc.gb_hex)
			end
			if struc.paperback_clip then
				PB_UTIL.set_paperclip(_card, string.sub(struc.paperback_clip, 1, #struc.paperback_clip - 5))
			end
			if struc.ortalab_curse then
				_card:set_curse(struc.ortalab_curse, true, true)
			end
			
			_card:set_sprites(_card.config.center, _card.config.card)
			ret[#ret+1] = _card--]]
		end
	end
	
	return #ret > 0 and ret or nil
end

retapi.localize = function(quality, mode)
	local prefix = "cq_"
	if mode == 1 then
		prefix = "Cq_"
	end
	return localize(prefix..quality)
end

return retapi