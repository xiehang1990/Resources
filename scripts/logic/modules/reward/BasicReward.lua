local BasicReward=class("BasicReward")

function BasicReward:ctor(rewardData)
	-- body
	self.type="BasicReward"
	self.gold=rewardData.gold
	self.items=rewardData.items
	self.experience=rewardData.experience 
	self.prestige=rewardData.prestige
	if not rewardData.prestige then
		self.prestige=0
	end 

end

function BasicReward:run()
	PlayerManager.Basic.gold=PlayerManager.Basic.gold+self.gold
--	PlayerManager.Basic.experience=PlayerManager.Basic.experience+self.experience
	PlayerManager.Basic.prestige=PlayerManager.Basic.prestige+self.prestige
	-- body
end

function BasicReward:addBasicReward(basicReward)
	self.gold=self.gold+basicReward.gold 
	self.prestige=self.prestige+basicReward.prestige 
end 

function BasicReward:removeBasicReward(basicReward)
	self.gold=self.gold-basicReward.gold 
	self.prestige=self.prestige-basicReward.prestige 
end 

return BasicReward