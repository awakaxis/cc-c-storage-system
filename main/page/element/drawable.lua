local Drawable = {}
Drawable.__index = Drawable

---will attempt to draw the given drawable element "d", assuming it has the required properties
---@param d table
---@param gpu table
function Drawable.draw_element(d, gpu)
    local size = {gpu.getSize()}
    if d.is_visible then
        -- dont draw if off screen
        if d.x + d.width > 1 and d.x <= size[1] and d.y + d.height > 1 and d.y <= size[2] then
            local drawX = math.max(1, math.min(size[1], d.x))
            local drawY = math.max(1, math.min(size[2], d.y))
            local drawWidth = math.max(1, math.min(size[1] + 1, (d.x + d.width))) - drawX
            local drawHeight = math.max(1, math.min(size[2] + 1, (d.y + d.height))) - drawY
            
            -- print(string.format("drawHeight: %d", drawHeight))
            -- print(string.format("drawWidth: %d", drawWidth))
            if d.background_color then
                gpu.filledRectangle(drawX, drawY, drawWidth, drawHeight, d.background_color)
            end
            if d.text then
                gpu.drawTextSmart(d.x - ((string.len(d.text) * 8) / 2), d.y - 8, d.text, d.text_color, d.background_color, true, 1, 1)
            end
            gpu.sync()
        end
    end
end

-- function Drawable.draw_buffer(d, gpu)
--     if d.buffer then
--         local scaledBuffer = NearestNeighbor(d.buffer, d.buffer_width, d.buffer_height, d.width, d.height)
--         local croppedBuffer = BufferCrop(scaledBuffer, d.width, d.x, d.y, drawX, drawY, drawWidth, drawHeight)
--         -- print(table.unpack(croppedBuffer))
--         -- print(drawWidth)
--         -- print(string.format("cropped image height: %d", #croppedBuffer / drawWidth))
--         gpu.drawBuffer(drawX, drawY, drawWidth, 1, table.unpack(croppedBuffer))
--     end
-- end