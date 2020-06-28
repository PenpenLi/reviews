--
-- Author: 
-- Date: 2018-08-07 18:17:10
-- 跑得快扑克牌工具
local CardConfig   = require("app.game.pdk.src.landcommon.data.CardConfig")
local CardKit = {}

local S2C_CARD_MAP =
{
       0x33,0x23,0x13,0x03,0x34,0x24,0x14,0x04,0x35,0x25,0x15,0x05,0x36,0x26,0x16,0x06,
       0x37,0x27,0x17,0x07,0x38,0x28,0x18,0x08,0x39,0x29,0x19,0x09,0x3A,0x2A,0x1A,0x0A,
       0x3B,0x2B,0x1B,0x0B,0x3C,0x2C,0x1C,0x0C,0x3D,0x2D,0x1D,0x0D,0x31,0x21,0x11,0x01,
       0x32,0x22,0x12,0x02,0x4E,0x4F,
}

function CardKit:S2C_CONVERT( tbl )
--	local ret = {}
--	if type (tbl) ~= "table" then
--		for k,v in ipairs( tbl ) do
--			ret[k] = S2C_CARD_CONVERT( v )
--		end
--	else
--		for k,v in pairs( tbl ) do
--			ret[k] = S2C_CARD_CONVERT( v )
--		end
--	end
--	return ret
    return tbl
end

function CardKit:C2S_CONVERT( tbl )
--	local ret = {}
--	if type (tbl) ~= "table" then
--		for k,v in ipairs( tbl ) do
--			ret[k] = C2S_CARD_CONVERT( v )
--		end
--	else
--		for k,v in pairs( tbl ) do
--			ret[k] = C2S_CARD_CONVERT( v )
--		end
--	end
--	return ret
    return tbl
end

function CardKit:S2C_CARD_CONVERT( val )
    return S2C_CARD_MAP[ val + 1 ]
end

function C2S_CARD_CONVERT( cardVale )
    local ret = 0
    for k,v in pairs( S2C_CARD_MAP ) do
       if v == cardVale then
           ret = k-1
           return ret
       end
    end
end

function CONVERT_AND_SORT( server_card )
	local tbl = S2C_CONVERT( server_card )
	table.sort( tbl, SortCardTable )
	return tbl
end

local function cal_layout_width( num )
	local cardSpace = 0
	local oneCardWidth = CardConfig.CardWidth
	if num <= 1 then return oneCardWidth , cardSpace end
	local size = cc.Director:getInstance():getWinSize()
	local spaceCount = math.max(1,num-1)
	cardSpace = (size.width - oneCardWidth)/spaceCount
	cardSpace = math.min(CardConfig.CardSpace,cardSpace)
	local ret = spaceCount*cardSpace+oneCardWidth
	return ret,cardSpace
end

local function create_by_prefix( pre , client_card_id )
	local info = CardConfig.CardInfos[ client_card_id ]
	if not info then return end
	local path   = "#"..pre.."_"..info.engName..".png"
	local sprite = display.newSprite( path )
	return sprite
end

function CREATE_HAPPY_SMALL_CARD( client_card_id )
	return create_by_prefix("hldz_poker",client_card_id)
end

function CREATE_CLASSIC_CARD( client_card_id )
	return create_by_prefix("lord_poker",client_card_id)
end

function CREATE_HAND_CARD_LAYOUT( client_tbl )
	local size = cc.Director:getInstance():getWinSize()
	local width,cardSpace = cal_layout_width( #client_tbl )
	local layout = ccui.Layout:create()
	layout:setAnchorPoint(0.5,0)
	layout:setPositionX( size.width/2 )
	layout:setContentSize( cc.size(width, CardConfig.CardHeight) )
	for k,v in ipairs( client_tbl ) do
		local sprite  = CREATE_CLASSIC_CARD( v )
		sprite:setAnchorPoint(cc.p(0,0))
		sprite:setPositionX((k-1)*cardSpace)
		layout:addChild( sprite )
	end
	return layout
end

local function get_card_value( client_card_id )
	local info = CardConfig.CardInfos[ client_card_id ]
	if not info then return end
	return info.Value
end

function find_replace_card( card , out_card , hand_card , bottom_card )
	for k,v in pairs( hand_card ) do
		if not IS_BELONG_TABLE( v , out_card ) and IS_BELONG_TABLE(v,bottom_card) and get_card_value( card ) == get_card_value( v ) then
			table.remove( hand_card , k )
			return v
		end
	end
	return card
end

function REPLACE_BOTTOM_CARD( out_card , hand_card , bottom_card )
	local ret = {}
	for k,v in pairs( out_card ) do
		ret[k] = find_replace_card( v , out_card , hand_card , bottom_card )
	end
	return ret
end

return CardKit