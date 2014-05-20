
--[[--

“hotel”的视图

视图注册模型事件，从而在模型发生变化时自动更新视图

]]

HotelScene = class()

SpriteMaxZ = 100

require "TenantView"
require "FighterView"
require "SunView"

require ("RoomUI")
require ("WorldMapUI")
require ("WaitingTenantUI")
require ("BagUI")
require ("labelsManager")

local ccs = require ("ccs")

local roleModel = require("roleModelData")
--local playerData = require("playerData")

local socketRequests = require("socketRequests")

function HotelScene:ctor()

    self.scene = CCScene:create()
    self.visibleSize = CCDirector:sharedDirector():getVisibleSize()
    self.origin = CCDirector:sharedDirector():getVisibleOrigin()
    self.dragThreshold = 1

end

function HotelScene:init() 

    self:loadData()

    local node = SceneReader:sharedSceneReader():createNodeWithSceneFile("HotelScene.json")
    if nil == node then
        return
    end
    self._curNode = node

    local winSize = CCDirector:sharedDirector():getWinSize()
    local scale = winSize.height / 640
    self._curNode:setScale(scale)
    self._curNode:setPosition(ccp((winSize.width - 960 * scale) / 2, (winSize.height - 640 * scale) / 2))

    --添加基础层
    self.baseLayer = CCLayer:create()
    self.baseLayer:addChild(self._curNode)
    self.scene:addChild(self.baseLayer)

    --注册触摸事件
    local function onTouchEvent(eventType, x, y)
        if eventType == "began" then
            return self:onTouchBegan(x, y)
        elseif eventType == "moved" then
            self:onTouchMoved(x, y)
        elseif eventType == "ended" then
            self:onTouchEnded(x,y)
        elseif eventType == "cancelled" then
            self:onTouchCancelled(x, y)
        end
    end

    self.baseLayer:setTouchEnabled(true)
    self.baseLayer:registerScriptTouchHandler(onTouchEvent)

    local rootLayer = self.baseLayer:getChildByTag(10000)

    self.groundLayer = node:getChildByTag(10005)--("groundLayer")
    self.farLayer = node:getChildByTag(10012)--("farLayer")
    self.midLayer = node:getChildByTag(10011)--("midLayer")
    self.nearLayer = node:getChildByTag(10015)--("nearLayer")

    local farBkg = tolua.cast(self.farLayer:getChildByTag(10008):getComponent("CCSprite"),"CCComRender")
    local midBkg = tolua.cast(self.midLayer:getChildByTag(10004):getComponent("CCSprite"),"CCComRender")
    local groundL = tolua.cast(self.groundLayer:getChildByTag(10006):getComponent("CCSprite"),"CCComRender")
    local groundR = tolua.cast(self.groundLayer:getChildByTag(10007):getComponent("CCSprite"),"CCComRender")

    self.farBkgImage = farBkg:getNode()
    self.midBkgImage = midBkg:getNode()
    self.groundLImage = groundL:getNode()
    self.groundRImage = groundR:getNode()

    self.screenLength = self.visibleSize.width
    self.farLength = self.farBkgImage:getContentSize().width
    self.midLength = self.midBkgImage:getContentSize().width
    self.groundLength = self.groundLImage:getContentSize().width + self.groundRImage:getContentSize().width
    self.nearLength = self.groundLength+200

    self.screenOffset = -490
    self:updateLayer()

    --添加太阳
    self.sunView = SunView.new()
    self.sunView:initSprite()
    self.farBkgImage:addChild(self.sunView.baseSprite)

    --添加酒店
    self.hotel = GUIReader:shareReader():widgetFromJsonFile("hotel.ExportJson")
    self.hotel:setZOrder(50)
    self.hotel:setPositionX(900)
    self.hotel:setPositionY(40)
    self.hotel:setScale(1.0)
    self.hotelLayer = TouchGroup:create()
    self.hotelLayer:setZOrder(50)
    self.groundLayer:addChild(self.hotelLayer)
    self.hotelLayer:addWidget(self.hotel)
    local floor1Panel = self.hotelLayer:getWidgetByName("floor1Panel")
    local floor2Panel = self.hotelLayer:getWidgetByName("floor2Panel")
    local floor3Panel = self.hotelLayer:getWidgetByName("floor3Panel")

    floor1Panel:setVisible(true)
    floor2Panel:setVisible(false)
    floor3Panel:setVisible(false)

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

    --add UI
    self:addUI()

    --打手数组
    self.fightersArray = {}
    
    --等待租客数组
    self.waitingTenantArray = {}

    --租客数组
    self.tenantArray = {}

    --离店租客数组
    self.leavingTenantArray = {}

    self:addSprites()

    --用于昼夜变换
    self.colorR = 255
    self.colorG = 255
    self.colorB = 255

    self.daySection = TimeManager.daySection

    function updateScene()
        self:updateScene()
    end

    --update

    CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(updateScene, 0, false)

    --添加有人标识
    self:addRoomMark()

    --收取房租
    function showRentCollect()
        --
        if CCDirector:sharedDirector():getRunningScene() == self.scene then
            local rewards = {}
            rewards[1] = {rewardType = "jinbi", value = TimeManager.todayRent}

            showRwardLabels(rewards)
        end
    end

    CCNotificationCenter:sharedNotificationCenter():registerScriptObserver(nil, showRentCollect, COLLECT_RENT)
    
