--@author by wangfulai  2014 3 23
local ArticleTask=import("ArticleTask")
local DefenceTask=import("DefenceTask")
local Reward=import("Reward")
local Talk=import("Talk")

local TenantTask = class("TenantTask")

function TenantTask:ctor()

	self.condition={} --任务执行条件
	self.state={} -- flushing ready doing done
	self.time=0    -- 0是complete的意思
	self.now  =0     --task现在是哪一个task，执行到最大数量结束。
	self.task={}
	--self:addReward(tenantTaskData.reward)
	--self:addTalk(tenantTaskData.talk)

end

function TenantTask:addTask(taskData)
	if self.now==#self.task and self.state=="done" then
		self.now=self.now+1;
		self.state="ready"
		end  

	if taskData.type=="ArticleTask" then

			self.task[#self.task+1]=ArticleTask.new(taskData);
			

		end
		if taskData.type=="DefenceTask" then
			self.task[#self.task+1]=DefenceTask.new(taskData)
		end
	if self.now==0 and #self.task==1 then 
		self:begin()
	end 
end 

function TenantTask:addReward(rewardData)
	if rewardData then
		--todo
		local reward=Reward.new(rewardData)
		self.reward=reward 
	end
	
end 

function TenantTask:getTask()
	return self.task[self.now]
end 

function TenantTask:addTalk(talkData)

	if talkData then
		local talk=Talk.new(talkData)
		self.talk=talk
	end

end


function TenantTask:taskReceived()
---------------------------------------判断
----------------------------------------
	if self.state=="ready" then
		self.task[self.now]:update()
		self.state="doing"
		dump("接任务成功")
		return true 

	end
	dump("接任务失败")
	return false 
end

function TenantTask:begin()
--

	if self.now==0 and #self.task>0 then
		--todo
		self.now=1;
		self.state="ready"
	end
end

function TenantTask:endup()
	self.now=#self.task+1;
end 
function TenantTask:getInfo() --不同类型任务返回不同信息 

	return self.task:getInfo();

end

function TenantTask:update() --更新任务条件是否满足
	return self.task:update();
end

function TenantTask:updateCompleted() --更新是否可完成任务
	return self.task:update();
end

function TenantTask:getState()
	return self.state 
end 

function TenantTask:completed() --完成任务
	--完成任务 向服务器提出要求
	--服务器验证通过
	
 -- self.task[self.now].reward:run();
	if self.state~="doing" then 
		dump("任务失败")
		return false 
	end 

  	if self.now==#self.task then
  		--todo
  		if self.task[self.now]:complete() then 
  			self.state="done"
  			self.now=self.now+1
  			dump("任务完成")
  			return true 
  		end 
  	elseif self.now<#self.task then 
  		if self.task[self.now]:complete() then 
  			self.state="ready";
  	
  			self.now=self.now+1;
  			dump("任务完成")
  			return true 
  		end 
  	else 
  		dump("eror")
  		sleep()
  	end
  	dump("任务失败")
  	return false 

--	self.reward:run();
end

function TenantTask:getTaskNum()
	return #self.task;
end

return TenantTask;