local ExternalFun = appdf.req(appdf.EXTERNAL_SRC .. "ExternalFun")
local RoomLayer = appdf.req(appdf.CLIENT_SRC .. "plaza.views.layer.room.RoomLayer")
local GameRoomLayer = class("GameRoomLayer", RoomLayer)
function GameRoomLayer:ctor(frameEngine, scene, bQuickStart)
    GameRoomLayer.super.ctor(self, frameEngine, scene, bQuickStart)
    self._frameEngine = frameEngine
end
function GameRoomLayer:getRoomLevelStr()
    local levelStr = "浣撻獙鍦�"
    local roomInfo = GlobalUserItem.GetRoomInfo()
    if roomInfo and roomInfo.wServerLevel then
        if roomInfo.wServerLevel == 1 then
            levelStr = "鐧惧€嶅満"
        elseif roomInfo.wServerLevel == 2 then
            levelStr = "鍗冪偖鍦�"
        elseif roomInfo.wServerLevel == 3 then
            levelStr = "涓囩偖鍦�"
        elseif roomInfo.wServerLevel == 4 then
            levelStr = "鍗佷竾鐐満"
        elseif roomInfo.wServerLevel == 5 then
            levelStr = "涓変竾鐐満"
        end
    end
    return levelStr
end
return GameRoomLayer
