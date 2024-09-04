local Element = require("page.element.element")
local ItemEntryElement = require("page.element.item_entry_element")

local SearchElement = {}
SearchElement.__index = SearchElement
setmetatable(SearchElement, {__index = Element})

local registry = ParseItemData()

function SearchElement:new(parent_group, x, y, bg_color, text_color, default_text)
    local o = Element:new("search", parent_group, x, y, 256, 16, bg_color, text_color, nil, nil)
    setmetatable(o, self)
    o.default_text = default_text
    o.draw_text = nil
    o.preview_entry = ItemEntryElement:create_placeholder(parent_group, x, y + 16 + 3, bg_color, text_color)
    return o
end

function SearchElement:get_text()
    return self.draw_text
end

function SearchElement:set_text(text)
    self.draw_text = text
end

function SearchElement:get_preview_entry()
    return self.preview_entry
end

function SearchElement:update_items()
    registry = ParseItemData()
end

function SearchElement:draw(gpu)
    if self.is_visible then
        Element.draw(self, gpu)
        if self.draw_text ~= nil and self.draw_text:len() * 8 < self.width then
            gpu.drawTextSmart(self.x, self.y, self.draw_text, self.text_color, self.background_color, true, 1, 1)
        else
            self.preview_entry = ItemEntryElement:create_placeholder(self.parent_group, self.x, self.y + 16 + 3, self.background_color, self.text_color)
            gpu.drawTextSmart(self.x, self.y, self.default_text, self.text_color, self.background_color, true, 1, 1)
        end
        for _, entry in ipairs(registry) do
            if entry.identifier == self.draw_text then
                self.preview_entry = ItemEntryElement:new(self.parent_group, self.x, self.y + 16 + 3, self.background_color, self.text_color, entry)
                break
            else
                self.preview_entry = ItemEntryElement:create_placeholder(self.parent_group, self.x, self.y + 16 + 3, self.background_color, self.text_color)
            end
        end
        self.preview_entry:draw(gpu)
        gpu.sync()
    end
end

return SearchElement