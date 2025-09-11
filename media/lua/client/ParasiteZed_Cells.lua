--[[ ParasiteZed = ParasiteZed or {}
require "lua_timers"

-----------------------            ---------------------------
LuaEventManager.AddEvent("OnNestCellChange")

 function ParasiteZed.reCell()
    ParasiteZed.parasiteList = {}
    ParasiteZed.queenList = {}
    --ParasiteZed.QueenZed = nil
    ParasiteZed.nest = nil
    ParasiteZed.nestSq = nil
end
function ParasiteZed.fetchZedLists()
    ParasiteZed.reCell()
    ParasiteZed.getNestCellZeds(x, y)
    ParasiteZed.getParasiteCount()
    ParasiteZed.getQueenCount()
    ParasiteZed.QueenZed = ParasiteZed.getNearestQueenToMidpoint()
    ParasiteZed.carHandler()
end
Events.OnCreatePlayer.Add(function()
    ParasiteZed.NestCellSize = 189
    ParasiteZed.fetchZedLists()
    ParasiteZed.NestCellEdgeMarkers = {}
    ParasiteZed.isWIP = false
end)

-----------------------   nestcell*   nest*  data*    ---------------------------


 function ParasiteZed.getNestCellData(str, x, y)
    local pl = getPlayer()
    if not pl then return end
    local size = ParasiteZed.NestCellSize
    x = x or math.floor(pl:getX() + 0.5)
    y = y or math.floor(pl:getY() + 0.5)
    local cellX = math.floor(x / size)
    local cellY = math.floor(y / size)
    local startX, startY = cellX * size, cellY * size
    local midX, midY = startX + math.floor(size / 2), startY + math.floor(size / 2)

    local key = str and string.lower(str)
    if key == "x" then return startX + size end
    if key == "y" then return startY + size end
    if key == "mid" then return {x = midX, y = midY} end
    if key == "midx" then return midX end
    if key == "midy" then return midY end
    if key == "sq" then return getCell():getOrCreateGridSquare(midX, midY, 0) end
    --if key == "name" then return string.format("%d:%d", startX + size, startY + size) end
    if key == "name" then return string.format("NestCell [%d,%d]", cellX, cellY) end


    if key == "dist" then return pl:DistToSquared(midX, midY) end
    return {x = startX + size, y = startY + size}
end

-----------------------            ---------------------------

function ParasiteZed.getCurrentNestCellX(pl)
    pl = pl or getPlayer()
    return math.floor(pl:getX() / ParasiteZed.NestCellSize)
end

function ParasiteZed.getCurrentNestCellY(pl)
    pl = pl or getPlayer()
    return math.floor(pl:getY() / ParasiteZed.NestCellSize)
end
function ParasiteZed.OnNestCellChangeEvent(pl)
    pl = pl or getPlayer()
    local currentCellX = ParasiteZed.getCurrentNestCellX(pl)
    local currentCellY = ParasiteZed.getCurrentNestCellY(pl)

    ParasiteZed.PreviousNestCell = ParasiteZed.PreviousNestCell or {x = currentCellX, y = currentCellY}


    if ParasiteZed.PreviousNestCell.x ~= currentCellX or ParasiteZed.PreviousNestCell.y ~= currentCellY then
        triggerEvent("OnNestCellChange", ParasiteZed.PreviousNestCell.x,  ParasiteZed.PreviousNestCell.y, currentCellX, currentCellY)
        ParasiteZed.PreviousNestCell.x, ParasiteZed.PreviousNestCell.y = currentCellX, currentCellY
    end
end
Events.OnPlayerMove.Add(ParasiteZed.OnNestCellChangeEvent)


function ParasiteZed.core(prevX, prevY, curX, curY)
    local pl = getPlayer()
    local x, y = round(pl:getX()), round(pl:getY())


    ParasiteZed.fetchZedLists()
    ParasiteZed.delGuide()
    Events.OnTick.Remove(ParasiteZed.guideHandler)
    ParasiteZed.plSync()

    local prevNestCellName = ParasiteZed.getNestCellName(prevX, prevY)
    local curNestCellName = ParasiteZed.getNestCellName(x, y)

    local curMidX = ParasiteZed.getNestCellData("midX", x, y)
    local curMidY = ParasiteZed.getNestCellData("midY", x, y)

    local msg = tostring(curNestCellName)
    if ParasiteZed.isWIP then
        ParasiteZed.setMarkersToNestCellEdge(false)
        ParasiteZed.setMarkersToNestCellEdge(true)

        timer:Simple(15, function()
            ParasiteZed.setMarkersToNestCellEdge(false)
        end)

    end

    if msg and msg ~= "" then
        if ParasiteZed.isWIP then
            print(msg)
            pl:setHaloNote(tostring(msg),150,250,150,900)
        end
        if ISChat and ISChat.instance then
            ISChat.instance.servermsgTimer = 4400
            ISChat.instance.servermsg = tostring(curNestCellName)
        end
    end

    local nestSq = ParasiteZed.getNestCellMidSquare()
    if nestSq and ParasiteZed.QueenZed  ~= nil then
       -- ParasiteZed.dirGuide(nestSq)
        ParasiteZed.showGuide()
    end
end

Events.OnNestCellChange.Add(ParasiteZed.core)

function ParasiteZed.getNestCell()
    return ParasiteZed.getNestCellData(nil, nil, nil)
end
-----------------------            ---------------------------


function ParasiteZed.getNestCellName(x, y)
    local pl = getPlayer()
    local size = ParasiteZed.NestCellSize
    x = x or round(pl:getX())
    y = y or round(pl:getY())
    local cellX = math.floor(math.floor(x + 0.5) / size)
    local cellY = math.floor(math.floor(y + 0.5) / size)

    return tostring(ParasiteZed.getCurrentNestCellX(pl)).."  "..tostring( ParasiteZed.getCurrentNestCellY(pl))
end
-----------------------            ---------------------------

function ParasiteZed.getNestCellMidSquare()
    local pl = getPlayer()
    local x = round(pl:getX())
    local y = round(pl:getY())
    local midX =  ParasiteZed.getNestCellMidX(x, y)
    local midY =  ParasiteZed.getNestCellMidY(x, y)

    local x, y, z = midX,  midY,  0
    local sq = getCell():getOrCreateGridSquare(x, y, z)
    if sq then
       -- ParasiteZed.tempMark(sq)
        return sq
    end
    return nil
end



function ParasiteZed.getNestCellMidX(x, y)
    local pl = getPlayer()
    x, y = round(pl:getX()),  round(pl:getY())
    return ParasiteZed.getNestCellData("midX", x, y)
end
function ParasiteZed.getNestCellMidY(x, y)
    local pl = getPlayer()
    x, y = round(pl:getX()),  round(pl:getY())
    return ParasiteZed.getNestCellData("midY", x, y)
end

-----------------------            ---------------------------



function ParasiteZed.getQueenCount(x, y)

    return #ParasiteZed.queenList
end

function ParasiteZed.getParasiteCount(x, y)

    return #ParasiteZed.parasiteList
end

function ParasiteZed.getNestCellZeds(x, y)
	local size = ParasiteZed.NestCellSize
	local parasiteList = {}
	local queenList = {}

	local pl = getPlayer()
	x = x or math.floor(pl:getX())
	y = y or math.floor(pl:getY())

	local cellX = math.floor(x / size)
	local cellY = math.floor(y / size)

	local startX = cellX * size
	local startY = cellY * size
	local endX = startX + size - 1
	local endY = startY + size - 1

	for xi = startX, endX do
		for yi = startY, endY do
			local sq = getCell():getGridSquare(xi, yi, 0)
			if sq then
				local movObjs = sq:getMovingObjects()
				for i = 1, movObjs:size() do
					local zed = movObjs:get(i - 1)
					if instanceof(zed, "IsoZombie") then
						if ParasiteZed.isParasiteQueen(zed) then
							table.insert(queenList, zed)
						end
						if ParasiteZed.isParasiteZed(zed) then
							table.insert(parasiteList, zed)
						end
					end
				end

				local objects = sq:getObjects()
				for i = 1, objects:size() do
					local obj = objects:get(i - 1)
					local sprName = ParasiteZed.getSprName(obj)
					if sprName and ParasiteZed.isSpawnerNest(sprName) then
						if not ParasiteZed.nest then
							ParasiteZed.nest = obj
							ParasiteZed.nestSq = sq
						elseif ParasiteZed.nest ~= obj then
							ParasiteZed.doSledge(obj)
						end
					end
				end
			end
		end
	end

	ParasiteZed.queenList = queenList
	ParasiteZed.parasiteList = parasiteList
end


-----------------------            ---------------------------

-----------------------            ---------------------------
function ParasiteZed.teleportToNestCellMid(nestCellName)
    if not nestCellName then return end
    local data = ParasiteZed.getNestCellFromName(nestCellName)
    if not data then
        print("Invalid nest cell name:", tostring(nestCellName))
        return
    end

    local midX = tonumber(ParasiteZed.getNestCellData("midX", data.x, data.y))
    local midY = tonumber(ParasiteZed.getNestCellData("midY", data.x, data.y))
    local midZ = 0

    if not midX or not midY then
        print("Midpoint data missing for nest cell:", nestCellName)
        return
    end

    local square = getCell():getGridSquare(midX, midY, midZ)
    if not square then
        print("GridSquare not found at:", midX, midY, midZ)
        return
    end
    local pl = getPlayer()
    pl:setX(midX + 0.5)
    pl:setY(midY + 0.5)
    pl:setLx(midX + 0.5)
    pl:setLy(midY + 0.5)
    pl:setZ(0)
    pl:setLz(0)


    print("Teleported to nest cell midpoint:", nestCellName, midX, midY)
end


-----------------------            ---------------------------

function ParasiteZed.tpToNestCell()
    local pl = getPlayer()
    x, y = round(pl:getX()),  round(pl:getY())
    local nestCellMidX = ParasiteZed.getNestCellMidX(x, y)
    local nestCellMidY = ParasiteZed.getNestCellMidY(x, y)

    pl:setX(nestCellMidX)
    pl:setY(nestCellMidY)
    pl:setLx(nestCellMidX)
    pl:setLy(nestCellMidY)
    pl:setZ(0)
    pl:setLz(0)

end




 ]]