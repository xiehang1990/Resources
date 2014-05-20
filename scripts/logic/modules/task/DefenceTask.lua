local Talk=import("Talk")
local talkData=import("talkData")
local Reward=import("Reward")
--local Condition=import("Condition")

local DefenceTask=class("DefenceTask")


function DefenceTask:ctor(defenceTaskData)
	self.type="DefenceTask" 
	self.talk=nil  
	self.reward=nil
	self.battleData=defenceTaskData.battleData
	self.condition=nil
--======================================================
	self.talk=Talk.new(talkData[defenceTaskData.talkID]);
	self:addReward(defenceTaskData.reward)

	self.description = defenceTaskData.description
	self.title = defenceTaskData.title

	self.completed = false
	
--	self:addCondition(defenceTaskData.condition)	

end

function DefenceTask:update()
	print("update in defence task")
end 

function DefenceTask:getBattleData()
	return self.battleData 
end 

function DefenceTask:addTalk(talkData)
	self.talk=Talk.new(talkData)
end

function DefenceTask:addReward(rewardData)
	self.reward=Reward.new(rewardData)
end 

function DefenceTask:addCondition(conditionData)
	--self.condition=Condition.new(conditionData)
end 

function DefenceTask:complete()
	self.reward:run()

	self.talk:test()
	return true;
end 

function DefenceTask:getTalk()
	return self.talk
end 

return DefenceTask