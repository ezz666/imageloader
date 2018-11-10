---------------------------------------------------------------------------
--- Loading gears.surfaces with propper image caching
--
-- @author Sergey Khilkov
-- @copyright 2018 Sergey Khilkov
-- @classmod imageloader
---------------------------------------------------------------------------

local setmetatable = setmetatable
local type = type
local capi = { awesome = awesome }
local surface = require("gears.surface")
local Gio = require("lgi").Gio
local cairo = require("lgi").cairo
local gdebug = require("gears.debug")
-- local naughty = require("naughty") -- debug info

local imageloader = {}
local surface_cache = setmetatable({}, { __mode = 'v' })
local surface_id_cache = setmetatable({}, { __mode = 'v' })

-- function count(tab)
--     local num = 0
--     for _, e in pairs(tab)do
--         num =num + 1
--     end
--     return num
-- end
local function get_default(arg)
    if type(arg) == 'nil' then
        return cairo.ImageSurface(cairo.Format.ARGB32, 0, 0)
    end
    return arg
end

function imageloader.load_image(_surface, default)
    if type(_surface) == "string" then
        gfile = Gio.File.new_for_path(_surface) -- basic normalization
        _surface = gfile:get_path() -- using glib file
        unique_surface_id = surface_id_cache[_surface]
        if not unique_surface_id then
            ginfo = gfile:query_info("id::file", 0)
            if ginfo then
                unique_surface_id = ginfo:get_attribute_as_string("id::file")
                surface_id_cache[_surface] = unique_surface_id 
            else
                return surface.load_uncached_silently(_surface, default) -- no file
            end
        end
        local cache = surface_cache[unique_surface_id]

        if cache then
            return cache
        end
        local result, err = surface.load_uncached_silently(_surface, default)
        if not err then
            -- Cache the file
            surface_cache[unique_surface_id] = result
            --naughty.notify({title="Cache icon", text ="#surface_cache = " .. tostring(count(surface_cache)).. ", #surface_id_cache = " .. tostring(count(surface_id_cache))})
        end
        return result, err
    end
    return surface.load_uncached_silently(_surface, default)
end

local function do_load_and_handle_errors(_surface, func)
    if type(_surface) == 'nil' then
        return get_default()
    end
    local result, err = func(_surface, false)
    if result then
        return result
    end
    gdebug.print_error(debug.traceback(
        "Failed to load '" .. tostring(_surface) .. "': " .. tostring(err)))
    return get_default()
end

function imageloader.load(_surface)
    return do_load_and_handle_errors(_surface, imageloader.load_image)
end
return imageloader
