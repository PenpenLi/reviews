
local chuangguansaiNum = require("app.game.pdk.src.landcommon.view.match.MatchConfig").getChuangguansaiNum()

local MatchRuleConfig = {}

MatchRuleConfig.config = {
		--闯关赛
		chuangguansai = {rule =
	chuangguansaiNum == 12 and
	"赛制流程：\
	共3轮2局，分别依次淘汰6人，3人，剩余3人按积分排名分出冠，亚，季军。" or
	chuangguansaiNum == 24 and
	"赛制流程：\
	共4轮2局，分别依次淘汰12人，6人，3人，剩余3人按积分排名分出冠，亚，季军。" or "",
	},

		chuangguansai24 = {rule = "赛制流程：\
	共4轮2局，分别依次淘汰12人，6人，3人，剩余3人按积分排名分出冠，亚，季军。"
	},
	
		--1元话费	24人
		huafei_1yuan = {rule = "赛制流程：\
	共4轮2局，分别依次淘汰12人，6人，3人，剩余3人按积分排名分出冠，亚，季军。"
	},

		--1元话费	36人
		huafei_1yuan_36 = {rule = "赛制流程：\
	共5轮2局，分别依次淘汰12人，12人，6人，3人，剩余3人按积分排名分出冠，亚，季军。"
	},

		--1元话费	36人超快
		huafei_1yuan_36_fast = {rule = "赛制流程：\
		初赛：末位淘汰制5轮1局，分别依次淘汰9人，6人，6人，6人，3人。\
		决赛：1轮2局，剩余3人按积分排名分出冠，亚，季军。如出现同分，报名比赛时间先者晋级。",
	},
	    --1元话费	24人
		huafei_1yuan_tpland = {rule = "赛制流程：\
		共4轮1局，分别依次淘汰12人，6人，4人，\
		剩余2人按积分排名分出冠，亚军。如出现同分，报名比赛时间先者晋级。",
	},

		--5元话费   180人
		huafei_5yuan = {rule = "赛制流程：\
	初赛：打立出局制：初始积分12000，低于一定积分时淘汰出局，剩余48人时截止比赛，24人晋级决赛。\
	决赛：4轮2局，每桌淘汰制：每1轮2局牌结束后，每桌排名第1的玩家晋级。第3名淘汰。第2名和其它桌第2名按积分排名，积分靠前者晋级。如出现同分，报名比赛时间先者晋级。",
	},

		huafei_5yuan_laizi = {rule = "赛制流程：\
	初赛：打立出局制：初始积分24000，低于一定积分时淘汰出局，剩余48人时截止比赛，24人晋级决赛。\
	决赛：4轮2局，每桌淘汰制：每1轮2局牌结束后，每桌排名第1的玩家晋级。第3名淘汰。第2名和其它桌第2名按积分排名，积分靠前者晋级。如出现同分，报名比赛时间先者晋级。",
	},

		--50元话费争夺赛赛制  180人
		huafei_50yuan = {rule = "赛制流程：\
	初赛：打立出局制：初始积分12000，低于一定积分时淘汰出局，剩余126人时截止比赛 ，96人晋级复赛。\
	复赛：4轮2局，末位淘汰制：每1轮2局牌结束后，按积分排名，依次淘汰24，18，18，12人。24人晋级决赛。\
	决赛：4轮2局，每桌淘汰制：每1轮2局牌结束后，每桌排名第1的玩家晋级。第3名淘汰。第2名和其它桌第2名按积分排名，积分靠前者晋级。如出现同分，报名比赛时间先者晋级。",
	},

		--跑得快10元餐劵比赛
		canquan_10yuan = {rule = "赛制流程：\
	初赛：打立出局制：初始积分12000，低于一定积分时淘汰出局，剩余24人时截止比赛 ，12人晋级决赛。\
	决赛：3轮2局，每桌淘汰制：每1轮2局牌结束后，每桌排名第1的玩家晋级。第3名淘汰。第2名和其它桌第2名按积分排名，积分靠前者晋级。如出现同分，报名比赛时间先者晋级。",
	},
	
		--跑得快20元餐劵比赛
		canquan_20yuan = {rule = "赛制流程：\
	初赛：末位淘汰制，共1轮2局，淘汰24人，剩余24人晋级决赛。如出现同分，报名比赛时间先者晋级。\
	决赛：4轮2局，每桌淘汰制：每1轮2局牌结束后，每桌排名第1的玩家晋级。第3名淘汰。第2名和其它桌第2名按积分排名，积分靠前者晋级。如出现同分，报名比赛时间先者晋级。\
	",
	},

		--跑得快100元餐劵比赛
		canquan_100yuan = {rule = "赛制流程：\
	初赛：打立出局制：初始积分12000，低于一定积分时淘汰出局，剩余48人时截止比赛 ，24人晋级决赛。\
	决赛：4轮2局，每桌淘汰制：每1轮2局牌结束后，每桌排名第1的玩家晋级。第3名淘汰。第2名和其它桌第2名按积分排名，积分靠前者晋级。如出现同分，报名比赛时间先者晋级。",
	},
	
		--四平市全民跑得快擂台争霸赛-海选赛
		sipin_haixuan = {rule = "赛制流程：\
	初赛：打立出局制：初始积分12000，低于一定积分时淘汰出局，剩余48人时截止比赛，24人晋级决赛。\
	决赛：4轮2局，每桌淘汰制：每1轮2局牌结束后，每桌排名第1的玩家晋级。第3名淘汰。第2名和其它桌第2名按积分排名，积分靠前者晋级。如出现同分，报名比赛时间先者晋级。"
	},
		
		--四平市全民跑得快擂台争霸赛-突围赛
		sipin_tuwei = {rule = "赛制流程：\
	初赛：打立出局制：初始积分12000，低于一定积分时淘汰出局，剩余24人时截止比赛 ，12人晋级决赛。\
	决赛：3轮2局，每桌淘汰制：每1轮2局牌结束后，每桌排名第1的玩家晋级。第3名淘汰。第2名和其它桌第2名按积分排名，积分靠前者晋级。如出现同分，报名比赛时间先者晋级。"
	},

		--四平人民剧院比赛
		sipin_people_operra = {rule = "赛制流程：\
	初赛：打立出局制：初始积分12000，低于一定积分时淘汰出局，剩余24人时截止比赛，12人晋级决赛。\
	决赛：末位淘汰制：共3轮2局，分别依次淘汰6人，3人，剩余3人按积分排名分出冠，亚，季军。如出现同分，报名比赛时间先者晋级。"
	},

		--跑得快大奖门票赛
		big_reward_ticket = {rule = "末位淘汰制：\
	共4轮2局，分别依次淘汰12人，6人，3人，剩余3人按积分排名分出冠，亚，季军。如出现同分，报名比赛时间先者晋级。"
	},
		--10000钻石争夺赛
		ten_thousand_diamond = {rule = "末位淘汰制：\
	共4轮1局，分别依次淘汰9人，3人，3人，剩余3人按积分排名分出冠，亚，季军。如出现同分，报名比赛时间先者晋级。"
	},
}

