local Room = import("Room")
local Tenant = import("Tenant")
local Board=import("Board")
local Weather=import("Weather")
local speciesData=import("speciesData")
local taskData=import("taskData")
local Species=import("Species")
local hotelModelData = import("hotelData")
local Hotel = {}

function Hotel.init(hotelData)
	Hotel.roomArray = {}
	Hotel.weather=Weather.new()
	Hotel.tenantWaitArray={}
	Hotel.tenantArray={}
	Hotel.BoardArray={}
	Hotel.tenantTaskArray={}
	Hotel.tenantLeftArray={}
	Hotel.species=Species.new(speciesData)
	Hotel.level = hotelData.level
	Hotel.floorNum = hotelModelData[hotelData.level].floorNum

	for _,v in pairs(hotelData.room) do
		-- 如果当前房间楼层不存在，则新建当前房间楼层
		if not(Hotel.roomArray[v.floorNumber]) then Hotel.roomArray[v.floorNumber] = {} end
		Hotel.roomArray[v.floorNumber][v.roomNumber] = Room.new(v)
	end

	for _,v in pairs(hotelData.board) do
		Hotel.BoardArray[v.boardNumber]=Board.new(v)
	end
	Hotel.initTenant(hotelData.tenant)
	Hotel.initWaitTenant(clone(hotelData.waitTenant))
	Hotel.addTask(taskData)
	
--==============================================================================================
end
--tenant各种array初始化===================================================================================

function Hotel.initTenant(tenantData)
	for k,v in pairs(tenantData) do
		Hotel.tenantArray[v.itemID]=Tenant.new(v)
		Hotel.addLiveTenant(v.itemID,v.floorNumber,v.roomNumber)

	end
end 

function Hotel.addTask(taskDataArray)
	for k,v in pairs(taskDataArray) do
		Hotel.tenantArray[v.tenantID]:addTask(v)
	end
end 


function Hotel.initWaitTenant(tenantDataArray)
	--dump(Hotel.tenantWaitArray)
	for k,v in pairs(tenantDataArray) do
		Hotel.tenantWaitArray[v.itemID]=Tenant.new(v)
	end
end

function Hotel.addWaitTenant(tenantData)

	Hotel.tenantWaitArray[tenantData.itemID]=Tenant.new(tenantData)
end 

function Hotel.getWaitTenantArray()
	return Hotel.tenantWaitArray
end 

--按照ID获取一个等待租客
function Hotel.getAWaitTenant(itemID)
	for k,v in pairs(Hotel.tenantWaitArray) do
		if v.itemID == itemID then
			return v
		end
	end

	return nil
end

-- 租客结账(该版本此函数无用，改为collectAllRoomRent)
function Hotel.checkOut(floorNumber,roomNumber)
	local addByCount = 10
	local addByRatio = 0.5
	if Hotel.roomArray[floorNumber][roomNumber] and Hotel.roomArray[floorNumber][roomNumber]:getOccupied() then
		local rent = Hotel.roomArray[floorNumber][roomNumber]:checkOut(addByCount,addByRatio)
		Hotel.removeLiveTenant(floorNumber,roomNumber)
		return rent
	end
end

function Hotel.removeLiveTenant(floorNumber,roomNumber)
	if Hotel.roomArray[floorNumber][roomNumber] and Hotel.roomArray[floorNumber][roomNumber]:getOccupied() then
		local roleID=Hotel.roomArray[floorNumber][roomNumber].tenantID
		
		Hotel.tenantArray[roleID]=nil
		Hotel.roomArray[floorNumber][roomNumber]:removeTenant()
	end 
end


--================================================================================================下面是内部函数
--添加入住租客
function Hotel.addLiveTenant(tenantID,floorNumber,roomNumber)
	if Hotel.roomArray[floorNumber][roomNumber] and not(Hotel.roomArray[floorNumber][roomNumber]:getOccupied()) then
		Hotel.roomArray[floorNumber][roomNumber]:setTenantID(tenantID)
		
	end
end
function Hotel.getTenantFromData(tenantData)
	local tenant=Tenant.new(tenantData)
	return tenant 
end 




--function Hotel.addBoardTenant(tenant,index)
	
--	Hotel.BoardArray[index]:addTenant(tenant)
--end

function Hotel.addTaskTenant(tenant,index)
	
	Hotel.tenantTaskArray[index]=tenant 
end

