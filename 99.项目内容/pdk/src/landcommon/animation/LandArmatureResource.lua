-- landArmatureResource
-- Author: 
-- Date: 2018-08-07 18:17:10
-- 跑得快骨骼动画管资源

local LandArmatureResource = class("LandArmatureResource")

function LandArmatureResource:ctor()
end  

function LandArmatureResource:getArmatureResourceById( resourceById )
    return LandArmatureResource.armatureResourceInfo[ resourceById ]
end

LandArmatureResource.armatureResourceInfo = {}

LandArmatureResource.ANI_AIR_PLANE 		 	= 1001                                  -- 飞机
LandArmatureResource.ANI_HUOJIANBAOZA    	= 1002                                  -- 火箭爆炸
LandArmatureResource.ANI_ZADAN		    	= 1003                                  -- 炸弹
LandArmatureResource.ANI_SHUNZHI		    = 1004                                  -- 顺子
LandArmatureResource.ANI_LIANDUI		    = 1005                                  -- 连对

LandArmatureResource.armatureResourceInfo[LandArmatureResource.ANI_AIR_PLANE] = 
{ resourceById = LandArmatureResource.ANI_AIR_PLANE, configFilePath = "airplane/airplane.ExportJson", armatureName = "airplane", animationName = "Animation2" ,
 time = 2.5 , po1 = cc.p(display.width/2,display.height/2), po2 = cc.p(display.width+600,115), isLoop = false, isCache = false, scale = 1}

LandArmatureResource.armatureResourceInfo[LandArmatureResource.ANI_HUOJIANBAOZA] =
{ resourceById = LandArmatureResource.ANI_HUOJIANBAOZA, configFilePath = "huojianbaozha/huojianbaozha.ExportJson", armatureName = "huojianbaozha", animationName = "Animation2" ,
 time = 3 , po1 = cc.p(display.cx,display.cy), po2 = cc.p(display.width+100,300), isLoop = false, isCache = false, scale = 1.1}

LandArmatureResource.armatureResourceInfo[LandArmatureResource.ANI_ZADAN] =
{ resourceById = LandArmatureResource.ANI_ZADAN, configFilePath = "zhadan/zhadan.ExportJson", armatureName = "zhadan", animationName = "zhadan",
 time = 3 , po1 = cc.p(640,360), po2 = cc.p(display.width+100,300), isLoop = false, isCache = false, scale = 0.9}

LandArmatureResource.armatureResourceInfo[LandArmatureResource.ANI_SHUNZHI] =
{ resourceById = LandArmatureResource.ANI_SHUNZHI, configFilePath = "shunzi/shunzi.ExportJson", armatureName = "shunzi", animationName = "Animation2" ,
time = 3 , po1 = cc.p(640,360), po2 = cc.p(display.width, 300), isLoop = false, isCache = false, scale = 0.8}

LandArmatureResource.armatureResourceInfo[LandArmatureResource.ANI_LIANDUI] =
{ resourceById = LandArmatureResource.ANI_LIANDUI, configFilePath = "lord_ani_liandui/lord_ani_liandui.ExportJson", armatureName = "lord_ani_liandui", animationName = "Animation1" ,
time = 3 , po1 = cc.p(640,360), po2 = cc.p(display.width+100,300), isLoop = false, isCache = false, scale = 1.1}



LandArmatureResource.ANI_SPRING 			= 1006                                  -- 春天动画

LandArmatureResource.ANI_WIN_LIGHT 			= 1007                                  -- 胜利闪光,转圈圈
LandArmatureResource.ANI_WIN_STAR 			= 1008                                  -- 胜利星星
LandArmatureResource.ANI_LOSE_RANNING 		= 1009                                  -- 失败动画 下雨
LandArmatureResource.ANI_LOSE_STAR 			= 1010                                  -- 失败动画 星星

LandArmatureResource.ANI_REDLIGHT		    = 1011                                  -- 红灯
LandArmatureResource.ANI_WAITTEXT		    = 1012                                  -- 等待房主开局
LandArmatureResource.ANI_SOUND			    = 1013                                  -- 语音说话
LandArmatureResource.ANI_DIZHUSHAOBA		= 1014                                  -- 地主骑扫把
LandArmatureResource.ANI_JIANGZHUANG		= 1015                                  -- 奖状盖印
LandArmatureResource.ANI_TAOTAI				= 1016                                  -- 淘汰
LandArmatureResource.ANI_SUNSHINE			= 1017                                  -- 阳光

LandArmatureResource.ANI_ZHADAN             = 1018                                  -- 炸弹


LandArmatureResource.armatureResourceInfo[LandArmatureResource.ANI_ZHADAN] =
{ resourceById = LandArmatureResource.ANI_ZHADAN, configFilePath = "app/game/pdk/res/animation/zhadan/zhadan.ExportJson", armatureName = "zhadan", animationName = "zhadan" ,
time = 3 , po1 = cc.p(display.cx,display.cy), po2 = cc.p(display.width+100,300), isLoop = false, isCache = false, scale = 1}


