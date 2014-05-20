
--[[--

世界地图界面

视图注册模型事件，从而在模型发生变化时自动更新视图

]]

WorldMapUI = class()

local ccs = require ("ccs")

function WorldMapUI:ctor(superView)
    self.node = GUIReader:shareReader():widgetFromJsonFile("map-4-8_1.ExportJson")
    self.superView = superView

    self.maxZ = 3

end

function WorldMapUI:init()
    --add funciton

    --退出按钮
    local function removeFun()
        CCDirector:sharedDirector():popScene()
    end

    local removeButton = self.superView.menuLayer:getWidgetByName("Button_return")
    removeButton:addTouchEventListener(removeFun)

    function touchMapButton(sender, eventType)

        if eventType == ccs.TouchEventType.began then
            local senderImageView = tolua.cast(self.superView.menuLayer:getWidgetByName(string.format("ImageView_%s", sender.name)),"ImageView")
            senderImageView:loadTexture(string.format("map--%s2.png",sender.name))
            sender:setZOrder(self.maxZ+1)
            senderImageView:setZOrder(self.maxZ)
            self.maxZ = self.maxZ+1
        end
        if eventType == ccs.TouchEventType.moved then
            --moved
        end
        if eventType == ccs.TouchEventType.ended then
            local senderImageView = tolua.cast(self.superView.menuLayer:getWidgetByName(string.format("ImageView_%s", sender.name)),"ImageView")
            senderImageView:loadTexture(string.format("map--%s1.png",sender.name))

            --加载区域地图
            self.superView:addRegionMapUI(sender.name)
            --PlayerManager.World.executeSector("aoLaiGuo", "aoLaiGuo1")
        end
        if eventType == ccs.TouchEventType.canceled then
            local senderImageView = tolua.cast(self.superView.menuLayer:getWidgetByName(string.format("ImageView_%s", sender.name)),"ImageView")
            senderImageView:loadTexture(string.format("map--%s1.png",sender.name))
        end
    end

    --傲来国
    local Button_aolaiguo = self.superView.menuLayer:getWidgetByName("Button_aolaiguo")
    Button_aolaiguo.name = "aolaiguo"
    Button_aolaiguo:addTouchEventListener(touchMapButton)

    --女儿国
    local Button_neg = self.superView.menuLayer:getWidgetByName("Button_neg")
    Button_neg.name = "neg"
    Button_neg:addTouchEventListener(touchMapButton)

    --花果山
    local Button_hgs = self.superView.menuLayer:getWidgetByName("Button_hgs")
    Button_hgs.name = "hgs"
    Button_hgs:addTouchEventListener(touchMapButton)

    --平顶山
    local Button_pds = self.superView.menuLayer:getWidgetByName("Button_pds")
    Button_pds.name = "pds"
    Button_pds:addTouchEventListener(touchMapButton)

    --白虎岭
    local Button_bhl = self.superView.menuLayer:getWidgetByName("Button_bhl")
    Button_bhl.name = "bhl"
    Button_bhl:addTouchEventListener(touchMapButton)

    --车迟国
    local Button_ccg = self.superView.menuLayer:getWidgetByName("Button_ccg")
    Button_ccg.name = "ccg"
    Button_ccg:addTouchEventListener(touchMapButton)

    --龙宫
    local Button_lg = self.superView.menuLayer:getWidgetByName("Button_lg")
    Button_lg.name = "lg"
    Button_lg:addTouchEventListener(touchMapButton)

    --地府
    local Button_df = self.superView.menuLayer:getWidgetByName("Button_df")
    Button_df.name = "df"
    Button_df:addTouchEventListener(touchMapButton)

    --宝象国
    local Button_bxg = self.superView.menuLayer:getWidgetByName("Button_bxg")
    Button_bxg.name = "bxg"
    Button_bxg:addTouchEventListener(touchMapButton)

    --盘丝洞
    local Button_psd = self.superView.menuLayer:getWidgetByName("Button_psd")
    Button_psd.name = "psd"
    Button_psd:addTouchEventListener(touchMapButton)

    --琵琶洞
    local Button_ppd = self.superView.menuLayer:getWidgetByName("Button_ppd")
    Button_ppd.name = "ppd"
    Button_ppd:addTouchEventListener(touchMapButton)

    --小雷音寺
    local Button_xlys = self.superView.menuLayer:getWidgetByName("Button_xlys")
    Button_xlys.name = "xlys"
    Button_xlys:addTouchEventListener(touchMapButton)

    --火焰山
    local Button_hys = self.superView.menuLayer:getWidgetByName("Button_hys")
    Button_hys.name = "hys"
    Button_hys:addTouchEventListener(touchMapButton)

    --狮驼岭
    local Button_stl = self.superView.menuLayer:getWidgetByName("Button_stl")
    Button_stl.name = "stl"
    Button_stl:addTouchEventListener(touchMapButton)

    --五庄观
    local Button_wzg = self.superView.menuLayer:getWidgetByName("Button_wzg")
    Button_wzg.name = "wzg"
    Button_wzg:addTouchEventListener(touchMapButton)

end

function WorldMapUI:loadData()
    --load room data

end
