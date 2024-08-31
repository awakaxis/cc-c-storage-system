io.stdout:write("Item: ")
local item = tostring(io.stdin:read())
if type(item) ~= "string" then
    io.stdout:write("Invalid input.\n")
    return
end

local dataFile = io.open("dataLinks.txt", "r")
local data = {}
if dataFile then
    for line in dataFile:lines() do
        local k, v = string.match(line, "%[(.+)%]: %[(.+)%]")
        if k and v then data[k] = v end
    end
    dataFile:close()
end
if not data[item] then
    io.stdout:write("Item has no data link.\n")
    return
end
local linker, line = string.match(data[item], "(.+):(.+)")
line = tonumber(line)
local dataLink = peripheral.wrap(linker)
local itemCount = dataLink.getLine(line)
io.stdout:write(string.format("Item count: %d\n", itemCount))