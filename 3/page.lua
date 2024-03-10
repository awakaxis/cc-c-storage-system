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
    for _, element_group in ipairs(self.element_groups) do
        if element_group:handle_click(x, y, sneak) then
            return true
        end
    end
    return false
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