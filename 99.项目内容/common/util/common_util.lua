--[[
通用接口文件
]]
local scheduler              =  require("framework.scheduler") 
common_util = {}


function common_util.tansCoin( coin )
    if not coin then coin = 0 end 
    return tonumber(coin) 
end

function common_util.trueCoin( coin )
    if not coin then coin = 0 end 
    return CommonConfig[100002].value * coin
end

--设置显示金币值
function common_util.setCoinStr(text_lable, coin, precision,prefix)
    local prefix = prefix or ""
    coin = tonumber(coin)
    text_lable.coin_num = coin

    -- if coin < 1 then
    --     text_lable:setString(coin)
    --     return
    -- end

    precision = precision or 0
    local num_str = common_util.getShortString(coin, precision)
    text_lable:setString(prefix..num_str)
    if coin == 0 then
        text_lable:setString(prefix .. "0")
    end
end

local mrandom = math.random
local mround = math.round

--@ 字符串有效性检查,只有大写字母，小写字母，数字和下划线
function common_util.wordValidCheck(inputStr)
    local validTable = {
        UPPER = {65, 90},LOWER = {97, 122},NUM = {48, 57},OTHER = {95,95}
    }
    for i=1,string.len(inputStr) do
        local wordByte = string.byte(inputStr, i)
        print(wordByte)
        local check = false
        for k,v in pairs(validTable) do
            local start = v[1]
            local endNum = v[2]
            if wordByte >= start and wordByte <= endNum then
                check = true
            end
        end
        if check == false then
            return false
        end
    end
    return true
end

--[[
纯数字检测
]]
function common_util.is_number(str)
    local ret = string.find(tostring(str), "^[.]?%d+$")
    return ret
end

-- 长数字 -> 短字符 （万、亿）
-- @param num          长数字
-- @param precision    进度(小数点后保留位数) [默认2]
-- ]]
function common_util.getShortString(num, precision)
    num = num or 0
    precision = precision or 2
    local ret = "0"
    local str = "%."..precision.."f%s"
    local t = ""
    if num < 0 then
        t = "-"
    end
    num = math.abs(num)
    if precision == 0 then
        num = math.floor(num)
    end
    if num < 10000 then
        if num - math.floor(num) > 0 then
            ret = string.format("%."..precision.."f", num)--tostring(num)
        else
            ret = num
        end
        
    elseif num < 100000000 then
        if num/10000 - math.floor(num/10000) == 0 then
            str = "%d%s"
        end
        ret = string.format(str, num / 10000, "万")
    else
        if num/100000000 - math.floor(num/100000000) == 0 then
            str = "%d%s"
        end
        ret = string.format(str, num / 100000000, "亿")
    end

    return t .. ret
end

--带小数的数字 -> 保留小数
function common_util.get_retain_decimal(num, precision)
    precision = precision or 2

    if math.floor(num) < num then
        ret = string.format("%."..precision.."f", num)--tostring(num)
    else
        ret = num
    end

    return ret
end

--[[
判空
]]
function common_util.is_empty(obj)
    if not obj then return true end
    if type(obj) == "string" and obj == "" then return true end
    if type(obj) == "number" and obj == 0 then return true end
    if type(obj) == "table" and table.nums(obj) == 0 then return true end
    if type(obj) == "userdata" and tolua.isnull(obj) then return true end
    return false
end

-- 从from开始到to随机生成一个数
function common_util.rand(from , to)
    return mrandom() * (to - from) + from
end

function common_util.randomChar(min, max)
    return string.char(mrandom(string.byte(min), string.byte(max)))
end

function common_util.randomString(strLen, timeLen)
    timeLen = math.min(strLen - 1, checknumber(timeLen))
    local s, t = "", 0
    for i = 1, strLen - timeLen do
        t = mrandom(1, 30)
        if t % 3 == 1 then
            s = s..common_util.randomChar("0", "9")
        elseif t % 3 == 2 then
            s = s..common_util.randomChar("a", "z")
        else
            s = s..common_util.randomChar("A", "Z")
        end
    end
    if timeLen > 0 then
        t = tostring(os.time())
        s = s..string.sub(t, -timeLen)
    end
    return s
end

------------------------------------------------------------------------
--[[
-- 闪光
-- ]]
function common_util.bling_animation(node, back)
    if not node then return end
    local time = 0.4
    local seq = {
        cc.FadeIn:create(time),
        cc.FadeOut:create(time),
        cc.FadeIn:create(time),
        cc.FadeOut:create(time),
        cc.FadeIn:create(time),
        cc.FadeOut:create(time),
        cc.CallFunc:create(function ( ) 
            if back then back() end
        end),
    }

    node:runAction(transition.sequence(seq))
end

--[[
-- 缩放动画
-- ]]
function common_util.zoom_animation( node )
    
    local seq = {
        cc.EaseSineIn:create(cc.ScaleTo:create(0.05, 0.9)),
        cc.EaseSineOut:create(cc.ScaleTo:create(0.05, 0.8)),
    }

    node:runAction(transition.sequence(seq))
end

