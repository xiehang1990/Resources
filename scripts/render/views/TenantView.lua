
--[[--

“租客”的视图

视图注册模型事件，从而在模型发生变化时自动更新视图

]]

local roleModel = require("roleModelData")

TenantView = class()

function TenantView:ctor(roleData, i, superView)

    self.baseSprite = CCSprite:create()
    self.roleData = roleData
    self.itemID = roleData.itemID

    self.spriteName = roleData.roleID

    self.superView = superView

    --加载资源
    CCArmatureDataManager:sharedArmatureDataManager():
    addArmatureFileInfo(string.format("%s.ExportJson", self.spriteName))

    print(string.format("%s.ExportJson", self.spriteName))

    --初始位置
    self.startX = 650+110*i

    --初始方向
    self.direction = "right"

    --缩放
    self.scale = roleModel[roleData.roleID].baseScale

    --移动速度
    --self.speed = roleData.moveSpeed*60
    self.speed = roleModel[roleData.roleID].moveSpeed*60
    self.alive = true
    self.maxZ = 0       

    --房间
    self.room = 0   --所住房间
    self.floor = 1  --所住楼层
 
    self.targetFloor = 1    --目标楼层
    self.currentFloor = 1   --当前楼层

    --是否在换层
    self.switchFloor = false

    --是否在进房间
    self.enteringRoom = false

    --是否在出房间
    self.exitingRoom = false

    --是否在房间里
    self.inRoom = false

    --是否已离开
    self.hasLeft = false

    --租客状态
    --"waiting":    等待入住
    --"leave":      离开酒店
    --"backRoom":   回房间
    --"inRoom":     在房间里

    if i == -1 then
        self.state = "inRoom"
        self.inRoom = true
    else
        self.state = "waiting"
    end

    --self.itemID = roleData.itemID
end

--换层函数
function TenantView:switchFloorFun(_currentFloor, _targetFloor)
    --换层之前
    function beforeSwitchFloor()
        self.switchFloor = true

        if self.animationName ~= "load1" then
            self.animationName = "load1"
            self.animation:play(self.animationName)
        end
    end

    --换层中
    function switchingFloor()
        local targetY = 0

        if _targetFloor == 1 then
            targetY = FLOOR_1_Y
        elseif _targetFloor == 2 then
            targetY = FLOOR_2_Y
        else
            targetY = FLOOR_3_Y
        end

        self.baseSprite:setPositionY(targetY)
        self.baseSprite:setPositionX(STAIR_X)
        self.direction="left"
        self.sprite:setScaleX(self.scale)
    end

    --换层后
    function afterSwitchFloor()
        self.switchFloor = false
        self.currentFloor = _targetFloor
    end

    local actionTime = 0.35

    --换层动画
    local array = CCArray:create()
    array:addObject(CCCallFuncN:create(beforeSwitchFloor))
    array:addObject(CCDelayTime:create(0.3))
    array:addObject(CCFadeOut:create(actionTime))
    array:addObject(CCCallFuncN:create(switchingFloor))
    array:addObject(CCDelayTime:create(0.8))
    array:addObject(CCFadeIn:create(actionTime))
    array:addObject(CCDelayTime:create(0.4))
    array:addObject(CCCallFuncN:create(afterSwitchFloor))
    local action = CCSequence:create(array)
    self.sprite:runAction(action)

end

--行走
function TenantView:walkForward()
    local x = self.baseSprite:getPositionX()

    if self.direction == "left" then
        x = x - self.speed * CCDirector:sharedDirector():getAnimationInterval()
        self.sprite:setScaleX(self.scale)
    else
        x = x + self.speed * CCDirector:sharedDirector():getAnimationInterval()
        self.sprite:setScaleX(-self.scale)
    end

    self.baseSprite:setPosition(ccp(x, self.baseSprite:getPositionY()))

    if self.animationName ~= "walk1" then
        self.animationName = "walk1"
        self.animation:play(self.animationName)
    end

end

--进房间
function TenantView:enterRoom()
    function beforeEnterRoom()
        --进入房间之前
        self.enteringRoom = true

        if self.animationName ~= "load1" then
            self.animationName = "load1"
            self.animation:play(self.animationName)
        end

        --打开房门
        self.superView:openDoorOfRoom(self.floor,self.room)
    end

    function afterEnterRoom()
        --进入房间之后
        self.state = "inRoom"
        self.enteringRoom = false
        self.inRoom = true

        if self.animationName ~= "none" then
            self.animationName = "none"
            self.animation:stop()
        end

        --关闭房门
        self.superView:closeDoorOfRoom(self.floor,self.room)
    end

    local array = CCArray:create()
    array:addObject(CCCallFuncN:create(beforeEnterRoom))
    array:addObject(CCDelayTime:create(0.8))
    array:addObject(CCFadeOut:create(0.2))
    array:addObject(CCCallFuncN:create(afterEnterRoom))
    local action = CCSequence:create(array)
    self.sprite:runAction(action)

end

