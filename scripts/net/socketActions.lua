--[[

所有 socket 通信发送前以及回调

]]
local ByteArray = require("ByteArray")

local socketRequests = require("socketRequests")

local M = {}

--[[连接选择服成功]]
function M.selectServer_connected( type , socket , data )
	if type == 1 then
		print("选择服连接成功")
	elseif type == 2 then
		--nothing
	end

	return true , data
end

--[[连接登陆服成功]]
function M.loginServer_connected( type , socket , data )
	if type == 1 then
		print("登陆服连接成功")

	elseif type == 2 then
		--nothing
	end

	return true , data
end

--[[连接逻辑服成功]]
function M.logicServer_connected( type , socket , data )
	if type == 1 then
		print("逻辑服连接成功")

	elseif type == 2 then
		--nothing
	end

	return true , data
end

--[[选择服返回登陆服数据]]
function M.selectServer_2( type , socket , data )
	if type == 1 then
	elseif type == 2 then
		print("已获取登陆服IP,Port")

		socketRequests["loginServer_login"]()
	end

	return true , data
end

--[[登陆服返回选取信息]]
function M.loginServer_100_1( type , socket , data )
	if type == 1 then
	elseif type == 2 then
		print("已获取选区信息")
		
		socketRequests["loginServer_getLogicSever"]()
	end

	return true , data
end

--[[登陆服返回选取信息]]
function M.loginServer_110_1( type , socket , data )
	if type == 1 then
	elseif type == 2 then
		print("已获取逻辑服信息，逐个连接")
		
		socketRequests["logicServer_login"]()
	end

	return true , data
end

--[[登陆服返回逻辑服数据]]
function M.loginServer_2( type , socket , data )
	if type == 1 then
	elseif type == 2 then
		print("已获取逻辑服IP,Port")
		
		socketRequests["logicServer_login"]()
	end

	return true , data
end

--[[逻辑服登录成功]]
function M.logicServer_100_1( type , socket , data )
	if type == 1 then
	elseif type == 2 then
		print("逻辑服登录成功，玩家信息初始化完成")
		
		CCNotificationCenter:sharedNotificationCenter():postNotification(LOGIN_DONE,nil)
	end

	return true , data
end

return M
