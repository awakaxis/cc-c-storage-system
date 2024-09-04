local BootPage = require("page.boot_page")
local OverviewPage = require("page.overview_page")
local OrderPage = require("page.order_page")
local RegistryPage = require("page.registry_page")
local OrderManager = require("order_manager")
local inspect = require("inspect")

local PageManager = {}
PageManager.__index = PageManager
PageManager.pages = {
    ["boot"] = BootPage:new(),
    ["overview"] = OverviewPage:new(),
    ["order"] = OrderPage:new(),
    ["registry"] = RegistryPage:new()
}
PageManager.current_page = PageManager.pages["boot"]
PageManager.gpu = nil
PageManager.last_clicked = nil

function PageManager:set_current_page(page_name)
    local page = self.pages[page_name]
    if page ~= nil then
        print("hi")
        self.current_page = page
        return
    end
    io.stderr:write("Error in PageManager: could not set page because page at index page_name is nil\n")
    if self.pages["boot"] == nil then
        io.stderr:write("Error in PageManager: failed to fallback to boot because pages[boot] is nil\n")
        return
    end
    self.current_page = self.pages["boot"]
end

function PageManager:set_gpu(gpu)
    self.gpu = gpu
end

function PageManager:get_gpu()
    return self.gpu
end

function PageManager:get_last_clicked()
    return self.last_clicked
end

function PageManager:handle_click(x, y, sneak)
    if self.current_page == nil then
        io.stderr:write("Error in PageManager: current_page is nil\n")
        return
    end
    if self.current_page.name == "boot" then
        self.current_page = self.pages["overview"]
        return
    end
    local last_clicked_element = self.current_page:handle_click(x, y, sneak)
    print("Last clicked element: " .. tostring(last_clicked_element))
    if last_clicked_element ~= nil then
        print("Last clicked element name: " .. tostring(last_clicked_element:get_name()))
        if last_clicked_element.page_name ~= nil then
            print(last_clicked_element.page_name)
            self:set_current_page(last_clicked_element.page_name)
        end
        if last_clicked_element:get_name() == "search" then
            if last_clicked_element:get_text() == nil then
                print("Setting text to empty string")
                last_clicked_element:set_text("")
            end
        end
        -- handle registry button click
        if last_clicked_element:get_name() == "registry_button" then
            local previous_page = self.current_page
            self:set_current_page("registry")
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
                    io.stderr:write("Invalid input - Expected string.\n")
                    return
                end
                if not string.match(identifier, "%a+:%a+") then
                    io.stderr:write("Invalid input - Expected format: \"mod:item\".\n")
                    return
                end
                return identifier
            end

            local function getDisplayName()
                io.stdout:write("Input item display name:\n")
                local display_name = tostring(io.stdin:read())
                if (type(display_name) ~= "string") then
                    io.stderr:write("Invalid input - Expected string.\n")
                    return
                end
                return display_name
            end

            local function getDataLink(str)
                io.stdout:write("Input item data link channel (peripheral:line), or \"done\" if done.\n")
                local data_link = tostring(io.stdin:read()):lower()
                if (type(data_link) ~= "string") then
                    io.stderr:write("Invalid input - Expected string.\n")
                    return str
                end
                if data_link == "done" then
                    if str == "[" then
                        io.stderr:write("At least one data link is required.\n")
                        return str
                    end
                    return str.."]"
                end
                if not string.match(data_link, ".+:%d+") then
                    io.stderr:write("Invalid input - Expected format: \"peripheral:line\".\n")
                    return str
                end
                local peripheralName, line = data_link:match("(.+):(%d+)")
                local peripheralType = peripheral.getType(peripheralName)
                if (peripheralType == nil or peripheralType ~= "create_target") then
                    io.stderr:write("Peripheral not present or not a CC:C Bridged target block.\n")
                    return str
                end
                if (tonumber(line) < 1 or tonumber(line) > 24) then
                    io.stderr:write("Invalid data line. Please choose a number between 1 and 24.\n")
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
                    io.stderr:write("Invalid input - Expected string.\n")
                    return
                end
                if not string.match(funnel, ".+:%a+") then
                    io.stderr:write("Invalid input - Expected format: \"peripheral:direction\".\n")
                    return
                end
                local peripheralName, direction = funnel:match("(.+):(%a+)")
                local peripheralType = peripheral.getType(peripheralName)
                print(peripheralType)
                if (peripheralType == nil or peripheralType ~= "tm_rsPort") then
                    io.stderr:write("Peripheral not present or not a redstone port.\n")
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
                    io.stderr:write("Invalid direction. Please choose one of: north, east, south, west, up, down.\n")
                    return
                end
                for _, line in ipairs(registry) do
                    if line:match(funnel) then
                        local identifier = line:match("\"identifier\": \"(%a+:%a+)\"")
                        io.stderr:write(string.format("Funnel is already bound to %s.\n", identifier))
                        return
                    end
                end
                peripheral.call(peripheralName, "setOutput", direction, true)
                return funnel
            end

            io.stdout:write("Would you like to add or remove an item from the registry? (add/remove)\n")
            local action = tostring(io.stdin:read()):lower()
            if action ~= "add" and action ~= "remove" then
                io.stderr:write("Invalid input - Expected \"add\" or \"remove\".\n")
                self:set_current_page("overview")
                return
            end
            if action == "remove" then
                local identifier = getIdentifier()
                for i, line in ipairs(registry) do
                    if line:match(identifier) then
                        for _, funnel in ipairs(registry[i].funnels) do
                            local funnelName, direction = string.match(funnel, "(.+):(.+)")
                            peripheral.call(funnelName, "setDirection", direction, false)
                        end
                        table.remove(registry, i)
                        break
                    end
                end
                file = io.open("registry.txt", "w")
                if file then
                    for _, line in ipairs(registry) do
                        file:write(line.."\n")
                    end
                    file:close()
                end
                if previous_page ~= nil then
                    previous_page:update_items()
                end
                for _, page in ipairs(self.pages) do
                    if page.name == "order" then
                        for _, group in ipairs(page.element_groups) do
                            for _, element in ipairs(group.elements) do
                                if element:get_name() == "search" then
                                    element:update_items()
                                end
                            end
                        end
                    end
                end
                OrderManager:update_items()
                self:set_current_page("overview")
                return
            else
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
            end
            if previous_page ~= nil then
                previous_page:update_items()
            end
            for _, page in ipairs(self.pages) do
                if page.name == "order" then
                    for _, group in ipairs(page.element_groups) do
                        for _, element in ipairs(group.elements) do
                            if element:get_name() == "search" then
                                element:update_items()
                            end
                        end
                    end
                end
            end
            OrderManager:update_items()
            self:set_current_page("overview")
        end
    end
    self.last_clicked = last_clicked_element
