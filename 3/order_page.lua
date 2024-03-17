local Page = require("page")
local ElementGroup = require("element_group")
local ScrollerGroup = require("scroller_group")
local PageButtonElement = require("page_button_element")
local Element = require("element")
local OrderManager = require("order_manager")
local SearchElement = require("search_element")
local QuantitySelectorElement = require("quantity_selector_element")
local OrderEntryElement = require("order_entry_element")
local UpdateOrderButtonElement = require("update_order_button_element")
local SubmitOrderButtonElement = require("submit_order_button_element")

local OrderPage = {}
OrderPage.__index = OrderPage
setmetatable(OrderPage, {__index = Page})

local gpu = peripheral.find("tm_gpu")
local size = {gpu.getSize()}

local order_elements = {}

local order_scroller = ScrollerGroup:new(nil)
local order_pane = ElementGroup:new(nil, "order_pane")
local buttons = ElementGroup:new(nil, "button_group")

local element_groups = {
    order_scroller:set_elements(order_elements),
    order_pane:set_elements({
        Element:new("border_top", order_pane, 1, 1, size[1], 24, 0x939393, 0x000000, nil, nil),
        Element:new("border_bottom", order_pane, 1, size[2] - 95, size[1], 96, 0x939393, 0x000000, nil, nil),
        SearchElement:new(order_pane, 4, size[2] - 90, 0xFFFFFF, 0x000000, "Search for items"),
        QuantitySelectorElement:new(order_pane, 4, size[2] - 44, 0xFFFFFF, 0x000000),
        UpdateOrderButtonElement:new(order_pane, 100, size[2] - 44, 64, 16, 0xCECECE, 0x000000, "Update Order"),
        SubmitOrderButtonElement:new(order_pane, 200, size[2] - 44, 64, 16, 0xCECECE, 0x000000, "Submit Order")

    }),
    buttons:set_elements({
        PageButtonElement:new(buttons, (size[1] - 64) - 32, 4, 64, 16, 0xCECECE, 0x000000, "Overview", "overview")
    })
}

function OrderPage:new()
    local o = Page:new("order", element_groups)
    setmetatable(o, self)
    return o
end

function OrderPage:handle_click(x, y, sneak)
    local clicked_element = Page.handle_click(self, x, y, sneak)
    if clicked_element ~= nil then
        if clicked_element:get_name() == "update_order_button" then
            print("Order updated")
            local search_preview = nil
            local quantity_selector = nil
            for _, group in ipairs(self.element_groups) do
                for _, element in ipairs(group.elements) do
                    if element:get_name() == "search" then
                        if element:get_preview_entry() ~= nil then
                            search_preview = element:get_preview_entry()
                        end
                    end
                    if element:get_name() == "quantity_selector" then
                        quantity_selector = element
                    end
                end
            end
            local order_entry = nil
            if search_preview ~= nil and quantity_selector ~= nil and search_preview:get_item().identifier ~= "placeholder" then
                local startPos = 30
                if order_scroller ~= nil and order_elements[1] ~= nil then
                    startPos = order_elements[1].y
                end
                order_entry = OrderEntryElement:new(order_scroller, 8, startPos + (#order_elements * 27), 0xAAAAAA, 0x000000, search_preview:get_item(), quantity_selector:get_value())
                local duplicate = false
                for i, element in ipairs(order_elements) do
                    if element:get_name() == "item_entry" then
                        if element.quantity ~= nil and element.quantity > 0 then
                            if element:get_item().identifier == order_entry:get_item().identifier then
                                order_elements[i] = OrderEntryElement:new(self.element_groups[1], 8, order_elements[i].y, 0xAAAAAA, 0x000000, search_preview:get_item(), quantity_selector:get_value())
                                duplicate = true
                            end
                        end
                    end
                end
                if not duplicate then
                    order_elements[#order_elements + 1] = order_entry
                end
            end
        end
        if clicked_element:get_name() == "submit_order_button" then
            print("Order submitted")
            local order = {}
            for _, element in ipairs(order_elements) do
                if element:get_name() == "item_entry" then
                    order[#order + 1] = {
                        identifier = element:get_item().identifier,
                        quantity = element.quantity
                    }
                end
            end
            OrderManager:new_order(order)
            order_elements = {}
            order_scroller:set_elements(order_elements)
        end
    end
    return clicked_element
end

function OrderPage:update(gpu)
    Page.update(self, gpu)
    local search_preview = nil
    local quantity_selector = nil
    for _, group in ipairs(self.element_groups) do
        for _, element in ipairs(group.elements) do
            if element:get_name() == "search" then
                if element:get_preview_entry() ~= nil then
                    search_preview = element:get_preview_entry()
                end
            end
            if element:get_name() == "quantity_selector" then
                quantity_selector = element
            end
        end
    end
    if search_preview ~= nil and quantity_selector ~= nil then
        if search_preview:get_item().identifier ~= "placeholder" then
            local itemCount = 0
            for _, link in ipairs(search_preview:get_item().data_links) do
                local peripheralName, line = link:match("(.+):(%d+)")
                line = tonumber(line)
                itemCount = itemCount + tonumber(peripheral.call(peripheralName, "getLine", line))
            end
            quantity_selector:set_max_quantity(itemCount)
        end
    end
end

return OrderPage