--出房间
function TenantView:exitRoom()
    function beforeExitRoom()
        --出房间之前
        self.exitingRoom = true

        local _y = 0
        local _x = 0

        if self.floor == 1 then
            _y = FLOOR_1_Y
        elseif self.floor == 2 then
            _y = FLOOR_2_Y
        else
            _y = FLOOR_3_Y
        end

        _x = 900+140*(self.room-1)+235

        self.baseSprite:setPositionY(_y)
        self.baseSprite:setPositionX(_x)
        self.direction="right"
        self.sprite:setScaleX(-self.scale)

        if self.animationName ~= "load1" then
            self.animationName = "load1"
            self.animation:play(self.animationName)
        end

        --打开房门
        self.superView:openDoorOfRoom(self.floor,self.room)
    end

    function afterExitRoom()
        --出房间之后
        self.exitingRoom = false
        self.inRoom = false

        --关闭房门
        self.superView:closeDoorOfRoom(self.floor,self.room)
    end

    local array = CCArray:create()
    array:addObject(CCCallFuncN:create(beforeExitRoom))
    array:addObject(CCDelayTime:create(0.4))
    array:addObject(CCFadeIn:create(0.8))
    array:addObject(CCCallFuncN:create(afterExitRoom))
    local action = CCSequence:create(array)
    self.sprite:runAction(action)

end

--自动寻路到目标楼层与目标横坐标
function TenantView:moveToTargetFloorAndPositionX(targetFloor, targetX, offSetX)
    self.targetFloor = targetFloor

    --判断在不在目标楼层
    if self.currentFloor ~= self.targetFloor then
        --如果不在目标楼层
            
        --楼道的位置
        local stairX = STAIR_X
        local stairWidth = 30

        --判断在不在当前楼层的楼梯口
        if self.baseSprite:getPositionX() >= stairX-stairWidth/2 and
         self.baseSprite:getPositionX() <= stairX+stairWidth/2 then
            --在楼梯口就换楼层
            if self.switchFloor == false then
                self:switchFloorFun(self.currentFloor, self.targetFloor)

                self:setSpriteZ()
            end
        else
            --不在楼梯口就向楼梯口走
            if self.baseSprite:getPositionX() >= STAIR_X then
                self.direction = "left"
            else
                self.direction = "right"
            end

            self:walkForward()
                
        end
    else
        --如果在目标楼层

        --判断到了目标横坐标没有
        if self.baseSprite:getPositionX() >= targetX-offSetX and
            self.baseSprite:getPositionX() <= targetX+offSetX then
            --如果到了，就停下来 
            
        else
            --如果不在门口就走向房间
            if self.baseSprite:getPositionX() >= targetX then
                self.direction = "left"
            else
                self.direction = "right"
            end

            self:walkForward()
        end

    end

end

--通过X坐标来调整Z坐标
function TenantView:setSpriteZ()

    SpriteMaxZ = SpriteMaxZ + 1

    self.baseSprite:setZOrder(SpriteMaxZ)
end


function TenantView:updateInHotel()

    --等待入住
    if self.state == "waiting" then
        --todo
        if self.animationName ~= "load1" then
            self.animationName = "load1"
            self.animation:play(self.animationName)
        end
    end

    --离开酒店
    if self.state == "leave" then
        --判断是否在房间内
        if self.inRoom == true then
            --如果在房间里
            --先出房间
            if self.exitingRoom == false then
                self:exitRoom()
            end
        else
            --如果不在房间
            --自动寻路离店
            local targetX = -50
            local offSetX = 15
            self:moveToTargetFloorAndPositionX(1, targetX, offSetX)

            --判断到了目标位置
            if self.baseSprite:getPositionX() >= targetX-offSetX and
            self.baseSprite:getPositionX() <= targetX+offSetX and
            self.currentFloor == 1 then

                if self.hasLeft == false then
                    --如果到了就销毁对象
                    if self.animationName ~= "none" then
                        self.animationName = "none"
                        self.animation:stop()
                    end

                    self.baseSprite:removeChild(self.sprite, true)

                    self.hasLeft = true
                end
            end
        end
    end

    --回房间
    if self.state == "backRoom" then
        --自动寻路回房间
        local targetX = 900+140*(self.room-1)+235
        local offSetX = 15
        self:moveToTargetFloorAndPositionX(self.floor, targetX, offSetX)

        --判断到了目标房间没有
        if self.baseSprite:getPositionX() >= targetX-offSetX and
           self.baseSprite:getPositionX() <= targetX+offSetX and
           self.currentFloor == self.floor then
            --如果在门口就进房间 
            if self.enteringRoom == false then
                self:enterRoom()
            end
        end
    end

    --在房间里
    if self.state == "inRoom" then
        --todo
        
    end

end

function TenantView:initSprite()
    local frameName
    -- add sprite

    local armature = CCArmature:create(self.spriteName)
    self.animation = armature:getAnimation()
    self.sprite = armature

    --租客位置
    local _x = 0
    local _y = 0

    --是否是等待租客
    if self.state == "waiting" then
        --如果是等待租客
        self.animationName = "load1"
        self.animation:play(self.animationName)

        _x = self.startX
        _y = FLOOR_1_Y

    elseif self.state == "inRoom" then
        --如果是已入住租客
        self.currentFloor = self.floor

        self.animation:stop()
        self.animationName = "none"
        self.sprite:setOpacity(0)

        if self.floor == 1 then
            _y = FLOOR_1_Y
        elseif self.floor == 2 then
            _y = FLOOR_2_Y
        else
            _y = FLOOR_3_Y
        end

        _x = 900+140*(self.room-1)+235

        self.direction="right"
    end

    self.sprite:setScale(math.abs(self.scale))

    if self.direction == "left" then
        self.sprite:setScaleX(self.scale)
    else
        self.sprite:setScaleX(-self.scale)
    end
    
    self.baseSprite:addChild(armature)
    self.baseSprite:setPositionY(_y)
    self.baseSprite:setPositionX(_x)
    self.baseSprite:setZOrder(SpriteMaxZ)
    
    
end

