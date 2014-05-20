
--[[--

背包界面

视图注册模型事件，从而在模型发生变化时自动更新视图

]]

BagUI = class()

local ccs = require ("ccs")

function BagUI:ctor(superView)
    self.node = GUIReader:shareReader():widgetFromJsonFile("bag 56_1.ExportJson")
    self.superView = superView

    self.maxZ = 3

end

function BagUI:init()
    --add funciton

    --退出按钮
    local function removeFun(sender, eventType)
        if eventType == ccs.TouchEventType.ended then
            self.superView.secondLevelMenuLayer:removeWidget(self.node)
            self.superView:removeSecondLevelUICallBack()
        end
    end

    local removeButton = self.superView.secondLevelMenuLayer:getWidgetByName("Button_x")
    removeButton:addTouchEventListener(removeFun)

    --自动整理
    local function resetFun(sender, eventType)
        if eventType == ccs.TouchEventType.ended then
            PlayerManager.Storage.reset()
            self:clear()
            self:loadData()
        end
    end

    local resetButton = self.superView.secondLevelMenuLayer:getWidgetByName("Button_reset")
    resetButton:addTouchEventListener(resetFun)

    local scrollView = tolua.cast(self.superView.secondLevelMenuLayer:getWidgetByName("ScrollView_36"),"ScrollView")
    scrollView:setClippingEnabled(true)

    self:loadData()

end

function BagUI:clear()
    for i=1,6 do
        for j=1,6 do
            local button = tolua.cast(self.superView.secondLevelMenuLayer:getWidgetByName(string.format("Button_slot_%d_%d", i, j)),"Button")
            if button.itemImage then
                button.itemImage:setVisible(false)
            end
            if button.numLabel then
                button.numLabel:setVisible(false)
            end
        end
    end
end

function BagUI:loadData()
    --load room data
    local resource = PlayerManager.Storage.getItemArray()

    dump(PlayerManager.Storage.getItemArray())

    for k,v in pairs(resource.material) do
        print(k)
        local rowNum = math.floor(k/6)+1
        local queueNum = (k-1)%6+1

        --添加物品格子
        local button = tolua.cast(self.superView.secondLevelMenuLayer:getWidgetByName(string.format("Button_slot_%d_%d", rowNum, queueNum)),"Button")
        --物品图片
        if not button.itemImage then
            local itemImage = ImageView:create()
            button.itemImage = itemImage
            button:addChild(button.itemImage)
        end
        button.itemImage:loadTexture(string.format("%s.png", v.itemName))
        button.itemImage:setVisible(true)
        

        --物品数量
        if not button.numLabel then
            local numLabel = LabelAtlas:create()
            button.numLabel = numLabel
            button:addChild(button.numLabel)
        end
        button.numLabel:setProperty(string.format("%d", v.amount), "numLabel.png", 46, 58, "/")
        button.numLabel:setScale(0.4)
        button.numLabel:setPosition(CCPoint(25, -35))
        button.numLabel:setVisible(true)
    end
end
