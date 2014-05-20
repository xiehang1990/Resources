local StorageReward=class("StorageReward")

function StorageReward:ctor(storageRewardData)
	-- body
	self.type="StorageReward"
	self.article=storageRewardData
end

function StorageReward:run()
	for k,v in pairs(self.article) do
		PlayerManager.Storage.addItem(v.id,v.num);
	end
end 
return StorageReward