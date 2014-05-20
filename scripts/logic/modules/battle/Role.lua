local roleModel = DataManager.XMLData.roleModel
local state = DataManager.XMLData.state
local formation = DataManager.XMLData.formation

local Role = class("Role")

function Role:ctor(roleData)
	-- 1.基础数据
	self.originalState = {
		newlyCreated      = true,
		itemID            = roleData.itemID,
		totalHP           = roleData.totalHP,
		roleID            = roleData.roleID,
		--textureHeight   = roleModel[roleData.roleID].textureHeight,
		textureHeight     = 0,
		textureWidth      = roleModel[roleData.roleID].textureWidth,
		--height          = roleModel[roleData.roleID].textureHeight/2,
		height            = 0,
		attack            = roleData.attack,
		physicalDefense   = roleData.physicalDefense,
		magicDefense      = roleData.magicDefense,
		weaponStyle       = roleModel[roleData.roleID].weaponStyle,
		attackStyle       = roleModel[roleData.roleID].attackStyle,
		bulletName        = roleModel[roleData.roleID].bulletName,
		bulletXShift      = roleModel[roleData.roleID].bulletXShift,
		bulletYShift      = roleModel[roleData.roleID].bulletYShift,
		skillBulletXShift = roleModel[roleData.roleID].skillBulletXShift,
		skillBulletYShift = roleModel[roleData.roleID].skillBulletYShift,
		weaponRange       = roleModel[roleData.roleID].weaponRange,
		attackRange       = roleModel[roleData.roleID].attackRange,
		area              = roleModel[roleData.roleID].area,
		areaRange         = roleModel[roleData.roleID].areaRange,
		moveSpeed         = roleModel[roleData.roleID].moveSpeed,
		group             = roleData.group,
		statePriority     = state,				-- 这里是并没有修改，所以不需要clone
		skillArray        = roleData.skillArray,	-- 这里载入的只是技能名字，在下面才载入具体的技能表
	}

	-- 2.帧数相关
	self.basicFrame = {
		waitTotal        = roleModel[roleData.roleID].totalWaitFrame,
		moveTotal        = roleModel[roleData.roleID].totalMoveFrame,
		attackTotal      = roleModel[roleData.roleID].totalAttackFrame,
		attackAccomplish = roleModel[roleData.roleID].attackAccomplish,
		skillTotal       = roleModel[roleData.roleID].totalSkillFrame,
		skillAccomplish  = roleModel[roleData.roleID].skillAccomplish,
		attackCDTotal    = roleModel[roleData.roleID].totalAttackCDFrame,
		stunTotal        = roleModel[roleData.roleID].totalStunFrame,
		dieTotal         = roleModel[roleData.roleID].totalDieFrame,
		
		shiftBefore      = roleModel[roleData.roleID].shiftBefore,
		shiftExecute     = roleModel[roleData.roleID].shiftExecute,
		shiftAfter       = roleModel[roleData.roleID].shiftAfter,
		shiftTotal       = roleModel[roleData.roleID].shiftBefore + roleModel[roleData.roleID].shiftExecute + roleModel[roleData.roleID].shiftAfter,
		shiftAccomplish  = roleModel[roleData.roleID].shiftBefore + roleModel[roleData.roleID].shiftExecute,
	}

	-- buff相关
	self.buff = {
		buffNumber      = 0,
		buffArray       = {},
		renderBuffArray = {},
	}

	self.shiftTarget = {
		floor           = 0,
		line            = 0,
		originalY       = 0,
		originalFloorY  = 0,
		--originalLineY = 0,
		targetFloorY    = 0,
		
		originalX       = 0,
		targetX         = 0,
	}

	self.repelParameter = {
		repelDirection = "",
		repelLength    = 0,
		repelTime      = 0,
		originalHeight = 0,
		repelHeight    = 0,
	}

	-- 3.当前状态
	self.currentState = {
		alive         = true,
		active        = true,
		previousState = "wait",
		state         = "wait",		
		direction     = "",
		beDamaged     = false,
		paused        = false,
		pauseSource   = false,

		candidateTarget = {
			targetName     = "",	-- 距离最近的敌人，作为目标候选人
			direction      = "",		-- 目标候选人的方向
			distance       = 99999,	-- toEdgeDistance
			toEdgeDistance = 99999,
			targetExist    = false,
		},
		attackTarget = {
			targetName     = "",	-- 攻击目标
			direction      = "", 	-- 为"left","right"	-- 决定移动，根据移动目标确定
			distance       = 99999, 	----待difine
			toEdgeDistance = 99999,
			targetExist    = false,
		},
		basic = {
			HP              = roleData.totalHP,
			attack          = roleData.attack,
			physicalDefense = roleData.physicalDefense,
			magicDefense    = roleData.magicDefense,
			attackSpeed     = 1,			-- 默认的attackSpeed都为1，攻速的变换都是以1为标准进行变换的
			moveSpeed       = roleModel[roleData.roleID].moveSpeed,
		},
		position = {
			X            = formation[roleData.group][roleData.position[1]][roleData.position[2]].X,
			Y            = roleModel[roleData.roleID].textureHeight/2,
			left         = formation[roleData.group][roleData.position[1]][roleData.position[2]].X - roleModel[roleData.roleID].textureWidth/2,
			right        = formation[roleData.group][roleData.position[1]][roleData.position[2]].X + roleModel[roleData.roleID].textureWidth/2,
			floor        = formation[roleData.group][roleData.position[1]][roleData.position[2]].floor,
			line         = 0,
			
			stayFrame    = 0,
			canBeChoosen = true,
			floorShift   = false,
		},
		frame = {
			wait     = 1,
			move     = 1,
			attack   = 1,
			attacked = false,
			skill    = 1,
			skilled  = false,
			attackCD = 1,			
			repel    = 1,
			stun     = 1,
			die      = 1,
			shift    = 1,
		}
	
	}
	-- 4.下一帧状态
	self.nextState = clone(self.currentState)
	-- 5.状态判断数组
	self.stateReady = {
		die             = false,
		stun            = false,
		shift           = false,
		repel           = false,
		attackCD        = false,
		skill           = false,
		attack          = false,
		move            = false,
		wait            = true,
		invoke          = false,	-- 这里因为skill状态在每一帧都是清除的，所以需要一个在帧之间不清除的invoke状态来保存上一帧是否触发了攻击施法
		invokeNeedPause = false,
	}
	-- 6.攻击参数数组
	self.attackParameter = {
		damage = {
			source         = self.originalState.itemID, 
			value          = self.currentState.basic.attack, 
			type           = self.originalState.attackStyle,
			critical       = false,
			criticalFactor = 1,
			beDodged       = false,
			accuracy       = 1,
			area           = self.originalState.area,
			areaRange      = self.originalState.areaRange,
		},
		buff = {},
	}
	-- 7.数字渲染数组
	self.numberArray = {}
	-- 8.载入技能
	for k,v in pairs(self.originalState.skillArray) do
		self.originalState.skillArray[k] = clone(BattleManager.battleInitData.skill[v])
		for _,v in ipairs(self.originalState.skillArray[k]) do
			v.needExecute = false
		end
	end
	-- 9.受到攻击数组
	self.beAttackedArray = {}
	-- 9.调用初始函数
	self:onCreat()
