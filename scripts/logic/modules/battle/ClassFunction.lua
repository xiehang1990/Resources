ClassFunction = {}

function ClassFunction.copyTable(sourceObject,targetObject)
    for k,v in pairs(sourceObject) do
        if type(v) == "number" or type(v) == "string" or type(v) == "boolean" then
            targetObject[k] = v
        elseif type(v) == "table" then
            for t,u in pairs(v) do
               	targetObject[k][t] = u
            end
        end
    end
end

function ClassFunction.clearObject(sourceObject)
	for k,v in pairs(sourceObject) do
		if type(v) ~= "function" then
            sourceObject[k] = nil
        end
	end
end

function ClassFunction.clearTable(sourceObject)
    for k,v in pairs(sourceObject) do
        sourceObject[k] = nil
    end
end