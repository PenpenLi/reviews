-- LandGlobalDefine
-- Author: 
-- Date: 2018-08-07 18:17:10
local LandGlobalDefine = {}
--公共宏定义
LandGlobalDefine.INVALID_WORD  =            65535                   --无效数值
LandGlobalDefine.INVALID_TABLE =            LandGlobalDefine.INVALID_WORD            --无效桌子
LandGlobalDefine.INVALID_CHAIR =            LandGlobalDefine.INVALID_WORD            --无效椅子
LandGlobalDefine.CARDIMAGE_WIDTH =          1079
LandGlobalDefine.CARDIMAGE_HEIGHT=          500
LandGlobalDefine.CARDHSPACE =               38
LandGlobalDefine.GAME_PLAYER =              3                       --游戏人数
LandGlobalDefine.GAME_NAME =                "跑得快"                --游戏名字
LandGlobalDefine.GENDER_NULL =              0		                --未知性别
LandGlobalDefine.GENDER_BOY =               1					    --男性性别
LandGlobalDefine.GENDER_GIRL =              2					    --女性性别
LandGlobalDefine.GIRL_BEGIN =               100
LandGlobalDefine.SHOUT_SCORE =              10
--卡牌的牌型等定义，统一放在这里,排序类型
LandGlobalDefine.ST_ORDER =					0						--大小排序
LandGlobalDefine.ST_COUNT =					1						--数目排序
LandGlobalDefine.MAX_COUNT =			    20						--最大数目
LandGlobalDefine.FULL_COUNT =				54						--全牌数目
LandGlobalDefine.BACK_COUNT =				3						--底牌数目
LandGlobalDefine.NORMAL_COUNT =				17						--常规数目

--扑克类型
LandGlobalDefine.CT_ERROR=					0		                --错误类型
LandGlobalDefine.CT_SINGLE=					1		                --单牌类型
LandGlobalDefine.CT_DOUBLE=					2		                --对牌类型
LandGlobalDefine.CT_THREE=					3		          		--三条类型
LandGlobalDefine.CT_SINGLE_LINE	=			4						--单连类型
LandGlobalDefine.CT_DOUBLE_LINE=			5						--对连类型
LandGlobalDefine.CT_THREE_LINE=				6						--三连类型
LandGlobalDefine.CT_THREE_TAKE_ONE=		    7						--三带一单
LandGlobalDefine.CT_THREE_TAKE_TWO=		    8						--三带一对
LandGlobalDefine.CT_FOUR_LINE_TAKE_ONE=		9						--四带两单
LandGlobalDefine.CT_FOUR_LINE_TAKE_TWO=		10						--四带两对
LandGlobalDefine.CT_BOMB_CARD=				11						--炸弹类型
LandGlobalDefine.CT_MISSILE_CARD=		    12						--火箭类型
LandGlobalDefine.CT_FEIJI_TAKE_ONE=         13      				--飞机类型
LandGlobalDefine.CT_FEIJI_TAKE_TWO=         14      				--飞机类型
LandGlobalDefine.CT_LAIZI_BOMB =            15      				-- 纯赖子炸弹
LandGlobalDefine.CT_RUAN_BOMB =             16     					-- 软炸
LandGlobalDefine.CT_COUNT=					17	    				--!!牌型总数量
LandGlobalDefine.CT_THREE_TAKE_TT=		    8						--三带两张，可以是两单，也可以是一对
LandGlobalDefine.CT_FOUR_TAKE_THREE=   19						--四带三

--底牌扑克类型
LandGlobalDefine.BCT_ERROR	=				 0						--错误类型
LandGlobalDefine.BCT_SINGLE_KING=			 1						--单王
LandGlobalDefine.BCT_DOUBLE	=				 2						--对子
LandGlobalDefine.BCT_SINGLE_LINE=			 3						--顺子
LandGlobalDefine.BCT_SAME_COLOR	=			 4					    --同花
LandGlobalDefine.BCT_SINGLE_LINE_SAME_COLOR= 5						--同花顺
LandGlobalDefine.BCT_THREE=					 6						--三条 
LandGlobalDefine.BCT_DOUBLE_KING=			 7						--双王
LandGlobalDefine.BCT_COUNT	=				 8					    --牌底类型数量
LandGlobalDefine.LAND_LAIZICARD =            0

--玩家说话文字显示
LandGlobalDefine.SPEAK_CALLLAND =             101                     --叫地主
LandGlobalDefine.SPEAK_NOT_CALLLAND =         102                     --不叫
LandGlobalDefine.SPEAK_ROBLAND =              103                     --抢地主
LandGlobalDefine.SPEAK_NOT_ROBLAND =          104                     --不抢
LandGlobalDefine.SPEAK_DOUBLE  =              105                     --加倍
LandGlobalDefine.SPEAK_NOT_DOUBLE =           106                     --不加倍
LandGlobalDefine.SPEAK_LET_CARD =             107                     --让牌
LandGlobalDefine.SPEAK_NOT_LET_CARD =         108                     --不让
LandGlobalDefine.SPEAK_BRIGHT_CARD =          109                     --明牌
LandGlobalDefine.SPEAK_SCORE_ONE =            110                     --1分
LandGlobalDefine.SPEAK_SCORE_TWO =            111                     --2分
LandGlobalDefine.SPEAK_SCORE_THREE =          112                     --3分
LandGlobalDefine.SPEAK_CARD_PASS =            113                     --不出