LandArmatureResource.armatureResourceInfo[LandArmatureResource.ANI_REDLIGHT] =
{ resourceById = LandArmatureResource.ANI_REDLIGHT, configFilePath = "ani_alarm/ani_alarm.ExportJson", armatureName = "ani_alarm", animationName = "ani_alarm" ,
time = 3 , po1 = cc.p(0,30), po2 = cc.p(display.width+100,300), isLoop = true, isCache = false, scale = 1}

LandArmatureResource.armatureResourceInfo[LandArmatureResource.ANI_SPRING] =
{ resourceById = LandArmatureResource.ANI_SPRING, configFilePath = "chuntian/chuntian.ExportJson", armatureName = "chuntian", animationName = "Animation1" ,
 time = 3 , po1 = cc.p(display.cx,display.cy), po2 = cc.p(display.width+100,300), isLoop = false, isCache = false, scale = 1.5}

LandArmatureResource.armatureResourceInfo[LandArmatureResource.ANI_WIN_LIGHT] = 
{ resourceById = LandArmatureResource.ANI_WIN_LIGHT, configFilePath = "shengliguang/shengliguang.ExportJson", armatureName = "shengliguang", animationName = "sanguang",
time = 3 , po1 = cc.p(0,0), po2 = cc.p(display.width+100,300), isLoop = true, isCache = false, scale = 1}

LandArmatureResource.armatureResourceInfo[LandArmatureResource.ANI_WIN_STAR] = 
{ resourceById = LandArmatureResource.ANI_WIN_STAR, configFilePath = "jiesuanshengli/jiesuanshengli.ExportJson", armatureName = "jiesuanshengli", animationName = "shengli",
time = 3 , po1 = cc.p(0,0), po2 = cc.p(display.width+100,300), isLoop = true, isCache = false, scale = 1}

LandArmatureResource.armatureResourceInfo[LandArmatureResource.ANI_LOSE_RANNING] = 
{ resourceById = LandArmatureResource.ANI_LOSE_RANNING, configFilePath = "Fail_rainning/Fail_rainning.ExportJson", armatureName = "Fail_rainning", animationName = "Animation2",
time = 3 , po1 = cc.p(0,-100), po2 = cc.p(display.width+100,300), isLoop = true, isCache = false, scale = 1}

LandArmatureResource.armatureResourceInfo[LandArmatureResource.ANI_LOSE_STAR] = 
{ resourceById = LandArmatureResource.ANI_LOSE_STAR, configFilePath = "Fail_star/Fail_star.ExportJson", armatureName = "Fail_star", animationName = "Animation2",
time = 3 , po1 = cc.p(0,-200), po2 = cc.p(display.width+100,300), isLoop = true, isCache = false, scale = 1}

LandArmatureResource.armatureResourceInfo[LandArmatureResource.ANI_WAITTEXT] = 
{ resourceById = LandArmatureResource.ANI_WAITTEXT, configFilePath = "waittext/waittext.ExportJson", armatureName = "waittext", animationName = "Animation2",
time = 3 , po1 = cc.p(0,-30), po2 = cc.p(display.width+100,300), isLoop = true, isCache = false, scale = 1}

LandArmatureResource.armatureResourceInfo[LandArmatureResource.ANI_SOUND] = 
{ resourceById = LandArmatureResource.ANI_SOUND, configFilePath = "doudizhusound/doudizhusound.ExportJson", armatureName = "doudizhusound", animationName = "Animation2",
time = 3 , po1 = cc.p(640,360), po2 = cc.p(display.width+100,300), isLoop = true, isCache = false, scale = 1}

LandArmatureResource.armatureResourceInfo[LandArmatureResource.ANI_DIZHUSHAOBA] = 
{ resourceById = LandArmatureResource.ANI_DIZHUSHAOBA, configFilePath = "dizhusaozhou/dizhusaozhou.ExportJson", armatureName = "dizhusaozhou", animationName = "Animation1",
time = 3 , po1 = cc.p(50,-170), po2 = cc.p(display.width+100,300), isLoop = true, isCache = false, scale = 1}

LandArmatureResource.armatureResourceInfo[LandArmatureResource.ANI_JIANGZHUANG] = 
{ resourceById = LandArmatureResource.ANI_JIANGZHUANG, configFilePath = "lord_match_diploma01/lord_match_diploma01.ExportJson", armatureName = "lord_match_diploma01", animationName = "Animation1",
time = 3 , po1 = cc.p(0,0), po2 = cc.p(display.width+100,300), isLoop = false, isCache = false, scale = 1, isDelete = false}

