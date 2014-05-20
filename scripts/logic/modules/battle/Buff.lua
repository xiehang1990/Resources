local Buff = {
	trigger = {},
	buffTemplate = {
		extraState = function () end,
		beforeFrame = function () end,
		afterFrame = function () end,
		beforeAttack = function() end,
		afterAttack = function() end,
		beforeDamage = function() end,
		afterDamage = function() end,
		onDamageApply = function ()	end,
	},

	changeHP = {},
	changeAttackDamage = {},
	changeBuffDamage = {},
	changeDamage = {},
	changePhysicalDefense = {},
	changeMagicDefense = {},
	changeDefense = {},
	changeAttackSpeed = {},
	changeCritical = {},
	changeDodge = {},
	changeAccuracy = {},

	stun = {},
	repel = {},

	poison = {},

	-- 作为伤害特效的源头，寻找受到伤害的目标，并向目标添加伤害特效Buff
	damageEffectSource = {},
	-- 作为伤害特效的处理部分，为目标添加受到伤害，并向渲染池中加入需要的参数
	damageEffect = {},
}

function Buff.init()
	--Buff.initAttackBuff()
	Buff.initChangeAttackSpeed()
	--Buff.initPhysicalDefenseBuff()
	--Buff.initMagicDefenseBuff()
	--Buff.initMoveSpeedBuff()
	--Buff.initHPChangeBuff()
	Buff.initStun()
	Buff.initRepel()
	Buff.initPoison()

	Buff.initDamageEffectSource()
	Buff.initDamageEffect()
end

-- 创建Buff
function Buff.creat(buffParameter,sourceItemID,targetItemID)
	local buff = clone(buffParameter)
	buff.source = sourceItemID
	buff.target = targetItemID
	return buff
end

-- 执行Buff
function Buff.run(buffName,condition,buff,sourceObject,targetObject,...)
	-- 当前condition情况下是否Buff需要触发以及判断Buff是否触发
	-- 由此就规定了每个Buff只可能在一个状态下进行触发
	if Buff[buffName][condition] and Buff.trigger[buff.trigger.mode](buff) then
		Buff[buffName][condition](buff,sourceObject,targetObject,...)
	end
end

-- 各状态的调用示例
function Buff.extraState(buffName,buff,object)end
function Buff.beforeFrame(buffName,buff,object)end
function Buff.afterFrame(buffName,buff,object)end
function Buff.beforeAttack(buffName,buff,sourceObject,targetObject)end
function Buff.afterAttack(buffName,buff,sourceObject,targetObject)end
function Buff.beforeDamage(buffName,buff,sourceObject,targetObject,damage)end
function Buff.afterDamage(buffName,buff,sourceObject,targetObject,damage)end

-- Buff触发条件判断
-- 只触发一次
function Buff.trigger.once(buff)
	if not(buff.trigger.done) then
		buff.trigger.done = true
		buff.counter.done = true
		return true
	else
		return false
	end
end
-- 始终触发
function Buff.trigger.always(buff)
	return true
end
-- 攻击次数触发
function Buff.trigger.attackCount(buff)
	if not(buff.trigger.currentAttack) then buff.trigger.currentAttack = 0 end
	if buff.trigger.currentAttack == buff.trigger.count then
		buff.trigger.currentAttack = 0
		return true
	else 
		return false
	end
end
-- 间隔时间触发
function Buff.trigger.frameCount(buff)
	if not(buff.trigger.currentFrame) then buff.trigger.currentFrame = 0 end
	if buff.trigger.currentFrame == buff.trigger.count then
		buff.trigger.currentFrame = 0
		return true
	else 
		return false
	end
end
-- 概率触发
function Buff.trigger.ratio(buff)
	if math.random() <= buff.trigger.ratio then
		return true
	else
		return false
	end
end



-- 初始化函数
function Buff.initChangeAttackSpeed()
	function Buff.changeAttackSpeed.beforeFrame(buff,object)
		object:changeAttackSpeed(buff.parameter.ratio)
	end
end

function Buff.initStun()
	function Buff.stun.beforeFrame(buff,object)
		object:beStuned()
	end
end

function Buff.initRepel()
	function Buff.repel.beforeFrame(buff,object)
		object:beRepeled(buff.parameter.direction,buff.parameter.length,buff.parameter.height,buff.parameter.time)	
	end
end

function Buff.initPoison()
	function Buff.poison.beforeFrame(buff,object)
		local beAttacked = {damage = {},buff = {}}
		beAttacked.damage.source = buff.source
		beAttacked.damage.value = buff.parameter.value
		beAttacked.damage.type = buff.parameter.type
		beAttacked.damage.critical = false
		beAttacked.damage.criticalFactor = 1
		beAttacked.damage.beDodged = false
		beAttacked.damage.accuracy = 2
		beAttacked.damage.area = false
		beAttacked.damage.areaRange = 0
		object:beAttacked(beAttacked)
	end
end

-- 向别的目标添加带特效的攻击
function Buff.initDamageEffectSource(buff,object)
	function Buff.damageEffectSource.beforeFrame(buff,object)
		local enemyGroup = ""
		if object:getGroup() == "attacker" then enemyGroup = "defender" end
		if object:getGroup() == "defender" then enemyGroup = "attacker" end
		
		if buff.parameter.targetMode == "floor" then
			print("floor = " .. object:getPosition().floor)
			local target = BattleManager.findRandomTargetByFloor(enemyGroup,object:getPosition().floor)
			local damageEffect =  BattleManager.Buff.creat(buff.parameter.buff,object:getItemID(),nil)
			if BattleManager.roleArray[target] then BattleManager.roleArray[target]:addBuff(damageEffect) end
		end
		if buff.parameter.targetMode == "hotel" then
			local target = BattleManager.findRandomTarget(enemyGroup)
			local damageEffect = BattleManager.Buff.creat(buff.parameter.buff,object:getItemID(),nil)
			if BattleManager.roleArray[target] then BattleManager.roleArray[target]:addBuff(damageEffect) end
		end
	end
end

-- 处理带特效的攻击
function Buff.initDamageEffect(buff,object)
	function Buff.damageEffect.beforeFrame(buff,object)
		-- 添加受到攻击
		local beAttacked = {damage = {},buff = {}}
		beAttacked.damage.source = buff.source
		beAttacked.damage.value = buff.parameter.value
		beAttacked.damage.type = buff.parameter.type
		beAttacked.damage.critical = false
		beAttacked.damage.criticalFactor = 1
		beAttacked.damage.beDodged = false
		beAttacked.damage.accuracy = 2
		beAttacked.damage.area = false
		beAttacked.damage.areaRange = 0
		object:beAttacked(beAttacked)
		-- 加入受到攻击特效
		object:addRenderBuff(buff.parameter.effectName)
	end
end


print("CreatBuff -- Success")
return Buff