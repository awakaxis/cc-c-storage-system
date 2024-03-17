local Page = require("page")
local TextElement = require("text_element")
local ElementGroup = require("element_group")

local RegistryPage = {}
RegistryPage.__index = RegistryPage
setmetatable(RegistryPage, {__index = Page})

local gpu = peripheral.find("tm_gpu")
local size = {gpu.getSize()}

local main_group = ElementGroup:new(nil, "main_group")

local element_groups = {
    main_group:set_elements({
        TextElement:new(main_group, size[1] / 2, (size[2] / 2), 0, 0, 1, 1, 1, 0xFFFFFF, 0x000000, "Continue in console.")
    })
}

function RegistryPage:new()
    local o = Page:new("registry", element_groups)
    setmetatable(o, self)
    return o
end

return RegistryPage