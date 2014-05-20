--[[

所有 socket 通信发送函数

]]
local ByteArray = require("ByteArray")

require ("PlayerInitData")

local M = {}

--[[选择服获取登陆服列表]]
function M.selectServer_getList()
	
	local socket = LuaSocket.new(SELECT_SERVER, -1)

	return true
end

--[[登陆服登陆]]
function M.loginServer_login()
	
	--userName and password
	local tempBuffer = ByteArray.new(ByteArray.ENDIAN_BIG)
	tempBuffer:writeStringUInt("abc")
	tempBuffer:writeStringUInt("abc")

	local socket = LuaSocket.new(LOGIN_SERVER, 100, 1, tempBuffer)

	return true
end

--[[登陆服获取逻辑服信息]]
function M.loginServer_getLogicSever()
	
	--userName and password
	local tempBuffer = ByteArray.new(ByteArray.ENDIAN_BIG)
	tempBuffer:writeInt(1)

	local socket = LuaSocket.new(LOGIN_SERVER, 110, 1, tempBuffer)

	return true
end

--[[逻辑服登陆]]
function M.logicServer_login()
	
	--userID and serverID
	local tempBuffer = ByteArray.new(ByteArray.ENDIAN_BIG)
	tempBuffer:writeInt(DATA_Account:get("userID"))
	tempBuffer:writeInt(1)

	local socket = LuaSocket.new(LOGIC_SERVER, 100, 1, tempBuffer)

	return true
end

--[[酒店升级]]
function M.upgradeHotel()
	
	--userID
	local tempBuffer = ByteArray.new(ByteArray.ENDIAN_BIG)
	tempBuffer:writeInt(DATA_Account:get("userID"))

	local socket = LuaSocket.new(LOGIC_SERVER, 110, 1, tempBuffer)

	return true
end

--[[房间升级]]
function M.upgradeRoom(roomIndex)
	
	--userID
	local tempBuffer = ByteArray.new(ByteArray.ENDIAN_BIG)
	tempBuffer:writeInt(DATA_Account:get("userID"))

	local room = DATA_PlayerData:getARoom(roomIndex)

	if room then
		tempBuffer:writeInt(room.roomID)
		local socket = LuaSocket.new(LOGIC_SERVER, 120, 1, tempBuffer)
		print("升级房间",room.roomID)
	else
		print("无此房间")
	end


	return true
end

return M
