local ClickableElement = require("page.element.clickable_element")

local DebugElement = {}
DebugElement.__index = DebugElement
setmetatable(DebugElement, {__index = ClickableElement})
DebugElement.type = "debug_element"

function DebugElement:new(x, y, width, height)
    local o = ClickableElement:new(x, y, width, height)
    setmetatable(o, self)
    return o
end

function DebugElement:on_click(x, y, sneak)
    ClickableElement.on_click(self, x, y, sneak)
    -- check for clicks on the leftmost 5 pixels of the element
    if self.x <= x and x < self.x + 5 then
        print("Left side clicked")
        self.x = self.x - 1
    end
    -- check for clicks on the rightmost 5 pixels of the element
    if self.x + self.width - 5 <= x and x < self.x + self.width then
        print("Right side clicked")
        self.x = self.x + 1
    end
    -- check for clicks on the topmost 5 pixels of the element
    if self.y <= y and y < self.y + 5 then
        print("Top side clicked")
        self.y = self.y - 1
    end
    -- check for clicks on the bottommost 5 pixels of the element
    if self.y + self.height - 5 <= y and y < self.y + self.height then
        print("Bottom side clicked")
        self.y = self.y + 1
    end
end

return DebugElement