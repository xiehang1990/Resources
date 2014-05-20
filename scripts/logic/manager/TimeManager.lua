local socket = require "socket"

local TimeManager = {
	--游戏时间控制器
	loginGameTime = 0,
	loginServerTime = 0,
	loginLocalTime = 0,
	timeOffset = 0,
	originLocalTime = 0,
	realTime = 0,
}
-- 一、初始化函数
function TimeManager.init(timeData)
	-- 初始化数据
	TimeManager.loginGameTime = timeData.loginGameTime
	TimeManager.loginServerTime = timeData.loginServerTime
	TimeManager.loginLocalTime = math.floor(socket.gettime()*1000)
	TimeManager.timeOffset = TimeManager.loginServerTime - TimeManager.loginLocalTime
	TimeManager.originLocalTime = 0
	TimeManager.realTime = 0
	TimeManager.gameTime = 0

	TimeManager.daySection = "day"

	TimeManager.updateGameTime()

	--暂存TimeManager中的参数
	TimeManager.todayRent = 0

	function update()
		TimeManager.updateGameTime()
	end

	--实时更新时间
	CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(update, 0, false)
	
	-- 输出初始化结果
	--dump(TimeManager,"TimeManager")
end

-- 二、更新本地游戏时间
function TimeManager.updateLocalTime()
	TimeManager.originLocalTime = math.floor(socket.gettime()*1000)

	TimeManager.realTime = TimeManager.originLocalTime+TimeManager.timeOffset
end
-- 三、更新玩家游戏时间
function TimeManager.updateGameTime()
	--
	local tempTime = TimeManager.gameTime

	TimeManager.updateLocalTime()

	local passedTime = (TimeManager.loginGameTime+TimeManager.realTime-TimeManager.loginServerTime)/1000

	TimeManager.gameTime = math.floor(passedTime)%SECONDS_PER_DAY + 1 + (passedTime-math.floor(passedTime))

	--一天结束，结算的时候到了
	if math.floor(tempTime) == SECONDS_PER_DAY and math.floor(TimeManager.gameTime) == 1 then
        --一天结束，收租
        local dayRent = PlayerManager.Hotel.collectAllRoomRent()
        PlayerManager.Basic.changeGold(dayRent)
        TimeManager.todayRent = dayRent
        CCNotificationCenter:sharedNotificationCenter():postNotification(COLLECT_RENT, nil)
	end

	if TimeManager.gameTime < DUSK_START_TIME then
		TimeManager.daySection = "day"
	elseif TimeManager.gameTime < NIGHT_START_TIME then
		TimeManager.daySection = "day"
	else
		TimeManager.daySection = "night"
	end

end

print("CreatTimeManager -- Success")
return TimeManager