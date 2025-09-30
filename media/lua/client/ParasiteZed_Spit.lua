require "ISUI/ISUIElement" 
ParasiteZed = ParasiteZed or {}
SpitAnim = ISUIElement:derive("SpitAnim")


function ParasiteZed.OnSpitHitLocal(id)
    local targPl = getPlayerByOnlineID(id)
    if targPl == getPlayer()  then
        ParasiteZed.spitScreen(0.55, 0.22, 0.67 , 0.75)
        targPl:getStats():setPanic(100)
        local sq = targPl:getSquare()
        getSoundManager():PlayWorldSound('ParasiteZed_SpitHit', sq, 0, 5, 5, false);
        if isClient() then
            sendClientCommand('ParasiteZed', 'OnSpitHit', {  id = targPl:getOnlineID() })
        end
        ParasiteZed.CallToArms(targPl)
    end
end
--[[ 
ParasiteZed.OnSpitHitLocal(getPlayer():getOnlineID()) 
]]

ParasiteZed.damageFlash = nil
ParasiteZed.gasNearby = false

function ParasiteZed.spitScreen(r, g, b, a, dur)
    
    if ParasiteZed.damageFlash then 
        ParasiteZed.damageFlash.a = a
        ParasiteZed.gasNearby = true
        return
    end
    dur = dur or 0.5
    ParasiteZed.damageFlash = ISPanel:new(0, 0, getCore():getScreenWidth(), getCore():getScreenHeight())
    ParasiteZed.damageFlash.backgroundColor = { r = r or 0, g = g or 1, b = b or 0, a = a or 0.5 }
    ParasiteZed.damageFlash.noBackground = false
    ParasiteZed.damageFlash.consumeMouseEvents = false
    ParasiteZed.damageFlash:initialise()
    ParasiteZed.damageFlash:addToUIManager()
    ParasiteZed.gasNearby = true
    
    function ParasiteZed.fade()
        if ParasiteZed.gasNearby then
            ParasiteZed.gasNearby = false
            return
        end
        if ParasiteZed.damageFlash then
            ParasiteZed.damageFlash.backgroundColor.a = ParasiteZed.damageFlash.backgroundColor.a - 0.02
            if ParasiteZed.damageFlash.backgroundColor.a <= 0 then
                if ParasiteZed.damageFlash then
                    ParasiteZed.damageFlash:close()   
                    ParasiteZed.damageFlash = nil
                    Events.OnTick.Remove(ParasiteZed.fade)
                end
            end
        end
    end
    Events.OnTick.Add(ParasiteZed.fade)
end

function SpitAnim:new(x1, y1, x2, y2, z, duration, scale)
    local o = ISUIElement:new(0, 0, 256, 256)
    setmetatable(o, self)
    self.__index = self

    o.frames = {}
    for i = 0, 16 do
        table.insert(o.frames, getTexture(string.format("media/textures/spit/spit_%d.png", i)))
    end

    o.frameIndex = 1
    o.startX, o.startY = x1, y1
    o.endX, o.endY = x2, y2
    o.worldZ = z or 0
    o.duration = duration or 1000
    o.elapsed = 0
    o.worldX, o.worldY = x1, y1
    o.scale = scale or 0.5
    o.width = 256 * o.scale
    o.height = 256 * o.scale

    return o
end

function SpitAnim:update()
    local now = getTimestampMs()
    local dt = now - (self.lastUpdate or now)
    self.lastUpdate = now

    self.elapsed = self.elapsed + dt
    local t = math.min(self.elapsed / self.duration, 1.0)
    self.worldX = self.startX + (self.endX - self.startX) * t
    self.worldY = self.startY + (self.endY - self.startY) * t

    local sq = getCell():getGridSquare(math.floor(self.worldX), math.floor(self.worldY), self.worldZ)
    if sq then
        local objs = sq:getMovingObjects()
        for i = 0, objs:size() - 1 do
            local obj = objs:get(i)
            if instanceof(obj, "IsoPlayer") then
                self:removeFromUIManager()
                ParasiteZed.OnSpitHitLocal(obj:getOnlineID())
                return
            end
        end
    end

    local screenX, screenY = ISCoordConversion.ToScreen(self.worldX, self.worldY, self.worldZ)
    local pl = getPlayer()
    local zoom = getCore():getZoom(pl:getPlayerNum()) or 1.0
    self:setX(screenX / zoom - self.width / 2)
    self:setY(screenY / zoom - self.height / 2)

    local totalSteps = #self.frames
    self.frameIndex = math.min(math.floor(t * totalSteps) + 1, totalSteps)

    if t >= 1.0 then
        self:removeFromUIManager()
    end
end

function SpitAnim:render()
    local tex = self.frames[self.frameIndex]
    if tex then
        local pl = getPlayer()
        local zoom = getCore():getZoom(pl:getPlayerNum()) or 1.0
        self:drawTextureScaled(tex, 0, 0, self.width / zoom, self.height / zoom, 1, 1, 1, 1)
    end
end

function ParasiteZed.doSpit(x1, y1, x2, y2, z, duration, scale)
    
    local effect = SpitAnim:new(x1, y1, x2, y2, z or 0, duration or 5000, scale or 0.7)	
    effect:initialise()
    effect:addToUIManager()
end
       
