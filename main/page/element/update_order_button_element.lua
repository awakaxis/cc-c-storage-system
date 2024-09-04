local Element = require("page.element.element")

local UpdateOrderButtonElement = {}
UpdateOrderButtonElement.__index = UpdateOrderButtonElement
setmetatable(UpdateOrderButtonElement, {__index = Element})

function UpdateOrderButtonElement:new(parent_group, x, y, width, height, bg_color, text_color, text)
    local o = Element:new("update_order_button", parent_group, x, y, width, height, bg_color, text_color, nil, nil)
    setmetatable(o, self)
    o.draw_text = text
    return o
end

function UpdateOrderButtonElement:draw(gpu)
    if self.is_visible then
        Element.draw(self, gpu)
        gpu.drawTextSmart(self.x, self.y, self.draw_text, self.text_color, self.background_color, true, 1, 1)
        gpu.sync()
    end
end

return UpdateOrderButtonElement