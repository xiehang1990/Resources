
--[[--

房间界面

视图注册模型事件，从而在模型发生变化时自动更新视图

]]

RoomUI = class()

local socketRequests = require("socketRequests")
local roleModel = require("roleModelData")

require ("labelsManager")

local ccs = require ("ccs")

function RoomUI:ctor(superView)
    --self.baseSprite = CCSprite:create()
    self.node = GUIReader:shareReader():widgetFromJsonFile("room_1.ExportJson")

    --self.baseSprite:addChild(self.node)
    self.superView = superView

end

function RoomUI:init(floorNum, roomNum)
    --add funciton
    self.room = PlayerManager.Hotel.roomArray[floorNum][roomNum]

    self.roomNum = roomNum
    self.floorNum = floorNum
    self.roomIndex = (floorNum-1)*4+roomNum

    --Button_tuichu
    function removeFromSuperView(sender, eventType)
        if eventType == ccs.TouchEventType.ended then
            self.superView.secondLevelMenuLayer:removeWidget(self.node)
            self.superView:removeSecondLevelUICallBack()
        end
    end
    local removeButton = self.superView.secondLevelMenuLayer:getWidgetByName("Button_tuichu")
    removeButton:addTouchEventListener(removeFromSuperView)

    --Button_quzhu
    function checkOutFun(sender, eventType)
        if eventType == ccs.TouchEventType.ended then
            self.superView:tenantCheckOut(self.floorNum, self.roomNum)
            self.superView.secondLevelMenuLayer:removeWidget(self.node)
            self.superView:removeSecondLevelUICallBack()
        end
    end
    local Button_quzhu = self.superView.secondLevelMenuLayer:getWidgetByName("Button_quzhu")
    Button_quzhu:addTouchEventListener(checkOutFun)

    --房间升级
    function upgradeFun(sender, eventType)
        if eventType == ccs.TouchEventType.ended then
            self:upgradeRoomRequest()
        end
    end
    local shengjiButton = self.superView.secondLevelMenuLayer:getWidgetByName("Button_shengji")
    shengjiButton:addTouchEventListener(upgradeFun)

    self:loadData()
end

function RoomUI:loadData()
    --load room data
    self:updateRoomUI()

    self.tenant = PlayerManager.Hotel.getTenantByRoom(self.floorNum, self.roomNum)
    
    if self.tenant == nil then
        return
    end

    self.subNode = GUIReader:shareReader():widgetFromJsonFile("room-tenant-right_1.ExportJson")
    self.subNode:setZOrder(5)
    self.subNode:setPosition(CCPoint(518,51))

    self.node:addChild(self.subNode)

    --[[local tenantView = TenantView.new( self.tenant, 0, self)
    tenantView:initSprite()
    tenantView.baseSprite:setZOrder(50)
    self.subNode:addNode(tenantView.baseSprite)]]--

    local spriteName = self.tenant.roleID
    local scale = roleModel[spriteName].baseScale*1.5
    CCArmatureDataManager:sharedArmatureDataManager():
    addArmatureFileInfo(string.format("%s.ExportJson", spriteName))
    self.armature = CCArmature:create(spriteName)
    self.animation = self.armature:getAnimation()
    self.animation:play("load1")
    self.armature:setPosition(ccp(90,150))
    self.armature:setScaleX(-scale)
    self.armature:setScaleY(math.abs(scale))
    self.subNode:addNode(self.armature)


    print(self.tenant.task.state)
    if self.tenant.task.state == "ready" then
        self.tenant:taskReceived()
    end

    local task = self.tenant:getTask()

    --提交按钮
    function submitTask(sender, eventType)
        if eventType == ccs.TouchEventType.ended then
            
            if self.tenant.task.state=="doing" then

                self.tenant:taskDone()
                self:updateTenantUI()

                print(self.tenant.task.state)
                --
                local rewards = {}
                rewards[1] = {rewardType = "jinbi", value = task.reward.BasicReward.gold}
                rewards[2] = {rewardType = "weiwang", value = task.reward.BasicReward.gold}

                showRwardLabels(rewards)
            end
        end
    end

    local submitButton = tolua.cast(self.superView.secondLevelMenuLayer:getWidgetByName("Button_tijiao"),"Button")
    submitButton:addTouchEventListener(submitTask)

    --头像按钮 
    
    local avatarButton = tolua.cast(self.superView.secondLevelMenuLayer:getWidgetByName("touxiang-mianban"),"Button")

    avatarButton:loadTextures(string.format("avatar-%s-s-1.png", self.tenant.roleID),
     string.format("avatar-%s-s-2.png", self.tenant.roleID), "")

    self:updateTenantUI()
end

function RoomUI:updateRoomUI()
    --加载房间信息
    local roomRentLabel = tolua.cast(self.superView.secondLevelMenuLayer:getWidgetByName("roomRentLabel"),"LabelAtlas")
    local roomLevelLabel = tolua.cast(self.superView.secondLevelMenuLayer:getWidgetByName("roomLevelLabel"),"LabelAtlas")

    roomLevelLabel:setStringValue(string.format("%d",self.room.level))
    roomRentLabel:setStringValue(string.format("%d",self.room.roomRent))

    --加载家居信息
    for i=1,8 do
        local button = tolua.cast(self.superView.secondLevelMenuLayer:getWidgetByName(string.format("Button_jiaju_%d", i)),"Button")
        if self.room.furnitureNum < i then
            button:loadTextures("furnitureLock.png","","")
            button:setTouchEnabled(false)
        else
            button:loadTextures("furniture2.png","furniture1.png","")
            button:setTouchEnabled(false)
        end
    end
    
