local Element = require("element")

local QuantitySelectorElement = {}
QuantitySelectorElement.__index = QuantitySelectorElement
setmetatable(QuantitySelectorElement, {__index = Element})

function QuantitySelectorElement:new(parent_group, x, y, bg_color, text_color)
    local o = Element:new("quantity_selector", parent_group, x, y, 80, 16, bg_color, text_color, nil, nil)
    setmetatable(o, self)
    o.max_quantity = 0
    o.quantity = "0"
    o.value = 0
    return o
end

function QuantitySelectorElement:get_max_quantity()
    return self.max_quantity
end

function QuantitySelectorElement:set_max_quantity(quantity)
    self.max_quantity = quantity
end

function QuantitySelectorElement:get_quantity()
    return self.quantity
end

function QuantitySelectorElement:set_quantity(quantity)
    self.quantity = quantity
end

function QuantitySelectorElement:get_value()
    return self.value
end

function QuantitySelectorElement:update(gpu)
    if self.is_visible then
        Element.update(self, gpu)
        if self.quantity ~= nil then
            if not self.quantity:match("-?%d+") then
                print(string.format("Invalid quantity: %s", self.quantity))
                self.value = 0
            else
                self.value = tonumber(self.quantity)
            end
            if tostring(self.value):len() * 8 > self.width then
                gpu.drawTextSmart(self.x, self.y, "too long", self.text_color, self.background_color, true, 1, 1)
            elseif self.value > self.max_quantity then
                gpu.drawTextSmart(self.x, self.y, "too much", self.text_color, self.background_color, true, 1, 1)
            else
                gpu.drawTextSmart(self.x, self.y, self.quantity, self.text_color, self.background_color, true, 1, 1)
            end
        end
        gpu.sync()
    end
end

return QuantitySelectorElement