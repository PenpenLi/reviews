local CollisionLayer =
    class(
    "CollisionLayer",
    function()
        return display.newLayer()
    end
)
local module_pre = "game.yule.qpby.src"
local ExternalFun = require(appdf.EXTERNAL_SRC .. "ExternalFun")
local scheduler = cc.Director:getInstance():getScheduler()
function CollisionLayer:ctor(scene)
    self.scene = scene
    self:enableNodeEvents()
    self.fishList = {}
    self.bulletList = {}
    self.bulletObbList = {}
    self.isDebug = false
    self._drawDebug = nil
end
function CollisionLayer:setDataList(fishList, bulletList)
    self.fishList = fishList
    self.bulletList = bulletList
end
function CollisionLayer:enableDebug(isDebug)
    self.isDebug = isDebug or false
    if tolua.isnull(self._drawDebug) then
        self._drawDebug = cc.DrawNode3D:create():addTo(self)
    end
    if tolua.isnull(self.darwNode2D) then
        self.darwNode2D = cc.DrawNode:create():addTo(self)
    end
end
function CollisionLayer:onEnter()
end
function CollisionLayer:getFishRectBoxByFishId(fishId)
    local fishBox = {
        ["1"] = cc.size(60, 30),
        ["2"] = cc.size(80, 35),
        ["3"] = cc.size(110, 50),
        ["4"] = cc.size(80, 60),
        ["5"] = cc.size(80, 60),
        ["6"] = cc.size(80, 60),
        ["7"] = cc.size(80, 60),
        ["8"] = cc.size(110, 80),
        ["9"] = cc.size(150, 140),
        ["10"] = cc.size(170, 180),
        ["11"] = cc.size(210, 150),
        ["12"] = cc.size(100, 80),
        ["13"] = cc.size(180, 120),
        ["14"] = cc.size(80, 60),
        ["15"] = cc.size(130, 60),
        ["16"] = cc.size(270, 150),
        ["17"] = cc.size(130, 50),
        ["18"] = cc.size(160, 90),
        ["19"] = cc.size(170, 100),
        ["20"] = cc.size(200, 110),
        ["21"] = cc.size(100, 200),
        ["22"] = cc.size(160, 100),
        ["23"] = cc.size(60, 50),
        ["24"] = cc.size(160, 70),
        ["25"] = cc.size(280, 200),
        ["26"] = cc.size(160, 80),
        ["27"] = cc.size(60, 110),
        ["601"] = cc.size(60, 30),
        ["602"] = cc.size(60, 30),
        ["603"] = cc.size(80, 35),
        ["604"] = cc.size(80, 60),
        ["605"] = cc.size(80, 60),
        ["606"] = cc.size(60, 60),
        ["607"] = cc.size(80, 60),
        ["608"] = cc.size(80, 60),
        ["609"] = cc.size(110, 50),
        ["610"] = cc.size(110, 80),
        ["611"] = cc.size(100, 30),
        ["612"] = cc.size(110, 40),
        ["613"] = cc.size(150, 80),
        ["614"] = cc.size(110, 60),
        ["615"] = cc.size(110, 60),
        ["616"] = cc.size(60, 60),
        ["617"] = cc.size(110, 60),
        ["618"] = cc.size(110, 60),
        ["619"] = cc.size(110, 50),
        ["620"] = cc.size(110, 80),
        ["621"] = cc.size(40, 45),
        ["622"] = cc.size(40, 30),
        ["701"] = cc.size(30, 10),
        ["702"] = cc.size(30, 10),
        ["703"] = cc.size(40, 15),
        ["704"] = cc.size(40, 30),
        ["705"] = cc.size(40, 30),
        ["706"] = cc.size(40, 30),
        ["707"] = cc.size(40, 30),
        ["708"] = cc.size(40, 30),
        ["709"] = cc.size(55, 25),
        ["710"] = cc.size(50, 30),
        ["801"] = cc.size(30, 10),
        ["802"] = cc.size(30, 12),
        ["803"] = cc.size(40, 15),
        ["804"] = cc.size(40, 30),
        ["805"] = cc.size(40, 30),
        ["806"] = cc.size(40, 30),
        ["807"] = cc.size(50, 50),
        ["808"] = cc.size(50, 30),
        ["809"] = cc.size(50, 30),
        ["910"] = cc.size(50, 40),
        ["920"] = cc.size(100, 120),
        ["930"] = cc.size(70, 30),
        ["940"] = cc.size(110, 30)
    }
    local fishOffset = {
        ["1"] = cc.p(0, 0),
        ["2"] = cc.p(0, 0),
        ["3"] = cc.p(0, 0),
        ["4"] = cc.p(0, 0),
        ["5"] = cc.p(0, 0),
        ["6"] = cc.p(0, 0),
        ["7"] = cc.p(0, 0),
        ["8"] = cc.p(0, 0),
        ["9"] = cc.p(0, 0),
        ["10"] = cc.p(0, 0),
        ["11"] = cc.p(0, 0),
        ["12"] = cc.p(0, 0),
        ["13"] = cc.p(0, 0),
        ["14"] = cc.p(0, 0),
        ["15"] = cc.p(0, 0),
        ["16"] = cc.p(0, 0),
        ["17"] = cc.p(0, 0),
        ["18"] = cc.p(0, 0),
        ["19"] = cc.p(0, 0),
        ["20"] = cc.p(0, 0),
        ["21"] = cc.p(0, 0),
        ["22"] = cc.p(0, 0),
        ["23"] = cc.p(0, 0),
        ["24"] = cc.p(0, 0),
        ["25"] = cc.p(0, 80),
        ["26"] = cc.p(0, 0),
        ["27"] = cc.p(0, 40),
        ["601"] = cc.p(0, 0),
        ["602"] = cc.p(0, 0),
        ["603"] = cc.p(0, 0),
        ["604"] = cc.p(0, 0),
        ["605"] = cc.p(0, 0),
        ["606"] = cc.p(0, 0),
        ["607"] = cc.p(0, 0),
        ["608"] = cc.p(0, 0),
        ["609"] = cc.p(0, 0),
        ["610"] = cc.p(0, 0),
        ["611"] = cc.p(0, 0),
        ["612"] = cc.p(0, 0),
        ["613"] = cc.p(0, 0),
        ["614"] = cc.p(0, 0),
        ["615"] = cc.p(0, 0),
        ["616"] = cc.p(0, 0),
        ["617"] = cc.p(0, 0),
        ["618"] = cc.p(0, 0),
        ["619"] = cc.p(0, 0),
        ["620"] = cc.p(0, 0),
        ["621"] = cc.p(0, 0),
        ["622"] = cc.p(0, 0),
        ["701"] = cc.p(0, 0),
        ["702"] = cc.p(0, 0),
        ["703"] = cc.p(0, 0),
        ["704"] = cc.p(0, 0),
        ["705"] = cc.p(0, 0),
        ["706"] = cc.p(0, 0),
        ["707"] = cc.p(0, 0),
        ["708"] = cc.p(0, 0),
        ["709"] = cc.p(0, 0),
        ["710"] = cc.p(0, 0),
        ["801"] = cc.p(0, 0),
        ["802"] = cc.p(0, 0),
        ["803"] = cc.p(0, 0),
        ["804"] = cc.p(0, 0),
        ["805"] = cc.p(0, 0),
        ["806"] = cc.p(0, 0),
        ["807"] = cc.p(0, 0),
        ["808"] = cc.p(0, 0),
        ["809"] = cc.p(0, 0),
        ["910"] = cc.p(0, 0),
        ["920"] = cc.p(0, 0),
        ["930"] = cc.p(0, 0),
        ["940"] = cc.p(0, 0)
    }
    return fishBox[fishId], fishOffset[fishId]
