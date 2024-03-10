local ElementGroup = {}
ElementGroup.__index = ElementGroup
ElementGroup.elements = {}
ElementGroup.name = nil
ElementGroup.is_visible = true

function ElementGroup:new(elements, name)
    local o = {
        elements = elements,
        name = name
    }
    setmetatable(o, self)
    return o
end

-- should be avoided when element_group is invisible
function ElementGroup:translate_elements(x, y)
    for _, element in ipairs(self.elements) do
        element.x = element.x + x
        element.y = element.y + y
        print(string.format("Translated element %s to %d, %d", element.name, element.x, element.y))
    end
end

function ElementGroup:handle_click(x, y, sneak)
    if not self.is_visible then
        return false
    end
    local clicked = {}
    for _, element in ipairs(self.elements) do
        if element:check_click(x, y, sneak) then
            clicked[#clicked + 1] = element
        end
    end
    if not clicked[1] then
        return false
    end
    return clicked[#clicked]:on_click(x, y, sneak)
end

function ElementGroup:update(gpu)
    if not self.is_visible then
        return
    end
    for _, element in ipairs(self.elements) do
        element:update(gpu)
    end
end

function ElementGroup:set_visibility(is_visible)
    self.is_visible = is_visible
end

function ElementGroup:move_element(fromIndex, toIndex)
    local element = table.remove(self.elements, fromIndex)
    table.insert(self.elements, toIndex, element)
end

return ElementGroup