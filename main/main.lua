require("page.element.item_entry_element")
local ImageResampling = require("image_resampling")
local PageManager = require("page_manager")
local OrderManager = require("order_manager")

function Run()
    local gpu = peripheral.find("tm_gpu")
    gpu.refreshSize()
    gpu.setSize(64)
    gpu.fill(0xFFFFFFFF)
    gpu.sync()
    local size = {gpu.getSize()}
    print(size[1], size[2], size[3], size[4], size[5])
    local kb = peripheral.find("tm_keyboard")
    if (kb == nil) then
        io.stderr:write("No keyboard found. A keyboard is required to operate this machine.\n")
    else
        kb.setFireNativeEvents(true)
    end

    PageManager:set_gpu(gpu)

    local registry = ParseItemData()
    print(#registry)
    for _, item in ipairs(registry) do
        local item_id = item.identifier
        for _, funnel in pairs(item.funnels) do
            local funnelName, direction = string.match(funnel, "(.+):(.+)")
            peripheral.call(funnelName, "setOutput", direction, true)
            -- print(string.format("turned on funnel %s:%s for %s", funnelName, direction, item_id))
        end
    end

    local shift = false


    local function update()
        while true do
            PageManager:update()
            os.sleep(0.01)
        end
    end

    local function orderUpdate()
        while true do
            if not OrderManager:is_fulfilling_order() then
                OrderManager:fulfill_order()
            end
            os.sleep(1)
        end
    end

    local function eventLoop()
        while true do
            local eventData = {os.pullEvent()}
            if eventData[1] == "tm_monitor_touch" then
                print(eventData[3], eventData[4], eventData[5])
                PageManager:handle_click(eventData[3], eventData[4], eventData[5])
            elseif eventData[1] == "tm_monitor_mouse_click" then
                PageManager:handle_click(eventData[3], eventData[4], false)
            elseif eventData[1] == "tm_monitor_mouse_scroll" then
                PageManager:handle_scroll(eventData[5])
            elseif eventData[1] == "key_up" then
                if eventData[2] == 340 then
                    shift = false
                end
            elseif eventData[1] == "key" then
                if eventData[2] == 340 then
                    shift = true
                end
                if eventData[2] == 259 then
                    PageManager:handle_key("backspace")
                end
            elseif eventData[1] == "char" then
                PageManager:handle_key(eventData[2])
            else
                -- if eventData[1] ~= "timer" then
                --     print(table.unpack(eventData))
                -- end
            end
        end
    end

    parallel.waitForAny(update, eventLoop, orderUpdate)

    -- this stuff works:
    -- local image = gpu.decodeImage(LoadImage("Untitled3.png"))
    -- local image = gpu.decodeImage(table.unpack(ImageResampling:load_image("test2.png")))
    -- local scaledBuffer = NearestNeighbor({image.getAsBuffer()}, image.getWidth(), image.getHeight(), 192, 128)
    -- gpu.drawBuffer(1, 1, 192, 1, table.unpack(scaledBuffer))
    -- gpu.sync()
end
