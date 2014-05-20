-- 存储玩家数据，初始化于服务器

DATA_PlayerData = {}

local _Data = {
	-- 玩家基本参数
	basic = {
		playerID = 0,				--玩家ID
		playerName = "",			--客栈名称
		playerLevel = 0,			--玩家等级
		prestige = 0,				--当前威望
		vip = 0,					--VIP等级
		totalDiamond = 0,			--累计充值金额
		diamond = 0,				--元宝数量
		gold = 0,					--游戏币数量
		energy = 0,					--剩余体力
		storageCapacity = 20,		--背包容量
		userID = 0,					--userID
		lastTenantRefreshTime = 0,	--租客时间戳
		serverID = 0,				--所在服务器编号
		playerLoginTime = 0,		--登录时间戳
		
	},

	--时间信息
	time = {
		loginGameTime = 0,
		loginServerTime = os.time()-3600,
	},
	
	-- 玩家各界面参数
	-- 酒店
	hotel = {
		hotelID = 0,				--客栈ID
		level = 0, 					--客栈级别
		userID = 0,					--角色ID
		maxWaitTenantNum = 3,		--最大租客等待数量
		room = {},					--房间
		furnishing = {},			--家具
		tenant = {},				--租客
		waitTenant = {},			--等待租客

		--本地数据填充
		board = {
			{
				boardNumber=1,
				level=1,
				totalTime=60,
				flushTime=os.time(),

			},
			{
				boardNumber=2,
				level=2,
				totalTime=20,
				flushTime=os.time()-10,
			}
		},
		tenant = {
			{
				roleID = "TieShanGongZhu",
				itemID = "10000",
				floorNumber = 1,
				roomNumber = 1,
				stayLength = 3,
				stayedLength = 1,
				satisfaction = 0,
				task = {},

				level = 10,
				experience = 1000,
				strength = 10,
				intelligence = 10,
				physique = 10,

				skillArray = {
					"accuracy1",
					"poison1",
					--"selfExplode1",
					--"rage1",
					--"skillBullet1",
					--"skillAttack2",
				},
				--==========================
				roleLevel=10,
				region="花果山",
				roleTitle="愤怒的",
				name = "铁扇公主",
				roleType="normal",
				description={	
					"暂时没有任务了",
					"我要睡觉"
				},
				productive=30,
				rewards={},

			},
			{
				roleID = "luoluo2",
				itemID = "10001",
				floorNumber = 1,
				roomNumber = 2,
				stayLength = 3,
				stayedLength = 2,
				satisfaction = 80,
				task = {},

				level = 10,
				experience = 1000,
				strength = 10,
				intelligence = 10,
				physique = 10,

				skillArray = {
					"vampire1",
					--"dodge1",
					"critical1",
					--"skillAttack2",
					--"banyuezhan",
					"skillAttack3",
				},
				--=================
				name = "老鼠精",
				description={
					"出去巡山去了",		
					"我这里没有任务",
					"好开心"
				},
				productive=30,
				rewards={},
			},
			{
				roleID = "QingFeng",
				itemID = "10002",
				floorNumber = 1,
				roomNumber = 3,
				stayLength = 3,
				stayedLength = 2,
				satisfaction = 80,
				task = {},

				level = 10,
				experience = 1000,
				strength = 10,
				intelligence = 10,
				physique = 10,

				skillArray = {
					"critical1",
					"WanJianJue",
				},
				--=================
				name = "清风",
				description={
					"困死了，睡觉",		
					"我这里没有任务",
					"好开心"
				},
				productive=30,
				rewards={},
			},
			--[[{
				roleID = "Honghaier",
				itemID = "10003",
				floorNumber = 1,
				roomNumber = 4,
				stayLength = 3,
				stayedLength = 2,
				satisfaction = 80,
				task = {},

				level = 10,
				experience = 1000,
				strength = 10,
				intelligence = 10,
				physique = 10,

				skillArray = {
					"critical1",
					"vampire1",
					"skillAttack2",
				},
				--=================
				name = "红孩儿",
				description={	
					"我这里没有任务",
					"好开心"
				},
				productive=30,
				rewards={},
			},]]--
		},

		-- 任务

		waitTenant = {
			--
			{
				roleID = "Honghaier",
				itemID = "10004",
				stayLength = 3,
				stayedLength = 2,
				satisfaction = 80,
				task = {},

				level = 10,
				experience = 1000,
				strength = 10,
				intelligence = 10,
				physique = 10,

				skillArray = {
					"critical1",
					"vampire1",
					"skillAttack2",
				},
				--=================
				name = "牛魔王",
				description={	
					"我这里没有任务",
					"好开心"
				},
				productive=30,
				rewards={},
			},
		},
	},
	
	--依然本地数据填充
	-- 任务
	task = {},
	-- 战斗相关
	military = {
		formationArray = {
			currentFormation = 1,
			{
				{2,0,0},
				{1,0,0},
				{3,0,0},
			},
			{
				{1,0,0},
				{2,0,0},
				{3,0,0},
			},
		},
	},

	tavern = {},

	world = {
		aoLaiGuo = {
			display = true,
			unlocked = true,
			prestige = 50,
			sector = {
				aoLaiGuo1 = {
					display = true,
					unlocked = true,
					task = "task1",
				},
				aoLaiGuo2 = {
					display = true,
					unlocked = true,
					task = "task2",
				},
			},
			
			tenaut = {true,true},
		},
		huoYanShan = {
			display = true,
			unlocked = true,
			prestige = 50,
			sector = {
				huoYanShan1 = {
					display = true,
					unlocked = false,
					task = "",
				},
			},
			tenaut = {true,true},
		},
	},
	storage = {
		weaponMaxStorage = 20,
		resourceMaxStorage = 100,
		weapon = {
			{
				itemID = "HuoJianQiang",
				level = 1
			},
			{
				itemID = "DingShuiZhu",
				level = 2
			},
		},
		resource = {
			PanTao = {
				level1 = {amount = 5},
			},
			XiGua = {
				level1 = {amount = 10},
			},
			ZhuSun={
				level1 = {amount = 1},

			}
		},
	},
}

