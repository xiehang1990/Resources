-- XML数据
local floorData = {
	tendency = "downStair",
	totalFloor = 3,
	totalLine = 5,
	floor = {},
	line = {},
}

floorData.floor[1] = {
	floor = 1,
	--Y = 57,
	Y = 80,
	height = 140,
	bulletRange = {
		leftBound = -100,
		rightBound = 1300,
	},
	roleRange = {
		leftBound = 100,
		rightBound = 860,
	},
}

floorData.floor[2] = {
	floor = 2,
	--Y = 234,
	Y = 200,
	height = 140,
	bulletRange = {
		leftBound = -100,
		rightBound = 1300,
	},
	roleRange = {
		leftBound = 100,
		rightBound = 860,
	},
}

floorData.floor[3] = {
	floor = 3,
	--Y = 412,
	Y = 320,
	height = 140,
	bulletRange = {
		leftBound = -100,
		rightBound = 1300,
	},
	roleRange = {
		leftBound = 100,
		rightBound = 860,
	},
}

floorData.line.priority = {3,4,2,5,1}

floorData.line[1] = {YShift = -0,XShift = 40}
floorData.line[2] = {YShift = -0,XShift = 20}
floorData.line[3] = {YShift = 0,XShift = 0}
floorData.line[4] = {YShift = 0,XShift = -20}
floorData.line[5] = {YShift = 0,XShift = -40}

print("LoadFloorData -- Success")
return floorData