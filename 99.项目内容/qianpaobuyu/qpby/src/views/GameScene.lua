local GameScene = class("GameScene", cc.Scene)
local module_pre = "game.yule.qpby.src"
local ExternalFun = appdf.req(appdf.EXTERNAL_SRC .. "ExternalFun")
local GameController = appdf.req(module_pre .. ".views.layer.GameController")
local GameLayer = appdf.req(module_pre .. ".views.GameLayer")
local GameFrameEngine = appdf.req(appdf.CLIENT_SRC .. "plaza.models.GameFrameEngine")
local Game_CMD = appdf.req(module_pre .. ".models.CMD_LKPYGame")
local PathChecker = appdf.req(module_pre .. ".views.layer.PathChecker")
local PathTester = appdf.req(module_pre .. ".views.layer.PathTester")
local FishPathTester = appdf.req(module_pre .. ".views.layer.FishPathTester")
local GameConfigMgr = appdf.req(module_pre .. ".models.GameConfigMgr")
local FishVisual = appdf.req(module_pre .. ".views.layer.FishVisual")
function GameScene:ctor(plazzScene, frameEngine)
    self:setName("qpbyGameScene")
    self._plazzScene = plazzScene
    self._gameFrame = frameEngine
    self.maxPlayer = Game_CMD.GAME_PLAYER
    self.bFishStop = false
    self:enableNodeEvents()
    self:addSearchPath()
    self.configMgr = GameConfigMgr:create()
    self.gameController = GameController.new(self)
    self:initGameLayer()
    self:initLayers()
    self.gameController:initLayers()
    ExternalFun.playBackgroudMusic("sound/bgm/bgm1.mp3")
    ExternalFun.loadNightModel(self)
    self.isNoGameMessage = false
    self.isNoAutoQuit = false
end
function GameScene:update(dt)
    local fishList = self.fishLayer:getFishList()
    self.collisionLayer:setDataList(fishList, {})
    self.collisionLayer:update(dt)
end
function GameScene:onCleanup()
    if self._searchPath then
        cc.FileUtils:getInstance():setSearchPaths(self._searchPath)
    end
    local currentScene = cc.Director:getInstance():getRunningScene()
    local winSize = cc.Director:getInstance():getWinSize()
    local camera = currentScene:getDefaultCamera()
    camera:initDefault()
    self.gameController:finalizer()
    if self.timerId then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.timerId)
    end
end
function GameScene:initGameLayer()
    self.messageLayer = GameLayer:create(self._gameFrame, self):addTo(self)
    self._gameFrame:setViewFrame(self.messageLayer)
end
function GameScene:initLayers()
    self.backgroundLayer = self:getLayerByName("BackgroundLayer", 4)
    self.fishLayer = self:getLayerByName("FishLayer", 5)
    self.collisionLayer = self:getLayerByName("CollisionLayer", 11)
    self.bulletLayer = self:getLayerByName("BulletLayer", 7)
    self.cannonLayer = self:getLayerByName("CannonLayer", 8)
    self.effectLayer = self:getLayerByName("EffectLayer", 9)
    self.uiLayer = self:getLayerByName("UILayer", 10)
end
function GameScene:nextPath()
    self.pathId = self.pathId + 1
    local pathTable = self.fishLayer:getPathByPathId(self.pathId)
    self.pathChecker:drawPathBox(pathTable, self.pathId)
end
function GameScene:getLayerByName(layerName, zOrder)
    local filePath = string.format("%s.views.layer.%s", module_pre, layerName)
    local resLayer = appdf.req(filePath)
    local showLayer =
        resLayer.new(self):setName(layerName):setPosition(0, 0):addTo(self, zOrder):setGlobalZOrder(zOrder)
    return showLayer
end
function GameScene:createFishes()
    self.fishLayer:createFishes()
end
function GameScene:onEnter()
    self:initCamera()
end
function GameScene:initCamera()
    local zEye = display.height / 1.1566
    local currentScene = cc.Director:getInstance():getRunningScene()
    local winSize = cc.Director:getInstance():getWinSize()
    self._camera = currentScene:getDefaultCamera()
    self._camera:initPerspective(60, winSize.width / winSize.height, 300, 5000)
end
function GameScene:addSearchPath()
    local oldPaths = cc.FileUtils:getInstance():getSearchPaths()
    local gameSearchPath = device.writablePath .. "game/yule/qpby/res"
    gameSearchPath = string.format("%s/", gameSearchPath)
    local isHave = false
    for k, v in pairs(oldPaths) do
        if tostring(v) == tostring(gameSearchPath) then
            isHave = true
            break
        end
    end
    if not isHave then
        self._searchPath = oldPaths
        cc.FileUtils:getInstance():addSearchPath(gameSearchPath)
    end
end
return GameScene
