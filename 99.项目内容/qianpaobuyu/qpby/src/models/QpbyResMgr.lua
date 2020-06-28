require "lfs"
QpbyResMgr = class("QpbyResMgr")
QpbyResMgr.instance = nil
function QpbyResMgr:getInstance()
    if QpbyResMgr.instance == nil then
        QpbyResMgr.instance = QpbyResMgr:create()
    end
    return QpbyResMgr.instance
end
function QpbyResMgr:create()
    local obj = QpbyResMgr.new()
    return obj
end
function QpbyResMgr:ctor()
    self:init()
end
function QpbyResMgr:init()
    self.wirtePath = device.writablePath .. "game/yule/qpby/res/"
    self.tempPath = ""
    self.plistPaths = {}
    self.plistPngPaths = {}
    self.pngPaths = {}
    self.armaturePaths = {}
    self.audioPaths = {}
    self:resetCount()
    self._plistPaths = {}
    self._plistPngPaths = {}
    self._pngPaths = {}
    self.isDebugPercent = false
    self.isDebugToFile = true
end
function QpbyResMgr:configTable()
    self:addPictureByDirectory("model")
    self:addPictureByDirectory("animationex")
    self:addPictureByDirectory("particle")
end
function QpbyResMgr:addPictureByDirectory(directory)
    local picturePaths = self:getAllPicturePathByDirectory(directory)
    self:addPngs(picturePaths)
end
function QpbyResMgr:addPictureNoPreloadByDirectory(directory)
    local picturePaths = self:getAllPicturePathByDirectory(directory)
    self:addPngsNoPreload(picturePaths)
end
function QpbyResMgr:getAllPicturePathByDirectory(directory)
    self.tempPath = self.wirtePath .. directory
    local pathTable = {}
    pathTable = self:getAllPicturePath(self.tempPath, pathTable)
    self.tempPath = ""
    for i = 1, #pathTable do
        pathTable[i] = directory .. pathTable[i]
    end
    return pathTable
end
function QpbyResMgr:getAllPicturePath(rootpath, pathTable)
    for entry in lfs.dir(rootpath) do
        if entry ~= "." and entry ~= ".." then
            local path = rootpath .. "/" .. entry
            local attr = lfs.attributes(path)
            if attr.mode ~= "directory" then
                if string.find(entry, ".png") or string.find(entry, ".jpg") then
                    local picPath = rootpath .. "/" .. entry
                    picPath = string.gsub(picPath, self.tempPath, "")
                    table.insert(pathTable, picPath)
                end
            else
                self:getAllPicturePath(path, pathTable)
            end
        end
    end
    return pathTable
end
function QpbyResMgr:setRemovePngsNoPreload()
    local roomlistPngs = {
        "bg/Room_Background.jpg",
        "animation/3dby_xuanfangwater.png",
        "animation/3dby_xuanfangwaterdi.png"
    }
    for i = 1, #roomlistPngs do
        roomlistPngs[i] = "roomlist/" .. roomlistPngs[i]
    end
    self:addPngsNoPreload(roomlistPngs)
    local scenePngs = self:getAllPicturePathByDirectory("scene")
    self:addPngsNoPreload(scenePngs)
    local spinePngs = {
        "room_spine_1/3Dbuyu_tiyanchang.png",
        "room_spine_2/3Dbuyu_qianpaochang.png",
        "room_spine_3/3Dbuyu_wanpaochang.png",
        "room_spine_4/3Dbuyu_shiwanpaochang.png",
        "room_spine_5/3Dbuyu_sanshiwanpaochang.png",
        "room_spine_light/3Dbuyu_xuanchang_light.png",
        "room_spine_particle/tyc_paopao.png"
    }
    for i = 1, #spinePngs do
        spinePngs[i] = "spine/" .. spinePngs[i]
    end
    self:addPngsNoPreload(spinePngs)
    self:addPictureNoPreloadByDirectory("fish_effect")
    self:addPictureNoPreloadByDirectory("ui")
end
function QpbyResMgr:update(dt)
    if self.delay > 1 then
        return
    end
    self.delay = self.delay + 1 / 300
    if self.delay >= 1.0 then
        self:updatePercent(1.0)
        self:updateEnd()
        if self.timerId then
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.timerId)
        end
        return
    end
    self:updatePercent(self.delay)
end
function QpbyResMgr:clearFile(filePath)
    local targetPlatform = cc.Application:getInstance():getTargetPlatform()
    if cc.PLATFORM_OS_WINDOWS ~= targetPlatform then
        return
    end
    local file = io.open(filePath, "w")
    io.output(file)
    io.close(file)
