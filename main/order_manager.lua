local registry = ParseItemData()

local OrderManager = {}
OrderManager.__index = OrderManager

local orders = {}
local fulfilling_order = false

function OrderManager:update_items()
    registry = ParseItemData()
end

function OrderManager:is_fulfilling_order()
    return fulfilling_order
end

-- order is an array of identifier, quantity pairs
function OrderManager:new_order(order)
    orders[#orders+1] = order
end

function OrderManager:fulfill_order()
    if #orders == 0 then
        return
    end
    fulfilling_order = true
    for _, orderItem in ipairs(orders[1]) do
        print(table.unpack(orderItem))
        local identifier = orderItem.identifier
        local num = orderItem.quantity

        local itemEntry
        for _, item in ipairs(registry) do
            if item.identifier == identifier then
                itemEntry = item
                break
            end
        end
        if not itemEntry then
            io.stdout:write("Item identifier %s not found in registry.\n", identifier)
            return
        end

        local stacks = num / 64
        local remainder = num % 64
        local stacks16 = remainder / 16
        remainder = remainder % 16

        local totalItems = 0
        for _, link in ipairs(itemEntry.data_links) do
            local peripheralName, line = link:match("(.+):(%d+)")
            line = tonumber(line)
            totalItems = totalItems + tonumber(peripheral.call(peripheralName, "getLine", line))
        end

        if totalItems < num then
            io.stdout:write(string.format("Tried to take %d %s items, but the system only contains %d\n", num, identifier, totalItems))
            return
        end

        for i = 1, stacks do
            print(string.format("stack64 for %s", identifier))
            local funnel, direction = string.match(itemEntry.funnels.funnel64, "(.+):(.+)")
            -- print(funnel, direction)
            -- print(itemEntry.funnels.funnel64)
            peripheral.call(funnel, "setOutput", direction, false)
            os.sleep(0.25)
            peripheral.call(funnel, "setOutput", direction, true)
            os.sleep(0.25)
        end

        for i = 1, stacks16 do
            print(string.format("stack16 for %s", identifier))
            local funnel, direction = string.match(itemEntry.funnels.funnel16, "(.+):(.+)")
            -- print(funnel, direction)
            -- print(itemEntry.funnels.funnel16)
            peripheral.call(funnel, "setOutput", direction, false)
            os.sleep(0.25)
            peripheral.call(funnel, "setOutput", direction, true)
            os.sleep(0.25)
        end

        for i = 1, remainder do
            print(string.format("stack1 for %s", identifier))
            local funnel, direction = string.match(itemEntry.funnels.funnel1, "(.+):(.+)")
            -- print(funnel, direction)
            -- print(itemEntry.funnels.funnel1)
            peripheral.call(funnel, "setOutput", direction, false)
            os.sleep(0.25)
            peripheral.call(funnel, "setOutput", direction, true)
            os.sleep(0.25)
        end
    end
    table.remove(orders, 1)
    fulfilling_order = false
end

return OrderManager