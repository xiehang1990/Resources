-- XML数据
local itemModelData = {
	-- 武器
	HuoJianQiang = {
		serialNumber = 1001,
		type = "weapon",
		pile = false,
		description = "",
	},
	-- 家具
	Bed = {
		serialNumber = 2001,
		type = "furniture",
		pile = false,
		description = "",
	},
	-- 消耗品
	PanTao = {
		serialNumber = 3001,
		type = "material",
		pile = true,
		description = "",
	},
	ZhuSun = {
		serialNumber = 3002,
		type = "material",
		pile = true,
		description = "",
	},
	XiGua = {
		serialNumber = 3003,
		type = "material",
		pile = true,
		description = "",
	},
}

print("LoadItemModelData -- Success")
return itemModelData
