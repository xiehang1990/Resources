local Board=class("Board")
local Tenant=import("Tenant")
function Board:ctor(boardData)
	self.boardNumber=boardData.boardNumber
	self.level=boardData.level
	self.totalTime=boardData.totalTime 
	self.flushTime=boardData.flushTime
	self.tenant=self:addTenantData(boardData.tenant)

end

function Board:addTenantData(tenantData)
	if tenantData then 
		local tenant=Tenant.new(tenantData)
		self:addTenant(tenant)
	end
end 
function Board:getTenant()
	return self.tenant 
end
function Board:addTenant(tenant)
	self.tenant=tenant
	self.flushTime=0
end 

function Board:removeTenant()
	if self.tenant then 
		self.tenant=nil
		self.flushTime=os.time()
	end 
end 

function Board:update()
	if os.time()-self.flushTime>self.totalTime then
		self:addTenant(nil)
	end
end 


return Board