end

function HotelScene:onTouchBegan(x,y)
    self.drag = {
        currentX = x,
        currentY = y,
        startX = x,
        startY = y,
        isTap = true,
    }

    return true
end

function HotelScene:onTouchMoved(x,y)
    if self.drag.isTap and math.abs(x - self.drag.startX) >= self.dragThreshold then
        self.drag.isTap = false
    end

    if not self.drag.isTap then
        self.screenOffset = self.screenOffset - self.drag.currentX + x

        if self.screenOffset > 0 then
            self.screenOffset = 0
        end

        if self.screenOffset < self.visibleSize.width - self.groundLength  then
            self.screenOffset = self.visibleSize.width - self.groundLength
        end

        self:updateLayer()
    end

    self.drag.currentX = x
    self.drag.currentY = y    
end

function checkPointInRect(centerX, centerY, width, height, x, y)
    if x >= centerX-width/2 and x <= centerX+width/2 and y >= centerY-height/2 and y <= centerY+height/2 then
        --todo
        return true
    end

    return false
end

--进入房间界面
function HotelScene:enterRoom(roomNumI, roomNumJ)
    self:addSecondLevelUICallBack()

    local roomUI = RoomUI.new(self)
    self.secondLevelMenuLayer:addWidget(roomUI.node)
    roomUI:init(roomNumI, roomNumJ)
    self.secondLevelMenuLayer:setTouchEnabled(true)

end

--进入租客等待界面
function HotelScene:callWaitingTenantUI(waitTenantID)
    
    --self.menuLayer:addChild(CCLayerColor:create(ccc4(0, 0, 0, 111)))
    self:addSecondLevelUICallBack()

    local waitingTenantUI = WaitingTenantUI.new(self)
    self.secondLevelMenuLayer:addWidget(waitingTenantUI.node)
    waitingTenantUI:init(waitTenantID)
    self.secondLevelMenuLayer:setTouchEnabled(true)

end

--二级界面出现时调用
function HotelScene:addSecondLevelUICallBack()
    self.baseLayer:setTouchEnabled(false)
    self.menuLayer:setTouchEnabled(false)
end

--二级界面消失时调用
function HotelScene:removeSecondLevelUICallBack()
    self.baseLayer:setTouchEnabled(true)
    self.menuLayer:setTouchEnabled(true)
end

--点击等待租客
function HotelScene:tapWaitingTenant(tenentView)
    print("tapTenant", tenentView.roleData.itemID)

    self:callWaitingTenantUI(tenentView.roleData.itemID)
end

--打开房门
function HotelScene:openDoorOfRoom(floor,room)
    local doorImage = tolua.cast(self.hotelLayer:getWidgetByName(string.format("door%d0%d", floor, room)),"ImageView")
    doorImage:setVisible(false)
end

--关闭房门
function HotelScene:closeDoorOfRoom(floor,room)
    local doorImage = tolua.cast(self.hotelLayer:getWidgetByName(string.format("door%d0%d", floor, room)),"ImageView")
    doorImage:setVisible(true)
end


