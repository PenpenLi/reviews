local GameController = class("GameController")
local module_pre = "game.yule.qpby.src"
local ExternalFun = require(appdf.EXTERNAL_SRC .. "ExternalFun")
local scheduler = cc.Director:getInstance():getScheduler()
local Game_CMD = appdf.req(module_pre .. ".models.CMD_LKPYGame")
function GameController:ctor(scene)
    self.scene = scene
    self._gameFrame = self.scene._gameFrame
    self:enableTimer()
    self:initListener()
    self.m_pUserItem = self._gameFrame:GetMeUserItem()
    self.m_nTableID = self.m_pUserItem.wTableID
    self.m_nChairID = self.m_pUserItem.wChairID
    self.m_dwUserID = self.m_pUserItem.dwUserID
    self.MinShoot = 0
    self.MaxShoot = 0
end
function GameController:initLayers()
    self.backgroundLayer = self.scene.backgroundLayer
    self.fishLayer = self.scene.fishLayer
    self.bulletLayer = self.scene.bulletLayer
    self.collisionLayer = self.scene.collisionLayer
    self.effectLayer = self.scene.effectLayer
    self.cannonLayer = self.scene.cannonLayer
end
function GameController:initListener()
    local eventListeners = {}
    eventListeners["qpby_changeLockTarget"] = handler(self, self.changeLocktarget)
    eventListeners["qpby_changeAutoLock"] = handler(self, self.changeAutoLock)
    -- self.qpbyEventHandles = EventMgr:getInstance():addEventListenerByTable(eventListeners)
    self.qpbyEventHandles = nil
   local listener1 = cc.EventListenerCustom:create("qpby_changeLockTarget", function(args) self:changeLocktarget(args._usedata) end)
   local listener2 = cc.EventListenerCustom:create("qpby_changeAutoLock", function(args) self:changeAutoLock(args._usedata) end)
   local dispacther=cc.Director:getInstance():getEventDispatcher()
   dispacther:addEventListenerWithFixedPriority(listener1, 1)
   dispacther:addEventListenerWithFixedPriority(listener2, 1)
end
function GameController:removeListener()
    -- EventMgr:getInstance():removeListenerByTable(self.qpbyEventHandles)
    self.qpbyEventHandles = nil
    local dispacther=cc.Director:getInstance():getEventDispatcher()
    dispacther:removeCustomEventListeners("qpby_changeLockTarget")
    dispacther:removeCustomEventListeners("qpby_changeAutoLock")
end
function GameController:checkLockTarget(fishId)
    local curTagrget = self.cannonLayer.myCannon.lockingTarget
    if curTagrget == fishId then
        self:changeLocktarget()
    end
end
function GameController:changeLocktarget(args)
    local curTagrget = self.cannonLayer.myCannon.lockingTarget
    local lockId = self.fishLayer:getAutoLockFishId(curTagrget)
    if lockId ~= 0xFFFFFFFF then
        self.cannonLayer:setMyCannonLockFish(lockId)
    end
    self.effectLayer:loadLockedFish(lockId)
end
function GameController:changeAutoLock(args)
    local param = args.para
    if param.isLock then
        local lockId = self.fishLayer:getAutoLockFishId()
        if lockId ~= 0xFFFFFFFF then
            self.cannonLayer:setMyCannonLockFish(lockId)
        end
        self.effectLayer:loadLockedFish(lockId)
    else
        self.cannonLayer:setMyCannonLockFish(0xFFFFFFFF)
        self.effectLayer:loadLockedFish(0xFFFFFFFF)
    end
end
function GameController:onEventUserEnter(wTableID, wChairID, useritem)
    self.cannonLayer:onEventUserEnter(wTableID, wChairID, useritem)
end
function GameController:onEventUserStatus(useritem, newstatus, oldstatus)
    self.cannonLayer:onEventUserStatus(useritem, newstatus, oldstatus)
end
function GameController:othershoot(fire)
    if fire.lock_fishid ~= 0 then
    else
    end
    self.cannonLayer:othershoot(fire)
end
function GameController:setAuto(isAuto)
    self.cannonLayer:setAutoFire(isAuto)
