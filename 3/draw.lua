local ImageResampling = require("image_resampling")
local PageManager = require("page_manager")

local gpu = peripheral.wrap("right")
local size = {gpu.getSize()}
gpu.refreshSize()
gpu.setSize(64)
gpu.fill(0xFFFFFFFF)
gpu.sync()

PageManager:set_gpu(gpu)


local function update()
    while true do
        PageManager:update()
        os.sleep(0.05)
    end
end

local function eventLoop()
    while true do
        local eventData = {os.pullEvent()}
        if eventData[1] == "tm_monitor_touch" then
            print(eventData[3], eventData[4], eventData[5])
            PageManager:handle_click(eventData[3], eventData[4], eventData[5])
        end
    end
end

parallel.waitForAny(update, eventLoop)

-- this stuff works:
-- local image = gpu.decodeImage(LoadImage("Untitled3.png"))
-- local image = gpu.decodeImage(table.unpack(ImageResampling:load_image("test2.png")))
-- local scaledBuffer = NearestNeighbor({image.getAsBuffer()}, image.getWidth(), image.getHeight(), 192, 128)
-- gpu.drawBuffer(1, 1, 192, 1, table.unpack(scaledBuffer))
-- gpu.sync()
