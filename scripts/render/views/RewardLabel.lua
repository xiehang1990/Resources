
--[[--

“打手”的视图

视图注册模型事件，从而在模型发生变化时自动更新视图

]]

RewardLabel = class()

function RewardLabel:ctor(type,value,x,y,index)
    self.baseSprite = CCSprite:create()
    
    --物品数量
    --self.valueLabel = LabelAtlas:create()
    --self.valueLabel:setProperty(string.format("%d", value), "numLabel.png", 46, 58, "/")
    self.valueLabel = CCLabelBMFont:create("Test", "fonts/futura-48.fnt")
    self.valueLabel:setString(string.format("%d", value))
    self.valueLabel:setScale(1.0)
    self.valueLabel:setAnchorPoint(ccp(0.0, 0.5))
    self.valueLabel:setPosition(ccp(40, 0))
    self.valueLabel:setVisible(false)
    self.baseSprite:addChild(self.valueLabel)

    if type == "jinbi" then
        self.titleImage = CCSprite:create("jinbi-jia.png")
    end

    if type == "weiwang" then
        self.titleImage = CCSprite:create("weiwang-jia.png")
        --self.valueLabel:setColor(ccc3(160,240,120))
    end

    self.titleImage:setScale(0.45)
    self.titleImage:setPosition(ccp(-30, 0))
    self.titleImage:setVisible(false)
    self.baseSprite:addChild(self.titleImage)
    
    self.baseSprite:setAnchorPoint(ccp(0.5, 0.5))
    self.baseSprite:setPosition(ccp(x, y))

    self.baseSprite:setCascadeOpacityEnabled(true)

    self.x = x
    self.y = y
    self.index = index

end

function RewardLabel:showSprite()
    --
    function showFun(sender)
        self.valueLabel:setVisible(true)
        self.titleImage:setVisible(true)
    end

    function removeFun(sender)
        self.baseSprite:removeAllChildrenWithCleanup(true)
        self.baseSprite:removeFromParentAndCleanup(true)
    end

    local delay = CCDelayTime:create(0.3)
    local move = CCMoveTo:create(0.6, ccp(self.x, self.y+120))
    local fadeOut = CCFadeOut:create(0.3)
            
    local array = CCArray:create()
    array:addObject(delay)
    array:addObject(fadeOut)
    array:addObject(CCCallFuncN:create(removeFun))
    local sequence = CCSequence:create(array)

    local spawn = CCSpawn:createWithTwoActions(sequence,move)

    local array1 = CCArray:create()
    array1:addObject(CCCallFuncN:create(showFun))
    array1:addObject(CCDelayTime:create(0.25*self.index))
    array1:addObject(spawn)
    local sequence1 = CCSequence:create(array1)

    self.baseSprite:runAction(sequence1)
    --self.valueLabel:setOpacity(100)
end

function RewardLabel:initSprite()
    --
end