end
function GameController:setFireSpeed(speed)
    self.cannonLayer:setFireSpeed(speed)
end
function GameController:setMultiple(sceneData)
    self.MinShoot = sceneData.MinShoot
    self.MaxShoot = sceneData.MaxShoot
    self.cannonLayer:setMinScore(sceneData.MinShoot)
end
function GameController:createBullet(angle, cannonPos, chairId, bulletScore, bulletLockTarget)
    local isCreate = self.bulletLayer:createBullet(angle, cannonPos, chairId, bulletScore, bulletLockTarget)
    if isCreate and self.m_nChairID == chairId then
        local cannon = self.cannonLayer:getCannonByChairId(chairId)
        if not tolua.isnull(cannon) then
            cannon:addScore(-bulletScore)
        end
    end
end
function GameController:createFish(fishData)
    self.fishLayer:createFish(fishData)
end
function GameController:updateScore(data)
    local chairId = data.wChairID
    local score = data.lFishScore
    local cannon = self.cannonLayer:getCannonByChairId(chairId)
    if tolua.isnull(cannon) then
        return
    end
    cannon:updateScore(score)
end
function GameController:onBackScore(score)
    local chairId = score.chair_id
    local mulScore = score.bullet_mul
    local cannon = self.cannonLayer:getCannonByChairId(chairId)
    if tolua.isnull(cannon) then
        return
    end
    cannon:addScore(mulScore)
end
function GameController:onSubCatchFishKingResult(catchData)
    local catchFish = self.fishLayer:getFishByFishId(catchData.dwFishID)
    if tolua.isnull(catchFish) then
        return
    end
    if catchFish.fishData.TypeID == "920" then
        local deadFishIdList = catchData.catch_fish_id[1]
        self.effectLayer:dynamiteFishBoom(catchFish, deadFishIdList, catchData.wChairID, catchData.fish_score)
    elseif catchFish.fishData.TypeID == "940" then
        local deadFishIdList = catchData.catch_fish_id[1]
        self.effectLayer:blackholeFishEffect(
            catchFish,
            deadFishIdList,
            catchData.catch_fish_count,
            catchData.wChairID,
            catchData.fish_score
        )
    end
end
function GameController:onSubCatchFishKing(catchData)
    local catchFish = self.fishLayer:getFishByFishId(catchData.dwFishID)
    if not tolua.isnull(catchFish) then
    else
        return
    end
    if catchFish.fishData.TypeID == "920" then
        if catchData.wChairID == self.m_nChairID then
            local catchCount = 0
            local fishList = self.fishLayer:getFishList()
            local fishId = {}
            for i = 1, #fishList do
                local fishTemp = fishList[i]
                if not tolua.isnull(fishTemp) then
                    catchCount = catchCount + 1
                    table.insert(fishId, fishTemp.fishId)
                end
            end
            if catchCount > 0 then
                local cmddata = CCmd_Data:create(1210)
                cmddata:setcmdinfo(yl.MDM_GF_GAME, Game_CMD.SUB_C_CATCH_SWEEP_FISH)
                cmddata:pushword(catchData.wChairID)
                cmddata:pushint(catchData.dwFishID)
                cmddata:pushint(catchCount)
                for i = 1, catchCount do
                    cmddata:pushint(fishId[i])
                end
                for i = catchCount + 1, 300 do
                    cmddata:pushint(0)
                end
                for i = #fishId, 1, -1 do
                    table.remove(fishId, i)
                end
                if not self._gameFrame:sendSocketData(cmddata) then
                    self._gameFrame._callBack(-1, "发送消息失败")
                end
            end
        end
    elseif catchFish.fishData.TypeID == "940" then
        if catchData.wChairID == self.m_nChairID then
            local catchCount = 0
            local fishId = {}
            local fishList = self.fishLayer:getFishList()
            local catchFishPos3D = catchFish:getPosition3D()
            local catchFishPos = self.scene._camera:projectGL(catchFishPos3D)
            for i = 1, #fishList do
                local fishTemp = fishList[i]
                local fishPos3D = fishTemp:getPosition3D()
                local pos = self.scene._camera:projectGL(fishPos3D)
                local distance =
                    math.sqrt(
                    (catchFishPos.x - pos.x) * (catchFishPos.x - pos.x) +
                        (catchFishPos.y - pos.y) * (catchFishPos.y - pos.y)
                )
                if distance <= 300 then
                    catchCount = catchCount + 1
                    table.insert(fishId, fishTemp.fishId)
                end
            end
            if catchCount > 0 then
                local cmddata = CCmd_Data:create(1210)
                cmddata:setcmdinfo(yl.MDM_GF_GAME, Game_CMD.SUB_C_CATCH_SWEEP_FISH)
                cmddata:pushword(catchData.wChairID)
                cmddata:pushint(catchData.dwFishID)
                cmddata:pushint(catchCount)
                for i = 1, catchCount do
                    cmddata:pushint(fishId[i])
                end
                for i = catchCount + 1, 300 do
                    cmddata:pushint(0)
                end
                for i = #fishId, 1, -1 do
                    table.remove(fishId, i)
                end
                if not self._gameFrame:sendSocketData(cmddata) then
                    self._gameFrame._callBack(-1, "发送消息失败")
                end
            end
        end
    end
