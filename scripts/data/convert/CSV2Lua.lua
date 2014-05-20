local init_encode = DataManager.dll.encode
-- 加载ANSI到UTF8的转换模块


--csv解析
-- 去掉字符串左空白  
local function trim_left(s)  
    return string.gsub(s, "^%s+", "");  
end
-- 去掉字符串右空白  
local function trim_right(s)  
    return string.gsub(s, "%s+$", "");  
end  
-- 解析一行  
local function parseline(line)  
    local ret = {};
    local s = line .. ",";  -- 添加逗号,保证能得到最后一个字段
    while (s ~= "") do  
        --print(0,s);  
        local v = "";  
        local tl = true;  
        local tr = true;
        while(s ~= "" and string.find(s, "^,") == nil) do  
            --print(1,s);  
            if(string.find(s, "^\"")) then  
                local _,_,vx,vz = string.find(s, "^\"(.-)\"(.*)");  
                --print(2,vx,vz);  
                if(vx == nil) then  
                    return nil;  -- 不完整的一行  
                end
                -- 引号开头的不去空白  
                if(v == "") then  
                    tl = false;  
                end
                v = v..vx;  
                s = vz;
                --print(3,v,s);
                while(string.find(s, "^\"")) do  
                    local _,_,vx,vz = string.find(s, "^\"(.-)\"(.*)");  
                    --print(4,vx,vz);  
                    if(vx == nil) then  
                        return nil;  
                    end  
                    v = v.."\""..vx;  
                    s = vz;  
                    --print(5,v,s);  
                end  
                tr = true;  
            else  
                local _,_,vx,vz = string.find(s, "^(.-)([,\"].*)");  
                --print(6,vx,vz);  
                if(vx~=nil) then  
                    v = v..vx;  
                    s = vz;  
                else  
                    v = v..s;  
                    s = "";  
                end  
                --print(7,v,s);  
                tr = false;  
            end  
        end
        if(tl) then v = trim_left(v); end  
        if(tr) then v = trim_right(v); end
        ret[table.getn(ret)+1] = v;  
        --print(8,"ret["..table.getn(ret).."]=".."\""..v.."\"");
        if(string.find(s, "^,")) then  
            s = string.gsub(s,"^,", "");  
        end  
    end
    return ret;  
end

--解析csv文件的每一行  
local function getRowContent(file)  
    local content;  
  
    local check = false  
    local count = 0  
    while true do  
        local t = file:read()  
        if not t then  if count==0 then check = true end  break end
        if not content then  
           content = t  
        else  
            content = content..t  
        end
        local i = 1  
        while true do  
            local index = string.find(t, "\"", i)  
            if not index then break end  
            i = index + 1  
            count = count + 1  
        end
        if count % 2 == 0 then check = true break end  
    end
    if not check then  assert(1~=1) end  
    return content  
end  
  
--解析csv文件  
function LoadCsv(file)
    --initANSI2UTF8()
    local ret = {}; 
    assert(file)
    local content = {}  
    while true do  
        local line = getRowContent(file)  
        if not line then break end  
        table.insert(content, line)  
    end
    for k,v in pairs(content) do  
        ret[table.getn(ret)+1] = parseline(v);  
    end
    
    -- 进行编码转换
    --ANSI2UTF8(ret)
    print("读取CSV文件成功")
    return ret  
end 

-- 将所有的ANSI编码转换为UTF8编码
function ANSI2UTF8(table)
    for k,v in pairs(table) do
        for l,u in pairs(v) do
            ret[k][l] = encode.a2u8(u)
        end
    end
end

-----------------------------------------------------------------------
-- 确定类型
function defineType(object,objecttype)
    if objecttype == "string" then return object end
    if objecttype == "number" then return tonumber(object) end
    if objecttype == "bool" then return object == "TRUE" end
end
-----------------------------------------------------------------------
-- quick里的vardump
function vardump(object, label)
    local lookupTable = {}
    local result = {}

    local function _v(v)
        if type(v) == "string" then
            v = "\"" .. v .. "\""
        end
        return tostring(v)
    end
    local function _vardump(object, label, indent, nest)
        label = label or "<var>"
        local postfix = ""
        if nest > 1 then postfix = "," end
        if type(object) ~= "table" then
            if type(label) == "string" then
                result[#result +1] = string.format("%s%s = %s%s", indent, label, _v(object), postfix)
            else
                result[#result +1] = string.format("%s%s%s", indent, _v(object), postfix)
            end
        elseif not lookupTable[object] then
            lookupTable[object] = true

            if type(label) == "string" then
                result[#result +1 ] = string.format("%s%s = {", indent, label)
            else
                result[#result +1 ] = string.format("%s{", indent)
            end
            local indent2 = indent .. "    "
            local keys = {}
            local values = {}
            for k, v in pairs(object) do
                keys[#keys + 1] = k
                values[k] = v
            end
            table.sort(keys, function(a, b)
                if type(a) == "number" and type(b) == "number" then
                    return a < b
                else
                    return tostring(a) < tostring(b)
                end
            end)
            for i, k in ipairs(keys) do
                _vardump(values[k], k, indent2, nest + 1)
            end
            result[#result +1] = string.format("%s}%s", indent, postfix)
        end
    end
    _vardump(object, label, "", 1)

    return table.concat(result, "\n")
end