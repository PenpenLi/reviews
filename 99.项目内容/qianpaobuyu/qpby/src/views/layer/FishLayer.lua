local FishLayer =
    class(
    "FishLayer",
    function()
        return display.newLayer()
    end
)
local module_pre = "game.yule.qpby.src"
local ExternalFun = require(appdf.EXTERNAL_SRC .. "ExternalFun")
local scheduler = cc.Director:getInstance():getScheduler()
local FishVisual = appdf.req(module_pre .. ".views.layer.FishVisual")
local FishMapping = appdf.req(module_pre .. ".models.FishMapping")
function FishLayer:ctor(scene)
    self.scene = scene
    self:enableNodeEvents()
    self.fishList = {}
end
function FishLayer:onEnter()
end
function FishLayer:clearFish()
    for i = #self.fishList, 1, -1 do
        local fish = self.fishList[i]
        if not tolua.isnull(fish) then
            fish.isDead = true
            fish.isRemove = true
        end
    end
end
function FishLayer:playTroop(troopTable, pointData)
    local pointData = troopTable[#troopTable]
    local pointTable = {["3"] = pointData[1], ["6"] = pointData[2], ["9"] = pointData[3]}
    local troopId = 0
    local troopFun =
        cc.CallFunc:create(
        function()
            troopId = troopId + 1
            if troopId > #troopTable - 1 then
                return
            end
            local troopFish = troopTable[troopId]
            self:createTroop(troopFish)
            local pointFishData = pointTable[tostring(troopId)]
            if pointFishData then
                self:createPointFish(pointFishData)
            end
        end
    )
    local delayTime = cc.DelayTime:create(6.0)
    local seq = cc.Sequence:create(troopFun, delayTime)
    local rep = cc.Repeat:create(seq, #troopTable - 1)
    self:runAction(rep)
end
function FishLayer:createTestFish(fishCmd)
    local fishKind = fishCmd.fish_kind + 1
    if fishKind == 27 then
        return
    end
    if fishKind == 46 then
        fishKind = 27
    end
    local fishData = self.scene.configMgr:getFishDataByFishId(fishKind)
    if not fishData then
        return
    end
    local fish = FishVisual:create(fishData):addTo(self)
    fish.fishId = fishCmd.fish_id
    table.insert(self.fishList, fish)
    return fish
end
function FishLayer:createFish(fishCmd)
    local fishKind = fishCmd.fish_kind + 1
    if FishMapping.FishType[fishKind] then
        fishKind = FishMapping.FishType[fishKind]
    else
        return
    end
    local pathId = fishCmd.cmd_version
    local fishData = self.scene.configMgr:getFishDataByFishId(fishKind)
    if not fishData then
        return
    end
    local posTable = self.scene.configMgr:getPathByPathId(pathId)
    if not posTable then
        return
    end
    local fish = FishVisual:create(fishData):addTo(self)
    fish:setPath(posTable)
    fish.fishId = fishCmd.fish_id
    table.insert(self.fishList, fish)
    return fish
end
function FishLayer:createTroop(troopData)
    for i = 1, #troopData do
        local fishKind = troopData[i][1] + 1
        local fishId = troopData[i][2]
        local fishData = self.scene.configMgr:getFishDataByFishId(fishKind)
        if not fishData then
            return
        end
        local pathId = 1
        local posTable = self.scene.configMgr:getPathByPathId(pathId)
        if not posTable then
            return
        end
        local fish = FishVisual:create(fishData):addTo(self)
        fish:setScale(fishData.troopScale)
        fish:setPath(posTable)
        fish.isTroop = true
        fish.troopId = i
        fish.fishId = fishId
        table.insert(self.fishList, fish)
        local interval = 20
        local startRadius = 100
        local center = {x = 0, y = display.cy, z = 0}
        local pos = pathMathCirclePos(interval, startRadius, i, center)
        fish:setPosition3D(pos)
    end
end
function FishLayer:createPointFish(pointFishData)
    local fishKind = pointFishData[1] + 1
    local fishId = pointFishData[2]
    local fishData = self.scene.configMgr:getFishDataByFishId(fishKind)
    if not fishData then
        return
    end
    local pathId = 1
    local posTable = self.scene.configMgr:getPathByPathId(pathId)
    if not posTable then
        return
    end
    fishData.isPoint = true
    local fish = FishVisual:create(fishData):addTo(self)
    fish:setScale(fishData.troopScale)
    fish:setPath(posTable)
    fish.fishId = fishId
    fish.isPoint = true
    table.insert(self.fishList, fish)
    local pos = {x = -200, y = display.cy, z = 0}
    fish:setPosition3D(pos)
end
function FishLayer:getFishList()
    return self.fishList
end
function FishLayer:getFishByFishId(fishId)
    local fish = nil
    for i = 1, #self.fishList do
        local fishTemp = self.fishList[i]
        if fishId == fishTemp.fishId then
            fish = fishTemp
            return fish
        end
    end
    return fish
end
function FishLayer:getAutoLockFishId(curTagrget)
    curTagrget = curTagrget or 0xFFFFFFFF
    local lockLevel = 0
    if #self.fishList == 1 then
        return self.fishList[1].fishId
    end
    local maxLevel = -1
    local currentId = curTagrget
    for i = 1, #self.fishList do
        local fishTemp = self.fishList[i]
        local lockLevel = tonumber(fishTemp.fishData.LockLevel)
        if self:fishAvailable(fishTemp) and fishTemp.fishId ~= curTagrget and lockLevel > maxLevel then
            maxLevel = lockLevel
            currentId = fishTemp.fishId
        end
    end
    if tonumber(currentId) ~= 0xFFFFFFFF then
        return currentId
    end
    return 0xFFFFFFFF
end
function FishLayer:fishAvailable(fish)
    if tolua.isnull(fish) then
        return false
    end
    if fish.isDead then
        return false
    end
    local fishPos = fish:getPosition3D()
    fishPos = self.scene._camera:projectGL(fishPos)
    local boundaryOverflow = 0
    if
        fishPos.x < -boundaryOverflow or fishPos.x > display.width + boundaryOverflow or fishPos.y < -boundaryOverflow or
            fishPos.y > display.height + boundaryOverflow
     then
        return false
    else
        local cannonPos = self.scene.cannonLayer.myCannon:getWorldPos()
        local myChairId = self.scene.cannonLayer.myCannon.chairId
        if myChairId < 2 then
            if fishPos.y < cannonPos.y then
                return false
            else
                return true
            end
        else
            if fishPos.y > cannonPos.y then
                return false
            else
                return true
            end
        end
    end
    return true
end
return FishLayer
