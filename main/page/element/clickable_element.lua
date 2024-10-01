local Element = require("page.element.element")

local ClickableElement = {}
ClickableElement.__index = ClickableElement
setmetatable(ClickableElement, {__index = Element})
ClickableElement.type = "clickable_element"
ClickableElement.callback = function ()
end

function ClickableElement:new(x, y, width, height, callback)
    local o = Element:new(x, y, width, height)
    setmetatable(o, self)
    o.callback = callback or self.callback
    return o
end

--- @return boolean
function ClickableElement:check_click(x, y, sneak)
    return self.is_visible and self.is_active and x >= self.x and x < self.x + self.width and y >= self.y and y < self.y + self.height
end

function ClickableElement:on_click(x, y, sneak)
    if self.callback then
        self:callback()
        io.stdout:write("ClickableElement clicked with x: " .. x .. ", y: " .. y .. ", sneak: " .. tostring(sneak) .. "\n")
    end
end

function ClickableElement.is_valid_click(i)
    return i == 1
end

--- @return boolean
function ClickableElement:mouse_click(x, y, button)
    if self.is_visible and self.is_active then
        if self.is_valid_click(button) then
            if self:check_click(x, y, button == 1) then
                self:on_click(x, y, button == 1)
                return true
            end
        end
        return false
    else
        return false
    end
end
