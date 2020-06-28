
--跑得快比赛的一些规则，人数等统一获取，方便修改
require "app.game.pdk.src.landcommon.data.StringConfig"
local StringConfig = require("app.game.pdk.src.landcommon.data.StringConfig")

local MatchConfig = {}

local YUSAI = 1
local CHUSAI = 2
local FUSAI = 3
local JUESAI = 4

local DALICHUJU = StringConfig.getValueByKey("match_dalichujuzhi")             --打立出局
local MOWEITAOTAI = StringConfig.getValueByKey("match_moweitaotaizhi")         --末位淘汰
local MEIZHUOTAOTAI = StringConfig.getValueByKey("match_meizhuotaotaizhi")     --每桌淘汰

---------------------
--[[
DALICHUJU      打立出局: 需要晋级多少人，截止多少人	(显示的	   XX人晋级,XX人截止)
MOWEITAOTAI    末尾淘汰: 需要每轮晋级多少人			(显示的是  XX人晋级)
MEIZHUOTAOTAI  每桌淘汰: 不需要数据					(显示的是  第一名晋级，第二名待定，第三名淘汰)

如果没有某个阶段，就一个空table
]]

-------------------------------------------
--闯关赛：直接决赛， 12人 3轮，     12->6,  6->3, 3->1
--闯关赛：直接决赛， 24人 4轮，     24->12, 12->6,  6->3, 3->1

--常量: 闯关赛是12人还是24人
local chuangguansaiCount = 12

local chuangguansai = {
	[YUSAI] = {},
	[CHUSAI] = {},
	[FUSAI] = {},
	[JUESAI] = {
		rule = MOWEITAOTAI,
		[1] = 6,
		[2] = 3,
		[3] = 1,
	},
}

local chuangguansai24 = {
	[YUSAI] = {},
	[CHUSAI] = {},
	[FUSAI] = {},
	[JUESAI] = {
		rule = MOWEITAOTAI,
		[1] = 12,
		[2] = 6,
		[3] = 3,
		[4] = 1,
	},
}

-------------------------------------------
--10元餐券
local canquan10 = {
	[YUSAI] = {},
	[CHUSAI] = {
		rule = DALICHUJU,
		jinji = 12,
		jiezhi = 24,
	},
	[FUSAI] = {},
	[JUESAI] = {
		rule = MEIZHUOTAOTAI,
	},
}

-------------------------------------------
--20元餐券
local canquan20 = {
	[YUSAI] = {},
	[CHUSAI] = {
		rule = MOWEITAOTAI,
		[1] = 24,
	},
	[FUSAI] = {},
	[JUESAI] = {
		rule = MEIZHUOTAOTAI,
	},
}

-------------------------------------------
--100元餐券
local canquan100 = {
	[YUSAI] = {},
	[CHUSAI] = {
		rule = DALICHUJU,
		jinji = 24,
		jiezhi = 48,
	},
	[FUSAI] = {},
	[JUESAI] = {
		rule = MEIZHUOTAOTAI,
	},
}

-------------------------------------------
--1元话费争夺赛
local huafei1yuan = {
	[YUSAI] = {},
	[CHUSAI] = {},
	[FUSAI] = {},
	[JUESAI] = {
		rule = MOWEITAOTAI,
		[1] = 12,
		[2] = 6,
		[3] = 3,
		[4] = 1,
	},
}

-------------------------------------------
--1元话费争夺赛
local huafei1yuan_36 = {
	[YUSAI] = {},
	[CHUSAI] = {},
	[FUSAI] = {},
	[JUESAI] = {
		rule = MOWEITAOTAI,
		[1] = 24,
		[2] = 12,
		[3] = 6,
		[4] = 3,
		[5] = 1,
	},
}

-------------------------------------------
--1元话费超快
local huafei1yuan_36_fast = {
	[YUSAI] = {},
	[CHUSAI] = {
	},
	[FUSAI] = {},
	[JUESAI] = {
		rule = MOWEITAOTAI,
		[1] = 24,
		[2] = 18,
		[3] = 12,
		[4] = 6,
		[5] = 3,
		[6] = 1,
	},
}
	
-------------------------------------------
--1元话费争夺赛(二人跑得快)
local huafei1yuan_tpland = {
	[YUSAI] = {},
	[CHUSAI] = {},
	[FUSAI] = {},
	[JUESAI] = {
		rule = MOWEITAOTAI,
		[1] = 12,
		[2] = 6,
		[3] = 4,
		[6] = 1,
	},
}


