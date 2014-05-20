	
local DataManager = {
	--user = "bozi",
	user = "xigua",
	battleInitData = {},
	playerData = {},
	XMLData = {},
	class = {},
	dll = {},
	csv = {},
	dataFile = {},
	battleResultData = {
		renderData = {},
		result = {},
	},
}

function DataManager.loadTanentData()
	if DataManager.user == "bozi" then
		DataManager.tanentData = import(".app.task.tanentData")
		DataManager.tanentData.tanentTaskData = import(".app.task.tanentTaskData")
		DataManager.tanentData.tanentTaskData.taskData = import(".app.task.articleTaskData")
	end
	if DataManager.user == "xigua" then
		DataManager.tanentData = require("tanentData")
		DataManager.tanentData.tanentTaskData = require("tanentTaskData")
		DataManager.tanentData.tanentTaskData.taskData = require("articleTaskData")
	end
end

function DataManager.getTanentData()
	return DataManager.tanentData
end

function DataManager.initConvert()
	if DataManager.user == "bozi" then
		require(".app.convert.CSV2Lua")
		--[[
		local init_encode = package.loadlib("./scripts/app/convert/encode.dll","luaopen_encode")
		if init_encode then
        	init_encode()
        	print("编码转换模块初始化成功")
    	else
        	print("读取字符转换模块失败！")
    	end
    	--]]
		DataManager.csv.roleModelData = io.open("./scripts/app/convert/roleModelData.csv","r")
		DataManager.dataFile.roleModelData = io.open("./scripts/app/battle/data/roleModelData.lua","w")
		require(".app.convert.convertRoleModelData")
	end
	if DataManager.user == "xigua" then
	end
end

function DataManager.convertData()
	convertRoleModelData()
	DataManager.csv.roleModelData:close()
	DataManager.dataFile.roleModelData:close()
end

function DataManager.init()
	if DataManager.user == "bozi" then
		import(".app.battle.class.ClassFunction")
		DataManager.playerData = import(".app.player.data.playerData")
		DataManager.battleInitData.bullet = import(".app.battle.data.bulletData")
		DataManager.battleInitData.skill = import(".app.battle.data.skillData")
		DataManager.battleInitData.floor = import(".app.battle.data.floorData")
		-- 战斗数据
		DataManager.XMLData.roleModel = import(".app.battle.data.roleModelData")
		DataManager.XMLData.state = import(".app.battle.data.stateData")
		DataManager.XMLData.formation = import(".app.battle.data.formationData")
		-- 玩家数据
		DataManager.XMLData.vipData = import(".app.player.data.vipData")
		DataManager.XMLData.furnitureData = import(".app.player.data.furnitureData")
		DataManager.XMLData.tenantData = import(".app.player.data.tenantData")
		DataManager.XMLData.regionData = import(".app.player.data.regionData")
		-- 战斗类
		DataManager.class.Bullet = import(".app.battle.class.Bullet")
		DataManager.class.Role = import(".app.battle.class.Role")
		DataManager.class.Floor = import(".app.battle.class.Floor")
		DataManager.class.Skill = import(".app.battle.class.Skill")
		DataManager.class.Buff = import(".app.battle.class.Buff")
		-- 玩家类
		DataManager.class.Room = import(".app.player.class.Room")
		DataManager.class.Tenant = import(".app.player.class.Tenant")
		DataManager.class.Region = import(".app.player.class.Region")
		DataManager.class.Basic = import(".app.player.class.Basic")
		DataManager.class.Hotel = import(".app.player.class.Hotel")
		DataManager.class.World = import(".app.player.class.World")
		DataManager.class.Task = import(".app.player.class.Task")
		DataManager.class.Military = import(".app.player.class.Military")
		DataManager.class.Tavern = import(".app.player.class.Tavern")
		DataManager.class.Storage = import(".app.player.class.Storage")
	end
	if DataManager.user == "xigua" then
		require("ClassFunction")
		if OFFLINE then
			DataManager.playerData = require("playerData")
		else
			DataManager.playerData = DATA_PlayerData:getPlayer()
			--DataManager.playerData = require("playerData")
		end

		
		DataManager.battleInitData.bullet = require("bulletData")
		DataManager.battleInitData.skill = require("skillData")
		DataManager.battleInitData.floor = require("floorData")
		-- 战斗数据
		DataManager.XMLData.roleModel = require("roleModelData")
		DataManager.XMLData.state = require("stateData")
		DataManager.XMLData.formation = require("formationData")
		-- 玩家数据
		DataManager.XMLData.vipData = require("vipData")
		DataManager.XMLData.furnitureData = require("furnitureData")
		DataManager.XMLData.tenantData = require("tenantData")
		DataManager.XMLData.regionData = require("regionData")
		-- 战斗类
		DataManager.class.Bullet = require("Bullet")
		DataManager.class.Role = require("Role")
		DataManager.class.Floor = require("Floor")
		DataManager.class.Skill = require("Skill")
		DataManager.class.Buff = require("Buff")
		-- 玩家类
		DataManager.class.Room = require("Room")
		DataManager.class.Tenant = require("Tenant")
		DataManager.class.Region = require("Region")
		DataManager.class.Basic = require("Basic")
		DataManager.class.Hotel = require("Hotel")
		DataManager.class.World = require("World")
		DataManager.class.Task = require("Task")
		DataManager.class.Military = require("Military")
		DataManager.class.Tavern = require("Tavern")
		DataManager.class.Storage = require("Storage")
	end
end

function DataManager.setBattleInitData(battleInitData)
	--DataManager.battleInitData.role = import(".app.battle.data.roleData")
	DataManager.battleInitData.role = battleInitData
end

function DataManager.refreshData()
	-- body
end

function DataManager.setBattleResultData(renderData,result)
	DataManager.battleResultData.renderData = renderData
	DataManager.battleResultData.result = result
end


function DataManager.getBattleInitData()
	return DataManager.battleInitData
end

function DataManager.getBattleResult()
	return DataManager.battleResultData.renderData,DataManager.battleResultData.result 
end

print("CreatDataManager -- Success")
return DataManager