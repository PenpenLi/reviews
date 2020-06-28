-- LandRollNotice


local LandRollNotice = class("LandRollNotice",function()
    return display.newNode() end
)



function LandRollNotice:ctor( _infor , model , time)
    self.params = _infor
    self.m_showModel = model
    self:myInit()

    self.m_Time = time
    self.m_callbackYes = nil
    self.m_callbackNo = nil
    self.m_callbackEnd = nil

    self:setupViews()
end

function LandRollNotice:myInit()

    ToolKit:registDistructor( self, handler(self, self.onDestory))
end

function LandRollNotice:onDestory()
    LogINFO("function LandRollNotice:onDestory()")
end


function LandRollNotice:setupViews()
    self.node = UIAdapter:createNode("src/app/game/pdk/res/csb/land_common_cs/land_roll_notice.csb")
   
    self:addChild(self.node,100000) 
    
    self.layer_bg  = self.node:getChildByName("layer_bg")
    self.layer_bg:setSwallowTouches(false)

    for i=1,3 do
        self["model_"..i] = self.node:getChildByName("model_"..i)
        self["model_"..i]:setVisible(false)
    end

    self["model_"..self.m_showModel]:setVisible(true)
    self.model_1:setContentSize(display.width, self.model_1:getContentSize().height)
    self.model_2:setContentSize(display.width, self.model_1:getContentSize().height)

    self.text_title = self["model_"..self.m_showModel]:getChildByName("text_title")
    if self.text_title then
        self.text_title:setString("比赛开始了")
    end

    self.model3_bg = self["model_"..self.m_showModel]:getChildByName("Panel_7")
    if self.model3_bg then
        self.model3_bg:setContentSize(display.size)
    end
   
    self.txt_notice  = self["model_"..self.m_showModel]:getChildByName("txt_notice")
    self.txt_notice:setString(self.params)

    if self.m_showModel == 1 then
        self.txt_notice:setPositionX(display.width/2)
    end
    local moveTime = 4
    if self.m_showModel == 2 then
        local Panel_8 = self["model_"..self.m_showModel]:getChildByName("Panel_8")
        Panel_8:setContentSize(display.width, self.model_1:getContentSize().height)

        local posX, posY = self.txt_notice:getPosition()
        local offset = self.txt_notice:getContentSize().width - 930 + 50
        self.txt_notice:setPositionX(posX - offset)
        local moveR = cc.MoveTo:create(moveTime, cc.p(posX+50, posY))
        local moveL = cc.MoveTo:create(moveTime, cc.p(posX-offset, posY))
        self.txt_notice:runAction(cc.RepeatForever:create(cc.Sequence:create(moveR, moveL)))
    end

    self.btn_no  = self["model_"..self.m_showModel]:getChildByName("btn_no")
    self.btn_yes = self["model_"..self.m_showModel]:getChildByName("btn_yes")

    if self.btn_no  then 
        self.btn_no:addTouchEventListener(handler(self,self.onClickNo)) 
        if self.m_showModel == 2 then  self.btn_no:setPositionX(display.width- 110) end
    end
    if self.btn_yes then 
        self.btn_yes:addTouchEventListener(handler(self,self.onClickYes)) 
        if self.m_showModel == 2 then  self.btn_yes:setPositionX(display.width- 270) end
    end

    local TIME = self.m_Time or 10

    local callback  = function ()
        if self.m_showModel == 3 then
            print("倒计时..", self.m_Time)
            self.m_Time = self.m_Time - 1
            local txt = string.split(self.params, '(')
            local newTxt = txt[1].."("..(self.m_Time)..")"
            self.txt_notice:setString(newTxt)
            if self.m_Time <= 0 then
                self:removeFromParent()
            end
        end
    end
    local callbackend = function () 
        if self.m_callbackEnd then
            self.m_callbackEnd()
        end
    end

    local delay = cc.DelayTime:create(1)
    local sequence = cc.Sequence:create(delay, cc.CallFunc:create(callback))
    local repea = cc.Repeat:create(sequence, TIME)
    local sequ = cc.Sequence:create(repea, cc.CallFunc:create(callbackend))
    self:runAction(sequ)
end

function LandRollNotice:setCallBackYes(callBack)
    self.m_callbackYes = callBack
end

function LandRollNotice:setCallBackNo(callBack)
    self.m_callbackNo = callBack
end

-- 设置计时结束回调
function LandRollNotice:setCallBackEnd(callBack)
    self.m_callbackEnd = callBack or function () print("function LandRollNotice:setCallBackEnd(callBack) is nil") end
end

-- 是 回调
function LandRollNotice:onClickYes(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        print("onClickBntYes")
        if self.m_callbackYes then
            self.m_callbackYes()
            --self:removeFromParent()
            self:setVisible(false)
        end
    end
end

-- 否回调
function LandRollNotice:onClickNo(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        print("onClickBntNo")
        if self.m_callbackNo then
            self.m_callbackNo()
            --self:removeFromParent()
            self:setVisible(false)
        end
    end
end

--设置背景颜色
function LandRollNotice:setBgColor( _color )
    self.layer_bg:setBackGroundColorType(1)
    self.layer_bg:setBackGroundColor(_color)
      
--    _loyout:setBackGroundColorOpacity(100)
end

--设置字体颜色
function LandRollNotice:setFontColor( _color )
    self.txt_notice:setColor(_color)
end

--设置字体大小
function LandRollNotice:setFontSize( _size  )
    self.txt_notice:setFontSize(_size)
end


function LandRollNotice:getNoticeSize()
   return  self.layer_bg:getContentSize()
end

return  LandRollNotice