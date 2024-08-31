local function getChannel(item, stackSize)
    io.stdout:write(string.format("Channel location for %s%d: (peripheral:direction)\n", item, stackSize))
    local itemStack = tostring(io.stdin:read())
    if (type(itemStack) ~= "string") then
        io.stdout:write("Invalid input - Expected string.\n")
        return
    end

    if itemStack:lower() == "none" then
        return "none"
    end

    if itemStack:lower() == "pass" then
        return "pass"
    end

    if string.find(itemStack, ":") == nil then
        io.stdout:write("Channel location must be in the format of 'peripheral:direction'.\n")
        return
    end

    local t = {}
    for word in string.gmatch(itemStack, '([^:]+)') do
        table.insert(t, word)
    end

    local peripheralName, direction = t[1], string.lower(t[2])
    local peripheralType = peripheral.getType(peripheralName)
    if peripheralType == nil or peripheralType ~= "tm_rsPort" then
        io.stdout:write(string.format("Peripheral %s is not present or is not a redstone port.\n", peripheralName))
        return
    end

    local validDirections = {"north", "east", "south", "west", "up", "down"}
    local isValidDirection = false
    for _, dir in ipairs(validDirections) do
        if direction == dir then
            isValidDirection = true
            break
        end
    end

    if not isValidDirection then
        io.stdout:write("Invalid direction. Please choose one of: north, east, south, west, up, down.\n")
        return
    end
    return string.format("%s:%s", peripheralName, direction)
end

local function getInfoLink(item)
    io.stdout:write(string.format("Link router for %s\n", item))
    local linkName = tostring(io.stdin:read())
    if (type(linkName) ~= "string") then
        io.stdout:write("Invalid input - Expected string.\n")
        return
    end
    local peripheralType = peripheral.getType(linkName)
    if peripheralType == nil or peripheralType ~= "create_target" then
        io.stdout:write(string.format("Peripheral %s is not present or is not a CC:C Bridged target block.\n", linkName))
        return
    end
    io.stdout:write(string.format("Data line for %s\n", item))
    local dataLine = tonumber(io.stdin:read())
    if (type(dataLine) ~= "number") then
        io.stdout:write("Invalid input - Expected number.\n")
        return
    end
    if dataLine < 1 or dataLine > 24 then
        io.stdout:write("Invalid data line. Please choose a number between 1 and 24.\n")
        return
    end
    return string.format("%s:%d", linkName, dataLine)
end

-- get the data links and item data from file
local file = io.open("dataLinks.txt", "r")
local dataLinks = {}
if file then
    for line in file:lines() do
        local k, v = string.match(line, "%[(.+)%]: %[(.+)%]")
        if k and v then dataLinks[k] = v end
    end
    file:close()
end

file = io.open("itemData.txt", "r")
local itemData = {}
if file then
    for line in file:lines() do
        local k, v = string.match(line, "%[(.+)%]: %[(.+)%]")
        if k and v then itemData[k] = v end
    end
    file:close()
end

-- get the item identifier from the user to be registered
io.stdout:write("item identifier:\n")
local item = tostring(io.stdin:read())
if (type(item) ~= "string") then
    io.stdout:write("invalid input - Expected string.\n")
    return
end
item = item:lower()

-- get the link for the item from the user
local itemDataLink
while itemDataLink == nil do
    itemDataLink = getInfoLink(item)
    for k, v in pairs(dataLinks) do
        if k ~= item and v == itemDataLink then
            io.stdout:write(string.format("Linker is already bound to item %s\n", v, k))
            itemDataLink = nil
            break
        end
    end
end

-- get the funnel channels for the item from the user
local item64
while item64 == nil do
    item64 = getChannel(item, 64)
    for k, v in pairs(itemData) do
        if k ~= string.format("%s64", item) and v == item64 then
            io.stdout:write(string.format("Channel is already bound to item %s\n", k))
            item64 = nil
            break
        end
    end
end
local item32
while item32 == nil do
    item32 = getChannel(item, 32)
    for k, v in pairs(itemData) do
        if k ~= string.format("%s32", item) and v == item32 then
            io.stdout:write(string.format("Channel is already bound to item %s\n", k))
            item32 = nil
            break
        end
    end
end
local item1
while item1 == nil do
    item1 = getChannel(item, 1)
    for k, v in pairs(itemData) do
        if k ~= string.format("%s1", item) and v == item1 then
            io.stdout:write(string.format("Channel is already bound to item %s\n", k))
            item1 = nil
            break
        end
    end
end

-- modify the item data with the new channels
if item64 ~= "pass" then
    itemData[string.format("%s64", item)] = item64
end
if item32 ~= "pass" then
    itemData[string.format("%s32", item)] = item32
end
if item1 ~= "pass" then
    itemData[string.format("%s1", item)] = item1
end

-- modify the data links with the new item data link
dataLinks[item] = itemDataLink

-- write the new data to the files
file = io.open("dataLinks.txt", "w")
if file then
    for k, v in pairs(dataLinks) do
        file:write(string.format("[%s]: [%s]\n", k, v))
    end
    file:close()
else
    io.stdout:write("Failed to open dataLinks.txt for writing.\n")
end

file = io.open("itemData.txt", "w")
if file then
    for k, v in pairs(itemData) do
        local routerName, direction = string.match(v, "(.+):(.+)")
        local router = peripheral.wrap(routerName)
        router.setOutput(direction, true)
        file:write(string.format("[%s]: [%s]\n", k, v))
    end
    file:close()
else
    io.stdout:write("Failed to open itemData.txt for writing.\n")
end