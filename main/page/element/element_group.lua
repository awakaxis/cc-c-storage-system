local ElementGroup = {}
ElementGroup.__index = ElementGroup
ElementGroup.elements = {}

function ElementGroup:new(elements)
    local o = {
        elements = elements
    }
    setmetatable(o, self)
    return o
end

function ElementGroup:translate_elements(dx, dy)
    for _, element in ipairs(self.elements) do
        element.x = element.x + dx
        element.y = element.y + dy
        print(string.format("Translated element %s to %d, %d", element.name, element.x, element.y))
    end
end

-- function ElementGroup:handle_click(x, y, sneak)
--     if not self.is_visible then
--         return
--     end
--     local clicked = {}
--     for _, element in ipairs(self.elements) do
--         if element:check_click(x, y, sneak) then
--             clicked[#clicked + 1] = element
--         end
--     end
--     if not clicked[1] then
--         return
--     end
--     return clicked[#clicked]:on_click(x, y, sneak)
-- end

-- -- returns nil if no element was clicked, otherwise returns the clicked element
-- function ElementGroup:check_click(x, y, sneak)
--     if not self.is_visible then
--         print('invisible group')
--         return nil
--     end
--     local clicked = {}
--     for _, element in ipairs(self.elements) do
--         local value = element:check_click(x, y, sneak)
--         if value ~= nil then
--             clicked[#clicked+1] = value
--         end
--     end
--     if not clicked[1] then
--         return nil
--     end
--     return clicked[#clicked]
-- end

-- function ElementGroup:draw(gpu)
--     if not self.is_visible then
--         return
--     end
--     for _, element in ipairs(self.elements) do
--         element:draw(gpu)
--     end
-- end

-- function ElementGroup:set_visibility(is_visible)
--     self.is_visible = is_visible
-- end

-- function ElementGroup:move_element(fromIndex, toIndex)
--     local element = table.remove(self.elements, fromIndex)
--     table.insert(self.elements, toIndex, element)
-- end

--- @return table
function ElementGroup:set_elements(elements)
    self.elements = elements
    return self
end

return ElementGroup