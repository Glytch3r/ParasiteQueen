ParasiteZed = ParasiteZed or {}

function ParasiteZed.setQueenStats(zed)
    if zed then
        if zed:isReanimatedPlayer() then
            return
        end
        if  zed:getModData()['ParasiteZed_Init'] == nil then

            local sandOpt = getSandboxOptions()
           

            --sandOpt:set("ZombieLore.Speed", 1) 		-- 1 sprinters  		2 fast shamblers  	3 shamblers 		4 random
            sandOpt:set("ZombieLore.Strength",1)  	-- 1 superhuman 		2 normal 			3 weak 				4 random
            sandOpt:set("ZombieLore.Toughness",1)	-- 1 tough 				2 normal 			3 fragile 			4 random
            sandOpt:set("ZombieLore.Cognition",2) 	-- 1 navigate + doors 	2 navigate 			3 basic navigation 	4 random
            sandOpt:set("ZombieLore.Memory",1) 		 --1 long 				2 normal 			3 short				4 none 			5 random
            sandOpt:set("ZombieLore.Sight",1) 		-- 1 eagle 				2 normal 			3 poor 				4 random
            sandOpt:set("ZombieLore.Hearing",1) 	-- 1 pinpoint 			2 normal 			3 poor 				4 random
            --ParasiteZed.setTurnSpeed(zed, 2)
            zed:makeInactive(true);
            zed:makeInactive(false);
            --ParasiteZed.setCrawler(zed)
            --zed:dressInPersistentOutfit("ParasiteZed")
      
            ParasiteZed.setCrawler(zed)
            ParasiteZed.cleanUp(zed)

            zed:setTurnDelta(4)
            zed:getModData()['ParasiteZed_Init'] = true
            zed:resetModelNextFrame()

        end
    end
end

function ParasiteZed.isShouldIgnore(zed)
    if not zed or not ParasiteZed.isParasiteQueen(zed) then return false end
    local targ = zed:getTarget()
    return targ and instanceof(targ, "IsoPlayer")
end

function ParasiteZed.CallToArms(pl)
    local rad = 30
    local cell = getCell()
    local sqX, sqY, sqZ = pl:getX(), pl:getY(), pl:getZ()
    local zeds = cell:getZombieList()
    for i = 0, zeds:size() - 1 do
        local zed = zeds:get(i)
        if zed and  ParasiteZed.isParasiteZed(zed)  and not zed:isDead() then
            local dx = zed:getX() - sqX
            local dy = zed:getY() - sqY
            if dx * dx + dy * dy <= rad * rad then
                ParasiteZed.setScent(zed)
                zed:setTarget(pl)
            end
        end
    end
end
function ParasiteZed.getNearbySoldierCount(sq)
    local rad = 20
    local cell = getCell()
    local zeds = cell:getZombieList()
    local count = 0
    for i = 0, zeds:size() - 1 do
        local soldier = zeds:get(i)
        if soldier and ParasiteZed.isParasiteZed(soldier) and not soldier:isDead() then
            if  sq:DistTo(soldier) <= rad then
                count = count + 1
            end
        end
    end
    return count
end
function ParasiteZed.isInSpitRange(zed, targ)
    if not zed then return false end
    targ = targ or zed:getTarget()
    if not targ then return false end
    local dist = zed:DistTo(targ)
    if getCore():getDebug() then  
        zed:addLineChatElement(tostring("TARGET IN RANGE"))
    end
    return dist >= 8 and dist <= 15 and zed:isFacingTarget() and zed:isTargetVisible()
end
function ParasiteZed.isOutOfRangeClose(zed, targ)
    if not zed then return false end
    targ = targ or zed:getTarget()
    if not targ then return false end
    return zed:DistTo(targ) < 8
end

function ParasiteZed.isOutOfRangeFar(zed, targ)
    if not zed then return false end
    targ = targ or zed:getTarget()
    if not targ then return false end
    return zed:DistTo(targ) > 15
end
--[[ 
function ParasiteZed.getQueenAct(zed, targ)
    if not zed then return nil end
    targ = targ or zed:getTarget()
    local dist = targ and zed:DistTo(targ) or math.huge
    local facing = targ and zed:isFacingTarget() or false
    local gotHit = zed:getHitTime() <= 2
    --local soldiersCount = ParasiteZed.getNearbySoldierCount(zed)
    local curAct = zed:getVariableString("QueenBehavior")
    if targ then
        if not facing and seeTarg then 
            zed:faceLocation(targ:getX(), targ:getY())                
        end
        if ParasiteZed.isInSpitRange(zed, targ) and seeTarg then       
            if (not curAct or curAct ~= "doSpit") then
                zed:setUseless(true)
                return "doSpit"
            end
        elseif ParasiteZed.isOutOfRangeClose(zed, targ) and seeTarg then
            if (not curAct or curAct ~= "doBash") then
                return "doBash"
            end
        elseif ParasiteZed.isOutOfRangeFar(zed, targ) and seeTarg then            
            return "doEgg"
        end
        if (not curAct or curAct ~= "doGas") and zed:isBeingSteppedOn() then
            return "doGas"
        end
    else    
        return "doEgg"
    end    
end
 ]]
function ParasiteZed.queen(zed)
    if not zed then return end
    local isQueen = ParasiteZed.isParasiteQueen(zed)
    if isQueen then
        if zed:getModData()['ParasiteZed_Init'] == nil then
            ParasiteZed.setQueenStats(zed)
        end
        if not zed:getVariableBoolean('isParasiteQueen') then
            zed:setVariable('isParasiteQueen', 'true')
        end
        if not ParasiteZed.isCrawler(zed) then
            ParasiteZed.setCrawler(zed)
        end        
    end
