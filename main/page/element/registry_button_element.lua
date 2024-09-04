local Element = require("page.element.element")

local RegistryButtonElement = {}
RegistryButtonElement.__index = RegistryButtonElement
setmetatable(RegistryButtonElement, {__index = Element})

function RegistryButtonElement:new(parent_group, x, y, width, height, background_color, text_color, text)
    local o = Element:new("registry_button", parent_group, x, y, width, height, background_color, text_color, nil, nil)
    setmetatable(o, self)
    o.button_text = text
    return o
end

function RegistryButtonElement:draw(gpu)
    Element.draw(self, gpu)
    gpu.drawTextSmart((self.x + (self.width / 2)) - ((self.button_text:len() * 8) / 2), self.y, self.button_text, self.text_color, self.background_color, true, 1, 1)
end

return RegistryButtonElement