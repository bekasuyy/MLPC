require('widgets')

local ffi      = require("ffi")
local mem      = require("memory")
local SAMemory = require("SAMemory")
SAMemory.require("CCamera")

local NOP_W = "\xAF\xF3\x00\x80"
local base  = MONET_GTASA_BASE

mem.copy(base + 0x4A1358, NOP_W, 4, true)
mem.copy(base + 0x4A1434, NOP_W, 4, true)

local bekasuyy = ffi.cast("void*(**)(int)", base + 0x672F58)

local function snapTo45(angle)
    local deg = math.deg(angle)
    local snapped = math.floor(deg / 45.0 + 0.5) * 45
    return math.rad(snapped)
end

function main()
    while true do
        wait(0)

        local pressed, x, y = isWidgetPressedEx(WIDGET_PED_MOVE, 0)
        pressed = pressed or false
        x = tonumber(x) or 0.0
        y = tonumber(y) or 0.0

        local magnitude = math.sqrt(x*x + y*y) / 169.9

        if pressed and magnitude > 0.2 then
            local ped = ffi.cast("CPed*", bekasuyy[0](0))
            local phi = SAMemory.camera.aCams[0].fHorizontalAngle

            if ped ~= nil then
                local joyAngle = math.atan2(-y / 169.9, x / 169.9)
                ped.fCurrentRotation = snapTo45(phi + joyAngle)
            end
        end
    end
end
