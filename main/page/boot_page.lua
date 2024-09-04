local Page = require("page.page")
local Element = require("page.element.element")
local DebugElement = require("page.element.debug_element")
local TextElement = require("page.element.text_element")
local ElementGroup = require("page.element.element_group")
local ImageResampling = require("image_resampling")

local BootPage = {}
BootPage.__index = BootPage
setmetatable(BootPage, {__index = Page})

local gpu = peripheral.find("tm_gpu")
local size = {gpu.getSize()}

local main_group = ElementGroup:new(nil, "main_group")

print(size[1].." "..size[2])

local element_groups = {
    main_group:set_elements({
        DebugElement:new(main_group, size[1] - 31, size[2] - 31, 32, 32, 0xFF0000, gpu.decodeImage(table.unpack(ImageResampling:load_image("a.png")))),
        TextElement:new(main_group, size[1] / 2, (size[2] / 2) - 16, 0, 0, 1, 1, 1, 0xFFFFFF, 0x000000, "Kana OS"),
        TextElement:new(main_group, size[1] / 2, (size[2] / 2) + 16, 0, 0, 1, 1, 1, 0xFFFFFF, 0x000000, "Developed by awakaxis")
    })
}

function BootPage:new()
    local o = Page:new("boot", element_groups)
    setmetatable(o, self)
    return o
end

function BootPage:draw(gpu)
    for _, element_group in ipairs(self.element_groups) do
        element_group:draw(gpu)
    end
end

return BootPage