MatchRuleConfig.getRewardByGameType = function(gameType)
	--local roomInfo = RoomListLogic.getRoomListDetailByGameType(gameType)
	--if roomInfo then
		--return roomInfo.GameReward
	--end
	return ""
end

MatchRuleConfig.getRuleByGameType = function(gameType)
	local reward = MatchRuleConfig.getRewardByGameType(gameType)
	if gameType == 54 then
		return MatchRuleConfig.config.huafei_1yuan_36.rule, reward
	elseif gameType == 102 then
		return MatchRuleConfig.config.huafei_1yuan_36_fast.rule, reward
	elseif gameType == 103 then
		--1元话费(二人跑得快)
		return MatchRuleConfig.config.huafei_1yuan_tpland, reward
	elseif gameType == 59 or gameType == 64 then
		--1元话费
		return MatchRuleConfig.config.huafei_1yuan.rule, reward
	elseif (gameType == 50) then
		-- 闯关赛第一关
		return MatchRuleConfig.config.chuangguansai24.rule, reward
	elseif (gameType >= 51 and gameType <= 65) or gameType == 100 then
		-- 闯关赛
		local checkpoint = gameType % 5 + 1
		return MatchRuleConfig.config.chuangguansai.rule, reward
	elseif gameType == 5 or gameType == 6 then
		-- 180人 5元
		return MatchRuleConfig.config.huafei_5yuan.rule, reward
	elseif gameType == 78 then
		return MatchRuleConfig.config.huafei_5yuan_laizi.rule, reward
	elseif gameType == 8 or gameType == 9 or gameType == 13 then
		--180人 50元
		return MatchRuleConfig.config.huafei_50yuan.rule, reward
	elseif gameType == 15 then
		--100元饭店
		return MatchRuleConfig.config.canquan_100yuan.rule, reward
	elseif gameType == 79 then
		--10元饭店
		return MatchRuleConfig.config.canquan_10yuan.rule, reward
	elseif gameType == 16 then
		--20元餐券
		return MatchRuleConfig.config.canquan_20yuan.rule, reward
	elseif gameType == 19 then
		--四平海选
		return MatchRuleConfig.config.sipin_haixuan.rule, reward
	elseif gameType == 20 then
		--四平突围
		return MatchRuleConfig.config.sipin_tuwei.rule, reward
	elseif gameType == 14 then
		--四平人民剧院
		return MatchRuleConfig.config.sipin_people_operra.rule, reward
	elseif gameType == 24 then
		--跑得快大奖门票赛
		return MatchRuleConfig.config.big_reward_ticket.rule, reward
	elseif gameType == 101 then
		return MatchRuleConfig.config.ten_thousand_diamond.rule, reward
	else
		return "", ""
	end
end

return MatchRuleConfig