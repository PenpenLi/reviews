--
-- Author: 
-- Date: 2018-08-07 18:17:10
-- 超快赛比赛报名对话框

local StackLayer = require("app.hall.base.ui.StackLayer")
local GlobalItemInfoMgr = GlobalItemInfoMgr or require("app.hall.bag.model.GoodsData").new()
local SignUpTips = class("SignUpTips", function ()
    return display.newLayer() 
end)

function SignUpTips:ctor( type , atomID )
	self.mType = type
    self.mRoomData  = RoomData:getRoomDataById( atomID )
    self.callBack = nil
    self:initUI(self.mType )
    self:initPanel()
end

function SignUpTips:initUI( ... )
	local function closeCallback()
        if self.callBack then
            self.callBack()
        end
        self:removeFromParent()
    end
    local size = cc.Director:getInstance():getWinSize()
    local item = cc.MenuItemImage:create()
    item:setContentSize(cc.size(size.width, size.height))
    item:registerScriptTapHandler(closeCallback)
    self.backMenu = cc.Menu:create(item)
    self:addChild(self.backMenu)

	local path = "src/app/game/pdk/res/csb/land_match_cs/land_match_secondetip.csb"
	self.mNode = cc.CSLoader:createNode(path)
    UIAdapter:adapter( self.mNode , handler(self, self.onTouchCallback) )
    self:addChild( self.mNode )

    self.land_tiaojian = self.mNode:getChildByName("land_tiaojian")
    self.layout_bg = self.mNode:getChildByName("layout_bg")
    self.land_my_score = self.layout_bg:getChildByName("land_my_score")
    self.land_rule_panel = self.layout_bg:getChildByName("land_rule_panel")


    self.itemIcon  = self.mNode:getChildByName("tip_spr")

    if self.mType == 101 then  -- 奖励列表
        self.land_tiaojian:setVisible(false)
        self.layout_bg:setVisible(true)
	    self.land_rule_panel:setVisible(true)
	    self.land_my_score:setVisible(false)
	elseif self.mType == 102 then -- 赛制详情
        self.land_tiaojian:setVisible(false)
        self.layout_bg:setVisible(true)
        self.land_rule_panel:setVisible(true)
        self.land_my_score:setVisible(false)
	elseif self.mType == 103 then -- 我的战绩
        self.land_tiaojian:setVisible(false)
        self.layout_bg:setVisible(true)
        self.land_rule_panel:setVisible(false)
        self.land_my_score:setVisible(true)
    elseif self.mType == 200 then -- 门票问号
        self.land_tiaojian:setVisible(true)
        self.layout_bg:setVisible(false)
        self.land_rule_panel:setVisible(false)
        self.land_my_score:setVisible(false)
    end
end


function SignUpTips:initPanel()
    if self.mType == 101 then
        self:initJiangLiPanel()
        --LAND_LOAD_OPEN_EFFECT(self.layout_bg)
	elseif self.mType == 102 then
        self:initShaZiPanel()
        --LAND_LOAD_OPEN_EFFECT(self.layout_bg)
	elseif self.mType == 103 then
        self:initMyScroePanel()
        --LAND_LOAD_OPEN_EFFECT(self.layout_bg)
    elseif self.mType == 200 then
        self:initWenHaoPanel()
        --LAND_LOAD_OPEN_EFFECT(self.land_tiaojian)
    end
end

