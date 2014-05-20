local ret = LoadCsv(DataManager.csv.roleModelData)
local file = DataManager.dataFile.roleModelData
function convertRoleModelData()
    local roleModelData = {}
    local rolePrint = {}

    
    -- 清除第一列中文
    ret[1] = nil
    -- 读取并清除第二列名称以及第三列类型
    local objectTitle = ret[2]
    local objectType = ret[3]
    ret[2] = nil
    ret[3] = nil

    -- 读取角色名称   
    local roleTitle = {}
    for k,v in pairs(ret) do
        roleTitle[k] = v[2]
    end

    -- 进行转换
    for k,v in pairs(ret) do
        roleModelData[roleTitle[k]] = {}
        for l,u in pairs(v) do
            roleModelData[roleTitle[k]][objectTitle[l]] = defineType(u,objectType[l])
        end
    end

    rolePrint = vardump(roleModelData,"roleModelData")

   
    file:write("local ")
    file:write(rolePrint)
    file:write('\nprint("LoadRoleModelData -- Success")\nreturn roleModelData')
   
end