--
-- Author: 
-- Date: 2018-08-07 18:17:10
-- 欢乐跑得快明牌界面
local btn_str = 
{
    [1] = {"不叫","叫地主"},
    [2] = {"不抢","抢地主"},
    [3] = {"不明牌","明牌"},
}
local timeCard = {[1]=2, [6]=3,[12]=4,[17]=5,}

local StackLayer = require("app.hall.base.ui.StackLayer")

local HappyOpenPoker = class("HappyOpenPoker", function()
    return StackLayer.new()
end)

function HappyOpenPoker:ctor( landMainScene , atom )
    self.gameScene = landMainScene
    self.game_atom = atom
    self:initUI()
end

function HappyOpenPoker:initUI()
    self.root = UIAdapter:createNode("src/app/game/pdk/res/csb/classic_land_cs/happy_land_showcard.csb")
    
    self:addChild( self.root )
    UIAdapter:adapter(self.root, handler(self, self.onTouchCallback))
    self.open_poker_bg = self.root:getChildByName("center_time")
    self.call_bg      = self.root:getChildByName("center_call_land")

    self:initLoadingbar()
    self:initButton()
end

function HappyOpenPoker:initLoadingbar()
    self.m_show_time = {}
    self.loadingBar = self.open_poker_bg:getChildByName("time_loadingbar")
    self.loadingBar:setPercent(0)
    for i=1,4 do
        self.m_show_time[i] = {}
        self.m_show_time[i].showTime = self.open_poker_bg:getChildByName("show_time_"..i)
        self.m_show_time[i].img_bg = self.m_show_time[i].showTime:getChildByName("img_bg")
        self.m_show_time[i].img_bg:setVisible(i~=1)
        self.m_show_time[i].text_time = self.m_show_time[i].showTime:getChildByName("text_time")
    end
end

function HappyOpenPoker:initButton()
    self.open_poker_btn = self.open_poker_bg:getChildByName("show_button")
    self.open_poker_btn:enableOutline({r = 103, g = 142, b = 28, a = 255}, 3)
    self.open_poker_btn:addTouchEventListener(handler(self,self.OnClickOpenPokerBtn))

    self.not_btn  = self.call_bg:getChildByName("show_button_0")
    self.yes_btn  = self.call_bg:getChildByName("show_button")
    
    self.yes_btn:enableOutline({r = 103, g = 142, b = 28, a = 255}, 3)
    self.not_btn:enableOutline({r = 28, g = 142, b = 122, a = 255}, 3)

    self.not_btn:addTouchEventListener(handler(self,self.OnClickChoiceBtn))
    self.yes_btn:addTouchEventListener(handler(self,self.OnClickChoiceBtn))
end

function HappyOpenPoker:setLoadingBarText( info )
    self.openval_info = info.m_nOpenVal
    self.timeTick = 0.035
    self.mTime = 0
    for i=1,4 do
        self.m_show_time[i].img_bg:setVisible(i~=1)
        self.m_show_time[i].text_time:setString("X"..self.openval_info[i])
    end
end

--断线重连回来直接设置一部分进度
function HappyOpenPoker:restoreStatus( totalSec , leftSec )
    local alreadyUse = totalSec - leftSec
    local per = math.floor((alreadyUse/totalSec)*100)
    self.loadingBar:setPercent( per )
    self:highLightDot(self:getStopDot())
    --print("=============================",totalSec , leftSec,alreadyUse,per)
end

function HappyOpenPoker:startLoadingBarTimer()
    local function f()
        self:updateLoadingPercent()
    end
    self:schedule(f, self.timeTick)
end

function HappyOpenPoker:updateLoadingPercent()
    local stopDot = self:getStopDot()
    if stopDot then
        self:stopLoadingBar()
    else
        self:increaseLoadingBar() 
    end
    self:highLightDotByPer()
end