--更新房间标识
function HotelScene:updateRoomMark()
    for i = 1, PlayerManager.Hotel.floorNum do
        for j = 1, 4 do
            local doorImage = tolua.cast(self.hotelLayer:getWidgetByName(string.format("door%d0%d", i, j)),"ImageView")
            
            if PlayerManager.Hotel.getRoomOccupied(i, j) then
                local tenant = PlayerManager.Hotel.getTenantByRoom(i, j)
                doorImage.avatarImage:loadTexture(string.format("avatar-%s-ss.png",tenant.roleID))
                doorImage.roomOccupiedMark:setVisible(true)
                doorImage.avatarImage:setVisible(true)
            else
                doorImage.roomOccupiedMark:setVisible(false)
                doorImage.avatarImage:setVisible(false)
            end
        end
    end
end

--添加房间标识
function HotelScene:addRoomMark()

    for i = 1, 3 do
        for j = 1, 4 do
            local doorImage = tolua.cast(self.hotelLayer:getWidgetByName(string.format("door%d0%d", i, j)),"ImageView")
    
            local roomOccupiedMark = ImageView:create()
            roomOccupiedMark:loadTexture("roomOccupiedMark.png")
            roomOccupiedMark:setPosition(CCPoint(-6,20))
            roomOccupiedMark:setZOrder(20000)
            roomOccupiedMark:setVisible(false)
            doorImage:addChild(roomOccupiedMark)

            doorImage.roomOccupiedMark = roomOccupiedMark

            local avatarImage = ImageView:create() 
            avatarImage:setPosition(CCPoint(-6,20))
            avatarImage:setZOrder(20001)
            avatarImage:setVisible(false)
            doorImage:addChild(avatarImage)

            doorImage.avatarImage = avatarImage
        end
    end

end


--处理点击事件
function HotelScene:onTouchEnded(x,y)

    if self.drag.isTap == true then
        
        local _x = x-self.screenOffset
        local _y = y

        print("tap:", _x, _y)

        --检测房间点击
        local hotelOffsetX = 900
        local hotelOffsetY = 40

        --进入房间之前
        function beforeEnterRoom(sender)
            sender:setVisible(false)
        end

        --进入房间
        function enteringRoom(sender)
            self:enterRoom(sender.floor, sender.room)
        end

        --进入房间之后
        function afterEnterRoom(sender)
            sender:setVisible(true)
        end

        for i = 1, PlayerManager.Hotel.floorNum do
            for j = 1, 4 do
                local _centerX = hotelOffsetX+140*(j-1)+235
                local _centerY = hotelOffsetY+175*(i-1)+115

                local _width = 80
                local _height = 110

                if checkPointInRect(_centerX, _centerY, _width, _height, _x, _y) then

                    local doorImage = tolua.cast(self.hotelLayer:getWidgetByName(string.format("door%d0%d", i, j)),"ImageView")
                    --doorImage:loadTexture()
                    doorImage:setVisible(false)
                    doorImage.floor = i
                    doorImage.room = j

                    --添加开门动画
                    local array = CCArray:create()
                    array:addObject(CCCallFuncN:create(beforeEnterRoom))
                    array:addObject(CCDelayTime:create(0.1))
                    array:addObject(CCCallFuncN:create(enteringRoom))
                    array:addObject(CCDelayTime:create(0.1))
                    array:addObject(CCCallFuncN:create(afterEnterRoom))
                    local action = CCSequence:create(array)
                    doorImage:runAction(action)

                    return
                end
            end
        end

        --检测等待租客点击
        for i,v in pairs(self.waitingTenantArray) do
            local _width = 100
            local _height = 120

            local _centerX = v.baseSprite:getPositionX()
            local _centerY = v.baseSprite:getPositionY()+_height/2

            if checkPointInRect(_centerX, _centerY, _width, _height, _x, _y) then
                self:tapWaitingTenant(v)
            end
        end

    end
end

function HotelScene:onTouchCancelled(x,y)
    print("touchCancel")
end

--加载用户数据
function HotelScene:loadData()
    DataManager.init()

    --读取玩家数据
    PlayerManager.init(DataManager.playerData)

    --初始化时间戳信息
    TimeManager.init(DataManager.playerData.time)
    
    --dump(DataManager.playerData)

    print("PlayerManagerInit --  Success")
    -- 战斗！！！！！！！ 全员警戒！！！！！
    PlayerManager.World.executeSector("aoLaiGuo","aoLaiGuo1")
