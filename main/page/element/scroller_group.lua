local ElementGroup = require("page.element.element_group")

local ScrollerGroup = {}
ScrollerGroup.__index = ScrollerGroup
setmetatable(ScrollerGroup, {__index = ElementGroup})

function ScrollerGroup:new(elements)
    local o = ElementGroup:new(elements, "scroller")
    setmetatable(o, self)
    return o
end

return ScrollerGroup