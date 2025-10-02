----------------------------------------------------------------
-----  ▄▄▄   ▄    ▄   ▄  ▄▄▄▄▄   ▄▄▄   ▄   ▄   ▄▄▄    ▄▄▄  -----
----- █   ▀  █    █▄▄▄█    █    █   ▀  █▄▄▄█  ▀  ▄█  █ ▄▄▀ -----
----- █  ▀█  █      █      █    █   ▄  █   █  ▄   █  █   █ -----
-----  ▀▀▀▀  ▀▀▀▀   ▀      ▀     ▀▀▀   ▀   ▀   ▀▀▀   ▀   ▀ -----
----------------------------------------------------------------
--                                                            --
--   Project Zomboid Modding Commissions                      --
--   https://steamcommunity.com/id/glytch3r/myworkshopfiles   --
--                                                            --
--   ▫ Discord  ꞉   glytch3r                                  --
--   ▫ Support  ꞉   https://ko-fi.com/glytch3r                --
--   ▫ Youtube  ꞉   https://www.youtube.com/@glytch3r         --
--   ▫ Github   ꞉   https://github.com/Glytch3r               --
--                                                            --
----------------------------------------------------------------
----- ▄   ▄   ▄▄▄   ▄   ▄   ▄▄▄     ▄      ▄   ▄▄▄▄  ▄▄▄▄  -----
----- █   █  █   ▀  █   █  ▀   █    █      █      █  █▄  █ -----
----- ▄▀▀ █  █▀  ▄  █▀▀▀█  ▄   █    █    █▀▀▀█    █  ▄   █ -----
-----  ▀▀▀    ▀▀▀   ▀   ▀   ▀▀▀   ▀▀▀▀▀  ▀   ▀    ▀   ▀▀▀  -----
----------------------------------------------------------------


ParasiteZed = ParasiteZed or {}

