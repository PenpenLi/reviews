local ExternalFun = appdf.req(appdf.EXTERNAL_SRC .. "ExternalFun")
local HeadSprite = appdf.req(appdf.EXTERNAL_SRC .. "HeadSprite")
local RoomListLayer = appdf.req(appdf.CLIENT_SRC .. "plaza.views.layer.plaza.RoomListLayer")
local GameRoomListLayer = class("GameRoomListLayer", RoomListLayer)
local module_pre = "game.yule.qpby.src"
appdf.req(module_pre .. ".models.QpbyResMgr")
local PreLoading = appdf.req(module_pre .. ".views.layer.PreLoading")
local ANI_PATH = "animation/"
local RES_ID = 140
function GameRoomListLayer:ctor(scene, frameEngine, isQuickStart)
    self.scene = scene
    GameRoomListLayer.super.ctor(self, scene, isQuickStart)
    self._frameEngine = frameEngine
    self.isNeedPerLoading = true
    if self.isNeedPerLoading then
        self:addPerLoading()
    end
end
function GameRoomListLayer:addPerLoading()
    local preLoadingLayer = PreLoading.new():setPosition(0, 0):addTo(self, 1000)
    QpbyResMgr:getInstance():preload()
end
function GameRoomListLayer:onEnterRoom(frameEngine)
    if nil ~= frameEngine and frameEngine:SitDown(yl.INVALID_TABLE, yl.INVALID_CHAIR) then
        return true
    end
end
function GameRoomListLayer:addSearchPath()
    self._searchPath = cc.FileUtils:getInstance():getSearchPaths()
    cc.FileUtils:getInstance():addSearchPath(device.writablePath .. "game/yule/qpby/res")
end
function GameRoomListLayer:onEnter()
end
function GameRoomListLayer:onExit()
end
function GameRoomListLayer:onCleanup()
    if QpbyResMgr then
        QpbyResMgr:getInstance():releaseAll()
    end
    cc.FileUtils:getInstance():setSearchPaths(self._searchPath)
end
function GameRoomListLayer:initBg()
    local bg = display.newSprite("roomlist/bg/Room_Background.jpg"):setPosition(display.cx, display.cy):addTo(self)
    local jsonName = "roomlist/animation/3dby_xuanfangwaterdi.json"
    local atlasName = "roomlist/animation/3dby_xuanfangwaterdi.atlas"
    local effectNode =
        sp.SkeletonAnimation:create(jsonName, atlasName, 1.0):setPosition(display.cx, display.cy):addTo(self):setAnimation(
        0,
        "animation",
        true
    )
    jsonName = "roomlist/animation/3dby_xuanfangwater.json"
    atlasName = "roomlist/animation/3dby_xuanfangwater.atlas"
    effectNode =
        sp.SkeletonAnimation:create(jsonName, atlasName, 1.0):setPosition(display.cx, display.cy):addTo(self):setAnimation(
        0,
        "animation",
        true
    )
end
function GameRoomListLayer:initTopUI(enterGame)
    local logoPath = "RoomList/logo/logo_" .. GlobalUserItem.nCurGameKind .. ".png"
    local gameLogo = display.newSprite(logoPath)
    if nil ~= gameLogo then
        local logoSize = gameLogo:getContentSize()
        local offsetX = logoSize.width > 300 and 10 or 30
        gameLogo:addTo(self):setPosition(
            display.width - logoSize.width / 2 - offsetX,
            display.height - logoSize.height / 2 - 10
        )
    end
    local backBtn =
        ccui.Button:create("roomlist/an_Return.png", "", "", 0):setPosition(54, display.height - 63):addTo(self):addTouchEventListener(
        function(ref, tType)
            if tType == ccui.TouchEventType.ended then
                ExternalFun.playCloseButtonClickEffect()
                self:removeFromParent()
            end
        end
    )
    local viewBtn =
        ccui.Button:create("roomlist/wenhao.png", "", "", 0):setPosition(115 + 44, display.height - 63 + 4):addTo(self):addTouchEventListener(
        function(ref, tType)
            if tType == ccui.TouchEventType.ended then
                ExternalFun.playCloseButtonClickEffect()
            end
        end
    )
    self._notify =
        display.newSprite("roomlist/yydb_num_bg.png"):setPosition(display.cx, display.height - 57):addTo(self):setCascadeOpacityEnabled(
        true
    )
    local stencil = display.newSprite():setAnchorPoint(cc.p(0, 0.5))
    stencil:setTextureRect(cc.rect(0, 0, 360, 30))
    self._notifyClip = cc.ClippingNode:create(stencil):setAnchorPoint(cc.p(0, 0.5))
    self._notifyClip:setInverted(false)
    self._notifyClip:setPosition(70, 18)
    self._notifyClip:addTo(self._notify)
    self._notifyClip:setCascadeOpacityEnabled(true)
    self._notifyText =
        cc.Label:createWithTTF("", "fonts/round_body.ttf", 22):addTo(self._notifyClip):setTextColor(
        cc.c4b(255, 255, 255, 255)
    ):setAnchorPoint(cc.p(0, 0.5)):enableOutline(cc.c4b(79, 48, 35, 255), 1)
    self.m_bNotifyRunning = false
    self:onChangeNotify(self.scene.m_tabSystemNotice[self.scene._sysIndex])
