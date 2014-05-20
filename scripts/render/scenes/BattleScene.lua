
--[[--

“Battle”的视图

视图注册模型事件，从而在模型发生变化时自动更新视图

]]

--local DataManager = require ("DataManager")
--local dataManager = DataManager.new()


require "BattleManager"

--class

BattleScene = class()

function BattleScene:ctor()
    self.frameIndex = 1
    self.scene = CCScene:create()
    self.visibleSize = CCDirector:sharedDirector():getVisibleSize()
    self.origin = CCDirector:sharedDirector():getVisibleOrigin()
    self.maxDamageZ = 10000
    self.gameOver = false

    self.pauseNum = 0
    self.paused = false
end


function BattleScene:init()

    self.fightersArray = {}
    self.damageLabels = {}
    self.bulletsArray = {}

    self.renderData = {} 
    self.battleResult = {}

    -- run
    self:initLayers()
    self:addComponents()

    t1 = os.clock();
    self.renderData, self.battleResult = DataManager.getBattleResult()
    t2 = os.clock();

    print("Caculate Consumed Time = " .. (t2 - t1) .. " s")

    function updateLayerFun()
        self:updateLayer()
    end

    CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(updateLayerFun, 0, false)

    for i=1,50 do
        --add damageLabel
        local label = CCLabelBMFont:create("Test", "fonts/futura-48.fnt")
        label:setScale(1.3)
        label:setZOrder(self.maxDamageZ)
        self.stageLayer:addChild(label)
        label:setOpacity(0)
        self.damageLabels[#self.damageLabels+1] = label
    end

    local function back()
        CCDirector:sharedDirector():popScene()
    end

    local backButtonItem = CCMenuItemImage:create("replay_normal.png", "replay_pressed.png")
    backButtonItem:setPosition(0, 0)
    backButtonItem:setScale(0.8)
    backButtonItem:registerScriptTapHandler(back)
    self.backButton = CCMenu:createWithItem(backButtonItem)
    self.backButton:setPosition(50, self.visibleSize.height-60)
    self.backButton:setVisible(false)
    self.menuLayer:addChild(self.backButton)
end

function BattleScene:initLayers()
    -- stageLayer
    self.stageLayer = CCLayer:create()
    self.stageLayer:setAnchorPoint(ccp(0, 0))
    self.scene:addChild(self.stageLayer)

    -- menuLayer
    self.menuLayer = CCLayer:create()
    self.menuLayer:setAnchorPoint(ccp(0, 0))
    self.scene:addChild(self.menuLayer)

    -- maskLayer
    self.skillMaskLayer = CCLayerColor:create(ccc4(0, 0, 0, 150))
    self.skillMaskLayer:setOpacity(0)
    self.skillMaskLayer:setVisible(false)
    self.skillMaskLayer:setZOrder(SKILL_MASK)
    self.stageLayer:addChild(self.skillMaskLayer)
end

function BattleScene:updateLayer()
    --update sprites
    if self.frameIndex < #self.renderData.roleData and not self.gameOver then
        local frameData = self.renderData.roleData[self.frameIndex]
        local bulletData = self.renderData.bulletData[self.frameIndex]
        local damageData = self.renderData.numberData[self.frameIndex]

        --暂停数据
        local pauseFightersArray = {}
        pauseFighter = self.renderData.pauseBy[self.frameIndex]

        if pauseFighter ~= "" then
            self.pauseNum = PAUSE_TIME
        else
            if self.pauseNum > 0 then
                self.pauseNum = self.pauseNum-1
            end
        end

        if self.pauseNum > 0 then
            self.skillMaskLayer:setOpacity(self.pauseNum*(150/PAUSE_TIME))
            self.skillMaskLayer:setVisible(true)
        else
            self.skillMaskLayer:setVisible(false)
        end
        
        if self.paused == false then
            --如果未暂停
            self.frameIndex = self.frameIndex + 1

            local maxZ = 0
            for i,v in pairs(self.fightersArray) do
                if v.maxZ > maxZ  then
                    maxZ = v.maxZ
                end
            end

            for i,v in pairs(frameData) do
                if v.new then
                    local fighter = FighterViewInBattle.new(v)
                    fighter:initSprite()
                    self.stageLayer:addChild(fighter.baseSprite)
                    self.fightersArray[#self.fightersArray+1] = fighter
                else
                    local view = self:findSpriteWithID(i)
                    if view then
                        view.maxZ = maxZ
                        view:updateInBattle(v)
                    end
                end
            end

            for i,v in pairs(damageData) do
                local x = v.X
                local y = v.Y

                self:showDamageAtPoint(v.X+(2-4*math.random()), v.Y+(8-16*math.random()), v, 1.1-0.2*math.random())
            end

            for i,v in pairs(bulletData) do
                if v.new then
                    local _z = 10000
                    if pauseFighter ~= "" then
                        _z = SKILL_MASK+1
                    end
                    local bullet = BulletView.new(v,_z)
                    bullet:initSprite()
                    self.stageLayer:addChild(bullet.baseSprite)
                    self.bulletsArray[#self.bulletsArray+1] = bullet
                else
                    local view = self:findBulletWithID(i)
                    if view then
                        view:updateSprite(v)
                    end
                end
            end
        end
    else
        if not self.gameOver then
            for i,v in pairs(self.fightersArray) do
                v:gameOver()
            end
            for i,v in pairs(self.bulletsArray) do
                v:gameOver()
            end
            self.gameOver = true

            --addButton
            self.backButton:setVisible(true)
        end

    end
end

function BattleScene:showDamageAtPoint(x, y, damage, scale)

    for i,v in pairs(self.damageLabels) do
        if v:getOpacity() < 10 then
            v:setString(damage.value)
            v:setColor(ccc3(255, 255, 255))

            if damage.type == "normal" then
                v:setString(string.format("-%d", damage.value))
                v:setColor(ccc3(255, 255, 255))
            end
            if damage.type == "critical" then
                v:setString(string.format("-%d", damage.value))
                v:setColor(ccc3(255, 0, 0))
            end
            if damage.type == "heal" then
                v:setString(string.format("+%d", damage.value))
                v:setColor(ccc3(0, 255, 0))
            end
            if damage.type == "dodge" then
                v:setString("MISS")
                v:setColor(ccc3(0, 0, 255))
            end
            
            v:setPosition(ccp(x, y+60))
            v:setOpacity(255)
            v:setZOrder(self.maxDamageZ)
            v:setScale(scale)

            self.maxDamageZ = self.maxDamageZ+1

            local delay = CCDelayTime:create(0.4)

            local move = CCMoveTo:create(0.3, ccp(x, y+120))
            local fadeOut = CCFadeOut:create(0.3)
            local spawn = CCSpawn:createWithTwoActions(move,fadeOut)
            
            local array = CCArray:create()
            array:addObject(delay)
            array:addObject(spawn)
            local sequence = CCSequence:create(array)

            v:runAction(sequence)

            return
        end
    end
end

function BattleScene:addComponents()
    --add floor
    local scale = 1.0

    local battleBkg1 = CCSprite:create("huaguoshan_battleBkg_2.png")

    battleBkg1:setAnchorPoint(ccp(0.5, 0))

    battleBkg1:setPosition(ccp(self.visibleSize.width/2, 0))

    battleBkg1:setZOrder(0) 

    battleBkg1:setScale(scale)

    self.stageLayer:addChild(battleBkg1)
end

function BattleScene:findSpriteWithID(itemID)
    for i,v in pairs(self.fightersArray) do
        if v.itemID == itemID then
            return v
        end
    end

    return nil
end

function BattleScene:findBulletWithID(itemID)
    for i,v in pairs(self.bulletsArray) do
        if v.itemID == itemID then
            return v
        end
    end

    return nil
end

