--
-- Author: 
-- Date: 2018-08-07 18:17:10
-- 跑得快判断房间类型
local LandGlobalDefine = require("src.app.game.pdk.src.landcommon.data.LandGlobalDefine")

function IS_PAI_JU_HUIFANG( id )
	if id == LandGlobalDefine.FRIEND_REPLAY_ID then return true end
end

function IS_PAI_YOU_FANG( id )
	local data = RoomData:getRoomDataById( id )
	if not data or not data.roomType then return end
	if data.roomType == 5 then return true end
end

function IS_FAST_GAME( id )
	local data = RoomData:getRoomDataById( id )
	if not data or not data.roomType then return end
	if data.roomType == 2 then return true end
end

function IS_DING_DIAN_SAI( id )
	local data = RoomData:getRoomDataById( id )
	if not data or not data.roomType then return end
	if data.roomType == 3 then return true end
end

function IS_FREE_ROOM( id )
	local data = RoomData:getRoomDataById( id )
	if not data or not data.roomType then return end
	if data.roomType == 4 then return true end
end

function IS_HAPPY_LAND( id )
	local data = RoomData:getRoomDataById( id )
	if not data or not data.gameKindType then return end
	if data.gameKindType == 102 then return true end
end
function IS_CLASSIC_LAND( id )
	local data = RoomData:getRoomDataById( id )
	if not data or not data.gameKindType then return end
	if data.gameKindType == 101 then return true end
end
function IS_HAPPY_LAND_PROTAL( id )
	if id >= 120000 and id <= 121000 then return true end
end

function IS_LAND_LORD_PROTAL( id )
	if id >= 100000 and id <= 121000 then return true end
end

function CLASSIC_ROOM_TYPE( id )
	if id >= 110101 and id < 110200 then 
		return 1
	elseif id >= 110201 and id < 110300 then 
		return 2 
	elseif id >= 110301 and id < 110400 then 
		return 3 
	end
end

function HAPPY_ROOM_TYPE( id )
	if id >= 120101 and id < 120200 then 
		return 1
	elseif id >= 120201 and id < 120300 then 
		return 2 
	elseif id >= 120301 and id < 120400 then 
		return 3 
	end
end

function GET_GAME_GLOAL_TYPE( id )
	local data = RoomData:getRoomDataById( id )
	if not data or not data.gameKindType then return 101 end
	return data.gameKindType
end

function IS_LAND_LORD( id )
	local portalData = RoomData:getPortalDataByAtomId( id )
	if portalData and portalData.id == RoomData.LANDLORD then return true end
end