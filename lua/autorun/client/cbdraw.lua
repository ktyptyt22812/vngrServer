-- cbdraw
-- Copyright (C) 2018-2026 ktypt, selyodka, Astalcircle(partially)

-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <https://www.gnu.org/licenses/>.

cbdraw = {}

function cbdraw.ScreenScale(size, resolution)
    return math.max(size * (ScrW() / (resolution or 1280)), 1)
end

function cbdraw.ScreenScaleH(size, resolution)
    return math.max(size * (ScrH() / (resolution or 720)), 1)
end

function cbdraw.SimpleText(text, font, x, y, color, xalign, yalign, shadow_font, shadow_destiny)
    font          = font          or "CBFont"
    shadow_font   = shadow_font   or "CBFont_Shadow"
    shadow_destiny = shadow_destiny or 1
    xalign        = xalign        or TEXT_ALIGN_LEFT
    yalign        = yalign        or TEXT_ALIGN_TOP

    surface.SetFont(font)
    local tw, th = surface.GetTextSize(text)

    local px = x
    local py = y
    if xalign == TEXT_ALIGN_CENTER then px = x - tw / 2
    elseif xalign == TEXT_ALIGN_RIGHT then px = x - tw end
    if yalign == TEXT_ALIGN_CENTER then py = y - th / 2
    elseif yalign == TEXT_ALIGN_BOTTOM then py = y - th end

    if shadow_font then
        surface.SetFont(shadow_font)
        surface.SetTextColor(0, 0, 0, 180)
        surface.SetTextPos(px + shadow_destiny, py + shadow_destiny)
        surface.DrawText(text)
    end

    surface.SetFont(font)
    surface.SetTextColor(color or color_white)
    surface.SetTextPos(px, py)
    surface.DrawText(text)
end

function cbdraw.DrawText(text, columns, x, y)
    local parts = string.Explode("\n", text)
    for i, column in ipairs(columns) do
        local part = parts[i]  
        if part then
            cbdraw.SimpleText(
                part,
                column.font,
                x, y + (i - 1) * cbdraw.ScreenScaleH(20),  
                column.color,
                column.xalign,
                column.yalign
            )
        end
    end
end