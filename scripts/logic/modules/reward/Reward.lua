local BasicReward=import("BasicReward")
local StorageReward=import("StorageReward")
local TenantReward=import("TenantReward")
local Reward=class("Reward")

function Reward:ctor(rewardData)
	if rewardData then 
	self.BasicReward={}
	for k,v in pairs(rewardData) do
		if k=="BasicReward" then
			--todo
			self.BasicReward=BasicReward.new(v)
		end
		if k=="StorageReward" then
			self.StorageReward=StorageReward.new(v)
		end
		if k=="TenantReward" then 
			self.TenantReward=TenantReward.new(v)
		end 
	end
	end 
end

function Reward:run()
 	self.BasicReward:run()
 	if self.StorageReward~=nil then 
 		self.StorageReward:run()
 	end
 	if self.TenantReward~=nil then 
 		self.TenantReward:run()
 		end  
end 
--[[
function Reward:addReward(reward)
	for k,v in pairs(reward) do
		if k=="BasicReward" then 
			if #self.BasicReward==0 then 
				self.BasicReward=reward.BasicReward
			else
				self.BasicReward:addBasicReward(reward.BasicReward)
			end 
		end 
	end
end 

function Reward:removeReward(reward)
	for k,v in pairs(reward) do
		if k=="BasicReward" then 
			if #self.BasicReward==0 then 
				dump("error in reward")
				sleep()
			end 
				self.BasicReward:removeBasicReward(reward.BasicReward)
		end 
	end
end 
]]
print("rewardsuccess")
return Reward