function HappyOpenPoker:getStopDot()
    local per = self.loadingBar:getPercent()
    if per%25 ~= 0 or per < 25 then return end
    local ret = per/25+1
    return ret
end

function HappyOpenPoker:stopLoadingBar()
    local need = 15
    if not self.stopStartFrame then self.stopStartFrame = GET_CUR_FRAME() end
    if GET_CUR_FRAME() - self.stopStartFrame >= need then
        self.stopStartFrame = nil
        self:increaseLoadingBar()
    end
end

function HappyOpenPoker:increaseLoadingBar()
    local step = 1
    local oldPer = self.loadingBar:getPercent()
    if oldPer >= 25 then
        self.gameScene:showCardByPer( oldPer - 25 )
    end
    self.loadingBar:setPercent( oldPer + step )
    if oldPer == 100 then
        self:hideOpenPokerBG()
    end
end

function HappyOpenPoker:getDotByPer()
    local per = self.loadingBar:getPercent()
    local num = math.ceil(per/25)
    return num
end

function HappyOpenPoker:highLightDotByPer()
    local num = self:getDotByPer()
    self:highLightDot(num)
end

function HappyOpenPoker:highLightDot( dot )
    for k,v in pairs( self.m_show_time ) do
        v.img_bg:setVisible( k ~= dot )
    end
end

function HappyOpenPoker:OnClickOpenPokerBtn( sender, eventType )
    if eventType == ccui.TouchEventType.ended then
        local num = self:getDotByPer()
        local val = self.openval_info[num]
        LogINFO("点击了明牌按钮,当前亮起,对应倍数,",num,val)
        if val and val > 0 then
            ConnectManager:send2GameServer(self.game_atom, "CS_C2G_HLLand_OpenPoker_Req", {val} )
        end
    end
end

function HappyOpenPoker:OnClickChoiceBtn( sender, eventType )
    if eventType == ccui.TouchEventType.ended then
        local str = sender:getTitleText()
        if str == "不叫" or str == "不抢" then
            ConnectManager:send2GameServer(self.game_atom, "CS_C2G_LandLord_BeLord_Nty", {0} )
        elseif str == "叫地主" or str == "抢地主" then
            ConnectManager:send2GameServer(self.game_atom, "CS_C2G_LandLord_BeLord_Nty", {1} )
        elseif str == "不明牌" then
            ConnectManager:send2GameServer(self.game_atom, "CS_C2G_HLLand_LandOpenPoker_Req", {0} )
        elseif str == "明牌" then
            ConnectManager:send2GameServer(self.game_atom, "CS_C2G_HLLand_LandOpenPoker_Req", {1} )
        end
    end
end

function HappyOpenPoker:OnClickTakeLordBtn( sender, eventType )
    if eventType == ccui.TouchEventType.ended then
        LogINFO("点击了叫地主按钮")
        ConnectManager:send2GameServer(self.game_atom, "CS_C2G_LandLord_BeLord_Nty", {1} )
    end
end

function HappyOpenPoker:OnClickNotTakeBtn( sender, eventType )
    if eventType == ccui.TouchEventType.ended then
        LogINFO("点击了不叫按钮")
        ConnectManager:send2GameServer(self.game_atom, "CS_C2G_LandLord_BeLord_Nty", {0} )
    end
end

function HappyOpenPoker:hideOpenPokerBG()
    self.open_poker_bg:setVisible(false)
end

function HappyOpenPoker:showCallBG( tag )
    self:hideOpenPokerBG()
    self.call_bg:setVisible(true)
    local info = btn_str[ tag ]
    self.not_btn:setTitleText( info[1] )
    self.yes_btn:setTitleText( info[2] )
end


function HappyOpenPoker:hideCallBG()
    self.call_bg:setVisible(false)
end

-- 点击事件回调
function HappyOpenPoker:onTouchCallback( sender )
    local name = sender:getName()
    print("HappyOpenPoker : ", name)
end

return HappyOpenPoker