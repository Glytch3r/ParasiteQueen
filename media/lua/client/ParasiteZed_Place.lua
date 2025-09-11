

function ParasiteZed.getNestOnSq(sq)
    sq = sq or ParasiteZed.getPointer()
    if not sq then return nil end
    for i = 0, sq:getObjects():size() - 1 do
        local obj = sq:getObjects():get(i)
        local sprName = ParasiteZed.getSprName(obj)
        if sprName and ParasiteZed.isSpawnerNest(sprName) then
            return obj
        end
    end
    return nil
end




function ParasiteZed.place(sprName, bombItem)
    if not sprName and not bombItem then return end

    local pl = getPlayer()
    local plNum = pl:getPlayerNum()
    local isBomb = bombItem ~= nil
    if isBomb then sprName = "preset_depthmaps_01_7" end

    local cursor = ISBrushToolTileCursor:new(sprName, sprName, pl)
    cursor.dragNilAfterPlace = true
    getCell():setDrag(cursor, plNum)


    local function OnRightMouseUp()
        getCell():setDrag(nil, plNum)
        Events.OnRightMouseUp.Remove(OnRightMouseUp)
        Events.OnTick.Remove(OnTick)
    end


    local function OnTick()
        local sq =  cursor.square or ParasiteZed.getPointer()
        local isNest = ParasiteZed.getNestOnSq(sq) ~= nil
        ParasiteZed.nest = ParasiteZed.nest or ParasiteZed.getNestOnSq(sq)

        local col = { r = 1, g = 0, b = 0 }

        if sq then
            local flr = sq:getFloor()
            if flr then
                if isNest or not isBomb then col = { r = 0, g = 0, b = 1 } end
                flr:setHighlightColor(col.r, col.g, col.b, 1)
                flr:setHighlighted(true, true)
            end
        end

        if getCell():getDrag(plNum) ~= cursor then
            if not sq then return end
            if isBomb then
                if not isNest then
                    pl:setHaloNote("Must be placed on a Parasite Nest.", 150, 250, 150, 900)
                    return
                end

                local nest = ParasiteZed.nest
                if nest then
                    if luautils.walkAdj(pl, sq) then
                        ISTimedActionQueue.add(BugBombAction:new(pl, sq, nest, bombItem))
                    else
                        pl:setHaloNote("Must be close to the Parasite Nest.", 150, 250, 150, 900)
                    end
                end

            end
            Events.OnTick.Remove(OnTick)
            Events.OnRightMouseUp.Remove(OnRightMouseUp)
            getPlayerLoot(plNum):refreshBackpacks()




        end
    end


    Events.OnRightMouseUp.Add(OnRightMouseUp)

    Events.OnTick.Add(OnTick)
end

--[[
function ParasiteZed.place(sprName, bombItem)
    if not sprName and not bombItem then return end
    local pl = getPlayer()
    local plNum = pl:getPlayerNum()
    local isBomb = bombItem ~= nil
    if isBomb then sprName = "preset_depthmaps_01_7" end

    local cursor = ISBrushToolTileCursor:new(sprName, sprName, pl)
    cursor.dragNilAfterPlace = true
    local drag = getCell():setDrag(cursor, plNum)
    local function OnTick()
        local sq = ParasiteZed.getPointer() or cursor.square
        local col = {r = 1, g = 0, b = 0}
        local isNest = ParasiteZed.getNestOnSq(sq)

        if sq then
            local flr = sq:getFloor()
            if flr then
                if isNest or not isBomb then col = {r = 0, g = 0, b = 1} end
                flr:setHighlightColor(col.r, col.g, col.b, 1)
                flr:setHighlighted(true, true)
            end
        end

        if getCell():getDrag(plNum) ~= cursor then

            --print(tostring(instanceof(drag, "IsoObject")).."\n"..tostring(cursor) )
            if isBomb then
                    if luautils.walkAdj(pl, cursor.square) then
                    --if pl:DistTo(cursor.square:getX(), cursor.square:getY()) <= 3 then
                        if col.b == 1 then
                            cursor.square:AddWorldInventoryItem("Base.ParasiteZed_BugBomb", 0.5, 0.5, 0)
                            ISRemoveItemTool.removeItem(bombItem, plNum)
                            ISInventoryPage.dirtyUI()
                        else
                            pl:setHaloNote("Must be placed on a Parasite Nest.", 150, 250, 150, 900)
                        end
                    else
                        pl:setHaloNote("Must be close to the Parasite Nest.", 150, 250, 150, 900)

                    end
            else
                if sq then
                    if not ParasiteZed.QueenZed then
                        ParasiteZed.doSpawn(sq, false, 'ParasiteZed_Queen')
                    end
                    local x, y = round(pl:getX()),  round(pl:getY())
                    local cellName = ParasiteZed.getNestCellName(x, y)
                    if cellName then
                        if isClient() then
                            sendClientCommand('ParasiteZed', 'CellEvent', { cellName = cellName})
                        else
                            triggerEvent("OnNestCellChange", x, y, x,  y)
                        end
                    end
                end
            end

            Events.OnTick.Remove(OnTick)
        end
    end

    Events.OnTick.Add(OnTick)
end
 ]]
--[[
    local bombItem = getPlayer():getInventory():FindAndReturn("Base.ParasiteZed_BugBomb")
    if bombItem then
        ParasiteZed.place(nil, bombItem)
    else
        ParasiteZed.place("ParasiteZedNest_0")
    end



 ]]

