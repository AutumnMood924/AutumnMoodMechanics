local centerX, centerY = 0, 0 
local tracking = false          
local totalAngle = 0            
local prevAngle = nil           
local minRadius = 0.5            
local resetTime = 0.2
local countedTime = 0
local petTime = 0
local hoveredCard = nil

if not math.sign then
	function math.sign(num)
		if not num then return 0 end
		return (num > 0 and 1) or (num < 0 and -1) or 0
	end
end

local ref = Card.hover
function Card:hover()
    tracking = true
    hoveredCard = self
    local ret = ref(self)
    return ret
end

local ref = Card.stop_hover
function Card:stop_hover()
    if hoveredCard == self then
        tracking = false
        hoveredCard = nil
    end
    local ret = ref(self)
    return ret
end

local ref = love.update
function love.update(dt)
    ref(dt)
    countedTime = countedTime + dt
    if countedTime >= resetTime then
        local x, y = love.mouse.getPosition()
        countedTime = countedTime - resetTime
        centerX, centerY = x, y 
        prevAngle = nil
    end
    if tracking then
        petTime = petTime + dt
        local x, y = love.mouse.getPosition()
        centerX = centerX or x
        centerY = centerY or y
        local dx, dy = x - centerX, y - centerY
        local radius = math.sqrt(dx*dx + dy*dy)
        
        if radius >= minRadius then
            local angle = math.atan2(dy, dx) 
            
            if prevAngle then
                local diff = angle - prevAngle
                if diff > math.pi then
                    diff = diff - 2 * math.pi
                elseif diff < -math.pi then
                    diff = diff + 2 * math.pi
                end
                
                if math.sign(totalAngle) ~= math.sign(diff) and totalAngle ~= 0 and diff ~= 0 then --Moving to another direction? Resets.
                    petTime = 0
                    totalAngle = 0
                end
                totalAngle = totalAngle + diff
                
                if math.abs(totalAngle) >= 1.75 * math.pi then
					if (hoveredCard.area and not hoveredCard.area.config.collection or true) and (G.STATE == G.STATES.SELECTING_HAND or
						G.STATE == G.STATES.SHOP or
						G.STATE == G.STATES.ROUND_EVAL or
						G.STATE == G.STATES.BLIND_SELECT or
						G.STATE == G.STATES.TAROT_PACK or
						G.STATE == G.STATES.PLANET_PACK or
						G.STATE == G.STATES.SPECTRAL_PACK or
						G.STATE == G.STATES.BUFFOON_PACK or
						G.STATE == G.STATES.STANDARD_PACK or
						G.STATE == G.STATES.SMODS_BOOSTER_OPENED) then
						percent = (0.5 + (pseudorandom("funny_petting_sound")) + (0.5/petTime))/2
						local this_hoveredCard = hoveredCard
						--hoveredCard.no_ui = true
						this_hoveredCard:juice_up(0.1, 0.1)
						this_hoveredCard:stop_hover()
						SMODS.calculate_context({amm_pet_card = this_hoveredCard, amm_pet_time = petTime, amm_pet_direction = (totalAngle > 0 and "clockwise" or "counter-clockwise")})
						G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.1,func = function()
							local selected = G and G.CONTROLLER and
								(G.CONTROLLER.focused.target or G.CONTROLLER.hovering.target)
							selected:stop_hover()
							selected:hover()
							percent = 1
							return true end }))
					end
                    totalAngle = 0
                    petTime = 0
                end
            end
            
            prevAngle = angle
        else
            prevAngle = nil 
        end
    else
        totalAngle = 0
        petTime = 0
    end
end