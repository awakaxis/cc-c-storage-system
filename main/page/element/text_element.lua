local Element = require("page.element.element")
local Drawable = require("page.element.drawable")

local TextElement = {}
TextElement.__index = TextElement
setmetatable(TextElement, {__index = Element})
TextElement.type = "text_element"
TextElement.text = ""
TextElement.background_color = 0x565656
TextElement.text_color = 0xFFFFFF
TextElement.textSize = 1
TextElement.padding = 1
TextElement.alignFlag = 0

-- alignFlag is either 0, 1, or 2 and corresponds to left, center, and right alignment
function TextElement:new(x, y, size, padding, alignFlag, background_color, text_color, text)
    local o = Element:new(x, y, 0, 0)
    setmetatable(o, self)
    o.text = text or self.text
    o.background_color = background_color or self.background_color
    o.text_color = text_color or self.text_color
    o.textSize = size or self.textSize
    o.padding = padding or self.padding
    o.alignFlag = math.max(0, math.min(2, alignFlag))
    return o
end

function TextElement:check_click(x, y, sneak)
    return false
end

function TextElement:draw(gpu)
    if not self.is_visible then
        return
    end
    Drawable.draw(self, gpu)
    if self.text then
        if self.alignFlag == 0 then
            gpu.drawTextSmart(self.x, self.y - 8, self.text, self.text_color, self.background_color, true, self.textSize, self.padding)
        elseif self.alignFlag == 1 then
            gpu.drawTextSmart(self.x - ((string.len(self.text) * 8) / 2), self.y - 8, self.text, self.text_color, self.background_color, true, self.textSize, self.padding)
        elseif self.alignFlag == 2 then
            gpu.drawTextSmart(self.x - ((string.len(self.text) * 8)), self.y - 8, self.text, self.text_color, self.background_color, true, self.textSize, self.padding)
        end
    end
    gpu.sync()
end

return TextElement