end
function GameController:fishDead(catchData)
    local fish = self.fishLayer:getFishByFishId(catchData.dwFishID)
    if not tolua.isnull(fish) then
        if fish.fishData.TypeID == "910" then
            self.scene.bFishStop = true
            self.effectLayer:displayFrozenEffect(fish)
            return
        else
            fish.hp = 0
        end
    else
        return
    end
    local fishPos = fish:getPosition3D()
    fishPos = self.scene._camera:projectGL(fishPos)
    local chairId = catchData.wChairID
    local score = catchData.lFishScore
    local app = catchData.app
    local effectLevel = 1
    local cannon = self.cannonLayer:getCannonByChairId(chairId)
    if tolua.isnull(cannon) then
        return
    end
    local coinPos = cannon:getCoinPosToWord()
    if fish.fishData.TypeID == "27" then
        self.effectLayer:crabBoom(score, chairId, app, fishPos)
    else
        self.effectLayer:ShowFishGoldEx(fishPos, coinPos, chairId, score, effectLevel)
    end
    if fish.fishData.ShakeScreen == "true" then
        self.effectLayer:setShakeScreen()
    end
    if chairId == self.m_nChairID and fish.fishData.ShowBingo == "true" then
        ExternalFun.playSoundEffectCommon("sound/effect/CJ.mp3")
    end
