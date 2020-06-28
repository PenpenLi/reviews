-- StringConfig.lua
-- Author: 
-- Date: 2018-08-07 18:17:10
-- 字符串处理

local StringConfig = {}
local gStringConfigValueMap = cc.FileUtils:getInstance():getValueMapFromFile("config/strings.plist")  

StringConfig.getValueByKey = function(strKey)
    local str = ""
    for key, value in pairs(gStringConfigValueMap) do  
	    if key == strKey then
	    	if value then
	    		print(value)
	    		str = gStringConfigValueMap[key]
	    	end
	     end 
	end 
	return str
end

return StringConfig