local Skill = {
	--[[
	skillTemplate = {
		onCreat = function() end,         
		beforeFrame = function() end,
		afterFrame = function() end,
		beforeAttack = function() end,
		afterAttack = function() end,
		beforeDamage = function() end,
		afterDamage = function() end,
		onDamageApply = function()	end,
		onKillTarget = function() end,
		onStateChange = function() end,
		invokeSkill = function() end,
	},
	--]]

	trigger = {},

	vampire = {},
	killVampire = {},
	poison = {},
	critical = {},
	accuracy = {},
	dodge = {},
	rage = {},
	stun = {},
	repel = {},

	changeTotalHP = {},
	changeAttackDamage = {},
	changeSkillDamage = {},
	changePhysicalDefense = {},
	changeMagicDefense = {},
	changeDefense = {},
	changeAttackSpeed = {},
	changeCritical = {},
	changeDodge = {},
	changeAccuracy = {},

	damageEffectSource = {},

	skillAttack = {},
	
}

function Skill.init()
	Skill.initVampire()
	Skill.initKillVampire()
	Skill.initPoison()
	Skill.initCritical()
	Skill.initAccuracy()
	Skill.initDodge()
	Skill.initRage()
	Skill.initStun()

	Skill.initChangeTotalHP()

	Skill.initDamageEffectSource()

	Skill.initSkillAttack()
end
-------------------------------------------------------------------------------------------------------------
-- 一、技能的入口
function Skill.run(condition,skill,sourceObject,targetObject,...)
	-- 判定技能是否触发
	if skill.trigger.condition == condition then
		if Skill.trigger[skill.trigger.mode](skill) then
			if skill.needInvoke then sourceObject:invoke(skill.needPause) end
			for i,v in ipairs(skill) do
				skill.needExecute = true
			end
		end
	end
	-- 执行已触发的技能
	for i,v in ipairs(skill) do
		if Skill[v.skillName][condition] and skill.needExecute then
			Skill[v.skillName][condition](v,sourceObject,targetObject,...)
			skill.needExecute = false
		end
	end
end

-- 各状态的调用示例
--[[
function Skill.onCreat(skillName,skill,sourceObject)end
function Skill.beforeAttack(skillName,skill,sourceObject,targetObject)end
function Skill.afterAttack(skillName,skill,sourceObject,targetObject)end
function Skill.beforeDamage(skillName,skill,sourceObject,targetObject,damage)end
function Skill.afterDamage(skillName,skill,sourceObject,targetObject,damage,deductedHP)end
function Skill.onDamageApply(skillName,skill,sourceObject,targetObject,damage,deductedHP)end
--]]
-------------------------------------------------------------------------------------------------
-- 二、技能触发条件判断
-- 始终触发
function Skill.trigger.always(skill)
	return true
end
-- 攻击次数触发
function Skill.trigger.attackCount(skill)
	if not(skill.trigger.currentAttack) then skill.trigger.currentAttack = 0 end
	if skill.trigger.currentAttack == skill.trigger.count then
		skill.trigger.currentAttack = 0
		return true
	else 
		return false
	end
end
-- 间隔时间触发
function Skill.trigger.frameCount(skill)
	if not(skill.trigger.currentFrame) then skill.trigger.currentFrame = 0 end
	if skill.trigger.currentFrame == skill.trigger.count then
		skill.trigger.currentFrame = 0
		return true
	else 
		return false
	end
end
-- 概率触发
function Skill.trigger.ratio(skill)
	if math.random() <= skill.trigger.ratio then
		return true
	else
		return false
	end
end

-------------------------------------------------------------------------------------------------------
-- 以下为各技能的初始化函数
-- 三、自身buff类技能
-- 狂暴技能初始化函数
function Skill.initRage()
	function Skill.rage.beforeFrame(skill,sourceObject,targetObject)
		local changeAttackSpeed = BattleManager.Buff.creat(skill.buff,nil,nil)
		sourceObject:addBuff(changeAttackSpeed)
	end		
end

-------------------------------------------------------------------------------------------------------
-- 四、附加buff类技能
-- 中毒技能初始化函数
function Skill.initPoison()
	function Skill.poison.beforeAttack(skill,sourceObject,targetObject)
		local poison = BattleManager.Buff.creat(skill.buff,sourceObject:getItemID(),nil)
		sourceObject:addAttackBuff(poison)
	end
end

-- 眩晕技能初始化函数
function Skill.initStun()
	function Skill.stun.beforeAttack(skill,sourceObject,targetObject)
		local stun = BattleManager.Buff.creat(skill.buff,nil,nil)
		sourceObject:addAttackBuff(stun)
	end
