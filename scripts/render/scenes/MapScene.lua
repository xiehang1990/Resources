
--[[--

“Map”的视图

视图注册模型事件，从而在模型发生变化时自动更新视图

]]

MapScene = class()

SpriteMaxZ = 100

require ("WorldMapUI")
require ("RegionMapUI")

local ccs = require ("ccs")

local playerData = require("playerData")

function MapScene:ctor()

    self.scene = CCScene:create()
    self.visibleSize = CCDirector:sharedDirector():getVisibleSize()
    self.origin = CCDirector:sharedDirector():getVisibleOrigin()
    self.dragThreshold = 1

end

--二级界面出现时调用
function MapScene:addSecondLevelUICallBack()
    self.menuLayer:setTouchEnabled(false)
    self.secondLevelMenuLayer:setTouchEnabled(true)
end

--二级界面消失时调用
function MapScene:removeSecondLevelUICallBack()
    self.menuLayer:setTouchEnabled(true)
    self.secondLevelMenuLayer:setTouchEnabled(false)
end

--添加区域地图界面
function MapScene:addRegionMapUI(reginMapID)
    self:addSecondLevelUICallBack()

    local regionMapUI = RegionMapUI.new(self)
    self.secondLevelMenuLayer:addWidget(regionMapUI.node)
    regionMapUI:init(reginMapID)
end


function MapScene:init() 

    self:loadData()

    --添加基础层
    self.baseLayer = CCLayer:create()
    self.scene:addChild(self.baseLayer)

    --添加一级菜单层
    self.menuLayer = TouchGroup:create()
    self.menuLayer:setAnchorPoint(ccp(0, 0))
    self.menuLayer:setZOrder(5000)
    self.baseLayer:addChild(self.menuLayer)

    --添加二级菜单层
    self.secondLevelMenuLayer = TouchGroup:create()
    self.secondLevelMenuLayer:setAnchorPoint(ccp(0, 0))
    self.secondLevelMenuLayer:setZOrder(6000)
    self.baseLayer:addChild(self.secondLevelMenuLayer)
    self.secondLevelMenuLayer:setTouchEnabled(false)

    --添加Map界面
    local worldMapUI = WorldMapUI.new(self)
    self.menuLayer:addWidget(worldMapUI.node)
    worldMapUI:init()



    --CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(updateScene, 0, false)
    
end

function MapScene:loadData() 
    --读取地图数据
end


