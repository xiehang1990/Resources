
--[[--

“打手”的视图

视图注册模型事件，从而在模型发生变化时自动更新视图

]]

local buffData = require("buffData")

BuffView = class()

function BuffView:ctor(buffName,spriteWidth,spriteHeight)
    self.baseSprite = CCSprite:create()
    self.direction = "left"

    self.buffTextureName = buffData[buffName].textureName

    self.totalCreatFrame = buffData[buffName].totalCreatFrame
    self.totalMoveFrame = buffData[buffName].totalMoveFrame
    self.totalDisappearFrame = buffData[buffName].totalDisappearFrame
    self.scale = buffData[buffName].basicScale
    self.fps = buffData[buffName].fps

    self.totalFrame = self.totalCreatFrame+self.totalMoveFrame+self.totalDisappearFrame

    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile(string.format("%s.plist", self.buffTextureName))

    self.alive = true

    self.x = buffData[buffName].xShift*spriteWidth + buffData[buffName].xOffset*self.scale
    self.y = buffData[buffName].yShift*spriteHeight + buffData[buffName].yOffset*self.scale

    self.baseSprite:setZOrder(100)
    self.baseSprite:setAnchorPoint(ccp(0.5, 0.0))
    self.baseSprite:setPosition(ccp(self.x, self.y))

end

function BuffView:updateSprite()
    --
end

function BuffView:initSprite()
    self.state = ""

    self.sprite = CCSprite:createWithSpriteFrame(CCSpriteFrameCache:
        sharedSpriteFrameCache():spriteFrameByName(string.format("%s%s%d.png", self.buffTextureName, "_attack_", 0)))

    self.sprite:setAnchorPoint(ccp(0.5, 0.0))

    local cache = CCSpriteFrameCache:sharedSpriteFrameCache()
    local buffAnimFrames = CCArray:createWithCapacity(self.totalFrame)
    for i = 0,self.totalFrame-1 do
        local frame = cache:spriteFrameByName( 
            string.format("%s%s%d.png", self.buffTextureName, "_attack_", i) )
        buffAnimFrames:addObject(frame)
    end

    local buffAnimation = CCAnimation:createWithSpriteFrames(buffAnimFrames, self.fps)

    self.sprite:stopAllActions()
    --[[self.sprite:runAction(CCRepeatForever:
        create(CCAnimate:create(buffAnimation)))]]--

    --放完动画就消失
    function removeFromeSuperView ()
        self.baseSprite:removeAllChildrenWithCleanup(true)
        self.baseSprite:removeFromParentAndCleanup(true)
    end

    local array = CCArray:create()
    array:addObject(CCRepeat:
        create(CCAnimate:create(buffAnimation), 1))
    array:addObject(CCCallFuncN:create(removeFromeSuperView))
    local action = CCSequence:create(array)

    self.sprite:runAction(action)

    self.sprite:setScale(math.abs(self.scale))

    if self.direction == "left" then
        self.sprite:setScaleX(self.scale)
    else
        self.sprite:setScaleX(-self.scale)
    end
    
    self.baseSprite:addChild(self.sprite)
end

function BuffView:gameOver()
    --
end