end
Events.OnZombieUpdate.Remove(ParasiteZed.queen)
Events.OnZombieUpdate.Add(ParasiteZed.queen)

function ParasiteZed.behavior(zed)
    if not zed then return end
    local isQueen = ParasiteZed.isParasiteQueen(zed)
    if isQueen then
        local sq = zed:getSquare() 
        if  zed:isBeingSteppedOn() then
            zed:getModData()['ParasiteZed_Gas'] = nil
            zed:getModData()['ParasiteZed_Spit'] = nil
            ParasiteZed.doGasTrigger(zed)
        else
            local targ = zed:getTarget()
            if targ == nil then
                ParasiteZed.huntCorpse(zed)
                zed:getModData()['ParasiteZed_Gas'] = nil
                zed:getModData()['ParasiteZed_Spit'] = nil
            elseif targ then
                if not sq then return end
                local cd = SandboxVars.ParasiteQueen.spitCooldown or 5
                if cd > 0 then  
                    if zed:getModData()['ParasiteZed_Spit'] == nil then
                        if ParasiteZed.isInSpitRange(zed, targ) and targ:getZ() == zed:getZ() then   
                            local facing = zed:isFacingTarget() or false
                            if facing then
                                zed:setUseless(true)
                                zed:getModData()['ParasiteZed_Spit'] = true
                                getSoundManager():PlayWorldSound('ParasiteZed_LaunchSpit', sq, 0, 5, 5, false)
                                local dur =  SandboxVars.ParasiteQueen.spitDuration or 3000
                                ParasiteZed.doSpit(zed:getX(), zed:getY(), targ:getX(), targ:getY(), targ:getZ(), dur, 0.7)
                                timer:Simple(cd, function() 
                                    if zed then                        
                                        zed:getModData()['ParasiteZed_Spit'] = nil
                                        zed:setUseless(false)                            
                                    end
                                end)
                            else
                                zed:setUseless(false)    
                                zed:faceLocation(targ:getX(), targ:getY())     
                            end
                        end
                    else
                        zed:setUseless(false)    
                    end
                end
            end
        end
    end
end

Events.OnZombieUpdate.Remove(ParasiteZed.behavior)
Events.OnZombieUpdate.Add(ParasiteZed.behavior)


--[[ 
function ParasiteZed.collide(zed, pl)
    if ParasiteZed.isParasiteZed(zed) and pl == getPlayer() then
        if zed:getModData()['ParasiteZed_Gas'] == nil then
            ParasiteZed.doGasTrigger(zed)
        end
    end
end

Events.OnObjectCollide.Add(ParasiteZed.collide)

 ]]



--[[ 
function ParasiteZed.doQueenBehavior(zed, targ)
    if not zed then return end
    local sq = zed:getSquare()
    targ = targ or zed:getTarget()

    if not targ  then
        return
    end

    local act = ParasiteZed.getQueenAct(zed, targ)
    if act then
        zed:setVariable("QueenBehavior", act)
        if act ~= 'doWait' then
            sq = zed:getSquare()
            if act == 'doGas' then
                zed:setUseless(true)
                ParasiteZed.doGasTrigger(zed)
                getSoundManager():PlayWorldSound('ParasiteZed_LaunchSpit', sq, 0, 5, 5, false)
            elseif act == 'doSpit' and targ and targ:getZ() == zed:getZ() then
                getSoundManager():PlayWorldSound('ParasiteZed_LaunchSpit', sq, 0, 5, 5, false)
                zed:setUseless(true)
                ParasiteZed.doSpit(zed:getX(), zed:getY(), targ:getX(), targ:getY(), targ:getZ(), 1, 1)
    
            end
        end
    else
        zed:setUseless(false)
    end
end
 ]]
--[[ 
function ParasiteZed.spitAtFurtherSetClosest(zed)
    if not zed then return end
    local players = getOnlinePlayers()
    if not players or players:size() < 2 then return end
    local closest, second
    local dist1, dist2 = math.huge, math.huge
    for i = 0, players:size() - 1 do
        local pl = players:get(i)
        if pl and not pl:isDead() then
            local d = zed:DistTo(pl)
            if d < dist1 then
                second, dist2 = closest, dist1
                closest, dist1 = pl, d
            elseif d < dist2 then
                second, dist2 = pl, d
            end
        end
    end
    if closest and second then
        ParasiteZed.doSpit(zed:getX(), zed:getY(), second:getX(), second:getY(), second:getZ(), 1, 1)
        getSoundManager():PlayWorldSound('ParasiteZed_LaunchSpit', zed:getSqure(), 0, 5, 5, false);
        zed:setTarget(closest)
    end
end
 ]]
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
--[[ 

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
 ]]


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

function ParasiteZed.isFirearm(pl, wpn)
	if not wpn then return false end
	if wpn:isAimedFirearm() then return true end
	if wpn:getCategories():contains("Unarmed") then return false end
	return wpn:getScriptItem() and wpn:getScriptItem():isRanged()
end

function ParasiteZed.hitQueenZed(zed, pl, part, wpn)
	if ParasiteZed.isParasiteQueen(zed) then
        zed:setAvoidDamage(true)

        local hp = zed:getHealth()
        if hp then
            local healthDmg = 0.02
            if wpn:isAimedFirearm() then
                healthDmg = 0.01
            end
            zed:setHealth(hp - healthDmg)
            --   print(zed:getHealth())
        end
        
        zed:setVariable("hitreaction", "hurt")
        zed:update()
    

	end
end
Events.OnHitZombie.Remove(ParasiteZed.hitQueenZed)
Events.OnHitZombie.Add(ParasiteZed.hitQueenZed)