--[[
-- 缩放动画
-- ]]
function common_util.zoom_animation_hall( node )
    
    local seq = {
        cc.EaseSineIn:create(cc.ScaleTo:create(0.075, 1.3)),
        cc.EaseSineOut:create(cc.ScaleTo:create(0.075, 0.7)),
        cc.EaseSineIn:create(cc.ScaleTo:create(0.075, 1.2)),
        cc.EaseSineOut:create(cc.ScaleTo:create(0.075, 0.8)),
        cc.EaseSineIn:create(cc.ScaleTo:create(0.075, 1.1)),
        cc.EaseSineOut:create(cc.ScaleTo:create(0.075, 1)),
    }

    node:runAction(transition.sequence(seq))
end


--随机时间
function common_util.random_time(from, to)
    return 0.001 * common_util.rand(from,to)
end

--[[
-- 抛筹码
-- ]]
function common_util.throw_jetton(node, ox, oy, epos, time, scale, callback)
    local time = time or common_util.random_time(500, 800)
    local x = common_util.rand(-ox,ox)
    local y = common_util.rand(-oy,oy)

    local ac = cc.MoveTo:create(time, cc.p(epos.x + x, epos.y + y))
    ac = cc.EaseExponentialOut:create(ac)

    local scale = cc.ScaleTo:create(time/2, scale)

    local angle = common_util.random_time(-180000, 180000)
    local rota = cc.RotateTo:create(1.2, angle)
    rota = cc.EaseExponentialOut:create(rota)

    ac = cc.Spawn:create(ac, scale, rota)

    local callfun = cc.CallFunc:create(function ( )
        if callback then
            callback(node)
        end
    end)


    ac = cc.Sequence:create(ac, rota, callfun)
    node:runAction(ac)
end

--[[
-- 回收筹码
-- ]]
function common_util.collect_jetton(node, aim_node, time, elastic_x, elastic_y, scale, call)
    if not node then return end
    scale = scale or 1
    local time = time or common_util.random_time(200,500)
    local sx, sy = node:getPosition()
    local ex, ey = aim_node:getPosition()

    local elasticx = elastic_x or common_util.random_time(35000,65000)
    local elasticy = elastic_y or common_util.random_time(35000,65000)

    if sx < ex then elasticx = -elasticx end
    if sy < ey then elasticy = -elasticx end

    local back_time = common_util.random_time(150,500)

    local acBy = cc.MoveBy:create(back_time, cc.p(elasticx, elasticy))
    acBy = cc.EaseSineOut:create(acBy)

    local delay_time = 0.075
    local delay = cc.DelayTime:create(delay_time)
    local acTo = cc.MoveTo:create(time, cc.p(ex, ey))
    acTo = cc.EaseSineIn:create(acTo)

    local callfun = cc.CallFunc:create(function ( )
        if call then
            call(node)
        end
    end)

    node:setScale(scale)

    local ac = cc.Sequence:create(acBy, delay, acTo, callfun)
    node:runAction(ac)
end

--[[
-- 五人牛牛结算筹码
-- ]]
function common_util.result_jetton(node, aim_node, time, scale, call)
    if not node then return end
    scale = scale or 1
    local time = time or common_util.random_time(200,500)
    local sx, sy = node:getPosition()

    local ex, ey = 0,0
    if aim_node then
        ex, ey = aim_node:getPosition()
    end
    -- local delay_time = 0.075
    -- local delay = cc.DelayTime:create(delay_time)
    local acTo = cc.MoveTo:create(time, cc.p(ex, ey))
    acTo = cc.EaseSineIn:create(acTo)

    local callfun = cc.CallFunc:create(function ( )
        if call then
            call(node)
        end
    end)
    node:setScale(scale)
    local ac = cc.Sequence:create( acTo, callfun)
    node:runAction(ac)
end

--[[
-- 五人牛牛结算筹码
-- ]]
function common_util.result_jetton2(node, pos, time, scale, call)
    if not node then return end
    scale = scale or 1
    local time = time or common_util.random_time(200,500)
    local sx, sy = node:getPosition()

    local ex, ey = 0,0
    if pos then
        ex, ey = pos.x,pos.y
    end
    -- local delay_time = 0.075
    -- local delay = cc.DelayTime:create(delay_time)
    local acTo = cc.MoveTo:create(time, cc.p(ex, ey))
    acTo = cc.EaseSineIn:create(acTo)

    local callfun = cc.CallFunc:create(function ( )
        if call then
            call(node)
        end
    end)
    node:setScale(scale)
    local ac = cc.Sequence:create( acTo, callfun)
    node:runAction(ac)
end

--[[
-- 吞筹码
-- ]]
function common_util.swallow_jetton(node, time, call)
    local time = time or common_util.random_time(150,350)
    local fade = cc.FadeOut:create(time)
    local callfun = cc.CallFunc:create(function ( )
        call(node)
    end)

    local ac = cc.Sequence:create(fade, callfun)
    node:runAction(ac)
end

