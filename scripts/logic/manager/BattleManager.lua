local Bullet = DataManager.class.Bullet
local Role = DataManager.class.Role

BattleManager = {
	-- 1.读取数据
	battleInitData = {
		role = {},
		state = {},
		bullet = {},
		skill = {},
		floor = {},
	},
	
	-- 2.初始化
	roleArray = {},
	lineArray = {},
	deadArray = {},
	bulletArray = {},
	bulletNumber = 0,
	pauseByArray = {},
	pauseBy = "",

	renderData = {
		pauseBy = {},
		roleData = {},
		bulletData = {},
		skillData = {},
		numberData = {},
	},
	result = {},
}

-- 零、读取数据
function BattleManager.setBattleInitData(battleInitData)
	BattleManager.battleInitData = battleInitData
end

-- 一、构造函数
function BattleManager.run()

	local roleCount = 0
	-- 指针指向载入数据，并对各类进行加载
	BattleManager.Skill = DataManager.class.Skill
	BattleManager.Buff = DataManager.class.Buff
	BattleManager.Floor = DataManager.class.Floor
	BattleManager.Skill.init()
	BattleManager.Buff.init()
	BattleManager.Floor.init(BattleManager.battleInitData.floor)
	-- 3.创建战斗对象
	for _,v in pairs(BattleManager.battleInitData.role.attacker) do
		v.group = "attacker"
		roleCount = roleCount + 1
		v.itemID = v.group .. roleCount
		BattleManager.roleArray[v.itemID] = Role.new(v)
	end
	for _,v in pairs(BattleManager.battleInitData.role.defender) do
		v.group = "defender"
		roleCount = roleCount + 1
		v.itemID = v.group .. roleCount
		BattleManager.roleArray[v.itemID] = Role.new(v) 
	end
	-- 4.进行计算
	while (not BattleManager.battleEnd()) do
		BattleManager.nextFrame()
	end
	print("CaculatebattleResultData -- Success")
	-- 5.返回数据
	return BattleManager.renderData,BattleManager.result	
end

-- 二、析构，并重载数据
function BattleManager.release()
	-- body
end

