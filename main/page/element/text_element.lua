local Element = require("page.element.element")

local TextElement = {}
TextElement.__index = TextElement
setmetatable(TextElement, {__index = Element})
TextElement.textOffsetX = 0
TextElement.textOffsetY = 0
TextElement.textSize = 1
TextElement.padding = 1
TextElement.alignFlag = 0

-- alignFlag is either 0, 1, or 2 and corresponds to left, center, and right alignment
function TextElement:new(parent_group, x, y, textOffX, textOffY, size, padding, alignFlag, background_color, text_color, text)
    local o = Element:new("text", parent_group, x, y, 0, 0, background_color, text_color, text, nil)
    setmetatable(o, self)
    o.textOffsetX = textOffX
    o.textOffsetY = textOffY
    o.textSize = size
    o.padding = padding
    o.alignFlag = math.max(0, math.min(2, alignFlag))
    return o
end

function TextElement:check_click(x, y, sneak)
    return nil
end

function TextElement:draw(gpu)
    if not self.is_visible then
        return
    end
    Element.draw(self, gpu)
    if self.text then
        gpu.setFont("ascii")
        if self.alignFlag == 0 then
            gpu.drawTextSmart(self.x + self.textOffsetX, self.y + self.textOffsetY - 8, self.text, self.text_color, self.background_color, true, self.textSize, self.padding)
        elseif self.alignFlag == 1 then
            gpu.drawTextSmart((self.x + self.textOffsetX) - ((string.len(self.text) * 8) / 2), self.y + self.textOffsetY - 8, self.text, self.text_color, self.background_color, true, self.textSize, self.padding)
        elseif self.alignFlag == 2 then
            gpu.drawTextSmart((self.x + self.textOffsetX) - ((string.len(self.text) * 8)), self.y + self.textOffsetY - 8, self.text, self.text_color, self.background_color, true, self.textSize, self.padding)
        end
    end
    gpu.sync()
end

return TextElement