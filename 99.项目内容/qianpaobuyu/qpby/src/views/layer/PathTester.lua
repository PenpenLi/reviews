local PathTester =
    class(
    "PathTester",
    function()
        return display.newLayer()
    end
)
local module_pre = "game.yule.qpby.src"
local ExternalFun = require(appdf.EXTERNAL_SRC .. "ExternalFun")
local scheduler = cc.Director:getInstance():getScheduler()
function PathTester:ctor()
    self:enableNodeEvents()
    self._drawDebug = cc.DrawNode3D:create():addTo(self)
    self.posTable = {
        cc.vec3(display.width * 0.1, display.height * 0.2, 0),
        cc.vec3(display.width * 0.5, display.height * 0.8, 0),
        cc.vec3(display.width * 0.9, display.height * 0.2, 0)
    }
    local slider_save =
        ccui.Slider:create():loadBarTexture("ui/bank_img_progressBarBg.png", 0):loadProgressBarTexture(
        "ui/bank_img_progressBar.png",
        0
    ):loadSlidBallTextureNormal("ui/bank_btn_slide_normal.png", 0):loadSlidBallTexturePressed(
        "ui/bank_btn_slide_pressed.png",
        0
    ):loadSlidBallTextureDisabled("ui/bank_btn_slide_pressed.png", 0):setPercent(0):setPosition(display.cx, 50):addTo(
        self
    ):onEvent(handler(self, self.SlideEvent))
    local pos = self:getInterpolatedPt(self.posTable[1], self.posTable[2], self.posTable[3], 0)
    local fileName = string.format("model/%s/%s.c3b", "xiaohuangyu", "xiaohuangyu")
    self.fish = nil
end
function PathTester:SlideEvent(event)
    if event.name == "ON_PERCENTAGE_CHANGED" then
        local percent = event.target:getPercent()
        local pos = self:getInterpolatedPt(self.posTable[1], self.posTable[2], self.posTable[3], percent / 100)
        self.fish:setPosition3D(pos)
    end
end
function PathTester:getInterpolatedPt(p0, p1, p2, t)
    p0 = clone(p0)
    p1 = clone(p1)
    p2 = clone(p2)
    local t2 = t * t
    p0.x = p0.x * ((1.0 - 2.0 * t + t2) * 0.5)
    p0.y = p0.y * ((1.0 - 2.0 * t + t2) * 0.5)
    p0.z = p0.z * ((1.0 - 2.0 * t + t2) * 0.5)
    p1.x = p1.x * ((1.0 + 2.0 * t - 2.0 * t2) * 0.5)
    p1.y = p1.y * ((1.0 + 2.0 * t - 2.0 * t2) * 0.5)
    p1.z = p1.z * ((1.0 + 2.0 * t - 2.0 * t2) * 0.5)
    p2.x = p2.x * (t2 * 0.5)
    p2.y = p2.y * (t2 * 0.5)
    p2.z = p2.z * (t2 * 0.5)
    local posX = p0.x + p1.x + p2.x
    local posY = p0.y + p1.y + p2.y
    local posZ = p0.z + p1.z + p2.z
    return cc.vec3(posX, posY, posZ)
end
function PathTester:onEnter()
    self:drawPathBox(self.posTable)
    self.aa = 0
    self.timerId = scheduler:scheduleScriptFunc(handler(self, self.update), 0.0, false)
    local length = self:getLength(5)
    self.speed = 260 / length
end
function PathTester:update(dt)
    self.aa = self.aa + self.speed * dt
    local pos = self:getInterpolatedPt(self.posTable[1], self.posTable[2], self.posTable[3], self.aa)
    self.fish:setPosition3D(pos)
end
function PathTester:getLength(num)
    local interval = 1 / num
    local length = 0
    local startT = 0
    local p0 = self.posTable[1]
    local p1 = 0
    for i = 1, num do
        startT = startT + interval
        if i > 1 then
            p0 = p1
        end
        p1 = self:getInterpolatedPt(self.posTable[1], self.posTable[2], self.posTable[3], startT)
        length = length + self:distance3D(p0, p1)
    end
    return length
end
function PathTester:distance3D(p1, p2)
    local offsetX = p1.x - p2.x
    local offsetY = p1.y - p2.y
    local offsetZ = p1.z - p2.z
    return math.sqrt(offsetX * offsetX + offsetY * offsetY + offsetZ * offsetZ)
end
function PathTester:onCleanup()
    scheduler:unscheduleScriptEntry(self.timerId)
end
function PathTester:drawPathBox(posTable)
    self._drawDebug:clear()
    for i = 1, #posTable do
        local pos = posTable[i]
        local radius = 20
        self:drawBox(pos, radius, i)
    end
end
function PathTester:drawBox(pos, radius, index)
    local sPos = cc.vec3(pos.x + radius, pos.y + radius, pos.z + radius)
    local ePos = cc.vec3(pos.x - radius, pos.y - radius, pos.z - radius)
    local aabb = cc.AABB:new(sPos, ePos)
    local obb = cc.OBB:new(aabb)
    obb._center = cc.vec3(pos.x, pos.y, pos.z)
    self:drawCollisionBox(obb)
    return obb
end
function PathTester:drawCollisionBox(obb)
    local color = cc.c4f(0, 1, 0, 1)
    local corners = {}
    for i = 1, 8 do
        corners[i] = {}
    end
    corners = obb:getCorners(corners)
    self._drawDebug:drawCube(corners, color)
end
return PathTester