end

-- 函数
-- 一、运行函数（核心循环函数）-------------------------------------------------------------------------
function Role:runFrame()
	-- 1.获取当前状态
	-- 将nextState赋值给currentState，并初始化nextState
	
	ClassFunction.clearTable(self.numberArray)
	ClassFunction.copyTable(self.nextState,self.currentState)

	-- 如果不被暂停，则继续执行
	if not(self:isPaused()) then
		self:beforeFrame()
		-- 2.执行当前状态,并设置部分stateReady
		if self.currentState.state == "shift" then self:shiftFunc() end
		if self.currentState.state == "die" then self:dieFunc() end
		if self.currentState.state == "stun" then self:stunFunc() end
		if self.currentState.state == "repel" then self:repelFunc() end
		if self.currentState.state == "attackCD" then self:attackCDFunc() end
		if self.currentState.state == "skill" then self:skillFunc() end
		if self.currentState.state == "attack" then self:attackFunc() end
		if self.currentState.state == "move" then self:moveFunc() end
		if self.currentState.state == "wait" then self:waitFunc() end
		-- 3.计算下一帧状态
		-- 3.1 结算伤害
		self:settleBeAttacked()	
		-- 3.2 更新剩余部分的stateReady
		self:setstateReady()
		-- 3.3 计算得到nextState的状态,并对frame进行计算
		self.nextState.previousState = self.currentState.state
		self:executeState()
		-- 3.4 更新Buff项
		self:updateBuff()
		-- 4.重置stateReady(invoke不需要重置)
		self.stateReady.shift    = false
		self.stateReady.die      = false
		self.stateReady.stun     = false
		self.stateReady.repel    = false
		self.stateReady.attackCD = false
		self.stateReady.skill    = false
		self.stateReady.attack   = false
		self.stateReady.move     = false
		self.stateReady.wait     = true

		-- 5.重置attackParameter
		self.attackParameter.damage.source         = self.originalState.itemID
		self.attackParameter.damage.value          = self.currentState.basic.attack
		self.attackParameter.damage.type           = self.originalState.attackStyle
		self.attackParameter.damage.critical       = false
		self.attackParameter.damage.criticalFactor = 1
		self.attackParameter.damage.beDodged       = false
		self.attackParameter.damage.accuracy       = 1
		self.attackParameter.damage.area           = self.originalState.area
		self.attackParameter.damage.areaRange      = self.originalState.areaRange
		ClassFunction.clearTable(self.attackParameter.buff)
		--[[
		self.attackParameter = {
			damage = {
				source = self.originalState.itemID, 
				value = self.currentState.basic.attack, 
				type = self.originalState.attackStyle,
				critical = false,
				criticalFactor = 1,
				beDodged = false,
				accuracy = 1,
				area = self.originalState.area,
				areaRange = self.originalState.areaRange,
			},
			buff = {},
		}
		--]]
		-- 5.计算下一帧的目标
		if (self.nextState.state ~= "attack") and (self.nextState.state ~= "attackCD") then
			self:loadSingleTarget()
			self.nextState.direction = self.nextState.candidateTarget.direction
			self:clearAttackTarget()
		else
			self:loadDirectionSingleTarget()
			self.nextState.direction = self.nextState.attackTarget.direction
		end
		self.nextState.attackTarget.targetName     = self.currentState.attackTarget.targetName
		self.nextState.attackTarget.direction      = self.currentState.attackTarget.direction
		self.nextState.attackTarget.distance       = self.currentState.attackTarget.distance
		self.nextState.attackTarget.toEdgeDistance = self.currentState.attackTarget.toEdgeDistance
		self.nextState.attackTarget.targetExist    = self.currentState.attackTarget.targetExist

		-- 6.若不是移动状态，则增加下一帧的stayFrame
		if (self.nextState.state == "move") then
			self.nextState.position.stayFrame = 1
		else
			self.nextState.position.stayFrame = self.currentState.position.stayFrame + 1
		end
		self:afterFrame()
	-- 如果被暂停，则检测是否是暂停源
	-- 如果是暂停源，则只执行技能函数，不进行伤害结算等
	else
		if self:isPauseSource() then
			self:skillFunc()
			self.nextState.previousState = self.currentState.state
			self:executeState()			
		end
		self:setUnpaused()
		self:clearPauseSource()
	end
