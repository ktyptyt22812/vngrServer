-- cl_hud
-- Copyright (C) 2018-2026 ktypt, selyodka, kot, akych

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

local wep = {
	["gmod_tool"] = true,
	["weapon_physgun"] = true,	
	}
--[[]
hook.Add( "PostDrawTranslucentRenderables", "xyz", function( drawingDepth, drawingSky )

	if !GearBox.GetCvar('gearbox_prop_xyz') then return end
		local me = LocalPlayer()
		local wepo = me:GetActiveWeapon()
		if me:Alive() then 
		if IsValid(wepo) then
		if !wep[wepo:GetClass()] then return end
		if ( not IsValid( me ) ) then return end
		
		local ent = me:GetEyeTrace().Entity
		if ( not IsValid( ent ) ) then
			return
		end
		
		if(me:GetPos():Distance(ent:GetPos()) > 500) then return end

		
		local pos = ent:GetPos()
		local f = ent:GetForward()
		local r = ent:GetRight()
		local u = ent:GetUp()

		render.DrawLine( pos,    pos + (f*25),      Color(255,0,0), false )
		render.DrawLine( pos,    pos + (r*25),      Color(0,255,0), false )
		render.DrawLine( pos,    pos + (u*25),      Color(0,100,255), false )

		local fs = (pos + f*30):ToScreen()
		local rs = (pos + r*30):ToScreen()
		local us = (pos + u*30):ToScreen()
		local ang = ent:GetAngles()
		cam.Start2D()
			draw.SimpleText( "X", "GB_PropHud", fs.x, fs.y, Color(255,0,0),   0, 0, 1 )
			draw.SimpleText( "Y", "GB_PropHud", rs.x, rs.y,  Color(0,255,0), 0, 0, 1 )
			draw.SimpleText( "Z", "GB_PropHud", us.x, us.y,  Color(0,100,255),  1, 0, 1 )
		cam.End2D()
		
	end 
end
end)
]]
local function rmgavno()
     for k, v in pairs( g_SpawnMenu.CreateMenu.Items ) do
        if (v.Tab:GetText() == language.GetPhrase("spawnmenu.category.dupes") or
            v.Tab:GetText() == language.GetPhrase("spawnmenu.category.saves")) then
            g_SpawnMenu.CreateMenu:CloseTab( v.Tab, true )
            rmgavno()
        end
    end
end

hook.Add("SpawnMenuOpen", "rmgavno", rmgavno) 


surface.CreateFont("GB_Hud", {
    font = "Roboto",
    size = 40
})
 
surface.CreateFont("GB_PropHud", {
    font = "Roboto",
    size = 22
})
 
surface.CreateFont("GB_PropHude", {
    font = "Roboto",
    size = 22
})
 
surface.CreateFont("GB_NameHead", {
    font = "Roboto",
    size = 50
})
VNGR = VNGR or {}
VNGR.color = VNGR.color or {}

hook.Remove("PlayerTick", "TickWidgets")
hook.Add("OnEntityCreated", "WidgetInit", function(ent)
    if ent:IsWidget() then
        hook.Add("PlayerTick", "TickWidgets", function(pl, mv)
            widgets.PlayerTick(pl, mv)
        end)
        hook.Remove("OnEntityCreated", "WidgetInit")
    end
end)
 
 
GearBox = GearBox or {}
GearBox.cvars = GearBox.cvars or {}
 
GearBox.GetCvar = function(name)
    return GearBox.cvars[name] and GearBox.cvars[name] > 0
end
 
local cvarList = {
    "gearbox_prop_info",
    "gearbox_prop_xyz",
    "gearbox_show_hud",
    "gearbox_show_deadnotify",
    "gearbox_show_notify",
    "gearbox_show_chat_screen",
    "gearbox_load_addons",
    "gearbox_disconnect_animation",
	"vngr_style",
}
 
