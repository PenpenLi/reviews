local PathChecker =
    class(
    "PathChecker",
    function()
        return display.newLayer()
    end
)
local module_pre = "game.yule.qpby.src"
local ExternalFun = require(appdf.EXTERNAL_SRC .. "ExternalFun")
local scheduler = cc.Director:getInstance():getScheduler()
function PathChecker:ctor()
    self:enableNodeEvents()
    self._drawDebug = cc.DrawNode3D:create():addTo(self)
    self.lastPos = nil
    self.numTable = {}
    local currentScene = cc.Director:getInstance():getRunningScene()
    self._camera = currentScene:getDefaultCamera()
end
function PathChecker:onEnter()
end
function PathChecker:drawPathBox(pathTable, pathId)
    self._drawDebug:clear()
    for i = #self.numTable, 1, -1 do
        local numText = self.numTable[i]
        if not tolua.isnull(numText) then
            numText:removeFromParent()
        end
    end
    if tolua.isnull(self.pathNumText) then
        self.pathNumText =
            ccui.Text:create():setFontSize(34):setTextColor(cc.c3b(0, 255, 0)):setPosition(200, display.height - 50):setAnchorPoint(
            0.5,
            0.5
        ):addTo(self)
    end
    self.pathNumText:setString("pathId:" .. pathId)
    self.lastPos = nil
    for i = 1, #pathTable do
        local pos = pathTable[i]
        local radius = 40
        self:drawBox(pos, radius, i)
    end
end
function PathChecker:drawBox(pos, radius, index)
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
function PathChecker:drawCollisionBox(obb)
    local color = cc.c4f(0, 1, 0, 1)
    local corners = {}
    for i = 1, 8 do
        corners[i] = {}
    end
    corners = obb:getCorners(corners)
    self._drawDebug:drawCube(corners, color)
end
return PathChecker
