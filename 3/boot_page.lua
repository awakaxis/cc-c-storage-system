local Page = require("page")
local Element = require("element")
local DebugElement = require("debug_element")
local ElementGroup = require("element_group")
local ImageResampling = require("image_resampling")

local BootPage = {}
BootPage.__index = BootPage
setmetatable(BootPage, {__index = Page})

local gpu = peripheral.find("tm_gpu")
local size = {gpu.getSize()}
local element_groups = {
    ElementGroup:new({
                DebugElement:new(size[1] - 31, size[2] - 31, 32, 32, 0xFF0000, gpu.decodeImage(table.unpack(ImageResampling:load_image("debug.png")))),
                Element:new("test", 65, 65, 0, 0, 0xFFFFFF, 0x000000, "storage system", nil)},
    "test_group")
}

function BootPage:new()
    local o = Page:new("boot", element_groups)
    setmetatable(o, self)
    return o
end

function BootPage:update(gpu)
    for _, element_group in ipairs(self.element_groups) do
        element_group:update(gpu)
    end
end

return BootPage