LandArmatureResource.armatureResourceInfo[LandArmatureResource.ANI_TAOTAI] = 
{ resourceById = LandArmatureResource.ANI_TAOTAI, configFilePath = "lord_match_lose/lord_match_lose.ExportJson", armatureName = "lord_match_lose", animationName = "lord_match_ani_lose",
time = 3 , po1 = cc.p(0,0), po2 = cc.p(display.width+100,300), isLoop = false, isCache = false, scale = 1, isDelete = false}

LandArmatureResource.armatureResourceInfo[LandArmatureResource.ANI_SUNSHINE] = 
{ resourceById = LandArmatureResource.ANI_SUNSHINE, configFilePath = "dizhuscene/dizhuscene.ExportJson", armatureName = "dizhuscene", animationName = "Animation1",
time = 3 , po1 = cc.p(640,360), po2 = cc.p(display.width+100,300), isLoop = true, isCache = false, scale = 1}

LandArmatureResource.ANI_DIZHU		    	= 1110                                  -- 地主
LandArmatureResource.ANI_NONG_MING			= 1111                                  -- 农民
LandArmatureResource.ANI_MATCH		    	= 1112                                  -- 比赛场  比赛开始, 第几名  晋级等动画
LandArmatureResource.ANI_GUAN_YA		    = 1113                                  -- 冠军亚军

LandArmatureResource.armatureResourceInfo[LandArmatureResource.ANI_DIZHU] =
{ resourceById = LandArmatureResource.ANI_DIZHU, configFilePath = "dizhudongzuo/dizhudongzuo.ExportJson", armatureName = "dizhudongzuo",
animationName ={daiji ="xuanpai", xuanpai = "xuanpai", chupai = "chupai", shengli = "shengli", shibai = "shibai",},
time = 3 , po1 =cc.p(640,360), po2 = cc.p(display.width+100,300), isLoop = true, isCache = false, scale = 1}

LandArmatureResource.armatureResourceInfo[LandArmatureResource.ANI_NONG_MING] =
{ resourceById = LandArmatureResource.ANI_NONG_MING, configFilePath = "nongmindongzuo/nongmindongzuo.ExportJson", armatureName = "nongmindongzuo",
animationName ={daiji ="xuanpai", xuanpai = "xuanpai", chupai = "chupai", shengli = "shengli", shibai = "shibai",},
time = 3 , po1 =cc.p(640,360), po2 = cc.p(display.width+100,300), isLoop = true, isCache = false, scale = 1}


LandArmatureResource.armatureResourceInfo[LandArmatureResource.ANI_MATCH] =
{ resourceById = LandArmatureResource.ANI_MATCH, configFilePath = "lord_match/lord_match.ExportJson", armatureName = "lord_match",
animationName ={lord_match_ani_start="lord_match_ani_start", lord_match_ani_ranking= "lord_match_ani_ranking", lord_match_ani_ranking01= "lord_match_ani_ranking01", lord_match_ani_ranking02= "lord_match_ani_ranking02"},
time = 3 , po1 = cc.p(0,0), po2 = cc.p(display.width+100,300), isLoop = false, isCache = false, scale = 1}

LandArmatureResource.armatureResourceInfo[LandArmatureResource.ANI_GUAN_YA] =
{ resourceById = LandArmatureResource.ANI_GUAN_YA, configFilePath = "lord_match_no1/lord_match_no1.ExportJson", armatureName = "lord_match_no1",
animationName ={lord_ani_no1 ="lord_ani_no1", lord_ani_no2 = "lord_ani_no2",},
time = 3 , po1 = cc.p(0,-150), po2 = cc.p(display.width+100,300), isLoop = true, isCache = false, scale = 1}


LandArmatureResource.ANI_JINDIAN	    	= 1120                                  -- 经典
LandArmatureResource.ANI_ERREN		    	= 1121                                  -- 二人
LandArmatureResource.ANI_HUANLE		    	= 1122                                  -- 欢乐
LandArmatureResource.ANI_LAIZI			    = 1123                                  -- 赖子
LandArmatureResource.ANI_PAIYOU			    = 1124                                  -- 牌友 

LandArmatureResource.armatureResourceInfo[LandArmatureResource.ANI_JINDIAN] = 
{ resourceById = LandArmatureResource.ANI_JINDIAN, configFilePath = "jingdian/jingdian.ExportJson", armatureName = "jingdian", animationName = "jingdian",
time = 3 , po1 = cc.p(0,0), po2 = cc.p(display.width+100,300), isLoop = true, isCache = false, scale = 1}

LandArmatureResource.armatureResourceInfo[LandArmatureResource.ANI_ERREN] = 
{ resourceById = LandArmatureResource.ANI_ERREN, configFilePath = "erren/erren.ExportJson", armatureName = "erren", animationName = "erren",
time = 3 , po1 = cc.p(0,0), po2 = cc.p(display.width+100,300), isLoop = true, isCache = false, scale = 1}