end
--[[
-- 击退技能初始化函数
function Skill.initRepel()
	function Skill.repel.invokeSkill(skill,sourceObject,targetObject)
		skill.buff.parameter.direction = sourceObject:getDirection()
		local repel = BattleManager.Buff.creat(skill.buff,nil,nil)
		sourceObject:addAttackBuff(repel)
	end
end
--]]
----------------------------------------------------------------------------------------
-- 五、其他类技能
-- 吸血技能初始化函数
function Skill.initVampire()
	function Skill.vampire.onDamageApply(skill,sourceObject,targetObject,damage,deductedHP)
		if damage.type ~= "skill" then
			sourceObject:changeHP(deductedHP*skill.parameter.ratio)
			sourceObject:addToNumberArray(deductedHP*skill.parameter.ratio, "vampire")
		end
	end
end
-- 击杀吸血技能初始化函数
function Skill.initKillVampire()
	function Skill.killVampire.onKillTarget(skill,sourceObject,targetObject)
		local addHP = targetObject:getTotalHP()*skill.parameter.ratio
		sourceObject:changeHP(addHP)
		sourceObject:addToNumberArray(addHP, "vampire")
	end
end
-- 暴击技能初始化函数
function Skill.initCritical()
	function Skill.critical.beforeAttack(skill,sourceObject,targetObject)
		sourceObject:setCriticalFactor(skill.parameter.factor)
	end
end
-- 命中率技能初始化函数
function Skill.initAccuracy()
	function Skill.accuracy.beforeAttack(skill,sourceObject,targetObject)
		sourceObject:changeAccuracy(skill.parameter.ratio)
	end
end
-- 闪避率技能初始化函数
function Skill.initDodge()
	function Skill.dodge.beforeDamage(skill,sourceObject,targetObject,damage)
		if not(damage.dodge) then
			-- 判断是否强制命中
			if math.random() > damage.accuracy - 1 then
				-- 如果不强制命中，则根据闪避率决定是否闪避
				if math.random() < skill.parameter.ratio then
					damage.dodge = true
				end
			end
		end
	end
end
-- 改变最大血量值函数
function Skill.initChangeTotalHP()
	function Skill.changeTotalHP.onCreat(skill,sourceObject)
		sourceObject:changeTotalHP(sourceObject:getTotalHP()*skill.parameter.ratio)
		sourceObject:changeHP(sourceObject:getTotalHP()*skill.parameter.ratio)
	end
end
-- 多重带特效的随机打击（他妈的，就是月骑的大）
function Skill.initDamageEffectSource()
	function Skill.damageEffectSource.invokeSkill(skill,sourceObject)
		local damageEffectSource = BattleManager.Buff.creat(skill.buff,nil,nil)
		sourceObject:addBuff(damageEffectSource)
	end
end

-- 带Buff的技能攻击
function Skill.initSkillAttack()
	function Skill.skillAttack.invokeSkill(skill,sourceObject,targetObject)
		-- 创建攻击参数数据
		local attackParameter = {
			damage = {
				source = sourceObject:getItemID(), 
				value = skill.parameter.skillDamage, 
				type = "skill",
				critical = false,
				criticalFactor = 1,
				beDodged = false,
				accuracy = 2,
				area = skill.parameter.area,
				areaRange = skill.parameter.areaRange,
			},
			buff = {},
		}
		for i,v in ipairs(skill.parameter.buff) do
			attackParameter.buff[i] = clone(v)
			attackParameter.buff[i].parameter.direction = sourceObject:getDirection()
		end
		-- 判定变换后的目标是否存在，是否存活
		if targetObject then
			-- 近程攻击处理函数
			if skill.parameter.weaponStyle == "short" then		
				-- 非范围攻击
				if not(skill.parameter.area) then
					targetObject:beAttacked(attackParameter)
				end
				-- 范围攻击
				if skill.parameter.area then
					local targetGroup = ""
					if sourceObject:getDirection() == "left" then 
						XRange1 = sourceObject:getPosition().X - skill.parameter.areaRange
						XRange2 = sourceObject:getPosition().X
					end
					if sourceObject:getDirection() == "right" then 
						XRange1 = sourceObject:getPosition().X + skill.parameter.areaRange
						XRange2 = sourceObject:getPosition().X
					end
					if sourceObject:getGroup() == "attacker" then targetGroup = "defender" end
					if sourceObject:getGroup() == "defender" then targetGroup = "attacker" end
					local targetArray = BattleManager.findAreaTarget(sourceObject:getPosition().floor,XRange1,XRange2,targetGroup)
					for _,v in pairs(targetArray) do
						v:beAttacked(attackParameter)
					end
				end			
			end
			-- 远程攻击处理函数
			if skill.parameter.weaponStyle == "long" then
				local position = sourceObject:getPosition()
				local bulletParameter = {
					group = sourceObject:getGroup(),
					bulletName = skill.parameter.bulletName,				
					position = {
						X = position.X + sourceObject:getSkillBulletShift().X,
						Y = position.Y + sourceObject:getSkillBulletShift().Y,
						floor = position.floor,
					},
					direction = sourceObject:getDirection(),
					target = targetObject:getItemID(),
					range = skill.parameter.range,
					attackParameter = attackParameter,
				}
				BattleManager.creatBullet(bulletParameter)
			end
		end
	end
end
--]]


print("CreatSkillClass -- Success")
return Skill