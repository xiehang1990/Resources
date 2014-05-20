--@author by wangfulai 2014.3.15
local Talk=import("Talk")
local talkData=import("talkData")
local Reward=import("Reward")
--local Condition=import("Condition")
local ArticleTask=class("ArticleTask")

function ArticleTask:ctor(articleTaskData)
	self.type="articleTask"
 --判断article是否已经完成 返回 true false 的数组，和article 一一对应
	self.talkModel=nil  --对话发生在资源点的对话
 --自定义talk 没有则利用talkModel
	self.condition=nil 

	self.article=articleTaskData.article
	self.description = articleTaskData.description
	self.title = articleTaskData.title
	
	self.talk=Talk.new(talkData[articleTaskData.talkID])
	self.talk:test()
	self.reward=Reward.new(articleTaskData.reward)

	self.completed = false
end

--利用articleid载入article所有数据
function ArticleTask:loadAriticleId(id)
end;

--利用talkmodelid载入对话模块

function ArticleTask:loadTalkModelId(id)
	
		-- body
end

function ArticleTask:complete() --完成函数，减少人物对应物品
	self:update()

	local j=true;
	for i=1,#self.article do
		j=j and self.article[i].judge
	end

	if j==true then 
	self:reduceArticle()

	self.reward:run()
	return true 
	else 
		return false 
	end 


end

function ArticleTask:reduceArticle()

	for k,v in pairs(self.article) do
		PlayerManager.Storage.removeItem(v.id,v.num);

	end

end 

function ArticleTask:update()  ---判断此时任务是否为可完成状态。第一个为所有物品，后面为每个物品。 true为已完成，false为未完成
	self.completed = true

	for k,v in pairs(self.article) do
		local num1=PlayerManager.Storage.checkItem(v.id)
		if num1>=v.num then 
			v.judge=true;
		else 
			v.judge=false;

			self.completed = false
		end 
	end
	
end


function ArticleTask:getTalk()
	return self.talk;
end

return ArticleTask