--[[--

“日月”的视图

视图注册模型事件，从而在模型发生变化时自动更新视图

]]

SunView = class()

function SunView:ctor()
    self.baseSprite = CCSprite:create()

    self.sun1Frame = 4
    self.sun2Frame = 4
    self.sun3Frame = 3
    self.moon1Frame = 11
    self.scale = 1.0

    self.gameTime = TimeManager.gameTime
    self.daySection = "none"

    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile(string.format("%s.plist", "sun"))
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile(string.format("%s.plist", "moon"))

    self.alive = true

    self.angleSpeed = 0.1

    self.centerPoint = ccp(800, -400)
    self.radius = 850
    self.startAngle = -1.0
    self.targetAngle = 1.0

    self.angle = self.startAngle+(self.targetAngle-self.startAngle)/(SECONDS_PER_DAY/2.0)*self.gameTime

    self.x = self.centerPoint.x+math.sin(self.angle)*self.radius
    self.y = self.centerPoint.y+math.cos(self.angle)*self.radius

    self.baseSprite:setZOrder(0)
    self.baseSprite:setAnchorPoint(ccp(0.5, 0.5))
    self.baseSprite:setPosition(ccp(self.x, self.y))

    self.baseSprite:setVisible(false)
end

function SunView:updateSprite()
    if self.alive then

        self.baseSprite:setVisible(true)

        --取出游戏时间 
        self.gameTime = TimeManager.gameTime

        if TimeManager.daySection == "day" then
             --计算太阳角度
            self.angle = self.startAngle+(self.targetAngle-self.startAngle)/(SECONDS_PER_DAY/2.0)*self.gameTime
        elseif TimeManager.daySection == "night" then
            --计算月亮角度
            self.angle = self.startAngle+(self.targetAngle-self.startAngle)/(SECONDS_PER_DAY/2.0)*(self.gameTime-NIGHT_START_TIME)
        end

        self.x = self.centerPoint.x+math.sin(self.angle)*self.radius
        self.y = self.centerPoint.y+math.cos(self.angle)*self.radius
        self.baseSprite:setPosition(ccp(self.x,self.y))


        if self.daySection ~= TimeManager.daySection then
            --有状态变化

            self.daySection = TimeManager.daySection

            local cache = CCSpriteFrameCache:sharedSpriteFrameCache()

            if self.daySection == "day" then

                self.sprite:setDisplayFrame(CCSpriteFrameCache:
                    sharedSpriteFrameCache():spriteFrameByName(string.format("%s%d.png", "sun", 5)))

                --[[local animFrames = CCArray:createWithCapacity(self.sun2Frame)
                for i = self.sun1Frame+1,self.sun1Frame+self.sun2Frame do 
                    local frame = cache:spriteFrameByName( 
                        string.format("%s%d.png", "sun", i))
                    animFrames:addObject(frame)
                end

                local animation = CCAnimation:createWithSpriteFrames(animFrames, 0.016)

                self.sprite:stopAllActions()
                self.sprite:runAction(CCRepeatForever:
                    create(CCAnimate:create(animation)))]]--

            elseif self.daySection == "dusk" then

                --[[local animFrames = CCArray:createWithCapacity(self.sun3Frame)
                for i = self.sun1Frame+self.sun2Frame+1,self.sun1Frame+self.sun2Frame+self.sun3Frame do 
                    local frame = cache:spriteFrameByName( 
                        string.format("%s%d.png", "sun", i))
                    animFrames:addObject(frame)
                end

                local animation = CCAnimation:createWithSpriteFrames(animFrames, 0.016)

                self.sprite:stopAllActions()
                self.sprite:runAction(CCRepeatForever:
                    create(CCAnimate:create(animation)))]]--

            elseif self.daySection == "night" then
                self.sprite:setDisplayFrame(CCSpriteFrameCache:
                    sharedSpriteFrameCache():spriteFrameByName(string.format("%s%d.png", "moon", 6)))

                --[[local animFrames = CCArray:createWithCapacity(self.moon1Frame)
                for i = 1, self.moon1Frame do 
                    local frame = cache:spriteFrameByName( 
                        string.format("%s%d.png", "moon", i))
                    animFrames:addObject(frame)
                end

                local animation = CCAnimation:createWithSpriteFrames(animFrames, 0.016)

                self.sprite:stopAllActions()
                self.sprite:runAction(CCRepeatForever:
                    create(CCAnimate:create(animation)))]]--
            end
        end
    end
end

function SunView:initSprite()

    self.sprite = CCSprite:createWithSpriteFrame(CCSpriteFrameCache:
        sharedSpriteFrameCache():spriteFrameByName(string.format("%s%d.png", "sun", 5)))

    self.sprite:setScale(math.abs(self.scale))
    
    self.baseSprite:addChild(self.sprite)
end

