--[[

LuaSocket 通信接口

]]
LuaSocket = class()


local socketActions = require("socketActions")
local commonActions = require("commonActions")

local cc = {}

cc.utils 				= require("initUtils")
cc.net 					= require("initNet")

local ByteArray = require("ByteArray")

-- 打开一个新链接
function LuaSocket:ctor(serverFlag, act, subAct, data)

	self.isConnected = false
	self._act = act
	self._subAct = subAct
	self._data = data

	self.socket = cc.net.SocketTCP.new()

	self.socket:addEventListener(cc.net.SocketTCP.EVENT_CONNECTED, handler(self, self.onStatus))
	self.socket:addEventListener(cc.net.SocketTCP.EVENT_CLOSE, handler(self,self.onStatus))
	self.socket:addEventListener(cc.net.SocketTCP.EVENT_CLOSED, handler(self,self.onStatus))
	self.socket:addEventListener(cc.net.SocketTCP.EVENT_CONNECT_FAILURE, handler(self,self.onStatus))
	self.socket:addEventListener(cc.net.SocketTCP.EVENT_DATA, handler(self,self.onData))

	self:reconnect(serverFlag)
end

--重连接
function LuaSocket:reconnect(serverFlag)

	self.serverFlag = serverFlag

	local _IP = {}
	local _Port = {}

	--如果是逻辑服
	if serverFlag == LOGIC_SERVER then
		--检查逻辑服IP和Port数据
		local logicServerList = DATA_Account:get("logicServerList")

		--_IP = DATA_Account:get("logic_IP")
		--_Port = DATA_Account:get("logic_Port")

		_IP = logicServerList[1].IP
		_Port = logicServerList[1].port

		print("当前逻辑服：", _IP, _Port)

		if type(_IP) ~= "string" or type(_Port) ~= "number" then
			_IP = SELECT_SERVER_IP
			_Port = SELECT_SERVER_PORT
			self.serverFlag = SELECT_SERVER
		else
			print("--logicSever:IP and Port ok!--", _IP, _Port)
		end

	elseif serverFlag == LOGIN_SERVER then
		--检查登陆服IP和Port数据
		_IP = DATA_Account:get("login_IP")
		_Port = DATA_Account:get("login_Port")

		if type(_IP) ~= "string" or type(_Port) ~= "number" then
			_IP = SELECT_SERVER_IP
			_Port = SELECT_SERVER_PORT
			self.serverFlag = SELECT_SERVER
		else
			print("--loginSever:IP and Port ok:", _IP, _Port)
		end

		--return

	elseif serverFlag == SELECT_SERVER then
		_IP = SELECT_SERVER_IP
		_Port = SELECT_SERVER_PORT
		self.serverFlag = SELECT_SERVER
	end

	self.socket:connect(_IP, _Port, false)
end

--前端主动发送数据
function LuaSocket:call(act , subAct , data)

	local func = act .. "_" .. subAct
	local success = false

	--打包数据
	local tempBuffer = ByteArray.new(ByteArray.ENDIAN_BIG)
	tempBuffer:writeInt(act)
	tempBuffer:writeInt(subAct)
	
	tempBuffer:writeBytes(data)

	local buffer = ByteArray.new(ByteArray.ENDIAN_BIG)
	buffer:writeInt(tempBuffer:getLen())
	buffer:writeBytes(tempBuffer)

	print("send packet: ", buffer:toString(16))

	self.socket:send(buffer:getPack())

	return true
end

--socket状态改变监听器
function LuaSocket:onStatus(__event)
	--print("onState")
	print("socket status:", __event.name)
	if __event.name == "SOCKET_TCP_CONNECTED" then
		self.isConnected = true

		--连接成功回调
		local func = self.serverFlag .. "_" .. "connected"
		socketActions[func](1, self)

		--如果要发请求
		if self._act ~= -1 then
			self:call(self._act, self._subAct, self._data)
		end
	else
		self.isConnected = false

		self.socket = nil
		self = nil
	end
end

--socket数据接受监听器
function LuaSocket:onData(__event)
	print("receive message")

	print("socket receive raw data:", cc.utils.ByteArray.toString(__event.data, 16))

	-- 去掉 loading
	--if loading ~= nil then loading:remove() end 		

	local revBuffer = ByteArray.new(ByteArray.ENDIAN_BIG)
	
	revBuffer:setPos(revBuffer:getLen()+1)
	revBuffer:writeBuf(__event.data)
	revBuffer:setPos(1)

	local dataLen = revBuffer:getLen()
	local dataPosition = 1
		

	--处理粘包
	local dataArray = {}

	while dataPosition < dataLen do
			
		revBuffer:setPos(dataPosition)
			
		local tempDataLen = revBuffer:readInt()

		print("包长度",tempDataLen)

		dataPosition = dataPosition+4

		local tempBuffer = ByteArray.new(ByteArray.ENDIAN_BIG)
	
		tempBuffer:setPos(1)
		tempBuffer:writeBytes(revBuffer, dataPosition, tempDataLen)
		tempBuffer:setPos(1)

		dataPosition = dataPosition+tempDataLen

		dataArray[#dataArray+1] = tempBuffer

	end

	--一个一个包处理
	for i,v in pairs(dataArray) do
        
        print("socket receive part data:", cc.utils.ByteArray.toString(v, 16))    

        --act：获取动作
        local act = v:readInt()
        local subAct = {}
        if act >= 100 then
        	subAct = v:readInt()
        end
        v:setPos(1)
		
		if act < 100 then
			local func = self.serverFlag .. "_" .. act

			--存储数据包
			commonActions.saveCommonData(func, v)
			--执行 socketActions 回调
			v:setPos(1)
			if type(socketActions[func]) == "function" then
				local success , data = socketActions[func](2 , self, v)
			else
				print("无此回调:", func)
			end
		end

		if act >= 100 then
			local func = self.serverFlag .. "_" .. act .. "_" .. subAct

			--存储数据包
			commonActions.saveCommonData(func, v)
			--执行 socketActions 回调
			v:setPos(1)
			if type(socketActions[func]) == "function" then
				local success , data = socketActions[func](2 , self, v)
			else
				print("无此回调:", func)
			end
		end
    end
end
