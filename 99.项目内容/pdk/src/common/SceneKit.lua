--
-- Author: 
-- Date: 2018-08-07 18:17:10
-- 跑得快场景工具
local scheduler           = require("framework.scheduler")
local LandGlobalDefine      = require("src.app.game.pdk.src.landcommon.data.LandGlobalDefine")

local game_scene_path = "src.app.game.pdk.src.classicland.scene.LandGameMainScene"

function REQ_ENTER_SCENE( atom )
	LogINFO("请求进入场景,",atom)
	g_GameController:reqEnterScene( atom )
end

function REQ_ENTER_CLASSIC_LORD(callback)
	local info = 
	{
		["m_portalId"]        = 110000,
		["m_portalList"]      = {{["m_portalId"]=110100},{["m_portalId"]=110200}}
	}

	--[[if callback then
		callback(info)
	else
		DOHALL("showLandHallPortal",info)
	end--]]

	--sendMsg(PublicGameMsg.MSG_PUBLIC_ENTER_GAME, { id = tbl[i].m_portalId , lcount = 1 } )
		
	sendMsg(PublicGameMsg.MSG_PUBLIC_ENTER_GAME, { id = 110100 , lcount = 1 } )
end

function REQ_ENTER_HAPPY_LORD()
	local info = 
	{
		["m_portalId"]        = 120000,
		["m_portalList"]      = {{["m_portalId"]=120100},{["m_portalId"]=120200}}
	}
	
	--DOHALL("showLandHallPortal",info)
	
	sendMsg(PublicGameMsg.MSG_PUBLIC_ENTER_GAME, { id = 120100 , lcount = 1 } )
end

function LOAD_GAMEMSG_CALLBACK()
	RequireEX("app.game.pdk.src.common.GameMsgCallBack")
end

function PRELOAD_GAME_SCENE( atom )
	LOAD_GAMEMSG_CALLBACK()
	POP_GAME_SCENE()
	SHOW_GAME_ROOM_BG( atom )
end

function PUSH_GAME_SCENE( atom )
	RequireEX( game_scene_path )
	HIDE_GAME_ROOM_BG()
	local scene = UIAdapter:pushScene( game_scene_path , DIRECTION.HORIZONTAL , atom )
	return scene
end

function POP_GAME_SCENE()
	if not LAST_POP_GAME_SCENE_FRAME then LAST_POP_GAME_SCENE_FRAME = 0 end
	if GET_CUR_FRAME() - LAST_POP_GAME_SCENE_FRAME < 1 then return end
	LAST_POP_GAME_SCENE_FRAME = GET_CUR_FRAME()
	local scene = cc.Director:getInstance():getRunningScene()
	if scene.class and scene.class.__cname then
		if scene.class.__cname == "LandGameMainScene" then
			UIAdapter:popScene()
		end
	end
	HIDE_GAME_ROOM_BG()
end

function POP_LORD_SCENE()
	local scene = cc.Director:getInstance():getRunningScene()
	if scene.class and scene.class.__cname then
		if scene.class.__cname == "LandLord" then
			UIAdapter:popScene()
		end
	end
end

function IN_LORD_SCENE()
	local scene = cc.Director:getInstance():getRunningScene()
	if scene.class and scene.class.__cname then
		if scene.class.__cname == "LandLord" then
			return true
		end
	end
end

function GET_LORD_SCENE()
	local scene = cc.Director:getInstance():getRunningScene()
	if scene.class and scene.class.__cname then
		if scene.class.__cname == "LandLord" then
			return scene
		end
	end
end

function GET_GAME_SCENE()
	local scene = cc.Director:getInstance():getRunningScene()
	if scene.class and scene.class.__cname then
		if scene.class.__cname == "LandGameMainScene" then
			return scene
		end
	end
end

function GAME_SCENE_DO( funName , ... )
	local scene = GET_GAME_SCENE()
	if scene and type( scene[ funName ] ) == "function" then
		return scene[ funName ]( scene , ... )
	end
end

function FRIEND_ROOM_SCENE_DO( funName , ... )
	local scene = GET_GAME_SCENE()
	if scene and IS_PAI_YOU_FANG( scene.game_atom ) and type( scene[ funName ] ) == "function" then
		scene[ funName ]( scene , ... )
	end
end

function DOHALL_CENTER( funName , ... )
	local layer = GET_HALL_CENTER()
	if layer and type( layer[funName] ) == "function" then
		return layer[funName]( layer , ... )
	end
end

function DOHALL( funName , ... )
	local hall = GET_LORD_HALL()
	if hall and hall[ funName ] and type( hall[ funName ] ) == "function" then
		hall[ funName ]( hall , ... )
	end
end

function GET_HALL_CENTER()
	local hall = GET_LORD_HALL()
	if not hall then return end
	if hall and hall.center_layer then return hall.center_layer end
end

function GET_LORD_HALL()
	local scene = GET_LORD_SCENE()
	if not scene then return end
	return scene.hall
end

function SHOW_GAME_ROOM_BG(game_atom)
	for k,v in pairs( UIAdapter.sceneStack ) do
		if v.class and v.class.__cname and v.class.__cname == "LandLord" then
			if v.hall and v.hall.gameRoomBG then
				v.hall:showGameRoomBG(game_atom)
				return v.hall.gameRoomBG
			end
		end
	end
end

function HIDE_GAME_ROOM_BG()
	for k,v in pairs( UIAdapter.sceneStack ) do
		if v.class and v.class.__cname and v.class.__cname == "LandLord" then
			if v.hall then
				v.hall:hideGameRoomBG()
			end
		end
	end
end