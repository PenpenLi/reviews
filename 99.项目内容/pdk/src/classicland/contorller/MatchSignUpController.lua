-- MatchSignUpController
-- Author: 
-- Date: 2018-08-07 18:17:10
-- 比赛报名管理器
local DDSRoomController      = require("src.app.game.pdk.src.classicland.contorller.DingDianSaiRoomController")
local FastRoomController     = require("src.app.game.pdk.src.classicland.contorller.FastRoomController")
local MatchSignUpController  = class("MatchSignUpController")
MatchSignUpController.instance = MatchSignUpController.instance or nil

function MatchSignUpController:getInstance()
	if MatchSignUpController.instance == nil then
		MatchSignUpController.instance = MatchSignUpController.new()
	end
    return MatchSignUpController.instance
end

function MatchSignUpController:ctor()
    
end

function MatchSignUpController:reqSignUp( atom , _contidion , _force , _showQiaoLuoDaGu )
	LogINFO("请求报名比赛 , atom : " , atom , "报名选项 : ", _contidion )
	self.__gameAtomTypeId = atom
	if not IS_LAND_LORD( atom ) then return end
	local contidion = _contidion or 0
	local extenInfo = {}
	extenInfo["extend"] = _force or 0
	local str = require("cjson").encode( extenInfo )

	local function callBack( _info )
		self:ackSignUp( _info , _showQiaoLuoDaGu )
	end
	RoomTotalController:getInstance():matchSignUp( atom , contidion , callBack , str )
end

function MatchSignUpController:ackSignUp( _info , _showQiaoLuoDaGu )
	if not IS_LAND_LORD( _info.m_gameAtomTypeId ) then return end
	dump( _info )
	if _info.m_ret == 0 then
		LogINFO("比赛报名成功")
		if _showQiaoLuoDaGu then
			GAME_SCENE_DO("exit")
			local bg = SHOW_GAME_ROOM_BG(self.__gameAtomTypeId)
			bg:showQiaoLuoDaGu()
		else
			DOHALL_CENTER("onBaoMingSuccess" , _info.m_gameAtomTypeId )
		end
		if IS_DING_DIAN_SAI( _info.m_gameAtomTypeId ) then
			DDSRoomController:getInstance():setSignUpStatus( _info.m_gameAtomTypeId ,  1 )
		elseif IS_FAST_GAME( _info.m_gameAtomTypeId ) then
			FastRoomController:getInstance():setSignUpStatus( _info.m_gameAtomTypeId , 1 )
		end
	elseif _info.m_ret < 0 then
		if _info.m_ret == -742 then
			LogINFO("金币不足")
			POP_GAME_SCENE()
			local function f()
			DOHALL_CENTER("showChongQiangMatch", _info.m_gameAtomTypeId)
			end
			DO_ON_FRAME(GET_CUR_FRAME()+2,f)
		elseif _info.m_ret ~= -20013 then
        	LAND_SHOW_ERROR_TIP(_info.m_ret)
        end
	end
end

function MatchSignUpController:reqCancelSignUp( target , from )
	LogINFO("请求取消比赛报名 , 取消目标是 : " , target , "为了报名哪个比赛发起的这个取消请求 : " , from )
	local extenInfo = {}
	extenInfo["fromGameAtomTypeId"] = from or 0
	local str = require("cjson").encode( extenInfo )
	local function callBack( _info )
		self:ackCancelSignUp( _info , from )
	end
	RoomTotalController:getInstance():cancelMatchSignUp( target , callBack , str )
end

function MatchSignUpController:ackCancelSignUp( _info , atom )
	if _info.m_ret == 0 then
		LogINFO("比赛取消报名成功,取消报名的游戏类型为," , _info.m_gameAtomTypeId , "接下来要报名,",atom )
		if GET_GAME_SCENE() then
			GAME_SCENE_DO("onCancelBaoMingSuccess")
		elseif GET_LORD_SCENE() then
			DOHALL_CENTER("onCancelBaoMingSuccess",_info.m_gameAtomTypeId)
		end
		if IS_DING_DIAN_SAI( _info.m_gameAtomTypeId ) then
			DDSRoomController:getInstance():setSignUpStatus( _info.m_gameAtomTypeId , 0  )
		elseif IS_FAST_GAME( _info.m_gameAtomTypeId ) then
			FastRoomController:getInstance():setSignUpStatus( _info.m_gameAtomTypeId , 0 )
		end
		
		
		if IS_LAND_LORD( atom ) then
			if atom ~= _info.m_gameAtomTypeId then
				if IS_FAST_GAME( atom ) or IS_DING_DIAN_SAI( atom ) then
					self:reqSignUp( atom )
				elseif IS_FREE_ROOM( atom ) then
					REQ_ENTER_SCENE( atom )
				end
			end
		end
	else
		LAND_SHOW_ERROR_TIP(_info.m_ret)
	end
end

return MatchSignUpController