-- 奖励
function SignUpTips:initJiangLiPanel( ... )
    self.itemIcon:setSpriteFrame(display.newSpriteFrame("ddz_zi_jiangli.png"))

    local scorllView = self.land_rule_panel:getChildByName("ScrollView_1") 
    local t_content = scorllView:getChildByName("t_content")
    local t_content_0 = scorllView:getChildByName("t_content_0")
    local t_content_1 = scorllView:getChildByName("t_content_1")

    t_content:setVisible(false)
    t_content_0:setVisible(false)
    t_content_1:setVisible(false)

    local strSplit = string.split(self.mRoomData.matchReward, '#')  
    local  enterStr1 = string.split(strSplit[1], '\n') 
    local  enterStr2 = string.split(strSplit[2], '\n') 

    local grap = 20
    local scrollViewS = scorllView:getContentSize()
    local totalHeight = (30 + grap)*(#enterStr1)
    if scrollViewS.height > totalHeight then
        scorllView:setInnerContainerSize(cc.size(scrollViewS.width, scrollViewS.height))
    else
        scorllView:setInnerContainerSize(cc.size(scrollViewS.width, totalHeight))
    end

    local realHeight = scorllView:getInnerContainerSize().height
    print(">>>>>>>>>>>>>>>>>realHeight=", realHeight)
    for k,v in pairs(enterStr1) do
        local label_rule = display.newTTFLabel( {
            text = v, 
            font = "font/jcy.TTF", 
            size = 25, 
            color = cc.c3b(68, 99, 154),
            dimensions = cc.size(660, 0),
        } )

        local curHeight = realHeight - (30 + grap) * (k-1)
        label_rule:setAnchorPoint(cc.p(0, 1))
        label_rule:setPosition(cc.p(t_content_0:getPositionX(), curHeight))
        scorllView:addChild(label_rule)

        if strSplit[2] then
            local label_reward = display.newTTFLabel( {
                text = enterStr2[k], 
                font = "font/jcy.TTF", 
                size = 25, 
                color = cc.c3b(68, 99, 154),
                dimensions = cc.size(660, 0),
            } )
            label_reward:setAnchorPoint(cc.p(0, 1))
            label_reward:setPosition(cc.p(t_content_1:getPositionX(), curHeight)) 
            scorllView:addChild(label_reward)
        end

    end

end

-- 赛制详情
function SignUpTips:initShaZiPanel()
    self.itemIcon:setSpriteFrame(display.newSpriteFrame("ddz_zi_saizhi.png"))

    local scorllView = self.land_rule_panel:getChildByName("ScrollView_1") 
    local t_content = self.land_rule_panel:getChildByName("t_content")
    local t_content_0 = self.land_rule_panel:getChildByName("t_content_0")
    local t_content_1 = self.land_rule_panel:getChildByName("t_content_1")
    t_content:setVisible(false)
    t_content_0:setVisible(false)
    t_content_1:setVisible(false)
    --t_content:setString(self.mRoomData.matchDetail)

    local label_rule = display.newTTFLabel( {
            text = self.mRoomData.matchDetail, 
            font = "font/jcy.TTF", 
            size = 25, 
            color = cc.c3b(68, 99, 154),
            dimensions = cc.size(t_content:getContentSize().width, 0),
        } )

    local label_ruleS = label_rule:getContentSize()
    local totalHeight = label_ruleS.height + 20 * 3
    local scrollViewS = scorllView:getContentSize()
    label_rule:setAnchorPoint(cc.p(0, 1))
    if scrollViewS.height > totalHeight then
        scorllView:setInnerContainerSize(cc.size(scrollViewS.width, scrollViewS.height))
        label_rule:setPosition(cc.p(t_content:getPositionX(), scrollViewS.height))
    else
        scorllView:setInnerContainerSize(cc.size(scrollViewS.width, totalHeight))
        label_rule:setPosition(cc.p(t_content:getPositionX(), totalHeight))
    end
    scorllView:addChild(label_rule)  

end

-- 我的战绩
function SignUpTips:initMyScroePanel()
    self.itemIcon:setSpriteFrame(display.newSpriteFrame("ddz_zi_zhanji.png"))

    local t_content_1 = self.land_my_score:getChildByName("t_content_1") -- 第几名
    local t_content_2 = self.land_my_score:getChildByName("t_content_2") -- 时间
    local t_content_4 = self.land_my_score:getChildByName("t_content_4") -- 金币
    local t_content_6 = self.land_my_score:getChildByName("t_content_6") -- 进入决赛几次
    local t_content_8 = self.land_my_score:getChildByName("t_content_8") -- 进入复赛赛几次
    local btn_share   = self.land_my_score:getChildByName("btn_share")

end

-- 问号
function SignUpTips:initWenHaoPanel()
    local btn_chong_qian = self.land_my_score:getChildByName("btn_chong_qian") -- 充值
    local strTbl = {}
    if self.mRoomData.condition1 then
        strTbl = fromJson(self.mRoomData.condition1)

    end
    local lord_apply_img_hx = self.land_tiaojian:getChildByName("lord_apply_img_hx") 
    local text_1   = self.land_tiaojian:getChildByName("text_1") -- 报名费用
    local text_2   = self.land_tiaojian:getChildByName("text_2") -- 获取途径
    local text_3   = self.land_tiaojian:getChildByName("text_3") -- 报名费用
    local text_4   = self.land_tiaojian:getChildByName("text_4") -- 获取途径
    local text_1_0 = self.land_tiaojian:getChildByName("text_1_0") -- 扣除金币数量123245679
    local text_2_0 = self.land_tiaojian:getChildByName("text_2_0") -- 比赛获取或充值获取
    local text_3_0 = self.land_tiaojian:getChildByName("text_3_0") -- 扣除100元参赛卷数量1
    local text_4_0 = self.land_tiaojian:getChildByName("text_4_0") -- 可在游戏中各种比赛中获取

    if strTbl[1]["type"] == 2 then
        text_1_0:setString("扣除金币数量"..strTbl[1]["num"])
    elseif strTbl[1]["type"] == 3 then
        text_1_0:setString("扣除钻石数量"..strTbl[1]["num"])
    else
        local itemInfo = GlobalItemInfoMgr:getItemInfoByID(502)--strTbl[1]["itemId"])
        dump(itemInfo)
        local name = "扣除"..itemInfo:getName()
        text_1_0:setString(name..strTbl[1]["num"])
    end
    
    text_3:setVisible(false)
    text_4:setVisible(false)
    text_3_0:setVisible(false)
    text_4_0:setVisible(false)
    lord_apply_img_hx:setVisible(false)
end

function SignUpTips:setCallBack(callback)
    self.callBack = callback
end

function SignUpTips:onClickCloseBtn( sender, eventType )
	if eventType == ccui.TouchEventType.ended then
        if self.callBack then
            self.callBack()
        end
		self:removeFromParent()
	end
end

function SignUpTips:onTouchCallback( sender )
    local name = sender:getName()
    local tag = sender:getTag()
    print("SignUpTips name: ", name)
    if name =="btn_close" then
        if self.callBack then
            self.callBack()
        end
   		self:removeFromParent()
    elseif name == "btn_chong_qian" then
        if getFuncOpenStatus(1013) == 1 then
            TOAST("商城维护中!")
            return
        end
        local data = fromFunction(GlobalDefine.FUNC_ID.GOLD_RECHARGE )
        local stackLayer = data.mobileFunction
        if stackLayer and string.len(stackLayer) > 0 then
            sendMsg(MSG_GOTO_STACK_LAYER, {layer = stackLayer, name = data.name, funcId = GlobalDefine.FUNC_ID.GOLD_RECHARGE})
        end
    elseif name == "btn_share" then
        TOAST("敬请期待")
    end
end

return SignUpTips
