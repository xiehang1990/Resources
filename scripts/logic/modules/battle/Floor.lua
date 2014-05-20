local Floor = {
	tendency = "",
	totalFloor = 0,
	usingStep = "",
}

-- 初始化函数
function Floor.init(floorData)
	Floor.tendency = floorData.tendency
	Floor.totalFloor = floorData.totalFloor
	Floor.totalLine = floorData.totalLine
	Floor.usingStep = ""
	Floor.line = clone(floorData.line)
	-- 初始化各楼层
	for i,_ in ipairs(floorData.floor) do
		Floor[i] = clone(floorData.floor[i])
		Floor[i].attackerClear = true
		Floor[i].defenderClear = true
		Floor[i].floorClear = true
		Floor[i].line = {}
		Floor[i].line.attacker = {}
		Floor[i].line.defender = {}
		Floor[i].line.attacker.short = {}
		Floor[i].line.defender.short = {}
		Floor[i].line.attacker.long = {}
		Floor[i].line.defender.long = {}
		for j,_ in ipairs(Floor.line) do
			Floor[i].line.attacker.short[j] = ""
			Floor[i].line.defender.short[j] = ""
			Floor[i].line.attacker.long[j] = ""
			Floor[i].line.defender.long[j] = ""
		end
	end
end

-- 获取线的便宜量
function Floor.getLineShift(lineNumber)
	return clone(Floor.line[lineNumber])
end

-- 寻找转换楼层
function Floor.floorShift(group,currentFloor)
	local targetFloor = currentFloor
	-- 优先下楼
	if Floor.tendency == "downStair" then
		local find = false		
		for i = currentFloor-1,1,-1 do
			if group == "attacker" then
				if not(Floor[i].defenderClear) then
					targetFloor = i
					find = true
					break
				end
			end
			if group == "defender" then
				if not(Floor[i].attackerClear) then
					targetFloor = i
					find = true
					break
				end
			end
		end
		if not(find) then
			for i = currentFloor+1,Floor.totalFloor do
				if group == "attacker" then
					if not(Floor[i].defenderClear) then
						targetFloor = i
						find = true
						break
					end
				end
				if group == "defender" then
					if not(Floor[i].attackerClear) then
						targetFloor = i
						find = true
						break
					end
				end
			end
		end
	end
	-- 优先上楼
	if Floor.tendency == "upStair" then
		local find = false		
		for i = currentFloor+1,Floor.totalFloor do
			if group == "attacker" then
				if not(Floor[i].defenderClear) then
					targetFloor = i
					find = true
					break
				end
			end
			if group == "defender" then
				if not(Floor[i].attackerClear) then
					targetFloor = i
					find = true
					break
				end
			end
		end
		if not(find) then
			for i = currentFloor-1,1,-1 do
				if group == "attacker" then
					if not(Floor[i].defenderClear) then
						targetFloor = i
						find = true
						break
					end
				end
				if group == "defender" then
					if not(Floor[i].attackerClear) then
						targetFloor = i
						find = true
						break
					end
				end
			end
		end
	end
	return targetFloor
end



-- 寻找空闲的线
function Floor.caculateLine(group,weaponStyle,floor)
	for _,v in ipairs(Floor.line.priority) do
		--print(v)
		--print(Floor[floor].line[group][weaponStyle][v])
		if Floor[floor].line[group][weaponStyle][v] == "" then
			return v
		end
	end
end

-- 设置线被占据
function Floor.setLine(group,weaponStyle,floor,line,roleID)
	Floor[floor].line[group][weaponStyle][line] = roleID
	print(roleID .. ":  " .. floor .. "  " .. line)
end

-- 解除线被占据
function Floor.clearLine(group,weaponStyle,floor,line)
	Floor[floor].line[group][weaponStyle][line] = ""
end

print("CreatFloor -- Success")
return Floor