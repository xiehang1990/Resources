local regionXMLData = import("regionData")
local Region = import("Region")

local World = {}

function World.init(worldData)
	World.region = {}
	for k,v in pairs(regionXMLData) do
		World.region[k] = Region.new(v)
	end
	for k,v in pairs(worldData) do
		World.region[k]:updateRegion(v)
	end
end

function World.getRegion(regionName)
	return World.region[regionName]
end

-- 获得世界区域是否解锁
function World.regionUnlocked(regionName)
	return World.region[regionName] and World.region[regionName]:isUnlocked()
end

-- 获得区域
function World.getSector(regionName,sectorName)
	return World.region[regionName] and World.region[regionName]:getSector(sectorName)
end

-- 获得区域的地区是否解锁
function World.sectorUnlocked(regionName,sectorName)
	return World.region[regionName] and World.region[regionName]:isSectorUnlocked(sectorName)
end


function World.executeSector(regionName,sectorName)
	if World.region[regionName] then
		World.region[regionName]:executeSector(sectorName)
	end
end

print("CreatWorldClass -- Success")
return World