local GameWikiLayer =
    class(
    "GameWikiLayer",
    function()
        return display.newLayer(cc.c4b(0, 0, 0, 125))
    end
)
local module_pre = "game.yule.qpby.src"
local ExternalFun = appdf.req(appdf.EXTERNAL_SRC .. "ExternalFun")
local GameWikiDetailLayer = appdf.req(module_pre .. ".views.layer.GameWikiDetailLayer")
function GameWikiLayer:ctor(scene)
    self.scene = scene
    self:enableNodeEvents()
    self:setTouchEnabled(true)
    self:registerScriptTouchHandler(
        function(event, x, y)
            if event == "ended" then
                self:onClose()
            end
            return true
        end
    )
    self:addCamera()
    self:initUI()
end
function GameWikiLayer:addCamera()
    local zEye = display.height / 1.1566
    local winSize = cc.Director:getInstance():getWinSize()
    self.cameraWiki = cc.Camera:createPerspective(60, winSize.width / winSize.height, 100, 1000)
    self.cameraWiki:setCameraFlag(cc.CameraFlag.USER1)
    self.cameraWiki:setDepth(1)
    self.cameraWiki:addTo(self)
    self.cameraWiki:setPosition3D(cc.vec3(display.cx, display.cy, zEye))
    self.cameraWiki:lookAt(cc.vec3(display.cx, display.cy, 0), cc.vec3(0, 1, 0))
end
function GameWikiLayer:onEnter()
    self:showLayer()
end
function GameWikiLayer:initUI()
    self.wikiBg =
        ccui.ImageView:create("ui/wiki/tujian_bg.png"):setPosition(display.cx, display.cy):setAnchorPoint(0.5, 0.5):addTo(
        self
    ):setTouchEnabled(true):setCascadeOpacityEnabled(true)
    local wikiBgSize = self.wikiBg:getContentSize()
    local btnBack =
        ccui.Button:create("ui/wiki/Btn_Return.png"):setPosition(
        wikiBgSize.width / 2 - 574,
        wikiBgSize.height / 2 + 309
    ):addTo(self.wikiBg)
    btnBack:addTouchEventListener(
        function(ref, tType)
            if tType == ccui.TouchEventType.ended then
                ExternalFun.playCommonButtonClickEffect()
                self:onClose()
            end
        end
    )
    self.showType = 1
    self.btnNormal =
        ccui.Button:create("ui/wiki/Btn_putongyu.png", "ui/wiki/Btn_putongyu.png"):setPosition(
        wikiBgSize.width / 2 - 251,
        wikiBgSize.height / 2 + 307
    ):addTo(self.wikiBg)
    self.btnNormal:addTouchEventListener(
        function(ref, tType)
            if tType == ccui.TouchEventType.ended then
                ExternalFun.playCommonButtonClickEffect()
                self.showType = 1
                self:refreshButton()
            end
        end
    )
    self.btnBoss =
        ccui.Button:create("ui/wiki/Bth_bossyu.png", "ui/wiki/Bth_bossyu.png"):setPosition(
        wikiBgSize.width / 2 - 17,
        wikiBgSize.height / 2 + 307
    ):addTo(self.wikiBg):setOpacity(0)
    self.btnBoss:addTouchEventListener(
        function(ref, tType)
            if tType == ccui.TouchEventType.ended then
                ExternalFun.playCommonButtonClickEffect()
                self.showType = 2
                self:refreshButton()
            end
        end
    )
    self.btnSpecial =
        ccui.Button:create("ui/wiki/Bth_texiaoyu.png", "ui/wiki/Bth_texiaoyu.png"):setPosition(
        wikiBgSize.width / 2 + 215,
        wikiBgSize.height / 2 + 307
    ):addTo(self.wikiBg):setOpacity(0)
    self.btnSpecial:addTouchEventListener(
        function(ref, tType)
            if tType == ccui.TouchEventType.ended then
                ExternalFun.playCommonButtonClickEffect()
                self.showType = 3
                self:refreshButton()
            end
        end
    )
    self:loadNormalList()
    self:loadBossList()
    self:loadSpecialList()
