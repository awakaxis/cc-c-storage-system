require("image_resampling")
local ElementGroup = require "element_group"
local Element = {}
Element.__index = Element
Element.name = nil
Element.parent_group = nil
Element.is_visible = true
Element.x = 1
Element.y = 1
Element.width = 16
Element.height = 8
Element.background_color = 0xFFFFFF
Element.text_color = 0x00000000
Element.text = nil
Element.buffer = nil
Element.buffer_width = nil
Element.buffer_height = nil

function Element:new(name, parent_group, x, y, width, height, background_color, text_color, text, image)
    local buffer = nil
    local buffer_width = nil
    local buffer_height = nil
    if image then
        buffer = {image:getAsBuffer()}
        buffer_width = image:getWidth()
        buffer_height = image:getHeight()
    end
    local o = {
        name = name,
        parent_group = parent_group,
        x = x,
        y = y,
        width = width,
        height = height,
        background_color = background_color,
        text_color, text_color,
        text = text,
        buffer = buffer,
        buffer_width = buffer_width,
        buffer_height = buffer_height
    }
    setmetatable(o, self)
    return o
end

-- returns nil if the element was not clicked, otherwise returns itself
function Element:check_click(x, y, sneak)
    if not self.is_visible then
        return nil
    end
    if x == nil or y == nil or sneak == nil then
        return nil
    end
    if x >= self.x and x <= self.x + self.width and y >= self.y and y <= self.y + self.height then
        return self
    end
    return nil
end

function Element:on_click(x, y, sneak)
    print(string.format("Element clicked at %d, %d with sneak %s", x, y, tostring(sneak)))
end

function Element:update(gpu)
    -- monitor size: pixelX, pixelY, blockX, blockY, resMult
    local size = {gpu.getSize()}
    if self.is_visible then
        -- dont draw if off screen
        if self.x + self.width > 1 and self.x < size[1] + 1 and self.y + self.height > 1 and self.y < size[2] + 1 then
            local drawX = math.max(1, math.min(size[1], self.x))
            local drawY = math.max(1, math.min(size[2], self.y))
            local drawWidth = math.max(1, math.min(size[1] + 1, (self.x + self.width))) - drawX
            local drawHeight = math.max(1, math.min(size[2] + 1, (self.y + self.height))) - drawY
            
            -- print(string.format("drawHeight: %d", drawHeight))
            -- print(string.format("drawWidth: %d", drawWidth))
            gpu.filledRectangle(drawX, drawY, drawWidth, drawHeight, self.background_color)
            if self.buffer then
                local scaledBuffer = NearestNeighbor(self.buffer, self.buffer_width, self.buffer_height, self.width, self.height)
                local croppedBuffer = BufferCrop(scaledBuffer, self.width, self.x, self.y, drawX, drawY, drawWidth, drawHeight)
                -- print(table.unpack(croppedBuffer))
                -- print(drawWidth)
                -- print(string.format("cropped image height: %d", #croppedBuffer / drawWidth))
                gpu.drawBuffer(drawX, drawY, drawWidth, 1, table.unpack(croppedBuffer))
            end
            if self.text and self.name ~= "text" then
                io.stderr:write(string.format("\"are you sure you know what you're doing\" error in %s: Base elements should not handle text rendering\n", self.name))
            end
            gpu.sync()
        end
    end
end

function Element:set_visibility(is_visible)
    self.is_visible = is_visible
end

function Element:get_name()
    return self.name
end

function Element:get_parent_group()
    return self.parent_group
end

return Element