end
function GameRoomListLayer:onChangeNotify(msg)
    self._notifyText:stopAllActions()
    if not msg or not msg.str or #msg.str == 0 then
        self._notifyText:setString("")
        self.m_bNotifyRunning = false
        self.scene._tipIndex = 1
        self.scene._sysIndex = 1
        return
    end
    self.m_bNotifyRunning = true
    local msgcolor = cc.c4b(255, 255, 255, 255)
    self._notifyText:setVisible(false)
    self._notifyText:setString(msg.str)
    self._notifyText:setTextColor(msgcolor)
    if true == msg.autoremove then
        msg.showcount = msg.showcount or 0
        msg.showcount = msg.showcount - 1
        if msg.showcount <= 0 then
            self.scene:removeNoticeById(msg.id)
        end
    end
    local tmpWidth = self._notifyText:getContentSize().width
    self._notifyText:runAction(
        cc.Sequence:create(
            cc.CallFunc:create(
                function()
                    self._notifyText:setPosition(300 + 360, 0)
                    self._notifyText:setVisible(true)
                end
            ),
            cc.MoveTo:create(16 + (tmpWidth / 172), cc.p(0 - tmpWidth, 0)),
            cc.CallFunc:create(
                function()
                    local tipsSize = 0
                    local tips = {}
                    local index = 1
                    if 0 ~= #self.scene.m_tabInfoTips then
                        local tmp = self.scene._tipIndex + 1
                        if tmp > #self.scene.m_tabInfoTips then
                            tmp = 1
                        end
                        self.scene._tipIndex = tmp
                        self:onChangeNotify(self.scene.m_tabInfoTips[self.scene._tipIndex])
                    else
                        local tmp = self.scene._sysIndex + 1
                        if tmp > #self.scene.m_tabSystemNotice then
                            tmp = 1
                        end
                        self.scene._sysIndex = tmp
                        self:onChangeNotify(self.scene.m_tabSystemNotice[self.scene._sysIndex])
                    end
                end
            )
        )
    )
