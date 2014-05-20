--[[--

“打手”的视图

视图注册模型事件，从而在模型发生变化时自动更新视图

]]

local _bulletData = DataManager.battleInitData.bullet

BulletView = class()

function BulletView:ctor(bulletData,z)
    self.baseSprite = CCSprite:create()
    self.itemID = bulletData.itemID
    self.direction = "right"

    self.bulletName = _bulletData[bulletData.name].textureName

    self.totalCreatFrame = _bulletData[bulletData.name].totalCreatFrame
    self.totalMoveFrame = _bulletData[bulletData.name].totalMoveFrame
    self.totalDisappearFrame = _bulletData[bulletData.name].totalDisappearFrame
    self.scale = _bulletData[bulletData.name].basicScale

    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile(string.format("%s.plist", self.bulletName))

    self.alive = true

    self.x = bulletData.X
    self.y = bulletData.Y
    self.angle = bulletData.angle
    self.direction = bulletData.direction

    self.baseSprite:setZOrder(z)
    self.baseSprite:setAnchorPoint(ccp(0.5, 0.5))
    self.baseSprite:setPosition(ccp(self.x, self.y))

end

function BulletView:updateSprite(bulletData)
    if self.alive then

        self.x = bulletData.X
        self.y = bulletData.Y
        self.angle = bulletData.angle
        self.direction = bulletData.direction

        local release = bulletData.last

        --放完动画就消失
        function removeFromeSuperView ()
            self.baseSprite:removeAllChildrenWithCleanup(true)
            self.baseSprite:removeFromParentAndCleanup(true)
            self.alive = false
        end

        if not release then
            self.baseSprite:setPosition(ccp(self.x, self.y))

            if self.direction == "left" then
                self.sprite:setRotation(self.angle)
                self.sprite:setScaleX(self.scale)
            else
                self.sprite:setRotation(-self.angle)
                self.sprite:setScaleX(-self.scale)
            end

            if self.state ~= bulletData.state then

                self.state = bulletData.state

                local cache = CCSpriteFrameCache:sharedSpriteFrameCache()
                
                if self.state == "create" then 
                    
                end

                if self.state == "move"  then

                    local moveAnimFrames = CCArray:createWithCapacity(10)
                    for i = 0,self.totalMoveFrame-1 do 
                        local frame = cache:spriteFrameByName( 
                            string.format("%s%s%01d.png", self.bulletName, "_fly_", i) )
                        moveAnimFrames:addObject(frame)
                    end

                    local moveAnimation = CCAnimation:createWithSpriteFrames(moveAnimFrames, 0.016)

                    self.sprite:stopAllActions()
                    self.sprite:runAction(CCRepeatForever:
                        create(CCAnimate:create(moveAnimation)))
                end
                if self.state == "disappear"  then

                    local disappearAnimFrames = CCArray:createWithCapacity(10)
                    for i = 0,self.totalDisappearFrame-1 do 
                        local frame = cache:spriteFrameByName( 
                            string.format("%s%s%01d.png", self.bulletName, "_disappear_", i) )
                        disappearAnimFrames:addObject(frame)
                    end

                    local disappearAnimation = CCAnimation:createWithSpriteFrames(disappearAnimFrames, 0.016)

                    self.sprite:stopAllActions()

                    local array = CCArray:create()
                    array:addObject(CCRepeat:
                        create(CCAnimate:create(disappearAnimation), 1))
                    array:addObject(CCCallFuncN:create(removeFromeSuperView))
                    local action = CCSequence:create(array)

                    self.sprite:runAction(action)
                end
            end
        else
            self.alive = false
            local cache = CCSpriteFrameCache:sharedSpriteFrameCache()
            local disappearAnimFrames = CCArray:createWithCapacity(10)
            for i = 0,self.totalDisappearFrame-1 do 
                local frame = cache:spriteFrameByName( 
                    string.format("%s%s%01d.png", self.bulletName, "_disappear_", i) )
                disappearAnimFrames:addObject(frame)
            end

            local disappearAnimation = CCAnimation:createWithSpriteFrames(disappearAnimFrames, 0.016)

            self.sprite:stopAllActions()
            
            local array = CCArray:create()
            array:addObject(CCRepeat:
                create(CCAnimate:create(disappearAnimation), 1))
            array:addObject(CCCallFuncN:create(removeFromeSuperView))
            local action = CCSequence:create(array)

            self.sprite:runAction(action)
        end
    end
end

function BulletView:initSprite()
    self.state = ""

    self.sprite = CCSprite:createWithSpriteFrame(CCSpriteFrameCache:
        sharedSpriteFrameCache():spriteFrameByName(string.format("%s%s%01d.png", self.bulletName, "_fly_", 0)))

    self.sprite:setScale(math.abs(self.scale))

    if self.direction == "left" then
        self.sprite:setRotation(self.angle)
        self.sprite:setScaleX(self.scale)
    else
        self.sprite:setRotation(-self.angle)
        self.sprite:setScaleX(-self.scale)
    end
    
    self.baseSprite:addChild(self.sprite)
end

function BulletView:gameOver()
    if self.alive then
        self.sprite:runAction(CCFadeTo:create(0.3, 0))
    end
end
