
--[[--

“打手”的视图

视图注册模型事件，从而在模型发生变化时自动更新视图

]]
local roleModel = require("roleModelData")

FighterViewInBattle = class()

function FighterViewInBattle:ctor(roleData)
    self.baseSprite = CCSprite:create()
    self.itemID = roleData.itemID
    self.spriteName = roleData.roleID
    self.direction = roleData.direction

    --加载资源
    CCArmatureDataManager:sharedArmatureDataManager():
    addArmatureFileInfo(string.format("%s.ExportJson", self.spriteName))
    
    self.scale = 1.0

    --读取人物模型信息
    self.textureHeight = roleModel[roleData.roleID].textureHeight
    self.textureWidth = roleModel[roleData.roleID].textureWidth
    self.scale = roleModel[roleData.roleID].baseScale
    self.attackKinds = roleModel[roleData.roleID].attackKinds

    --初始化人物信息
    self.alive = true
    self.paused = false
    self.pauseSource = false
    self.maxZ = 0
    self.floor = roleData.floor

    self.x = roleData.X
    self.y = roleData.Y

    --print("position", self.x, self.y)

    self.baseSprite:setZOrder(self.maxZ+(4-self.floor)*1000)
    self.baseZOrder = self.maxZ+(4-self.floor)*1000
    self.baseSprite:setPosition(ccp(self.x, self.y))

    self.hurtFrameIndex = 0
    self.shiftFrameIndex = 0

    if self.x <= 460 then
        self.direction = "right"
    else
        self.direction = "left"
    end

    --加血条
    self.HPBkgBar = CCProgressTimer:create(CCSprite:create("blood_bkg.png"))
    self.HPBkgBar:setScaleX(0.15)
    self.HPBkgBar:setScaleY(0.1)
    self.HPBkgBar:setPosition(ccp(0, self.textureHeight))
    self.HPBkgBar:setAnchorPoint(ccp(0.5, 0.5))
    self.HPBkgBar:setPercentage(100)
    self.HPBkgBar:setZOrder(10)

    self.HPBar = CCProgressTimer:create(CCSprite:create("blood_front.png"))
    self.HPBar:setScaleX(0.15)
    self.HPBar:setScaleY(0.1)
    self.HPBar:setPosition(ccp(0, self.textureHeight))
    self.HPBar:setAnchorPoint(ccp(0.5, 0.5))
    self.HPBar:setMidpoint(ccp(0, 1))
    self.HPBar:setBarChangeRate(ccp(1, 0))
    self.HPBar:setType(kCCProgressTimerTypeBar)
    self.HPBar:setPercentage(100)
    self.HPBar:setZOrder(20)

    self.baseSprite:addChild(self.HPBkgBar)
    self.baseSprite:addChild(self.HPBar)

    --血条隐藏倒计时
    self.hiddeHPBarTimer = 0
    self.HPBkgBar:setVisible(false)
    self.HPBar:setVisible(false)
    self.HP = -1

    --增加特效层
    self.effectSprite = CCSprite:create()
    self.effectSprite:setZOrder(100)
    --self.effectSprite:setAnchorPoint(ccp(0, 0))
    self.effectSprite:setPosition(ccp(0, 60))
    self.effectSprite:setScale(0.9)
    self.baseSprite:addChild(self.effectSprite)
end

