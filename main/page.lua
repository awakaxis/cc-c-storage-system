local Page = {}
Page.__index = Page
Page.element_groups = {}
Page.name = nil

function Page:new(name, element_groups)
    local o = {
        name = name,
        element_groups = element_groups
    }
    setmetatable(o, self)
    return o
end

function Page:handle_click(x, y, sneak)
    local clicked = {}
    for _, element_group in ipairs(self.element_groups) do
        if element_group:check_click(x, y, sneak) ~= nil then
            clicked[#clicked + 1] = element_group
        end
    end
    if not clicked[1] then
        print("No element clicked")
        return nil
    end
    clicked[#clicked]:handle_click(x, y, sneak)
    return clicked[#clicked]:check_click(x, y, sneak)
end

function Page:update(gpu)
    for _, element_group in ipairs(self.element_groups) do
        element_group:update(gpu)
    end
end

function Page:get_name()
    return self.name
end

return Page