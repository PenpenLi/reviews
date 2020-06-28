--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

local LordDataMgr       = require("game.lord.bean.LordDataMgr")
local LordScene_Events  = require("game.lord.scene.LordSceneEvent")
local LordDataMgr       = require("game.lord.bean.LordDataMgr")
local LordGameLogic     = require("game.lord.bean.LordGameLogic")

local SPACE_CARD = 22

local CheatLayer = class("CheatLayer", cc.Layer)

function CheatLayer:ctor()
    self:enableNodeEvents()
    self:init()
end

function CheatLayer:init()
    self:initCSB()
end

function CheatLayer:onEnter()
    self:initEvent()
end

function CheatLayer:onExit()
    self:stopEvent()
end

function CheatLayer:initEvent()
    
    self.event_ = {
        [LordScene_Events.MSG_SHOW_ALL_CARD]     = { func = self.onMsgAllCard,      log = "", debug = true, },
        [LordScene_Events.MSG_LANDLORD_CONCLUDE] = { func = self.onMsgGameConclude, log = "", debug = true, },
    }
    for key, event in pairs(self.event_) do   --监听事件
         SLFacade:addCustomEventListener(key, handler(self, event.func), self.__cname)
    end
end

function CheatLayer:stopEvent()
    for key in pairs(self.event_) do   --监听事件
         SLFacade:removeCustomEventListener(key, self.__cname)
    end
    self.event_ = {}
end

function CheatLayer:initCSB()
    
    self.m_rootUI = display.newNode()
    self.m_rootUI:addTo(self)

    self.m_pathUI = cc.CSLoader:createNode("game/lord/CheatLayer.csb")
    self.m_pathUI:addTo(self.m_rootUI)

    self.m_pRootLayer = self.m_pathUI:getChildByName("Panel_root")
    self.m_pRootLayer:setPositionX((display.width - 1334) / 2)
    self.m_pCheatLayer = self.m_pRootLayer:getChildByName("Node_cheat")

    self.m_pBtnCheat = self.m_pCheatLayer:getChildByName("Button_cheat")
    self.m_pLayerCheat = {}
    self.m_pLayerCheat[0] = self.m_pCheatLayer:getChildByName("Layer_0")
    self.m_pLayerCheat[2] = self.m_pCheatLayer:getChildByName("Layer_2")

    self.m_pBtnCheat:addClickEventListener(handler(self, self.onCheatClicked))

    self.m_pLayerCheat[0]:removeAllChildren()
    self.m_pLayerCheat[2]:removeAllChildren()

    self:onUpdateLayer(self.m_bCheat)
end

function CheatLayer:onCheatClicked()
    AudioManager:getInstance():playSound("public/sound/sound-button.mp3")

    self:onUpdateLayer(not self.m_bCheat)
end

function CheatLayer:onUpdateLayer(bVisible)

    self.m_bCheat = bVisible

    if bVisible then
        self.m_pBtnCheat:loadTextureNormal("game/lord/gui-image/gui-up-btn-push.png", ccui.TextureResType.plistType)
        self.m_pBtnCheat:loadTexturePressed("game/lord/gui-image/gui-up-btn-pop.png", ccui.TextureResType.plistType)
        self.m_pLayerCheat[0]:setVisible(true)
        self.m_pLayerCheat[2]:setVisible(true)
    else
        self.m_pBtnCheat:loadTextureNormal("game/lord/gui-image/gui-up-btn-pop.png", ccui.TextureResType.plistType)
        self.m_pBtnCheat:loadTexturePressed("game/lord/gui-image/gui-up-btn-push.png", ccui.TextureResType.plistType)
        self.m_pLayerCheat[0]:setVisible(false)
        self.m_pLayerCheat[2]:setVisible(false)
    end
end

function CheatLayer:onMsgGameConclude()
    
    self:onUpdateLayer(false)
end

function CheatLayer:onMsgAllCard(_event)

    local _userdata = unpack(_event._userdata)
    if not _userdata then
        return
    end
    local msg = _userdata
    for index, cards in pairs(msg.allCards) do
        local viewChair = LordDataMgr.getInstance():SwitchViewChairID(index)
        local stringCard = ""
        for i, card in pairs(cards) do
            if i < msg.allCounts[index] then
                stringCard = stringCard .. getCardString(card) .. ","
            end
        end
        print(k, viewChair, stringCard)

        if viewChair == 0 or viewChair == 2 then
            self:onUpdateAllCards(viewChair, cards, msg.allCounts[index])
        end
    end
end

function CheatLayer:onUpdateAllCards(index, cbCardData, count)
    
    self.m_pLayerCheat[index]:removeAllChildren()

    for k, data in pairs(cbCardData) do
        if k < count then
            local card = self:onUpdateCard(data)
            local posX = k * SPACE_CARD
            if index == 2 then
                posX = posX + (20 - count) * SPACE_CARD
            end
            card:setPositionX(posX)
            card:addTo(self.m_pLayerCheat[index])
        end
    end
end

function CheatLayer:onUpdateCard(cbCardData)
    
    local cardUI = cc.CSLoader:createNode("game/lord/CheatCard.csb")
    cardUI.rootUI   = cardUI:getChildByName("NodeRoot")
    cardUI.imgValue = cardUI.rootUI:getChildByName("ImageValue")
    cardUI.imgColor = cardUI.rootUI:getChildByName("ImageColor")
    cardUI.imgKing  = cardUI.rootUI:getChildByName("ImageKing")

    local value = bit.band(cbCardData, 0x0F)
    local color = bit.rshift(bit.band(cbCardData, 0xF0), 0x04)
    if 0 <= color and color <= 3 and 1 <= value and value <= 13 then --普通牌

        local pathValue = string.format("value-%d-%d.png", value, color % 2)
        local pathColor = string.format("color-%d.png", color)
        cardUI.imgValue:loadTexture("game/lord/gui-card/" .. pathValue, ccui.TextureResType.plistType)
        cardUI.imgColor:loadTexture("game/lord/gui-card/" .. pathColor, ccui.TextureResType.plistType)

        cardUI.imgValue:setVisible(true)
        cardUI.imgColor:setVisible(true)
        cardUI.imgKing:setVisible(false)

    elseif color == 4 and value == 14 then --小王
        cardUI.imgKing:loadTexture("game/lord/gui-card/value-53.png", ccui.TextureResType.plistType)

        cardUI.imgValue:setVisible(false)
        cardUI.imgColor:setVisible(false)
        cardUI.imgKing:setVisible(true)

    elseif color == 4 and value == 15 then --大王
        cardUI.imgKing:loadTexture("game/lord/gui-card/value-54.png", ccui.TextureResType.plistType)

        cardUI.imgValue:setVisible(false)
        cardUI.imgColor:setVisible(false)
        cardUI.imgKing:setVisible(true)
    end

    cardUI:setVisible(true)
    cardUI:setAnchorPoint(0, 0)
    cardUI:setPosition(0, 0)

    return cardUI
end

return CheatLayer
--endregion