end

function PageManager:handle_scroll(scroll)
    if self.current_page == nil then
        io.stderr:write("Error in PageManager: current_page is nil\n")
        return
    end
    if self.last_clicked == nil then
        return
    end
    if self.last_clicked:get_parent_group().name == "scroller" then
        self.last_clicked:get_parent_group():translate_elements(0, scroll)
        return
    end
end

function PageManager:handle_key(char)
    if self.current_page == nil then
        io.stderr:write("Error in PageManager: current_page is nil\n")
        return
    end
    if self.last_clicked == nil then
        return
    end
    if self.last_clicked:get_name() == "search" then
        if self.last_clicked:get_text() == nil then
            self.last_clicked:set_text("")
        end
        if char == "backspace" then
            self.last_clicked:set_text(self.last_clicked:get_text():sub(1, -2))
            if self.last_clicked:get_text() == "" then
                self.last_clicked:set_text(nil)
            end
            return
        end
        print(char)
        self.last_clicked:set_text(self.last_clicked:get_text() .. char)
    end
    if self.last_clicked:get_name() == "quantity_selector" then
        if not char:match("[%d%-]") and char ~= "backspace" then
            print("Invalid character: " .. char)
            return
        end
        local new_quantity = tostring(self.last_clicked:get_quantity())
        if char == "backspace" then
            new_quantity = new_quantity:sub(1, -2)
        else
            new_quantity = new_quantity .. char
        end
        self.last_clicked:set_quantity(new_quantity)
    end
end

function PageManager:update()
    self.gpu.fill(0xFFFFFF)
    self.gpu.sync()
    if self.current_page == nil then
        io.stderr:write("Error in PageManager: current_page is nil\n")
        io.stderr:write("Attempting to set current_page to boot_page\n")
        self.current_page = self:set_current_page("boot")
        return
    end
    if self.gpu == nil then
        io.stderr:write("Error in PageManager: gpu is nil\n")
        return
    end
    self.current_page:draw(self.gpu)
end

return PageManager