-- 服务器传输数据
local playerData = {
	-- 玩家基本参数
	basic = {
		playerName = "NiDaye",
		gold = 10000,
		prestige = 100,
		energy = 30,
		diamond = 100,
		vip = 3,
		hotelLevel = 1,
		playerLevel = 10,
	},

	--时间信息
	time = {
		loginGameTime = 0,
		loginServerTime = 1400059378275,
	},
	
	-- 玩家各界面参数
	-- 酒店
	hotel = {
		level = 3,
		room = {
			{
				floorNumber = 1,
				roomNumber = 1,
				level = 1,
				furniture = {"bed1","desk1"},
			},
			{
				floorNumber = 1,
				roomNumber = 2,
				level = 2,
				furniture = {"bed2","desk2"},
			},
			{
				floorNumber = 1,
				roomNumber = 3,
				level = 2,
				furniture = {"bed1","desk1"},
			},
			{
				floorNumber = 1,
				roomNumber = 4,
				level = 1,
				furniture = {"bed2","desk2"},
			},
			{
				floorNumber = 2,
				roomNumber = 1,
				level = 1,
				furniture = {"bed1","desk2"},
			},
			{
				floorNumber = 2,
				roomNumber = 2,
				level = 1,
				furniture = {},
			},
			{
				floorNumber = 2,
				roomNumber = 3,
				level = 1,
				furniture = {},
			},
			{
				floorNumber = 2,
				roomNumber = 4,
				level = 1,
				furniture = {},
			},
		},
		board = {
			{
				boardNumber=1,
				level=1,
				totalTime=60,
				flushTime=os.clock()*1000,

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

				friendshipValue = 100,
				friendshipLevel = 3,

				skillArray = {
					--"accuracy1",
					"poison1",
					--"selfExplode1",
					--"rage1",
					--"skillBullet1",
					--"skillAttack2",
				},
				--==========================
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

				level = 12,
				experience = 1000,
				strength = 10,
				intelligence = 10,
				physique = 10,

				friendshipValue = 100,
				friendshipLevel = 3,

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

				level = 12,
				experience = 1000,
				strength = 10,
				intelligence = 10,
				physique = 10,

				friendshipValue = 60,
				friendshipLevel = 2,

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

				friendshipValue = 100,
				friendshipLevel = 3,

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
			},
		},
	},
	
	-- 任务
	task = {},
	-- 战斗相关
	military = {
		formationArray = {
			currentFormation = 1,
			{
				{1,0,0},
				{3,0,0},
				{2,0,0},
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
		{
			itemID = "10001",
			itemName = "PanTao",
			amount = 5,
		},
		{
			itemID = "10002",
			itemName = "XiGua",
			amount = 10,
		},
		{
			itemID = "10003",
			itemName = "ZhuSun",
			amount = 1,
		},
		{
			itemID = "10005",
			itemName = "Bed",
			amount = 1,
		},
		{
			itemID = "10006",
			itemName = "HuoJianQiang",
			amount = 1,
		},
		--[[
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
		]]
	},
}

print("LoadPlayerData -- Success")
return playerData