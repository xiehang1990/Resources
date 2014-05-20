local Talk=class("Talk")
function Talk:ctor(talkData)
	-- body
	self.data=talkData;
end
--得到内容
function Talk:getContent(index)
	-- body
	return self.data[index].content;
end
--得到说话人
function Talk:getOwner(index)
	return self.data[index].role;
end 
--得到类型
function Talk:getType(index)
	if self.data[index].next==0 then
		--todo
		return "end"
	end
	if self.data[index].num~=nil then 
		return "select"
	end
	return "normal"
end 
function Talk:getNext(index,offset)
	if self:getType(index)=="select" then
		--todo
		return self.data[index].next[offset];
	else
		return self.data[index].next;
	end
end
function Talk:getContentType(index)
	if self.data[index].contentType~=nil then
		--todo
		return self.data[index].contentType;
	end
end

function  Talk:test()
    local i=1;
    while true do
		    	if self:getType(i)=="normal" then
		    		print(self:getOwner(i));
		    		print("说");
		    		print(self:getContent(i));
		    		i=self:getNext(i,0)
		    	else if self:getType(i)=="select" then
		    		print(self:getOwner(i));
		    		print("选")
		    		local content=self:getContent(i);
		    		for k,v in pairs(content) do
		    			print(k,v)
		    		end
		    		i=self:getNext(i,3);
		    		if i==0 then
		    			break;
		    		end;
		    	else
		    		print(self:getOwner(i),"结束时说");
		    		print(self:getContent(i));
		    		break;
		    	end
    	end 

    end
  -- sleep();
end




return Talk;