function common_util.getJettonsCows(coin ,bet)
    local jettons = {}
    local tmp_coin = coin
    table.sort(bet, function ( a,b ) return a < b end ) 

    for i = #bet , 1, -1 do
        -- print("bet[i]=",bet[i])
        local c = bet[i]
        if c >= 1 then
            c = math.floor(c)
        end
        local leave_coin = c
        if tmp_coin >= leave_coin then
            local t_c = tmp_coin/leave_coin
            if t_c >= 1 then
                t_c = math.floor(t_c)
            end
            jettons[leave_coin] = t_c
            tmp_coin = tmp_coin - jettons[leave_coin]*leave_coin
            -- print("leave_coin,tmp_coin=",coin,leave_coin,tmp_coin)
        end
    end 
    local num = 0
    for k,v in pairs(bet) do
        local c = v
        if c >= 1 then
            c = math.floor(c)
        end
        if jettons[c] then
            local t_c = v
            if t_c >= 1 then
                t_c = math.floor(t_c)
            end
            num = num + jettons[t_c]
        end
    end
    
    if num > 1000 then
        for i , leave in pairs(bet) do
            jettons[leave] = 10
        end
    end
    return jettons
end

function common_util.getJettonsConfig(coin)
    local jettons = {}
    local tmp_coin = coin
    local bet = {}
    -- dump(ChipConfig)
    print("tmp_coin=",tmp_coin)
    for k , v in pairs(ChipConfig) do
        if type(k) == "number" and v.chip_limit ~= "" then
            table.insert(bet,v.chip_limit)
        end
    end
    table.sort(bet, function ( a,b ) return a < b end ) 

    for i = #bet , 1, -1 do
        -- print("bet[i]=",bet[i])
        local c = bet[i]
        if c >= 1 then
            c = math.floor(c)
        end
        local leave_coin = c
        if tmp_coin >= leave_coin then
            local t_c = tmp_coin/leave_coin
            if t_c >= 1 then
                t_c = math.floor(t_c)
            end
            jettons[leave_coin] = t_c
            tmp_coin = tmp_coin - jettons[leave_coin]*leave_coin
            print("leave_coin,tmp_coin=",coin,leave_coin,tmp_coin)
        end
    end 
    local num = 0
    for k,v in pairs(bet) do
        local c = v
        if c >= 1 then
            c = math.floor(c)
        end
        if jettons[c] then
            local t_c = v
            if t_c >= 1 then
                t_c = math.floor(t_c)
            end
            num = num + jettons[t_c]
        end
    end
    
    -- if num > 1000 then
    --     for i , leave in pairs(bet) do
    --         jettons[leave] = 10
    --     end
    -- end
    dump(jettons)
    return jettons
end

--[[
-- 百人类筹码
-- ]]
function common_util.getJettons( coin, bet )
    local jettons = {}
    table.sort(bet, function ( a,b ) return a < b end ) 
    local leave_1 = bet[1]
    local leave_2 = bet[2]
    local leave_3 = bet[3]
    local leave_4 = bet[4]
    local leave_5 = bet[5]

    coin = math.floor(coin)


    if coin >= leave_5 then
        jettons[leave_5] = math.floor(coin/leave_5)
        local remain = coin -  jettons[leave_5]*leave_5
        jettons[leave_4] = math.floor(remain/leave_4)
        remain = remain - jettons[leave_4]*leave_4
        jettons[leave_3] = math.floor(remain/leave_3)
        remain = remain - jettons[leave_3]*leave_3
        jettons[leave_2] = math.floor(remain/leave_2)
        remain = remain - jettons[leave_2]*leave_2
        jettons[leave_1] = remain
    elseif coin >= leave_4 and coin < leave_5 then
        jettons[leave_4] = math.floor(coin/leave_4)
    elseif coin >= leave_3 and coin < leave_4 then
        jettons[leave_3] = math.floor(coin/leave_3)
    elseif coin >= leave_2 and coin < leave_3 then
        jettons[leave_2] = math.floor(coin/leave_2)
    else
        jettons[leave_1] = math.floor(coin/leave_1)
        if jettons[leave_1] > 5 then jettons[leave_1] = 5 end
    end

    local num = 0
    for k,v in pairs(bet) do
        if jettons[v] then
            num = num + jettons[v]
        end
    end
    
    if num > 1000 then
        jettons[leave_1] = 5
        jettons[leave_2] = 5
        jettons[leave_3] = 5
        jettons[leave_4] = 5
        jettons[leave_5] = 5
    end
    return jettons
end

function common_util.get_jettion_config(coin)
    for k , v in pairs(ChipConfig) do
        if type(k) == "number" then
            if v.chip_limit == coin then
                return v.resource_small
            end
        end
    end
    return ChipConfig[100005].resource_small
end

-- 抛出去的小筹码
function common_util.get_jetton_res( coin, bet)
    local jettons_res = {
        [1] = "xiao_cm_37.png",
        [2] = "xiao_cm_39.png",
        [3] = "xiao_cm_41.png",
        [4] = "xiao_cm_43.png",
        [5] = "xiao_cm_45.png",
    }

    local res = jettons_res[1]
    for k,v in pairs(bet) do
        if coin == common_util.tansCoin(v) then
            res = jettons_res[k]
            return res
        end
    end

    return res
end

-- 抛出去的小筹码(从分开始)
function common_util.get_jetton_res_minute( coin, bet)
    local jettons_res = {
        [1] = "xiao_cm_29.png",
        [2] = "xiao_cm_31.png",
        [3] = "xiao_cm_33.png",
        [4] = "xiao_cm_35.png",
        [5] = "xiao_cm_37.png",
        [6] = "xiao_cm_39.png",
        [7] = "xiao_cm_41.png",
        [8] = "xiao_cm_43.png",
        [9] = "xiao_cm_45.png",
    }

    local res = jettons_res[1]
    for k = #jettons_res, 1 , -1 do
    -- for k,v in pairs(bet) do
    -- print("coin,bet[k],k=",coin,bet[k],common_util.tansCoin(bet[k]),k)
        if tonumber(coin) >= tonumber(common_util.tansCoin(bet[k])) then
            res = jettons_res[k]
            return res
        end
    end

    return res
