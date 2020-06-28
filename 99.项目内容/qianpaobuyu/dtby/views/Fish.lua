local FishSprite = class("FishSprite", cc.Sprite)
local Game_CMD = require("app.views.Common")

function FishSprite:ctor(type,speed,pathIndex,bodyList,parentNode)
    self.live = type --血量
    self.isDie = false
    self.m_type = type
    self.m_speed = speed
    self.fscene = nil
    self.index = 1
    self.Xpos = 0
    self.Ypos = 0
    self.m_pathIndex = pathIndex
    self.mX = -1
    self.mY = -1
    self.disAngle = 0
    self.fortieth = 0
    self.CurrPathindex = 1
    self.m_bodyList = bodyList
    self.m_parentNode = parentNode
    self.alreadyDie = false --判断是否已经死亡,即判断是否需要播放金币动画

    if self.m_pathIndex < 36 then
        if self.m_pathIndex ~= 1 and self.m_pathIndex ~= 4 and self.m_pathIndex ~= 10 and self.m_pathIndex ~= 20 and self.m_pathIndex ~= 33 and self.m_pathIndex ~= 34 then
            self.disAngle = 180
        end
    end
    self:switchY(self.m_pathIndex)
    self:switchX(self.m_pathIndex)

    --目前肯定不会调用的判断
    if self.m_pathIndex == 48 and self.type < 10 then
        self.Xpos=Game_CMD.PathIndex[self.m_pathIndex][1][1] - 180 * math.cos(math.rad(12*self.fortieth))
        self.Ypos=Game_CMD.PathIndex[self.m_pathIndex][1][2] + 180 * math.sin(math.rad(12*self.fortieth))
        self.fortieth = self.fortieth +1
        if self.fortieth >29 then
        self.fortieth = 0
        end
    else
        self.Xpos=Game_CMD.PathIndex[self.m_pathIndex][1][1]
        self.Ypos=Game_CMD.PathIndex[self.m_pathIndex][1][2]
    end

    self.Rolation=Game_CMD.PathIndex[self.m_pathIndex][1][3]
    self.m_speed=Game_CMD.PathIndex[self.m_pathIndex][1][4]*1.6

    if self.Xpos<1000 and self.Xpos>0 and self.m_pathIndex ~= 10 then
        self:setRotation(self.Rolation+180)
    else
        local fAngle = false
        local angle = 180
        local fswitchA = self:switchA(self.m_pathIndex)
        if fswitchA then
            fAngle = fswitchA
        end
        if fAngle then
            self:setRotation(self.Rolation + angle)
        else
            self:setRotation(self.Rolation)
        end
    end


    local file = string.format("fishMove_%03d_01.png", type)
    local actionName = string.format("animation_fish_move%d", type)
    self:initWithSpriteFrameName(file)
    local animation = cc.AnimationCache:getInstance():getAnimation(actionName)

    --影子
    local sprShadow = cc.Sprite:createWithSpriteFrame(self:getSpriteFrame())
    :setColor(cc.BLACK)
    :addTo(self)
    :setPosition(cc.p(self:getContentSize().width / 2+5, self:getContentSize().height / 2-10))
    :setLocalZOrder(-1)
    :setOpacity(200)

    if nil ~= animation then
        local action = cc.RepeatForever:create(cc.Animate:create(animation))
        self:runAction(action)
        self:setOpacity(0)
        self:runAction(cc.FadeTo:create(0.2,255))
        local action2 = cc.RepeatForever:create(cc.Animate:create(animation))
        sprShadow:runAction(action2)
    end

    self:initPhysicsBody()
end

--掉落金币
function FishSprite:fallingCoin()
    if self.live > 0 or self.alreadyDie == true then return
    elseif self.live <= 0 and self.alreadyDie == false then
        self.alreadyDie = true
        local armature = ccs.Armature:create("fish_jinbi_1")
        armature:setPosition(self.Xpos,self.Ypos)
        self.m_parentNode:addChild(armature,100)
        armature:getAnimation():play("idle",-1,1)
        armature:retain()
        armature:runAction(cc.Sequence:create(cc.DelayTime:create(0.7),cc.CallFunc:create(function()
            armature:removeFromParent(true)
            self.isDie = true
        end)))
    end
end

--重新计算鱼的尺寸
function FishSprite:getBodyByType(param)
    local param = string.format("fishMove_%03d_01", param)
    if #self.m_bodyList ~= 0 then
        for i=1,#self.m_bodyList do
            local sublist = self.m_bodyList[i]
            local k = sublist.k
            if k == param then
                local points = sublist.p
                local physicsBody = cc.PhysicsBody:create(PHYSICS_INFINITY, PHYSICS_INFINITY)
                for s=1,#points do
                    local onePoint = points[s]
                    local resultPoints = {}
                    for t=1,#onePoint do
                        local vector = onePoint[t]
                        local result = string.sub(vector, 2, -2)
                        local len = string.len(result)
                        local dindex = string.find(result,",")

                        local subx = string.sub(result,1,dindex-1)
                        local x = tonumber(subx)
                        local suby = string.sub(result,dindex+1,len)
                        local y = tonumber(suby)

                        local p = cc.p(x,y)
                        table.insert(resultPoints, p)
                    end
                    local center = cc.PhysicsShape:getPolyonCenter(resultPoints)
                    local shape = cc.PhysicsShapePolygon:create(resultPoints,cc.PHYSICSBODY_MATERIAL_DEFAULT,cc.p(-center.x, -center.y))
                    physicsBody:addShape(shape)
                    physicsBody:setGravityEnable(false)
                    return physicsBody
                end
            break
            end
        end
    end
end

function FishSprite:initPhysicsBody()
    local body = self:getBodyByType(self.m_type)
    if body == nil then print("body is nil") return end
    self:setPhysicsBody(body)
    --self:setPhysicsBody(cc.PhysicsBody:createBox(self:getContentSize()))
    --设置物理刚体类别掩码,可以通过检查或比较掩码来确定是否发生碰撞
    self:getPhysicsBody():setCategoryBitmask(1)
    --设置物理刚体碰撞掩码,可以通过检查或比较掩码来确定是否发生碰撞
    self:getPhysicsBody():setCollisionBitmask(0)
    --设置物理联系掩码,因为碰撞事件还是不会在默认状态下被接收
    self:getPhysicsBody():setContactTestBitmask(2)
    --设置子弹不受重力系数影响
    self:getPhysicsBody():setGravityEnable(false)
end

function FishSprite:getT()
    return 1
end

function FishSprite:setConvertPoint(point,angle)
    self:setPosition(point)
    self.Xpos = point.x
    self.Ypos = point.y
    if nil ~= angle then
        self:setRotation(angle)
    end
end

function FishSprite:setscene(sce)
    self.fscene = sce
end

--限制条件1
function FishSprite:switchY(num)
    if num == 1 or num == 4 or num == 10 or num == 20 or num == 33 then
        self.mY = 1
    elseif num == 34 then
        self.disAngle=175
    end
end

--限制条件2
function FishSprite:switchX(num)
    if num == 1 or num == 4 or num == 10 or num == 20 or num == 33 then
        self.mX=1
    end
end

function FishSprite:switchA(num)
    if num == 2 or num == 9 or num == 16 or num >= 25 and num <= 29 or num == 32 or num == 35 or num >= 45 and num <= 48 then
        return true
    else
        return false
    end
end

return FishSprite