end

-- 二、状态调用函数------------------------------------------------------------------------------------
-- 换层函数
function Role:shiftFunc()
	if self.currentState.frame.shift < self.basicFrame.shiftTotal then
		self.stateReady.shift = true
	end

	if self.currentState.frame.shift >= self.basicFrame.shiftBefore and self.currentState.frame.shift < self.basicFrame.shiftAccomplish then
		local Y0,Y1,T,t = self.shiftTarget.originalFloorY,self.shiftTarget.targetFloorY,self.basicFrame.shiftExecute,(self.currentState.frame.shift - self.basicFrame.shiftBefore)
		if Y0 >= Y1 then 
			self.nextState.position.Y = self.shiftTarget.originalY + (Y1 - Y0)*t^2/(T^2)
		else
			self.nextState.position.Y = self.shiftTarget.originalY + (Y0 - Y1)*(T-t)^2/(T^2) + (Y1 - Y0)
		end
	else
		self.nextState.position.Y = self.shiftTarget.originalY
	end

	if self.currentState.frame.shift == self.basicFrame.shiftTotal then
		BattleManager.Floor.usingStep = ""
	end

	if self.currentState.frame.shift == self.basicFrame.shiftAccomplish then
		self:shiftAccomplish()
		self.nextState.position.floorShift = true
	else
		self.nextState.position.floorShift = false
	end
end
-- 死亡函数
function Role:dieFunc()
	self.stateReady.die = true
end
-- 眩晕函数
function Role:stunFunc()
end
-- 击退函数
function Role:repelFunc()
	if self.currentState.frame.repel < self.repelParameter.time then
		local t0 = self.repelParameter.time
		local t = self.currentState.frame.repel
		local L = self.repelParameter.length
		local H = self.repelParameter.height
		local H0 = self.repelParameter.originalHeight
		-- 处理水平方向坐标
		local deltRepelLength = 2*L/t0 - L*(2*t - 1)/(t0*t0)
		if self.repelParameter.direction == "left" then
			self:setPositionX(self:getPosition().X - deltRepelLength) 
		end
		if self.repelParameter.direction == "right" then 
			self:setPositionX(self:getPosition().X + deltRepelLength) 
		end
		-- 处理竖直方向坐标
		local repelHeight = 0
		if H0 < H then
			local k = 1/(1+math.sqrt(H/(H-H0)))
			local a = ((1-k)*H0-H)/((k-k*k)*t0*t0)
			local b = (H-(1-k*k)*H0)/((k-k*k)*t0)
			repelHeight = a*t*t + b*t + H0
		else
			repelHeight = (-1)*(H/(t0*t0))*t*t + H			
		end
		self:setPositionY(self.originalState.height + repelHeight)
		self.stateReady.repel = true
	end
end
-- 攻击间隔函数
function Role:attackCDFunc()
	if self.currentState.frame.attackCD < self.basicFrame.attackCDTotal then
		self.stateReady.attackCD = true
	end
end
-- 释放技能函数
function Role:skillFunc()
	-- 设置目标
	if not(self.currentState.attackTarget.targetExist) then
		self.currentState.attackTarget = clone(self.currentState.candidateTarget)
	end
	-- 播放动画并释放技能
	if self.currentState.frame.skill < self.basicFrame.skillTotal then
		self.stateReady.skill = true
	else
		self.stateReady.attackCD = true
	end
	if self.currentState.frame.skill >= self.basicFrame.skillAccomplish  and self.currentState.frame.skilled == false then
		self:skillAccomplish()
		self.nextState.frame.skilled = true
	end
end
-- 攻击函数
function Role:attackFunc()
	-- 设置目标
	if not(self.currentState.attackTarget.targetExist) then
		self.currentState.attackTarget = clone(self.currentState.candidateTarget)
	end
	--end
	-- 播放动画并进行攻击
	if self.currentState.frame.attack < self.basicFrame.attackTotal then
		self.stateReady.attack = true
	else
		self.stateReady.attackCD = true
	end
	if self.currentState.frame.attack >= self.basicFrame.attackAccomplish  and self.currentState.frame.attacked == false then
		self:attackAccomplish()
		self.nextState.frame.attacked = true
	end
end
-- 移动函数
function Role:moveFunc()
	if self.currentState.direction == "left" then
		self.nextState.position.X = self.currentState.position.X - self.currentState.basic.moveSpeed
		self.nextState.position.left = self.currentState.position.X - self.originalState.textureWidth/2
		self.nextState.position.right = self.currentState.position.X + self.originalState.textureWidth/2
	end
	if self.currentState.direction == "right" then
		self.nextState.position.X = self.currentState.position.X + self.currentState.basic.moveSpeed
		self.nextState.position.left = self.currentState.position.X - self.originalState.textureWidth/2
		self.nextState.position.right = self.currentState.position.X + self.originalState.textureWidth/2
	end
end
-- 等待函数
function Role:waitFunc()
end

-- 三、状态计算函数------------------------------------------------------------------------------
function Role:setstateReady()
	if self.nextState.basic.HP <= 0 then
		self.stateReady.die = true
	end
	-- 近程按照边缘距离判断，远程按照中心距离判断
	if (self.originalState.weaponStyle == "short" and self.nextState.candidateTarget.toEdgeDistance <= self.originalState.attackRange) or (self.originalState.weaponStyle == "long" and self.nextState.candidateTarget.distance <= self.originalState.attackRange) then
		self.stateReady.attack = true
	end
	if BattleManager.Floor[self:getPosition().floor].floorClear and (BattleManager.Floor.usingStep == self:getItemID() or BattleManager.Floor.usingStep == "") then
		self.stateReady.shift = true
		if self.currentState.state ~= "shift" then
			BattleManager.Floor.usingStep = self:getItemID()
		end
	end
	-- 这里没有设置边界,所以move都为true
	if not(BattleManager.Floor[self:getPosition().floor].floorClear) then
		self.stateReady.move = true
	end
	-- 设置是否需要施放技能
	if self.stateReady.invoke then
		self.stateReady.skill = true
	end
