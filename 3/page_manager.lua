local BootPage = require("boot_page")

local PageManager = {}
PageManager.__index = PageManager
PageManager.boot_page = BootPage:new()
PageManager.pages = PageManager.boot_page
PageManager.current_page = nil
PageManager.gpu = nil

function PageManager:set_pages(pages)
    self.pages = table.insert(pages, self.boot_page)
end

function PageManager:add_page(page)
    table.insert(self.pages, page)
end

function PageManager:set_current_page(page_name)
    for _, page in ipairs(self.pages) do
        if page:get_name() == page_name then
            self.current_page = page
            return
        end
    end
    self.current_page = self.pages[1]
end

function PageManager:set_gpu(gpu)
    self.gpu = gpu
end

function PageManager:get_gpu()
    return self.gpu
end

function PageManager:handle_click(x, y, sneak)
    return self.current_page:handle_click(x, y, sneak)
end

function PageManager:update()
    self.gpu.fill(0xFFFFFF)
    self.gpu.sync()
    if self.current_page == nil then
        io.stderr:write("Error in PageManager: current_page is nil\n")
        io.stderr:write("Attempting to set current_page to boot_page\n")
        self.current_page = self.boot_page
        return
    end
    if self.gpu == nil then
        io.stderr:write("Error in PageManager: gpu is nil\n")
        return
    end
    self.current_page:update(self.gpu)
end

return PageManager