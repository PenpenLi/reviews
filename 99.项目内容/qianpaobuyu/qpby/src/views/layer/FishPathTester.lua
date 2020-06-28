local FishPathTester =
    class(
    "FishPathTester",
    function()
        return display.newLayer()
    end
)
local module_pre = "game.yule.qpby.src"
local ExternalFun = require(appdf.EXTERNAL_SRC .. "ExternalFun")
local scheduler = cc.Director:getInstance():getScheduler()
function FishPathTester:ctor(scene)
    self.scene = scene
    self:enableNodeEvents()
    self._drawDebug = cc.DrawNode3D:create():addTo(self)
    self.lastPos = nil
    self.numTable = {}
    self.fishTable = clone(self.scene.configMgr.fishTable)
    local currentScene = cc.Director:getInstance():getRunningScene()
    self._camera = currentScene:getDefaultCamera()
    self.testFishKind = 1
    self:initUI()
end
function FishPathTester:orderTabel(needOrderTable)
end
function FishPathTester:initUI()
    self:initPathButton()
    self:initFishButton()
    self.fishKindText =
        ccui.Text:create():setFontSize(16):setTextColor(cc.c3b(0, 255, 0)):setPosition(20, display.height - 20):setAnchorPoint(
        0,
        0.5
    ):addTo(self)
    self.fishNameText =
        ccui.Text:create():setFontSize(16):setTextColor(cc.c3b(0, 255, 0)):setPosition(20, display.height - 20 - 20):setAnchorPoint(
        0,
        0.5
    ):addTo(self)
    self.pathNumText =
        ccui.Text:create():setFontSize(16):setTextColor(cc.c3b(0, 255, 0)):setPosition(20, display.height - 20 - 20 * 2):setAnchorPoint(
        0,
        0.5
    ):addTo(self)
end
function FishPathTester:initPathButton()
    local totalCount = 100
    local colNum = 5
    local rowNum = math.ceil(totalCount / colNum)
    local intervalX = 30
    local intervalY = 30
    for i = 1, totalCount do
        local btnIndex = i - 1
        local buttonSize = cc.size(20, 20)
        local colIdx = (i - 1) % colNum + 1
        local rowIdx = math.ceil(i / colNum)
        local posX = display.width - 170 + (intervalX) * (colIdx - 1)
        local posY = display.height - 50 - (intervalY) * (rowIdx - 1)
        local btn =
            ccui.Button:create():setAnchorPoint(cc.p(0.5, 0.5)):ignoreContentAdaptWithSize(true):setContentSize(
            buttonSize
        ):setScale9Enabled(true):addTo(self):setPosition(posX, posY)
        btn:addTouchEventListener(
            function(ref, type)
                if type == ccui.TouchEventType.ended then
                    self:testFish(btnIndex)
                    self:updateFishInfo()
                    return true
                end
            end
        )
        ExternalFun.createDebugBox(btn)
        btn:setTitleText(btnIndex)
    end
end
function FishPathTester:updateFishInfo()
    local fishInfo = nil
    for i = 1, #self.fishTable do
        local fishTemp = self.fishTable[i]
        if tonumber(fishTemp.TypeID) == self.testFishKind then
            fishInfo = fishTemp
            break
        end
    end
    if not fishInfo then
        return
    end
    self.fishKindText:setString("fishKind:" .. self.testFishKind)
    self.fishNameText:setString("fishName:" .. fishInfo.Name)
end
function FishPathTester:initFishButton()
    local totalCount = #self.fishTable
    local colNum = 42
    local rowNum = math.ceil(totalCount / colNum)
    local intervalX = 30
    local intervalY = 30
    for i = 1, totalCount do
        local fishKind = self.fishTable[i].TypeID
        local buttonSize = cc.size(20, 20)
        local colIdx = (i - 1) % colNum + 1
        local rowIdx = math.ceil(i / colNum)
        local posX = 50 + (intervalX) * (colIdx - 1)
        local posY = 50 - (intervalY) * (rowIdx - 1)
        local btn =
            ccui.Button:create():setAnchorPoint(cc.p(0.5, 0.5)):ignoreContentAdaptWithSize(true):setContentSize(
            buttonSize
        ):setScale9Enabled(true):addTo(self):setPosition(posX, posY)
        btn:addTouchEventListener(
            function(ref, type)
                if type == ccui.TouchEventType.ended then
                    self.scene.fishLayer:clearFish()
                    self.testFishKind = tonumber(fishKind)
                    self:updateFishInfo()
                    return true
                end
            end
        )
        ExternalFun.createDebugBox(btn)
        btn:setTitleText(fishKind)
        btn:setTitleColor(cc.c3b(255, 255, 0))
    end
end
function FishPathTester:testFish(btnIndex)
    self.scene.fishLayer:clearFish()
    local fishCmd = {fish_kind = tonumber(self.testFishKind) - 1, cmd_version = btnIndex, fish_id = 12232133}
    local fish = self.scene.fishLayer:createFish(fishCmd)
    local pathTable = self.scene.configMgr:getPathByPathId(btnIndex)
    self:drawPathBox(pathTable, btnIndex)
end
function FishPathTester:drawPathBox(pathTable, pathId)
    self._drawDebug:clear()
    for i = #self.numTable, 1, -1 do
        local numText = self.numTable[i]
        if not tolua.isnull(numText) then
            numText:removeFromParent()
        end
    end
    self.pathNumText:setString("pathId:" .. pathId)
    self.lastPos = nil
    for i = 1, #pathTable do
        local pos = pathTable[i]
        local radius = 40
        self:drawBox(pos, radius, i)
    end
end
function FishPathTester:drawBox(pos, radius, index)
    local sPos = cc.vec3(pos.x + radius, pos.y + radius, pos.z + radius)
    local ePos = cc.vec3(pos.x - radius, pos.y - radius, pos.z - radius)
    local aabb = cc.AABB:new(sPos, ePos)
    local obb = cc.OBB:new(aabb)
    obb._center = cc.vec3(pos.x, pos.y, pos.z)
    self:drawCollisionBox(obb)
    local textPos = self._camera:projectGL(cc.vec3(pos.x, pos.y + radius + 30, pos.z))
    local numText =
        ccui.Text:create():setFontSize(34):setTextColor(cc.c3b(0, 255, 0)):setPosition(textPos):setAnchorPoint(0.5, 0.5):setString(
        index
    ):addTo(self)
    table.insert(self.numTable, numText)
    if self.lastPos then
        self._drawDebug:drawLine(pos, self.lastPos, cc.c4f(1, 0, 0, 1))
    end
    self.lastPos = pos
    return obb
end
function FishPathTester:drawCollisionBox(obb)
    local color = cc.c4f(0, 1, 0, 1)
    local corners = {}
    for i = 1, 8 do
        corners[i] = {}
    end
    corners = obb:getCorners(corners)
    self._drawDebug:drawCube(corners, color)
end
function FishPathTester:onEnter()
end
function FishPathTester:onCleanup()
end
return FishPathTester