end


--[[
-- 裁剪图形
-- node 要裁剪的图片
--stencil 用来裁剪的图片
-- ]]
function common_util.clipNode(node, stencil)
    local clipping_node = cc.ClippingNode:create()
    clipping_node:setStencil(stencil)
    clipping_node:addChild(node)
    clipping_node:setAlphaThreshold(0.5)
    clipping_node:setInverted( false )

    return clipping_node
end




--[[
-- 获取动画
-- ]]
function common_util:get_animation(parent, path, start,last, pos, callback)
    local node = cc.uiloader:load(path)
    local ac = cc.CSLoader:createTimeline(path)

    local isRepeat = true
    if callback then isRepeat = false end 
  --   local aniInfo = ac:getAnimationInfo("animation0")
    common_util.playAnimation(ac,start,last,isRepeat,function (  )
        if not callback then return end
        callback(node)
    end)
    if not pos then pos = cc.p(0,0) end

    node:setPosition(pos)
    parent:addChild(node,100)
    parent:runAction(ac)

    common_util.setBlendFuncEx(node, 10)
    return node, ac
end

function common_util.playAnimation(timeline,start,last,loop,func) 
   
    timeline:gotoFrameAndPlay(start, last, loop)

--    if func and type(func) == "function" then
--        timeline:setLastFrameCallFunc(func)
--    else
--        timeline:clearLastFrameCallFunc( )
--    end
end

function common_util.setBlendFuncEx(node, num )
    local tb = {}
    for i=1,num do
        table.insert(tb, "add_"..i)
    end

    common_util.setBlendFunc(node, tb, GL_ONE, GL_SRC_ALPHA)
end

--叠加模式
function common_util.setBlendFunc(node, tb, targt, original)
    for k,v in pairs(tb) do
        local effect = cc.uiloader:seekNodeByName(node, v)
        local bf = {src = original, dst = targt}
        if effect then
            effect:setBlendFunc(original,targt)
        end
    end
end

--发牌动作
function common_util.play_card(data)
    
end

--------------
--停止定时器
function common_util.stopSch( sch )
    if sch then
        scheduler.unscheduleGlobal(sch)
        sch = nil
    end
end

function common_util.stopSchs( schs )
    for k,v in pairs(schs) do
        common_util.stopSch(v)
    end
end

local Designer_data = ""
function common_util.clean_debuf( )
    Designer_data = ""
    common_util.writeData("")
end

--写数据到文件
function common_util.writeData( str )
    Designer_data = Designer_data..str
    local file = io.open(device.writablePath.."Designer.lua","w")
    file:write(Designer_data)
    file:close()
end

common_util.jettons_node = {}
common_util.index = 1
function common_util.get_jettion( clone_node )
    local is_repeat = false
    local node = common_util.jettons_node[common_util.index]
    if node then
        is_repeat = true
    else
        node = clone_node:clone()
        table.insert(common_util.jettons_node, node)
    end
    
    common_util.index = common_util.index + 1
    
    return node, is_repeat
end

function common_util.remove_jetton(  )
   for k,v in pairs(common_util.jettons_node) do
        v:removeFromParent()
        v = nil
    end

    common_util.jettons_node = {}
    common_util.index = 1
end

--颜色值转rgb
function common_util.colorFromString(str, decimal)
    if not str then return end
    local c = {}
    if type(str) == "string" then
        if string.find(str, "0x") or string.find(str, "0X") then
            str = string.sub(str, 3)
            decimal = false
        end
        if string.find(str, "#") then
            str = string.sub(str, 2)
            decimal = false
        end
        local pre = decimal and "" or "0x"
        c.r = pre..string.sub(str, 1, 2)
        c.g = pre..string.sub(str, 3, 4)
        c.b = pre..string.sub(str, 5, 6)
    else
        c.r = str.r or str[1]
        c.g = str.g or str[2]
        c.b = str.b or str[3]
    end
    return cc.c3b(tonumber(c.r) or 0, tonumber(c.g) or 0, tonumber(c.b) or 0)
end


common_util.cnt = 0
--
function common_util.get_node_num( layer )
    if layer then
        common_util.cnt = common_util.cnt + layer:getChildrenCount()
        local parent = layer:getChildren()
        for v, ly in pairs(parent) do
            if ly then
                common_util.get_node_num(ly)
            end
        end
    end
    return common_util.cnt
end