end
function Role:executeState()
	for _,v in ipairs(self.originalState.statePriority[self.currentState.state]) do
		if self.stateReady[v] then
			if v == "shift" then self:toShiftFunc() end
			if v == "die" then self:toDieFunc() end
			if v == "stun" then self:toStunFunc() end
			if v == "repel" then self:toRepelFunc() end
			if v == "attackCD" then self:toAttackCDFunc() end
			if v == "skill" then self:toSkillFunc() end
			if v == "attack" then self:toAttackFunc() end
			if v == "move" then self:toMoveFunc() end
			if v == "wait" then self:toWaitFunc() end
			break
		end
	end
end

-- 四、状态设置调用函数---------------------------------------------------------------------------
-- 换层函数
function Role:toShiftFunc()
	self.nextState.state = "shift"
	if self.nextState.previousState ~= "shift" then
		self.nextState.frame.shift = 1
		self.shiftTarget.floor = BattleManager.Floor.floorShift(self:getGroup(),self:getPosition().floor)
		self.shiftTarget.line = BattleManager.Floor.caculateLine(self:getGroup(),self:getWeaponStyle(),self.shiftTarget.floor) -- 计算阵线
		self.shiftTarget.originalFloorY = BattleManager.Floor[self:getPosition().floor].Y
		self.shiftTarget.targetFloorY = BattleManager.Floor[self.shiftTarget.floor].Y
		self.shiftTarget.originalY = self:getPosition().Y
	else
		self.nextState.frame.shift = self.nextState.frame.shift + 1
	end
end
-- 死亡函数
function Role:toDieFunc()
	-- 判断之前的状态时否为die
	self.nextState.state = "die" 
	if self.nextState.previousState ~= "die" then
		Role:beforeDeath()
		self.nextState.alive = false
		self.nextState.frame.die = 1
		-- 清除占用的楼梯
		if BattleManager.Floor.usingStep == self:getItemID() then
			BattleManager.Floor.usingStep = ""
		end
		-- 清除暂停源
		if self.stateReady.invokeNeedPause then
			BattleManager.unpause(self:getItemID())
		end
	else
		self.nextState.frame.die = self.currentState.frame.die + 1		
	end
	-- 判断role是否活动
	if self.nextState.frame.die > self.basicFrame.dieTotal then
			self.nextState.active = false
	end
end
-- 眩晕函数
function Role:toStunFunc()
	self.nextState.state = "stun" 
	if self.nextState.previousState ~= "stun" then
		self.nextState.frame.stun = 1
	else 
		self.nextState.frame.stun = self.nextState.frame.stun + 1
	end
end
-- 击退函数
function Role:toRepelFunc()
	self.nextState.state = "repel"
	if self.nextState.previousState ~= "repel" then
		self.nextState.frame.repel = 1
		self.repelParameter.originalHeight = 0
	else
		self.nextState.frame.repel = self.nextState.frame.repel + 1
	end
end
-- 攻击间隔函数
function Role:toAttackCDFunc()
	self.nextState.state = "attackCD" 
	if self.nextState.previousState ~= "attackCD" then
		self.nextState.frame.attackCD = 1
	else 
		self.nextState.frame.attackCD = self.nextState.frame.attackCD + self.currentState.basic.attackSpeed
	end
end
-- 技能函数
function Role:toSkillFunc()
	self.nextState.state = "skill"
	if self.nextState.previousState ~= "skill" then
		if self.stateReady.invokeNeedPause then
			BattleManager.pause(self:getItemID())
		end
		self.nextState.frame.skill = 1
		self.nextState.frame.skilled = false
		self.stateReady.invoke = false
	else 
		self.nextState.frame.skill = self.nextState.frame.skill + self.currentState.basic.attackSpeed
	end
	-- body
end
-- 攻击函数
function Role:toAttackFunc()
	self.nextState.state = "attack"
	if self.nextState.previousState ~= "attack" then
		self.nextState.frame.attack = 1
		self.nextState.frame.attacked = false
	else 
		self.nextState.frame.attack = self.nextState.frame.attack + self.currentState.basic.attackSpeed
	end
	-- body
end
-- 移动函数
function Role:toMoveFunc()
	self.nextState.state = "move"
	if self.nextState.previousState ~= "move" then
		self.nextState.frame.move = 1
	else 
		self.nextState.frame.move = self.nextState.frame.move + 1
	end
end
-- 等待函数
function Role:toWaitFunc()
	self.nextState.state = "wait"
	if self.nextState.previousState ~= "wait" then
		self.nextState.frame.wait = 1
	else 
		self.nextState.frame.wait = self.nextState.frame.wait + 1
	end
end

function Role:shiftAccomplish()
	-- 在换层后清除需要释放的技能
	self.stateReady.invoke = false
	BattleManager.Floor.clearLine(self:getGroup(),self:getWeaponStyle(),self:getPosition().floor,self:getPosition().line,self:getItemID())
	-- 切换楼层
	self:setFloor(self.shiftTarget.floor)
	self:setLine(self.shiftTarget.Line)
	BattleManager.Floor.setLine(self:getGroup(),self:getWeaponStyle(),self:getPosition().floor,self:getPosition().line,self:getItemID())
end


