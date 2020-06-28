-- FriendRule
-- 跑得快游戏规则显示
local XbDialog = require("app.hall.base.ui.CommonView")
local StringConfig = require("app.game.pdk.src.landcommon.data.StringConfig")
local LandMaskLayer = require ("app.game.pdk.src.landcommon.view.LandMaskLayer")
local LandGlobalDefine = require("app.game.pdk.src.landcommon.data.LandGlobalDefine")

local FriendRuleText = { 
    rule = "跑得快规则：\n",
    doubleRule = "1、发牌 \n一副牌54张，一人17张，留3张做底牌，在确定地主之前玩家不能看底牌。 \n2、叫牌 \n叫牌按出牌的顺序轮流进行，每人只能叫一次。叫牌时可以叫“1分”，“2分”，“3分”，“不叫”。后叫牌者只能叫比前面玩家高的分或者不叫。叫牌结束后所叫分值最大的玩家为地主；如果有玩家叫“3分”则立即结束叫牌，该玩家为地主；如果都不叫，则重新发牌，重新叫牌。 \n3、第一个叫牌的玩家 \n第一轮叫牌的玩家由系统选定，以后每一轮首先叫牌的玩家按出牌顺序轮流担任。 \n4、出牌 \n将三张底牌交给地主，并亮出底牌让所有人都能看到。地主首先出牌，然后按逆时针顺序依次出牌，轮到用户跟牌时，用户可以选择“不出”或出比上一个玩家大的牌。某一玩家出完牌时结束本局。 \n5、牌型 \n火箭：即双王（大王和小王），最大的牌。\n炸弹：四张同数值牌（如四个7）。\n单牌：单个牌（如红桃5）。\n对牌：数值相同的两张牌（如梅花4+方块4）。\n三张牌：数值相同的三张牌（如三个J）。\n三带一：数值相同的三张牌 + 一张单牌或一对牌。例如： 333+6或444+99 \n单顺：五张或更多的连续单牌（如：45678或78910JQK）。不包括2点和双王。\n双顺：三对或更多的连续对牌（如：334455、7788991010JJ）。不包括2点和双王。\n三顺：二个或更多的连续三张牌（如：333444、555666777888）。不包括2点和双王。\n飞机带翅膀：三顺＋同数量的单牌（或同数量的对牌）。\n如：444555+79 或333444555+7799JJ\n四带二：四张牌＋两手牌。（注意：四带二不是炸弹）。\n如：5555＋3＋8或4444＋55＋77。 \n6、牌型的大小 \n火箭最大，可以打任意其他的牌。\n炸弹比火箭小，比其他牌大。都是炸弹时按牌的分值比大小。\n除火箭和炸弹外，其他牌必须要牌型相同且总张数相同才能比大小。\n单牌按分值比大小，依次是 大王>小王>2>A>K>Q>J>10>9>8>7>6>5>4>3，不分花色。\n对牌、三张牌都按分值比大小。\n顺牌按最大的一张牌的分值来比大小。\n飞机带翅膀 和 四带二 按其中的三顺和四张部分来比，带的牌不影响大小。\n7、胜负判定 \n任意一家出完牌后结束游戏，若是地主先出完牌则地主胜，否则另外两家胜。 \n8、积分 \n底分：叫牌的分数\n倍数：初始为1，每出一个炸弹或火箭翻一倍。（火箭和炸弹留在手上没出的不算） \n一局结束后：\n地主胜：地主得分为2*底分*倍数。 其余玩家各得：-底分*倍数\n地主败：地主得分为-2*底分*倍数。 其余玩家各得：底分*倍数\n地主所有牌出完，其他两家一张都未出： 分数 * 2\n其他两家中有一家先出完牌，地主只出过一手牌： 分数 * 2\n"
}

local FriendRule = class("FriendRule", function()
    return XbDialog.new()
end)

