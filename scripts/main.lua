require "AudioEngine" 
require "debug"
require "functions"
require "Config"

require "LuaSocket"

DataManager = require("DataManager")
DataManager.init()
BattleManager = require("BattleManager")
PlayerManager = require("PlayerManager")
TimeManager = require("TimeManager")

-- 将CSV文件转换为数据文件
--DataManager.initConvert()
--DataManager.convertData()
-- 初始化数据

require "BuffView"
require "BulletView"
require "FighterViewInBattle"
require "BattleScene"
require "PVPScene"
require "MapScene"
require "HotelScene"

local socketRequests = require("socketRequests")

-- for CCLuaEngine traceback
function __G__TRACKBACK__(msg)
    print("----------------------------------------")
    print("LUA ERROR: " .. tostring(msg) .. "\n")
    print(debug.traceback())
    print("----------------------------------------")
end

local function main()
    -- avoid memory leak
    collectgarbage("setpause", 100)
    collectgarbage("setstepmul", 5000)

    local cclog = function(...)
        print(string.format(...))
    end
    ---------------

    -- run
    --local hotelScene = HotelScene:new()

    function runHotelScene()
        local hotelScene = HotelScene:new()
        hotelScene:init()
        CCDirector:sharedDirector():runWithScene(hotelScene.scene)
    end

    --
    if OFFLINE == true then
        --单机模式
        runHotelScene()
    else
        --联网模式
        CCNotificationCenter:sharedNotificationCenter():registerScriptObserver(nil, runHotelScene, LOGIN_DONE)
        socketRequests["selectServer_getList"]()
    end
    
end

xpcall(main, __G__TRACKBACK__)
