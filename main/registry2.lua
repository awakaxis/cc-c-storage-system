local registry = {}
local file = io.open("registry.txt", "r")
if file then
    for line in file:lines() do
        registry[#registry+1] = line
    end
    file:close()
end

local function getIdentifier()
    io.stdout:write("Input item identifier: (mod:item)\n")
    local identifier = tostring(io.stdin:read()):lower()
    if (type(identifier) ~= "string") then
        io.stdout:write("Invalid input - Expected string.\n")
        return
    end
    if not string.match(identifier, "%a+:%a+") then
        io.stdout:write("Invalid input - Expected format: \"mod:item\".\n")
        return
    end
    return identifier
end

local function getDisplayName()
    io.stdout:write("Input item display name:\n")
    local display_name = tostring(io.stdin:read())
    if (type(display_name) ~= "string") then
        io.stdout:write("Invalid input - Expected string.\n")
        return
    end
    return display_name
end

local function getDataLink(str)
    io.stdout:write("Input item data link channel (peripheral:line), or \"done\" if done.\n")
    local data_link = tostring(io.stdin:read()):lower()
    if (type(data_link) ~= "string") then
        io.stdout:write("Invalid input - Expected string.\n")
        return str
    end
    if data_link == "done" then
        if str == "[" then
            io.stdout:write("At least one data link is required.\n")
            return str
        end
        return str.."]"
    end
    if not string.match(data_link, ".+:%d+") then
        io.stdout:write("Invalid input - Expected format: \"peripheral:line\".\n")
        return str
    end
    local peripheralName, line = data_link:match("(.+):(%d+)")
    local peripheralType = peripheral.getType(peripheralName)
    if (peripheralType == nil or peripheralType ~= "create_target") then
        io.stdout:write("Peripheral not present or not a CC:C Bridged target block.\n")
        return str
    end
    if (tonumber(line) < 1 or tonumber(line) > 24) then
        io.stdout:write("Invalid data line. Please choose a number between 1 and 24.\n")
        return str
    end
    if str == "[" then
        return str..data_link
    end
    return str..", "..data_link
end

local function getFunnel(num)
    io.stdout:write(string.format("Input item funnel%d channel (peripheral:direction)\n", num))
    local funnel = tostring(io.stdin:read())
    if (type(funnel) ~= "string") then
        io.stdout:write("Invalid input - Expected string.\n")
        return
    end
    if not string.match(funnel, ".+:%a+") then
        io.stdout:write("Invalid input - Expected format: \"peripheral:direction\".\n")
        return
    end
    local peripheralName, direction = funnel:match("(.+):(%a+)")
    local peripheralType = peripheral.getType(peripheralName)
    print(peripheralType)
    if (peripheralType == nil or peripheralType ~= "tm_rsPort") then
        io.stdout:write("Peripheral not present or not a redstone port.\n")
        return
    end
    local validDirections = {"north", "east", "south", "west", "up", "down"}
        local isValidDirection = false
        for _, dir in ipairs(validDirections) do
            if direction:lower() == dir then
                isValidDirection = true
                break
            end
        end
    if not isValidDirection then
        io.stdout:write("Invalid direction. Please choose one of: north, east, south, west, up, down.\n")
        return
    end
    for _, line in ipairs(registry) do
        if line:match(funnel) then
            local identifier = line:match("\"identifier\": \"(%a+:%a+)\"")
            io.stdout:write("Funnel is already bound to %s.\n", identifier)
            return
        end
    end
    peripheral.call(peripheralName, "setOutput", direction, true)
    return funnel
end

local out = "{"

local identifier
while identifier == nil do
    identifier = getIdentifier()
end
out = out..string.format("\"identifier\": \"%s\"", identifier)

local display_name
while display_name == nil do
    display_name = getDisplayName()
end
out = out..string.format(", \"display_name\": \"%s\"", display_name)

local data_link = "["
while not data_link:match("%]") do
    data_link = getDataLink(data_link)
end
out = out..string.format(", \"data_links\": %s", data_link)

local funnel64
while funnel64 == nil do
    funnel64 = getFunnel(64)
end
local funnel16
while funnel16 == nil do
    funnel16 = getFunnel(16)
end
local funnel1
while funnel1 == nil do
    funnel1 = getFunnel(1)
end
out = out..string.format(", \"funnels\": {\"funnel64\": %s, \"funnel16\": %s, \"funnel1\": %s}", funnel64, funnel16, funnel1)

out = out.."}"
local duplicate = false
for i, line in ipairs(registry) do
    if line:match(identifier) then
        duplicate = true
        registry[i] = out
        break
    end
end
if not duplicate then
    registry[#registry+1] = out
end

file = io.open("registry.txt", "w")
if file then
    for _, line in ipairs(registry) do
        file:write(line.."\n")
    end
    file:close()
end