local function CvarRebuild()
    local t = {}
    for _, name in ipairs(cvarList) do
        CreateClientConVar(name, 1, true, false)
        GearBox.cvars[name] = 1
        cvars.AddChangeCallback(name, function(n, o, new)
            local val = tonumber(new)
            if type(val) ~= "number" then return end
            GearBox.cvars[n] = val
        end)
        table.insert(t, 1)
        MsgC("Initialize GB cvar ", Color(0, 255, 255), name, Color(255, 255, 255), " -> 1\n")
    end
    file.Write("gearbox/settings.txt", util.TableToJSON(t))
end
 
local function CvarRead()
    local t = util.JSONToTable(file.Read("gearbox/settings.txt", "DATA"))
    if not t or #t ~= #cvarList then
        CvarRebuild()
        return
    end
    for k, v in ipairs(t) do
        local name = cvarList[k]
        CreateClientConVar(name, v, false)
        GearBox.cvars[name] = v
        cvars.AddChangeCallback(name, function(n, o, new)
            local val = tonumber(new)
            if type(val) ~= "number" then return end
            GearBox.cvars[n] = val
        end)
        MsgC("Initialize cvar ", Color(0, 255, 255), name, "  ", Color(255, v * 255, 255), tostring(v), "\n")
    end
end
local Colors = {
	[NOTIFY_GENERIC] = Color(0, 255, 0, 255),
	[NOTIFY_ERROR]   = Color(255, 100, 100, 255),
	[NOTIFY_UNDO]    = Color(255, 255, 255, 255),
	[NOTIFY_HINT]    = Color(0, 255, 255, 255),
	[NOTIFY_CLEANUP] = Color(255, 255, 0, 255),
}
local ScreenPos = ScrH() - 150
local Notifications = {}

smoothcubes = 10
GearBox.Naming = "GearBox"
VNGR.color.accent = Color(255, 255, 255)
VNGR.color.BG = Color(20, 20, 20, 29)
VNGR.color.TEXT1 = Color(255, 255, 255)
VNGR.color.TEXT2 = Color(255, 255, 255)
local function UpdateStyle(newVal)
    local val = tonumber(newVal) or 0
    if val == 0 then 
        smoothcubes = 10
        GearBox.Naming = "GearBox"
		VNGR.color.accent = Color(0, 255, 255)
		VNGR.color.BG = Color(0, 0, 0, 200)
		VNGR.color.TEXT1 = Color(255, 255, 255)
    else 
        smoothcubes = 0
        GearBox.Naming = "VanguardR"
		VNGR.color.accent = Color(255, 255, 255)
		VNGR.color.BG = Color(25, 25, 25, 200)
		VNGR.color.TEXT1 = Color(255, 255, 255)
		VNGR.color.TEXT2 = Color(255, 255, 255)
    end
	RunConsoleCommand("spawnmenu_reload")
    MsgC(VNGR.color.accent, "VNGR: ", Color(255, 255, 255), "Style updated to: " .. GearBox.Naming .. "\n")
end
if not file.Exists("gearbox/settings.txt", "DATA") then
    CvarRebuild()
else
    CvarRead()
end
 


cvars.AddChangeCallback("vngr_style", function(name, old, new)
    UpdateStyle(new)
end)

timer.Simple(0, function()
    UpdateStyle(GetConVar("vngr_style"):GetInt())
end)
local function DrawNotification(x, y, w, h, text, col)
    draw.RoundedBox(smoothcubes, x + h, y, w - h, h, Color(27, 27, 27, 200))
    draw.SimpleText(text, "GB_PropHud", x + h + 10, y + h * 0.5, col, 0, 1)
end
 
function notification.AddLegacy(text, notifyType, time)
    if not GearBox.GetCvar("gearbox_show_notify") then return end
    surface.SetFont("GB_PropHud")
    local w = surface.GetTextSize(text) + 20 + 32
    local h = 32
    table.insert(Notifications, 1, {
        x        = 0,
        y        = ScreenPos,
        w        = w,
        h        = h,
        text     = text,
        col      = Colors[notifyType] or Color(255, 255, 255),
        time     = CurTime() + time,
        progress = false,
    })