end
function GameController:testTroop()
    local troopComb = {
        ["fish_count"] = 201,
        ["fish_id"] = {
            [1] = {
                [1] = 339114,
                [2] = 339115,
                [3] = 339116,
                [4] = 339117,
                [5] = 339118,
                [6] = 339119,
                [7] = 339120,
                [8] = 339121,
                [9] = 339122,
                [10] = 339123,
                [11] = 339124,
                [12] = 339125,
                [13] = 339126,
                [14] = 339127,
                [15] = 339128,
                [16] = 339129,
                [17] = 339130,
                [18] = 339131,
                [19] = 339132,
                [20] = 339133,
                [21] = 339134,
                [22] = 339135,
                [23] = 339136,
                [24] = 339137,
                [25] = 339138,
                [26] = 339139,
                [27] = 339140,
                [28] = 339141,
                [29] = 339142,
                [30] = 339143,
                [31] = 339144,
                [32] = 339145,
                [33] = 339146,
                [34] = 339147,
                [35] = 339148,
                [36] = 339149,
                [37] = 339150,
                [38] = 339151,
                [39] = 339152,
                [40] = 339153,
                [41] = 339154,
                [42] = 339155,
                [43] = 339156,
                [44] = 339157,
                [45] = 339158,
                [46] = 339159,
                [47] = 339160,
                [48] = 339161,
                [49] = 339162,
                [50] = 339163,
                [51] = 339164,
                [52] = 339165,
                [53] = 339166,
                [54] = 339167,
                [55] = 339168,
                [56] = 339169,
                [57] = 339170,
                [58] = 339171,
                [59] = 339172,
                [60] = 339173,
                [61] = 339174,
                [62] = 339175,
                [63] = 339176,
                [64] = 339177,
                [65] = 339178,
                [66] = 339179,
                [67] = 339180,
                [68] = 339181,
                [69] = 339182,
                [70] = 339183,
                [71] = 339184,
                [72] = 339185,
                [73] = 339186,
                [74] = 339187,
                [75] = 339188,
                [76] = 339189,
                [77] = 339190,
                [78] = 339191,
                [79] = 339192,
                [80] = 339193,
                [81] = 339194,
                [82] = 339195,
                [83] = 339196,
                [84] = 339197,
                [85] = 339198,
                [86] = 339199,
                [87] = 339200,
                [88] = 339201,
                [89] = 339202,
                [90] = 339203,
                [91] = 339204,
                [92] = 339205,
                [93] = 339206,
                [94] = 339207,
                [95] = 339208,
                [96] = 339209,
                [97] = 339210,
                [98] = 339211,
                [99] = 339212,
                [100] = 339213,
                [101] = 339214,
                [102] = 339215,
                [103] = 339216,
                [104] = 339217,
                [105] = 339218,
                [106] = 339219,
                [107] = 339220,
                [108] = 339221,
                [109] = 339222,
                [110] = 339223,
                [111] = 339224,
                [112] = 339225,
                [113] = 339226,
                [114] = 339227,
                [115] = 339228,
                [116] = 339229,
                [117] = 339230,
                [118] = 339231,
                [119] = 339232,
                [120] = 339233,
                [121] = 339234,
                [122] = 339235,
                [123] = 339236,
                [124] = 339237,
                [125] = 339238,
                [126] = 339239,
                [127] = 339240,
                [128] = 339241,
                [129] = 339242,
                [130] = 339243,
                [131] = 339244,
                [132] = 339245,
                [133] = 339246,
                [134] = 339247,
                [135] = 339248,
                [136] = 339249,
                [137] = 339250,
                [138] = 339251,
                [139] = 339252,
                [140] = 339253,
                [141] = 339254,
                [142] = 339255,
                [143] = 339256,
                [144] = 339257,
                [145] = 339258,
                [146] = 339259,
                [147] = 339260,
                [148] = 339261,
                [149] = 339262,
                [150] = 339263,
                [151] = 339264,
                [152] = 339265,
                [153] = 339266,
                [154] = 339267,
                [155] = 339268,
                [156] = 339269,
                [157] = 339270,
                [158] = 339271,
                [159] = 339272,
                [160] = 339273,
                [161] = 339274,
                [162] = 339275,
                [163] = 339276,
                [164] = 339277,
                [165] = 339278,
                [166] = 339279,
                [167] = 339280,
                [168] = 339281,
                [169] = 339282,
                [170] = 339283,
                [171] = 339284,
                [172] = 339285,
                [173] = 339286,
                [174] = 339287,
                [175] = 339288,
                [176] = 339289,
                [177] = 339290,
                [178] = 339291,
                [179] = 339292,
                [180] = 339293,
                [181] = 339294,
                [182] = 339295,
                [183] = 339296,
                [184] = 339297,
                [185] = 339298,
                [186] = 339299,
                [187] = 339300,
                [188] = 339301,
                [189] = 339302,
                [190] = 339303,
                [191] = 339304,
                [192] = 339305,
                [193] = 339306,
                [194] = 339307,
                [195] = 339308,
                [196] = 339309,
                [197] = 339310,
                [198] = 339311,
                [199] = 339312,
                [200] = 339313,
                [201] = 339314,
                [202] = 0,
                [203] = 0,
                [204] = 0,
                [205] = 0,
                [206] = 0,
                [207] = 0,
                [208] = 0,
                [209] = 0,
                [210] = 0,
                [211] = 0,
                [212] = 0,
                [213] = 0,
                [214] = 0,
                [215] = 0,
                [216] = 0,
                [217] = 0,
                [218] = 0,
                [219] = 0,
                [220] = 0,
                [221] = 0,
                [222] = 0,
                [223] = 0,
                [224] = 0,
                [225] = 0,
                [226] = 0,
                [227] = 0,
                [228] = 0,
                [229] = 0,
                [230] = 0,
                [231] = 0,
                [232] = 0,
                [233] = 0,
                [234] = 0,
                [235] = 0,
                [236] = 0,
                [237] = 0,
                [238] = 0,
                [239] = 0,
                [240] = 0,
                [241] = 0,
                [242] = 0,
                [243] = 0,
                [244] = 0,
                [245] = 0,
                [246] = 0,
                [247] = 0,
                [248] = 0,
                [249] = 0,
                [250] = 0,
                [251] = 0,
                [252] = 0,
                [253] = 0,
                [254] = 0,
                [255] = 0,
                [256] = 0,
                [257] = 0,
                [258] = 0,
                [259] = 0,
                [260] = 0,
                [261] = 0,
                [262] = 0,
                [263] = 0,
                [264] = 0,
                [265] = 0,
                [266] = 0,
                [267] = 0,
                [268] = 0,
                [269] = 0,
                [270] = 0,
                [271] = 0,
                [272] = 0,
                [273] = 0,
                [274] = 0,
                [275] = 0,
                [276] = 0,
                [277] = 0,
                [278] = 0,
                [279] = 0,
                [280] = 0,
                [281] = 0,
                [282] = 0,
                [283] = 0,
                [284] = 0,
                [285] = 0,
                [286] = 0,
                [287] = 0,
                [288] = 0,
                [289] = 0,
                [290] = 0,
                [291] = 0,
                [292] = 0,
                [293] = 0,
                [294] = 0,
                [295] = 0,
                [296] = 0,
                [297] = 0,
                [298] = 0,
                [299] = 0,
                [300] = 0
            }
        },
        ["fish_kind"] = {
            [1] = {
                [1] = 14,
                [2] = 14,
                [3] = 14,
                [4] = 14,
                [5] = 14,
                [6] = 14,
                [7] = 14,
                [8] = 14,
                [9] = 14,
                [10] = 14,
                [11] = 14,
                [12] = 14,
                [13] = 14,
                [14] = 14,
                [15] = 14,
                [16] = 14,
                [17] = 14,
                [18] = 14,
                [19] = 7,
                [20] = 7,
                [21] = 7,
                [22] = 7,
                [23] = 7,
                [24] = 7,
                [25] = 7,
                [26] = 7,
                [27] = 7,
                [28] = 7,
                [29] = 7,
                [30] = 7,
                [31] = 7,
                [32] = 7,
                [33] = 7,
                [34] = 7,
                [35] = 7,
                [36] = 7,
                [37] = 14,
                [38] = 14,
                [39] = 14,
                [40] = 14,
                [41] = 14,
                [42] = 14,
                [43] = 14,
                [44] = 14,
                [45] = 14,
                [46] = 14,
                [47] = 14,
                [48] = 14,
                [49] = 14,
                [50] = 14,
                [51] = 14,
                [52] = 14,
                [53] = 14,
                [54] = 14,
                [55] = 7,
                [56] = 7,
                [57] = 7,
                [58] = 7,
                [59] = 7,
                [60] = 7,
                [61] = 7,
                [62] = 7,
                [63] = 7,
                [64] = 7,
                [65] = 7,
                [66] = 7,
                [67] = 7,
                [68] = 7,
                [69] = 7,
                [70] = 7,
                [71] = 7,
                [72] = 7,
                [73] = 14,
                [74] = 14,
                [75] = 14,
                [76] = 14,
                [77] = 14,
                [78] = 14,
                [79] = 14,
                [80] = 14,
                [81] = 14,
                [82] = 14,
                [83] = 14,
                [84] = 14,
                [85] = 14,
                [86] = 14,
                [87] = 14,
                [88] = 14,
                [89] = 14,
                [90] = 14,
                [91] = 7,
                [92] = 7,
                [93] = 7,
                [94] = 7,
                [95] = 7,
                [96] = 7,
                [97] = 7,
                [98] = 7,
                [99] = 7,
                [100] = 7,
                [101] = 7,
                [102] = 7,
                [103] = 7,
                [104] = 7,
                [105] = 7,
                [106] = 7,
                [107] = 7,
                [108] = 7,
                [109] = 14,
                [110] = 14,
                [111] = 14,
                [112] = 14,
                [113] = 14,
                [114] = 14,
                [115] = 14,
                [116] = 14,
                [117] = 14,
                [118] = 14,
                [119] = 14,
                [120] = 14,
                [121] = 14,
                [122] = 14,
                [123] = 14,
                [124] = 14,
                [125] = 14,
                [126] = 14,
                [127] = 7,
                [128] = 7,
                [129] = 7,
                [130] = 7,
                [131] = 7,
                [132] = 7,
                [133] = 7,
                [134] = 7,
                [135] = 7,
                [136] = 7,
                [137] = 7,
                [138] = 7,
                [139] = 7,
                [140] = 7,
                [141] = 7,
                [142] = 7,
                [143] = 7,
                [144] = 7,
                [145] = 14,
                [146] = 14,
                [147] = 14,
                [148] = 14,
                [149] = 14,
                [150] = 14,
                [151] = 14,
                [152] = 14,
                [153] = 14,
                [154] = 14,
                [155] = 14,
                [156] = 14,
                [157] = 14,
                [158] = 14,
                [159] = 14,
                [160] = 14,
                [161] = 14,
                [162] = 14,
                [163] = 7,
                [164] = 7,
                [165] = 7,
                [166] = 7,
                [167] = 7,
                [168] = 7,
                [169] = 7,
                [170] = 7,
                [171] = 7,
                [172] = 7,
                [173] = 7,
                [174] = 7,
                [175] = 7,
                [176] = 7,
                [177] = 7,
                [178] = 7,
                [179] = 7,
                [180] = 7,
                [181] = 14,
                [182] = 14,
                [183] = 14,
                [184] = 14,
                [185] = 14,
                [186] = 14,
                [187] = 14,
                [188] = 14,
                [189] = 14,
                [190] = 14,
                [191] = 14,
                [192] = 14,
                [193] = 14,
                [194] = 14,
                [195] = 14,
                [196] = 14,
                [197] = 14,
                [198] = 14,
                [199] = 18,
                [200] = 18,
                [201] = 18,
                [202] = 0,
                [203] = 0,
                [204] = 0,
                [205] = 0,
                [206] = 0,
                [207] = 0,
                [208] = 0,
                [209] = 0,
                [210] = 0,
                [211] = 0,
                [212] = 0,
                [213] = 0,
                [214] = 0,
                [215] = 0,
                [216] = 0,
                [217] = 0,
                [218] = 0,
                [219] = 0,
                [220] = 0,
                [221] = 0,
                [222] = 0,
                [223] = 0,
                [224] = 0,
                [225] = 0,
                [226] = 0,
                [227] = 0,
                [228] = 0,
                [229] = 0,
                [230] = 0,
                [231] = 0,
                [232] = 0,
                [233] = 0,
                [234] = 0,
                [235] = 0,
                [236] = 0,
                [237] = 0,
                [238] = 0,
                [239] = 0,
                [240] = 0,
                [241] = 0,
                [242] = 0,
                [243] = 0,
                [244] = 0,
                [245] = 0,
                [246] = 0,
                [247] = 0,
                [248] = 0,
                [249] = 0,
                [250] = 0,
                [251] = 0,
                [252] = 0,
                [253] = 0,
                [254] = 0,
                [255] = 0,
                [256] = 0,
                [257] = 0,
                [258] = 0,
                [259] = 0,
                [260] = 0,
                [261] = 0,
                [262] = 0,
                [263] = 0,
                [264] = 0,
                [265] = 0,
                [266] = 0,
                [267] = 0,
                [268] = 0,
                [269] = 0,
                [270] = 0,
                [271] = 0,
                [272] = 0,
                [273] = 0,
                [274] = 0,
                [275] = 0,
                [276] = 0,
                [277] = 0,
                [278] = 0,
                [279] = 0,
                [280] = 0,
                [281] = 0,
                [282] = 0,
                [283] = 0,
                [284] = 0,
                [285] = 0,
                [286] = 0,
                [287] = 0,
                [288] = 0,
                [289] = 0,
                [290] = 0,
                [291] = 0,
                [292] = 0,
                [293] = 0,
                [294] = 0,
                [295] = 0,
                [296] = 0,
                [297] = 0,
                [298] = 0,
                [299] = 0,
                [300] = 0
            }
        },
        ["scene_kind"] = 0
    }
    self:playTroop(troopComb)