end
function QpbyResMgr:writeToFile(filePath, content, prefix)
    local file = io.open(filePath, "a")
    io.output(file)
    io.write("***************************************")
    io.write(os.date("%c") .. ":")
    if prefix then
        prefix = prefix
        io.write(prefix)
    end
    io.write(content)
    io.close(file)
end
function QpbyResMgr:writeTextureInfo(prefix)
    local info = cc.Director:getInstance():getTextureCache():getCachedTextureInfo()
    local targetPlatform = cc.Application:getInstance():getTargetPlatform()
    if cc.PLATFORM_OS_WINDOWS == targetPlatform then
        self:writeToFile("TextureInfo.txt", info, prefix)
    end
end
function QpbyResMgr:preload()
    if self.isDebugToFile then
        self:clearFile("TextureInfo.txt")
        self:writeTextureInfo("11111111")
    end
    if self.isDebugPercent then
        local scheduler = cc.Director:getInstance():getScheduler()
        self.timerId = scheduler:scheduleScriptFunc(handler(self, self.update), 0.0, false)
        self.delay = 0
        return
    end
    self:configTable()
    self.curIndex = 0
    if self.totalNum == 0 then
        self:updatePercent(1.0)
        self:updateEnd()
        return
    end
    local function loadedImage(texture)
        self.curIndex = self.curIndex + 1
        local percent = self.curIndex / self.totalNum
        self:updatePercent(percent)
        if self.curIndex >= self.totalNum then
            self:updateEnd()
        end
    end
    local textureCache = cc.Director:getInstance():getTextureCache()
    for i = 1, self.totalNum do
        textureCache:addImageAsync(self.pngPaths[i], loadedImage)
    end
end
function QpbyResMgr:updatePercent(percent)
    -- EventMgr:getInstance():dispatchEvent({name = "qpbyResMgr_percent", para = {percent = percent}})
    local event = cc.EventCustom:new("qpbyResMgr_percent")
    event._usedata = {name = "qpbyResMgr_percent", para = {percent = percent}}
    local dispacther=cc.Director:getInstance():getEventDispatcher()
    dispacther:dispatchEvent(event)
end
function QpbyResMgr:updateEnd()
    if self.isDebugToFile then
        self:writeTextureInfo("2222222222")
    end
    -- EventMgr:getInstance():dispatchEvent({name = "qpbyResMgr_updateEnd", para = {}})
    local event = cc.EventCustom:new("qpbyResMgr_updateEnd")
    event._usedata = {name = "qpbyResMgr_updateEnd", para = {}}
    local dispacther=cc.Director:getInstance():getEventDispatcher()
    dispacther:dispatchEvent(event)
end
function QpbyResMgr:addPlists(plists, pngs)
    for i = 1, #plists do
        table.insert(self.plistPaths, plists[i])
        table.insert(self.plistPngPaths, pngs[i])
    end
    self.totalNum = self.totalNum + #plists
end
function QpbyResMgr:addPngs(pngs)
    for i = 1, #pngs do
        table.insert(self.pngPaths, pngs[i])
    end
    self.totalNum = self.totalNum + #pngs
end
function QpbyResMgr:addPngsNoPreload(pngs)
    for i = 1, #pngs do
        table.insert(self._pngPaths, pngs[i])
    end
end
function QpbyResMgr:resetCount()
    self.curIndex = 0
    self.audioIndex = 0
    self.totalNum = 0
    self.endCall = nil
    self.FilesPerInterval = 10
end
function QpbyResMgr:releaseAll()
    self:setRemovePngsNoPreload()
    self:removeSpriteCache()
    if self.isDebugToFile then
        self:writeTextureInfo("333333333333")
    end
end
function QpbyResMgr:removeSpriteCache()
    for i = 1, #self.plistPaths do
        display.removeSpriteFrames(self.plistPaths[i], self.plistPngPaths[i])
    end
    for i = 1, #self.pngPaths do
        display.removeSpriteFrame(self.pngPaths[i])
        display.removeImage(self.pngPaths[i])
    end
    for i = 1, #self._plistPaths do
        display.removeSpriteFrames(self._plistPaths[i], self._plistPngPaths[i])
    end
    for i = 1, #self._pngPaths do
        display.removeSpriteFrame(self._pngPaths[i])
        display.removeImage(self._pngPaths[i])
    end
    self.plistPaths = {}
    self.plistPngPaths = {}
    self.pngPaths = {}
    self._plistPaths = {}
    self._plistPngPaths = {}
    self._pngPaths = {}
    self:resetCount()
end
return QpbyResMgr
