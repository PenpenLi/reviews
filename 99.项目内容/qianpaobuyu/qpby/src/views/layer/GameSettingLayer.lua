local GameSettingLayer =
    class(
    "GameSettingLayer",
    function()
        return display.newLayer(cc.c4b(0, 0, 0, 125))
    end
)
local ExternalFun = appdf.req(appdf.EXTERNAL_SRC .. "ExternalFun")
function GameSettingLayer:ctor(scene)
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
    self:initUI()
    self:initButton()
end
function GameSettingLayer:initUI()
    self.settingBg =
        ccui.ImageView:create("ui/setting/tongyongtanchukuang.png"):setPosition(display.cx - 3, display.cy):setAnchorPoint(
        0.5,
        0.5
    ):addTo(self):setTouchEnabled(true):setCascadeOpacityEnabled(true)
    local title = display.newSprite("ui/setting/title_txt_shezhi.png"):setPosition(367, 446):addTo(self.settingBg)
    local scenePic = display.newSprite("ui/setting/biaoti.png"):setPosition(374, 229):addTo(self.settingBg)
    local musicPic = display.newSprite("ui/setting/yinyue.png"):setPosition(90, 316):addTo(self.settingBg)
    local effectPic = display.newSprite("ui/setting/yinxiao.png"):setPosition(313, 316):addTo(self.settingBg)
    local mutePic = display.newSprite("ui/setting/jingyin.png"):setPosition(536, 316):addTo(self.settingBg)
    local autoPic = display.newSprite("ui/setting/zidong.png"):setPosition(90, 138):addTo(self.settingBg)
    local dayPic = display.newSprite("ui/setting/baitian.png"):setPosition(313, 138):addTo(self.settingBg)
    local nightPic = display.newSprite("ui/setting/yinjian.png"):setPosition(536, 138):addTo(self.settingBg)
end
function GameSettingLayer:initButton()
    local function closeCallBack()
        self:onClose()
    end
    local btnClose = ExternalFun.createLayoutButton(self.settingBg, cc.size(80, 80), cc.p(669, 447), closeCallBack)
    local closeIcon = display.newSprite("ui/setting/tujian_yulan_colse.png"):setPosition(35, 49):addTo(btnClose)
    self.btnMusic = self:addSwitchButton(cc.p(187, 317), handler(self, self.musicCallBack))
    self.btnEffect = self:addSwitchButton(cc.p(187 + 223, 317), handler(self, self.effectCallBack))
    self.btnMute = self:addSwitchButton(cc.p(187 + 223 + 223, 317), handler(self, self.muteCallBack))
    self.btnAuto = self:addSwitchButton(cc.p(187, 137), handler(self, self.autoCallBack))
    self.btnDay = self:addSwitchButton(cc.p(410, 137), handler(self, self.dayCallBack))
    self.btnNight = self:addSwitchButton(cc.p(633, 137), handler(self, self.nightCallBack))
    self.btnMusic.isOn = GlobalUserItem.bVoiceAble
    self.btnMusic.changeOn(self.btnMusic.isOn)
    self.btnEffect.isOn = GlobalUserItem.bSoundAble
    self.btnEffect.changeOn(self.btnEffect.isOn)
    if not self.btnMusic.isOn and not self.btnEffect.isOn then
        self.btnMute.isOn = true
    else
        self.btnMute.isOn = false
    end
    self.btnMute.changeOn(self.btnMute.isOn)
    if GlobalUserItem.bAutoAble then
        self.btnDay.isOn = false
        self.btnNight.isOn = false
    else
        self.btnDay.isOn = GlobalUserItem.bDayAble
        self.btnNight.isOn = not GlobalUserItem.bDayAble
    end
    self.btnDay.changeOn(self.btnDay.isOn)
    self.btnNight.changeOn(self.btnNight.isOn)
    self.btnAuto.isOn = GlobalUserItem.bAutoAble
    self.btnAuto.changeOn(self.btnAuto.isOn)
end
function GameSettingLayer:musicCallBack(sender)
    GlobalUserItem.setVoiceAble(sender.isOn)
    if sender.isOn then
        ExternalFun.playBackgroudMusic("sound/bgm/bgm1.mp3")
        if self.btnMute.isOn then
            self.btnMute.isOn = false
            self.btnMute.changeOn(self.btnMute.isOn)
        end
    else
        if not self.btnMute.isOn and not self.btnEffect.isOn then
            self.btnMute.isOn = true
            self.btnMute.changeOn(self.btnMute.isOn)
        end
    end
end
function GameSettingLayer:effectCallBack(sender)
    GlobalUserItem.setSoundAble(sender.isOn)
    if sender.isOn then
        if self.btnMute.isOn then
            self.btnMute.isOn = false
            self.btnMute.changeOn(self.btnMute.isOn)
        end
    else
        if not self.btnMute.isOn and not self.btnMusic.isOn then
            self.btnMute.isOn = true
            self.btnMute.changeOn(self.btnMute.isOn)
        end
    end
end
function GameSettingLayer:muteCallBack(sender)
    GlobalUserItem.setVoiceAble(not sender.isOn)
    GlobalUserItem.setSoundAble(not sender.isOn)
    self.btnMusic.changeOn(not sender.isOn)
    self.btnEffect.changeOn(not sender.isOn)
    if not sender.isOn then
        ExternalFun.playBackgroudMusic("sound/bgm/bgm1.mp3")
    end
