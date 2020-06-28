--[[

--]]
local N_MAX_HANDCOUNT = 14
local N_MAX_WEAVECOUNT = (N_MAX_HANDCOUNT-2)/3

local func_removetype = function( par_t_handcard, par_t_removecardtype )
    local t_temphandcard = {}
    for k,v in pairs(par_t_handcard) do
        local b_found = false
        for kk,vv in pairs(par_t_removecardtype) do
            if v == vv then
                b_found = true
                break
            end
        end
        if not b_found then
            table.insert(t_temphandcard, vv)
        end
    end
    local n_tempmagiccount = table.maxn(par_t_handcard) - #t_temphandcard
    --
    return t_temphandcard, n_tempmagiccount
end

local func_transfer = function(par_s_key)
    if not par_s_key then return 0 end
    local n_return = 0
    local n_temp = string.len(par_s_key)
    for i=1,n_temp do
        local s_cell = string.sub(par_s_key, i, i)
        local n_cell = tonumber(s_cell) + 1
        local t_wei = {1, 2, 3, 4, 5,}
        local t_value = {0, 0x02, 0x06, 0x0e, 0x1e}
        -- print("n_returna", n_cell, t_wei[n_cell], t_value[n_cell])
        n_return = bit.lshift(n_return, t_wei[n_cell] )
        n_return = bit.bor(n_return, t_value[n_cell] )
        -- print("n_returnb", string.format("0x%0x", n_return))
    end
    return n_return
end

local func_IfFound = function(t_temphand, table_normal)
    if 0 == t_temphand then
        return true
    end
    --
    local t_tempindex = {}
    for k,v in pairs(t_temphand) do
        if not t_tempindex[v] then t_tempindex[v] = 0 end
        t_tempindex[v] = t_tempindex[v] + 1
    end
    for k,v in pairs(t_tempindex) do
        print(k,v)
    end
    local s_tempkey = nil
    local b_kong = false
    for i=1,table.maxn(t_tempindex) do
        if t_tempindex[i] then
            if not s_tempkey then s_tempkey = "" end
            if b_kong then 
                b_kong = false
                s_tempkey = s_tempkey .. "0"
            end
            s_tempkey = string.format("%s%d", s_tempkey, t_tempindex[i])
        else
            if s_tempkey then b_kong = true end
        end
    end
    -- 
    local n_return = func_transfer(s_tempkey)
    print("func_IfFound", s_tempkey, n_return)
    local b_found = table_normal[n_return]
    return b_found
end