end
 
function notification.AddProgress(id, text)
    return notification.AddLegacy(text, NOTIFY_UNDO, 10)
end
 
function notification.Kill(id)
    for _, v in ipairs(Notifications) do
        if v.id == id then v.time = 0 end
    end
end
 
hook.Add("HUDPaint", "DrawNotifications", function()
    for k, v in ipairs(Notifications) do
        DrawNotification(
            math.floor(v.x) - 40,
            math.floor(v.y),
            v.w, v.h, v.text, v.col
        )       
        local targetX = (v.time > CurTime()) and (10 + v.w) or (-4 - v.w)
        v.x = Lerp(FrameTime() * 10, v.x, targetX)
        v.y = Lerp(FrameTime() * 10, v.y, ScreenPos - (k - 1) * (v.h + 5))
    end

    for k = #Notifications, 1, -1 do
        local v = Notifications[k]
        if v.x <= -v.w and v.time < CurTime() then
            table.remove(Notifications, k)
        end
    end
end)
 
 
net.Receive("VK", function()
    local data = net.ReadTable()
    for _, v in ipairs(data[1]) do
        local isVK = v[3] > 0
        chat.AddText(
            Color(0, 0, 0),     "[",
            isVK and Color(100, 150, 255) or Color(100, 100, 255),
            isVK and "VK" or "Discord",
            Color(0, 0, 0),     "] ",
            Color(255, 205, 255), v[1], ": ",
            Color(250, 250, 250), v[2]
        )
        surface.PlaySound("gearbox/ui/" .. (isVK and "on" or "off") .. ".wav")
    end
end)
 
 
 
local deathNotices = {}
 
