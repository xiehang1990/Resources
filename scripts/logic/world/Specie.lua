local Weather=import("Weather")
local Reward=import("Reward")
local Specie=class("Specie")

function Specie:ctor(specieData)

	self.weather=Weather.new()
	self:updateWeather(specieData.weather)
	self.name=specieData.name;
	self.maxLevel=specieData.maxLevel --最大等级
	self.level={}
	self:addLevelData(specieData.level)
	self.specieCondition=specieData.specieCondition
	-- body

end

function Specie:updateWeather(specieWeatherData)
	for k,v in pairs(specieWeatherData) do
		self.weather:addBeginReward(v.weatherType,v.level,v.BeginReward)
		self.weather:addEndReward(v.weatherType,v.level,v.EndReward)
	end
end

function Specie:addLevelData(specieLevelData)
	if self.maxLevel==nil or self.maxLevel<1 then
		--todo
		return
	end
	for i=1,self.maxLevel do
		self.level[i]={}
		self.level[i].locked=specieLevelData[i].locked
		self.level[i].score=specieLevelData[i].score
		self.level[i].reward=Reward.new(specieLevelData[i].reward)
	end
end 

function Specie:unlockLevel(level)
 	if level>self.maxLevel then 
 		return 
 	end 
 	if self.level[level].locked==false then 
 		dump("error")
 		sleep()
 	end 
 	self.level[level].locked=false
 	self.level[level].reward:run()
end

function Specie:getScore()
	-- body
	local score=0;
	for i=1,#self.level do
		if not self.level[i].locked then 
			score=score+self.level[i].score 
		end 

	end
	return score
end

function Specie:getSpecieCondition()
	return self.specieCondition
end 

return Specie