local TenantReward=class("TenantReward")

function TenantReward:ctor(tenantRewardData)
	-- body
	self.type="TenantReward"
	self.tenantID=tenantRewardData.tenantID 
	self.experience=tenantRewardData.experience
	--tenantID为某个具体ID，奖励给某个人，为“battle”时，奖励给战斗所有人 “now” 给入住的所有人 “all”给解锁的所有人
end

function TenantReward:run()
	if self.tenantID=="battle" then 
	end
	if PlayerManager.Hotel.tenantArray[self.tenantID]~=nil then 
	
		 PlayerManager.Hotel.tenantArray[self.tenantID].role.experience= PlayerManager.Hotel.tenantArray[self.tenantID].role.experience+self.experience 

		 PlayerManager.Hotel.tenantArray[self.tenantID]:calculateLevel()
	end 

end 
return TenantReward