end
function CollisionLayer:drawFishCollisionBox(obj, pos)
    local fishSize, fishOffset = self:getFishRectBoxByFishId(obj.fishData.TypeID)
    local scale = obj:getScale()
    local width = fishSize.width * scale
    local height = fishSize.height * scale
    local fishLeft = cc.vec3(pos.x - width + fishOffset.x, pos.y - height + fishOffset.y, pos.z)
    local fishRight = cc.vec3(pos.x + width + fishOffset.x, pos.y + height + fishOffset.y, pos.z)
    fishLeft = self.scene._camera:projectGL(fishLeft)
    fishRight = self.scene._camera:projectGL(fishRight)
    local centerP = cc.vec3(pos.x, pos.y, pos.z)
    centerP = self.scene._camera:projectGL(centerP)
    local fixWidth = math.abs(centerP.x - fishLeft.x)
    local fixHeight = math.abs(centerP.y - fishRight.y)
    local fixRect = cc.rect(centerP.x, centerP.y, fixWidth, fixHeight)
    local fishFixLeft = cc.p(fixRect.x + fixRect.width, fixRect.y)
    local fishFixRight = cc.p(fixRect.x - fixRect.width, fixRect.y)
    local fishFixTop = cc.p(fixRect.x, fixRect.y + fixRect.height)
    local fishFixBottom = cc.p(fixRect.x, fixRect.y - fixRect.height)
    if self.isDebug then
        self.darwNode2D:drawLine(fishFixLeft, fishFixRight, cc.c4f(1, 0, 0, 1))
        self.darwNode2D:drawLine(fishFixTop, fishFixBottom, cc.c4f(1, 0, 0, 1))
    end
    local hitIdx = 0
    for i = 1, #self.bulletAreaList do
        local areaTable = self.bulletAreaList[i]
        local area = areaTable[1]
        local bullet = areaTable[2]
        local bulletTop = area[1]
        local bulletBottom = area[2]
        local canCollision = true
        if bullet.lockingTarget ~= 0xFFFFFFFF then
            if obj.fishId ~= bullet.lockingTarget then
                canCollision = false
            end
        end
        if canCollision then
            if
                cc.pIsSegmentIntersect(fishFixLeft, fishFixRight, bulletTop, bulletBottom) or
                    cc.pIsSegmentIntersect(fishFixTop, fishFixBottom, bulletTop, bulletBottom)
             then
                hitIdx = i
                break
            end
        end
    end
    if hitIdx ~= 0 then
        obj:changeHurtAction()
        self.bulletAreaList[hitIdx][2].isDead = true
        self:sendCollision(self.bulletAreaList[hitIdx][2], obj)
    end
