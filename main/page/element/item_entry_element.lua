local Element = require("page.element.element")
local Drawable = require("page.element.drawable")
local ImageResampling = require("image_resampling")

function ParseItemData()
    local file = io.open("registry.txt", "r")
    local registry = {}
    if file then
        for line in file:lines() do
            local data_links = {}
            local data_link_str = line:match("\"data_links\": %[(.-)%]")
            for link in data_link_str:gmatch("(create_target_%d+:%d+)") do
                data_links[#data_links+1] = link
            end
            registry[#registry+1] = {
                identifier = line:match("\"identifier\": \"(%a+:[%a_]+)\","),
                display_name = line:match("\"display_name\": \"(.+)\","),
                data_links = data_links,
                funnels = {
                    funnel64 = line:match("\"funnel64\": ([%a_%d]+:%a+),"),
                    funnel16 = line:match("\"funnel16\": ([%a_%d]+:%a+),"),
                    funnel1 = line:match("\"funnel1\": ([%a_%d]+:%a+)}")
                }
            }
        end
        file:close()
    end
    return registry
end

local ItemEntryElement = {}
ItemEntryElement.__index = ItemEntryElement
setmetatable(ItemEntryElement, {__index = Element})
ItemEntryElement.type = "item_entry"
ItemEntryElement.background_color = 0x565656
ItemEntryElement.text_color = 0xFFFFFF
ItemEntryElement.item = nil
ItemEntryElement.icon = nil

local gpu = peripheral.find("tm_gpu")
local size = {gpu.getSize()}

function ItemEntryElement:new(x, y, background_color, text_color, item)
    local o = Element:new(x, y, 256, 24)
    setmetatable(o, self)
    o.item = item
    o.background_color = background_color
    o.text_color = text_color
    local namespace, identifier = item.identifier:match("(.+):(.+)")
    o.icon = gpu.decodeImage(table.unpack(ImageResampling:load_image(namespace..identifier..".png")))
    return o
end

function ItemEntryElement:create_placeholder(x, y, background_color, text_color)
    local o = Element:new(x, y, 256, 24)
    setmetatable(o, self)
    o.item = {
        identifier = "placeholder",
        display_name = "No Item Found.",
        data_links = {},
        funnels = {}
    }
    o.background_color = background_color
    o.text_color = text_color
    o.icon = gpu.decodeImage(table.unpack(ImageResampling:load_image("missing.png")))
    return o
end

function ItemEntryElement:get_item()
    return self.item
end

function ItemEntryElement:draw(gpu)
    if self.is_visible then
        if self.y < 1 or self.y > size[2] - 24 then
            return
        end
        Drawable.draw_element(self, gpu)
        local itemCount = 0
        if self.item.identifier ~= "placeholder" then
            for _, link in ipairs(self.item.data_links) do
                local peripheralName, line = link:match("(.+):(%d+)")
                line = tonumber(line)
                itemCount = itemCount + tonumber(peripheral.call(peripheralName, "getLine", line))
            end
        else
            itemCount = 9999
        end
        gpu.drawBuffer(self.x, self.y + 4, 16, 1, self.icon:getAsBuffer())
        gpu.drawTextSmart(self.x + 20, self.y + 4, self.item.display_name.." "..tostring(itemCount), self.text_color, self.background_color, true, 1, 1)
        gpu.sync()
    end
end

return ItemEntryElement