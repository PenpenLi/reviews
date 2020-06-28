--
-- Author: 
-- Date: 2018-08-07 18:17:10
-- 跑得快工具类

local LandGlobalDefine     = require("src.app.game.pdk.src.landcommon.data.LandGlobalDefine")
local GameLogic            = require("app.game.pdk.src.landcommon.logic.GameLogic")
local LogUtil              = require("app.hall.base.log.Log")

function RequireEX( path )
	LogINFO("[reload_file]",path)
	package.loaded[ path ]  = nil
	return require (path)
end

function LogINFO( ... )
	print("["..os.date("%H:%M:%S",os.time()).."]","第",GET_CUR_FRAME(),"帧", ... )
end

function LogERROR( ... )
	LogINFO("[ERROR]",...)
end

function WriteLogToFile( ... )
	LogUtil:getInstance():writeLog(...)
end

function D( sec )
	return cc.DelayTime:create( sec )
end

function CALL_FUNC( callBack )
	return cc.CallFunc:create( callBack )
end

function ADD_UP_TABLE( tbl )
	local ret = 0
	if type( tbl ) ~= "table" then return ret end
    for k,v in pairs( tbl ) do
        ret = ret + v
    end
    return ret
end

function UPDATE_TABLE( tbl , wantRemove )
	local org  = clone( tbl )
	local want = EXCHANGE_KEY_VAL( wantRemove )

	if type (tbl) ~= "table" then
		for k,v in ipairs( org ) do
			if want[v] then
				org[k] = nil
			end
		end
	else
		for k,v in pairs( org ) do
			if want[v] then
				org[k] = nil
			end
		end
	end
	
	return org
end

function IPARE_TABLE( tbl )
	local ret = {}
	if type (tbl) ~= "table" then
		for k,v in ipairs( tbl ) do
			table.insert( ret , v )
		end
	else
		for k,v in pairs( tbl ) do
			table.insert( ret , v )
		end
	end
	
	return ret
end

function EXCHANGE_KEY_VAL( tbl )
	local ret = {}
	for k,v in pairs( tbl ) do
		ret[v] = k
	end
	return ret
end

function IS_BELONG_TABLE(value, tbl)
	for k,v in pairs(tbl) do
		if value == v then return true end
	end
end

function MY_DUMP( tbl , level, filteDefault)
  	local msg = ""
  	filteDefault = filteDefault or false --默认过滤关键字（DeleteMe, _class_type）
  	level = level or 1
  	local indent_str = ""
  	for i = 1, level do
    	indent_str = indent_str.."  "
  	end

 	print(indent_str .. "{")
  	for k,v in pairs(tbl) do
	    if filteDefault then
			if k ~= "_class_type" and k ~= "DeleteMe" then
				local item_str = string.format("%s%s = %s", indent_str .. " ",tostring(k), tostring(v))
				print(item_str)
				if type(v) == "table" then
				  PrintTable(v, level + 1)
				end
	    	end
    	else
			local item_str = string.format("[%s%s] = %s", indent_str .. " ",tostring(k), tostring(string.format("%#x",v)))
			print(item_str)
			if type(v) == "table" then
				PrintTable(v, level + 1)
			end
    	end
  	end
 	print(indent_str .. "}")
end

function PEPLE_COUNT_FORMAT( peopleCoutn )
    if peopleCoutn < 10000 then
        return tostring(peopleCoutn)
    else
        local peopleC = peopleCoutn
        local show = math.floor(peopleC/10000)
        local yu = peopleC%10000
        local showYu = math.floor(yu/1000)
        show = show + showYu/10
       	return (show.."万")
    end
end


-- 先加个全局开关,名得到时候又说效果 不好不要这个效果 
function LAND_LOAD_OPEN_ANIMATION()
	return false
end

