ParasiteZed = ParasiteZed or {}

function ParasiteZed.getNearestQueenToMidpoint(x, y)
    local pl = getPlayer()
    x = x or math.floor(pl:getX())
    y = y or math.floor(pl:getY())

    ParasiteZed.getNestCellZeds(x, y)
    ParasiteZed.midSq = ParasiteZed.getNestCellMidSquare()

    local queens = ParasiteZed.queenList
    if not queens or #queens == 0 then return nil end
    if #queens == 1 then return queens[1] end

    local size = ParasiteZed.NestCellSize

    local cellX = math.floor(x / size)
    local cellY = math.floor(y / size)

    local midX = (cellX * size) + math.floor(size / 2)
    local midY = (cellY * size) + math.floor(size / 2)

    local function getDistSq(zed)
        local zx = math.floor(zed:getX())
        local zy = math.floor(zed:getY())
        return (zx - midX)^2 + (zy - midY)^2
    end

    local closest = queens[1]
    local closestDist = getDistSq(closest)

    for i = 2, #queens do
        local dist = getDistSq(queens[i])
        if dist < closestDist then
            closest = queens[i]
            closestDist = dist
        end
    end
    return closest
end

function ParasiteZed.setQueenStats(zed, force)
    if zed then
        if zed:isReanimatedPlayer() then
            return
        end
        if ParasiteZed.isParasiteQueen(zed) and (zed:getModData()['ParasiteZed_Queen_Init'] == nil or force) then
            local sandOpt = getSandboxOptions()
           

            --sandOpt:set("ZombieLore.Speed", 1) 		-- 1 sprinters  		2 fast shamblers  	3 shamblers 		4 random
            sandOpt:set("ZombieLore.Strength",1)  	-- 1 superhuman 		2 normal 			3 weak 				4 random
            sandOpt:set("ZombieLore.Toughness",1)	-- 1 tough 				2 normal 			3 fragile 			4 random
            sandOpt:set("ZombieLore.Cognition",2) 	-- 1 navigate + doors 	2 navigate 			3 basic navigation 	4 random
            sandOpt:set("ZombieLore.Memory",1) 		 --1 long 				2 normal 			3 short				4 none 			5 random
            sandOpt:set("ZombieLore.Sight",1) 		-- 1 eagle 				2 normal 			3 poor 				4 random
            sandOpt:set("ZombieLore.Hearing",1) 	-- 1 pinpoint 			2 normal 			3 poor 				4 random
            --ParasiteZed.setTurnSpeed(zed, 2)
            zed:setVariable('isParasiteQueen', 'true')
            zed:makeInactive(true);
            zed:makeInactive(false);
            zed:setUseless(true)
            --ParasiteZed.setCrawler(zed)
            --zed:dressInPersistentOutfit("ParasiteZed")
            ParasiteZed.cleanUp(zed)
            if not ParasiteZed.isCrawler(zed) then
                ParasiteZed.setCrawler(zed)
            end
            zed:setTurnDelta(1)
            zed:getModData()['ParasiteZed_Queen_Init'] = true

        end
    end
end
function ParasiteZed.isShouldIgnore(zed)
    if not ParasiteZed.nest then return false end
    if not zed or not ParasiteZed.isParasiteQueen(zed) then return false end
    local targ = zed:getTarget()
    return targ and instanceof(targ, "IsoPlayer")
end


function ParasiteZed.queen(zed)
	if not zed then return end

	local isQueen = ParasiteZed.isParasiteQueen(zed)
	local isNested = ParasiteZed.isNested(zed)

	if isQueen then
		if SandboxVars.ParasiteZed_Queen.AlertIndicator ~= false and isNested then
			zed:addLineChatElement("Nested")
		end

		if zed:getModData().ParasiteZed_Queen_Init == nil then
			ParasiteZed.setQueenStats(zed)
		end
		if not zed:getVariableBoolean("isParasiteQueen") then
			zed:setVariable("isParasiteQueen", true)
		end
		if not ParasiteZed.isCrawler(zed) then
			ParasiteZed.setCrawler(zed)
		end

		zed:setUseless(isNested)
		--ParasiteZed.doQueenBehavior(zed)

	else
		if zed:getVariableBoolean("isParasiteQueen") then
			zed:setVariable("isParasiteQueen", false)
			zed:getModData().ParasiteZed_Queen_Init = nil
		end
	end

	if not (isQueen and ParasiteZed.isParasiteZed(zed)) then
		if not zed:isCrawling() then
			ParasiteZed.doNearZedEffects(zed)
		end
	end
end

Events.OnZombieUpdate.Remove(ParasiteZed.queen)
Events.OnZombieUpdate.Add(ParasiteZed.queen)

--[[ function ParasiteZed.doQueenBehavior(zed)
	if tonumber(Calendar.SECOND) % 30 == 0 then
		local nestSq = ParasiteZed.getNest(zed)
		if nestSq then
			local isNested = zed:DistTo(nestSq:getX(), nestSq:getY()) <= 3
			if isNested then
				local targ = zed:getTarget()
				if targ then
					zed:faceLocation(targ:getX(), targ:getY())
				end
			else
				ParasiteZed.moveToXYZ(zed, nestSq:getX(), nestSq:getY(), 0)
			end
		end
	end
end ]]

