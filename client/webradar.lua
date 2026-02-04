package.preload['polys.engine'] = (function (...)
local engine = _G.engine or {}

function engine.log(message, r, g, b, a)

    if r == 255 and g == 0 and b == 0 then
        log_error(tostring(message))
    else
        log(tostring(message))
    end
end

function engine.register_on_engine_tick(callback)
    table.insert(_G.Polyfill_TickCallbacks, callback)
end


function engine.unregister_on_engine_tick(id)
    if id and _G.Polyfill_TickCallbacks[id] then
        _G.Polyfill_TickCallbacks[id] = nil
    end
end

function engine.register_onunload(callback)
    table.insert(_G.Polyfill_UnloadCallbacks, callback)
end

function engine.register_on_network_callback(callback)
    table.insert(_G.Polyfill_NetCallbacks, callback)
end

function engine.get_username()
    return "User" 
end

_G.engine = engine
return engine
 end)

package.preload['polys.fs'] = (function (...)
local fs = _G.fs or {}
local m = _G.m

function fs.does_file_exist(file_name)
    return does_file_exist(file_name)
end

function fs.read_from_file(file_name)
    local ok, data = read_file(file_name)
    if ok then return data end
    return ""
end

function fs.write_to_file(file_name, data)
    return create_file(file_name, data)
end

function fs.delete_file(file_name)
    return delete_file(file_name)
end

function fs.get_file_size(file_name)
    local ok, data = read_file(file_name)
    if ok then return #data end
    return 0
end

function fs.write_to_file_from_buffer(file_name, buffer_handle)
    local data = ""
    if buffer_handle then
        if buffer_handle._type == "ffi_buffer" and buffer_handle.ptr then
            local ffi = require("ffi")
            data = ffi.string(buffer_handle.ptr, buffer_handle.size)
        elseif buffer_handle._type == "lua_buffer" and buffer_handle.data then
            for i=1, buffer_handle.size do
                data = data .. string.char(buffer_handle.data[i])
            end
        end
    end
    return fs.write_to_file(file_name, data)
end

function fs.read_from_file_to_buffer(file_name, buffer_handle)
    local data = fs.read_from_file(file_name)
    if not data or not buffer_handle then return false end

    if buffer_handle._type == "ffi_buffer" then
        local ffi = require("ffi")
        ffi.copy(buffer_handle.ptr, data, math.min(#data, buffer_handle.size))
    elseif buffer_handle._type == "lua_buffer" then
        for i=1, math.min(#data, buffer_handle.size) do
            buffer_handle.data[i] = string.byte(data, i)
        end
    end
    return true
end

function fs.compress(str)
    return str
end

function fs.decompress(str)
    return str
end

_G.fs = fs
return fs
 end)

package.preload['polys.gui'] = (function (...)
local gui = _G.gui or {}

local TAB_INDICES = {
    ["aimbot"] = 0,
    ["visuals"] = 1,
    ["lua"] = 4, 
    ["settings"] = 3,
}


local PanelWrapper = {}
PanelWrapper.__index = PanelWrapper

function PanelWrapper.new(panel_obj)
    local self = setmetatable({}, PanelWrapper)
    self.panel = panel_obj
    return self
end

function PanelWrapper:add_checkbox(label)
    local cb = self.panel:add_checkbox(label, false)
    return cb
end

function PanelWrapper:add_slider_int(label, postfix, default, min, max, step)
    local s = self.panel:add_slider_int(label, postfix or "", default, min, max, step or 1)
    return s
end

function PanelWrapper:add_slider_float(label, postfix, value, min, max, step)
    local s = self.panel:add_slider_double(label, postfix or "", value, min, max, step or 1)
    return s
end

function PanelWrapper:add_button(label, callback)
    local btn = self.panel:add_button(label, callback)
    return btn
end

function PanelWrapper:add_text(label)

    self.panel:add_button(label, function() end)
end

function PanelWrapper:add_input_text(label, default)
    local inp = self.panel:add_input(label, default)
    return inp
end

function PanelWrapper:add_color_picker(label, r, g, b, a)
    local col = self.panel:add_color(label, {r, g, b, a})
    return col
end

function PanelWrapper:add_keybind(label, key, mode)

    local kb = self.panel:add_keybind(label, key, mode)
    return kb
end

function PanelWrapper:add_single_select(name, options_table, initial_index, is_expandable)
    local ss = self.panel:add_single_select(name, options_table, initial_index or 0, is_expandable or false)
    return ss
end

function PanelWrapper:add_multi_select(label, list)
    local options = {}
    for i, v in ipairs(list) do
        table.insert(options, {v, true}) 
    end
    local ms = self.panel:add_multi_select(label, options, false)
    return ms
end

local TabWrapper = {}
TabWrapper.__index = TabWrapper

function TabWrapper.new(index)
    local self = setmetatable({}, TabWrapper)
    self.index = index
    return self
end

function TabWrapper:create_panel(label, small_panel)

    local subtab = ui.create_subtab(self.index, label)
    local panel = subtab:add_panel(label, small_panel or false)
    return PanelWrapper.new(panel)
end

function TabWrapper:create_subtab(label)
    local subtab = ui.create_subtab(self.index, label)
    return SubTabWrapper.new(subtab)
end

local SubTabWrapper = {}
SubTabWrapper.__index = SubTabWrapper

function SubTabWrapper.new(subtab_obj)
    local self = setmetatable({}, SubTabWrapper)
    self.subtab = subtab_obj
    return self
end

function SubTabWrapper:create_panel(label, small_panel)
    local panel = self.subtab:add_panel(label, small_panel or false)
    return PanelWrapper.new(panel)
end

function gui.get_tab(name)
    local idx = TAB_INDICES[string.lower(name)] or 4
    return TabWrapper.new(idx)
end


_G.gui = gui
_G.SubTabWrapper = SubTabWrapper

return gui
 end)

package.preload['polys.input'] = (function (...)
local input = _G.input or {}

function input.simulate_mouse(dx, dy, flag)
    if flag == 1 then
        mouse_move_relative(dx, dy)
    elseif flag == 2 then

        mouse_left_click()
    elseif flag == 4 then

    else
        mouse_move_relative(dx, dy)
    end
end

function input.simulate_keyboard(key, flag)
    if not flag or flag == 0 then win_key_press(key)
    elseif flag == 1 then win_key_down(key)
    elseif flag == 2 then win_key_up(key) end
end

function input.is_key_pressed(key) return key_fired(key) end
function input.is_key_down(key) return key_down(key) end
function input.is_key_toggled(key) return key_toggle(key) end
function input.get_mouse_position() return get_mouse_pos() end
function input.get_mouse_move_delta() return get_mouse_delta() end
function input.get_scroll_delta() return get_scroll_delta() end
function input.get_clipboard() return copy_from_clipboard() end
function input.set_clipboard(text) copy_to_clipboard(text) end
function input.is_menu_open() return false end

_G.input = input
return input
 end)

package.preload['polys.m'] = (function (...)
local m = _G.m or {}
local has_ffi, ffi = pcall(require, "ffi")

function m.alloc(size)
    if has_ffi then
        local ptr = ffi.new("uint8_t[?]", size)
        return { _type = "ffi_buffer", ptr = ptr, size = size }
    else
        local t = {}
        for i=1, size do t[i] = 0 end
        return { _type = "lua_buffer", data = t, size = size }
    end
end

function m.free(handle)
    if handle then
        handle.ptr = nil
        handle.data = nil
    end
end

function m.get_size(handle)
    return handle and handle.size or 0
end

local function check_bounds(handle, offset, type_size)
    if not handle or offset < 0 or (offset + type_size) > handle.size then
        return false
    end
    return true
end

function m.read_int8(handle, offset)
    if not check_bounds(handle, offset, 1) then return 0 end
    if handle._type == "ffi_buffer" then
        return handle.ptr[offset]
    else
        return handle.data[offset + 1] or 0
    end
end

function m.read_int16(handle, offset)
    if not check_bounds(handle, offset, 2) then return 0 end
    if handle._type == "ffi_buffer" then
        local ptr = ffi.cast("int16_t*", handle.ptr + offset)
        return ptr[0]
    else
        local b1 = handle.data[offset + 1]
        local b2 = handle.data[offset + 2]
        local val = b1 + (b2 * 256)
        if val > 32767 then val = val - 65536 end
        return val
    end
end

function m.read_int32(handle, offset)
    if not check_bounds(handle, offset, 4) then return 0 end
    if handle._type == "ffi_buffer" then
        local ptr = ffi.cast("int32_t*", handle.ptr + offset)
        return ptr[0]
    else
        local b1 = handle.data[offset + 1]
        local b2 = handle.data[offset + 2]
        local b3 = handle.data[offset + 3]
        local b4 = handle.data[offset + 4]
        local val = b1 + (b2 * 256) + (b3 * 65536) + (b4 * 16777216)

        if val > 2147483647 then val = val - 4294967296 end
        return val
    end
end

function m.read_int64(handle, offset)
    if not check_bounds(handle, offset, 8) then return 0 end
    if handle._type == "ffi_buffer" then
        local ptr = ffi.cast("int64_t*", handle.ptr + offset)
        return tonumber(ptr[0]) 
    else
        return m.read_int32(handle, offset)
    end
end

function m.read_float(handle, offset)
    if not check_bounds(handle, offset, 4) then return 0.0 end
    if handle._type == "ffi_buffer" then
        local ptr = ffi.cast("float*", handle.ptr + offset)
        return tonumber(ptr[0])
    else
        return 0.0 
    end
end

function m.read_double(handle, offset)
    if not check_bounds(handle, offset, 8) then return 0.0 end
    if handle._type == "ffi_buffer" then
        local ptr = ffi.cast("double*", handle.ptr + offset)
        return tonumber(ptr[0])
    else
        return 0.0
    end
end

function m.read_string(handle, offset)
    if not handle then return "" end
    local str = ""
    if handle._type == "ffi_buffer" then
        local ptr = handle.ptr + offset
        return ffi.string(ptr)
    else
        for i = offset + 1, handle.size do
            local b = handle.data[i]
            if b == 0 then break end
            str = str .. string.char(b)
        end
    end
    return str
end

function m.write_int8(handle, offset, value)
    if not check_bounds(handle, offset, 1) then return end
    if handle._type == "ffi_buffer" then
        handle.ptr[offset] = value
    else
        handle.data[offset + 1] = value % 256
    end
end

function m.write_int16(handle, offset, value)
    if not check_bounds(handle, offset, 2) then return end
    if handle._type == "ffi_buffer" then
        local ptr = ffi.cast("int16_t*", handle.ptr + offset)
        ptr[0] = value
    else
        handle.data[offset + 1] = value % 256
        handle.data[offset + 2] = math.floor(value / 256) % 256
    end
end

function m.write_int32(handle, offset, value)
    if not check_bounds(handle, offset, 4) then return end
    if handle._type == "ffi_buffer" then
        local ptr = ffi.cast("int32_t*", handle.ptr + offset)
        ptr[0] = value
    else
        handle.data[offset + 1] = value % 256
        handle.data[offset + 2] = math.floor(value / 256) % 256
        handle.data[offset + 3] = math.floor(value / 65536) % 256
        handle.data[offset + 4] = math.floor(value / 16777216) % 256
    end
end

function m.write_float(handle, offset, value)
    if not check_bounds(handle, offset, 4) then return end
    if handle._type == "ffi_buffer" then
        local ptr = ffi.cast("float*", handle.ptr + offset)
        ptr[0] = value
    end
end

function m.write_double(handle, offset, value)
    if not check_bounds(handle, offset, 8) then return end
    if handle._type == "ffi_buffer" then
        local ptr = ffi.cast("double*", handle.ptr + offset)
        ptr[0] = value
    end
end

function m.write_string(handle, offset, str)
    if not handle then return end
    if handle._type == "ffi_buffer" then
        ffi.copy(handle.ptr + offset, str)
    else
        for i = 1, #str do
            if offset + i <= handle.size then
                handle.data[offset + i] = string.byte(str, i)
            end
        end
        if offset + #str + 1 <= handle.size then
            handle.data[offset + #str + 1] = 0 
        end
    end
end

_G.m = m
return m
 end)

package.preload['polys.math'] = (function (...)
local m = math

function m.clamp(x, min, max)
    if x < min then return min end
    if x > max then return max end
    return x
end

function m.lerp(a, b, t)
    return a + (b - a) * t
end

function m.round(x)
    return math.floor(x + 0.5)
end

function m.round_up(x)
    return math.ceil(x)
end

function m.round_down(x)
    return math.floor(x)
end

function m.round_to_nearest(x, step)
    if step == 0 then return x end
    return math.floor(x / step + 0.5) * step
end

function m.sign(x)
    if x > 0 then return 1 end
    if x < 0 then return -1 end
    return 0
end

function m.map(x, in_min, in_max, out_min, out_max)
    return (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min
end

function m.saturate(x)
    return m.clamp(x, 0, 1)
end

function m.is_nan(x)
    return x ~= x
end

function m.is_inf(x)
    return x == math.huge or x == -math.huge
end

function m.smoothstep(edge0, edge1, x)
    x = m.clamp((x - edge0) / (edge1 - edge0), 0.0, 1.0)
    return x * x * (3 - 2 * x)
end

function m.inverse_lerp(a, b, x)
    return (x - a) / (b - a)
end

function m.fract(x)
    return x - math.floor(x)
end

function m.wrap(x, min, max)
    return min + (x - min) % (max - min)
end



return m
 end)

package.preload['polys.net'] = (function (...)
local net = _G.net or {}

function net.send_request(url, headers, post_fields)


    if post_fields and post_fields ~= "" then

        local ctype = "application/x-www-form-urlencoded"
        if headers and type(headers) == "table" then
            for k, v in pairs(headers) do
                if string.lower(k) == "content-type" then ctype = v break end
            end
        end

        local ok, status, body = net_http_post(url, ctype, post_fields, 5000)
        return body or "" 
    else
        local ok, status, body = net_http_get(url, 5000)
        return body or ""
    end
end

function net.resolve(hostname)
    return "127.0.0.1" 
end

function net.create_socket(ip, port)
    return {
        send = function() return 0 end,
        receive = function() return nil, "not supported" end,
        close = function() end
    }
end

function net.base64_encode(str)
    return util.base64_encode(str)
end

function net.base64_decode(str)
    return util.base64_decode(str)
end

_G.net = net
return net
 end)

package.preload['polys.process'] = (function (...)
local proc = _G.proc or {}

local _Internal_CurrentProcess = nil
local _Internal_AttachedName = nil

function proc.attach_by_pid(process_id, has_corrupt_cr3)
    if _Internal_CurrentProcess then
        deref_process(_Internal_CurrentProcess)
    end
    _Internal_CurrentProcess = ref_process(process_id)
    _Internal_AttachedName = nil
    return _Internal_CurrentProcess ~= nil
end

function proc.attach_by_name(process_name, has_corrupt_cr3)
    if _Internal_CurrentProcess then
        deref_process(_Internal_CurrentProcess)
    end
    _Internal_CurrentProcess = ref_process(process_name)
    _Internal_AttachedName = process_name
    return _Internal_CurrentProcess ~= nil
end

function proc.attach_by_window(window_class, window_name, has_corrupt_cr3)
    local hwnd = find_window(window_name, window_class)
    if hwnd then
        local tid, pid = get_window_thread_process_id(hwnd)
        if pid then
            return proc.attach_by_pid(pid, has_corrupt_cr3)
        end
    end
    return false
end

function proc.is_attached()
    return _Internal_CurrentProcess and _Internal_CurrentProcess:alive()
end

function proc.did_exit()
    return not (_Internal_CurrentProcess and _Internal_CurrentProcess:alive())
end

function proc.pid()
    if proc.is_attached() then
        return _Internal_CurrentProcess:pid()
    end
    return 0
end

function proc.peb()
    if proc.is_attached() then
        return _Internal_CurrentProcess:peb()
    end
    return 0
end

function proc.base_address()
    if proc.is_attached() then
        return _Internal_CurrentProcess:base_address()
    end
    return 0
end

function proc.handle()
    if proc.is_attached() then
        return _Internal_CurrentProcess
    end
    return nil
end

function proc.get_base_module()
    if proc.is_attached() then
        if _Internal_AttachedName then
            local address, size = _Internal_CurrentProcess:get_module(_Internal_AttachedName)
            
            return address, size
        end
        return _Internal_CurrentProcess:base_address(), 0 
    end
    return 0, 0
end

function proc.find_module(module_name)
    if proc.is_attached() then
        return _Internal_CurrentProcess:get_module(module_name)
    end
    return 0, 0
end

function proc.find_signature(base_address, size, signature)
    if proc.is_attached() then
        return _Internal_CurrentProcess:find_code_pattern(base_address, size, signature)
    end
    return 0
end

function proc.read_double(address)
    if proc.is_attached() then return _Internal_CurrentProcess:rf64(address) end; return 0
end
function proc.read_float(address)
    if proc.is_attached() then return _Internal_CurrentProcess:rf32(address) end; return 0
end
function proc.read_int64(address)
    if proc.is_attached() then return _Internal_CurrentProcess:r64(address) end; return 0
end
function proc.read_int32(address)
    if proc.is_attached() then return _Internal_CurrentProcess:r32(address) end; return 0
end
function proc.read_int16(address)
    if proc.is_attached() then return _Internal_CurrentProcess:r16(address) end; return 0
end
function proc.read_int8(address)
    if proc.is_attached() then return _Internal_CurrentProcess:r8(address) end; return 0
end

function proc.read_string(address, size)
    if proc.is_attached() then return _Internal_CurrentProcess:rs(address, size) end; return ""
end
function proc.read_wide_string(address, size)
    if proc.is_attached() then return _Internal_CurrentProcess:rws(address, size) end; return ""
end

function proc.read_to_memory_buffer(address, buffer, size)

    if proc.is_attached() then
         local data = _Internal_CurrentProcess:rs(address, size) 
         if type(buffer) == "table" then
             buffer.data = data
         end
    end
end

function proc.dump(file_name)

    -----Damn this func is missing
end

function proc.write_double(address, value)
    if proc.is_attached() then return _Internal_CurrentProcess:wf64(address, value) end; return false
end
function proc.write_float(address, value)
    if proc.is_attached() then return _Internal_CurrentProcess:wf32(address, value) end; return false
end
function proc.write_int64(address, value)
    if proc.is_attached() then return _Internal_CurrentProcess:w64(address, value) end; return false
end
function proc.write_int32(address, value)
    if proc.is_attached() then return _Internal_CurrentProcess:w32(address, value) end; return false
end
function proc.write_int16(address, value)
    if proc.is_attached() then return _Internal_CurrentProcess:w16(address, value) end; return false
end
function proc.write_int8(address, value)
    if proc.is_attached() then return _Internal_CurrentProcess:w8(address, value) end; return false
end
function proc.write_string(address, text)
    if proc.is_attached() then return _Internal_CurrentProcess:ws(address, text) end; return false
end
function proc.write_wide_string(address, text)
    if proc.is_attached() then return _Internal_CurrentProcess:wws(address, text) end; return false
end

function proc.write_from_memory_buffer(address, buffer, size)
    if proc.is_attached() and type(buffer) == "table" and buffer.data then
        return _Internal_CurrentProcess:ws(address, buffer.data)
    end
    return false
end


function proc.read_struct(base_address, descriptor)
    if proc.is_attached() then
        return _Internal_CurrentProcess:read_struct(base_address, descriptor)
    end
    return nil
end

-- table proc:read_struct_array(
--     uint64 base_address,
--     integer count,
--     integer struct_size,
--     table descriptor
-- )
function proc.read_struct_array(base_address, count, struct_size, descriptor)
    if proc.is_attached() then
        return _Internal_CurrentProcess:read_struct_array(base_address, count, struct_size, descriptor)
    end
    return false
end


_G.proc = proc
return proc

 end)

package.preload['polys.render'] = (function (...)
local render = _G.render or {}
local net = _G.net

local function unpack_color(r, g, b, a)
    return r, g, b, a or 255
end

function render.draw_line(x1, y1, x2, y2, r, g, b, a, thickness)
    draw_line(x1, y1, x2, y2, r, g, b, a, thickness)
end

function render.draw_rectangle(x, y, width, height, r, g, b, a, thickness, filled, rounding)
    rounding = rounding or 0
    a = a or 255
    r = math.floor(r or 255)
    g = math.floor(g or 255)
    b = math.floor(b or 255)
    a = math.floor(a)
    if filled then
        draw_rect_filled(x, y, width, height, r, g, b, a, rounding, 15)
    else
        draw_rect(x, y, width, height, r, g, b, a, thickness, rounding, 15)
    end
end

function render.draw_circle(x, y, radius, r, g, b, a, thickness, filled)
    draw_circle(x, y, radius, r, g, b, a, thickness, filled)
end

function render.draw_triangle(x1, y1, x2, y2, x3, y3, r, g, b, a, thickness, filled)
    local points = {x1, y1, x2, y2, x3, y3}
    draw_polygon(points, 3, r, g, b, a, thickness, filled)
end

function render.draw_polygon(points_table, r, g, b, a, thickness, filled)

    local flat_points = {}
    for i, pt in ipairs(points_table) do
        if type(pt) == "table" then
            table.insert(flat_points, pt[1])
            table.insert(flat_points, pt[2])
        else
            table.insert(flat_points, pt)
        end
    end

    draw_polygon(flat_points, #flat_points / 2, r, g, b, a, thickness, filled)
end

function render.draw_ellipse(x, y, rx, ry, r, g, b, a, thickness, filled)
    local points = {}
    local segments = 32
    for i = 0, segments - 1 do
        local theta = (i / segments) * math.pi * 2
        table.insert(points, x + rx * math.cos(theta))
        table.insert(points, y + ry * math.sin(theta))
    end
    draw_polygon(points, segments, r, g, b, a, thickness, filled)
end

function render.draw_arc(x, y, rx, ry, start_angle, sweep_angle, r, g, b, a, thickness, filled)
    local points = {}
    local segments = 16
    local start_rad = math.rad(start_angle)
    local sweep_rad = math.rad(sweep_angle)

    if filled then table.insert(points, x); table.insert(points, y) end

    for i = 0, segments do
        local theta = start_rad + (i / segments) * sweep_rad
        table.insert(points, x + rx * math.cos(theta))
        table.insert(points, y + ry * math.sin(theta))
    end

    draw_polygon(points, #points/2, r, g, b, a, thickness, filled)
end

function render.create_font(path, size, anti_aliased, load_color)
    return create_font(path, size, anti_aliased or false, load_color or false)
end

function render.create_font_from_buffer(font_label, size, buffer_handle, anti_aliased, load_color)
    local data = buffer_handle

    if type(buffer_handle) == "table" then
        if buffer_handle._type == "ffi_buffer" and buffer_handle.ptr then
            local ffi = require("ffi")
            data = ffi.string(buffer_handle.ptr, buffer_handle.size)
        elseif buffer_handle._type == "lua_buffer" and buffer_handle.data then
            local t = {}
            for i=1, buffer_handle.size do
                t[i] = string.char(buffer_handle.data[i])
            end
            data = table.concat(t)
        end
    end

    return create_font_mem(font_label, size, data, anti_aliased or false, load_color or false)
end

function render.draw_text(font, text, x, y, r, g, b, a, outline_thickness, o_r, o_g, o_b, o_a)
    r = math.floor(r or 255)
    g = math.floor(g or 255)
    b = math.floor(b or 255)
    a = math.floor(a or 255)
    
    local er = math.floor(o_r or 0)
    local eg = math.floor(o_g or 0)
    local eb = math.floor(o_b or 0)
    local ea = math.floor(o_a or 0)

    local effect = 0 
    local effect_amount = 0

    if outline_thickness and outline_thickness > 0 then
        effect = 1 
        effect_amount = outline_thickness
    end

    draw_text(text, x, y, r, g, b, a, font, effect, er, eg, eb, ea, effect_amount, true)
end

function render.measure_text(font_handle, text)
    local w, h = get_text_size(font_handle, text, 10000, 10000)
    return w, h
end

function render.get_viewport_size()
    return get_view()
end

function render.get_fps()
    return get_fps()
end

function render.clip_start(x, y, width, height)
    clip_push(x, y, width, height)
end

function render.clip_end()
    clip_pop()
end

function render.create_bitmap_from_url(url)
    local ok, status, body = net_http_get(url)
    if ok and status == 200 then
        return create_bitmap(body)
    end
    return nil
end

function render.create_bitmap_from_buffer(buffer_handle)
    local data = buffer_handle
    if type(buffer_handle) == "table" then
        if buffer_handle._type == "ffi_buffer" and buffer_handle.ptr then
            local ffi = require("ffi")
            data = ffi.string(buffer_handle.ptr, buffer_handle.size)
        elseif buffer_handle._type == "lua_buffer" and buffer_handle.data then
            local t = {}
            for i=1, buffer_handle.size do
                t[i] = string.char(buffer_handle.data[i])
            end
            data = table.concat(t)
        end
    end
    return create_bitmap(data)
end

function render.create_bitmap_from_file(file_name)
    local ok, data = read_file(file_name)
    if ok then
        return create_bitmap(data)
    end
    return nil
end

function render.draw_four_corner_gradient(x, y, width, height, r1, g1, b1, r2, g2, b2, r3, g3, b3, r4, g4, b4)

    draw_four_corner_gradient(x, y, width, height,
        r1, g1, b1, 255,
        r2, g2, b2, 255,
        r3, g3, b3, 255,
        r4, g4, b4, 255,
        0)
end

function render.draw_gradient_line(x1, y1, x2, y2, color_table, thickness)

    local r,g,b,a = 255, 255, 255, 255
    if type(color_table) == "table" and #color_table >= 4 then
        r,g,b,a = color_table[1], color_table[2], color_table[3], color_table[4]
    end
    draw_line(x1, y1, x2, y2, r, g, b, a, thickness)
end

function render.draw_gradient_rectangle(x, y, width, height, color_table, rounding)
    local r1, g1, b1, a1 = 255, 255, 255, 255
    local r2, g2, b2, a2 = 255, 255, 255, 255

    if type(color_table) == "table" then
        if type(color_table[1]) == "table" then
            local c1 = color_table[1] or {255,255,255,255}
            local c2 = color_table[2] or c1
            
            r1, g1, b1, a1 = c1[1], c1[2], c1[3], c1[4]
            r2, g2, b2, a2 = c2[1], c2[2], c2[3], c2[4]
        else
            if #color_table >= 4 then 
                r1,g1,b1,a1 = color_table[1], color_table[2], color_table[3], color_table[4] 
            end
            if #color_table >= 8 then
                r2,g2,b2,a2 = color_table[5], color_table[6], color_table[7], color_table[8]
            else
                r2,g2,b2,a2 = r1,g1,b1,a1 
            end
        end
    end

    draw_four_corner_gradient(
        x, y, width, height,
        math.floor(r1 or 255), math.floor(g1 or 255), math.floor(b1 or 255), math.floor(a1 or 255),
        math.floor(r1 or 255), math.floor(g1 or 255), math.floor(b1 or 255), math.floor(a1 or 255), -- Top Right matches Top Left (Horizontal/Vertical hybrid)
        math.floor(r2 or 255), math.floor(g2 or 255), math.floor(b2 or 255), math.floor(a2 or 255),
        math.floor(r2 or 255), math.floor(g2 or 255), math.floor(b2 or 255), math.floor(a2 or 255), -- Bottom Right matches Bottom Left
        math.floor(rounding or 0)
    )
end

_G.render = render
return render
 end)

package.preload['polys.str'] = (function (...)
local str = _G.str or {}

function str.trim(s)
    return s:match("^%s*(.-)%s*$")
end

function str.ltrim(s)
    return s:match("^%s*(.*)")
end

function str.rtrim(s)
    return s:match("(.-)%s*$")
end

function str.pad_left(s, len, char)
    if #s >= len then return s end
    return string.rep(char or " ", len - #s) .. s
end

function str.pad_right(s, len, char)
    if #s >= len then return s end
    return s .. string.rep(char or " ", len - #s)
end

function str.strip_prefix(s, prefix)
    if str.startswith(s, prefix) then
        return s:sub(#prefix + 1)
    end
    return s
end

function str.strip_suffix(s, suffix)
    if str.endswith(s, suffix) then
        return s:sub(1, -#suffix - 1)
    end
    return s
end

function str.startswith(s, prefix)
    return s:sub(1, #prefix) == prefix
end

function str.endswith(s, suffix)
    return suffix == "" or s:sub(-#suffix) == suffix
end

function str.contains(s, substring)
    return s:find(substring, 1, true) ~= nil
end

function str.indexof(s, substr, start)
    return s:find(substr, start or 1, true)
end

function str.last_indexof(s, substr)
    local i = 0
    local found = nil
    while true do
        i = s:find(substr, i + 1, true)
        if not i then break end
        found = i
    end
    return found
end

function str.count(s, substr)
    local c = 0
    local i = 0
    while true do
        i = s:find(substr, i + 1, true)
        if not i then break end
        c = c + 1
    end
    return c
end

function str.empty(s)
    return s == nil or s == ""
end

function str.equals(a, b)
    return a == b
end

function str.replace(s, from, to)

    local pattern = from:gsub("[%^%$%(%)%%%.%[%]%*%+%-%?]", "%%%1")
    local result, _ = s:gsub(pattern, to:gsub("%%", "%%%%")) 
    return result
end

function str.repeat_str(s, count)
    return string.rep(s, count)
end

function str.reverse(s)
    return string.reverse(s)
end

function str.insert(s, pos, substr)
    return s:sub(1, pos-1) .. substr .. s:sub(pos)
end

function str.remove(s, start, END)
    return s:sub(1, start-1) .. s:sub(END+1)
end

function str.substitute(s, tbl)
    return (s:gsub("{(.-)}", function(key)
        return tbl[key] or "{"..key.."}"
    end))
end

function str.upper(s)
    return string.upper(s)
end

function str.lower(s)
    return string.lower(s)
end

function str.split(s, delimiter)
    local result = {}
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match)
    end
    return result
end

function str.slice(s, start, END)
    return string.sub(s, start, END)
end

function str.utf8len(s)
    return utf8.len(s)
end

function str.utf8sub(s, start, END)

    return string.sub(s, start, END)
end

_G.str = str
return str
 end)

package.preload['polys.time'] = (function (...)
local time = _G.time or {}

time.SECONDS_PER_MINUTE = 60
time.SECONDS_PER_HOUR = 3600
time.SECONDS_PER_DAY = 86400
time.DAYS_PER_WEEK = 7
time.WEEKDAY_NAMES = {"Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"}
time.MONTH_NAMES = {"January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"}
time.MONTH_DAYS = {31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31}
time.MONTH_DAYS_LEAP = {31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31}
time.MONTH_NAME_TO_INDEX = {}
for i, v in ipairs(time.MONTH_NAMES) do time.MONTH_NAME_TO_INDEX[v] = i end

function time.unix()
    return os.time()
end

function time.unix_ms()

    return os.time() * 1000
end

function time.now_utc()
    return os.date("!%Y-%m-%d %H:%M:%S")
end

function time.now_local()
    return os.date("%Y-%m-%d %H:%M:%S")
end

function time.format(timestamp)
    return os.date("%Y-%m-%d %H:%M:%S", timestamp)
end

function time.format_custom(timestamp, format)

    return os.date("!" .. format, timestamp)
end

function time.delta(t1, t2)
    return math.abs(t1 - t2)
end

function time.compare(t1, t2)
    if t1 < t2 then return -1 end
    if t1 > t2 then return 1 end
    return 0
end

function time.same_day(t1, t2)
    local d1 = os.date("!*t", t1)
    local d2 = os.date("!*t", t2)
    return d1.year == d2.year and d1.month == d2.month and d1.day == d2.day
end

function time.diff_table(t1, t2)
    local diff = math.abs(t1 - t2)
    local days = math.floor(diff / 86400)
    local remainder = diff % 86400
    local hours = math.floor(remainder / 3600)
    remainder = remainder % 3600
    local minutes = math.floor(remainder / 60)
    local seconds = remainder % 60
    return {days=days, hours=hours, minutes=minutes, seconds=seconds}
end

function time.between(now, start, END)
    return now >= start and now <= END
end

function time.weekday(timestamp)
    local d = os.date("!*t", timestamp)
    return d.wday - 1

end

function time.day_of_year(timestamp)
    local d = os.date("!*t", timestamp)
    return d.yday
end

function time.year_month_day(timestamp)
    local d = os.date("!*t", timestamp)
    return {year=d.year, month=d.month, day=d.day}
end

function time.is_weekend(timestamp)
    local w = time.weekday(timestamp)
    return w == 0 or w == 6
end

function time.is_leap_year(timestamp)
    local y = os.date("!*t", timestamp).year
    return (y % 4 == 0 and y % 100 ~= 0) or (y % 400 == 0)
end

function time.days_in_month(year, month)
    local is_leap = (year % 4 == 0 and year % 100 ~= 0) or (year % 400 == 0)
    if is_leap then return time.MONTH_DAYS_LEAP[month] end
    return time.MONTH_DAYS[month]
end

function time.timestamp_utc(y, m, d, h, min, s)
    return os.time({year=y, month=m, day=d, hour=h, min=min, sec=s}) 

end

function time.add_days(timestamp, days)
    return timestamp + (days * 86400)
end

function time.start_of_day(timestamp)
    local d = os.date("!*t", timestamp)
    d.hour = 0; d.min = 0; d.sec = 0
    return os.time(d)
end

function time.end_of_day(timestamp)
    local d = os.date("!*t", timestamp)
    d.hour = 23; d.min = 59; d.sec = 59
    return os.time(d)
end

function time.to_table(timestamp)
    return os.date("*t", timestamp)
end

function time.from_table(tbl)
    return os.time(tbl)
end

function time.to_utc_table(timestamp)
    return os.date("!*t", timestamp)
end

function time.from_utc_table(tbl)

    return os.time(tbl)
end

function time.is_valid(timestamp)
    return type(timestamp) == "number" and timestamp > 0
end

function time.is_dst(timestamp)
    local d = os.date("*t", timestamp)
    return d.isdst
end

function time.utc_offset()
    local now = os.time()
    local utc = os.time(os.date("!*t", now))
    return os.difftime(now, utc)
end

function time.get_timezone()
    return os.date("%z")
end

function time.seconds_to_hhmmss(seconds)
    local h = math.floor(seconds / 3600)
    local m = math.floor((seconds % 3600) / 60)
    local s = seconds % 60
    return string.format("%02d:%02d:%02d", h, m, s)
end

_G.time = time
return time
 end)

package.preload['polys.vectors'] = (function (...)
local vec2_impl = {}
local vec3_impl = {}
local vec4_impl = {}



local function make_vector_proxy(original_constructor, type_name)
    local proxy = {}

    setmetatable(proxy, {
        __call = function(_, ...)
            return original_constructor(...)
        end
    })

    return proxy
end

_G.vec2 = make_vector_proxy(vector2, "vec2")
_G.vec3 = make_vector_proxy(vector3, "vec3")
_G.vec4 = make_vector_proxy(vector4, "vec4")

function _G.vec2.read_float(address)
   
    local v = vector2()
    local proc = _G.proc and _G._Internal_CurrentProcess 
   
    if _G.proc and _G.proc.is_attached() then

    end

    local x = _G.proc.read_float(address)
    local y = _G.proc.read_float(address + 4)
    return vector2(x, y)
end

function _G.vec2.read_double(address)
    local x = _G.proc.read_double(address)
    local y = _G.proc.read_double(address + 8)
    return vector2(x, y)
end

function _G.vec2.write_float(address, v)
    _G.proc.write_float(address, v.x)
    _G.proc.write_float(address + 4, v.y)
end

function _G.vec2.write_double(address, v)
    _G.proc.write_double(address, v.x)
    _G.proc.write_double(address + 8, v.y)
end


function _G.vec3.read_float(address)
    local x = _G.proc.read_float(address)
    local y = _G.proc.read_float(address + 4)
    local z = _G.proc.read_float(address + 8)
    return vector3(x, y, z)
end

function _G.vec3.read_double(address)
    local x = _G.proc.read_double(address)
    local y = _G.proc.read_double(address + 8)
    local z = _G.proc.read_double(address + 16)
    return vector3(x, y, z)
end

function _G.vec3.write_float(address, v)
    _G.proc.write_float(address, v.x)
    _G.proc.write_float(address + 4, v.y)
    _G.proc.write_float(address + 8, v.z)
end

function _G.vec3.write_double(address, v)
    _G.proc.write_double(address, v.x)
    _G.proc.write_double(address + 8, v.y)
    _G.proc.write_double(address + 16, v.z)
end



local v3_dummy = vector3()
local v3_mt = getmetatable(v3_dummy) or debug.getmetatable(v3_dummy)

if v3_mt then
    v3_mt.to_forward = function(self)

        local pitch = math.rad(self.x)
        local yaw = math.rad(self.y)
        local cp = math.cos(pitch)
        local sp = math.sin(pitch)
        local cy = math.cos(yaw)
        local sy = math.sin(yaw)
        return vector3(cp * cy, cp * sy, -sp)
    end

    v3_mt.to_right = function(self)

        local fwd = self:to_forward()
        local up = vector3(0, 0, 1) 

        return vector3(0, 1, 0) 
    end

    v3_mt.to_up = function(self)
        return vector3(0, 0, 1) 
    end

    v3_mt.to_qangle = function(self)
        return vector3(0, 0, 0)
    end

    v3_mt.normalize_angles = function(self)
        local x = self.x
        local y = self.y
        return vector3(x, y, self.z)
    end

    v3_mt.clamp_angles = function(self)
        return self
    end

 
    _G.vec3.from_qangle = function(pitch, yaw)
        local v = vector3(pitch, yaw, 0)
        return v:to_forward()
    end

    _G.vec3.normalize_angle = function(angle)
        return angle 
    end
else

    log_error("Polyfill: Cannot modify vector metatables. Instance methods like :to_forward() may fail.")
end

function _G.vec4.read_float(address)
    local x = _G.proc.read_float(address)
    local y = _G.proc.read_float(address + 4)
    local z = _G.proc.read_float(address + 8)
    local w = _G.proc.read_float(address + 12)
    return vector4(x, y, z, w)
end

function _G.vec4.read_double(address)
    local x = _G.proc.read_double(address)
    local y = _G.proc.read_double(address + 8)
    local z = _G.proc.read_double(address + 16)
    local w = _G.proc.read_double(address + 24)
    return vector4(x, y, z, w)
end

function _G.vec4.write_float(address, v)
    _G.proc.write_float(address, v.x)
    _G.proc.write_float(address + 4, v.y)
    _G.proc.write_float(address + 8, v.z)
    _G.proc.write_float(address + 12, v.w)
end

function _G.vec4.write_double(address, v)
    _G.proc.write_double(address, v.x)
    _G.proc.write_double(address + 8, v.y)
    _G.proc.write_double(address + 16, v.z)
    _G.proc.write_double(address + 24, v.w)
end
 end)

package.preload['polys.winapi'] = (function (...)
local winapi = _G.winapi or {}

function winapi.get_tickcount64()
    return get_tickcount64()
end

function winapi.play_sound(file_name)
end

function winapi.get_hwnd(class_name, window_name)
    return find_window(window_name, class_name)
end

function winapi.post_message(hwnd, msg, wparam, lparam)
    return post_message(hwnd, msg, wparam, lparam)
end

function winapi.get_foreground_window()
    return 0
end

function winapi.get_window_rect(hwnd)
    return get_window_rect(hwnd)
end

function winapi.get_window_thread_process_id(hwnd)
    local tid, pid = get_window_thread_process_id(hwnd)
    return tid, pid
end

function winapi.get_window_style(hwnd)
    return 0 
end

function winapi.is_window_visible(hwnd)
    return true
end

function winapi.is_window_enabled(hwnd)
    return true
end

_G.winapi = winapi
return winapi
 end)




_G.polyfill = {}

_G.Polyfill_TickCallbacks = {}
_G.Polyfill_UnloadCallbacks = {}
_G.Polyfill_NetCallbacks = {}

_G.engine = {}
_G.render = {}
_G.proc = {}
_G.fs = {}
_G.input = {}
_G.gui = {}
_G.net = {}
_G.time = {}
_G.winapi = {}
_G.m = {}
_G.str = {}

function polyfill.main()

    return 1 
end

function polyfill.on_frame()
    for id, callback in pairs(_G.Polyfill_TickCallbacks) do
        if callback then
            local success, err = pcall(callback, id)
            if not success then
           
            end
        end
    end
end

function polyfill.on_unload()
    for i = 1, #Polyfill_UnloadCallbacks do
        if Polyfill_UnloadCallbacks[i] then
            Polyfill_UnloadCallbacks[i]()
        end
    end
end

require("polys.engine")
require("polys.render")
require("polys.process")
require("polys.m")
require("polys.fs")
require("polys.input")
require("polys.gui")
require("polys.time")
require("polys.str")
require("polys.math")
require("polys.net")
require("polys.winapi")
require("polys.vectors")



main = polyfill.main
on_frame = polyfill.on_frame
on_unload = polyfill.on_unload

local engine = _G.engine or {}
local winapi = _G.winapi or {}
local Config = {
    url = "http://localhost/cs2radar/api.php", 
    send_delay_ms = 100,
    room_code = ""
}

local offsets = {
    dwLocalPlayerPawn = 0x1BEEF28,
    dwLocalPlayerController = 0x1E1DC18,
    dwEntityList = 0x1D13CE8,
    dwViewAngles = 0x1E3C800,
    dwGlobalVars = 0x1BE41C0, 
    
    m_nTickBase = 0x6B0,
    m_nBombSite = 0x1164,
    m_flC4Blow = 0x1190,
    m_flTimerLength = 0x1198,
    m_bBombDefused = 0x11B4,
    m_bBeingDefused = 0x119C,
    m_bBombTicking = 0x1160,
    m_flDefuseLength = 0x11AC,
    m_flDefuseCountDown = 0x11B0,

    m_iTeamNum = 0x3EB,
    m_iHealth = 0x34C,
    m_pGameSceneNode = 0x330,
    m_vecAbsOrigin = 0xD0,
    m_vecVelocity = 0x430, 
    m_angEyeAngles = 0x3DF0,
    m_hPlayerPawn = 0x8FC,
    m_sSanitizedPlayerName = 0x850,
    m_pInGameMoneyServices = 0x7F8,
    m_iAccount = 0x40,
    m_pClippingWeapon = 0x3DE0,
    m_hOwnerEntity = 0x520, 
    m_pEntity = 0x10,
    m_designerName = 0x20
}

local cs2_process = nil
local last_send_time = 0
local debug_c4_text = "Waiting..."
local font = nil

local function FastRound(num) return math.floor(num + 0.5) end

local function GenerateCode()
    local charset = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"
    local code = ""
    local seed = winapi.get_tickcount64 and winapi.get_tickcount64() or os.time()
    math.randomseed(seed)
    for i = 1, 5 do
        local r = math.random(1, #charset)
        code = code .. string.sub(charset, r, r)
    end
    return code
end

local function GetWeaponName(pawn)
    if not cs2_process then return "Knife" end
    local weapon_ptr = cs2_process:r64(pawn + offsets.m_pClippingWeapon)
    if not weapon_ptr or weapon_ptr == 0 then return "Knife" end
    local data_ptr = cs2_process:r64(weapon_ptr + 0x10)
    if not data_ptr or data_ptr == 0 then return "Knife" end
    local name_ptr = cs2_process:r64(data_ptr + 0x20)
    if not name_ptr or name_ptr == 0 then return "Knife" end
    local raw = cs2_process:rs(name_ptr, 32)
    if raw then return string.gsub(raw, "weapon_", "") end
    return "Knife"
end

local function GetMapName(client_base)
    if not cs2_process or not client_base then return nil end
    local global_vars = cs2_process:r64(client_base + offsets.dwGlobalVars) 
    if not global_vars or global_vars == 0 then return nil end
    local map_ptr = cs2_process:r64(global_vars + 0x180)
    if map_ptr and map_ptr > 0x10000 then
        local raw = cs2_process:rs(map_ptr, 64)
        if raw then
            local clean = string.gsub(raw, "maps/", ""):gsub("%.vpk", ""):gsub("^%s*(.-)%s*$", "%1")
            if clean == "_dust2" then clean = "de_dust2" end
            if string.sub(clean, 1, 1) == "_" then clean = "de" .. clean end
            return clean
        end
    end
    return nil
end

local function GetServerTime(client_dll)
    local gvars_ptr = cs2_process:r64(client_dll + offsets.dwGlobalVars)
    if gvars_ptr and gvars_ptr ~= 0 then
        local t = cs2_process:rf32(gvars_ptr + 0x2C)
        if t and t > 10 then return t end
    end
    local local_controller = cs2_process:r64(client_dll + offsets.dwLocalPlayerController)
    if local_controller and local_controller ~= 0 then
        local tick_base = cs2_process:r32(local_controller + offsets.m_nTickBase)
        if tick_base and tick_base > 0 then return tick_base * 0.015625 end
    end
    return 0
end

local GrenadeTracker = {} 
local Infernos = {}

local function GetGrenades(client_dll)
    local ent_list = cs2_process:r64(client_dll + offsets.dwEntityList)
    if not ent_list or ent_list == 0 then return {} end

    local current_tick = winapi.get_tickcount64()
    local found_this_tick = {}
    local active_grenades_list = {}

    for i = 64, 2048 do 
        local chunk = i >> 9
        local chunk_ptr = cs2_process:r64(ent_list + 8 * chunk + 16)
        if chunk_ptr ~= 0 then
            local ent = cs2_process:r64(chunk_ptr + 112 * (i & 0x1FF))
            if ent and ent ~= 0 then
                local entity_identity = cs2_process:r64(ent + offsets.m_pEntity)
                if entity_identity > 0 then
                    local name_ptr = cs2_process:r64(entity_identity + offsets.m_designerName)
                    if name_ptr > 0 then
                        local name = cs2_process:rs(name_ptr, 64)
                        
                        if name == "smokegrenade_projectile" then
                            found_this_tick[i] = true
                            
                            local vel_x = cs2_process:rf32(ent + offsets.m_vecVelocity)
                            local vel_y = cs2_process:rf32(ent + offsets.m_vecVelocity + 4)
                            local vel_z = cs2_process:rf32(ent + offsets.m_vecVelocity + 8)
                            local speed = math.sqrt(vel_x*vel_x + vel_y*vel_y + vel_z*vel_z)
                            
                            if not GrenadeTracker[i] then GrenadeTracker[i] = { type="smoke", start=0 } end
                            
                            if speed < 15 then
                                if GrenadeTracker[i].start == 0 then GrenadeTracker[i].start = current_tick end
                                
                                local elapsed = (current_tick - GrenadeTracker[i].start) / 1000.0
                                local left = 21.5 - elapsed
                                if left > 0 then
                                    local scene = cs2_process:r64(ent + offsets.m_pGameSceneNode)
                                    if scene > 0 then
                                        local x = FastRound(cs2_process:rf32(scene + offsets.m_vecAbsOrigin))
                                        local y = FastRound(cs2_process:rf32(scene + offsets.m_vecAbsOrigin + 4))
                                        table.insert(active_grenades_list, { type="smoke", x=x, y=y, time_left=left, max_time=21.5 })
                                    end
                                end
                            else
                                GrenadeTracker[i].start = 0
                            end
                        
                        elseif name == "molotov_projectile" or name == "incendiarygrenade_projectile" then
                            found_this_tick[i] = true
                            
                            local scene = cs2_process:r64(ent + offsets.m_pGameSceneNode)
                            if scene > 0 then
                                local x = FastRound(cs2_process:rf32(scene + offsets.m_vecAbsOrigin))
                                local y = FastRound(cs2_process:rf32(scene + offsets.m_vecAbsOrigin + 4))
                                
                                GrenadeTracker[i] = { type="fire_projectile", last_x=x, last_y=y }
                            end
                        end
                    end
                end
            end
        end
    end

    for idx, data in pairs(GrenadeTracker) do
        if not found_this_tick[idx] then
            if data.type == "fire_projectile" and data.last_x then
                table.insert(Infernos, {
                    x = data.last_x,
                    y = data.last_y,
                    start = current_tick,
                    duration = 7.0
                })
            end
            GrenadeTracker[idx] = nil
        end
    end

    for k, inf in pairs(Infernos) do
        local elapsed = (current_tick - inf.start) / 1000.0
        local left = inf.duration - elapsed
        
        if left > 0 then
            table.insert(active_grenades_list, { type="fire", x=inf.x, y=inf.y, time_left=left, max_time=inf.duration })
        else
            Infernos[k] = nil 
        end
    end

    return active_grenades_list
end

local function GetBombInfo(client_dll)
    local ent_list = cs2_process:r64(client_dll + offsets.dwEntityList)
    if not ent_list or ent_list == 0 then return nil end

    local c4_address = 0
    local valid_c4 = false

    for i = 64, 1024 do 
        local chunk = i >> 9
        local chunk_ptr = cs2_process:r64(ent_list + 8 * chunk + 16)
        if chunk_ptr ~= 0 then
            local ent = cs2_process:r64(chunk_ptr + 112 * (i & 0x1FF))
            if ent and ent ~= 0 then
                local length = cs2_process:rf32(ent + offsets.m_flTimerLength)
                if length > 29 and length < 61 then
                     local ticking = cs2_process:r8(ent + offsets.m_bBombTicking)
                     local defused = cs2_process:r8(ent + offsets.m_bBombDefused)
                     local blow = cs2_process:rf32(ent + offsets.m_flC4Blow)
                     if (ticking == 1 or defused == 1) and blow > 0 then
                        c4_address = ent
                        valid_c4 = true
                        break
                     end
                end
            end
        end
    end

    if not valid_c4 then return nil end
    
    local server_time = GetServerTime(client_dll)
    local blow_time = cs2_process:rf32(c4_address + offsets.m_flC4Blow)
    local timer_length = cs2_process:rf32(c4_address + offsets.m_flTimerLength)
    local defused = cs2_process:r8(c4_address + offsets.m_bBombDefused)

    if defused == 1 then
        return { 
            active = true, planted = true, 
            is_defused = true, 
            time = 0, max_time = 1, defusing = false 
        } 
    end

    if server_time == 0 or blow_time == 0 then return nil end
    local time_left = blow_time - server_time
    if time_left > 100 or time_left < -2 then return nil end
    if not timer_length or timer_length <= 0 then timer_length = 40.0 end

    local is_defusing = cs2_process:r8(c4_address + offsets.m_bBeingDefused) == 1
    
    local scene = cs2_process:r64(c4_address + offsets.m_pGameSceneNode)
    local bx, by = 0, 0
    if scene ~= 0 then
        bx = FastRound(cs2_process:rf32(scene + offsets.m_vecAbsOrigin))
        by = FastRound(cs2_process:rf32(scene + offsets.m_vecAbsOrigin + 4))
    end

    local site_id = cs2_process:r32(c4_address + offsets.m_nBombSite)
    local site_str = (site_id == 1) and "B" or "A"

    debug_c4_text = string.format("C4 FOUND! Left: %.1f Site: %s", time_left, site_str)

    return {
        active = true,
        planted = true,
        x = bx, y = by,
        time = math.max(0, time_left),
        max_time = timer_length,
        defused = false,
        defusing = is_defusing,
        site = site_str
    }
end

function main()
    Config.room_code = GenerateCode()
    if render and render.create_font then font = render.create_font("Verdana", 16, 700) end
    _Internal_CurrentProcess = ref_process("cs2.exe")
    cs2_process = _Internal_CurrentProcess
    return 1 
end

function on_frame()
    if font then 
        render.draw_text(font, "RADAR: " .. Config.room_code, 20, 300, 255, 255, 255, 255) 
        render.draw_text(font, debug_c4_text, 20, 320, 255, 255, 0, 255) 
    end
    
    if not cs2_process or not cs2_process:alive() then
        cs2_process = ref_process("cs2.exe")
        _Internal_CurrentProcess = cs2_process
        return
    end

    local get_tick = winapi.get_tickcount64 or _G.get_tickcount64
    local now = get_tick()
    if now - last_send_time < Config.send_delay_ms then return end
    last_send_time = now

    local client_base = cs2_process:get_module("client.dll")
    if not client_base or client_base == 0 then return end

    local local_pawn = cs2_process:r64(client_base + offsets.dwLocalPlayerPawn)
    if not local_pawn or local_pawn == 0 then return end

    local local_node = cs2_process:r64(local_pawn + offsets.m_pGameSceneNode)
    local pos_x, pos_y = 0, 0
    if local_node and local_node > 0 then
        pos_x = FastRound(cs2_process:rf32(local_node + offsets.m_vecAbsOrigin))
        pos_y = FastRound(cs2_process:rf32(local_node + offsets.m_vecAbsOrigin + 4))
    end
    
    local va_y = FastRound(cs2_process:rf32(client_base + offsets.dwViewAngles + 4))
    local local_team = cs2_process:r32(local_pawn + offsets.m_iTeamNum)
    local local_health = cs2_process:r32(local_pawn + offsets.m_iHealth)
    local local_weapon = GetWeaponName(local_pawn)

    local local_name = "ME"
    local local_money = 0
    local local_ctrl = cs2_process:r64(client_base + offsets.dwLocalPlayerController)
    
    if local_ctrl and local_ctrl > 0 then
        local name_ptr = cs2_process:r64(local_ctrl + offsets.m_sSanitizedPlayerName)
        if name_ptr and name_ptr > 0 then
            local raw = cs2_process:rs(name_ptr, 16)
            if raw and raw ~= "" then local_name = raw end
        end
        local money_svc = cs2_process:r64(local_ctrl + offsets.m_pInGameMoneyServices)
        if money_svc and money_svc > 0 then
            local_money = cs2_process:r32(money_svc + offsets.m_iAccount)
        end
    end

    local current_map = GetMapName(client_base) or "de_mirage"
    local ent_list = cs2_process:r64(client_base + offsets.dwEntityList)
    
    local c4_info = GetBombInfo(client_base)
    local grenades_data = GetGrenades(client_base)

    local payload = {
        m = current_map,
        l = { n = local_name, t = local_team, h = local_health, w = local_weapon, x = pos_x, y = pos_y, a = va_y, m = local_money },
        e = {}, d = {},
        c4 = c4_info,
        g = grenades_data 
    }

    if ent_list and ent_list > 0 then
        for i = 1, 64 do
            local list_entry = cs2_process:r64(ent_list + 8 * ((i & 0x7FFF) >> 9) + 16)
            if list_entry and list_entry > 0 then
                local controller = cs2_process:r64(list_entry + 112 * (i & 0x1FF))
                if controller and controller > 0 then
                    local pawn_h = cs2_process:r32(controller + offsets.m_hPlayerPawn)
                    if pawn_h and pawn_h > 0 then
                        local entry2 = cs2_process:r64(ent_list + 8 * ((pawn_h & 0x7FFF) >> 9) + 16)
                        if entry2 and entry2 > 0 then
                            local pawn = cs2_process:r64(entry2 + 112 * (pawn_h & 0x1FF))
                            
                            if pawn and pawn > 0 and pawn ~= local_pawn then
                                local health = cs2_process:r32(pawn + offsets.m_iHealth)
                                if health > 0 then
                                    local p_node = cs2_process:r64(pawn + offsets.m_pGameSceneNode)
                                    if p_node and p_node > 0 then
                                        local p_team = cs2_process:r32(pawn + offsets.m_iTeamNum)
                                        local px = FastRound(cs2_process:rf32(p_node + offsets.m_vecAbsOrigin))
                                        local py = FastRound(cs2_process:rf32(p_node + offsets.m_vecAbsOrigin + 4))
                                        local p_yaw = FastRound(cs2_process:rf32(pawn + offsets.m_angEyeAngles + 4))
                                        
                                        local p_name_addr = cs2_process:r64(controller + offsets.m_sSanitizedPlayerName)
                                        local p_name = "?"
                                        if p_name_addr > 0 then p_name = cs2_process:rs(p_name_addr, 16) end
                                        
                                        local p_weapon = GetWeaponName(pawn)
                                        
                                        local p_money = 0
                                        local p_money_svc = cs2_process:r64(controller + offsets.m_pInGameMoneyServices)
                                        if p_money_svc and p_money_svc > 0 then
                                            p_money = cs2_process:r32(p_money_svc + offsets.m_iAccount)
                                        end

                                        table.insert(payload.e, { 
                                            n = p_name, t = p_team, h = health, w = p_weapon, 
                                            x = px, y = py, a = p_yaw, m = p_money 
                                        })
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end

        for i = 65, 2048 do 
            local list_entry = cs2_process:r64(ent_list + 8 * ((i >> 9) & 0x7F) + 16)
            if list_entry and list_entry > 0 then
                local entity = cs2_process:r64(list_entry + 112 * (i & 0x1FF))
                if entity and entity > 0 then
                    local owner = cs2_process:r32(entity + offsets.m_hOwnerEntity)
                    
                    if owner == -1 or owner == 4294967295 then
                        local entity_identity = cs2_process:r64(entity + offsets.m_pEntity)
                        if entity_identity and entity_identity > 0 then
                            local name_ptr = cs2_process:r64(entity_identity + offsets.m_designerName)
                            if name_ptr and name_ptr > 0 then
                                local name = cs2_process:rs(name_ptr, 32)
                                if name and (string.find(name, "weapon_") or name == "weapon_c4") and not string.find(name, "knife") then
                                    local scene = cs2_process:r64(entity + offsets.m_pGameSceneNode)
                                    if scene and scene > 0 then
                                        local wx = FastRound(cs2_process:rf32(scene + offsets.m_vecAbsOrigin))
                                        local wy = FastRound(cs2_process:rf32(scene + offsets.m_vecAbsOrigin + 4))
                                        
                                        if wx ~= 0 and wy ~= 0 then
                                            local short_name = string.gsub(name, "weapon_", ""):gsub("_projectile", "")
                                            table.insert(payload.d, { n = short_name, x = wx, y = wy })
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    local success, json_str = pcall(json.stringify, payload)
    if success and json_str then
        pcall(net.send_request, Config.url .. "?id=" .. Config.room_code, {["Content-Type"] = "application/json"}, json_str)
    end
end