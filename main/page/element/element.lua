require("image_resampling")
local ElementGroup = require("page.element.element_group")
local Element = {}
Element.__index = Element
Element.type = "element"
Element.is_visible = true
Element.is_active = true
Element.x = 1
Element.y = 1
Element.width = 16
Element.height = 8

function Element:new(x, y, width, height)
    return setmetatable({
        x = x,
        y = y,
        width = width,
        height = height
    }, self)
end

function Element:set_visibility(is_visible)
    self.is_visible = is_visible
end

function Element:set_active(is_active)
    self.is_active = is_active
end

function Element:get_type()
    return self.type
end

return Element