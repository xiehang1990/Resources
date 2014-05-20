local ConvertManager = {
	csv = {},
	dataFile = {},
}
--require("CSV2Lua")
--require("convertRoleModelData")

local init_encode = package.loadlib("encode.dll","luaopen_encode")


--ConvertManager.csv.roleModelData = io.open("./scripts/app/convert/roleModelData.csv","r")
--ConvertManager.dataFile.roleModelData = io.open("./scripts/app/battle/data/roleModelData.lua","w")
--require("convertRoleModelData")

function ConvertManager.run()
	if init_encode then
    	init_encode()
		print("编码转换模块初始化成功")
	else
		print("读取字符转换模块失败！")
	end
	--ConvertRoleModelData()
	--ConvertManager.csv.roleModelData:close()
	--ConvertManager.dataFile.roleModelData:close()
end

ConvertManager.run()