--[[

通用数据存储

]]

--[[包含所有 DATA]]
local _datas = {
	"Account",
	"PlayerInitData",
}

for i = 1 , #_datas do
	require(_datas[i])
end

local M = {}

--[[初始化]]
function M.init()
	for i = 1 , #_datas do
		require(_datas[i]):init()
	end
end

--[[处理公用数据]]
function M.saveCommonData( type, data )
	
	-- 存储数据
	if type == "selectServer_2"          then DATA_Account:setLoginIP( data )                     	end
	if type == "loginServer_2"          then DATA_Account:setLogicIP( data )                     	end
	if type == "loginServer_100_1"          then DATA_Account:setUserIDAndAServerList( data )       end
	if type == "loginServer_110_1"          then DATA_Account:setLogicServerList( data )       		end

	if type == "logicServer_100_1"          then DATA_PlayerData:setPlayer( data )       				end

	if type == "logicServer_110_1"          then DATA_PlayerData:upgradeHotel( data )       				end
	if type == "logicServer_120_1"          then DATA_PlayerData:upgradeRoom( data )       				end

	return true
end


return M
