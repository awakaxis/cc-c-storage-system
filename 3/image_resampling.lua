local ImageResampling = {}
ImageResampling.__index = ImageResampling
ImageResampling.gpu = peripheral.wrap("right")

function NearestNeighbor(originalPixels, originalWidth, originalHeight, newWidth, newHeight)
    local newPixels = {}
    local ratioX = originalWidth / newWidth
    local ratioY = originalHeight / newHeight
    for y = 1, newHeight do
        for x = 1, newWidth do
            local px = math.floor((x - 1) * ratioX)
            local py = math.floor((y - 1) * ratioY)
            newPixels[(y - 1) * newWidth + x] = originalPixels[(py * originalWidth) + px + 1]
        end
    end
    return newPixels
end

function ImageResampling:load_image(name)
    local png = io.open(name, "rb")
    local b = png._handle.read(1)
    local bytes = {}
    while b do
        bytes[#bytes + 1] = string.unpack("<I1", b)
        b = png._handle.read(1)
    end
    png:close()
    return bytes
end

-- function BufferCrop(buffer, bufferWidth, bufferHeight, originX, originY, monitorWidth, monitorHeight)
--     local newBuffer = {}
--     for y = 0, bufferHeight do
--         for x = 0, bufferWidth do
--             if originX + x >= 1 and originX + x <= monitorWidth and originY + y >= 1 and originY + y <= monitorHeight then
--                 newBuffer[#newBuffer+1] = buffer[(y - 1) * bufferWidth + x + 1]
--             end
--         end
--     end
--     return newBuffer
-- end--
-- function BufferCrop(buffer, buffer_width, originX, originY, drawX, drawY, drawWidth, drawHeight)
--     local newBuffer = {}
--     for y = drawY, drawY + drawHeight - 1 do
--         for x = drawX, drawX + drawWidth - 1 do
--             local ogX = x - originX
--             local ogY = y - originY
--             newBuffer[#newBuffer+1] = buffer[((ogY - 1) * buffer_width) + (ogX)]
--         end
--     end
--     return newBuffer
-- end
function BufferCrop(buffer, buffer_width, originX, originY, drawX, drawY, drawWidth, drawHeight)
    local newBuffer = {}
    for y = drawY, drawY + drawHeight - 1 do
        for x = drawX, drawX + drawWidth - 1 do
            local ogX = x - originX
            local ogY = y - originY
            newBuffer[#newBuffer + 1] = buffer[((ogY) * buffer_width) + ogX + 1]
        end
    end
    return newBuffer
end


return ImageResampling