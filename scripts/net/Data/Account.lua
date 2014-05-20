--[[

帐户数据

]]


DATA_Account = {}


-- 私有变量
local login_IP = {}
local login_Port = {}

local logic_IP = {}
local logic_Port = {}

local userID = {}
local serverList = {}

local logicServerList = {}

function DATA_Account:init()
	logic_IP = {}
	logic_Port = {}

	login_IP = {}
	login_Port = {}

	userID = {}
	serverList = {}

	logicServerList = {}
end

function DATA_Account:setLoginIP(data)
	
	--act：2 获取IP port  3：拒绝登陆
    local act = data:readInt()
	login_IP = data:readStringUInt()
	login_Port = data:readInt()
	data:setPos(1)

end

function DATA_Account:setLogicIP(data)
	
	--act：2 获取IP port  3：拒绝登陆
    local act = data:readInt()
	logic_IP = data:readStringUInt()
	logic_Port = data:readInt()
	data:setPos(1)

end

function DATA_Account:setUserIDAndAServerList(data)
	
	--act：2 获取IP port  3：拒绝登陆
    local act = data:readInt()
    local subAct = data:readInt()
	userID = data:readInt()

	local serverNum = data:readInt()

	for i=1, serverNum do
		local serverIndex = data:readInt()
		local serverName = data:readStringUInt()

		local server = {
			index = serverIndex,
			name = serverName,
		}

		serverList[#serverList+1] = server

		print("区信息：", serverIndex, serverName)
	end

	data:setPos(1)

end

function DATA_Account:setLogicServerList(data)
	
	--act：2 获取IP port  3：拒绝登陆
    local act = data:readInt()
    local subAct = data:readInt()

	local serverNum = data:readInt()

	for i=1, serverNum do
		local serverIP = data:readStringUInt()
		local serverPort = data:readInt()

		local logicServer = {
			IP = serverIP,
			port = serverPort,
		}

		logicServerList[#logicServerList+1] = logicServer

		print("逻辑服：", serverIP, serverPort)
	end

	data:setPos(1)

end

function DATA_Account:get(key)

	if key == "logic_IP" then
		return logic_IP
	end

	if key == "logic_Port" then
		return logic_Port
	end

	if key == "login_IP" then
		return login_IP
	end

	if key == "login_Port" then
		return login_Port
	end

	if key == "userID" then
		return userID
	end

	if key == "serverList" then
		return serverList
	end

	if key == "logicServerList" then
		return logicServerList
	end
end

return DATA_Account