--[[
num_lbl : 需要滚动的文本
turn_end_func : 滚动完成的回调
precision ：滚动数字保留几位小数 默认为0
]]
function common_util.turn_over_number_scroll_quick( num_lbl, old_num, new_num, roll_time,turn_end_func,preci )
    local precision = 0
    if preci then
        precision = preci
    else
        if CommonConfig[100002].value == 1 then
            precision = 0
        elseif CommonConfig[100002].value == 10000 then
            precision = 2

        end
    end
    local roll_time = roll_time or 1
    local timeOffset = 0.017
    local apartNum = roll_time/timeOffset
    num_lbl:stopAllActions()
    num_lbl:setString(UtilHelper.numberToMoneyString(old_num))

    local delta_num = new_num - old_num
    
    local delta_cell_num
    -- delta_num为个位数时，正负取整要区分开来，math.ceil(0.5) = 1; math.ceil(-0.5) = 0; 所以当为负数时用math.floor()
    if precision == 0 then
        if delta_num > 0 then
            delta_cell_num = math.ceil(delta_num/apartNum)
            local temp = tostring(delta_cell_num)
            temp=string.gsub(temp, "0", "1")
            delta_cell_num = tonumber(temp)
        else
            delta_cell_num = math.floor(delta_num/apartNum)
        end
    else
        delta_cell_num = delta_num / apartNum
    end

    local turn_over_func = function()
        -- 增加
        if delta_num > 0 then
            old_num = old_num + delta_cell_num
            if old_num >= new_num then
                old_num = new_num
                
                num_lbl:setString(UtilHelper.numberToMoneyString(string.format("%."..precision.."f", old_num)))
                num_lbl:stopAllActions()
                if turn_end_func then
                    turn_end_func()
                end
            end
        else
            old_num = old_num + delta_cell_num
            if old_num <= new_num then
                old_num = new_num
                num_lbl:setString(UtilHelper.numberToMoneyString(string.format("%."..precision.."f", old_num)))
                num_lbl:stopAllActions()
                 if turn_end_func then
                    turn_end_func()
                end
            end
        end
        num_lbl:setString(UtilHelper.numberToMoneyString(string.format("%."..precision.."f", old_num)))
    end
    num_lbl:runAction(cc.RepeatForever:create( cc.Sequence:create(
                cc.DelayTime:create(timeOffset),
                cc.CallFunc:create(turn_over_func)
                ) 
            ))
end

--[[
num_lbl : 需要滚动的文本
turn_end_func : 滚动完成的回调
precision ：滚动数字保留几位小数 默认为0
]]
function common_util.turn_over_number_scroll(num_lbl, old_num, new_num, turn_end_func,preci,sep,timeOffset)
    local precision = 0
    local timeOffset = timeOffset or 0.1
    if preci then
        precision = preci
    else
        if CommonConfig[100002].value == 1 then
            precision = 0
        elseif CommonConfig[100002].value == 10000 then
            precision = 2

        end
    end
    old_num = tonumber(old_num)
    local sep = sep or ','
    num_lbl:stopAllActions()
    num_lbl:setString(UtilHelper.numberToMoneyString(old_num))
    old_num = UtilHelper.moneyStringToNumber(old_num,sep)
    local delta_num = new_num - old_num
    local delta_cell_num
    -- delta_num为个位数时，正负取整要区分开来，math.ceil(0.5) = 1; math.ceil(-0.5) = 0; 所以当为负数时用math.floor()
    if precision == 0 then
        if delta_num > 0 then
            delta_cell_num = math.ceil(delta_num/10)
        else
            delta_cell_num = math.floor(delta_num/10)
        end
    else
        delta_cell_num = string.format("%."..precision.."f", delta_num / 10)
    end
    
    local turn_over_func = function()
        -- 增加
        if delta_num > 0 then
            old_num = old_num + delta_cell_num
            if old_num >= new_num then
                old_num = new_num
                
                num_lbl:setString(UtilHelper.numberToMoneyString(old_num,sep))
                num_lbl:stopAllActions()
                if turn_end_func then
                    turn_end_func()
                end
            end
        else
            old_num = old_num + delta_cell_num
            if old_num <= new_num then
                old_num = new_num
                num_lbl:setString(UtilHelper.numberToMoneyString(old_num,sep))
                num_lbl:stopAllActions()
                 if turn_end_func then
                    turn_end_func()
                end
            end
        end
        num_lbl:setString(UtilHelper.numberToMoneyString(old_num,sep))
    end
    num_lbl:runAction(cc.RepeatForever:create( cc.Sequence:create(
                cc.DelayTime:create(timeOffset),
                cc.CallFunc:create(turn_over_func)
                ) 
            ))
end

-- 
function common_util.dump_memory(  )
    local sharedTextureCache = cc.Director:getInstance():getTextureCache()
    printInfo(sharedTextureCache:getCachedTextureInfo())
end

--获取玩家头像
function common_util.get_head_icon(head)
    if head == nil or type(head) == "table" then
        return "head_n1.png"
    else
        local file_name = FacelookConfig[tonumber(head)] and FacelookConfig[tonumber(head)].icon or ""
        if file_name == nil or file_name == "" then
            file_name = "head_n1.png"
        end
        return file_name
    end
end