---[[
local func_addAWeaveTo = function(s_addweave, t_beforeweave, t_temptemp, par_b_allowadd)
    par_b_allowadd = true
    local s_addzero = "0"
    if s_addweave == s_addzero then return end
    if #t_beforeweave == 0 then t_temptemp[s_addweave] = 1 return end
    -- 
    local n_addweave = string.len(s_addweave)
    local s_first = string.sub(s_addweave, 1, 1)
    local s_last = string.sub(s_addweave, n_addweave, n_addweave)
    for k,v in pairs(t_beforeweave) do
        -- 将组合(刻子或者顺子)的第一位，放在相对原来组合第一位的不同位置
        -- -n_addweave-1 ... -1 0 1 ... n_temp-1 n_temp n_temp+1
        local n_temp = string.len(v)
        for i=-n_addweave-1,n_temp+1 do
            local s_temp = v
            local s_tempadd = ""
            if i == -n_addweave-1 then
                if s_first ~= s_addzero then
                    s_tempadd = s_addweave .. s_addzero .. s_temp
                    t_temptemp[s_tempadd] = 1
                end
            elseif i == n_temp+1 then
                if s_last ~= s_addzero then
                    s_tempadd = s_temp .. s_addzero .. s_addweave
                    t_temptemp[s_tempadd] = 1
                end
            else
                local s_current = string.sub(s_temp, i+1, i+1)
                if (s_current == s_addzero) and par_b_allowadd then
                    local s_allow_before = string.sub(s_temp, 1, i)
                    local s_allow_after = string.sub(s_temp, i+2, n_temp)
                    local s_allowaddzero = string.format("%s%s%s%s%s", s_allow_before, s_addzero, s_addweave, s_addzero, s_allow_after)
                    if string.len(s_allowaddzero) <= N_MAX_HANDCOUNT then
                        t_temptemp[s_allowaddzero] = 1
                    end
                    s_allowaddzero = string.format("%s%s%s%s%s", s_allow_before, s_addzero, s_addweave, "", s_allow_after)
                    if string.len(s_allowaddzero) <= N_MAX_HANDCOUNT then
                        t_temptemp[s_allowaddzero] = 1
                    end
                    s_allowaddzero = string.format("%s%s%s%s%s", s_allow_before, "", s_addweave, s_addzero, s_allow_after)
                    if string.len(s_allowaddzero) <= N_MAX_HANDCOUNT then
                        t_temptemp[s_allowaddzero] = 1
                    end
                    s_allowaddzero = string.format("%s%s%s%s%s", s_allow_before, "", s_addweave, "", s_allow_after)
                    if string.len(s_allowaddzero) <= N_MAX_HANDCOUNT then
                        t_temptemp[s_allowaddzero] = 1
                    end
                end
                -- 
                local s_before = ""
                local s_after = ""
                if i > 0 then
                    s_before = string.sub(s_temp, 1, i)
                end
                if i + n_addweave-1 < n_temp-1 then
                    s_after = string.sub(s_temp, i + n_addweave+1, n_temp)
                end
                -- print("s_befores_before", i, s_before, s_after, s_temp)
                local b_found = true
                for j=1,n_addweave do
                    local n_idx = i + j - 1
                    local s_addidx = string.sub(s_addweave, j, j)
                    local n_addsum = tonumber(s_addidx)
                    -- print("n_addweave", j, i, n_idx, s_addidx)
                    if n_idx >= 0 and n_idx < n_temp then
                        local s_yuanidx = string.sub(s_temp, n_idx + 1, n_idx + 1)
                        local n_yuannum = tonumber(s_yuanidx)
                        -- print("s_yuanidx", s_yuanidx, n_yuannum)
                        if s_yuanidx and n_yuannum then
                            n_addsum = n_addsum + n_yuannum
                            if n_addsum > 4 then
                                b_found = false
                                break
                            end
                            s_addidx = tostring(n_addsum)
                        end
                        s_tempadd = s_tempadd .. s_addidx
                    else
                        s_tempadd = s_tempadd .. s_addidx
                    end
                end
                s_tempadd = s_before .. s_tempadd .. s_after
                if b_found and string.len(s_tempadd) <= N_MAX_HANDCOUNT then
                    -- print("s_tempadd", s_tempadd)
                    t_temptemp[s_tempadd] = 1
                end
            end
        end
    end
    return t_temptemp
end
local func_SUMLOOP = function (par_n_magiccount)
    local tab_key = {}
    local xxsjid = nil
    xxsjid = function (n_magicsan, par_t_temp)
        for j=1,n_magicsan do
            local t_temptable = {}
            for k,v in pairs(par_t_temp) do
                table.insert(t_temptable, v)
            end
            table.insert(t_temptable, j)
            local n_remaincount = n_magicsan - j
            if n_remaincount > 0 then
                xxsjid(n_remaincount, t_temptable)
            else
                table.insert(tab_key, t_temptable)
            end
        end
    end
    for n_magicdui=0,2 do
        local n_magicsan = par_n_magiccount - n_magicdui
        local t_temptable = { n_magicdui }
        if n_magicsan > 0 then
            xxsjid(n_magicsan, t_temptable)
        elseif n_magicsan == 0 then
            table.insert(tab_key, t_temptable)
        end
    end
    -- dump(tab_key, "tab_key")
    local t_typedui = { {"2"}, {"1"}, {"0"}, }
    local t_typesan = { {"3", "111"}, {"2", "11", "101",}, {"1"}, {"0"}, }
    local n_loopcount = N_MAX_WEAVECOUNT + 1
    local par_tts_ = {}
    for k,v in pairs(tab_key) do
        local t_temp = {}
        for i=1,n_loopcount do
            local n_tempkey = v[i]
            if not n_tempkey then n_tempkey = 0 end
            n_tempkey = n_tempkey + 1
            if i == 1 then
                if not t_typedui[n_tempkey] then break end
                table.insert(t_temp, t_typedui[n_tempkey])
            else
                if not t_typesan[n_tempkey] then break end
                table.insert(t_temp, t_typesan[n_tempkey])
            end
        end
        table.insert(par_tts_, t_temp)
    end
    -- dump(par_tts_, "par_tts_")
    return par_tts_
end
local func_SUMWEAVE = function (tab_all, par_tts_)
    local n_loopcount = #par_tts_
    local tab_weave = {}
    for i=1,n_loopcount do
        -- init
        tab_weave[i] = {}
        local t_tempweave = tab_weave[i]
        if i == 1 then
            -- table.insert(tab_all, "0")
            for k,v in pairs(par_tts_[i]) do
                if v ~= "0" then
                    table.insert(t_tempweave, v)
                end
            end
        else
            -- find before, loop, add weave to current
            local t_beforeweave = tab_weave[i - 1]
            local t_temptemp = {}
            for k,v in pairs(par_tts_[i]) do
                if v ~= "0" then
                    func_addAWeaveTo(v, t_beforeweave, t_temptemp)
                end
            end
            for k,v in pairs(t_temptemp) do
                table.insert(t_tempweave, k)
            end
        end
        -- addto
        for k,v in pairs(t_tempweave) do
            local n_v = func_transfer(v)
            tab_all[n_v] = 1
            -- table.insert(tab_all, v)
        end
    end
    -- dump(tab_all, "tab_all")
    return tab_all
end

local func_SAVEFILE = function (tab_all, par_s_path)
    -- 写入
    local function write_content( fileName, content )
        -- r表示读写权限（read），如果想追加内容 a(append) 想写入内容 w(write) 想打开二进制文件 b(binary)
        local f = assert( io.open( fileName, 'w')) --根据需要读写的文家目录去写入文件
        f:write( content ) 
        f:close() --关闭输入流
    end
    -- write_content("/Users/aaron/Desktop/table_hu0.lua", s_temp)
    -- 输出
    local function read_files( fileName )
        local f = assert( io.open(fileName, 'r'))
        --[[
        读取所有文件内容 *all
        读取一行 *line
        读取一个数字 *number
        读取一个不超过num个数的字符串 <num>
        ]] 
        -- local content = f:read("*all"))
        local content = f:read(5)
        f:close() --紧跟关闭
        return content
    end
    -- local result = read_files("a.lua")
    -- print(result)
    -- 
    local s_temp = ""
    for k,v in pairs(tab_all) do
        s_temp = string.format("%s[\"%s\"]=%d,", s_temp, k, v)
    end
    s_temp = string.format("local tab_all = \n{%s}\n return tab_all", s_temp)
    write_content(par_s_path, s_temp)
end

local func_PUBLISH = function (par_n_magiccount)
    par_n_magiccount = par_n_magiccount or 0
    local s_pathname = string.format("/Users/aaron/Desktop/table_hu%d.lua", par_n_magiccount)
    local tab_all = {}
    local par_ttts_ = func_SUMLOOP(par_n_magiccount)
    for k,v in pairs(par_ttts_) do
        func_SUMWEAVE(tab_all, v)
    end
    func_SAVEFILE(tab_all, s_pathname)
    -- dump(tab_all, "tab_all")
end
--]]

local HuLogic_LookupTable = class("HuLogic_LookupTable")

function HuLogic_LookupTable:setParams( ... )
    local t_argv = { ... }
    N_MAX_HANDCOUNT = t_argv[1]
    N_MAX_WEAVECOUNT = (N_MAX_HANDCOUNT-2)/3
end

function HuLogic_LookupTable:checkHu( par_t_hand, par_t_magic )
    -- func_PUBLISH()
    -- par_t_hand = {0x01,0x02,0x03, 0x05,0x05, 0x11,0x11,0x11, 0x21,0x21,0x21, 0x31,0x31,0x31, }
    -- par_t_magic = {0x01}
    local t_temphandcard, n_tempmagiccount = func_removetype(par_t_hand, par_t_magic)
    local table_normal = nil
    local b_checkhu = func_IfFound(t_temphandcard, table_normal)
    print("checkHu", checkHu)
    return b_checkhu
end

return HuLogic_LookupTable

    