function ParasiteZed.isNested(zed)
	local obj = ParasiteZed.getNest(zed)
	if obj == nil then
        ParasiteZed.nest = nil
        return false
    end
    return true
end

function ParasiteZed.doNearZedEffects(zed)
    if tonumber(os.time()) % 30 == 0 then
        local fit = zed:getOutfitName()
        if fit then
            local hasNest = ParasiteZed.isNested(zed, 3)
            local bool = not hasNest
            local hash = tostring(ParasiteZed.getOutfitHash(fit, bool))
            if zed:getVariableString("zombieWalkType") ~= hash then
                zed:setWalkType(hash)
            end
            zed:setVariable("Berserked", hasNest)

            ParasiteZed.setSmoke(zed, hasNest)
        end
    end
end



function ParasiteZed.isShouldBurn(zed)
	return zed:getVariableBoolean("Berserked")
end


function ParasiteZed.setSmoke(targ)
	local spr = targ:getAttachedAnimSprite()

	if not ParasiteZed.isShouldBurn(targ) then
		if spr and spr:size() > 0 then
			targ:RemoveAttachedAnims()
			targ:clearAttachedAnimSprite()
		end
		return
	end

	if spr and spr:size() > 0 then return end

	targ:AttachAnim("Smoke", "01", 5, 0.2, 0, 270, true, 0, false, 0, ColorInfo.new(0, 0.2, 0.2, 0.05))

	local newSpr = targ:getAttachedAnimSprite()
	if newSpr and newSpr:size() >= 2 then
		newSpr:get(0):setScale(1, 0.8)
		newSpr:get(1):setScale(0.8, 1)
	end
end






function ParasiteZed.getOutfitHash(fit, isDigitOnly)
    if not fit or type(fit) ~= "string" then return 1 end
    local hash = 0
    for i = 1, #fit do
        hash = hash + string.byte(fit, i)
    end
    local hashRes = (hash % 5) + 1
    if isDigitOnly then
      return hashRes
    end
    local str = "sprint"..tostring(hashRes)
    return str
end

--[[

function ParasiteZed.registerQueenCandidate(zed)
    if not ParasiteZed.QueenZed or not ParasiteZed.QueenZed:isAlive() then
        ParasiteZed.QueenZed = zed
        ParasiteZed.setQueenStats(zed)
    elseif ParasiteZed.QueenZed ~= zed then
        ParasiteZed.doDespawn(zed)
    end
end
 ]]
function ParasiteZed.isCanTrigger()
    local trigger = false
    if tonumber(Calendar.SECOND) %  10 == 0 then
   -- if tonumber(getGameTime():getWorldAgeSeconds()) % 10 == 0 then
        trigger = true
    end
    return trigger
end


--[[
function ParasiteZed.hitQueen(zed, pl, bodyPart, wpn)
    if pl ~= getPlayer() then return end
    if not ParasiteZed.isParasiteQueen(zed) then return end

    local toAvoid = false

    if ParasiteZed.nest ~= nil then
        toAvoid = true
        local targ = zed:getTarget()
        if targ and targ == getPlayer() then
            if ParasiteZed.doRoll(8) then
                local sq = zed:getSquare()
        		local midSq = ParasiteZed.getNestCellMidSquare()
                ParasiteZed.doSpawn(midSq, false, "ParasiteZed")

            end
        end
    end


    if ParasiteZed.isFirearm(pl, wpn) then
        toAvoid = true
    end

    if toAvoid ~= zed:avoidDamage() then
        zed:setAvoidDamage(toAvoid)
    end
end

Events.OnHitZombie.Remove(ParasiteZed.hitQueen)
Events.OnHitZombie.Add(ParasiteZed.hitQueen) ]]

function ParasiteZed.isFirearm(pl, wpn)
	if not wpn then return false end
	if wpn:isAimedFirearm() then return true end
	if wpn:getCategories():contains("Unarmed") then return false end
	return wpn:getScriptItem() and wpn:getScriptItem():isRanged()
end

function ParasiteZed.hitQueenZed(zed, pl, part, wpn)
	if ParasiteZed.isParasiteQueen(zed) then
        zed:setAvoidDamage(true)
        local isNested = ParasiteZed.isNested(zed)

        if isNested then
            local targ = zed:getTarget()
            if targ and targ == getPlayer() then
                if ParasiteZed.doRoll(8) then
                    local sq = zed:getSquare()
                    local midSq = ParasiteZed.getNestCellMidSquare()
                    ParasiteZed.doSpawn(midSq, false, "ParasiteZed")
                end
            end
        else
            if not  ParasiteZed.isFirearm(pl, wpn) then
                local hp = zed:getHealth()
                if hp then
                    if isDebugEnabled() then
                        zed:SayDebug(tostring(hp))
                        print(tostring(hp))
                    end
                    if hp < 0.15 then
                        zed:setAvoidDamage(false)
                        zed:setImmortalTutorialZombie(false)
                    end
                end
                local healthDmg = 0.05

                zed:setHealth(zed:getHealth() - healthDmg)
                zed:setVariable("hitreaction")
                zed:update()
            end
        end
	end
end
Events.OnHitZombie.Remove(ParasiteZed.hitQueenZed)
Events.OnHitZombie.Add(ParasiteZed.hitQueenZed)