end

function RoomUI:updateTenantUI()
    --加载租客基本信息
    --租客名字
    local nameLabel = tolua.cast(self.superView.secondLevelMenuLayer:getWidgetByName("Label_name"),"Label")
    nameLabel:setText(self.tenant.role.name)
    --租客好感度等级
    local Label_haogandu = tolua.cast(self.superView.secondLevelMenuLayer:getWidgetByName("Label_haogandu"),"Label")
    Label_haogandu:setText(self.tenant.role.friendshipLevel)
    --租客好感度
    local Bar_haogandu = tolua.cast(self.superView.secondLevelMenuLayer:getWidgetByName("Bar_haogandu"),"LoadingBar")
    Bar_haogandu:setPercent(self.tenant.role.currentFriendShipValueLeft/self.tenant.role.nextFriendshipLevelNeeded*100)

    --加载租客任务信息
    --加载物品
    local Button_item1 = tolua.cast(self.superView.secondLevelMenuLayer:getWidgetByName("Button_item1"),"Button")
    local Button_item2 = tolua.cast(self.superView.secondLevelMenuLayer:getWidgetByName("Button_item2"),"Button")
    local Button_item3 = tolua.cast(self.superView.secondLevelMenuLayer:getWidgetByName("Button_item3"),"Button")

    local item1NumLabel = tolua.cast(self.superView.secondLevelMenuLayer:getWidgetByName("item1NumLabel"),"LabelAtlas")
    local item2NumLabel = tolua.cast(self.superView.secondLevelMenuLayer:getWidgetByName("item2NumLabel"),"LabelAtlas")
    local item3NumLabel = tolua.cast(self.superView.secondLevelMenuLayer:getWidgetByName("item3NumLabel"),"LabelAtlas")

    local item1ImageView = tolua.cast(self.superView.secondLevelMenuLayer:getWidgetByName("item1ImageView"),"ImageView")
    local item2ImageView = tolua.cast(self.superView.secondLevelMenuLayer:getWidgetByName("item2ImageView"),"ImageView")
    local item3ImageView = tolua.cast(self.superView.secondLevelMenuLayer:getWidgetByName("item3ImageView"),"ImageView")

    Button_item1:setVisible(false)
    Button_item2:setVisible(false)
    Button_item3:setVisible(false)

    item1NumLabel:setVisible(false)
    item2NumLabel:setVisible(false)
    item3NumLabel:setVisible(false)

    item1ImageView:setVisible(false)
    item2ImageView:setVisible(false)
    item3ImageView:setVisible(false)

    local task =  self.tenant:getTask()

    --修改提交按钮
    local submitButton = tolua.cast(self.superView.secondLevelMenuLayer:getWidgetByName("Button_tijiao"),"Button")

    if self.tenant.task.state=="ready" or self.tenant.task.state=="doing" then
        --加载任务描述
        local talkLabel = tolua.cast(self.superView.secondLevelMenuLayer:getWidgetByName("talkLabel"),"Label")
        talkLabel:setText(task.description)

        local taskItems = self.tenant:getTask().article

        if taskItems then
            for k,v in pairs(taskItems) do
                if k == 1 then
                    --
                    Button_item1:setVisible(true)
                    item1NumLabel:setVisible(true)
                    item1ImageView:setVisible(true)

                    local hadNum = PlayerManager.Storage.checkItem(v.id)
                    local needNum = v.num
                    item1NumLabel:setStringValue(string.format("%d/%d",hadNum,needNum))

                    item1ImageView:loadTexture(string.format("%s.png",v.id))
                end

                if k == 2 then
                    --
                    Button_item2:setVisible(true)
                    item2NumLabel:setVisible(true)
                    item2ImageView:setVisible(true)

                    local hadNum = PlayerManager.Storage.checkItem(v.id)
                    local needNum = v.num
                    item2NumLabel:setStringValue(string.format("%d/%d",hadNum,needNum))

                    item2ImageView:loadTexture(string.format("%s.png",v.id))
                end

                if k == 3 then
                    --
                    Button_item3:setVisible(true)
                    item3NumLabel:setVisible(true)
                    item3ImageView:setVisible(true)

                    local hadNum = PlayerManager.Storage.checkItem(v.id)
                    local needNum = v.num
                    item3NumLabel:setStringValue(string.format("%d/%d",hadNum,needNum))

                    item3ImageView:loadTexture(string.format("%s.png",v.id))
                end

            end
        end

        --判断任务是否完成
        task:update()

        if self.tenant.task.state=="doing" then
            submitButton:setTouchEnabled(true)
            submitButton:setBright(true)
        else
            submitButton:setTouchEnabled(false)
            submitButton:setBright(false)
        end

    else
        --加载日常描述
        local talkLabel = tolua.cast(self.superView.secondLevelMenuLayer:getWidgetByName("talkLabel"),"Label")
        local tempTalk = self.tenant:getRandomDescription()
        talkLabel:setText(tempTalk)

        submitButton:setEnabled(false)
    end
end

--========================房间功能========================
--升级房间请求
function RoomUI:upgradeRoomRequest()
    print("房间升级")
    if OFFLINE == true then
        --单机模式
        self:upgradeRoomDone()
    else
        --联网模式
        socketRequests["upgradeRoom"](self.roomIndex)
    end
end

--升级房间完成
function RoomUI:upgradeRoomDone()
    --更新房间数据
    if self.room:upgradeRoom() then
        print("房间升级成功")
        self:updateRoomUI()
    else
        print("房间升级失败")
    end

    --更新资源数据


    --更新UI

end