--玩家操作按钮
LandGlobalDefine.OPERATION_CALLLAND =         201                     --叫地主
LandGlobalDefine.OPERATION_NOT_CALLLAND =     202                     --不叫
LandGlobalDefine.OPERATION_ROBLAND =          203                     --抢地主
LandGlobalDefine.OPERATION_NOT_ROBLAND =      204                     --不抢
LandGlobalDefine.OPERATION_DOUBLE  =          205                     --加倍
LandGlobalDefine.OPERATION_NOT_DOUBLE=        206                     --不加倍
LandGlobalDefine.OPERATION_LET_CARD =         207                     --让牌
LandGlobalDefine.OPERATION_NOT_LET_CARD =     208                     --不让
LandGlobalDefine.OPERATION_BRIGHT_CARD =      209                     --明牌
LandGlobalDefine.OPERATION_SCORE_ONE =        210                     --1分
LandGlobalDefine.OPERATION_SCORE_TWO =        211                     --2分
LandGlobalDefine.OPERATION_SCORE_THREE =      212                     --3分
LandGlobalDefine.OPERATION_CARD_PASS =        213                     --不出
LandGlobalDefine.OPERATION_CARD_PROMET =      214                     --提示
LandGlobalDefine.OPERATION_CARD_OUTCARD =     215                     --出牌

--功能设置按钮
LandGlobalDefine.SYSTEMSET_CHAT =             301                     --聊天
LandGlobalDefine.SYSTEMSET_SET  =             302                     --设置
LandGlobalDefine.SYSTEMSET_RULE  =            303                     --规则
LandGlobalDefine.SYSTEMSET_LAST_HAND  =       304                     --上手牌
LandGlobalDefine.SYSTEMSET_MUSIC  =           305                     --音效
LandGlobalDefine.SYSTEMSET_EXIT  =            306                     --退出

LandGlobalDefine.CALL_LAND =                  401                     --叫地主/不叫
LandGlobalDefine.ROB_LAND =                   402                     --抢地主/不抢

--让牌相关文字提示
LandGlobalDefine.BTN_FIRST_CHEAK =            501                     --如果让先，对方先出并额外让3张牌，本局输赢
LandGlobalDefine.BTN_BY_CHEAK =               502                     --您被让4张，再出13张可获胜
LandGlobalDefine.BTN_ACTIVE_CHEAK =           503                     --您让4张，对手再出13张可获胜

--跑得快类型(客户端区分是那种跑得快和服务器无关)
LandGlobalDefine.CLASSIC_LAND_TYPE =          101                  --经典跑得快
LandGlobalDefine.HAPPLY_LAND_TYPE =           102                  --欢乐跑得快
LandGlobalDefine.LAIZI_LAND_TYPE =            103                  --癞子跑得快
LandGlobalDefine.TP_LAND_TYPE =               104                  --二人跑得快
LandGlobalDefine.CLASSIC_LAND_FRIEND_TYPE =   605                  --经典跑得快牌友房

--房间类型
LandGlobalDefine.ROOM_TYPE_FREE =             1                    --1.自由桌
LandGlobalDefine.ROOM_TYPE_MATCHFULL =        2                    --2.比赛房：满人开赛
LandGlobalDefine.ROOM_TYPE_MATCHTOIMER =      3                    --3.比赛房：定时开赛
LandGlobalDefine.ROOM_TYPE_SYSTEM =           4                   -- 4.系统匹配房


--游戏服状态
LandGlobalDefine.GAME_READY            = 1  -- 等待状态   
LandGlobalDefine.GAME_LANDSCORE        = 2  -- 叫分状态
LandGlobalDefine.GAME_OUTCARD          = 3  -- 出牌状态
LandGlobalDefine.GAME_END              = 4  -- 游戏结束
LandGlobalDefine.GAME_JIABEI           = 5  -- 加倍状态
LandGlobalDefine.GAME_CARRY_ON         = 6  -- 继续状态
LandGlobalDefine.GAME_OPEN_POKER       = 7  -- 明牌状态
LandGlobalDefine.GAME_LAND_OPEN_POKER  = 8  -- 地主明牌状态


LandGlobalDefine.PAIJU_SERVER    = "http://paiju.milaichess.com/ddz" 

LandGlobalDefine.DELAY_SUB_GAMEEND  = 1.5 --延迟N秒处理结算消息
LandGlobalDefine.DELAY_SHOW_SCORE   = 1 --延迟N秒展示输赢滚动
LandGlobalDefine.DELAY_SHOW_ACCOUNT = 2 --延迟N秒展示金币房结算界面


LandGlobalDefine.DIALOG_COMFIRM        = 1 
LandGlobalDefine.DIALOG_COMFIRM_CANCEL = 2

LandGlobalDefine.FRIEND_ROOM_PORTAL_ID = 110500
LandGlobalDefine.FRIEND_ROOM_GAME_ID = 101008
LandGlobalDefine.YI_YUAN_CLASSIC_ROOM_ID = 101021
LandGlobalDefine.YI_YUAN_HAPPY_ROOM_ID = 102021


LandGlobalDefine.FRIEND_REPLAY_ID    = 10100800

LandGlobalDefine.SHARE_FUNCTION_OPEN = true

LandGlobalDefine.SINGLE_PAGEAGE = true

return LandGlobalDefine
		