function FighterViewInBattle:updateInBattle(roleData)
    if self.alive then
        
        self.pauseSource = roleData.pauseSource

        if self.pauseSource == false then
            self.baseSprite:setZOrder(self.baseZOrder)
            self.baseSprite:setScale(1.0)
        end

        if roleData.paused == true and self.pauseSource == false then
            if self.paused == false then
                self:pause()
            end
            return
        end

        if roleData.paused == false then
            if self.paused == true then
                self:resume()
            end
        end

        --[[if self.sprite:getBone("Layer2") then
            self.sprite:getBone("Layer2"):setOpacity(0)
        end]]--

        self.x = roleData.X
        self.y = roleData.Y

        if math.abs(self.y - roleData.Y) > 100 and self.state == "shift" then
            --
        else
            self.y = roleData.Y
        end

        self.direction = roleData.direction

        --检测血量变化
        local totalHP = roleData.totalHP
        if self.HP ~= roleData.HP then
            if self.HP ~= -1 then
                self.hiddeHPBarTimer = 20
            end
            self.HP = roleData.HP
        end

        local release = roleData.last

        self.HPBar:setPercentage(self.HP/totalHP*100)

        --显示血条
        if self.hiddeHPBarTimer > 0 then
            self.HPBkgBar:setVisible(true)
            self.HPBar:setVisible(true)
            self.hiddeHPBarTimer = self.hiddeHPBarTimer-1
        else
            self.HPBkgBar:setVisible(false)
            self.HPBar:setVisible(false)
            self.hiddeHPBarTimer = 0
        end

        if self.floor ~= roleData.floor then
            self.floor = roleData.floor
            
        end

        --[[if roleData.beDamaged then
            self.hurtFrameIndex = 20

            local tmpX = 10

            if self.direction == "right" then
                tmpX = -tmpX
            end

            local arr = CCArray:create()
            arr:addObject(CCMoveTo:create(0.2, ccp(tmpX, 0)))
            arr:addObject(CCMoveTo:create(0.1, ccp(0, 0)))
            self.sprite:runAction(CCSequence:create(arr))
        end]]--

        if self.hurtFrameIndex > 0 then
            self.hurtFrameIndex = self.hurtFrameIndex-1
        else
            self.hurtFrameIndex = 0
        end

        if self.shiftFrameIndex > 0 then
            if self.shiftFrameIndex == 54 then
                self.baseSprite:setZOrder(10000)
            end

            if self.shiftFrameIndex == 15 then
                self.baseSprite:setZOrder(self.maxZ+(4-self.floor)*1000)
            end

            self.shiftFrameIndex = self.shiftFrameIndex-1
        end
        
        if not release then
            self.baseSprite:setPosition(ccp(self.x, self.y))

            local cache = CCSpriteFrameCache:sharedSpriteFrameCache()
            
            if self.direction == "left" then
                self.sprite:setScaleX(self.scale)
            else
                self.sprite:setScaleX(-self.scale)
            end

            if self.state ~= "attack" then
                if roleData.beDamaged then
                    if self.hurtFrameIndex < 10 then
                        self.hurtFrameIndex = 20

                        --self.animation:play("hurt")
                    end
                end
            end

            if self.state ~= roleData.state then

                self.state = roleData.state
                
                if self.state == "die" then 
                    
                end
                if self.state == "stun"  then
                    self.animation:play("vertigo")
                end
                if self.state == "attackCD"  then
                    self.animation:play("load2")
                end
                if self.state == "attack"  then
                    local randomIndex = 1

                    --随机播放一个攻击动作
                    if self.attackKinds > 1 then
                        randomIndex = math.floor(math.random()*self.attackKinds+1)
                    end

                    self.animation:play(string.format("attack%d", randomIndex))
                    
                    self.maxZ = self.maxZ + 1
                    self.baseSprite:setZOrder(self.maxZ+(4-self.floor)*1000)
                    self.baseZOrder = self.maxZ+(4-self.floor)*1000
                end
                if self.state == "move"  then
                    self.animation:play("walk2")
                end
                if self.state == "wait"  then
                    self.animation:play("load2")
                end
                if self.state == "shift" then
                    self.shiftFrameIndex = 74

                    self.animation:play("jump")

                end

                if self.state == "repel" then
                    self.shiftFrameIndex = 74

                    self.animation:play("hurt")
                end

                if self.state == "skill" then 
                    self.animation:play("magic")

                    self.baseSprite:setZOrder(SKILL_MASK+1)
                    self.baseSprite:setScale(1.3)
                end

                
            end

            --buff特效
            for k,v in pairs(roleData.buff) do
                --print(k)
                if k == "WanJianJue" or k == "physical" then
                    local buffView = BuffView.new(k,self.textureWidth,self.textureHeight)
                    buffView:initSprite()
                    self.baseSprite:addChild(buffView.baseSprite)
                end
            end

         else
            print(self.spriteName,"die")
            self.animation:stop()
            self.animation:play("death")
            self.HPBar:runAction(CCFadeTo:create(1.0, 0))
            self.HPBkgBar:runAction(CCFadeTo:create(1.0, 0))
            self.sprite:runAction(CCFadeTo:create(1.2, 0))
            self.alive = false
        end
    end
end

function FighterViewInBattle:skill()
    self.state = "skill"
    self.animation:play("magic")
end

function FighterViewInBattle:initSprite()
    self.state = ""
    -- add sprite

    local armature = CCArmature:create(self.spriteName)
    self.animation = armature:getAnimation()

    --self.animation:setSpeedScale(24 / 60) -- Flash fps is 24, cocos2d-x is 60
    local aniName = self.state
    self.animation:play("load2")
    self.sprite = armature

    self.sprite:setScale(math.abs(self.scale))
    self.sprite:setZOrder(0)

    if self.direction == "left" then
        self.sprite:setScaleX(self.scale)
    else
        self.sprite:setScaleX(-self.scale)
    end
    
    self.baseSprite:addChild(armature)    
end

function FighterViewInBattle:pause()
    if self.alive then
        self.animation:pause()
        self.paused = true
    end
end

function FighterViewInBattle:resume()
    if self.alive then
        self.animation:resume()
        self.paused = false
    end
end

function FighterViewInBattle:gameOver()
    if self.alive then
        self.sprite:setColor(ccc3(255, 255, 255))
        self.animation:play("load2")
    end
end

