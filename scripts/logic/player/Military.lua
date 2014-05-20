local Military = {}

function Military.init(militaryData)
	Military.formationArray = clone(militaryData.formationArray)
	Military.fighterArray = {}
	Military.enemyArray = {}
end

function Military.setBattleInitData(group,enemyForce)
	Military.initFighterArray()
	Military.initEnemyArray(enemyForce)
	local battleInitData = {}
	local selfFormation = Military.formationArray[Military.formationArray.currentFormation]
	if group == "attacker" then
		battleInitData.attacker = Military.solveFormation(selfFormation,Military.fighterArray)
		battleInitData.defender = Military.solveFormation(enemyForce.formation,Military.enemyArray)
	end
	if group == "defender" then
		battleInitData.attacker = Military.solveFormation(enemyForce.formation,Military.enemyArray)
		battleInitData.defender = Military.solveFormation(selfFormation,Military.fighterArray)
	end
	DataManager.setBattleInitData(battleInitData)
end

-- 初始化打手数组
function Military.initFighterArray()
	-- 获取打手数组
	for _,v in pairs(PlayerManager.Hotel.tenantArray) do
		local fighter = {
			roleID = v.roleID,

			level = v.battle.level,
			strength = v.battle.strength,
			intelligence = v.battle.intelligence,
			physique = v.battle.physique,
			skillArray = clone(v.battle.skillArray),
			--moveSpeed = u.battle.moveSpeed,					

			totalHP = v.battle.totalHP,
			attack = v.battle.attack,
			physicalAttack = v.battle.physicalAttack,
			magicAttack = v.battle.magicAttack,
			physicalDefense = v.battle.physicalDefense,
			magicDefense = v.battle.magicDefense,
		}
		Military.fighterArray[#Military.fighterArray + 1] = clone(fighter)
	end
end
-- 初始化敌人数组
function Military.initEnemyArray(enemyForce)
	for _,v in pairs(enemyForce.fighterArray) do
		local fighter = {
			roleID = v.roleID,

			level = v.level,
			strength = v.strength,
			intelligence = v.intelligence,
			physique = v.physique,
			skillArray = clone(v.skillArray),
			--moveSpeed = u.tenant.battle.moveSpeed,

			totalHP = 0,
			attack = 0,
			physicalAttack = 0,
			magicAttack = 0,
			physicalDefense = 0,
			magicDefense = 0,
		}
		fighter.totalHP = math.ceil(fighter.physique * (fighter.level+10)*1.5)
		fighter.attack = math.ceil(fighter.strength * (fighter.level+10) * 0.35)
		fighter.physicalAttack = math.ceil(fighter.strength * (fighter.level+10) * 0.15)
		fighter.magicAttack = math.ceil(fighter.intelligence * (fighter.level+10) * 0.15)
		fighter.physicalDefense = math.ceil((fighter.physique+fighter.strength)/2 * (fighter.level+10)*0.1)
		fighter.magicDefense = math.ceil((fighter.physique+fighter.intelligence)/2 * (fighter.level+10)*0.1)

		Military.enemyArray[#Military.enemyArray + 1] = clone(fighter)
	end
end

-- 进行阵型数据格式的转换
function Military.solveFormation(formation,fighterArray)
	local tempFighter = clone(fighterArray)
	for i,v in ipairs(formation) do
		for j,u in ipairs(v) do
			if u ~= 0 then
				tempFighter[u].position = {i,j}
			end
		end
	end
	return tempFighter
end

-- 战斗
function Military.battle()
	BattleManager.setBattleInitData(DataManager.getBattleInitData())
	DataManager.setBattleResultData(BattleManager.run())
end

-- 获取阵型某位置的打手ID
function Military.getFighterIDByFormation(floor,location)
	return Military.formationArray[Military.formationArray.currentFormation][floor][location]
end

-- 获取某ID的打手
function Military.getFighterByID(fighterID)
	return clone(Military.fighterArray[fighterID])
end

-- 获取阵型某位置的打手
function Military.getFighterByFormation(floor,location)
	return Military.getFighterByID(Military.getFighterIDByFormation(floor,location))
end

-- 升级某个打手
function Military.upgradeFighter(fighterID)
	-- body
end

-- 升级阵型某位置的打手

-- 改变上场打手
function Military.changeFighter(fighterID,backupFighter)
	-- body
end

-- 改变阵型
function Military.changeFormation(position1,position2)
	-- body
end
-- 打手改变装备
function Military.changeEquipment()
	-- body
end

print("CreatMilitaryClass -- Success")
return Military