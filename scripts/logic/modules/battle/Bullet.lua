local Bullet = class("Bullet")

-- 一、构造函数
function Bullet:ctor(bulletData)
	self.newlyCreated = true
	self.active = true
	self.itemID = bulletData.itemID
	self.name = bulletData.name
	self.moveMode = bulletData.moveMode
	self.penetrate = bulletData.penetrate
	self.damagedTargetArray = {}
	self.maxLaunchAngle = bulletData.maxLaunchAngle
	self.rotateMode = bulletData.rotateMode
	self.selfRotateSpeed = bulletData.selfRotateSpeed

	self.attackParameter = bulletData.attackParameter

	self.direction = bulletData.direction
	self.group = bulletData.group
	self.target = bulletData.target
	self.range = bulletData.range

	self.moveSpeed = bulletData.moveSpeed
	self.textureHeight = bulletData.textureHeight
	self.textureWidth = bulletData.textureWidth
	self.operateRange = bulletData.operateRange
	
	self.frame = {
		creatTotal = bulletData.totalCreatFrame,
		moveTotal = bulletData.totalMoveFrame,
		disappearTotal = bulletData.totalDisappearFrame,		
	}

	self.currentState = {
		state = "creat", -- 另外的状态为"move"和"disappear"		
		closestTarget = "",
		targetToEdgeDistance = 99999,
		targetDistance = 99999,
		paused = false,
		position = {
			launchX = bulletData.position.X,
			launchY = bulletData.position.Y,
			X = bulletData.position.X,
			Y = bulletData.position.Y,
			angle = 0,
			floor = bulletData.position.floor,
			line = bulletData.position.line,
			floorHeight = 0,
			leftBound = 0,
			rightBound = 0,
			movedDistance = 0,
		},
		frame = {
			creat = 1,
			move = 1,
			disappear = 1,
		},
	}
	self.currentState.position.floorHeight = BattleManager.Floor[self.currentState.position.floor].height
	self.currentState.position.leftBound = BattleManager.Floor[self.currentState.position.floor].bulletRange.leftBound
	self.currentState.position.rightBound = BattleManager.Floor[self.currentState.position.floor].bulletRange.rightBound

	self.nextState = clone(self.currentState)

	self.stateChange = false
	
end

-- 二、核心循环函数
function Bullet:runFrame()
	-- 1.将下一帧状态赋值给这一帧
	ClassFunction.copyTable(self.nextState,self.currentState)
	-- 如果不被暂停，则继续执行，否则跳过执行
	if not(self:isPaused()) then
		-- 2.执行当前状态
		if self.currentState.state == "creat" then self:creatFunc() end
		if self.currentState.state == "move" then self:moveFunc() end
		if self.currentState.state == "disappear" then self:disappearFunc() end
		-- 3.计算下一帧状态
		if self.stateChange == true then
			if self.currentState.state == "creat" then 
				self.nextState.state = "move"
				self.stateChange = false
			end
		
			if self.currentState.state == "move" then 
				self.nextState.state = "disappear" 
				self.stateChange = false
			end		
		end
		-- 4.获取最靠近的目标
		local targetGroup = ""
		if self:getGroup() == "attacker" then targetGroup = "defender" end
		if self:getGroup() == "defender" then targetGroup = "attacker" end
		self.nextState.closestTarget, self.nextState.targetDistance, self.nextState.targetToEdgeDistance = BattleManager.findDirectionSingleTarget(self,targetGroup,self:getDirection())
	else
		self:setUnpaused()
	end
end

-- 三、数据交互函数
-- get
-- 获取是否新创建
function Bullet:isNewlyCreated()
	if self.newlyCreated == true then
		self.newlyCreated = false
		return true
	else
		return false
	end
end
-- 获取是否活动
function Bullet:isActive()
	return self.active
end
-- 获取是否暂停
function Bullet:isPaused()
	return self.currentState.paused
end
-- 获取itemID
function Bullet:getItemID()
	return self.itemID
end
-- 获取名称
function Bullet:getName()
	return self.name
end
-- 获取位置信息
function Bullet:getPosition()
	return self.currentState.position
end
-- 获取方向
function Bullet:getDirection()
	return self.direction
end
-- 获取阵营
function Bullet:getGroup()
	return self.group
end
-- 获取状态
function Bullet:getState()
	return self.currentState.state
end
-- 获取当前帧号
function Bullet:getFrameNumber()
	if self.currentState.state == "creat" then return self.currentState.frame.creat end
	if self.currentState.state == "move" then return self.currentState.frame.move end
	if self.currentState.state == "disappear" then return self.currentState.frame.disappear end
end
-- set
-- 设置暂停
function Bullet:setPaused()
	self.nextState.paused = true
end
-- 解除暂停
function Bullet:setUnpaused()
	self.nextState.paused = false
end

-- 四、状态执行函数
-- 创建执行函数
function Bullet:creatFunc()
	if self.currentState.frame.creat < self.frame.creatTotal then
		self.nextState.frame.creat = self.currentState.frame.creat + 1
	else
		self.stateChange = true
	end