end
function GameController:playTroop(troopComb)
    local troopTable = self:getTroopData(troopComb)
    if not troopTable or #troopTable < 1 then
        return
    end
    self.effectLayer:playTroopTip()
    local effectTime = cc.DelayTime:create(1.5)
    local changeFun =
        cc.CallFunc:create(
        function()
            if not tolua.isnull(self.backgroundLayer) then
                self.backgroundLayer:switchScene()
            end
        end
    )
    local aniTime = cc.DelayTime:create(3.5)
    local clearFun =
        cc.CallFunc:create(
        function()
            if not tolua.isnull(self.fishLayer) then
                self.fishLayer:clearFish()
            end
        end
    )
    local waitTime = cc.DelayTime:create(2.5)
    local troopFun =
        cc.CallFunc:create(
        function()
            if not tolua.isnull(self.fishLayer) then
                self.fishLayer:playTroop(troopTable)
            end
        end
    )
    local seq = cc.Sequence:create(effectTime, changeFun, aniTime, clearFun, waitTime, troopFun)
    self.fishLayer:runAction(seq)
end
function GameController:getTroopData(data)
    local count = data.fish_count
    local fishIdTable = data.fish_id[1]
    local fishKindTable = data.fish_kind[1]
    local maxNum = 18
    local groupTable = {}
    local groupNum = math.ceil(count / maxNum)
    for i = 1, groupNum do
        groupTable[i] = {}
        for j = 1, maxNum do
            local index = (i - 1) * maxNum + j
            local fishKind = fishKindTable[index]
            local fishId = fishIdTable[index]
            if fishId ~= 0 then
                table.insert(groupTable[i], {fishKind, fishId})
            end
        end
    end
    return groupTable