-------------------------------------------
--5元话费
local huafei5yuan = {
	[YUSAI] = {},
	[CHUSAI] = {
		rule = DALICHUJU,
		jinji = 24,
		jiezhi = 48,
	},
	[FUSAI] = {},
	[JUESAI] = {
		rule = MEIZHUOTAOTAI,
	},
}

-------------------------------------------
--50元话费
local huafei50yuan = {
	[YUSAI] = {},
	[CHUSAI] = {
		rule = DALICHUJU,
		jinji = 96,
		jiezhi = 128,
	},
	[FUSAI] = {
		rule = MOWEITAOTAI,
		[1] = 72,
		[2] = 54,
		[3] = 36,
		[4] = 24,
	},
	[JUESAI] = {
		rule = MEIZHUOTAOTAI,
	},
}

-------------------------------------------
--四平市全民跑得快擂台争霸赛-海选赛
local sipinHaixuan = {
	[YUSAI] = {},
	[CHUSAI] = {
		rule = DALICHUJU,
		jinji = 24,
		jiezhi = 48,
	},
	[FUSAI] = {},
	[JUESAI] = {
		rule = MEIZHUOTAOTAI,
	},
}

-------------------------------------------
--四平市全民跑得快擂台争霸赛-突围赛
local sipinTuwei = {
	[YUSAI] = {},
	[CHUSAI] = {
		rule = DALICHUJU,
		jinji = 12,
		jiezhi = 24,
	},
	[FUSAI] = {},
	[JUESAI] = {
		rule = MEIZHUOTAOTAI,
	},
}

-------------------------------------------
--四平市剧院
local sipinOpera = {
	[YUSAI] = {},
	[CHUSAI] = {
		rule = DALICHUJU,
		jinji = 12,
		jiezhi = 24,
	},
	[FUSAI] = {},
	[JUESAI] = {
		rule = MOWEITAOTAI,
	},
}

----------------------------------------------
--跑得快大奖门票争夺赛
local bigRewardTicket = {
	[YUSAI] = {},
	[CHUSAI] = {},
	[FUSAI] = {},
	[JUESAI] = {
		rule = MOWEITAOTAI,
		[1] = 12,
		[2] = 6,
		[3] = 3,
		[4] = 1,
	},
}

----------------------------------------------
--- 10000钻石争夺赛
local tenThousandDiamond = {
	[YUSAI] = {},
	[CHUSAI] = {},
	[FUSAI] = {},
	[JUESAI] = {
		rule = MOWEITAOTAI,
		[1] = 9,
		[2] = 6,
		[3] = 3,
		[4] = 1,
	},
}


----------------------
function MatchConfig.getMatchConfigByStage(gameType, stage)
	if gameType == 54 then
		return huafei1yuan_36[stage]
	elseif gameType == 102 then
		return huafei1yuan_36_fast[stage]
	elseif gameType == 59 or gameType == 64 then
		--1元话费
		return huafei1yuan[stage] 
	elseif gameType == 103 then  --1元话费(二人跑得快)
        return huafei1yuan_tpland[stage]
	elseif (gameType == 101) then -- 10000钻石争夺赛
		return tenThousandDiamond[stage] 
	elseif (gameType == 50) then
		--闯关赛第一关
		return chuangguansai24[stage]
	elseif (gameType >= 51 and gameType <= 65) or gameType == 100 then
		--闯关赛
		return chuangguansai[stage]
	elseif gameType == 79 then
		--10元餐券
		return canquan10[stage]
	elseif gameType == 16 then
		--20元餐券
		return canquan20[stage]
	elseif gameType == 15 then
		--100元餐券
		return canquan100[stage]
	elseif gameType == 5 or gameType == 6 or gameType == 78 then
		--5元
		return huafei5yuan[stage]
	elseif gameType == 8 or gameType == 9 or gameType == 13 then
		--50元
		return huafei50yuan[stage]
	elseif gameType == 19 then
		--海选
		return sipinHaixuan[stage]
	elseif gameType == 20 then
		--突围
		return sipinTuwei[stage]
	elseif gameType == 14 then
		--四平剧院
		return sipinOpera[stage]
	elseif gameType == 24 then
		--跑得快大奖门票赛
		return bigRewardTicket[stage]
	end
end

--获取闯关赛总人数
function MatchConfig.getChuangguansaiNum()
	return chuangguansaiCount
end

function MatchConfig.setChuangguansaiNum(count)
	chuangguansaiCount = count
end

return MatchConfig