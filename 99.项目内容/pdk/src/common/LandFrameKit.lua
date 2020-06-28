--
-- Author: 
-- Date: 2018-08-07 18:17:10
-- 跑得快帧工具
local scheduler = require("framework.scheduler")

local frame_fun       = {}
local land_lord_frame = 0

function GET_CUR_FRAME()
	return land_lord_frame
end

function CAL_PUSH_SCENE_FRAME()
	if GET_CUR_FRAME() <= 0 then return 1 end
	return GET_CUR_FRAME() + 2
end

function DO_ON_FRAME( frame , fun )
	if type( frame_fun[ frame ] ) ~= "table" then frame_fun[ frame ] = {} end
	table.insert( frame_fun[ frame ] , fun )
end

local function exe_frame_fun()
	for i,v in pairs( frame_fun ) do
		if i == land_lord_frame then
			if type(v) == "table" then
				for k,f in ipairs( v ) do
					if type(f) == "function" then
						f()
					end
				end
			end
			frame_fun[i] = nil
			return
		end
	end
end

local function onLandFrame()
	land_lord_frame = land_lord_frame + 1
	exe_frame_fun()
end

scheduler.scheduleUpdateGlobal( onLandFrame )