function Hotel.addLeftTenant(tenant)
	Hotel.tenantLeftArray[#Hotel.tenantLeftArray+1]=tenant 
end 
--=======================================================================================================remove
function Hotel.removeWaitTenant(index)
	-- body
	Hotel.tenantWaitArray[index]=nil 
end
function Hotel.removeBoardTenant(index)
	Hotel.BoardArray[index]:removeTenant()
end
function Hotel.removeLeftTenant(index)
	Hotel.tenantLeftArray[index]=nil
end
--=======================================================================================================
function Hotel.addWaitTenantToLive(index,floorNumber,roomNumber)
	Hotel.addLiveTenant(Hotel.tenantWaitArray[index],floorNumber,roomNumber)
	Hotel.removeWaitTenant(index)
end 
function Hotel.addBoardTenantToLive(index,floorNumber,roomNumber)
	Hotel.addLiveTenant(Hotel.BoardArray[index]:getTenant(),floorNumber,roomNumber)
	Hotel.removeBoardTenant(index)
end 

--经济操作==========================================================================================
--入住
function Hotel.addLiveFromWait(itemID,floorNumber,roomNumber)
	if Hotel.roomArray[floorNumber][roomNumber] and not(Hotel.roomArray[floorNumber][roomNumber]:getOccupied()) then
		Hotel.tenantArray[itemID]=Hotel.tenantWaitArray[itemID]
		Hotel.tenantWaitArray[itemID]=nil
		Hotel.addLiveTenant(itemID,floorNumber,roomNumber)
		
	end
end 

--收租
function Hotel.collectAllRoomRent()
	local allRent = 0

	for i = 1, Hotel.floorNum do
        for j = 1, 4 do
            allRent = allRent + Hotel.roomArray[i][j]:collectRoomRent()
        end
    end

    print("当日房租", allRent)
    return allRent
end


--=========================================================================================================

-- 获取房间是否空
function Hotel.getRoomOccupied(floorNumber,roomNumber)
	return Hotel.roomArray[floorNumber][roomNumber] and Hotel.roomArray[floorNumber][roomNumber]:getOccupied()
end

-- 获取某个房间
function Hotel.getRoom(floorNumber,roomNumber)
	if Hotel.roomArray[floorNumber] then
		return Hotel.roomArray[floorNumber][roomNumber]
	end

	return nil
end

-- 通过房间号获取房间租客
function Hotel.getTenantByRoom(floorNumber,roomNumber)
	return Hotel.roomArray[floorNumber][roomNumber] and Hotel.tenantArray[Hotel.roomArray[floorNumber][roomNumber].tenantID]
end

-- 获得租客数组
function Hotel.getTenantLivingArray()
	return Hotel.tenantLivingArray
end


-- 升级酒店
function Hotel.upgradeHotel()
	local hotelModel = hotelModelData[Hotel.level+1]

	if not hotelModel then
		print("酒店已到最大等级")
		return false
	end

	--检查条件是否满足
	if PlayerManager.Basic.playerLevel < hotelModel.upgradeLevelNeeded then
		print("等级不够")
		return false
	end

	--检查资源是否足够
	if PlayerManager.Basic.gold < hotelModel.upgradeGoldNeeded then
		print("金币不够")
		return false
	end

	--扣除资源
	PlayerManager.Basic.gold = PlayerManager.Basic.gold-hotelModel.upgradeGoldNeeded


	Hotel.level = Hotel.level+1
	Hotel.floorNum = hotelModel.floorNum

	--新建楼层
	if not(Hotel.roomArray[Hotel.floorNum]) then
		Hotel.roomArray[Hotel.floorNum] = {} 
		for i=1,4 do
			local room = {
				floorNumber = Hotel.floorNum,
				roomNumber = i,
				level = 1,
				furniture = {},
				}
			Hotel.roomArray[Hotel.floorNum][i] = Room.new(room)
		end
	end

	return true
end
-- 升级房间
function Hotel.upgradeRoom(floorNumber,roomNumber)
	-- body
end
-- 房间家具升级
function Hotel.upgradeFurniture()
	-- body
end
-- 改变房间家具
function Hotel.changeFurniture()
	-- body
end

-- 添加租客
function Hotel.addTenant(tenant,floorNumber,roomNumber)
	if Hotel.roomArray[floorNumber][roomNumber] and not(Hotel.roomArray[floorNumber][roomNumber]:getOccupied()) then
		Hotel.tenantID = Hotel.tenantID + 1
		tenant:setTenantID(Hotel.tenantID)
		Hotel.tenantLivingArray[Hotel.tenantID] = tenant
		Hotel.tenantLivingArray[Hotel.tenantID]:setRoom(Hotel.roomArray[floorNumber][roomNumber])
		Hotel.roomArray[floorNumber][roomNumber]:setTenant(Hotel.tenantLivingArray[Hotel.tenantID])
	end
end

-- 移除租客
function Hotel.removeTenant(floorNumber,roomNumber)
	if Hotel.roomArray[floorNumber][roomNumber] and Hotel.roomArray[floorNumber][roomNumber]:getOccupied() then
		
	end
end



print("CreatHotelClass -- Success")
return Hotel