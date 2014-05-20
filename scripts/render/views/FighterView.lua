
--[[--

“打手”的视图

视图注册模型事件，从而在模型发生变化时自动更新视图

]]
local roleModel = require("roleModelData")

FighterView = class()

function FighterView:ctor(roleData)

    self.baseSprite = CCSprite:create()
    self.spriteName = roleData.roleID

    --加载资源
    CCArmatureDataManager:sharedArmatureDataManager():
    addArmatureFileInfo(string.format("%s.ExportJson", self.spriteName))

    --活动楼层
    self.floor = roleData.position[1]

    --活动范围
    if self.floor == 1 then
        self.minX = 800
        self.maxX = 2000
    end

    if self.floor == 2 then
        self.minX = 1100
        self.maxX = 1700
    end

    if self.floor == 3 then
        self.minX = 1100
        self.maxX = 1700
    end

    --初始位置
    local tmpX = math.random()
    self.startX = self.minX+tmpX*(self.maxX-self.minX)

    --初始方向
    if tmpX > 0.5 then
        self.direction = "left"
    else
        self.direction = "right" 
    end

    --缩放
    self.scale = roleModel[roleData.roleID].baseScale

    --移动速度
    self.speed = roleModel[roleData.roleID].moveSpeed*60
    self.alive = true
    self.maxZ = 0
    self.state = "load"

    --self.itemID = roleData.itemID
end

--通过X坐标来调整Z坐标
function FighterView:setSpriteZ()
    SpriteMaxZ = SpriteMaxZ + 1

    self.baseSprite:setZOrder(SpriteMaxZ)

    --[[local x = self.baseSprite:getPositionX()

    local z = x/2+100

    self.baseSprite:setZOrder(z)]]--
end

function FighterView:updateInHotel()
    if self.alive then

        local x = self.baseSprite:getPositionX()

        if x > self.maxX then
            if self.direction ~= "left" then
                self.direction = "left"
                self:setSpriteZ()
            end
        end

        if x < self.minX then
            if self.direction ~= "right" then
                self.direction = "right"
                self:setSpriteZ()
            end
        end

        if self.direction == "left" then
            x = x - self.speed * CCDirector:sharedDirector():getAnimationInterval()
            self.sprite:setScaleX(self.scale)
        else
            x = x + self.speed * CCDirector:sharedDirector():getAnimationInterval()
            self.sprite:setScaleX(-self.scale)
        end

        self.baseSprite:setPosition(ccp(x, self.baseSprite:getPositionY()))

        --update state
        if self.state == "die" then 
                    
        end
        if self.state == "stun"  then
            self.animation:play("vertigo", -1, -1, 1)
        end
        if self.state == "attackCD"  then
            self.animation:play("load", -1, -1, 1)
        end
        if self.state == "attack"  then
            self.animation:play("attack", -1, -1, 0)
            self.maxZ = self.maxZ + 10
            self:setZOrder(self.maxZ)
        end
        if self.state == "move"  then
            self.animation:play("walk1", -1, -1, 1)
        end
        if self.state == "wait"  then
            self.animation:play("load1", -1, -1, 1)
        end
    end
end

function FighterView:initSprite()

    self.state = ""
    -- add sprite

    local armature = CCArmature:create(self.spriteName)
    self.animation = armature:getAnimation()

    --self.animation:setAnimationScale(24 / 60) -- Flash fps is 24, cocos2d-x is 60
    local aniName = self.state

    local animationName = "walk2"
    self.animation:play(animationName)
    self.sprite = armature

    self.sprite:setScale(math.abs(self.scale))

    if self.direction == "left" then
        self.sprite:setScaleX(self.scale)
    else
        self.sprite:setScaleX(-self.scale)
    end
    
    self.baseSprite:addChild(armature)

    if self.floor == 1 then
        self.baseSprite:setPosition(ccp(self.startX, FLOOR_1_Y))
        self.baseSprite:setZOrder(SpriteMaxZ)
    end

    if self.floor == 2 then
        self.baseSprite:setPosition(ccp(self.startX, FLOOR_2_Y))
        self.baseSprite:setZOrder(SpriteMaxZ)
    end

    if self.floor == 3 then
        self.baseSprite:setPosition(ccp(self.startX, FLOOR_3_Y))
        self.baseSprite:setZOrder(SpriteMaxZ)
    end
    
end

