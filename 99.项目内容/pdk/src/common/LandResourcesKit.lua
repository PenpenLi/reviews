--
-- Author: 
-- Date: 2018-08-07 18:17:10
-- 跑得快资源管理
local lord_game_resources = {
	[1]  = "src/app/game/pdk/res/csb/resouces/bigpoker1.plist",
	[2]  = "src/app/game/pdk/res/csb/resouces/bigpoker2.plist",
	[3]  = "src/app/game/pdk/res/csb/resouces/smallpoker.plist",
	[4]  = "src/app/game/pdk/res/csb/resouces/friendroom.plist",
	[5]  = "src/app/game/pdk/res/csb/resouces/happy_land.plist",
	[6]  = "src/app/game/pdk/res/csb/resouces/land_fight.plist",
	[7]  = "src/app/game/pdk/res/csb/resouces/land_jieshuan.plist",
	[8]  = "src/app/game/pdk/res/csb/resouces/landmatch.plist",
	[9]  = "src/app/game/pdk/res/csb/resouces/happy_small_poker.plist",
	[10] = "src/app/game/pdk/res/csb/resouces/small_long_poker.plist",
	[11] = "src/app/game/pdk/res/csb/resouces/land_player_state.plist",
	[12] = "src/app/game/pdk/res/csb/resouces/landmatch1.plist",
	"src/app/game/pdk/res/alter/FJGameBase.plist",
	"src/app/game/pdk/res/alter/FJPokerRes.plist",
	"src/app/game/pdk/res/alter/FJGameResult.plist",
	"src/app/game/pdk/res/alter/FJAnim.plist",
	"src/app/game/pdk/res/alter/FJAnimBomb.plist",
	"src/app/game/pdk/res/alter/FJAnimFJ.plist",
	"src/app/game/pdk/res/alter/FJAnimPlane.plist",
}

local function load_tbl( tbl )
	local helper  = require("app.hall.base.util.AsyncLoadRes").new()
	for k,v in pairs( tbl ) do
		helper:loadBlock( v )
	end
end

local LandResourcesKit = {}

function LandResourcesKit:LOAD_GAME_RESOURCES()
	load_tbl( lord_game_resources )
end

function LandResourcesKit:ADD_LAND_SEARCH_PATH()
	ToolKit:addSearchPath("src/app/game/pdk/src")
	ToolKit:addSearchPath("src/app/game/pdk/src/landcommon")
    ToolKit:addSearchPath("src/app/game/pdk/res")
    ToolKit:addSearchPath("src/app/game/pdk/res/csb")
    ToolKit:addSearchPath("src/app/game/pdk/res/animation")
    ToolKit:addSearchPath("src/app/game/pdk/res/csb/resouces")
end

-- ADD_LAND_SEARCH_PATH()

return LandResourcesKit