end

--昼夜变换函数
function HotelScene:dayNightSwitch(speed)

    --按照游戏时间进行昼夜变换
    local colorR = 255
    local colorG = 255
    local colorB = 255

    if TimeManager.daySection == "dusk" then
        colorR = 255
        colorG = 255
        colorB = 140
    end

    if TimeManager.daySection == "night" then
        colorR = 140
        colorG = 140
        colorB = 215
    end

    if self.colorR == colorR and self.colorB == colorB and self.colorG == colorG then
        self.daySection = TimeManager.daySection
        return true
    end

    local changeSpeed = speed

    if math.abs(self.colorR-colorR) < changeSpeed then
        self.colorR = colorR
    else
        self.colorR = self.colorR-changeSpeed*math.abs(self.colorR-colorR)/(self.colorR-colorR)
    end

    if math.abs(self.colorG-colorG) < changeSpeed then
        self.colorG = colorG
    else
        self.colorG = self.colorG-changeSpeed*math.abs(self.colorG-colorG)/(self.colorG-colorG)
    end

    if math.abs(self.colorB-colorB) < changeSpeed then
        self.colorB = colorB
    else
        self.colorB = self.colorB-changeSpeed*math.abs(self.colorB-colorB)/(self.colorB-colorB)
    end

    tolua.cast(self.farBkgImage,"CCSprite"):setColor(ccc3(self.colorR, self.colorG, self.colorB))
    tolua.cast(self.midBkgImage,"CCSprite"):setColor(ccc3(self.colorR, self.colorG, self.colorB))
    tolua.cast(self.groundLImage,"CCSprite"):setColor(ccc3(self.colorR, self.colorG, self.colorB))
    tolua.cast(self.groundRImage,"CCSprite"):setColor(ccc3(self.colorR, self.colorG, self.colorB))

    local floor1Panel = self.hotelLayer:getWidgetByName("floor1Panel")
    for i=0, floor1Panel:getChildrenCount()-1 do
        tolua.cast(floor1Panel:getChildren():objectAtIndex(i),"Widget"):setColor(ccc3(self.colorR, self.colorG, self.colorB))
    end

    local floor2Panel = self.hotelLayer:getWidgetByName("floor2Panel")
    for i=0, floor2Panel:getChildrenCount()-1 do
        tolua.cast(floor2Panel:getChildren():objectAtIndex(i),"Widget"):setColor(ccc3(self.colorR, self.colorG, self.colorB))
    end
end

--更新UI信息
function HotelScene:updateUI()
    --时间刷新 得写进专门的计时器类
    self.timerLabel:setString(string.format("%dS", TimeManager.gameTime))

    if self.daySection ~= TimeManager.daySection then
        self:dayNightSwitch(1)
    end

    --更新太阳
    self.sunView:updateSprite()

    --更新金钱
    local goldLabel = tolua.cast(self.menuLayer:getWidgetByName("goldLabel"),"Label")
    goldLabel:setText(string.format("%d",PlayerManager.Basic:getGold()))

    local diamondLabel = tolua.cast(self.menuLayer:getWidgetByName("diamondLabel"),"Label")
    diamondLabel:setText(string.format("%d",PlayerManager.Basic:getDiamond()))

    local powerLabel = tolua.cast(self.menuLayer:getWidgetByName("powerLabel"),"Label")
    powerLabel:setText(string.format("%d",PlayerManager.Basic:getEnergy()))

    local floor1Panel = self.hotelLayer:getWidgetByName("floor1Panel")
    local floor2Panel = self.hotelLayer:getWidgetByName("floor2Panel")
    local floor3Panel = self.hotelLayer:getWidgetByName("floor3Panel")

    if PlayerManager.Hotel.floorNum >= 1 then
        floor1Panel:setVisible(true)
    end
    if PlayerManager.Hotel.floorNum >= 2 then
        floor2Panel:setVisible(true)
    end
    if PlayerManager.Hotel.floorNum >= 3 then
        floor3Panel:setVisible(true)
    end
end

