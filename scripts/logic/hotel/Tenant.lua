local tenantXMLData = import("tenantData")
local TenantTask=import("TenantTask")
local Reward=import("Reward")
local ExpData = import("experienceData")
local friendshipData = import("friendshipData")
local Tenant = class("Tenant")

function Tenant:ctor(tenantData)
	math.randomseed(os.time())
	self.role={}
	self.financial={}
	self.roleID = tenantData.roleID
	self.itemID = tenantData.itemID
	--self.basicPrice = tenantXMLData[self.roleID].basicPrice
	--self.requrement = tenantXMLData[self.roleID].requirement
	self.stayLength = tenantData.stayLength
	self.stayedLength = tenantData.stayedLength
	self.satisfaction = tenantData.satisfaction
	self.task = {}
	--================================================
	self.role.region=tenantData.region 
	self.role.title=tenantData.roleTitle 
	self.type=tenantData.roleType --普通 or 主线
	self.rewards={}
	self.description=tenantData.description
	self.role.name = tenantData.name

	self:addReward(tenantData.rewards)
	self:initTask()

	--人物经验与等级
	self.role.experience=tenantData.experience
	self.role.Level=tenantData.level

	--人物好感度与好感度等级
	self.role.friendshipValue=tenantData.friendshipValue
	self.role.friendshipLevel=tenantData.friendshipLevel
	self.role.nextFriendshipLevelNeeded = 0
	self.role.currentFriendShipValueLeft = 0

	self:calculateFriendshipLevel()

	--====================================================
	self.financial.productive=tenantData.productive
--	self.room.floorNumber={}
--	self.room.roomNumber={}

	--=========================战斗数据============================
	self.battle = {}
	self.battle.level = tenantData.level
	self.battle.strength = tenantData.strength
	self.battle.intelligence = tenantData.intelligence
	self.battle.physique = tenantData.physique
	self.battle.skillArray = clone(tenantData.skillArray)

	self.battle.totalHP = 0
	self.battle.attack = 0
	self.battle.physicalAttack = 0
	self.battle.magicAttack = 0
	self.battle.physicalDefense = 0
	self.battle.magicDefense = 0
	
	self:updateBattleParameter()
end

--计算战斗数据
function Tenant:updateBattleParameter()
	self.battle.totalHP = math.ceil(self.battle.physique * (self.battle.level+10)*1.5)
	self.battle.attack = math.ceil(self.battle.strength * (self.battle.level+10) * 0.35)
	self.battle.physicalAttack = math.ceil(self.battle.strength * (self.battle.level+10) * 0.15)
	self.battle.magicAttack = math.ceil(self.battle.intelligence * (self.battle.level+10) * 0.15)
	self.battle.physicalDefense = math.ceil((self.battle.physique+self.battle.strength)/2 * (self.battle.level+10)*0.1)
	self.battle.magicDefense = math.ceil((self.battle.physique+self.battle.intelligence)/2 * (self.battle.level+10)*0.1)
end

function Tenant:addTask(taskData)
	self.task:addTask(taskData)
end 

function Tenant:updateRent()
	--
end 

-- execute
function Tenant:checkOut(roomValue,addByCount,addByRatio)
	--[[-- 	return self:caculatePayment(self.stayLength,roomValue,addByCount,addByRatio)
	local money=self:caculatePayment(self.stayedLength,roomValue,addByCount,addByRatio);
	local m={money,self.basicPrice,self.stayedLength,roomValue,addByCount,addByRatio}
	--dump(m,"租金")
	PlayerManager.Basic.changeGold(money)]]--
end

--计算租客基本数据
--战斗级别计算
function Tenant:calculateLevel()
	for k,v in pairs(ExpData) do
		if self.role.experience<v then 
			self.role.level=k 
			break
		end 
	end
end

--好感度级别计算
function Tenant:calculateFriendshipLevel()
	for k,v in pairs(friendshipData) do
		if self.role.friendshipValue<v then 
			self.role.friendshipLevel=k-1

			--计算好感度等级以及下一级需要
			local currentLevelValue = friendshipData[k-1]
			local nextLevelValue = friendshipData[k]

			self.role.nextFriendshipLevelNeeded = nextLevelValue-currentLevelValue
			self.role.currentFriendShipValueLeft = self.role.friendshipValue-currentLevelValue
			break
		end 
	end
end

function Tenant:caculatePayment(time,roomValue,addByCount,addByRatio) 

	return (self.basicPrice + roomValue + addByCount) * (1 + addByRatio) * time
end
--=================================================
--@editor by wangfulai 2014.4.8
--get
function Tenant:getRole()
	return self.role 
end
--set 
function Tenant:getTask()
	return self.task:getTask()
end 

function Tenant:setRoleID(roleID)
	self.roleID=roleID 
end 

--live
function Tenant:live(room)
	self:setRoom(room)
	self.task:begin()
end

--left
function Tenant:left()
	-- checkout
	self:removeRoom()
	self.task:endup()
end
--====================================================task
function Tenant:addReward(rewardData)
	self.rewards.nowNum=0;
	self.rewards.totalNum=0;
	if rewardData then 
		self.rewards.nowNum=1
		self.rewards.totalNum=#rewardData
	end 
	for k,v in pairs(rewardData) do
		self.rewards[k]={}
		self.rewards[k].threshold=v.threshold
		self.rewards[k].reward=Reward.new(v.reward)
		

	end
end

--update 刷新任务完成情况，和满意度 如果满意度达标，则给相应物品
function Tenant:update()
	self.task:update()
--	self:satisfactionUpdate()

end
function Tenant:initTask()
	
	local tenantTask=TenantTask.new()
	self.task=tenantTask
end
--get task num 
function Tenant:getTaskNum()
	return self.task:getNum()
end

function Tenant:taskReceived()
	return self.task:taskReceived()
end

function Tenant:taskDone()
	return self.task:completed()
end


function Tenant:satisfactionUpdate()
	if self.rewards.nowNum==0 then
		return;
	end
	for i=self.rewards.nowNum,self.rewards.totalNum do
		if self.satisfaction>=self.rewards[i].threshold then
			self.rewards[i].reward:run()
		else
			self.rewards.nowNum=i;  --i表示还未给的奖励的第一个
			break;
		end
		self.rewards.nowNum=0;
	end
end
--==================================================
function Tenant:getDescription(index)
	if index<=#self.description then
		return self.description[index]
	end
end 

function Tenant:getRandomDescription()
	
	local index=math.random(#self.description)

	return self:getDescription(index)
end 

--===================================================
function Tenant:setRoom(room)
	self.room=room
end

function Tenant:removeRoom()
	self.room=nil 
end
---------------------------------------------------------------------------------------------
--任务相关------------------------------------------------------------------------------------
function Tenant:addTenantTask(tenantTaskData)
	local tanenttask=TanentTask.new(tenantTaskData)
	self.task=tanentTask 
end

function Tenant:taskReceived()  --接任务
---------------------------------
---------------------------------判断
	self.task:taskReceived()
end

function Tenant:getTaskState()
	return self.task:getState()
end 

function Tenant:getTaskNum()  --返回正在执行的任务数
	return self.task:getNum();
end

function Tenant:taskDone()  --交任务
	self.task:completed();
end

---------------------------------------------------------------------------------------------

print("CreatTenantClass -- Success")
return Tenant