end
function GameRoomListLayer:initRoomButton()
    self.roomScrollView =
        ccui.ScrollView:create():setContentSize(cc.size(display.width, 540)):setPosition(cc.p(10, 100)):setDirection(2):setBounceEnabled(
        true
    ):setScrollBarEnabled(false):addTo(self, 100)
    local roomCount = #self.m_tabRoomListInfo
    local spaceX = 0
    local colNum = 8
    local rowNum = 1
    local intervalX = 360
    local intervalY = 240
    local scrollViewSize = cc.size(display.width, 540)
    if roomCount < 5 then
        self.roomScrollView:setInnerContainerSize(scrollViewSize)
        self.roomScrollView:setBounceEnabled(true)
    else
        scrollViewSize.width = roomCount * intervalX + spaceX * 2 + 50
        self.roomScrollView:setInnerContainerSize(scrollViewSize)
        self.roomScrollView:setBounceEnabled(true)
    end
    rowNum = math.ceil(roomCount / colNum)
    local enterGame = self._scene:getEnterGameInfo()
    for i = 1, roomCount do
        if i > 5 then
            break
        end
        local iteminfo = self.m_tabRoomListInfo[i]
        local wLv = (iteminfo == nil and 0 or iteminfo.wServerLevel)
        wLv = (wLv ~= 0) and wLv or 1
        local colIdx = (i - 1) % colNum + 1
        local rowIdx = math.ceil(i / colNum)
        local curColNum = roomCount - colNum * (rowIdx - 1)
        curColNum = curColNum > colNum and colNum or curColNum
        local posX = display.cx - (curColNum - 1) * (intervalX / 2) + (intervalX) * (colIdx - 1)
        if roomCount > 4 then
            posX = intervalX / 2 + (intervalX) * (i - 1)
        end
        local posY = display.cy - 125 + 15 + (rowNum - 1) * (intervalY / 2) - (intervalY) * (rowIdx - 1)
        local function btnGoldCallBack()
            if not iteminfo then
                return
            end
            GlobalUserItem.nCurRoomIndex = iteminfo._nRoomIndex
            GlobalUserItem.bPrivateRoom = (iteminfo.wServerType == yl.GAME_GENRE_PERSONAL)
            self:getParent():onStartGame()
        end
        local btnGold =
            ExternalFun.createLayoutButton(self.roomScrollView, cc.size(300, 490), cc.p(posX, posY), btnGoldCallBack)
        local spineIdx = wLv
        local btnSpine =
            sp.SkeletonAnimation:create(
            string.format("spine/room_spine_%d/spine.json", spineIdx),
            string.format("spine/room_spine_%d/spine.atlas", spineIdx),
            1
        ):setAnimation(0, "animation", true):setPosition(300 / 2, 230 - 111):addTo(btnGold)
        local btnEffect =
            sp.SkeletonAnimation:create("spine/room_spine_light/spine.json", "spine/room_spine_light/spine.atlas", 1):setAnimation(
            0,
            "animation",
            true
        ):setPosition(300 / 2, 230 - 111):addTo(btnGold)
        local btnParticle =
            cc.ParticleSystemQuad:create("spine/room_spine_particle/particle.plist"):setPosition(300 / 2, 230 - 111):addTo(
            btnGold
        )
        local enterScore = iteminfo.lEnterScore or 0
        if iteminfo.wServerType == 8 then
            enterScore = 0
        end
        if enterScore <= 0 then
            local minGold =
                display.newSprite("roomlist/dntgtest_play_free.png"):setPosition(0, -70):addTo(btnSpine, 100)
        elseif enterScore >= 10000 then
            if enterScore % 10000 ~= 0 then
                enterScore = string.format("%.1f", enterScore / 10000)
            else
                enterScore = math.ceil(enterScore / 10000)
            end
            local showStr = string.format("准入:%s万", enterScore)
            local label =
                ccui.Text:create(showStr, "", 24):setFontName("roomlist/round_body.ttf"):addTo(btnSpine, 100):setAnchorPoint(
                cc.p(0.5, 0.5)
            ):setPosition(0, -68):setTextColor(cc.c4b(210, 210, 210, 255))
        else
            local label =
                ccui.Text:create("准入:" .. enterScore, "", 24):setFontName("roomlist/round_body.ttf"):addTo(
                btnSpine,
                100
            ):setAnchorPoint(cc.p(0.5, 0.5)):setPosition(0, -68):setTextColor(cc.c4b(210, 210, 210, 255))
        end
    end
end
function GameRoomListLayer:initBottomUI()
    local bottomZorder = 10
    self.bottomLayer = display.newLayer():setPosition(0, 0):addTo(self, bottomZorder)
    local fastButtonNew =
        ccui.Button:create("roomlist/Start_game.png", "roomlist/Start_game.png"):setPosition(display.width - 185, 65):addTo(
        self.bottomLayer
    )
    fastButtonNew:addTouchEventListener(
        function(ref, type)
            if type == ccui.TouchEventType.ended then
                self:getParent():quickStartNew()
            end
        end
    )
    local infoBg = display.newSprite("roomlist/Head_bg.png"):setPosition(195, 48):addTo(self.bottomLayer)
    local head = HeadSprite:createClipHeadEx(GlobalUserItem, 96, "plaza/Hall_ZJM_Head_Bg_Boy.png")
    if not tolua.isnull(head) then
        local headBg =
            ccui.Button:create("plaza/Hall_ZJM_Head_Bg_Boy.png", "", ""):setPosition(53, 55):addTo(infoBg):setScale(
            0.74
        )
        local headBgSize = headBg:getContentSize()
        head:addTo(headBg)
        head:setPosition(headBgSize.width / 2, headBgSize.height / 2)
    end
    local nameStr = GlobalUserItem.szNickName
    nameStr = ExternalFun.subStringByWidth(nameStr, 180, "..", 18, "fonts/round_body.ttf")
    local nickName =
        cc.Label:createWithTTF(nameStr, "fonts/round_body.ttf", 18):setAnchorPoint(cc.p(0, 0.5)):setPosition(102, 67):setTextColor(
        cc.c4b(255, 255, 255, 255)
    ):addTo(infoBg)
    local beanBg = display.newSprite("roomlist/Ico_huanledou.png"):addTo(infoBg):setScale(0.9):setPosition(108, 42)
    local str = string.formatNumberThousands(GlobalUserItem.lUserScore, true, ":")
    self.userScore =
        ccui.TextAtlas:create(str, "roomlist/gold_number_collect.png", 16, 28, "0"):setScale(0.74):setAnchorPoint(
        cc.p(0, 0.5)
    ):setPosition(125, 40):addTo(infoBg)
    self:initListener()
end
return GameRoomListLayer