function LAND_LOAD_OPEN_EFFECT(node)
	if LAND_LOAD_OPEN_ANIMATION() == true then
		return
	end
	if nil == node then
		return
	end

	node:setAnchorPoint(cc.p(0.5, 0.5))
	node:setPosition(display.width / 2, display.height / 2)
	node:setScale(0.7)
	
	local action1 = cc.ScaleTo:create(0.1, 1)
	local action2 = cc.ScaleTo:create(0.05, 1.02)
	local action3 = cc.ScaleTo:create(0.05, 1)

	node:runAction(cc.Sequence:create(action1, action2, action3))
end

-- DUMP
function DUMP_DEBUG(str)
	dump(debug.traceback(), str or "DUMP_DEBUG")
end

function QKA_SHARE( atom )
	if not LandGlobalDefine.SHARE_FUNCTION_OPEN then
		TOAST("敬请期待")
		return
	end
	local function onShareResultCallback( result )
		XbShareUtil:showResultMsg(result)
		if result == XbShareUtil.WX_SHARE_OK then
        	TOAST("分享成功!")
    	end
	end
    XbShareUtil:share({gameType = XbShareUtil.gameType.share_lord, tag = 1, gameId = atom, callback = onShareResultCallback})
end

function LAND_GET_ERROR_TIP( _id )
	local errorTbl = require("app.game.pdk.src.common.LandErrorTips")
    local tip = tostring(_id)
    if _id and tonumber(_id) <= 0 then
    	if errorTbl[_id] then
    		tip = errorTbl[_id].tip2
    	end
    end

    return tip
end

function LAND_SHOW_ERROR_TIP(errorId)
	local errorStr =LAND_GET_ERROR_TIP(errorId)
	TOAST(errorStr)
end


function GET_RESULT( head, tail)
	local result = {}
    for i=1,#head do
		table.insert(result, i, head[i])
	end
	for i=1,#tail do
		table.insert(result, i+#head, tail[i])
	end
	return result
end

function GET_TABLE( result ,  tbl)
	dump(tbl, "tbl=")
	for k,v in pairs(tbl) do
		for m,n in pairs(v) do
			table.insert(result, n)	
		end
	end
	dump(result, "result=")
end

function CARD_SORT( tbl)
	local m_GameLogic = require("app.game.pdk.src.landcommon.logic.GameLogic").new()
	local wType = m_GameLogic:GetCardType(tbl)
	local head = {}
	local tail = {}
	dump(tbl, "要出的牌")
	print("出的牌型是=", wType)
	m_GameLogic:AnalysebCardData(tbl)
    if  wType == LandGlobalDefine.CT_FOUR_LINE_TAKE_ONE or wType == LandGlobalDefine.CT_FOUR_LINE_TAKE_TWO then
    	print("4带一, 4带一对 这一对属于两个单牌")
    	--4带二
    	GET_TABLE(head, m_GameLogic.fourCardTable)
    	table.sort( head, SortCardTable )

		GET_TABLE(tail, m_GameLogic.singleCardTable)
		table.sort( tail, SortCardTable )

		GET_TABLE(tail, m_GameLogic.doubleCardTable)
		table.sort( tail, SortCardTable )

    	return GET_RESULT(head, tail)
    elseif wType == LandGlobalDefine.CT_FEIJI_TAKE_ONE or wType == LandGlobalDefine.CT_THREE_TAKE_ONE or
    	wType == LandGlobalDefine.CT_FEIJI_TAKE_TWO or wType == LandGlobalDefine.CT_THREE_TAKE_TWO then
   		-- 飞机带单 三带单
   		print(" 飞机带单 三带单 飞机带对 三带对")
    	GET_TABLE(head, m_GameLogic.planeTable)
    	table.sort( head, SortCardTable )

    	GET_TABLE(tail, m_GameLogic.singleCardTable)
    	table.sort( tail, SortCardTable )

    	GET_TABLE(tail, m_GameLogic.doubleCardTable)
    	table.sort( tail, SortCardTable )

    	return GET_RESULT(head, tail)
    end
    print("不是三带4带类型,返回原值 ")
	return tbl
end
