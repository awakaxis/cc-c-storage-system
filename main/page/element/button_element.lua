local ClickableElement = require("page.element.clickable_element")

local ButtonElement = {}
ButtonElement.__index = ButtonElement
setmetatable(ButtonElement, {__index = ClickableElement})
ButtonElement.background_color = 0x565656
ButtonElement.text_color = 0xFFFFFF
ButtonElement.text = nil

function ButtonElement:new(x, y, width, height, callback, background_color, text_color, text)
    local o = ClickableElement:new(x, y, width, height, callback)
    setmetatable(o, self)
    o.background_color = background_color
    o.text_color = text_color
    o.text = text
    return o
end

function ButtonElement:draw(gpu)
    -- monitor size: pixelX, pixelY, blockX, blockY, resMult
    local size = {gpu.getSize()}
    if self.is_visible then
        -- dont draw if off screen
        if self.x + self.width > 1 and self.x <= size[1] and self.y + self.height > 1 and self.y <= size[2] then
            local drawX = math.max(1, math.min(size[1], self.x))
            local drawY = math.max(1, math.min(size[2], self.y))
            local drawWidth = math.max(1, math.min(size[1] + 1, (self.x + self.width))) - drawX
            local drawHeight = math.max(1, math.min(size[2] + 1, (self.y + self.height))) - drawY
            
            -- print(string.format("drawHeight: %d", drawHeight))
            -- print(string.format("drawWidth: %d", drawWidth))
            gpu.filledRectangle(drawX, drawY, drawWidth, drawHeight, self.background_color)
            if self.text then
                gpu.drawTextSmart(self.x - ((string.len(self.text) * 8) / 2), self.y - 8, self.text, self.text_color, self.background_color, true, 1, 1)
            end
            gpu.sync()
        end
    end
end
