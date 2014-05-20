local vipXMLData = import("vipData")

local Basic = {}

function Basic.init(basicData)
	Basic.playerName = basicData.playerName
	Basic.gold = basicData.gold
	Basic.diamond = basicData.diamond
	Basic.prestige = basicData.prestige
	Basic.energy = basicData.energy
	Basic.maxEnergy = 100
	Basic.vip = basicData.vip
	Basic.playerLevel = basicData.playerLevel

	-- 覆盖VIP属性
	for i=1,Basic.vip do
		for k,v in pairs(vipXMLData[i]) do
			Basic[k] = v
		end
	end
end

-- get
-- 获取玩家名字
function Basic.getPlayerName()
	return Basic.playerName
end
-- 获取玩家金币
function Basic.getGold()
	return Basic.gold
end
-- 获取玩家钻石数量
function Basic.getDiamond()
	return Basic.diamond
end
-- 获取玩家威望
function Basic.getPrestige()
	return Basic.prestige
end
-- 获取玩家体力
function Basic.getEnergy()
	return Basic.energy
end
-- 获取玩家最大体力值
function Basic.getMaxEnergy()
	return Basic.maxEnergy
end
-- 获取玩家VIP等级
function Basic.getVip()
	return Basic.vip
end

-- change
-- 改变玩家金币
function Basic.changeGold(gold)
	Basic.gold = Basic.gold + gold
end
-- 改变玩家钻石数量
function Basic.changeDiamond(diamond)
	Basic.diamond = Basic.diamond + diamond
end
-- 改变玩家威望
function Basic.changePrestige(prestige)
	Basic.prestige = Basic.prestige + prestige
end
-- 改变玩家体力
function Basic.changeEnergy(energy)
	Basic.energy = Basic.energy + energy
end

-- set
-- 修改玩家名字
function Basic.setPlayerName(playerName)
	Basic.playerName = playerName
end
-- 设置玩家VIP等级
function Basic.setVip(vip)
	Basic.vip = vip
end

function Basic.condition(basicCondition)
end 

print("CreatBasicClass -- Success")
return Basic