--is_not_clip
function common_util.change_head(facelook,  head_node, is_not_clip)
    if type(facelook) == "table" or facelook == nil then
        if type(facelook) == "table" then
            local long_str = ""
            for k , v in pairs(facelook) do
                long_str = long_str .. string.char(v)
            end
            print("long_str=",long_str)
            facelook = long_str
        else
            return
        end
    end

    if tonumber(facelook) then
        head_node:loadTexture(common_util.get_head_icon(facelook), ccui.TextureResType.plistType)
    else
        NetSprite:getImageByUrl(facelook, function ( node )
            local scale = head_node:getScale()
            local size_head = head_node:getContentSize()
            local node_head = node:getContentSize()
            node:setScaleX(size_head.height/node_head.height+0.1)
            node:setScaleY(size_head.width/node_head.width+0.1)
            if not is_not_clip then
                local stencil = display.newSprite("#hall_head1.png")
                local stencil_size = stencil:getContentSize()
                stencil:setScale(size_head.height/stencil_size.height+0.1)

                local clipping_node = common_util.clipNode(node, stencil)
                clipping_node:setPosition(head_node:getPosition())
                clipping_node:setScale(0.94*scale)
                head_node:getParent():addChild(clipping_node,0)
            else
                node:setPosition(head_node:getPosition())
                head_node:getParent():addChild(node,0)
            end
        end)
    end

end

function common_util.transName(obj,name)
    local len = string.len(name)
    local str_list = {}
    for i = 1 , len do
        local gs = string.sub(name,i,i)
        local asc = string.byte(gs)
        if asc == nil or asc > 127 then
            if #str_list == 0 then
                table.insert(str_list,string.sub(name,1,3))
            end
            break
        else
            if #str_list <= 4 then
                table.insert(str_list,gs)
            else
                break
            end
        end
    end
    local new_name = ""
    for k , v in pairs(str_list) do
        new_name = new_name .. v
    end
    if obj then
        obj:setString(new_name.."...")
    end
    return new_name
end

function common_util.reverseTable(tab_data)
    local tab = clone(tab_data)
    local tmp = {}
    for i = 1, #tab do
        local key = #tab
        tmp[i] = table.remove(tab)
    end

    return clone(tmp)
end

function common_util.delete_data( list, num)
    if #list <= num then
        return list
    end

    local temp = {}
    local index = 1
    for i=#list - num,#list do
        temp[index] = clone(list[i])
        index = index + 1
    end

    return temp
end

function common_util.deepNodeColor(node,color)
    local shadows = {
        ["shadow_image"] = true,
        ["shadow_image_1"] = true,
        ["shadow_image_2"] = true,
        ["shadow_image_3"] = true,
        ["shadow_image_4"] = true,
        ["shadow_image_5"] = true,
    }
    
    node:setColor(color)
    for k,v in pairs(node:getChildren()) do
        if not shadows[v:getName()] then
            common_util.deepNodeColor(v,color)
        end
    end
end

--[[
检测手机号
]]
function common_util.is_phone(phone, callback)
    phone = checknumber(phone)
    local ret = phone / 10000000000

    if ret < 1 or ret > 2 then
        if callback then
            callback(false)
        end
        return
    end

    callback(true)
    -- local url = "https://tcc.taobao.com/cc/json/mobile_tel_segment.htm"
    -- local request = network.createHTTPRequest(function ( event )
    --     if event.name == "completed" then
    --         local str = event.request:getResponseString()
    --         dump(str)

    --         callback(string.find(str, phone) ~= nil)
    --     end
    -- end,url,"POST")

    -- request:addPOSTValue("tel", phone)
    -- request:start()
end

-------随机头像
function common_util.randomFacelook(  )
    local index = 10000 + math.floor(common_util.rand(1,12)) 
    
    local info = FacelookConfig[index]
    if info then
        local sex = info.sex
        if index <= 10001 or index >= 10012 then
            index = 10012
        end

        return tostring(index), info.sex
    end

    return nil,nil
end

--通用bigwin大奖动画 播完移除
function common_util.getBigWinAni(  )
    local bigWin = cc.uiloader:load("common/common_BINWIN.csb")
    common_util.setBlendFuncEx(bigWin,20)
    local ac = cc.CSLoader:createTimeline("common/common_BINWIN.csb")
    local animationInfo = ac:getAnimationInfo("animation0")
    ac:gotoFrameAndPlay(animationInfo.startIndex,animationInfo.endIndex,false)
    ac:setLastFrameCallFunc(function ( ... )
        bigWin:removeFromParent()
    end)
    local Particle_10bo = cc.uiloader:seekNodeByName(bigWin,"Particle_10bo")
    local Particle_20bo = cc.uiloader:seekNodeByName(bigWin,"Particle_20bo")
    local Particle_280bo = cc.uiloader:seekNodeByName(bigWin,"Particle_280bo")
    ac:setFrameEventCallFunc(function ( frame )
        local frameEvent = frame:getEvent()
        if not frameEvent then return end
        print("getBigWinAni frameEvent===========>",frameEvent)
        if frameEvent == "Particle_10bo" then
            Particle_10bo:resetSystem()
        elseif frameEvent == "Particle_20bo" then
            Particle_20bo:resetSystem()
        elseif frameEvent == "Particle_280bo" then
            Particle_280bo:resetSystem()
        end
    end)
    bigWin:runAction(ac)
    return bigWin
end