LandArmatureResource.armatureResourceInfo[LandArmatureResource.ANI_HUANLE] = 
{ resourceById = LandArmatureResource.ANI_HUANLE, configFilePath = "huanle/huanle.ExportJson", armatureName = "huanle", animationName = "huanle",
time = 3 , po1 = cc.p(0,0), po2 = cc.p(display.width+100,300), isLoop = true, isCache = false, scale = 1}

LandArmatureResource.armatureResourceInfo[LandArmatureResource.ANI_LAIZI] = 
{ resourceById = LandArmatureResource.ANI_LAIZI, configFilePath = "laizi/laizi.ExportJson", armatureName = "laizi", animationName = "laizi",
time = 3 , po1 = cc.p(0,0), po2 = cc.p(display.width+100,300), isLoop = true, isCache = false, scale = 1}

LandArmatureResource.armatureResourceInfo[LandArmatureResource.ANI_PAIYOU] = 
{ resourceById = LandArmatureResource.ANI_PAIYOU, configFilePath = "paiyou/paiyou.ExportJson", armatureName = "paiyou", animationName = "paiyou",
time = 3 , po1 = cc.p(0,0), po2 = cc.p(display.width+100,300), isLoop = true, isCache = false, scale = 1}


-- 单包大厅动画
LandArmatureResource.ANI_SINGLE_CREATE    	= 1130                                  -- 创建
LandArmatureResource.ANI_SINGLE_JOININ    	= 1131                                  -- 加入
LandArmatureResource.ANI_SINGLE_JIANDIAN   	= 1132                                  -- 经典
LandArmatureResource.ANI_SINGLE_HUANLE	    = 1133                                  -- 欢乐 

LandArmatureResource.armatureResourceInfo[LandArmatureResource.ANI_SINGLE_CREATE] = 
{ resourceById = LandArmatureResource.ANI_SINGLE_CREATE, configFilePath = "chuangjianfangjian/chuangjianfangjian.ExportJson", armatureName = "chuangjianfangjian", animationName = "changjian",
time = 3 , po1 = cc.p(0,0), po2 = cc.p(display.width+100,300), isLoop = true, isCache = false, scale = 1}

LandArmatureResource.armatureResourceInfo[LandArmatureResource.ANI_SINGLE_JOININ] = 
{ resourceById = LandArmatureResource.ANI_SINGLE_JOININ, configFilePath = "jiarufangjian/jiarufangjian.ExportJson", armatureName = "jiarufangjian", animationName = "changjian",
time = 3 , po1 = cc.p(0,0), po2 = cc.p(display.width+100,300), isLoop = true, isCache = false, scale = 1}

LandArmatureResource.armatureResourceInfo[LandArmatureResource.ANI_SINGLE_JIANDIAN] = 
{ resourceById = LandArmatureResource.ANI_SINGLE_JIANDIAN, configFilePath = "jingdiandoudizhu/jingdiandoudizhu.ExportJson", armatureName = "jingdiandoudizhu", animationName = "changjian",
time = 3 , po1 = cc.p(0,0), po2 = cc.p(display.width+100,300), isLoop = true, isCache = false, scale = 1}

LandArmatureResource.armatureResourceInfo[LandArmatureResource.ANI_SINGLE_HUANLE] = 
{ resourceById = LandArmatureResource.ANI_SINGLE_HUANLE, configFilePath = "huanledoudizhu/huanledoudizhu.ExportJson", armatureName = "huanledoudizhu", animationName = "changjian",
time = 3 , po1 = cc.p(0,0), po2 = cc.p(display.width+100,300), isLoop = true, isCache = false, scale = 1}

LandArmatureResource.WAIT_START	    = 1134                                  -- 等待开始 
LandArmatureResource.armatureResourceInfo[LandArmatureResource.WAIT_START] = 
{ resourceById = LandArmatureResource.WAIT_START, configFilePath = "start/pinshi_animation.ExportJson", armatureName = "pinshi_animation", animationName = "dn_zhi_moment",
time = 0 , po1 =  cc.p(667*display.scaleX,360), po2 = cc.p(display.width+100,300), isLoop = true, isCache = false, scale = 1}


LandArmatureResource.MATCH_WAIT	    = 1135                                  -- 等待晋级 
LandArmatureResource.armatureResourceInfo[LandArmatureResource.MATCH_WAIT] = 
{ resourceById = LandArmatureResource.MATCH_WAIT, configFilePath = "matchwait/pinshi_animation.ExportJson", armatureName = "pinshi_animation", animationName = "dn_zhi_moment",
time = 0 , po1 =  cc.p(667*display.scaleX,360), po2 = cc.p(display.width+100,300), isLoop = true, isCache = false, scale = 1}


return LandArmatureResource