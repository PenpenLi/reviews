local GameConfigMgr = class("GameConfigMgr")
local module_pre = "game.yule.qpby.src"
function GameConfigMgr:ctor()
    self:loadConfig()
    self:initConfig()
    self:setFishData()
end
function GameConfigMgr:loadConfig()
    self.fishPath = appdf.req(module_pre .. ".luaTable.path")
    self.fishConfig = appdf.req(module_pre .. ".luaTable.Fish_New")
    self.visualConfig = appdf.req(module_pre .. ".luaTable.Visual_New")
    self.fishWiki = appdf.req(module_pre .. ".luaTable.FishWiki")
end
function GameConfigMgr:initConfig()
    self.wikiNormalData = self.fishWiki["Wiki"][1]["Normal"][1]["Fish"]
    self.wikiBossData = self.fishWiki["Wiki"][1]["Boss"][1]["Fish"]
    self.wikiSpecialData = self.fishWiki["Wiki"][1]["Special"][1]["Fish"]
    self.fishTable = self.fishConfig["FishSet"][1]["Fish"]
    self.visualTable = self.visualConfig["Visuals"][1]["Visual"]
    self.modelTable = self.visualConfig["Models"][1]["Model"]
    self.effectTable = self.visualConfig["Effects"][1]["Effect"]
    self.pathTable = self.fishPath["FishPath"][1]["Path"]
end
function GameConfigMgr:getPathByPathId(pathId)
    local pathInfoTable = self:getPathInfoByPathId(pathId)
    if not pathInfoTable then
        return
    end
    local posTable = pathInfoTable.Position
    local pos3DTable = {}
    for i = 1, #posTable do
        local point = posTable[i]
        local pos = self:pointfoToPos(point)
        table.insert(pos3DTable, pos)
    end
    return pos3DTable
end
function GameConfigMgr:getPathInfoByPathId(pathId)
    pathId = tostring(pathId)
    local pathInfo = nil
    for i = 1, #self.pathTable do
        local pathCurInfo = self.pathTable[i]
        if pathCurInfo.id == pathId then
            pathInfo = pathCurInfo
            break
        end
    end
    return pathInfo
end
function GameConfigMgr:pointfoToPos(point)
    local posX = tonumber(point.x + display.width / 2)
    local posY = tonumber(point.y + display.height / 2)
    local posZ = tonumber(point.z)
    return cc.vec3(posX, posY, posZ)
end
function GameConfigMgr:getEffectDataById(effectId)
    local effectInfo = nil
    for i = 1, #self.effectTable do
        if self.effectTable[i]["Id"] == effectId then
            effectInfo = self.effectTable[i]
            break
        end
    end
    if not effectInfo then
        return effectInfo
    end
    return effectInfo
end
function GameConfigMgr:getVisualDataByVisualId(visualId)
    local visualData = nil
    for i = 1, #self.visualTable do
        local visualInfo = self.visualTable[i]
        if visualInfo.Id == visualId then
            visualData = visualInfo
            break
        end
    end
    return visualData
end
function GameConfigMgr:getModelDataByModelId(modelId)
    local modelData = nil
    for i = 1, #self.modelTable do
        local modelInfo = self.modelTable[i]
        if modelInfo.Id == modelId then
            modelData = modelInfo
            break
        end
    end
    return modelData
end
function GameConfigMgr:getFishDataByFishId(fishId)
    fishId = tostring(fishId)
    return self.fishDataTable[fishId]
end
function GameConfigMgr:getFishDataByVisualId(visualId)
    visualId = tostring(visualId)
    for k, v in pairs(self.fishDataTable) do
        if v.VisualID == visualId then
            fishData = clone(v)
            break
        end
    end
    return fishData
end
function GameConfigMgr:setFishData()
    self.fishDataTable = {}
    for i = 1, #self.fishTable do
        local fishCurInfo = self.fishTable[i]
        local fishData = self:setFishDataByFishId(fishCurInfo)
        self.fishDataTable[fishCurInfo.TypeID] = fishData
    end
end
function GameConfigMgr:setFishDataByFishId(fishCurInfo)
    local fishData = {}
    fishData.BossId = fishCurInfo.BossId
    fishData.LockLevel = fishCurInfo.LockLevel
    fishData.Name = fishCurInfo.Name
    fishData.ShakeScreen = fishCurInfo.ShakeScreen
    fishData.Speed = fishCurInfo.Speed
    fishData.TypeID = fishCurInfo.TypeID
    fishData.VisualID = fishCurInfo.VisualID
    fishData.ShowBingo = fishCurInfo.ShowBingo
    local visualData = self:getVisualDataByVisualId(fishData.VisualID)
    if not visualData then
        return
    end
    fishData.Boss = visualData.Boss
    fishData.BossName = visualData.BossName
    fishData.Model = visualData.Model[1]
    fishData.BindModel = visualData.Model[2]
    fishData.useRandomAction = visualData.useRandomAction
    fishData.Effect = visualData.Effect
    fishData.presentationScale = visualData.presentationScale or 1.0
    fishData.troopScale = visualData.troopScale or 1.0
    local modelInfo = self:getModelDataByModelId(fishData.Model.Id)
    if not modelInfo then
        return
    end
    fishData.Model.resName = modelInfo.resName
    fishData.Model.Die = modelInfo.Die
    fishData.Model.Hurt = modelInfo.Hurt
    fishData.Model.Live = modelInfo.Live
    fishData.Model.Special = modelInfo.Special
    fishData.Model.Bone = modelInfo.Bone
    if fishData.BindModel then
        local bindModelInfo = self:getModelDataByModelId(fishData.BindModel.Id)
        fishData.BindModel.resName = bindModelInfo.resName
    end
    if fishData.Effect then
        for i = 1, #fishData.Effect do
            local effectInfo = fishData.Effect[i]
            local effectData = self:getEffectDataById(effectInfo.Id)
            effectInfo.resName = effectData.resName
            effectInfo.live = effectData.live
            effectInfo.cast = effectData.cast
            effectInfo.die = effectData.die
            effectInfo.type = effectData.type
        end
    end
    return fishData
end
function GameConfigMgr:getWikiDataByType(wikiType)
    if wikiType == 2 then
        return self.wikiBossData
    elseif wikiType == 3 then
        return self.wikiSpecialData
    end
    return self.wikiNormalData
end
function GameConfigMgr:getWikiDataCountByType(wikiType)
    if wikiType == 2 then
        return #self.wikiBossData
    elseif wikiType == 3 then
        return #self.wikiSpecialData
    end
    return #self.wikiNormalData
end
function GameConfigMgr:getFishWikiData(wikiType, index)
    index = tonumber(index)
    local wikiDataTable = self:getWikiDataByType(wikiType)
    local wikiData = wikiDataTable[index]
    local fishData = nil
    for k, v in pairs(self.fishDataTable) do
        if v.VisualID == wikiData.visualId then
            fishData = clone(v)
            break
        end
    end
    fishData.wikiName = wikiData.name
    fishData.wikiScore = wikiData.score
    fishData.wikiIntroduction = wikiData.introduction
    fishData.wikiScale = wikiData.modelScale or 1.0
    fishData.wikiOffsetX = wikiData.offsetX
    fishData.wikiOffsetY = wikiData.offsetY
    return fishData
end
function GameConfigMgr:getFishWikiInfo(wikiType, index)
    index = tonumber(index)
    local wikiDataTable = self:getWikiDataByType(wikiType)
    local wikiData = wikiDataTable[index]
    return wikiData
end
return GameConfigMgr