end
function CollisionLayer:sendCollision(bullet, fish)
    self.scene.gameController:sendHitFish(bullet, fish)
end
function CollisionLayer:getBulletCollisionArea(bullet)
    local pos = bullet:getPosition3D()
    local centerP = self.scene._camera:projectGL(pos)
    local bulletSize = bullet:getContentSize()
    local width = bulletSize.width
    local height = bulletSize.height
    local top = cc.vec3(pos.x, pos.y + height / 4, pos.z)
    local bottom = cc.vec3(pos.x, pos.y - height / 4, pos.z)
    top = self.scene._camera:projectGL(top)
    bottom = self.scene._camera:projectGL(bottom)
    local angle = bullet:getRotation()
    top = self:getPointByRotationPoint(centerP, top, angle)
    bottom = self:getPointByRotationPoint(centerP, bottom, angle)
    if self.isDebug then
        self.darwNode2D:drawLine(top, bottom, cc.c4f(1, 0, 0, 1))
    end
    return {top, bottom}
end
function CollisionLayer:getPointByRotationPoint(p0, p1, rotate)
    local p2 = cc.p(0, 0)
    local angle = rotate * 0.01745
    p2.x = (p1.x - p0.x) * math.cos(angle) + (p1.y - p0.y) * math.sin(angle) + p0.x
    p2.y = -(p1.x - p0.x) * math.sin(angle) + (p1.y - p0.y) * math.cos(angle) + p0.y
    return p2
end
function CollisionLayer:drawCollisionBox(obb, color)
    if not self.isDebug then
        return
    end
    local corners = {}
    for i = 1, 8 do
        corners[i] = {}
    end
    corners = obb:getCorners(corners)
    self._drawDebug:drawCube(corners, color)
end
function CollisionLayer:update(dt)
    if self.isDebug then
        if not tolua.isnull(self._drawDebug) then
            self._drawDebug:clear()
        end
        if not tolua.isnull(self.darwNode2D) then
            self.darwNode2D:clear()
        end
    end
    self.bulletAreaList = {}
    for i = 1, #self.bulletList do
        local bullet = self.bulletList[i]
        if not tolua.isnull(bullet) and not bullet.isDead then
            local area = self:getBulletCollisionArea(bullet)
            local areaTable = {area, bullet}
            table.insert(self.bulletAreaList, areaTable)
        end
    end
    for i = 1, #self.fishList do
        local fish = self.fishList[i]
        if not tolua.isnull(fish) and not fish.isDead and fish.hp > 0 then
            self:drawFishCollisionBox(fish, fish:getPosition3D())
        end
    end
end
return CollisionLayer