function ParasiteZed.getRewards(isQueen)
    local lootStr = ParasiteZed.getDeathRewards(isQueen)
    local parsedItems = ParasiteZed.parseItems(lootStr)
    local randomItem = nil
    local itemList = parsedItems
    if #itemList == 0 then return end
    if ParasiteZed.getRewardRoll(isQueen) then
        randomItem = itemList[ZombRand(1, #itemList + 1)]
        if randomItem then
            if getCore():getDebug() then
                print("Spawned: "..tostring(randomItem))
            end
        end
    end
    return randomItem
end



function ParasiteZed.getRewardRoll(isQueen)
    local chance = SandboxVars.ParasiteQueen.DropRate or 20
    if isQueen then
        chance = SandboxVars.ParasiteQueen.DropRateQueen or 30
    end
    if chance <= 0 then return false end
    if chance >= 100 then return true end
    return ParasiteZed.doRoll(chance)
end

function ParasiteZed.getDeathRewards(isQueen)
    local rewards = SandboxVars.ParasiteQueen.DeathRewards 
    if isQueen then
        rewards = SandboxVars.ParasiteQueen.DeathRewardsQueen
    end
    return rewards
end

function ParasiteZed.parseItems(lootStr)
    local tab = {}
    lootStr = lootStr or ParasiteZed.getDeathRewards()
    if not lootStr then return end
    if lootStr and lootStr ~= '' then
        for item in string.gmatch(lootStr, "([^;]+)") do
            table.insert(tab, item)
        end
    end
    return tab
end

ParasiteZed.materialDropTable = {
    [1] = "Base.ParasiteZed_Exosac",
    [2] = "Base.ParasiteZed_Raptorial",
    [3] = "Base.ParasiteZed_HeadCapsule",
    [4] = "Base.ParasiteZed_HindLimb",
    [5] = "Base.ParasiteZed_DorsalVessel",
    [6] = "Base.ParasiteZed_Mandibles",
    [7] = "Base.ParasiteZed_Aculeus",
    [8] = "Base.ParasiteZed_Metasoma",
}

function ParasiteZed.getMaterialDrop()
    if not ParasiteZed.doRoll(10) then return nil end
    local roll = ZombRand(1, 9)
    local mat = ParasiteZed.materialDropTable[roll]

    if getCore():getDebug() then
        getPlayer():addLineChatElement("Rolled: [" .. tostring(roll) .. "] " .. tostring(mat or "None"))
    end

    return mat
end
--[[
function ParasiteZed.doDropMaterial(sq)
    sq = sq or  getPlayer():getSquare()
    if not sq then return end
    local roll = ZombRand(1, 9)
    local mat = ParasiteZed.getMaterialDrop()
    if mat then
        sq:AddWorldInventoryItem(mat, 0, 0, 0)
        ISInventoryPage.dirtyUI()
    end
end
 ]]
ParasiteZed.LearnTable = {
    ["Craft Parasite Armor"] = SandboxVars.ParasiteQueen.KillsToLearnCraftDummy or 100,
    ["Craft Parasite Spear"] = SandboxVars.ParasiteQueen.KillsToLearnCraftSword or 85,
    ["Craft Parasite Sword"] = SandboxVars.ParasiteQueen.KillsToLearnCraftArmor or 70,
    ["Preserved Parasite Egg"] = SandboxVars.ParasiteQueen.KillsToLearnCraftSpear or 60,
    ["Craft Parasite Head Trophy"] = SandboxVars.ParasiteQueen.KillsToLearnCraftEgg or 50,
    ["Craft Parasite Mask"] = SandboxVars.ParasiteQueen.KillsToLearnCraftMask or 40,
    ["Construct Parasite Dummy"] = SandboxVars.ParasiteQueen.KillsToLearnCraftTrophy or 30,
    ["Paint Parasite Anatomy"] = SandboxVars.ParasiteQueen.KillsToLearnCraftAnatomy or 20,
    ["Synthesize Anti Parasitic Medication"] = SandboxVars.ParasiteQueen.KillsToLearnAntiParasitic or 200,
    ["Craft Pesticide Bomb"] = SandboxVars.ParasiteQueen.KillsToLearnBugBomb or 110,
}

function ParasiteZed.RewardsHandler(zed)
    local pl = getPlayer()
    local sq = zed:getSquare()
    if not pl or not sq then return end
    local inv = zed:getInventory();
    local attacker = zed:getAttackedBy()
    if not attacker then return end
    local isQueen = ParasiteZed.isParasiteQueen(zed) 
    if isQueen and attacker == pl then 
        ParasiteZed.spawnParasitesOnCorpsesWithNest(zed)
        local loot =  ParasiteZed.getRewards()
        if loot then
            inv:AddItem(loot)
        end
         
    end
    if attacker == pl and ParasiteZed.isParasiteZed(zed)  then
        local mats = ParasiteZed.getMaterialDrop()

        local loot =  ParasiteZed.getRewards()
        if loot then
            inv:AddItem(loot)
        end
        if mats then
            inv:AddItem(mats)
        end   
    end
    local score
    local md = attacker:getModData()
    if not md then return end
    if isQueen then
        md.ParasiteZed_QueenKillCount = (md.ParasiteZed_QueenKillCount or 0) + 1
        score = md.ParasiteZed_QueenKillCount
    else
        md.ParasiteZed_KillCount = (md.ParasiteZed_KillCount or 0) + 1
        score = md.ParasiteZed_KillCount
    end

    
  
    if attacker == pl then
        for recipeStr, killReq in pairs(ParasiteZed.LearnTable) do
            if score >= killReq and not pl:isRecipeKnown(recipeStr) then
                ParasiteZed.LearnHandler(recipeStr, pl)
            end
        end

        if getCore():getDebug() then
            zed:addLineChatElement("Parasite kill count: " .. tostring(score))
            local user = attacker:getUsername()
            if user then
                zed:addLineChatElement("Attacker: " .. tostring(user))
            end
            print("KillCount: " .. tostring(score))
        end
    end
end

Events.OnZombieDead.Add(ParasiteZed.RewardsHandler)

function ParasiteZed.spawnParasitesOnCorpsesWithNest(source)
    if forageSystem.getTimeOfDay() == 'isDay' then return end
    local rad = 30
    if RainManager.isRaining() then rad = 60 end
    local cell = getCell()
    local totalToSpawn = 0
    local x, y, z = source:getX(), source:getY(), 0
    local corpseSquares = {}

    for xDelta = -rad, rad do
        for yDelta = -rad, rad do
            local sq = cell:getOrCreateGridSquare(x + xDelta, y + yDelta, z)
            local hasNest = false
            for i = 0, sq:getObjects():size() - 1 do
                local obj = sq:getObjects():get(i)
                local sprName = ParasiteZed.getSprName(obj)
                if sprName and ParasiteZed.isSpawnerNest(sprName) then
                    hasNest = true
                    break
                end
            end
            if hasNest then
                for i = 0, sq:getObjects():size() - 1 do
                    local obj = sq:getObjects():get(i)
                    if instanceof(obj, "IsoDeadBody") and not obj:isRemoved() then
                        table.insert(corpseSquares, sq)
                        totalToSpawn = totalToSpawn + 1
                    end
                end
            end
        end
    end

    if totalToSpawn >= 10 then
        for i = 1, #corpseSquares do
            ParasiteZed.doSpawn(corpseSquares[i], false, "ParasiteZed")
        end
    end
end

function ParasiteZed.spawnAtAllNests(source, rad)
    local nests = ParasiteZed.getNests(source, rad)
    for i = 1, #nests do
        local sq = nests[i]:getSquare()
        if sq then
            ParasiteZed.doSpawn(sq, false, "ParasiteZed")
        end
    end
end

function ParasiteZed.LearnHandler(recipeStr, pl)
    pl = pl or getPlayer()
    pl:getKnownRecipes():add(recipeStr)
    getSoundManager():playUISound("GainExperienceLevel")
    pl:addLineChatElement("Learned: " .. recipeStr)
end