end
function GameWikiLayer:loadSpecialList()
    self.specialList = self:addListView()
    self.specialList:hide()
    local dataTable = self.scene.configMgr:getWikiDataByType(3)
    local colNum = 4
    local rowNum = math.ceil(#dataTable / colNum)
    local rowWidth = 1260
    local rowHeight = 310
    local rowTable = {}
    for i = 1, rowNum do
        local bossRow =
            ccui.Layout:create():setContentSize(rowWidth, rowHeight):ignoreContentAdaptWithSize(false):setClippingEnabled(
            false
        ):setTouchEnabled(true):setCascadeColorEnabled(true):setCascadeOpacityEnabled(true):addTo(self.specialList)
        table.insert(rowTable, bossRow)
    end
    local itemTable = {}
    local rowIdx = 1
    local colIdx = 1
    local row = rowTable[rowIdx]
    for i = 1, #dataTable do
        local itemData = dataTable[i]
        local pos = cc.p(158 + 315 * (colIdx - 1), 155)
        local item = self:addSpecialListItem(row, pos, itemData):setTag(3000 + i)
        table.insert(itemTable, item)
        colIdx = colIdx + 1
        if i % colNum == 0 then
            rowIdx = rowIdx + 1
            colIdx = 1
            row = rowTable[rowIdx]
        end
    end
end
function GameWikiLayer:addSpecialListItem(parentNode, pos, itemData)
    local item =
        ccui.Button:create("ui/wiki/texiaoyu_bg.png", "ui/wiki/texiaoyu_bg.png"):setPosition(pos):addTo(parentNode)
    item:addTouchEventListener(
        function(ref, tType)
            if tType == ccui.TouchEventType.ended then
                ExternalFun.playCommonButtonClickEffect()
                local fishIdx = item:getTag() - 3000
                GameWikiDetailLayer.new(self, self.scene, 3, fishIdx):setPosition(0, 0):addTo(self):setCameraMask(
                    cc.CameraFlag.USER1
                )
            end
        end
    )
    local nameFile = string.format("ui/wiki/name/special/txt_%s.png", itemData.name)
    local nameImg = cc.Sprite:create(nameFile):setPosition(171, 265 + 36):addTo(item)
    local fishFile = string.format("ui/wiki/fish/special/yu_%s.png", itemData.name)
    local fishImg = cc.Sprite:create(fishFile):setPosition(171, 167 + 36):addTo(item)
    local textStr = string.format("x%sb", itemData.score)
    local betText = self:getPicText(textStr, itemData.introduction, 250):setPosition(31 + 13, 74 + 36 + 12):addTo(item)
    return item
end
function GameWikiLayer:addListView()
    local wikiBgSize = self.wikiBg:getContentSize()
    local listView =
        ccui.ListView:create():setContentSize(1260, 570):setDirection(1):setGravity(0):ignoreContentAdaptWithSize(false):setClippingEnabled(
        true
    ):setLayoutComponentEnabled(true):setCascadeColorEnabled(true):setCascadeOpacityEnabled(true):setAnchorPoint(
        0.5,
        0.5
    ):setPosition(cc.p(wikiBgSize.width / 2 + 1.4, wikiBgSize.height / 2 - 48)):addTo(self.wikiBg):setBounceEnabled(
        true
    )
    return listView
end
function GameWikiLayer:loadBossList()
    self.bossList = self:addListView()
    self.bossList:hide()
    local dataTable = self.scene.configMgr:getWikiDataByType(2)
    local colNum = 3
    local rowNum = math.ceil(#dataTable / colNum)
    local rowWidth = 1260
    local rowHeight = 468
    local rowTable = {}
    for i = 1, rowNum do
        local bossRow =
            ccui.Layout:create():setContentSize(rowWidth, rowHeight):ignoreContentAdaptWithSize(false):setClippingEnabled(
            false
        ):setTouchEnabled(true):setCascadeColorEnabled(true):setCascadeOpacityEnabled(true):addTo(self.bossList)
        table.insert(rowTable, bossRow)
    end
    local itemTable = {}
    local rowIdx = 1
    local colIdx = 1
    local row = rowTable[rowIdx]
    for i = 1, #dataTable do
        local itemData = dataTable[i]
        local pos = cc.p(210 + 420 * (colIdx - 1), 173)
        local item = self:addBossListItem(row, pos, itemData):setTag(2000 + i)
        table.insert(itemTable, item)
        colIdx = colIdx + 1
        if i % colNum == 0 then
            rowIdx = rowIdx + 1
            colIdx = 1
            row = rowTable[rowIdx]
        end
    end
end
function GameWikiLayer:addBossListItem(parentNode, pos, itemData)
    local item = ccui.Button:create("ui/wiki/boss_bg.png", "ui/wiki/boss_bg.png"):setPosition(pos):addTo(parentNode)
    item:addTouchEventListener(
        function(ref, tType)
            if tType == ccui.TouchEventType.ended then
                ExternalFun.playCommonButtonClickEffect()
                local fishIdx = item:getTag() - 2000
                GameWikiDetailLayer.new(self, self.scene, 2, fishIdx):setPosition(0, 0):addTo(self):setCameraMask(
                    cc.CameraFlag.USER1
                )
            end
        end
    )
    local nameFile = string.format("ui/wiki/name/boss/txt_%s.png", itemData.name)
    local nameImg = cc.Sprite:create(nameFile):setPosition(210, 367 + 91.5):addTo(item)
    local fishFile = string.format("ui/wiki/fish/boss/yu_%s.png", itemData.name)
    local fishImg = cc.Sprite:create(fishFile):setPosition(210, 244 + 91.5):addTo(item)
    local textStr = string.format("x%sb", itemData.score)
    local betText = self:getPicText(textStr, itemData.introduction, 345):setPosition(41, 119 + 91.5):addTo(item)
    return item
end
function GameWikiLayer:getPicText(textStr, desStr, richWidth)
    local richTxt = ccui.RichText:create()
    local anPoint = cc.p(0.5, 0.5)
    if richWidth then
        richTxt:ignoreContentAdaptWithSize(false)
        richTxt:setContentSize(cc.size(richWidth, 0))
        anPoint = cc.p(0, 0)
    end
    richTxt:setAnchorPoint(anPoint)
    local len = #textStr
    for i = 1, len do
        local contentStr = string.sub(textStr, i, i) or "0"
        if contentStr == "-" then
            contentStr = "zhi"
        elseif contentStr == "b" then
            contentStr = "bei"
        end
        local filePath = string.format("ui/wiki/number/beishu_%s.png", contentStr)
        local elem = ccui.RichElementImage:create(-1, cc.c3b(255, 255, 255), 255, filePath)
        richTxt:pushBackElement(elem)
    end
    if desStr then
        local elem = ccui.RichElementText:create(-1, cc.c3b(255, 255, 255), 255, desStr, "fonts/round_body.ttf", 20)
        richTxt:pushBackElement(elem)
    end
    richTxt:formatText()
    return richTxt
end
function GameWikiLayer:loadNormalList()
    self.normalList = self:addListView()
    local dataTable = self.scene.configMgr:getWikiDataByType(1)
    local colNum = 6
    local rowNum = math.ceil(#dataTable / colNum)
    local rowWidth = 1260
    local rowHeight = 270
    local rowTable = {}
    for i = 1, rowNum do
        local normalRow =
            ccui.Layout:create():setContentSize(rowWidth, rowHeight):ignoreContentAdaptWithSize(false):setClippingEnabled(
            false
        ):setTouchEnabled(true):setCascadeColorEnabled(true):setCascadeOpacityEnabled(true):addTo(self.normalList)
        table.insert(rowTable, normalRow)
    end
    local itemTable = {}
    local rowIdx = 1
    local colIdx = 1
    local row = rowTable[rowIdx]
    for i = 1, #dataTable do
        local itemData = dataTable[i]
        local pos = cc.p(103 + 210 * (colIdx - 1), 138)
        local item = self:addNormalListItem(row, pos, itemData):setTag(1000 + i)
        table.insert(itemTable, item)
        colIdx = colIdx + 1
        if i % colNum == 0 then
            rowIdx = rowIdx + 1
            colIdx = 1
            row = rowTable[rowIdx]
        end
    end
end
function GameWikiLayer:addNormalListItem(parentNode, pos, itemData)
    local item =
        ccui.Button:create("ui/wiki/putongyu_bg.png", "ui/wiki/putongyu_bg.png"):setPosition(pos):addTo(parentNode)
    item:addTouchEventListener(
        function(ref, tType)
            if tType == ccui.TouchEventType.ended then
                ExternalFun.playCommonButtonClickEffect()
                local fishIdx = item:getTag() - 1000
                GameWikiDetailLayer.new(self, self.scene, 1, fishIdx):setPosition(0, 0):addTo(self):setCameraMask(
                    cc.CameraFlag.USER1
                )
            end
        end
    )
    local nameFile = string.format("ui/wiki/name/normal/txt_%s.png", itemData.name)
    local nameImg = cc.Sprite:create(nameFile):setPosition(102, 245):addTo(item)
    local fishFile = string.format("ui/wiki/fish/normal/yu_%s.png", itemData.name)
    local fishImg = cc.Sprite:create(fishFile):setPosition(102, 147):addTo(item)
    local textStr = string.format("x%sb", itemData.score)
    local betText = self:getPicText(textStr):setPosition(102, 46):addTo(item)
    return item
end
function GameWikiLayer:refreshButton()
    if self.showType == 1 then
        self.btnNormal:setOpacity(255)
        self.btnBoss:setOpacity(0)
        self.btnSpecial:setOpacity(0)
        self.normalList:show()
        self.bossList:hide()
        self.specialList:hide()
    elseif self.showType == 2 then
        self.btnNormal:setOpacity(0)
        self.btnBoss:setOpacity(255)
        self.btnSpecial:setOpacity(0)
        self.normalList:hide()
        self.bossList:show()
        self.specialList:hide()
    else
        self.btnNormal:setOpacity(0)
        self.btnBoss:setOpacity(0)
        self.btnSpecial:setOpacity(255)
        self.normalList:hide()
        self.bossList:hide()
        self.specialList:show()
    end
end
function GameWikiLayer:showLayer()
    self.wikiBg:stopAllActions()
    self.wikiBg:setScale(0.8)
    self.wikiBg:setOpacity(255 * 0)
    local fadeIn = cc.FadeIn:create(0.07)
    local bigger = cc.ScaleTo:create(0.07, 1.02)
    local spawn = cc.Spawn:create(fadeIn, bigger)
    local reNormal = cc.ScaleTo:create(0.21, 1.0)
    local seq = cc.Sequence:create(spawn, reNormal)
    self.wikiBg:runAction(seq)
end
function GameWikiLayer:hideBg(callBack)
    self.wikiBg:stopAllActions()
    self.wikiBg:setScale(1.0)
    self.wikiBg:setOpacity(255 * 1.0)
    local spawnTime = 0.1
    local moveUp = cc.MoveBy:create(spawnTime, cc.p(0, 20))
    local fadeOut = cc.FadeOut:create(spawnTime)
    local smaller = cc.ScaleTo:create(spawnTime, 0.8)
    local spawn = cc.Spawn:create(moveUp, fadeOut, smaller)
    local callFun =
        cc.CallFunc:create(
        function()
            if callBack then
                callBack()
            end
        end
    )
    local seq = cc.Sequence:create(spawn, callFun)
    self.wikiBg:runAction(seq)
end
function GameWikiLayer:onClose()
    local function callBack()
        self:stopAllActions()
        self:removeFromParent()
    end
    self:hideBg(callBack)
end
function GameWikiLayer:onCleanup()
    if not tolua.isnull(self.cameraWiki) then
        self.cameraWiki:removeFromParent()
    end
end
return GameWikiLayer