function FriendRule:ctor()
    self.m_enum =  {
        BLANK = 20,
        RULE_TAG = 1000,
        REWARD_TAG = 1001,
    }
    self.m_pInfoNode = nil
    self.m_pScrollView = nil
    self.m_labelWidth = nil
    self.m_labelX = nil

    self:init()
    LAND_LOAD_OPEN_EFFECT(self.layout_bg)
end

function FriendRule:init()
    --点击窗口外面关闭
    local LandMaskLayer = LandMaskLayer.new(function()
        self:closeDialog()
    end)
    self:addChild(LandMaskLayer, -1)

    self.m_pInfoNode = cc.CSLoader:createNode("src/app/game/pdk/res/csb/friend_land_cs/friend_rule.csb")


    UIAdapter:adapter(self.m_pInfoNode, handler(self, self.onTouchCallback))
    self:addChild(self.m_pInfoNode)

    self.layout_bg = self.m_pInfoNode:getChildByName("layout_bg")

    self.btn_close = self.layout_bg:getChildByName("btn_close")
    self.btn_close:addTouchEventListener(handler(self,self.onCloseCallBack))

    --显示游戏规则内容
    self.m_pScrollView = self.layout_bg:getChildByName("rule_scrollview")
    local content = self.m_pScrollView:getChildByName("t_content")
    content:setVisible(false)
    self.m_labelWidth = content:getContentSize().width
    self.m_labelX = content:getPositionX()
    self:showGameRule()

end


function FriendRule:removeAllLabel()
    local label_rule = self.m_pScrollView:getChildByTag(self.m_enum.RULE_TAG)
    if label_rule then
        self.m_pScrollView:removeChild(label_rule)
    end
end

function FriendRule:getRuleText()
    return  FriendRuleText.rule, FriendRuleText.doubleRule
end

function FriendRule:onCloseCallBack( sender , eventType)
    if eventType == ccui.TouchEventType.ended then
        self:closeDialog()
    end
end

function FriendRule:showGameRule()
    self:removeAllLabel()
    local rule, reward = self:getRuleText()
    --
    local label_rule = display.newTTFLabel( {
        text = rule, 
        font = "font/jcy.TTF", 
        size = 24, 
        color = cc.c3b(132, 81, 36),
        dimensions = cc.size(self.m_labelWidth, 0),
    } )
    label_rule:setTag(self.m_enum.RULE_TAG)
    local label_reward = display.newTTFLabel( {
        text = reward, 
        font = "font/jcy.TTF",
        size = 24, 
        color = cc.c3b(132, 81, 36),
        dimensions = cc.size(self.m_labelWidth, 0),
    } )
    label_reward:setTag(self.m_enum.REWARD_TAG)
    --
    local label_ruleS = label_rule:getContentSize()
    local label_rewardS = label_reward:getContentSize()
    local totalHeight = label_ruleS.height + label_rewardS.height + self.m_enum.BLANK * 3
    local scrollViewS = self.m_pScrollView:getContentSize()
    
    label_rule:setAnchorPoint(cc.p(0, 1))
    label_reward:setAnchorPoint(cc.p(0, 1))
    if scrollViewS.height > totalHeight then
        self.m_pScrollView:setInnerContainerSize(cc.size(scrollViewS.width, scrollViewS.height))
        label_rule:setPosition(cc.p(self.m_labelX, scrollViewS.height))
        label_reward:setPosition(cc.p(self.m_labelX, scrollViewS.height - label_ruleS.height - self.m_enum.BLANK))  
    else
        self.m_pScrollView:setInnerContainerSize(cc.size(scrollViewS.width, totalHeight))
        label_rule:setPosition(cc.p(self.m_labelX, totalHeight))
        label_reward:setPosition(cc.p(self.m_labelX, totalHeight - label_ruleS.height - self.m_enum.BLANK)) 
    end
    
    self.m_pScrollView:addChild(label_rule)
    self.m_pScrollView:addChild(label_reward)
end
 
-- 点击事件回调
function FriendRule:onTouchCallback( sender )
    local name = sender:getName()
    print("name: ", name)

end

return FriendRule