end
function GameController:enableTimer()
    self.timerId = scheduler:scheduleScriptFunc(handler(self, self.update), 0.0, false)
end
function GameController:update(dt)
    local fishList = self.fishLayer:getFishList()
    for i = #fishList, 1, -1 do
        local fish = fishList[i]
        if not tolua.isnull(fish) then
            if fish.isRemove then
                table.remove(fishList, i)
                self:checkLockTarget(fish.fishId)
                fish:removeFromParent()
            else
                fish:update(dt)
            end
        end
    end
    local bulletList = self.bulletLayer:getBulletList()
    for i = #bulletList, 1, -1 do
        local bullet = bulletList[i]
        if not tolua.isnull(bullet) then
            if bullet.isDead then
                local pos = bullet:getPosition3D()
                self.effectLayer:bulletEffect(pos)
                table.remove(bulletList, i)
                bullet:removeFromParent()
                return
            end
            if bullet.isRemove then
                table.remove(bulletList, i)
                bullet:removeFromParent()
                return
            end
            bullet:update(dt)
        end
    end
    self.collisionLayer:setDataList(fishList, bulletList)
    self.collisionLayer:update(dt)
    self.effectLayer:update(dt)
    self.cannonLayer:update(dt)
end
function GameController:sendHitFish(bullet, fish)
    local chairId = bullet.chairId
    local fishId = fish.fishId
    local bulletType = bullet.type or 1
    local bulletIndex = bullet.bulletIndex
    local bulletScore = bullet.bulletScore
    local cmddata = CCmd_Data:create(18)
    cmddata:setcmdinfo(yl.MDM_GF_GAME, Game_CMD.SUB_C_CATCH_FISH)
    cmddata:pushword(chairId)
    cmddata:pushint(fishId)
    cmddata:pushint(bulletType)
    cmddata:pushint(bulletIndex)
    cmddata:pushint(bulletScore)
    if not self._gameFrame:sendSocketData(cmddata) then
        self._gameFrame._callBack(-1, "发送开火息失败")
    end
end
function GameController:setCannonLockByChairId(chairId, lockingTarget)
    self.cannonLayer:setCannonLockByChairId(chairId, lockingTarget)
end
function GameController:finalizer()
    self:removeListener()
    scheduler:unscheduleScriptEntry(self.timerId)
end
return GameController