-- 六、攻击处理部分--------------------------------------------------------------------------------------
-- 攻击函数
function Role:attackAccomplish()
	local needChangeTarget = false
	-- 目标判定
	-- 如果目标不存在，则攻击最近的敌人，并在下一帧重新选择目标
	if not(BattleManager.roleArray[self.currentState.attackTarget.targetName]) then
		self.currentState.attackTarget = clone(self.currentState.candidateTarget)
		needChangeTarget = true
	-- 如果目标死亡，或进行了特殊移动,则攻击最近的敌人，并在下一帧重新选择目标
	elseif not(BattleManager.roleArray[self.currentState.attackTarget.targetName]:isAlive()) or not(BattleManager.roleArray[self.currentState.attackTarget.targetName]:canBeChoosen()) then
		self.currentState.attackTarget = clone(self.currentState.candidateTarget)
		needChangeTarget = true
	end
	-- 判定变换后的目标是否存在，是否存活
	if BattleManager.roleArray[self.currentState.attackTarget.targetName] and BattleManager.roleArray[self.currentState.attackTarget.targetName]:isAlive() then
		-- 判断攻击类型
		self:beforeAttack(BattleManager.roleArray[self.currentState.attackTarget.targetName])
		-- 近程攻击处理函数
		if self.originalState.weaponStyle == "short" then		
			-- 非范围攻击
			if not(self.originalState.area) and (self.currentState.attackTarget.toEdgeDistance <= self.originalState.weaponRange) then
				BattleManager.roleArray[self.currentState.attackTarget.targetName]:beAttacked(self.attackParameter)
			end
			-- 范围攻击
			if self.originalState.area then
				local targetGroup = ""
				if self:getDirection() == "left" then 
					XRange1 = self:getPosition().X - self.originalState.areaRange
					XRange2 = self:getPosition().X
				end
				if self:getDirection() == "right" then 
					XRange1 = self:getPosition().X + self.originalState.areaRange
					XRange2 = self:getPosition().X
				end
				if self:getGroup() == "attacker" then targetGroup = "defender" end
				if self:getGroup() == "defender" then targetGroup = "attacker" end
				local targetArray = BattleManager.findAreaTarget(self:getPosition().floor,XRange1,XRange2,targetGroup)
				for _,v in pairs(targetArray) do
					v:beAttacked(self.attackParameter)
				end
			end			
		end
		-- 远程攻击处理函数
		if self.originalState.weaponStyle == "long" then
			local bulletParameter = {
				group = self.originalState.group,
				bulletName = self.originalState.bulletName,				
				position = {
					X = self.currentState.position.X + self:getBulletShift().X,
					Y = self.currentState.position.Y + self:getBulletShift().Y,
					floor = self.currentState.position.floor,
					line = self.currentState.position.line,
				},
				direction = self.currentState.direction,
				target = self.currentState.attackTarget.targetName,
				range = self.originalState.weaponRange,
				attackParameter = clone(self.attackParameter),
			}
			BattleManager.creatBullet(bulletParameter)
		end	
		self:afterAttack()
	end
	-- 如果要变换攻击目标，则清空当前的攻击目标
	if needChangeTarget then
		self:clearAttackTarget()
	end	
end

function Role:skillAccomplish()
	local needChangeTarget = false
	-- 目标判定
	-- 如果目标不存在，则攻击最近的敌人，并在下一帧重新选择目标
	if not(BattleManager.roleArray[self.currentState.attackTarget.targetName]) then
		self.currentState.attackTarget = clone(self.currentState.candidateTarget)
		needChangeTarget = true
	-- 如果目标死亡，或进行了特殊移动,则攻击最近的敌人，并在下一帧重新选择目标
	elseif not(BattleManager.roleArray[self.currentState.attackTarget.targetName]:isAlive()) or not(BattleManager.roleArray[self.currentState.attackTarget.targetName]:canBeChoosen()) then
		self.currentState.attackTarget = clone(self.currentState.candidateTarget)
		needChangeTarget = true
	end
	if self.stateReady.invokeNeedPause then
		BattleManager.unpause(self:getItemID())
	end
	self:invokeSkill(BattleManager.roleArray[self.currentState.attackTarget.targetName])
end


