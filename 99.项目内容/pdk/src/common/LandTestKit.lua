-- Author: 
-- Date: 2018-08-07 18:17:10
-- 跑得快辅助测试工具

function TEST_DEFAULT()
	RELOAD_GAME_SCENE()
end

function RELOAD_GAME_SCENE()
	local scene = PUSH_GAME_SCENE( 101021 )
	scene:addSystemSetLayer()
	local layer = RequireEX("src.app.game.pdk.src.landcommon.view.LandAccounts").new( scene , "win" , scene.game_atom )
	layer:updateGameResult()
	scene:addChild( layer )
end

function POP_LAND_DIALOG()
	local dlg = RequireEX("app.game.pdk.src.landcommon.view.LandDiaLog").new()
	dlg:hideCloseBtn()
end

function TEST_MATCH_WIN_LOSE()
	

end

function BUY_FANGKA()
	local items = {{1,9999,100,"{}"}}
	ConnectManager:send2Server(Protocol.LobbyServer, "CS_C2H_AddItem_Req", { items } )
end
