
require ("RewardLabel")

function showRwardLabels(rewards)
    local visibleSize = CCDirector:sharedDirector():getVisibleSize()
    local currentScene = CCDirector:sharedDirector():getRunningScene()

    for i,v in ipairs(rewards) do
    	local rewardLabel = RewardLabel.new(v.rewardType,v.value,visibleSize.width/2,visibleSize.height/2,i-1)
    	currentScene:addChild(rewardLabel.baseSprite)
    	rewardLabel:showSprite()
    end
end