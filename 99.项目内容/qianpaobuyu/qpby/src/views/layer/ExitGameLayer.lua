local module_pre = "game.yule.qpby.src"
local ExternalFun = require(appdf.EXTERNAL_SRC .. "ExternalFun")
local cmd = module_pre .. ".models.CMD_LKPYGame"
local g_var = ExternalFun.req_var
local scheduler = cc.Director:getInstance():getScheduler()
local Game_CMD = appdf.req(module_pre .. ".models.CMD_LKPYGame")
local ExitGameLayer = class("ExitGameLayer", cc.Layer)
function ExitGameLayer:ctor(callback)
    local csbNode = ExternalFun.loadCSB(Game_CMD.RES_PATH .. "game_res/ExitGameLayer.csb", self)
    self.csbNode = csbNode
    ExternalFun.openLayerAction(self)
    self.callback = callback
    function callback(sender)
        self:onSelectedEvent(sender:getName(), sender)
    end
    appdf.getNodeByName(self.csbNode, "btnOk"):addClickEventListener(callback)
    appdf.getNodeByName(self.csbNode, "btnClose"):addClickEventListener(callback)
    self.time = 10
    appdf.getNodeByName(self.csbNode, "txtTime"):setString(math.floor(self.time))
    schedule(
        self,
        function()
            self.time = self.time - 1
            if self.time <= 0 then
                ExternalFun.closeLayerAction(
                    self,
                    function()
                        self:removeSelf()
                    end
                )
                return
            end
            appdf.getNodeByName(self.csbNode, "txtTime"):setString(math.floor(self.time))
        end,
        1.0
    )
end
function ExitGameLayer:onSelectedEvent(name, sender)
    if name == "btnClose" then
        ExternalFun.closeLayerAction(
            self,
            function()
                self:removeSelf()
            end
        )
    elseif name == "btnOk" then
        if self.callback then
            self.callback()
        end
    end
end
return ExitGameLayer
