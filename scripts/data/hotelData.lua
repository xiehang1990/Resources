-- XML数据
local hotelData = {
	--====一级酒店====
	{
		level = 1,
		floorNum = 1,
		roomNum = 4,
		maxWaitTenantNum = 2,
		upgradeGoldNeeded = 1000,
		upgradeLevelNeeded = 2,

	},
	--====二级酒店====
	{
		level = 2,
		floorNum = 1,
		roomNum = 4,
		maxWaitTenantNum = 3,
		upgradeGoldNeeded = 2000,
		upgradeLevelNeeded = 3,

	},
	--====三级酒店====
	{
		level = 3,
		floorNum = 2,
		roomNum = 8,
		maxWaitTenantNum = 3,
		upgradeGoldNeeded = 5000,
		upgradeLevelNeeded = 5,

	},
	--====四级酒店====
	{
		level = 4,
		floorNum = 2,
		roomNum = 8,
		maxWaitTenantNum = 4,
		upgradeGoldNeeded = 10000,
		upgradeLevelNeeded = 10,

	},
	--====五级酒店====
	{
		level = 5,
		floorNum = 3,
		roomNum = 12,
		maxWaitTenantNum = 5,
		upgradeGoldNeeded = 25000,
		upgradeLevelNeeded = 20,

	},
	--====六级酒店====
	{
		level = 6,
		floorNum = 3,
		roomNum = 12,
		maxWaitTenantNum = 5,
		upgradeGoldNeeded = 50000,
		upgradeLevelNeeded = 25,
	},
	--====七级酒店====
	{
		level = 7,
		floorNum = 3,
		roomNum = 12,
		maxWaitTenantNum = 5,
		upgradeGoldNeeded = 50000,
		upgradeLevelNeeded = 25,
	},
	--====八级酒店====
	{
		level = 8,
		floorNum = 3,
		roomNum = 12,
		maxWaitTenantNum = 5,
		upgradeGoldNeeded = 50000,
		upgradeLevelNeeded = 25,
	},
	--====九级酒店====
	{
		level = 9,
		floorNum = 3,
		roomNum = 12,
		maxWaitTenantNum = 5,
		upgradeGoldNeeded = 50000,
		upgradeLevelNeeded = 25,
	},

	--[[floorNum      = {1,1,2,2,3,3,3,3,3},
	hotelMaxLevel = 9,
	roomMaxLevel  = {1,2,2,3,3,4,4,5,5},
	furnitureMaxLevel = {
		bed    = {1,1,1,2,2,2,3,3,3,3},
		window = {1,1,1,1,1,2,2,2,2,2},
	},]]--
}

print("LoadHotelData -- Success")
return hotelData