end
-- 移动执行函数
function Bullet:moveFunc()
	-- 子弹超过射程则消失
	if self.currentState.position.movedDistance > self.range then
		self.stateChange = true
	end

	-- 判断子弹是否造成攻击判定
	if self.penetrate then
		self:damageOperate()
	else
		if self.currentState.targetDistance < self.operateRange then
			self:damageOperate()
			self.stateChange = true
		end
	end
	-- 子弹移动
	-- 处理子弹X移动
	if not(self.stateChange) then
		if self.direction == "right" then
			self.nextState.position.X = self.currentState.position.X + self.moveSpeed
		end
		if self.direction == "left" then
			self.nextState.position.X = self.currentState.position.X - self.moveSpeed
		end
		self.nextState.position.movedDistance = self.currentState.position.movedDistance + self.moveSpeed
		-- 处理子弹超出边界的问题
		if self.nextState.position.X < self.nextState.position.leftBound or self.nextState.position.X >self.nextState.position.rightBound then
			self.active = false
		end
		-- 处理子弹Y移动
		if self.moveMode == "ballistic" then
			self:caculateParabola()
		end
		-- 子弹帧动画切换
		if self.currentState.frame.move < self.frame.moveTotal then
		self.nextState.frame.move = self.currentState.frame.move + 1
		else
		self.nextState.frame.move = 1
		end
	end
end
-- 消失执行函数
function Bullet:disappearFunc()
	if self.currentState.frame.disappear < self.frame.disappearTotal then
		self.nextState.frame.disappear = self.currentState.frame.disappear + 1
	else
		self.active = false
	end
end

-- 五、造成伤害函数
function Bullet:damageOperate()
	if self.penetrate then
	-- 穿透攻击
		if self:getDirection() == "left" then Xrange = self:getPosition().X - (self.moveSpeed + self.operateRange) end
		if self:getDirection() == "right" then Xrange = self:getPosition().X + (self.moveSpeed + self.operateRange) end
		if self:getGroup() == "attacker" then targetGroup = "defender" end
		if self:getGroup() == "defender" then targetGroup = "attacker" end
		local targetArray = BattleManager.findAreaTarget(self:getPosition().floor,self:getPosition().X,Xrange,targetGroup)
		for _,v in pairs(targetArray) do
			local damaged = false
			for _,u in ipairs(self.damagedTargetArray) do
				if v:getItemID() == u then
					damaged = true
					break
				end
			end
			if not(damaged) then
				v:beAttacked(self.attackParameter)
				self.damagedTargetArray[#self.damagedTargetArray + 1] = v:getItemID()
			end
		end
	else
	-- 非穿透攻击
		--范围攻击
		if self.attackParameter.damage.area then
			if self:getDirection() == "left" then Xrange = self:getPosition().X - self.attackParameter.damage.areaRange end
			if self:getDirection() == "right" then Xrange = self:getPosition().X + self.attackParameter.damage.areaRange end
			if self:getGroup() == "attacker" then targetGroup = "defender" end
			if self:getGroup() == "defender" then targetGroup = "attacker" end
			local targetArray = BattleManager.findAreaTarget(self:getPosition().floor,self:getPosition().X,Xrange,targetGroup)
			for _,v in pairs(targetArray) do
				v:beAttacked(self.attackParameter)
			end
		end
		--非范围攻击
		if not(self.attackParameter.damage.area) and BattleManager.roleArray[self.currentState.closestTarget] and BattleManager.roleArray[self.currentState.closestTarget]:isAlive() then
			BattleManager.roleArray[self.currentState.closestTarget]:beAttacked(self.attackParameter)
		end
	end
end

function Bullet:caculateParabola()
	local movedDistance = self.currentState.position.movedDistance
	local floorHeight = self.currentState.position.floorHeight
	local launchY = self.currentState.position.launchY
	
	local totalDistance = self.currentState.targetDistance + self.currentState.position.movedDistance - self.textureWidth/2
	-- 防止出现距离无限大的情况
	if totalDistance > self.range then
		totalDistance = self.range
	end
	-- 进行计算
    local x0,y0 = totalDistance,(floorHeight - launchY)

    -- 防止出现角度过大的情况
    if 4*y0/x0 > math.tan(self.maxLaunchAngle*3.1415926/180) then
    	y0 = math.tan(self.maxLaunchAngle*3.1415926/180)*x0/4
    end
    -- 根据轨迹计算Y坐标增量
    local a,b = -(4*y0/(x0^2)),4*y0/x0
    self.nextState.position.Y = a*movedDistance^2 + b*movedDistance + launchY
    
    if self.rotateMode == "normal" then
    	self.nextState.position.angle = math.atan(2*a*movedDistance + b)*180/3.1415926
    end

    if self.rotateMode == "selfRotate" then
    	self.nextState.position.angle = self.currentState.position.angle + self.selfRotateSpeed
    end

    if self.nextState.position.Y <= 0 then
        self.nextState.position.Y = 0
        if self.active then
        	self.active = false
        end
    end	
end

print("CreatBulletClass -- Success")
return Bullet