--通用superwin动画 播完移除
function common_util.getSuperAni(  )
    local bigWin = cc.uiloader:load("common/common_SUPER.csb")
    common_util.setBlendFuncEx(bigWin,20)
    local ac = cc.CSLoader:createTimeline("common/common_SUPER.csb")
    local animationInfo = ac:getAnimationInfo("animation0")
    ac:gotoFrameAndPlay(animationInfo.startIndex,animationInfo.endIndex,false)
    ac:setLastFrameCallFunc(function ( ... )
        bigWin:removeFromParent()
    end)
    local Particle_10bo = cc.uiloader:seekNodeByName(bigWin,"Particle_10bo")
    local Particle_20bo = cc.uiloader:seekNodeByName(bigWin,"Particle_20bo")
    local Particle_280bo = cc.uiloader:seekNodeByName(bigWin,"Particle_280bo")
    ac:setFrameEventCallFunc(function ( frame )
        local frameEvent = frame:getEvent()
        if not frameEvent then return end
        print("getSuperAni frameEvent===========>",frameEvent)
        if frameEvent == "Particle_10bo" then
            Particle_10bo:resetSystem()
        elseif frameEvent == "Particle_20bo" then
            Particle_20bo:resetSystem()
        elseif frameEvent == "Particle_280bo" then
            Particle_280bo:resetSystem()
        end
    end)
    bigWin:runAction(ac)
    return bigWin
end

--通用amazing动画 播完移除
function common_util.getAmazingAni(  )
    local bigWin = cc.uiloader:load("common/common_AMAZING.csb")
    common_util.setBlendFuncEx(bigWin,20)
    local ac = cc.CSLoader:createTimeline("common/common_AMAZING.csb")
    local animationInfo = ac:getAnimationInfo("animation0")
    ac:gotoFrameAndPlay(animationInfo.startIndex,animationInfo.endIndex,false)
    ac:setLastFrameCallFunc(function ( ... )
        bigWin:removeFromParent()
    end)
    local Particle_165bo = cc.uiloader:seekNodeByName(bigWin,"Particle_165bo")
    ac:setFrameEventCallFunc(function ( frame )
        local frameEvent = frame:getEvent()
        if not frameEvent then return end
        print("getAmazingAni frameEvent===========>",frameEvent)
        if frameEvent == "Particle_165bo" then
            Particle_165bo:resetSystem()
        end
    end)
    bigWin:runAction(ac)
    return bigWin
end

function common_util.getIP( callback )
    UIManager:Loading_manage(true)
    local url = "http://2018.ip138.com/ic.asp"--"http://ip.qq.com"
    local request = network.createHTTPRequest(function ( event )
        if event.name == "completed" then
            local str = event.request:getResponseString()
            local index1 = string.find(str, "%[")
            local index2 = string.find(str, "%]")
            str = string.sub(str, index1+1, index2-1)
            callback("")
        elseif event.name == "failed" then
            callback("")
        end
    end,url,"GET")

    request:setTimeout(2)
    request:start()
end

--百人类投注筹码上的数字
function common_util.getNum_res( coin )
    local num_str = common_util.getShortString(coin)
    local tb = {}
    tb["万"] = {"xiao_cm_24.png", 8.5}
    tb["."] = {"xiao_cm_25.png", 7}
    tb["1"] = {"xiao_cm_03.png", 5}
    tb["2"] = {"xiao_cm_05.png", 7}
    tb["3"] = {"xiao_cm_07.png", 8}
    tb["4"] = {"xiao_cm_09.png", 7}
    tb["5"] = {"xiao_cm_11.png", 7.5}
    tb["6"] = {"xiao_cm_13.png", 7.5}
    tb["7"] = {"xiao_cm_15.png", 7}
    tb["8"] = {"xiao_cm_17.png", 7}
    tb["9"] = {"xiao_cm_19.png", 7}
    tb["0"] = {"xiao_cm_21.png", 10}

    local i = 1
    local num_res = {}
    while true do
        local c = string.sub(num_str,i,i)
        local b = string.byte(c)
        
        if b > 128 then
            local cut = string.sub(num_str,i,i+2)
            local num_png = tb[cut]
            table.insert(num_res, num_png)
            i = i + 3
        else
            if b ~= 32 then
                local num_png = tb[c]
                table.insert(num_res, num_png)
            end
            i = i + 1
        end

        if i > #num_str then
            break
        end
    end

    return num_res
end

--弹框动画
function common_util.zoom(node)
    if not node then return end
    node:stopAllActions()

    node:setScale(0.1)
    
    node.ac = cc.EaseBackOut:create(cc.ScaleTo:create(0.1, 1))
    node:runAction(node.ac)
end

