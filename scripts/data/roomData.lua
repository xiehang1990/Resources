-- XML数据
local roomData = {
	--====一级房间====
	{
		level = 1,
		basicLuxury = 50,
		upgradeGoldNeeded = 0,
		upgradeLevelNeeded = 0,
		furnitureNum = 3,
	},
	--====二级房间====
	{
		level = 2,
		basicLuxury = 100,
		upgradeGoldNeeded = 500,
		upgradeLevelNeeded = 1,
		furnitureNum = 4,
	},
	--====三级房间====
	{
		level = 3,
		basicLuxury = 200,
		upgradeGoldNeeded = 1500,
		upgradeLevelNeeded = 2,
		furnitureNum = 5,
	},
	--====四级房间====
	{
		level = 4,
		basicLuxury = 500,
		upgradeGoldNeeded = 2500,
		upgradeLevelNeeded = 3,
		furnitureNum = 6,
	},
	--====五级房间====
	{
		level = 5,
		basicLuxury = 1000,
		upgradeGoldNeeded = 4000,
		upgradeLevelNeeded = 4,
		furnitureNum = 7,
	},
	--====六级酒店====
	{
		level = 6,
		basicLuxury = 2000,
		upgradeGoldNeeded = 9000,
		upgradeLevelNeeded = 5,
		furnitureNum = 8,
	},
}

print("LoadRoomData -- Success")
return roomData