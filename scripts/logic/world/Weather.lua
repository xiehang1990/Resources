local WeatherTotalData=import("weatherTotalData")
local Reward=import("Reward")
local Weather=class("Weather")

function Weather:ctor()--所有天气信息
	for k,v in pairs(WeatherTotalData) do
		print(k,v)
		self[k]={}
		for i=v[1],v[2] do
			self[k][i]={
			BeginReward={},
			EndReward={}
		}
		end
	end
	self:flush()
end

function Weather:flush()
	self.now="Sun"
end

function Weather:loadWeatherData(weatherData)
end 
	

function Weather:addBeginReward(weather,level,beginRewardData)
	local beginReward=Reward.new(beginRewardData)
	-- body
	if self[weather]==nil then 
		return 
	end 
	if self[weather][level]==nil then 
		return 
	end
	if #self[weather][level]==0 then 
		self[weather][level].BeginReward=beginReward
	else
	 	self[weather][level].BeginReward:addReward(beginReward)
	end  



end

function Weather:addEndReward(weather,level,endRewardData)
	local endRewawrd=Reward.new(endRewardData)
	if self[weather]==nil then 
		return 
	end 
	if self[weather][level]==nil then 
		return 
	end
	if #self[weather][level]==0 then 
		self[weather][level].EndReward=endReward
	else
	 	self[weather][level].EndReward:addReward(endReward)
	end 
	-- body
end

function Weather:removeBeginReward(weather,level,beginReward)
	if self[weather]==nil then 
		return 
	end 
	if self[weather][level]==nil then 
		return 
	end 
	self[weather][level].BeginReward:removeReward(beginReward)
end 
function Weather:removeEndReward(weather,level,endReward)
	if self[weather]==nil then 
		return 
	end 
	if self[weather][level]==nil then 
		return 
	end 
	self[weather][level].EndReward:removeReward(endReward)
end

return Weather