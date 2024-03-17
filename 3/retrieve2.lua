local ItemEntryElement = require("item_entry_element")

local registry = ParseItemData()

local identifier

io.stdout:write("Enter item to fetch\n")
identifier = tostring(io.stdin:read())
local itemEntry
for _, item in ipairs(registry) do
    if item.identifier == identifier then
        itemEntry = item
        break
    end
end
if not itemEntry then
    io.stdout:write("Item not found in registry.\n")
    return
end
io.stdout:write("how many: ")
local num = tonumber(io.stdin:read())

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
    io.stdout:write(string.format("Tried to take %d items, but the system only contains %d\n", num, totalItems))
    return
end

for i = 1, stacks do
    print("stack")
    local funnel, direction = string.match(itemEntry.funnels.funnel64, "(.+):(.+)")
    print(funnel, direction)
    print(itemEntry.funnels.funnel64)
    peripheral.call(funnel, "setOutput", direction, false)
    os.sleep(0.25)
    peripheral.call(funnel, "setOutput", direction, true)
    os.sleep(0.25)
end

for i = 1, stacks16 do
    print("stack16")
    local funnel, direction = string.match(itemEntry.funnels.funnel16, "(.+):(.+)")
    print(funnel, direction)
    print(itemEntry.funnels.funnel16)
    peripheral.call(funnel, "setOutput", direction, false)
    os.sleep(0.25)
    peripheral.call(funnel, "setOutput", direction, true)
    os.sleep(0.25)
end

for i = 1, remainder do
    print("stack1")
    local funnel, direction = string.match(itemEntry.funnels.funnel1, "(.+):(.+)")
    print(funnel, direction)
    print(itemEntry.funnels.funnel1)
    peripheral.call(funnel, "setOutput", direction, false)
    os.sleep(0.25)
    peripheral.call(funnel, "setOutput", direction, true)
    os.sleep(0.25)
end