--更新场景中精灵位置
function HotelScene:updateScene()
    --update sprites
    self:updateUI()

    for i,v in pairs(self.fightersArray) do
        v:updateInHotel()
    end

    for i,v in pairs(self.waitingTenantArray) do
        v:updateInHotel()
    end

    for i,v in pairs(self.tenantArray) do
        v:updateInHotel()
    end

    for i,v in pairs(self.leavingTenantArray) do
        if v.hasLeft == false then
            v:updateInHotel()
        else
            self.groundLayer:removeChild(v.baseSprite, true)
            v = nil
        end
        
    end

    self:updateRoomMark()
end

--更新场景位置
function HotelScene:updateLayer()
    self.groundLayer:setPositionX(self.screenOffset)
    self.farLayer:setPositionX(self.screenOffset*
        (1-(self.groundLength-self.farLength)/(self.groundLength-self.screenLength)))
    self.midLayer:setPositionX(self.screenOffset*
        (1-(self.groundLength-self.midLength)/(self.groundLength-self.screenLength)))
    self.nearLayer:setPositionX(self.screenOffset*
        (1-(self.groundLength-self.nearLength)/(self.groundLength-self.screenLength)))
end

--添加主菜单
function HotelScene:addUI()
    --加载主菜单按钮
    self.widget = GUIReader:shareReader():widgetFromJsonFile("hotelUI.ExportJson")
    self.menuLayer:addWidget(self.widget)
    self.hiddeButtons = false

    --倒计时Label
    self.timerLabel = CCLabelBMFont:create("Test", "fonts/futura-48.fnt")
    self.timerLabel:setString(string.format("%dS", 0))
    self.timerLabel:setScale(0.8)
    self.timerLabel:setAnchorPoint(ccp(0.0, 0.5))
    self.timerLabel:setPosition(ccp(40, 280))
    self.timerLabel:setVisible(true)
    self.menuLayer:addChild(self.timerLabel)

    local buttonArray = {}

    local bottomPanel1 = self.menuLayer:getWidgetByName("bottomPanel1")
    local bottomPanel2 = self.menuLayer:getWidgetByName("bottomPanel2")
    local topPanel = self.menuLayer:getWidgetByName("topPanel")

    --PVPButton
    local function enterBattle(sender, eventType)
        if eventType == ccs.TouchEventType.ended then
            local pvpScene = PVPScene:new()
            pvpScene:init()
            CCDirector:sharedDirector():pushScene(pvpScene.scene)
        end
    end

    --酒店升级
    local function upgradeHotel(sender, eventType)
        if eventType == ccs.TouchEventType.ended then
            self:upgradeHotelRequest()
        end
    end

    local PVPButton = self.menuLayer:getWidgetByName("PVPButton")
    PVPButton:addTouchEventListener(enterBattle)
    buttonArray[#buttonArray+1] = PVPButton

    --robButton
    local robButton = self.menuLayer:getWidgetByName("robButton")
    robButton:addTouchEventListener(upgradeHotel)
    buttonArray[#buttonArray+1] = robButton

    --worldMap
    local function enterWorldMap(sender, eventType)
        if eventType == ccs.TouchEventType.ended then
            local mapScene = MapScene:new()
            mapScene:init()
            CCDirector:sharedDirector():pushScene(mapScene.scene)
        end
    end

    --settingButton
    local settingButton = self.menuLayer:getWidgetByName("settingButton")
    buttonArray[#buttonArray+1] = settingButton

    --friendsButton
    local friendsButton = self.menuLayer:getWidgetByName("friendsButton")
    buttonArray[#buttonArray+1] = friendsButton

    --formationButton
    local formationButton = self.menuLayer:getWidgetByName("formationButton")
    buttonArray[#buttonArray+1] = formationButton

    --fighterButton
    local fighterButton = self.menuLayer:getWidgetByName("fighterButton")
    buttonArray[#buttonArray+1] = fighterButton

    --包裹
    local function enterBag(sender, eventType)
        if eventType == ccs.TouchEventType.ended then
            self:addSecondLevelUICallBack()

            local bagUI = BagUI.new(self)
            self.secondLevelMenuLayer:addWidget(bagUI.node)
            bagUI:init()
            self.secondLevelMenuLayer:setTouchEnabled(true)
        end
    end

    --bagButton
    local bagButton = self.menuLayer:getWidgetByName("bagButton")
    bagButton:addTouchEventListener(enterBag)
    buttonArray[#buttonArray+1] = bagButton

    --WIKIButton
    local WIKIButton = self.menuLayer:getWidgetByName("WIKIButton")
    buttonArray[#buttonArray+1] = WIKIButton

    --acievementButton
    local acievementButton = self.menuLayer:getWidgetByName("acievementButton")
    buttonArray[#buttonArray+1] = acievementButton

    --menuButton
    local menuButton = self.menuLayer:getWidgetByName("menuButton")
    menuButton:setRotation(-45)

    --mailButton
    local mailButton = self.menuLayer:getWidgetByName("mailButton")
    buttonArray[#buttonArray+1] = mailButton

    --taskButton
    local taskButton = self.menuLayer:getWidgetByName("taskButton")
    taskButton:addTouchEventListener(enterWorldMap)
    buttonArray[#buttonArray+1] = taskButton 
    
    --onlineGiftButton
    local onlineGiftButton = self.menuLayer:getWidgetByName("onlineGiftButton")
    buttonArray[#buttonArray+1] = onlineGiftButton

    --activityButton
    local activityButton = self.menuLayer:getWidgetByName("activityButton")
    buttonArray[#buttonArray+1] = activityButton

    --marketButton 
    local marketButton  = self.menuLayer:getWidgetByName("marketButton")
    buttonArray[#buttonArray+1] = marketButton

    --everydayTaskButton 
    local everydayTaskButton  = self.menuLayer:getWidgetByName("everydayTaskButton")
    buttonArray[#buttonArray+1] = everydayTaskButton
    
    local function ButtonHiddeCallback(sender)
        sender:setEnabled(false)
    end

    local function hiddeButtons(sender, eventType)
        if eventType == ccs.TouchEventType.ended then
            local moveLen = 50
            local moveTime = 0.2
            local panel1_moveOut = CCMoveTo:create(moveTime, ccp(552+moveLen, -52))
            local panel1_moveIn = CCMoveTo:create(moveTime, ccp(552, -52))
            local panel2_moveOut = CCMoveTo:create(moveTime, ccp(796, 185-moveLen))
            local panel2_moveIn = CCMoveTo:create(moveTime, ccp(796, 185))
            local topPanel_moveOut = CCMoveTo:create(moveTime, ccp(504, 485+moveLen))
            local topPanel_moveIn = CCMoveTo:create(moveTime, ccp(504, 485))
            local fadeOut = CCFadeOut:create(moveTime)
            local fadeIn = CCFadeIn:create(moveTime)

            if self.hiddeButtons == false then
                 self.hiddeButtons = true

                --hiddeButtons
                local array1 = CCArray:create()
                array1:addObject(panel1_moveOut)
                array1:addObject(CCCallFuncN:create(ButtonHiddeCallback))

                local array2 = CCArray:create()
                array2:addObject(panel2_moveOut)
                array2:addObject(CCCallFuncN:create(ButtonHiddeCallback))

                local array3 = CCArray:create()
                array3:addObject(topPanel_moveOut)
                array3:addObject(CCCallFuncN:create(ButtonHiddeCallback))

                bottomPanel1:runAction(CCSequence:create(array1))
                bottomPanel2:runAction(CCSequence:create(array2))
                topPanel:runAction(CCSequence:create(array3))

                local rotate = CCRotateTo:create(moveTime, 0)
                menuButton:runAction(rotate)  

                for i,v in pairs(buttonArray) do

                    local array = CCArray:create()
                    array:addObject(CCFadeOut:create(moveTime))
                    array:addObject(CCCallFuncN:create(ButtonHiddeCallback))
                    local action = CCSequence:create(array)
                    v:runAction(action)

                    v:setTouchEnabled(false)
                end 
            else
                self.hiddeButtons = false

                --showButtons
                bottomPanel1:setEnabled(true)
                bottomPanel2:setEnabled(true)
                topPanel:setEnabled(true)

                bottomPanel1:runAction(panel1_moveIn)
                bottomPanel2:runAction(panel2_moveIn)
                topPanel:runAction(topPanel_moveIn)

                local rotate = CCRotateTo:create(moveTime, -45)
                menuButton:runAction(rotate)

                for i,v in pairs(buttonArray) do
                    v:setEnabled(true)
                    v:runAction(CCFadeIn:create(moveTime))
                    v:setTouchEnabled(true)
                end
            end

        end
    end

    menuButton:addTouchEventListener(hiddeButtons)
end

function HotelScene:addSprites()
    --[[--取打手阵容数据
    local _military = PlayerManager.Military
    local fighters = _military.solveFormation(
        _military.formationArray[_military.formationArray.currentFormation],_military.fighter)

    --添加打手
    for i,v in pairs(fighters) do
        local fighter = FighterView.new(v)
        fighter:initSprite()
        self.groundLayer:addChild(fighter.baseSprite)
        self.fightersArray[#self.fightersArray+1] = fighter
    end]]--

    --获取租客等待队列
    local waitingTenants = PlayerManager.Hotel.getWaitTenantArray()
    local waitTenantNumber = 0
    --添加等待租客
    for _,v in pairs(waitingTenants) do
        waitTenantNumber = waitTenantNumber + 1
        local tenantView = TenantView.new(v,waitTenantNumber,self)
        tenantView:initSprite()
        self.groundLayer:addChild(tenantView.baseSprite)
        self.waitingTenantArray[#self.waitingTenantArray+1] = tenantView
    end

    --添加租客
    for i = 1, PlayerManager.Hotel.floorNum do
        for j = 1, 4 do
            local tenant = PlayerManager.Hotel.getTenantByRoom(i, j)

            if tenant then
                local tenantView = TenantView.new(tenant,-1,self)
                tenantView.floor = i
                tenantView.room = j
                tenantView:initSprite()
                self.groundLayer:addChild(tenantView.baseSprite)
                self.tenantArray[(i-1)*4+j] = tenantView
            end
        end
    end
    
end

--=========================================功能函数===============================================
--=======================================酒店相关功能==============================================
--升级酒店请求
function HotelScene:upgradeHotelRequest()
    print("酒店升级")
    if OFFLINE == true then
        --单机模式
        self:upgradeHotelDone()
    else
        --联网模式
        socketRequests["upgradeHotel"]()
    end
end

--升级酒店完成
function HotelScene:upgradeHotelDone()
    --更新酒店数据
    if PlayerManager.Hotel.upgradeHotel() then
        print("酒店升级成功")
    else
        print("酒店升级失败")
    end

    --更新资源数据


    --更新UI

end

--=======================================租客相关功能=============================================
--按ID获取已入住租客
function HotelScene:tenantWithID(itemID)
    for k,v in pairs(self.tenantArray) do
        if v.roleData.itemID == itemID then
            return v
        end
    end

    return nil
end

--按ID获取等待租客
function HotelScene:waitTenantWithID(itemID)
    for k,v in pairs(self.waitingTenantArray) do
        if v.roleData.itemID == itemID then
            return v
        end
    end

    return nil
end

--使租客入住
function HotelScene:checkTenantIn(waitTenantID, floor, roomNum)
    local waitTenant = self:waitTenantWithID(waitTenantID)
    self.tenantArray[(floor-1)*4+roomNum] = waitTenant
    waitTenant = nil

    self.tenantArray[(floor-1)*4+roomNum].state = "backRoom"
    self.tenantArray[(floor-1)*4+roomNum].floor = floor
    self.tenantArray[(floor-1)*4+roomNum].room = roomNum

    PlayerManager.Hotel.addLiveFromWait(waitTenantID,floor,roomNum)
    print(self.tenantArray[(floor-1)*4+roomNum].roleData.roleID)
end

--租客离店
function HotelScene:tenantCheckOut(floor, roomNum)
    if self.tenantArray[(floor-1)*4+roomNum] == nil then
        print("empty room")
        return
    end

    self.tenantArray[(floor-1)*4+roomNum].state = "leave"

    self.leavingTenantArray[#self.leavingTenantArray+1] = self.tenantArray[(floor-1)*4+roomNum]
    self.tenantArray[(floor-1)*4+roomNum] = nil

    PlayerManager.Hotel.checkOut(floor, roomNum)
end


--驱逐租客
function HotelScene:makeWaitingTenantLeave(waitTenantID)
    self.waitingTenantArray[waitTenantID].state = "leave"

    self.leavingTenantArray[#self.leavingTenantArray+1] = self.waitingTenantArray[waitTenantID]
    self.waitingTenantArray[waitTenantID] = nil

end


