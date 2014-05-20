local Region = class("Region")

function Region:ctor(regionData)
	self.display = false
	self.unlocked = false
	self.prestige = 0
	self.requirement = regionData.regiurement
	self.sector = clone(regionData.sector)
	for _,v in pairs(self.sector) do
		v.display = false
		v.unlocked = false
	end
	self.tenant = clone(regionData.tenant)
end

-- Sector执行函数
function Region:executeSector(sectorName)
	if self.sector[sectorName].style == "battle" then
		PlayerManager.Military.setBattleInitData(self.sector[sectorName].group,self.sector[sectorName].enemy)
		PlayerManager.Military.battle()
	end
end

function Region:updateRegion(regionData)
	self.display = regionData.presitge
	self.unlocked = regionData.unlocked
	self.prestige = regionData.prestige
	-- 初始化每个sector的display
	for k,v in pairs(regionData.sector) do
		self.sector[k].display = v.dispaly
		self.sector[k].unlocked = v.unlocked
		self.sector[k].task = v.task
	end
end

function Region:isDisplayed()
	return self.display
end

function Region:isUnlocked()
	return self.unlocked
end

function Region:getSector(sectorName)
	return false
end

function Region:isSectorUnlocked(sectorName)
	return false
end

print("CreatRegionClass -- Success")
return Region