function DATA_PlayerData:init()
	--
end

--初始化
function DATA_PlayerData:setPlayer(data)
	print("获取初始化信息")

	local act = data:readInt()
    local subAct = data:readInt()
	
	--设置玩家基本信息
	_Data.basic.playerID = data:readInt()
	_Data.basic.playerName = data:readStringUInt()
	_Data.basic.playerLevel = data:readInt()
	_Data.basic.prestige = data:readInt()
	_Data.basic.vip = data:readInt()
	_Data.basic.totalDiamond = data:readInt()
	_Data.basic.diamond = data:readInt()
	_Data.basic.gold = data:readInt()
	_Data.basic.energy = data:readInt()
	_Data.basic.storageCapacity = data:readInt()
	_Data.basic.userID = data:readInt()
	_Data.basic.lastTenantRefreshTime = data:readLong()
	_Data.basic.serverID = data:readInt()
	_Data.basic.playerLoginTime = data:readLong()

	--客栈信息
	_Data.hotel.hotelID = data:readInt()
	_Data.hotel.level = data:readInt()
	_Data.hotel.userID = data:readInt()
	_Data.hotel.maxWaitTenantNum = data:readInt()

	--房间
	local roomNum = data:readInt()

	print("房间数", roomNum)

	for i=1,roomNum do
		local room = {}
		room.roomID = data:readInt()
		room.tenantID = data:readInt()
		room.tavernID = data:readInt()
		room.roomIndex = data:readInt()+1
		room.roomNumber = room.roomIndex % 4
		if room.roomNumber == 0 then
			room.roomNumber = 4
		end
		room.floorNumber = (room.roomIndex-room.roomNumber)/4 + 1
		room.level = data:readInt()
		room.furniture = {}

		_Data.hotel.room[i] = room
	end

	--家具
	local furnishingNum = data:readInt()

	print("家具数", furnishingNum)

	for i=1,furnishingNum do
		local furnishing = {}
		furnishing.furnishingID = data:readInt()
		furnishing.position = data:readInt()
		furnishing.modelDataID = data:readInt()
		furnishing.roomID = data:readInt()
		furnishing.tavernID = data:readInt()
		furnishing.playerID = data:readInt()
	end

	--租客
	local tenantNum = data:readInt()

	print("租客人数", tenantNum)

	for i=1,tenantNum do
		local _tenant = {}
		_tenant.tenantID = data:readInt()
		_tenant.name = data:readStringUInt()
		_tenant.roleModelID = data:readStringUInt()
		_tenant.satisfaction = data:readInt()
		_tenant.userID = data:readInt()
		_tenant.stayLength = data:readInt()
		_tenant.payment = data:readInt()
		_tenant.itemID = data:readStringUInt()
		_tenant.checkInTime = data:readLong()
		_tenant.roomID = data:readInt()

		--租客
		if _tenant.roomID ~= 0 then
			_Data.hotel.tenant[#_Data.hotel.tenant+1] = _tenant
		end		

		--等待租客
		if _tenant.roomID == 0 then
			_Data.hotel.waitTenant[#_Data.hotel.waitTenant+1] = _tenant
		end
	end

	local fighterNum = data:readInt()

	print("打手人数", fighterNum)

	for i=1,fighterNum do
		local _fighter = {}
		_fighter.fighterID = data:readInt()
		_fighter.name = data:readStringUInt()
		_fighter.stars = data:readInt()
		_fighter.quality = data:readInt()
		_fighter.roleModelID = data:readStringUInt()
		_fighter.currentExp = data:readInt()
		_fighter.level = data:readInt()
		_fighter.friendship = data:readInt()
		_fighter.friendshipLevel = data:readInt()
		_fighter.breakthroughLevel = data:readInt()
		_fighter.basicStrength = data:readInt()
		_fighter.additionStrength = data:readInt()
		_fighter.basicIntelligence = data:readInt()
		_fighter.additionIntelligence = data:readInt()
		_fighter.basicPhysique = data:readInt()
		_fighter.additionPhysique = data:readInt()
		_fighter.basicPhysicalAttack = data:readInt()
		_fighter.basicPhysicalDefense = data:readInt()
		_fighter.basicMagicAttack = data:readInt()
		_fighter.basicMagicDefense = data:readInt()
		_fighter.basicHP = data:readInt()
		_fighter.basicHit = data:readInt()
		_fighter.basicDodge = data:readInt()
		_fighter.basicCrack = data:readInt()
		_fighter.basicBlock = data:readInt()
		_fighter.basicCrit = data:readInt()
		_fighter.basicToughness = data:readInt()
		_fighter.initSpeed = data:readFloat()
		_fighter.initSkillID = data:readInt()
		--_fighter.talent1 = data:readInt()
		--_fighter.talent2 = data:readInt()
		--_fighter.talent3 = data:readInt()
		--_fighter.talent4 = data:readInt()
		_fighter.helmetID = data:readInt()
		_fighter.armorID = data:readInt()
		_fighter.weaponID = data:readInt()
		_fighter.accessoriesID = data:readInt()
		_fighter.ownerID = data:readInt()

		--_Data.military.fighter[#_Data.military.fighter+1] = _fighter

	end

	dump(_Data)
	
end

--酒店升级
function DATA_PlayerData:upgradeHotel(data)
	print("酒店升级")

	local act = data:readInt()
    local subAct = data:readInt()

    --酒店当前等级
	_Data.hotel.hotelLevel = data:readInt()

	--酒店最大租客等待数量
	_Data.hotel.maxWaitTenantNum = data:readInt()

	--新增房间
	local roomNum = data:readInt()

	print("新增房间数", roomNum)

	for i=1,roomNum do
		local room = {}
		local roomID = data:readInt()
		local roomPosition = data:readInt()
		roomPosition = roomPosition+1
		print(roomPosition)
	end

	dump(_Data.hotel)

end

--房间升级
function DATA_PlayerData:upgradeRoom(data)
	print("房间升级")

	local act = data:readInt()
    local subAct = data:readInt()

    print("房间升级成功")

end

--获取房间信息
function DATA_PlayerData:getRoom()
	return clone(_Data.hotel.room)
end

--获取一个房间信息
function DATA_PlayerData:getARoom(roomIndex)
	if _Data.hotel.room == nil then
		return nil
	end

	if roomIndex <= #_Data.hotel.room then
		return clone(_Data.hotel.room[roomIndex])
	else
		return nil
	end
end

--获取玩家信息
function DATA_PlayerData:getPlayer()
	
	return _Data

end

print("LoadPlayerData -- Success")
return DATA_PlayerData