--aes加密yyb_
function common_util.encrypt(data, key)
    local key = {string.byte(key,1,#key)}
    local tb = common_util.tansByteString(data)
    local d = common_util.data_xor(tb, key)
    return crypto.encodeBase64(d)
end

function common_util.getByte(len, index)
    if (index == 0) then
        return bit.band(len,0xff);
    else
        return bit.band(bit.rshift(len, index*8),0xff);
    end
end

--增加前后混淆
function common_util.add_blur( data )
    local l = #data
    local rans = {}
    rans[1] = math.ceil(common_util.rand(1,50))
    rans[2] = math.ceil(common_util.rand(50,100))
    rans[3] = math.ceil(common_util.rand(100,150))
    rans[4] = math.ceil(common_util.rand(150,200))
    local blur_data = {}

    for k,v in pairs(rans) do
        table.insert(blur_data, v)
    end
    
    table.insert(blur_data, common_util.getByte(l,3))
    table.insert(blur_data, common_util.getByte(l,2))
    table.insert(blur_data, common_util.getByte(l,1))
    table.insert(blur_data, common_util.getByte(l,0))
 
    for k,v in pairs(data) do
        table.insert(blur_data, v)
    end

    local add_len = math.ceil(#blur_data/16)*16 - #blur_data
  
    local suffix = {}
    for i=1,add_len do
        local d = math.ceil(common_util.rand(0,255))
        table.insert(suffix, d)
    end

    for k,v in pairs(suffix) do
        table.insert(blur_data, v)
    end

    blur_data = common_util.divide_data(blur_data)
    return blur_data
end

--每16位做一次分隔
function common_util.divide_data( data )
    local num = #data/16
    local ds = {}
    for i=1,num do
        local d = {}
        for j=(i-1)*16+1,i*16 do
            table.insert(d,data[j])
        end
        table.insert(ds,d)
    end

    return ds
end

function common_util.tansByteString(data)
    local l = string.len(data)
    local s = {}
    for i=1,l do
        local char = string.byte(string.sub(data, i, i))
        table.insert(s,char)
    end
    
    return common_util.add_blur(s)
end


--自己生成key
function common_util.get_key(d)
    -- dump(d)
    local ks = {}
    local rand_data ={}
    local temp_data = d[1]
    for i=1,4 do
        for j=1,4 do
            table.insert(rand_data, temp_data[j])
        end
    end
    return rand_data
end

--通过key和随机key生成加密key
function common_util.make_key(k1, k2)
    local temp = {}
    for i=2,#k1 do
        table.insert(temp, k1[i])
    end
    temp[#k1] = k1[1]
    local final_key = {}
    for i=1,16 do
        table.insert(final_key, common_util.bxor(temp[i],k2[i]))
    end

    return final_key
end

function common_util.data_xor(tb, key)
    local en_datas = ""
    local f_d = tb[1] --第一段数据直接拿key异或
    for i=1,16 do
        en_datas = en_datas..string.char(common_util.bxor(f_d[i],key[i]))
    end

    local tem_k = key
    --用随机数生成key
    local rand_key = common_util.get_key(tb)
    for i=2,#tb do
        local en_key = common_util.make_key(tem_k, rand_key)
        tem_k = en_key
        local d = tb[i]
        for i=1,16 do
            en_datas = en_datas..string.char(common_util.bxor(d[i],en_key[i]))
        end
    end
   return en_datas
end

--------------------解密yyb_------------------
--解密yyb_
function common_util.decrypt(data, key)
    local key = {string.byte(key,1,#key)};
    local byte_tb = common_util.tansStringByte(data)
    local keys = {}
    table.insert(keys, key)

    local tb = byte_tb[1]
    local d = {}
    local trans_d = ""

    for i=1,16 do
        table.insert(d, common_util.bxor(tb[i],key[i]))
        trans_d = trans_d..string.char(common_util.bxor(tb[i],key[i]))
    end

    local rand_key = {}
    for i=1,4 do
        for j=1,4 do
            table.insert(rand_key, d[j])
        end
    end

    local tem_k = key
    for i=2,#byte_tb do
        local en_key = common_util.make_key(tem_k, rand_key)
        tem_k = en_key
        local d = byte_tb[i]
        for i=1,16 do
            trans_d = trans_d..string.char(common_util.bxor(d[i],en_key[i]))
        end
    end

    return common_util.remove_blur(trans_d)
end


function common_util.tansStringByte( data )
    local dec_data = crypto.decodeBase64(data)
    local len = string.len(dec_data)
    local ds = {}
    for i=1,len do
        s = string.byte(string.sub(dec_data, i, i))
        table.insert(ds, s)
    end

    local num = #ds/16

    local tan_ds = {}
    for i=1,num do
        local tan_d = {}
        for j=(i-1)*16+1, i*16 do
            table.insert(tan_d, ds[j])
        end
        table.insert(tan_ds, tan_d)
    end

    return tan_ds
end

function common_util.putByte(number, index)
    if (index == 0) then
        return bit.band(number,0xff);
    else
        return common_util.lshift(bit.band(number,0xff),index*8);
    end
end


--取消前后混淆
function common_util.remove_blur( s )
    local len1 = string.byte(string.sub(s, 5, 5))
    local len2 = string.byte(string.sub(s, 6, 6))
    local len3 = string.byte(string.sub(s, 7, 7))
    local len4 = string.byte(string.sub(s, 8, 8))
    local l = common_util.putByte(len1,3)+common_util.putByte(len2,2)+common_util.putByte(len3,1)+common_util.putByte(len4,0)
    dump(l,"长度")

    local reals = {}
    local sss = ""
    for i=9,l+8 do
        table.insert(reals,string.byte(string.sub(s, i, i)))
        sss = sss..string.sub(s, i, i)
    end

    return sss
end

function common_util.bxor(m, n)
    local rhs = bit._or(bit._not(m), bit._not(n))
    local lhs = bit._or(m, n)
    local rslt = bit._and(lhs, rhs)
    return rslt
end

function common_util.lshift(n, bits)
    if(n < 0) then
      n = bit._not(math.abs(n)) + 1
    end

    for i=1, bits do
        n = n*2
        end
    return bit._and(n, 4294967295) -- 0xFFFFFFFF
end