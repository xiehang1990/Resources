local PlayerManager = {
	-- 玩家各界面参数
	Basic = DataManager.class.Basic,
	Hotel = DataManager.class.Hotel,
	World = DataManager.class.World,
	Task = DataManager.class.Task,
	Military = DataManager.class.Military,
	Tavern = DataManager.class.Tavern,
	Storage = DataManager.class.Storage,
}
-- 一、初始化函数
function PlayerManager.init(playerData)
	-- 初始化数据
	PlayerManager.Basic.init(playerData.basic)
	PlayerManager.Storage.init(playerData.storage)
	PlayerManager.Hotel.init(playerData.hotel)
	PlayerManager.World.init(playerData.world)
	PlayerManager.Task.init(playerData.task)
	PlayerManager.Military.init(playerData.military)
	PlayerManager.Tavern.init(playerData.tavern)
	
	-- 输出初始化结果
	--dump(PlayerManager,"PlayerManager")
end
print("CreatPlayerManager -- Success")
return PlayerManager