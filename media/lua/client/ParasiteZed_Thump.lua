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

function ParasiteZed.thumpHandler(zed)
    if not zed or zed:isDead() then return end
    local isQueen = ParasiteZed.isParasiteQueen(zed)
    local pl = getPlayer() 
    if isQueen and pl then
        if ParasiteZed.isClosestPl(pl, zed) then
            local rState =  zed:getRealState()
            if rState and string.lower(rState) == 'thump' then   
                local thump = zed:getThumpTarget()
                if thump then
                    local cond = zed:getThumpCondition() 
                    if cond and cond <= 0 then    
                        ParasiteZed.doSledge(thump)
                        if getCore():getDebug() then 
                            zed:addLineChatElement('thump: '..tostring(thump))
                        end
                    else
                        zed:setThumpCondition(0) 
                    end
                end
            end
        end
    end
end
Events.OnZombieUpdate.Remove(ParasiteZed.thumpHandler)
Events.OnZombieUpdate.Add(ParasiteZed.thumpHandler)