-- 七、受到伤害处理部分------------------------------------------------------------------------------------
-- 将攻击存入数组
function Role:beAttacked(beAttacked)
	self.beAttackedArray[#self.beAttackedArray+1] = clone(beAttacked)
end
-- 攻击结算函数
function Role:settleBeAttacked()
	self.currentState.beDamaged = false
	for _,v in ipairs(self.beAttackedArray) do
		self.nextState.basic.HP = self.nextState.basic.HP - self:caculateDeductedHP(v.damage)
		-- 处理有关extraState的数据,将其读入buffArray
		for _,u in ipairs(v.buff) do
			self:addBuff(u)
		end
		if self.nextState.basic.HP <= 0 then
			self.currentState.die = true
			if BattleManager.roleArray[v.damage.source] and BattleManager.roleArray[v.damage.source]:isAlive() then
				-- 如果自己死亡，则回调攻击者的击杀目标函数
				BattleManager.roleArray[v.damage.source]:onKillTarget(self)
			end
			break
		end
	end	
	-- 清空next受到攻击状态的数组
	self.beAttackedArray = {}
end
-- 计算受到的伤害
function Role:caculateDeductedHP(damage)
	self:beforeDamage(damage)
	-- 处理暴击
	if damage.critical then
		damage.value = damage.value*damage.criticalFactor
	end
	-- 处理闪避
	if not(damage.dodge) then
		if damage.type == "physical" then
			deductedHP = damage.value - self.currentState.basic.physicalDefense
		end
		if damage.type == "magic" then
			deductedHP = damage.value - self.currentState.basic.magicDefense
		end
		if damage.type == "skill" then
			deductedHP = damage.value
		end
		if damage.type == "real" then
			deductedHP = damage.value
		end
		deductedHP = (deductedHP < 1) and 1 or deductedHP --如果damage.type = 其他值，则会返回nil
		self.currentState.beDamaged = true
		-- 写入渲染部分
		self.buff.renderBuffArray[damage.type] = true
	else
		deductedHP = 0
	end
	self:afterDamage(damage,deductedHP)
	return deductedHP
end

-- 八、帧处理函数
-- 增加Frame计数器
function Role:addFrame()
	-- body
end
-- 更新Buff计数器
function Role:updateBuff()
	for k,v in pairs(self.buff.buffArray) do
		-- 如果计数器为时间，则进行更新，当超过时间时，则删除buff
		if v.counter.mode == "frame" then
			v.counter.lastFrame = v.counter.lastFrame - 1
			if v.counter.lastFrame <= 0 then
				self.buff.buffArray[k] = nil
			end
		end
		-- 如果计数器是次数，则如果完成，删除buff
		if v.counter.mode == "once" then
			if v.counter.done then
				self.buff.buffArray[k] = nil
			end
		end
	end
end

-- 九、特殊时刻处理函数----------------------------------------------------------------------------
-- 创建处理函数
function Role:onCreat()
	-- 调用技能函数
	for _,v in pairs(self.originalState.skillArray) do
		BattleManager.Skill.run("onCreat",v,self)
	end
	-- 处理楼层的行数
	self.currentState.position.line = BattleManager.Floor.caculateLine(self:getGroup(),self:getWeaponStyle(),self:getPosition().floor)
	self.nextState.position.line = self.currentState.position.line
	BattleManager.Floor.setLine(self:getGroup(),self:getWeaponStyle(),self:getPosition().floor,self:getPosition().line,self:getItemID())
end
-- 帧前处理函数
function Role:beforeFrame()
	-- 重置下一帧的Y位置
	self:setPositionY(self.originalState.height)
	-- 清空渲染Buff数组
	ClassFunction.clearTable(self.buff.renderBuffArray)

	-- 调用buff函数
	for _,v in pairs(self.buff.buffArray) do
		-- 执行buff
		BattleManager.Buff.run(v.buffName,"beforeFrame",v,self)
		-- 更新Frame计数器
		if v.trigger.currentFrame then
			v.trigger.currentFrame = v.trigger.currentFrame + 1
		end
		-- 如果需要渲染，则加入渲染数组中
		if v.needRender then
			self.buff.renderBuffArray[v.buffName] = v.needRender
		end
	end
	-- 调用skill函数
	for _,v in pairs(self.originalState.skillArray) do
		-- 执行Skill
		BattleManager.Skill.run("beforeFrame",v,self)
		-- 更新skill计数器
		if v.trigger.currentFrame then
			v.trigger.currentFrame = v.trigger.currentFrame + 1
		end		
	end
end
-- 帧后处理函数
function Role:afterFrame()
	-- body
end
-- 死亡前处理函数
function Role:beforeDeath()
	-- body
end
-- 技能前处理函数
function Role:onSkill()
	for _,v in pairs(self.originalState.skillArray) do
		BattleManager.Skill.run("onSkill",v,self,targetObject)
	end
end
-- 攻击前处理函数
function Role:beforeAttack(targetObject)
	-- 判断是否命中
	if math.random() > self.attackParameter.damage.accuracy then
		self.attackParameter.damage.dodge = true
	end
	
	for _,v in pairs(self.buff.buffArray) do
		-- 更新attackCount计数器
		if v.trigger.currentAttack then
			v.trigger.currentAttack = v.trigger.currentAttack + 1
		end
		-- 执行buff
		BattleManager.Buff.run(v.buffName,"beforeAttack",v,self)
	end
	
	-- 调用技能函数
	for _,v in pairs(self.originalState.skillArray) do
		-- 更新attackCount计数器
		if v.trigger.currentAttack then
			v.trigger.currentAttack = v.trigger.currentAttack + 1
		end
		-- 执行skill
		BattleManager.Skill.run("beforeAttack",v,self,targetObject)
	end
end
-- 攻击后处理函数
function Role:afterAttack()
	-- body
end
-- 伤害前处理函数
function Role:beforeDamage(damage)
	for _,v in pairs(self.originalState.skillArray) do
		BattleManager.Skill.run("beforeDamage",v,BattleManager.roleArray[damage.source],self,damage)
	end
end
-- 伤害后处理函数
function Role:afterDamage(damage,deductedHP)
	-- 1.写入伤害数字
	if damage.dodge == true then
		self:addToNumberArray(deductedHP, "dodge") 
	elseif damage.critical == true then
		self:addToNumberArray(deductedHP, "critical")
	else
		self:addToNumberArray(deductedHP, "normal")
	end
	-- 2.调用source的onDamageApply函数
	-- 判定目标是否存在，是否存活,如果存活，则回调造成伤害函数
	if BattleManager.roleArray[damage.source] and BattleManager.roleArray[damage.source]:isAlive() then
		BattleManager.roleArray[damage.source]:onDamageApply(self,damage,deductedHP)
	end
end
-- 攻击伤害结算时处理函数
function Role:onDamageApply(targetObject,damage,deductedHP)
	for _,v in pairs(self.originalState.skillArray) do
		BattleManager.Skill.run("onDamageApply",v,self,targetObject,damage,deductedHP)
	end
end
-- 击杀目标时的处理函数
function Role:onKillTarget(targetObject)
	for _,v in pairs(self.originalState.skillArray) do
		BattleManager.Skill.run("onKillTarget",v,self,targetObject,deductedHP)
	end
end
-- 施放技能
function Role:invokeSkill(targetObject)
	for _,v in pairs(self.originalState.skillArray) do
		BattleManager.Skill.run("invokeSkill",v,self,targetObject)
	end
end

-- 十、数据传输函数-----------------------------------------------------------------------------------
-- get
-- 获取是否新创建
function Role:isNewlyCreated()
	if self.originalState.newlyCreated == true then
		self.originalState.newlyCreated = false
		return true
	else
		return false
	end
end
-- 获取是否活动
function Role:isActive()
	return self.currentState.active
end
-- 获取是否存活
function Role:isAlive()
	return self.currentState.alive
end
-- 获取是否暂停
function Role:isPaused()
	return self.currentState.paused
end
-- 获取是否暂停源
function Role:isPauseSource()
	return self.currentState.pauseSource
end
-- 获取是否受到伤害
function Role:beDamaged()
	return self.currentState.beDamaged
end
-- 获取是否特殊移动
function Role:canBeChoosen()
	return self.currentState.position.canBeChoosen
end
-- 获取ItemID
function Role:getItemID()
	return self.originalState.itemID
end
-- 获取RoleID
function Role:getRoleID()
	return self.originalState.roleID
end
-- 获得Role阵营
function Role:getGroup()
	return self.originalState.group
end
-- 获得Role的武器类型
function Role:getWeaponStyle()
	return self.originalState.weaponStyle
end
-- 获得Role位置
function Role:getPosition()
	return self.currentState.position
end
-- 获得Role的渲染位置
function Role:getRenderPosition()
	local renderPosition = self.currentState.position
	renderPosition.X = renderPosition.X + BattleManager.Floor.line[renderPosition.line].XShift
	renderPosition.Y = renderPosition.Y + BattleManager.Floor.line[renderPosition.line].YShift
	-- 如果是shift状态，需要在渲染上平滑过渡到别的line
	if self.currentState.state == "shift" then
		local currentShift = BattleManager.Floor.getLineShift(self:getPosition().line)
		local targetShift = BattleManager.Floor.getLineShift(self.shiftTarget.line)
		local doneRatio = self.currentState.frame.shift/self.basicFrame.shiftTotal
		renderPosition.X = renderPosition.X + (targetShift.XShift - currentShift.XShift)*doneRatio
		renderPosition.Y = renderPosition.Y + (targetShift.YShift - currentShift.YShift)*doneRatio
	end
	return renderPosition
end
-- 获得Role方向
function Role:getDirection()
	return self.currentState.direction
end
-- 获得Role总血量
function Role:getTotalHP()
	return self.originalState.totalHP
end
-- 获得Role当前血量
function Role:getHP()
	return self.currentState.basic.HP
end
-- 获得Role下一帧血量
function Role:getNextHP()
	return self.nextState.basic.HP
end
-- 获得当前状态
function Role:getState()
	return self.currentState.state
end
-- 获得当前状态的当前帧号
function Role:getFrameNumber()
	local frameNumber = 1
	if self.currentState.state == "shift" then return self.currentState.frame.shift end
	if self.currentState.state == "die"  then return self.currentState.frame.die end
	if self.currentState.state == "stun"  then return self.currentState.frame.stun end
	if self.currentState.state == "attackCD"  then return self.currentState.frame.attackCD end
	if self.currentState.state == "skill" then return self.currentState.frame.skill end
	if self.currentState.state == "attack"  then return self.currentState.frame.attack end
	if self.currentState.state == "move"  then return self.currentState.frame.move end
	if self.currentState.state == "wait"  then return self.currentState.frame.wait end
end	
-- 获得numberArray
function Role:getNumberArray()
	return clone(self.numberArray)
end
-- 获得需要渲染的Buff
function Role:getRenderBuff()
	--dump(self.buff.renderBuffArray)
	return clone(self.buff.renderBuffArray)
end
-- 获取普通攻击子弹的偏移
function Role:getBulletShift()
	local bulletShift = {}
	if self:getDirection() == "left" then
		bulletShift.X = (-1)*self.originalState.bulletXShift
		bulletShift.Y = self.originalState.bulletYShift
	end
	if self:getDirection() == "right" then
		bulletShift.X = self.originalState.bulletXShift
		bulletShift.Y = self.originalState.bulletYShift
	end
	return bulletShift
end
-- 获取技能子弹的偏移
function Role:getSkillBulletShift()
	local bulletShift = {}
	if self:getDirection() == "left" then
		bulletShift.X = (-1)*self.originalState.skillBulletXShift
		bulletShift.Y = self.originalState.skillBulletYShift
	end
	if self:getDirection() == "right" then
		bulletShift.X = self.originalState.skillBulletXShift
		bulletShift.Y = self.originalState.skillBulletYShift
	end
	return bulletShift
end
-------------------------------------------
-- set
-- 设置暂停
function Role:setPaused()
	self.nextState.paused = true
end
-- 解除暂停
function Role:setUnpaused()
	self.nextState.paused = false
end
-- 设置为暂停源
function Role:setPauseSource()
	self.nextState.pauseSource = true
end
-- 清除暂停源
function Role:clearPauseSource()
	self.nextState.pauseSource = false
end
-- 设置X坐标
function Role:setPositionX(X)
	-- 不要超过楼层的左右边界
	if X < BattleManager.Floor[self:getPosition().floor].roleRange.leftBound then X = BattleManager.Floor[self:getPosition().floor].roleRange.leftBound end
	if X > BattleManager.Floor[self:getPosition().floor].roleRange.rightBound then X = BattleManager.Floor[self:getPosition().floor].roleRange.rightBound end
	self.nextState.position.X = X
	self.nextState.position.left = self.nextState.position.X - self.originalState.textureWidth/2
	self.nextState.position.right = self.nextState.position.X + self.originalState.textureWidth/2
end
-- 设置Y坐标
function Role:setPositionY(Y)
	self.nextState.position.Y = Y
end
-- 重置Y坐标
function Role:resetPositionY(Y)
	self.nextState.position.Y = self.originalState.height
end
-- 设置楼层
function Role:setFloor(floor)
	-- 从左右方进入其他楼层
	--[[
	if self:getGroup() == "attacker" then
		self:setPositionX(BattleManager.Floor[floor].roleRange.leftBound)
	end
	if self:getGroup() == "defender" then
		self:setPositionX(BattleManager.Floor[floor].roleRange.rightBound)
	end
	--]]
	-- 从当前位置进入其他楼层
	self:setPositionX(self.currentState.position.X)
	self.nextState.position.floor = floor
	self:clearAttackTarget()
end
-- 设置阵线
function Role:setLine(line)
	self.nextState.position.line = line
end
-- 设置单个目标
function Role:loadSingleTarget()
	local targetGroup = ""
	if self:getGroup() == "attacker" then targetGroup = "defender" end
	if self:getGroup() == "defender" then targetGroup = "attacker" end
	self.nextState.candidateTarget.targetName, self.nextState.candidateTarget.distance, self.nextState.candidateTarget.toEdgeDistance,self.nextState.candidateTarget.direction = BattleManager.findSingleTarget(self,targetGroup)
	self.nextState.candidateTarget.targetExist = not(self.nextState.candidateTarget.targetName == "")
end
-- 设置带方向的目标
function Role:loadDirectionSingleTarget()
	local targetGroup = ""
	if self:getGroup() == "attacker" then targetGroup = "defender" end
	if self:getGroup() == "defender" then targetGroup = "attacker" end
	self.nextState.candidateTarget.targetName, self.nextState.candidateTarget.distance, self.nextState.candidateTarget.toEdgeDistance,self.nextState.candidateTarget.direction = BattleManager.findDirectionSingleTarget(self,targetGroup,self:getDirection())
	self.nextState.candidateDirection  = self.currentState.direction
	self.nextState.candidateTarget.targetExist = not(self.nextState.candidateTarget.targetName == "")
end
-- 清除攻击目标
function Role:clearAttackTarget()
	self.currentState.attackTarget.targetName = ""
	self.currentState.attackTarget.direction = self:getDirection()
	self.currentState.attackTarget.distance = 99999
	self.currentState.attackTarget.targetExist = false
end
-- 修改最大血量
function Role:changeTotalHP(HP)
	self.originalState.totalHP = math.floor(self.originalState.totalHP + HP)
	if self.originalState.totalHP < 1 then self.originalState.totalHP = 1 end
end
-- 增加血量
function Role:changeHP(value)
	-- 需要先对value进行取整
	self.nextState.basic.HP = self.nextState.basic.HP + value
	if self.nextState.basic.HP > self.originalState.totalHP then
		self.nextState.basic.HP = self.originalState.totalHP
	end
	if self.nextState.basic.HP < 0 then
		self.nextState.basic.HP = 0
	end
end
-- 写入伤害数字
function Role:addToNumberArray(value,type)
	self.numberArray[#self.numberArray + 1] = {
		value = value, 
		X = self.currentState.position.X,
		Y = self.currentState.position.Y + self.originalState.textureHeight/2 + BattleManager.Floor[self.currentState.position.floor].Y,
		group = self.originalState.group,
		type = type,
	}
end
-- 设置暴击倍数
function Role:setCriticalFactor(factor)
	-- 如果有多重暴击，则取最大值
	if factor > self.attackParameter.damage.criticalFactor then
		self.attackParameter.damage.criticalFactor = factor
		self.attackParameter.damage.critical = true
	end
end
-- 改变命中率
function Role:changeAccuracy(value)
	self.attackParameter.damage.accuracy = self.attackParameter.damage.accuracy + value
	if self.attackParameter.damage.accuracy < 0 then
		self.attackParameter.damage.accuracy = 0
	end
	if self.attackParameter.damage.accuracy > 2 then
		self.attackParameter.damage.accuracy = 2
	end
end
-- 增加buff
function Role:addBuff(buff)
	self.buff.buffNumber = self.buff.buffNumber + 1
	if buff.unique then
		self.buff.buffArray[buff.buffName .. "unique" .. buff.uniqueNumber] = clone(buff)
	else
		self.buff.buffArray[buff.buffName .. self.buff.buffNumber] = clone(buff)
	end
end
-- 增加攻击速度
function Role:changeAttackSpeed(value)
	self.currentState.basic.attackSpeed = self.currentState.basic.attackSpeed + value
	if self.currentState.basic.attackSpeed < 0 then self.currentState.basic.attackSpeed = 0 end
	if self.currentState.basic.attackSpeed > 10 then self.currentState.basic.attackSpeed = 10 end
end
-- 设置stun判断状态
function Role:beStuned()
	self.stateReady.stun = true
end
-- 设置被击退
function Role:beRepeled(direction,length,height,time)
	self.stateReady.repel = true
	self.repelParameter.direction = direction
	self.repelParameter.length = length
	self.repelParameter.height = height
	-- 重新计算击退时间以及记录当前位置
	if self.repelParameter.time then
		self.repelParameter.time = (time > (self.repelParameter.time - self.currentState.frame.repel)) and time or (self.repelParameter.time - self.currentState.frame.repel) -- 和当前剩余时间的最大值  
	else
		self.repelParameter.time = time
	end
	self.nextState.frame.repel = 1
	self.repelParameter.originalHeight = self:getPosition().Y - self.originalState.height
end

-- 增加本次攻击所附带的buff
function Role:addAttackBuff(buff)
	self.attackParameter.buff[#self.attackParameter.buff +1] = clone(buff)
end
-- 设置需要施法
function Role:invoke(needPause)
	self.stateReady.invoke = true
	self.stateReady.invokeNeedPause = needPause
end
-- 增加需要渲染的特效
function Role:addRenderBuff(buffName)
	self.buff.renderBuffArray[buffName] = true
end

print("CreatRoleClass -- Success")
return Role