net.Receive("ded", function()
    if not GearBox.GetCvar("gearbox_show_deadnotify") then return end
    local txt = "  " .. table.concat(net.ReadTable(), " ") .. "  "
    local expireTime = CurTime() + 10
    surface.SetFont("GB_PropHude")
    local w, h = surface.GetTextSize(txt)
    table.insert(deathNotices, { txt, expireTime, -100, #deathNotices * 50, w, h })
end)
 
hook.Add("HUDPaint", "DrawDeathNotices", function()
    for k, v in ipairs(deathNotices) do
        v[3] = Lerp(0.1, v[3], v[5])
        v[4] = Lerp(0.1, v[4], k * (v[6] + 7))
        draw.RoundedBox(8, ScrW() - v[3] - 10, 50 + v[4], v[5] + 6, v[6] + 6, Color(25, 25, 25, 200))
        draw.SimpleText(v[1], "GB_PropHude", ScrW() - v[3] - 10, 52 + v[4], Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT)
        if v[2] < CurTime() then
            v[3] = Lerp(0.1, v[3], -v[5] - 28)
        end
        if (0.5 + v[2] - CurTime()) < 0 then
            table.remove(deathNotices, k)
        end
    end
end)
 
 local function GetPlayerState(ply)
    if ply:GetNWInt("buildmode") == 1 then
        return true, "В режиме строителя", Color(255, 255, 0)
    end
    if ply:GetNWInt("OnGod") == true then
        return true, "В режиме Бога", Color(255, 0, 255)
    end
    return false
end
 
local function DrawPlayerTag(ply)
    if not IsValid(ply) then return end
    local me = LocalPlayer()
    if me == ply then return end
    if me:GetPos():Distance(ply:GetPos()) > 1000 then return end
 
    local teamCol  = team.GetColor(ply:Team())
    local isAFK    = not ply:GetNWInt("Suka")  -- Suka == false означает AFK
    local hasState, stateText, stateCol = GetPlayerState(ply)
 
    cam.Start3D2D(ply:GetPos() + Vector(0, 0, 90), Angle(0, RenderAngles().y - 90, 90), 0.1)
        draw.SimpleText(ply:Name(), "GB_NameHead", 0, 50, teamCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        if hasState then
            draw.SimpleText(stateText, "GB_NameHead", 0, 0, stateCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        if not ply:GetNWInt("Suka") then
            draw.SimpleText(
                "Свернул игру  [" .. ply:GetNWInt("Tamer") .. " сек]",
                "GB_NameHead", 0, 90, teamCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER
            )
        end
    cam.End3D2D()
end
 hook.Add("PostPlayerDraw", "GearBox_NameTags", DrawPlayerTag)
 
local function DrawHUD()
    if GearBox.GetCvar("gearbox_show_hud") then return end
    local me = LocalPlayer()
    if not me:Alive() then return end
 
    local scrW, scrH = ScrW(), ScrH()
    local activeWep = me:GetActiveWeapon()
    if activeWep == "Camera" then return end
 
    surface.SetFont("GB_Hud")
 
    -- Броня
    local hpOffset = 40
    local armor = me:Armor()
    if armor > 0 then
        local armorTxt = "❖" .. armor .. " "
        local w, h = surface.GetTextSize(armorTxt)
        hpOffset = 0
        draw.RoundedBox(smoothcubes, 0, scrH - 40, w, h, Color(27, 27, 27, 200))
        draw.SimpleText(armorTxt, "GB_Hud", w * 0.5, scrH - 20, Color(255, 255, 255), 1, 1)
    end
 
    -- Здоровье
    local hpTxt = "✙" .. me:Health() .. " "
    local w, h = surface.GetTextSize(hpTxt)
    draw.RoundedBox(smoothcubes, 0, scrH - 80 + hpOffset, w, h, Color(27, 27, 27, 200))
    draw.SimpleText(hpTxt, "GB_Hud", w * 0.5, scrH - 80 + h * 0.5 + hpOffset, Color(255, 255, 255), 1, 1)
 
    -- Патроны
    if IsValid(activeWep) and activeWep:GetPrimaryAmmoType() ~= -1 then
        local clip1 = activeWep:Clip1()
        local prim  = me:GetAmmoCount(activeWep:GetPrimaryAmmoType())
        local sec   = me:GetAmmoCount(activeWep:GetSecondaryAmmoType())
        local ammoTxt
        if clip1 ~= -1 then
            ammoTxt = " " .. clip1
                .. (prim > 0 and " / " .. prim or "")
                .. (sec  > 0 and " / " .. sec  or "")
                .. " "
        else
            ammoTxt = " "
                .. (prim > 0 and tostring(prim) or "")
                .. (sec  > 0 and tostring(sec)  or "")
                .. " "
        end
        local aw, ah = surface.GetTextSize(ammoTxt)
        draw.RoundedBox(smoothcubes, scrW - aw, scrH - 40, aw, ah, Color(27, 27, 27, 200))
        draw.SimpleText(ammoTxt, "GB_Hud", scrW - aw * 0.5, scrH - 20, Color(255, 255, 255), 1, 1)
    end
end
 
hook.Add("HUDPaint", "GearBox_HUD", DrawHUD)
 
  
local hiddenHUD = {
    CHudHealth        = true,
    CHudSecondaryAmmo = true,
    CHudAmmo          = true,
    CHudBattery       = true,
}
 
hook.Add("HUDShouldDraw", "GearBox_HideDefaultHUD", function(name)
	if GearBox.GetCvar("gearbox_show_hud") then return true end
    if hiddenHUD[name] then return false end
end)
 
 
local xyzWeapons = {
    ["gmod_tool"]       = true,
    ["weapon_physgun"]  = true,
}
 
hook.Add("PostDrawTranslucentRenderables", "GearBox_XYZ", function()
    if not GearBox.GetCvar("gearbox_prop_xyz") then return end
    local me = LocalPlayer()
    if not me:Alive() then return end
    local wep = me:GetActiveWeapon()
    if not IsValid(wep) or not xyzWeapons[wep:GetClass()] then return end
 
    local ent = me:GetEyeTrace().Entity
    if not IsValid(ent) then return end
    if me:GetPos():Distance(ent:GetPos()) > 500 then return end
 
    local pos = ent:GetPos()
    local f, r, u = ent:GetForward(), ent:GetRight(), ent:GetUp()
 
    render.DrawLine(pos, pos + f * 25, Color(255, 0, 0),   false)
    render.DrawLine(pos, pos + r * 25, Color(0, 255, 0),   false)
    render.DrawLine(pos, pos + u * 25, Color(0, 100, 255), false)
 
    local fs = (pos + f * 30):ToScreen()
    local rs = (pos + r * 30):ToScreen()
    local us = (pos + u * 30):ToScreen()
 
    cam.Start2D()
        draw.SimpleText("X", "GB_PropHud", fs.x, fs.y, Color(255, 0, 0),   0, 0, 1)
        draw.SimpleText("Y", "GB_PropHud", rs.x, rs.y, Color(0, 255, 0),   0, 0, 1)
        draw.SimpleText("Z", "GB_PropHud", us.x, us.y, Color(0, 100, 255), 1, 0, 1)
    cam.End2D()
end)
 
 

local copyKeys = {
    KEY_1, KEY_2, KEY_3, KEY_4, KEY_5, KEY_6,
}
 
local function DrawPropInfo()
    if not GearBox.GetCvar("gearbox_prop_info") then return end
    local me = LocalPlayer()
    if not me:Alive() then return end
    local wep = me:GetActiveWeapon()
    if not IsValid(wep) or not xyzWeapons[wep:GetClass()] then return end
 
    local ent = me:GetEyeTrace().Entity
    if not IsValid(ent) or ent:IsWorld() then return end
 
    local t = {}
    local offset = 0
 
    if ent:IsPlayer() then
        t[1] = ent:Name()
        t[2] = ent:Health()
        t[3] = ent:GetModel()
    else
        local P   = ent:GetPos()
        local A   = ent:GetAngles()
        local S   = ent:OBBMaxs()
        local col = ent:GetColor()
        local mat = ent:GetMaterial()
 
        t[1] = ent
        t[2] = ent:GetModel()
 
        if mat == "" then
            offset = 1
        else
            t[3] = mat
        end
 
        t[4 - offset] = string.format("vec(%s,%s,%s)", math.Round(P[1], 1), math.Round(P[2], 1), math.Round(P[3], 1))
        t[5 - offset] = string.format("ang(%s,%s,%s)", math.Round(A[1], 1), math.Round(A[2], 1), math.Round(A[3], 1))
        t[6 - offset] = string.format("vec(%s,%s,%s,%s)", col.r, col.g, col.b, col.a)
        t[7 - offset] = string.format("vec(%s,%s,%s)", math.Round(S[1], 1), math.Round(S[2], 1), math.Round(S[3], 1))
    end
 
    for k, v in pairs(t) do
        local label = string.format("%s | %s", k, v)
        local y = ScrH() / 2 + k * 25
        draw.RoundedBox(10, ScrW() - 318, y, 318, 23, Color(25, 25, 25, 200))
        draw.DrawText(label, "GB_PropHud", ScrW() - 308, y, Color(255, 255, 255), TEXT_ALIGN_LEFT)
 
        if input.IsKeyDown(KEY_LALT) and input.IsKeyDown(copyKeys[k] or 0) then
            if t[k] ~= nil then
                draw.DrawText(label, "GB_PropHud", ScrW() - 308, y, Color(0, 255, 0), TEXT_ALIGN_LEFT)
                SetClipboardText(tostring(t[k]))
            end
        end
    end
end
 
hook.Add("HUDPaint", "GearBox_PropInfo", DrawPropInfo)
 