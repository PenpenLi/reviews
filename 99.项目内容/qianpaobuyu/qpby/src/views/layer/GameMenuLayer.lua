local GameMenuLayer =
    class(
    "GameMenuLayer",
    function()
        return display.newLayer(cc.c4b(0, 0, 0, 125))
    end
)
local module_pre = "game.yule.qpby.src"
local ExternalFun = appdf.req(appdf.EXTERNAL_SRC .. "ExternalFun")
local GameSettingLayer = appdf.req(module_pre .. ".views.layer.GameSettingLayer")
local GameWikiLayer = appdf.req(module_pre .. ".views.layer.GameWikiLayer")
local NODEZORDER = {UI = 1, POP = 2}
function GameMenuLayer:ctor(scene)
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
    self:changeMenuBtn(false)
    self:initMenu()
    self:showLayer()
end
function GameMenuLayer:showLayer()
    self.menuBg:setPosition(120, display.height - 250 + 60)
    self.menuBg:setOpacity(0)
    local fadeIn = cc.FadeIn:create(0.1)
    local moveTo = cc.MoveTo:create(0.1, cc.p(120, display.height - 250 - 10))
    local spawn = cc.Spawn:create(fadeIn, moveTo)
    local moveBack = cc.MoveTo:create(0.05, cc.p(120, display.height - 250))
    local seq = cc.Sequence:create(spawn, moveBack)
    self.menuBg:runAction(seq)
end
function GameMenuLayer:onClose()
    local fadeOut = cc.FadeOut:create(0.1)
    local moveTo = cc.MoveTo:create(0.1, cc.p(120, display.height - 250 + 60))
    local spawn = cc.Spawn:create(fadeOut, moveTo)
    local cFun =
        cc.CallFunc:create(
        function()
            self:changeMenuBtn()
            self:removeFromParent()
        end
    )
    local seq = cc.Sequence:create(spawn, cFun)
    self.menuBg:runAction(seq)
end
function GameMenuLayer:changeMenuBtn(isOpen)
    local setOpen = true
    if nil ~= isOpen then
        setOpen = isOpen
    end
    if not tolua.isnull(self.scene) then
        if not tolua.isnull(self.scene.uiLayer.menuBtn) then
            local fileName = "ui/an_menu_Open.png"
            if not setOpen then
                fileName = "ui/an_menu_Close.png"
            end
            self.scene.uiLayer.menuBtn:loadTextureNormal(fileName, 0)
        end
    end
end
function GameMenuLayer:initMenu()
    self.menuBg =
        ccui.ImageView:create("ui/menu_bg.png"):align(display.CENTER, 120, display.height - 325):addTo(self):setTouchEnabled(
        true
    ):setCascadeOpacityEnabled(true)
    local btnFileTable = {"ui/menu_tujian.png", "ui/menu_Sound.png", "ui/menu_Return.png"}
    local menuSize = self.menuBg:getContentSize()
    for i = 1, #btnFileTable do
        local menuBtn =
            ccui.Button:create(btnFileTable[i], nil, nil, 0):align(
            display.CENTER,
            menuSize.width / 2,
            menuSize.height - 85 * i + 10
        ):addTo(self.menuBg):addTouchEventListener(
            function(ref, tType)
                if tType == ccui.TouchEventType.ended then
                    ExternalFun.playCommonButtonClickEffect()
                    if i == 1 then
                        self:showWiki()
                    elseif i == 2 then
                        self:showSetting()
                    elseif i == 3 then
                        self:goBack()
                    end
                end
            end
        )
    end
end
function GameMenuLayer:onCleanup()
end
function GameMenuLayer:showWiki()
    GameWikiLayer.new(self.scene):setPosition(0, 0):addTo(self:getParent(), NODEZORDER.POP)
    self:onClose()
end
function GameMenuLayer:showSetting()
    GameSettingLayer.new(self.scene):setPosition(0, 0):addTo(self:getParent(), NODEZORDER.POP)
    self:onClose()
end
function GameMenuLayer:goBack()
    if not tolua.isnull(self.scene) then
        self.scene._gameFrame:setEnterAntiCheatRoom(false)
        self.scene._gameFrame:StandUp(1)
        self.scene._plazzScene:onKeyBack()
    end
end
return GameMenuLayer
