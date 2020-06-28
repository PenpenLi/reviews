--[[==========================================================================
]]
1.分层：
	msgid 
	model
	controller
	layer
	scene

2.消息到界面的处理
	common/BaseGameController.lua:TotalController; 消息函数
	TotalController:registerNetMsgCallback(self, Protocol.SceneServer, "CS_H2C_HandleMsg_Ack", handler(self, self.sceneNetMsgHandler))
	controller: 使用函数，注册消息到scene，scene调用layer；

3.10-7
2; 1w
6; 2w
3ceng: alabang; =>

