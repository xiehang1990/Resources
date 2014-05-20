local Specie=import("Specie")
local Species=class("Species")

function Species:ctor(SpeciesData)

	-- body
	self.score=SpeciesData.score  --整体评分
	self.name=SpeciesData.name
	for i=1,#SpeciesData do
		self[i]=Specie.new(SpeciesData[i])
	end
	self:updateLocked()
	self:updateScore()
end

function Species:updateScore()
	local score=0 
	for i=1,#self do
		score=score+self[i]:getScore()
	end
	self.score=score
end 

function Species:updateLocked()

	for i=1,#self do
		if self[i].level[1].locked then
			if self:calculateSpecieCondition(self[i].specieConditon) then 
				self[i]:unlockLevel(1)
				print("有新人物解锁:",self[i].name)
				self:updateLocked()
				return 
			end
		end
	end
	self:updateScore()
	end 

function Species:calculateSpecieCondition(specieConditon)
	local judge=false
	if not specieCondition then 
		return true  
	end 
	if #specieCondition==0 then 
		return true 
	end 
	for k,v in pairs(specieConditon) do
		judge=judge or self[v.index].level[v.level].locked 

	end
	dump(judge)
	return not judge 
end

return Species

