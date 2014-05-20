local furnitureModelData = import("furnitureData")
local roomModelData = import("roomData")
local Room = class("Room")

function Room:ctor(roomData)
	self.floorNumber = roomData.floorNumber
	self.roomNumber = roomData.roomNumber
	self.level = roomData.level
	self.furnitureNum = roomModelData[self.level].furnitureNum
	self.tenantID = {}
	self.occupied = false
	self.furniture = {}
	for _,v in pairs(roomData.furniture) do
		self.furniture[v] = furnitureModelData[v]
	end

	--上次结算租金的时间
	self.lastCollectRentTime = 0

	--上次计算租金的时间
	self.lastAddRentTime = PlayerManager.Basic.realTime

	--当前房间租金池
	self.rentPool = 0

	self.roomValue = 0
	self:caculateRoomValue()

	--房间每日租金
	self.roomRent = self.roomValue
end

-- execute
function Room:setTenantID(tenantID)

	self.tenantID = tenantID
	self.occupied = true
end

function Room:removeTenant()
	self.tenantID = -1 
	self.occupied = false
end

--计算房间豪华度
function Room:caculateRoomValue()
	self.roomValue = roomModelData[self.level].basicLuxury
	for _,v in pairs(self.furniture) do
		self.roomValue = self.roomValue + v.price
	end

	self.roomRent = self.roomValue

	--print("豪华度:",self.roomValue)
end

--结算房间租金池(按秒结算的方式,按天结算用不上此函数)
function Room:caculateRentPool()
	-- 公式：当前房间租金池 +=（当前时间－上次计算租金时间）＊（每日租金／游戏里一天的秒数）
	PlayerManager.Basic.updateGameTime()
	self.rentPool = self.rentPool + (PlayerManager.Basic.realTime-self.lastAddRentTime)*(self.roomRent/SECONDS_PER_DAY)
	self.lastAddRentTime = PlayerManager.Basic.realTime
	print("房间租金池", self.rentPool)
end

--收取房间租金
function Room:collectRoomRent()
	--按天结算方式
	if self.occupied then
		self:caculateRoomValue()
		return self.roomRent
	end

	return 0
	
	--按秒结算方式
	--[[self:caculateRentPool()
	local tempRentPool = self.rentPool
	self.rentPool = 0
	return tempRentPool]]--
end

function Room:upgradeRoom()
	local nextRoomModel = roomModelData[self.level+1]

	--查看是否是最高等级
	if not nextRoomModel then
		print("房间已到最高等级")
		return false
	end

	--检查条件是否满足
	if PlayerManager.Hotel.level < nextRoomModel.upgradeLevelNeeded then
		print("酒店等级不够")
		return false
	end

	--检查资源是否足够
	if PlayerManager.Basic.gold < nextRoomModel.upgradeGoldNeeded then
		print("金币不够")
		return false
	end

	--扣除资源
	PlayerManager.Basic.gold = PlayerManager.Basic.gold-nextRoomModel.upgradeGoldNeeded

	self.level = self.level+1

	self:caculateRoomValue()

	--更新房间信息
	self.furnitureNum = roomModelData[self.level].furnitureNum

	return true
end

 
function Room:checkOut(addByCount,addByRatio)
	return PlayerManager.Hotel.tenantArray[self.tenantID]:checkOut(self.roomValue,addByCount,addByRatio)
end

-- get
function Room:getTenantID()
	return self.tenantID
end

function Room:getOccupied()
	return self.occupied
end

print("CreatRoomClass -- Success")
return Room