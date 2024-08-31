local Element = require("element")

local PageButtonElement = {}
PageButtonElement.__index = PageButtonElement
setmetatable(PageButtonElement, {__index = Element})

function PageButtonElement:new(parent_group, x, y, width, height, background_color, text_color, text, page_name)
    local o = Element:new("page_button", parent_group, x, y, width, height, background_color, text_color, nil, nil)
    setmetatable(o, self)
    o.button_text = text
    o.page_name = page_name
    return o
end

function PageButtonElement:update(gpu)
    Element.update(self, gpu)
    gpu.drawTextSmart((self.x + (self.width / 2)) - ((self.button_text:len() * 8) / 2), self.y, self.button_text, self.text_color, self.background_color, true, 1, 1)
end

return PageButtonElement