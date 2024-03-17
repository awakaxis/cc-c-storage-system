local Page = require("page")
local ElementGroup = require("element_group")
local Element = require("element")
local TextElement = require("text_element")
local ItemEntryElement = require("item_entry_element")
local ScrollerGroup = require("scroller_group")
local PageButtonElement = require("page_button_element")
local RegistryButtonElement = require("registry_button_element")

local OverviewPage = {}
OverviewPage.__index = OverviewPage
setmetatable(OverviewPage, {__index = Page})

local gpu = peripheral.find("tm_gpu")
local size = {gpu.getSize()}

local scroller_bg = ElementGroup:new(nil, "scroller_bg")
local scroller = ScrollerGroup:new(nil)
local border = ElementGroup:new(nil, "border_group")
local buttons = ElementGroup:new(nil, "button_group")

local scroller_elements = {}

local element_groups = {
    scroller_bg:set_elements({
        Element:new("scroller_bg", scroller, 8, 1, 256, size[2], 0xC6C6C6, 0x000000, nil, nil)
    }),
    scroller:set_elements(scroller_elements),
    border:set_elements({
        Element:new("border_top", border, 1, 1, size[1], 24, 0x939393, 0x000000, nil, nil),
        Element:new("border_bottom", border, 1, size[2] - 23, size[1], 24, 0x939393, 0x000000, nil, nil)
    }),
    buttons:set_elements({
        PageButtonElement:new(buttons, (size[1] - 64) - 20, 4, 40, 16, 0xCECECE, 0x000000, "Order", "order"),
        RegistryButtonElement:new(buttons, 32, 4, 40, 16, 0xCECECE, 0x000000, "Register New")
    })
}

function OverviewPage:update_items()
    scroller_elements = {}
    for i, item in ipairs(ParseItemData()) do
        scroller_elements[#scroller_elements+1] = ItemEntryElement:new(scroller, 8, 16 + (i * 27), 0xAAAAAA, 0x000000, item)
    end
    scroller:set_elements(scroller_elements)
end

function OverviewPage:new()
    local o = Page:new("overview", element_groups)
    setmetatable(o, self)
    o:update_items()
    return o
end
return OverviewPage