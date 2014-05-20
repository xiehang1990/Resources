local BasicCondition=class("BasicCondition")

function BasicCondition:ctor(basicConditionData)
	self.gold=basicCondtionData.gold 
	self.diamond=basicConditionData.diamond 
	self.prestige=basicConditionData.prestige 
	self.energy=basicConditionData.energy 
	self.maxEnergy=basicConditionData.maxEnergy 
	self.vip=basicConditionData.vip 
end

function BasicCondition:run()
	-- body
	return ;
end