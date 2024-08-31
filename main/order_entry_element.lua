local ItemEntryElement = require("item_entry_element")

local OrderEntryElement = {}
OrderEntryElement.__index = OrderEntryElement
setmetatable(OrderEntryElement, {__index = ItemEntryElement})

function OrderEntryElement:new(parent_group, x, y, bg_color, text_color, item, quantity)
    local o = ItemEntryElement:new(parent_group, x, y, bg_color, text_color, item)
    setmetatable(o, self)
    o.quantity = quantity
    return o
end

function OrderEntryElement:update(gpu)
    local size = {gpu.getSize()}
    if self.is_visible then
        if self.y < 1 or self.y > size[2] - 24 then
            return
        end
        ItemEntryElement.update(self, gpu)
        gpu.drawTextSmart(self.x + 259, self.y, "x" .. self.quantity, self.text_color, self.background_color, true, 1, 1)
    end
end

function OrderEntryElement:get_quantity()
    return self.quantity
end

return OrderEntryElement
