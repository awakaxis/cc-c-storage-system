io.stdout:write("what: ")
local item = tostring(io.stdin:read())
if type(item) ~= "string" then
    io.stdout:write("Invalid input.\n")
    return
end

local file = io.open("itemData.txt", "r")
local itemData = {}
if file then
    for line in file:lines() do
        local k, v = string.match(line, "%[(.+)%]: %[(.+)%]")
        if k and v then itemData[k] = v end
    end
    file:close()
end

file = io.open("dataLinks.txt", "r")
local dataLinks = {}
if file then
    for line in file:lines() do
        local k, v = string.match(line, "%[(.+)%]: %[(.+)%]")
        if k and v then dataLinks[k] = v end
    end
    file:close()
end

if not itemData[string.format("%s64", item)] and not itemData[string.format("%s32", item)] and not itemData[string.format("%s1", item)] then
    io.stdout:write("Item not found in registry.\n")
    return
end
if itemData[string.format("%s64", item)] == "none" and itemData[string.format("%s32", item)] == "none" and itemData[string.format("%s1", item)] == "none" then
    io.stdout:write("Item has no bound funnels.\n")
    return
end
io.stdout:write(string.format("%s64 is bound to %s\n", item, itemData[string.format("%s64", item)]))
io.stdout:write(string.format("%s32 is bound to %s\n", item, itemData[string.format("%s32", item)]))
io.stdout:write(string.format("%s1 is bound to %s\n", item, itemData[string.format("%s1", item)]))

local routerName64, direction64 = string.match(itemData[string.format("%s64", item)], "(.+):(.+)")
local routerName32, direction32 = string.match(itemData[string.format("%s32", item)], "(.+):(.+)")
local routerName1, direction1 = string.match(itemData[string.format("%s1", item)], "(.+):(.+)")

local router64 = peripheral.wrap(routerName64)
local router32 = peripheral.wrap(routerName32)
local router1 = peripheral.wrap(routerName1)

io.stdout:write("how: ")
local num = tonumber(io.stdin:read())
if type(num) ~= "number" then
    io.stdout:write("NOT A NUMBER\n")
    return
end

if not dataLinks[item] then
    io.stdout:write("Item has no data link.\n")
    return
end

local linkerName, line = string.match(dataLinks[item], "(.+):(.+)")
line = tonumber(line)
local dataLink = peripheral.wrap(linkerName)
local itemCount = tonumber(dataLink.getLine(line))
if itemCount < num then
    io.stdout:write(string.format("Tried to take %d items, but the system only contains %d\n", num, itemCount))
    return
end

local stacks = num / 64
local remainder = num % 64
local halfStack = false
if remainder >= 32 then
    halfStack = true
    remainder = remainder - 32
end
for i = 1, stacks do
    print(string.format("stack number %d", i))
    router64.setOutput(direction64, false)
    os.sleep(0.25)
    router64.setOutput(direction64, true)
    os.sleep(0.25)
end
if halfStack then
    print("half a stack")
    router32.setOutput(direction32, false)
    os.sleep(0.25)
    router32.setOutput(direction32, true)
    os.sleep(0.25)
end
for i = 1, remainder do
    print(string.format("item remainder number %d", i))
    router1.setOutput(direction1, false)
    os.sleep(0.25)
    router1.setOutput(direction1, true)
    os.sleep(0.25)
end