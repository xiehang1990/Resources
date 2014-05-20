
--[[--

等待租客界面,入住、等待、驱逐

视图注册模型事件，从而在模型发生变化时自动更新视图

]]

WaitingTenantUI = class()

local ccs = require ("ccs")

local roleModel = require("roleModelData")

function WaitingTenantUI:ctor(superView)

    self.node = GUIReader:shareReader():widgetFromJsonFile("information- tenant_1.ExportJson")

    self.superView = superView

    self.selectFloor = 0
    self.selectRoom = 0

end

function WaitingTenantUI:init(waitTenantID)
    --add funciton
    self.waitTenantID = waitTenantID

    --退出按钮
    function removeFromSuperView(sender, eventType)
        if eventType == ccs.TouchEventType.ended then
            self.superView.secondLevelMenuLayer:removeWidget(self.node)
            self.superView:removeSecondLevelUICallBack()
        end
    end
    local removeButton = self.superView.secondLevelMenuLayer:getWidgetByName("Button_close")
    removeButton:addTouchEventListener(removeFromSuperView)

    --入住按钮
    function checkInFun(sender, eventType)
        if eventType == ccs.TouchEventType.ended then
            if self.selectFloor == 0 and self.selectRoom == 0 then
                print("请选择房间")
            else
                if PlayerManager.Hotel.getRoomOccupied(self.selectFloor, self.selectRoom) then
                    print("房间有人")
                else
                    self.superView.secondLevelMenuLayer:removeWidget(self.node)
                    self.superView:removeSecondLevelUICallBack()
                    self.superView:checkTenantIn(self.waitTenantID, self.selectFloor, self.selectRoom)
                end
            end
        end
    end
    local rzButton = self.superView.secondLevelMenuLayer:getWidgetByName("Button_rz")
    rzButton:addTouchEventListener(checkInFun)

    --驱逐按钮
    function makeLeaveFun(sender, eventType)
        if eventType == ccs.TouchEventType.ended then
            self.superView.secondLevelMenuLayer:removeWidget(self.node)
            self.superView:removeSecondLevelUICallBack()
            self.superView:makeWaitingTenantLeave(self.waitTenantID)
        end
    end
    local qzButton = self.superView.secondLevelMenuLayer:getWidgetByName("Button_qz")
    qzButton:addTouchEventListener(makeLeaveFun)

    --等待按钮
    local waitButton = self.superView.secondLevelMenuLayer:getWidgetByName("Button_wait")
    waitButton:addTouchEventListener(removeFromSuperView)

    self.roomButtonArray = {}

    --底板
    local bottomPanel = self.superView.secondLevelMenuLayer:getWidgetByName("ImageView_bottom")

    --选择标记
    self.selectedMark = ImageView:create()
    self.selectedMark:loadTexture("room-xuanzhong.png")
    self.selectedMark:setAnchorPoint(CCPoint(0.5, 0.5))
    self.selectedMark:setZOrder(5)
    self.selectedMark:setVisible(false)
    self.node:addChild(self.selectedMark)

    --tapRoom
    function tapRoomButton(sender, eventType)
        if eventType == ccs.TouchEventType.ended then
            self.selectRoom = sender.roomNum
            self.selectFloor = sender.floorNum

            --加选择标记
            self.selectedMark:setPositionX(sender:getPositionX())
            self.selectedMark:setPositionY(sender:getPositionY())
            self.selectedMark:setVisible(true)

            print("tapRoom:", sender.floorNum, sender.roomNum)
        end
    end

    --房间按钮

    for i = 1, 3 do
        for j = 1, 4 do
            local roomName = string.format("room-%d0%d", i, j)
            local roomButton = tolua.cast(self.superView.secondLevelMenuLayer:getWidgetByName(roomName),"Button")
            roomButton:addTouchEventListener(tapRoomButton)
            roomButton.floorNum = i
            roomButton.roomNum = j
            self.roomButtonArray[#self.roomButtonArray+1] = roomButton

            if PlayerManager.Hotel.getRoom(roomButton.floorNum, roomButton.roomNum) then
                if PlayerManager.Hotel.getRoomOccupied(roomButton.floorNum, roomButton.roomNum) then
                    roomButton:setTouchEnabled(false)
                    local widgetSize = roomButton:getSize()

                    local occupiedMark = ImageView:create()
                    occupiedMark:loadTexture("you-ren.png")
                    occupiedMark:setAnchorPoint(CCPoint(0.5, 0.5))
                    occupiedMark:setPosition(CCPoint(3, -10))
                    roomButton:addChild(occupiedMark)
                    roomButton.occupiedMark = occupiedMark
                end
            else
                roomButton:setTouchEnabled(false)
                roomButton:setBright(false)
            end

            
        end
    end

    --加载租客信息
    self:loadData()
end

function WaitingTenantUI:loadData()
    --load room data
    --获取租客信息
    print("等待租客编号",self.waitTenantID)
    self.tenant = PlayerManager.Hotel.getAWaitTenant(self.waitTenantID)

    --local avatarView = tolua.cast(self.superView.secondLevelMenuLayer:getWidgetByName("ImageView_avatar-tufei1"),"ImageView")
    --avatarView:loadTexture(string.format("avatar-%s-l.png", self.tenant.roleID))
    --avatarView:setVisible(false)

    --加载租客名字
    local nameLabel = tolua.cast(self.superView.secondLevelMenuLayer:getWidgetByName("nameLabel"),"Label")
    nameLabel:setText(self.tenant.role.name)

    local spriteName = self.tenant.roleID
    local scale = roleModel[spriteName].baseScale*1.5
    CCArmatureDataManager:sharedArmatureDataManager():
    addArmatureFileInfo(string.format("%s.ExportJson", spriteName))
    self.armature = CCArmature:create(spriteName)
    self.animation = self.armature:getAnimation()
    self.animation:play("load1")
    self.armature:setPosition(ccp(800,350))
    self.armature:setScaleX(scale)
    self.armature:setScaleY(math.abs(scale))
    self.node:addNode(self.armature)
end
