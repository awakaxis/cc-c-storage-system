local ClickableElement = require("page.element.clickable_element")

local TextFieldElement = {}
TextFieldElement.__index = TextFieldElement
setmetatable(TextFieldElement, {__index = ClickableElement})
TextFieldElement.type = "text_field"
TextFieldElement.cursor = 0
TextFieldElement.text = ""
TextFieldElement.Text_color = 0xFFFFFF
TextFieldElement.background_color = 0x565656
TextFieldElement.hint_text = "Text Field"
TextFieldElement.max_length = 0
TextFieldElement.text_pattern = ".*"

function TextFieldElement:new(x, y, width, height, text_color, background_color, hint_text)
    local o = ClickableElement:new(x, y, width, height, nil)
    setmetatable(o, self)
    o.hint_text = hint_text or self.hint_text
    o.text_color = text_color or self.text_color
    o.background_color = background_color or self.background_color
    return o
end

function TextFieldElement:get_text()
    return self.text
end

function TextFieldElement:set_text(text)
    self.text = text
end

function TextFieldElement:set_hint(text)
    self.hint_text = text
end

function TextFieldElement:set_pattern(pattern)
    self.text_pattern = pattern
end

function TextFieldElement:set_max_length(length)
    self.max_length = length
end

function TextFieldElement:draw(gpu)
    if self.is_visible then
        if self.text:len() == 0 then
            gpu.drawTextSmart(self.x, self.y, self.hint_text, self.text_color, self.background_color, true, 1, 1)
        else
            gpu.drawTextSmart(self.x, self.y, self.text, self.text_color, self.background_color, true, 1, 1)
        end
        if self.is_focused then
            local cursor_x = self.cursor * 8
            -- gpu.drawTextSmart(cursor_x, self.y, "_", self.text_color, self.background_color, true, 1, 1)
            gpu.filledRectangle(cursor_x, self.y, 1, 8, 0xFF0000) -- debug color
        end
    end
end