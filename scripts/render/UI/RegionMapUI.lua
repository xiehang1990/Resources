
--[[--

区域地图界面

视图注册模型事件，从而在模型发生变化时自动更新视图

]]

RegionMapUI = class()

local ccs = require ("ccs")

function RegionMapUI:ctor(superView)
    self.node = GUIReader:shareReader():widgetFromJsonFile("ziyuandian-4-10_1.ExportJson")
    self.superView = superView

    self.maxZ = 3

end

function RegionMapUI:init(reginMapID)
    --add funciton

    --退出按钮
    function removeFun(sender, eventType)
        if eventType == ccs.TouchEventType.ended then
            self.superView.secondLevelMenuLayer:removeWidget(self.node)
            self.superView:removeSecondLevelUICallBack()
        end
    end

    local removeButton = self.superView.secondLevelMenuLayer:getWidgetByName("Button_close")
    removeButton:addTouchEventListener(removeFun)

    function searchResoursePoint(sender, eventType)
        if eventType == ccs.TouchEventType.ended then
            local battleScene = BattleScene:new()
            battleScene:init()
            CCDirector:sharedDirector():pushScene(battleScene.scene)
        end
    end

    local zhuziButton = self.superView.secondLevelMenuLayer:getWidgetByName("Button_zhuzi")
    zhuziButton:addTouchEventListener(searchResoursePoint)
    zhuziButton.name = "zhuzi"

end

function RegionMapUI:loadData()
    --load room data

end
