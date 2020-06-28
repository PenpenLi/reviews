-- LandPublicController
-- Author: 
-- Date: 2018-08-07 18:17:10
-- 跑得快公共场景管理器

local LandPublicController  = class("LandPublicController")
LandPublicController.instance = LandPublicController.instance or nil

function LandPublicController:getInstance()
	if LandPublicController.instance == nil then
		LandPublicController.instance = LandPublicController.new()
	end
    return LandPublicController.instance
end

function LandPublicController:ctor()
    self.biao_qing_cd = {}
end

function LandPublicController:setLastSendBiaoQing( uid , timeStamp )
	self.biao_qing_cd[ uid ] = timeStamp
end

function LandPublicController:getBiaoQingCD( uid )
	return self.biao_qing_cd[ uid ] or 0
end

return LandPublicController