end
function GameSettingLayer:autoCallBack(sender)
    GlobalUserItem.setAutoAble(sender.isOn)
    if sender.isOn then
        self.btnDay.isOn = not sender.isOn
        self.btnDay.changeOn(self.btnDay.isOn)
        self.btnNight.isOn = not sender.isOn
        self.btnNight.changeOn(self.btnNight.isOn)
    else
        local nowDate = os.date("*t", os.time())
        if nowDate.hour <= 6 and nowDate.hour >= 18 then
            self.btnDay.isOn = false
            self.btnNight.isOn = true
            GlobalUserItem.setDayAble(false)
        else
            self.btnDay.isOn = true
            self.btnNight.isOn = false
            GlobalUserItem.setDayAble(true)
        end
        self.btnDay.changeOn(self.btnDay.isOn)
        self.btnNight.changeOn(self.btnNight.isOn)
    end
    ExternalFun.loadNightModel(self.scene)
end
function GameSettingLayer:dayCallBack(sender)
    self:showToastNight(not sender.isOn)
    GlobalUserItem.setDayAble(sender.isOn)
    if sender.isOn then
        GlobalUserItem.setAutoAble(false)
    end
    self.btnNight.isOn = not sender.isOn
    self.btnNight.changeOn(self.btnNight.isOn)
    ExternalFun.loadNightModel(self.scene)
end
function GameSettingLayer:nightCallBack(sender)
    self:showToastNight(sender.isOn)
    GlobalUserItem.setDayAble(not sender.isOn)
    if sender.isOn then
        GlobalUserItem.setAutoAble(false)
    end
    self.btnDay.isOn = not sender.isOn
    self.btnDay.changeOn(self.btnDay.isOn)
    ExternalFun.loadNightModel(self.scene)
end
function GameSettingLayer:showToastNight(isNight)
    local texts = {"已进入「", "夜间模式", "」"}
    if not isNight then
        texts = {"已退出「", "夜间模式", "」"}
    end
    local colors = {cc.c3b(0, 255, 0), cc.c3b(255, 255, 255), cc.c3b(0, 255, 0)}
    showToastColor(self, texts, colors, 1.5, 101)
end
function GameSettingLayer:addSwitchButton(pos, callback)
    local switchBtn =
        ccui.Layout:create():setAnchorPoint(cc.p(0.5, 0.5)):setContentSize(cc.size(241, 98)):setPosition(pos):addTo(
        self.settingBg
    )
    switchBtn:setCascadeOpacityEnabled(true)
    switchBtn.callback = callback
    local bgOn = display.newSprite("ui/setting/btn_base.png"):setPosition(123, 44):addTo(switchBtn):hide()
    local bgOff = display.newSprite("ui/setting/dikuang1.png"):setPosition(123, 44):addTo(switchBtn)
    local txtOff = display.newSprite("ui/setting/guan.png"):setPosition(145, 50):addTo(switchBtn)
    local txtOn = display.newSprite("ui/setting/kai.png"):setPosition(101, 49):addTo(switchBtn)
    local switcher = display.newSprite("ui/setting/anniu.png"):setPosition(86, 47):addTo(switchBtn)
    switchBtn.isOn = false
    local function changeOn(isOn)
        local posX = 86
        if isOn then
            posX = 160
        end
        bgOn:setVisible(isOn)
        bgOff:setVisible(not isOn)
        switcher:setPosition(cc.p(posX, 47))
    end
    switchBtn.changeOn = changeOn
    local function touchCallBack(event)
        if event.name == "ended" then
            ExternalFun.playCommonButtonClickEffect()
            if not tolua.isnull(switchBtn) then
                switchBtn.isOn = not switchBtn.isOn
                switchBtn.changeOn(switchBtn.isOn)
                switchBtn:stopAllActions()
                switchBtn:setTouchEnabled(false)
                local timeDelay = cc.DelayTime:create(0.2)
                local callFun =
                    cc.CallFunc:create(
                    function()
                        if switchBtn.callback then
                            switchBtn.callback(switchBtn)
                        end
                    end
                )
                local callFun2 =
                    cc.CallFunc:create(
                    function()
                        switchBtn:setTouchEnabled(true)
                    end
                )
                local seq = cc.Sequence:create(timeDelay, callFun, callFun2)
                switchBtn:runAction(seq)
            end
        end
    end
    switchBtn:setTouchEnabled(true)
    switchBtn:onTouch(touchCallBack)
    return switchBtn
end
function GameSettingLayer:onEnter()
    self:showLayer()
end
function GameSettingLayer:showLayer()
    self.settingBg:stopAllActions()
    self.settingBg:setScale(0.8)
    self.settingBg:setOpacity(255 * 0)
    local fadeIn = cc.FadeIn:create(0.07)
    local bigger = cc.ScaleTo:create(0.07, 1.02)
    local spawn = cc.Spawn:create(fadeIn, bigger)
    local reNormal = cc.ScaleTo:create(0.21, 1.0)
    local seq = cc.Sequence:create(spawn, reNormal)
    self.settingBg:runAction(seq)
end
function GameSettingLayer:hideBg(callBack)
    self.settingBg:stopAllActions()
    self.settingBg:setScale(1.0)
    self.settingBg:setOpacity(255 * 1.0)
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
    self.settingBg:runAction(seq)
end
function GameSettingLayer:onClose()
    local function callBack()
        self:stopAllActions()
        self:removeFromParent()
    end
    self:hideBg(callBack)
end
function GameSettingLayer:onCleanup()
end
return GameSettingLayer
