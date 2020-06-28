--
-- Author: 
-- Date: 2018-08-07 18:17:10
-- 地主和农民骨骼动画
-- 
local LandLordArmature = class("LandLordArmature" ,function()
	  return display.newNode()
end)


function LandLordArmature:ctor( _name )
	self.armatureName = _name
	self:create()
end


function LandLordArmature:create( ... )
	local path = "src/app/game/pdk/res/animation/"..self.armatureName.."/"
	self.armature = ToolKit:createArmatureAnimation( path , self.armatureName )
	self.animation = self.armature:getAnimation()
	self:addChild( self.armature )
end

function LandLordArmature:playAnimationByName( target , _loop  , _durationTo )
	local durationTo = _durationTo or -1
	local loop = _loop and 1 or 0
	self.animation:play( target , durationTo , loop )
end

function LandLordArmature:playByKey( ... )
	self.animation:playWithIndex(3,-1,1)
end

return  LandLordArmature
