-- 背包系统
-- canAddAmount(itemName) 检查某一类型的物品最多能够添加的数量
-- canAddItem(itemName,amount) 检查某一类型物品是否能够增加指定数量
-- addItem(itemName,amount) 增加物品
-- checkItem(itemName) 检查物品数量
-- checkItemByPosition(position) 检查某个位置的物品
-- removeItem(itemName,amount) 移除某类物品
-- removeItemByPosition(position,amount) 移除某个位置的物品
-- reset（）整理背包

local itemModelData = require("itemModelData")

local Storage = {}

function Storage.init(storageData)
	Storage.itemArray    = {}
	Storage.packageArray = {}

	Storage.itemArray.weapon    = {}
	Storage.itemArray.furniture = {}
	Storage.itemArray.material  = {}

	Storage.packageArray.weapon    = {}
	Storage.packageArray.furniture = {}
	Storage.packageArray.material  = {}

	for _,v in ipairs(storageData) do
		Storage.putInItem(v.itemID,v.itemName,v.amount)
	end
	Storage.updatePackage()
end

-- 获得物品列表
function Storage.getItemArray()
	local outputArray = clone(Storage.packageArray)
	for k,v in pairs(outputArray) do
		for i,u in pairs(v) do
			v[i] = Storage.itemArray[k][u]
			v[i].itemID = u
		end
	end
	return outputArray
end

-- 更新背包
function Storage.updatePackage()
	Storage.packageArray.weapon    = {}
	Storage.packageArray.furniture = {}
	Storage.packageArray.material  = {}
	local itemAmount = 0
	for k,_ in pairs(Storage.itemArray.weapon) do
		itemAmount = itemAmount + 1
		Storage.packageArray.weapon[itemAmount] = k
	end
	local itemAmount = 0
	for k,_ in pairs(Storage.itemArray.furniture) do
		itemAmount = itemAmount + 1
		Storage.packageArray.furniture[itemAmount] = k
	end
	local itemAmount = 0
	for k,_ in pairs(Storage.itemArray.material) do
		itemAmount = itemAmount + 1
		Storage.packageArray.material[itemAmount] = k
	end

end

-- add
function Storage.addItem(itemID,itemName,amount)
	local itemModel = itemModelData[itemName]
	-- 在已有格子中加入物品
	-- 判断是否有可以堆叠的物品堆
	if itemModel.pile then
		for _,v in pairs(Storage.itemArray) do
			if v.itemName == itemName then
				v.amount = v.amount + amount
				amount = 0
				break
			end
		end
	end
	-- 如果没有加入，则在空格子中加入物品
	if amount > 0 then
		Storage.putInItem(itemID,itemName,amount)
	end
	Storage.updatePackage()
end

-- 不进行检查，直接放入，瓜，不可直接调用！！
function Storage.putInItem(itemID,itemName,putInAmount)
	local itemModel = itemModelData[itemName]
	Storage.itemArray[itemModel.type][itemID] = {
		itemName = itemName,
		amount = putInAmount,
		pile = itemModel.pile,
		pileMax = itemModel.pileMax,
	}
end

function Storage.checkItemByID(itemID)
	for _,v in pairs(Storage.itemArray.weapon) do
		if v.itemID == itemID then
			return true
		end
	end
	for _,v in pairs(Storage.itemArray.furniture) do
		if v.itemID == itemID then
			return true
		end
	end
	return false
end

-- check
function Storage.checkItem(itemID)
	local amount = 0
	for _,v in pairs(Storage.itemArray) do
		for k,u in pairs(v) do
			if k == itemID then
				amount =  amount + u.amount
			end
		end
	end
	return amount
end

-- remove
function Storage.removeItem(itemID,amount)
	-- 合法性检查(可以没有)
	local itemCurrentAmount = Storage.checkItem(itemID)
	if amount > itemCurrentAmount then 
		print("移除物品数量超过库存数量")
		amount = itemCurrentAmount 
	end
	-- 移除物品
	for _,v in pairs(Storage.itemArray) do
		for k,u in pairs(v) do
			if k == itemID then
				if amount == u.amount then
					v[k] = nil
				else
					u.amount = u.amount - amount
				end
				break
			end
		end
	end
	Storage.updatePackage()
end


print("CreatStorageClass -- Success")
return Storage