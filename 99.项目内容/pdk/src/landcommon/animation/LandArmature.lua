--
-- LandArmature
-- Author: 
-- Date: 2018-08-07 18:17:10
-- 骨骼动画封装
-- 
local landArmatureResource = require ("app.game.pdk.src.landcommon.animation.LandArmatureResource")

	
local LandArmature = class("LandArmature" ,function()
	  return display.newNode()
end)

LandArmature._movementType = ccs.MovementEventType.complete  --动画类型（非循环/循环)

function LandArmature:ctor( resourceById ,animationLayer, _handlerBack)
    print("LandArmature_____LandArmature", resourceById ,animationLayer, _handlerBack)
     self.m_animationLayer = animationLayer
     self.handlerBack = _handlerBack
     self.armatureResourceInfo  = landArmatureResource:getArmatureResourceById( resourceById )
     self:loadAnimation()
end

--加载骨骼动画数据
function LandArmature:loadAnimation()
    dump(self.armatureResourceInfo)
    ccs.ArmatureDataManager:getInstance():addArmatureFileInfo( self.armatureResourceInfo.configFilePath )
    local isFileExist = cc.FileUtils:getInstance():isFileExist( self.armatureResourceInfo.configFilePath )
    if isFileExist then
        print("function LandArmature:loadAnimation()".. self.armatureResourceInfo.configFilePath)
        self.armature = ccs.Armature:create(self.armatureResourceInfo.armatureName)
        self.armature:setScale(self.armatureResourceInfo.scale)
        --动画播放回调
        self.armature:getAnimation():setMovementEventCallFunc(handler(self,self.animationEvent))
        self:addChild( self.armature )
    end
end

function LandArmature:setMovementEventCallFunc(_handlerBack)
    self.handlerBack = _handlerBack
    self.armature:getAnimation():setMovementEventCallFunc(handler(self,self.animationEvent1))
end
--动画播放回调
function LandArmature:animationEvent1( armatureBack, movementType, movementID )
    print("function LandArmature:animationEvent1( armatureBack, movementType, movementID )",armatureBack, movementType, movementID)
    --非循环播放一次
    --dump(self.armatureResourceInfo,"self.armatureResourceInfo:")
    if movementType == ccs.MovementEventType.complete then
        armatureBack:stopAllActions()
        if self.handlerBack then
            print("self.handlerBack")
           self.handlerBack()
        end
    end
 end

--播放动画
function LandArmature:playAnimation(isLoop)
    print("play animation  Name is:"..self.armatureResourceInfo.animationName)
    if not self.armature then
        self:loadAnimation()
    end
    if self.armature then
	   self.armature:getAnimation():play( self.armatureResourceInfo.animationName, -1 , isLoop and 1 or 0 )
    end
end

--播放动画
function LandArmature:playAnimationByName(animationName, isLoop)
    print("play animation  Name is:"..animationName)
    if not self.armature then
        self:loadAnimation()
    end
    if self.armature then
        self.armature:getAnimation():play(animationName, -1 , isLoop and 1 or 0 )
    end
end

function LandArmature:playAnimationByNames(animationNames, isLoop)
    dump(animationName, "play animation  Name is:")
    if not self.armature then
        self:loadAnimation()
    end
    if self.armature then
        self.armature:getAnimation():playWithNames(animationNames, -1, isLoop or false)
    end
end

--动画播放回调
function LandArmature:animationEvent( armatureBack, movementType, movementID )
    --非循环播放一次
    if movementType == ccs.MovementEventType.complete then
       if movementID == self.armatureResourceInfo.animationName then
            armatureBack:stopAllActions()
            if self.handlerBack then
               self.handlerBack()
            else
               self:clearArmatureFileInfo()
                self:removeFromParent()  
            end

       end
    end
 end

--清除骨骼数据
function  LandArmature:clearArmatureFileInfo()
	 ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo( self.armatureResourceInfo.configFilePath )
end

--停止动画
function  LandArmature:stopAllActionsEx()
    if self.armature then
       self.armature:stopAllActions()
    end
end


return  LandArmature