-- 三、计算下一帧，核心循环项
function BattleManager.nextFrame()
	BattleManager.pauseBy,_ = next(BattleManager.pauseByArray)
	if not(BattleManager.pauseBy) then
		BattleManager.pauseBy = ""
	end
	-- 1.所有对象跑1帧
	-- 1.1 所有Bullet跑1帧,如果不active,则删除
 	for _,v in pairs(BattleManager.bulletArray) do
 		if v:isActive() then
 			-- 如果有暂停源，则暂停子弹的移动
 			if BattleManager.pauseBy ~= "" then
 				v:setPaused()
 			end
 			v:runFrame()
 		else
 			BattleManager.bulletArray[v:getItemID()] = nil
 		end
 	end
	-- 1.2 对所有战斗对象跑1帧，对其他目标造成伤害（分为单体伤害和范围伤害。单体伤害给定目标；范围伤害给定范围，会带入到多个Role中）
	for _,v in pairs(BattleManager.roleArray) do
		if v:isAlive() then
			-- 如果有暂停源，则暂停所有的role
			if BattleManager.pauseBy ~= "" then
				v:setPaused() 
			end
			-- 如果是暂停源，则设置role的暂停源标志位
			if v:getItemID() == BattleManager.pauseBy then
				v:setPauseSource() 
			end 
			v:runFrame()
		else
			BattleManager.deadArray[v:getItemID()] = v
			BattleManager.roleArray[v:getItemID()] = nil
		end
	end
	-- 1.3 所有死亡但还在继续渲染的对象跑一帧
	for _,v in pairs(BattleManager.deadArray) do
		if v:isActive() then
			v:runFrame()
		else
			BattleManager.deadArray[v:getItemID()] = nil
		end
	end
	-- 2.写入渲染数据
	-- 2.0写入暂停数据
	BattleManager.renderData.pauseBy[#BattleManager.renderData.pauseBy + 1] = BattleManager.pauseBy
	-- 2.1写入角色渲染数据
	local tempRoleRenderData = {}
	for k,v in pairs(BattleManager.roleArray) do
		local rolePositon = v:getRenderPosition()
		tempRoleRenderData[k] = {
			itemID = k,
			roleID = v:getRoleID(),
			new = v:isNewlyCreated(), 
			last = not(v:isActive()),
			paused = v:isPaused(),
			pauseSource = v:isPauseSource(),
			group = v:getGroup(), 
			state = v:getState(), 
			frameNumber = v:getFrameNumber(), 
			X = rolePositon.X,
			Y = BattleManager.Floor[rolePositon.floor].Y + rolePositon.Y,
			floor = rolePositon.floor,
			floorShift = rolePositon.floorShift,
			direction = v:getDirection(), 
			totalHP = v:getTotalHP(), 
			HP = v:getHP(),
			beDamaged = v:beDamaged(),
			buff = v:getRenderBuff(),
			number = v:getNumberArray(),
		}
	end
	BattleManager.renderData.roleData[#BattleManager.renderData.roleData + 1] = tempRoleRenderData
	
	-- 2.2写入子弹渲染数据
	local tempBulletRenderData = {}
	for k,v in pairs(BattleManager.bulletArray) do
		local bulletPosition = v:getPosition()
		tempBulletRenderData[k] = {
			itemID = k,
			name = v:getName(),
			new = v:isNewlyCreated(),
			last = not(v:isActive()),
			paused = v:isPaused(),
			gourp = v:getGroup(),
			state = v:getState(),
			frameNumber = v:getFrameNumber(),
			X = bulletPosition.X,
			Y = BattleManager.Floor[bulletPosition.floor].Y + bulletPosition.Y,
			angle = bulletPosition.angle,
			direction = v:getDirection(),
		}
	end
	BattleManager.renderData.bulletData[#BattleManager.renderData.bulletData + 1] = tempBulletRenderData
	-- 2.3写入数字渲染数据
	local tempNumberRenderData = {}
	for _,v in pairs(BattleManager.roleArray) do
		for _,u in pairs(v:getNumberArray()) do
			tempNumberRenderData[#tempNumberRenderData + 1] = u
		end
	end
	BattleManager.renderData.numberData[#BattleManager.renderData.numberData + 1] = tempNumberRenderData
end
-- 四、计算结束条件
function BattleManager.battleEnd()
	local attackerAllClear = true
	local defenderAllClear = true
	-- 计算各层是否floorClear
	for i,v in ipairs(BattleManager.Floor) do
		local attackerClear = true
		local defenderClear = true
		for _,v in pairs(BattleManager.roleArray) do
			if v:getPosition().floor == i then
				if v:getGroup() == "attacker" then
					attackerClear = false
					attackerAllClear = false
				end
				if v:getGroup() == "defender" then
					defenderClear = false
					defenderAllClear = false
				end
			end
		end
	
		v.attackerClear = attackerClear
		v.defenderClear = defenderClear
		v.floorClear = attackerClear or defenderClear
	end

	-- 计算战斗是否结束(某一方死光了,且死亡动画也播放完成)
	if (attackerAllClear or defenderAllClear) and (next(BattleManager.deadArray) == nil) then
		BattleManager.result.winner = (attackerAllClear and "defender") or "attacker"
		
		return true
	else
		if os.clock() > 3 then
			return false
		else
			return false
		end
	end

	return false
end

-- 五、计算对象之间的位置关系
-- 计算不带方向的最近敌人
function BattleManager.findSingleTarget(object,targetGroup)
	-- 读取当前角色对象位置，并初始化搜索初始值
	local objectPosition = object:getPosition()
	local objectDirection = object:getDirection()
	local objectTarget = ""
	local distance = 99999 -------待define
	local toEdgeDistance = 99999
	local stayFrame = 0
	local direction = ""
	local floorClear = "true"
	-- 进行循环搜索
	for i,v in pairs(BattleManager.roleArray) do
		if (v:getGroup() == targetGroup) then
			targetPosition = v:getPosition()
			if (targetPosition.floor == objectPosition.floor) and  (v:canBeChoosen()) then	
				if (math.abs(targetPosition.X - objectPosition.X) < distance) or ((math.abs(targetPosition.X - objectPosition.X) == distance) and targetPosition.stayFrame > stayFrame) then
					objectTarget = i
					distance = math.abs(targetPosition.X - objectPosition.X)
					direction = ((targetPosition.X > objectPosition.X) and "right" or "left")
					toEdgeDistance = math.abs((direction == "left" and targetPosition.right or targetPosition.left) - objectPosition.X)
					-- 以下3行代码是防止被吞到肚子里面去了
					if objectPosition.X > targetPosition.left and objectPosition.X < targetPosition.right then
						toEdgeDistance = 0
					end
					stayFrame = targetPosition.stayFrame
				end
			end
		end
	end

	if direction == "" then direction = objectDirection end


	-- 将数据写入角色对象中
	return objectTarget,distance,toEdgeDistance,direction
end
-- 计算带方向的最近敌人
function BattleManager.findDirectionSingleTarget(object,targetGroup,direction) -- 这里的targetGroup部分还没有完成，还是个摆设
	-- 读取当前角色对象位置，并初始化搜索初始值
	local objectPosition = object:getPosition()
	local objectTarget = ""
	local distance = 99999 -------待define
	local toEdgeDistance = 99999
	-- 进行循环搜索
	for i,v in pairs(BattleManager.roleArray) do
		if (v:getGroup() == targetGroup) then
			targetPosition = v:getPosition()
			if (targetPosition.floor == objectPosition.floor) and  (v:canBeChoosen()) then
				if (direction == "right") and ((targetPosition.X - objectPosition.X) >= 0) and ((targetPosition.X - objectPosition.X) < distance) then
					objectTarget = i
			 		distance = targetPosition.X - objectPosition.X
					toEdgeDistance = targetPosition.left - objectPosition.X
				end
				if (direction == "left") and ((objectPosition.X - targetPosition.X) >= 0) and ((objectPosition.X - targetPosition.X) < distance) then
					objectTarget = i
					distance = objectPosition.X - targetPosition.X
					toEdgeDistance =  objectPosition.X - targetPosition.right
				end
			end
		end	
	end
	-- 将数据写入角色对象中
	return objectTarget,distance,toEdgeDistance,direction
end
-- 计算范围内的敌人
function BattleManager.findAreaTarget(floor,X1,X2,targetGroup)
	if X1 > X2 then X1,X2 = X2,X1 end -- 确保X1 < X2
	local areaTargetArray = {}
	for k,v in pairs(BattleManager.roleArray) do
		if (v:getGroup() == targetGroup) then
			targetPosition = v:getPosition()
			if (targetPosition.floor == floor) and  (v:canBeChoosen()) and ((targetPosition.right > X1 and targetPosition.right < X2) or (targetPosition.left > X1 and targetPosition.left < X2)) then
				areaTargetArray[k] = v
			end
		end
	end
	return areaTargetArray
end
-- 寻找一个随机目标
function BattleManager.findRandomTarget(targetGroup)
	local lookupTable = {}
	local roleNumber = 0
	for k,v in pairs(BattleManager.roleArray) do
		if v:getGroup() == targetGroup then
			roleNumber = roleNumber + 1
			lookupTable[roleNumber] = k
		end
	end
	local choosenNumber = math.floor(math.random()*roleNumber)+1
	return lookupTable[choosenNumber]
end
-- 寻找某个楼层的随机目标
function BattleManager.findRandomTargetByFloor(targetGroup,targetFloor)
	local lookupTable = {}
	local roleNumber = 0
	for k,v in pairs(BattleManager.roleArray) do
		if v:getGroup() == targetGroup and v:getPosition().floor == targetFloor then
			roleNumber = roleNumber + 1
			lookupTable[roleNumber] = k
		end
	end
	local choosenNumber = math.floor(math.random()*roleNumber)+1
	return lookupTable[choosenNumber]
end

-- 六、新建子弹对象
function BattleManager.creatBullet(bulletParameter)
	local tempBulletData = BattleManager.battleInitData.bullet[bulletParameter.bulletName]
	tempBulletData.group = bulletParameter.group
	tempBulletData.position = bulletParameter.position
	tempBulletData.direction = bulletParameter.direction
	tempBulletData.attackParameter = bulletParameter.attackParameter
	tempBulletData.range = bulletParameter.range
	
	BattleManager.bulletNumber = BattleManager.bulletNumber + 1
	tempBulletData.itemID = (BattleManager.bulletNumber)
	BattleManager.bulletArray[tempBulletData.itemID] = Bullet.new(tempBulletData)
end

-- 七、画面暂停
-- 加入暂停源
function BattleManager.pause(roleID)
	BattleManager.pauseByArray[roleID] = true
end
-- 移除暂停源
function BattleManager.unpause(roleID)
	BattleManager.pauseByArray[roleID] = nil
end

print("CreatBattleManager -- Success")
return BattleManager