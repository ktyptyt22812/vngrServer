-- cl_main
-- Copyright (C) 2021-2026 ktypt, selyodka, kot

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

--a block with messages
local function discord(name, msg)
	chat.AddText(Color(0,0,0),"[",Color(100,100,255),"Discord",Color(0,0,0),"] ",Color(255,225,255),name, Color(255,255,255),": ",Color(250,250,250),msg)
end
local function telegram(name, msg)
	chat.AddText(Color(0,0,0),"[",Color(36, 161, 222),"Telegramm",Color(0,0,0),"] ",Color(255,225,255),name, Color(255,255,255),": ",Color(250,250,250),msg)
end
local function BOTmessage(name, msg)
	chat.AddText(Color(0,0,0),"[",Color(0, 0, 255),"BOT",Color(0,0,0),"] ",Color(255,225,255),name, Color(255,255,255),": ",Color(250,250,250),msg)
end
local function server2message(name, msg)
	chat.AddText(Color(0,0,0),"[",Color(255, 191, 0),"Server 2",Color(0,0,0),"] ",Color(255,225,255),name, Color(255,255,255),": ",Color(250,250,250),msg)
end
net.Receive("VK",function()
	local gay = net.ReadTable() 
	for k,v in pairs(gay[1]) do
		discord(v[1],v[2])
	end
end)
net.Receive("BOTmessage",function()
	local gay = net.ReadTable() 
	for k,v in pairs(gay[1]) do
		BOTmessage(v[1],v[2])
	end
end)

net.Receive("server2message",function()
	local gay = net.ReadTable() 
	for k,v in pairs(gay[1]) do
		server2message(v[1],v[2])
	end
end)
local accum = 0
net.Receive("telega",function()
	local gay = net.ReadTable() 
	for k,v in pairs(gay[1]) do
		telegram(v[1],v[2])
	end
end)


--custom chat tags
function ChatTags(player, text, isTeam, something)
    local parts = {}
    local defaultColor = Color(255, 255, 255)

    if not IsValid(player) then
        table.Add(parts, { Color(30, 30, 30), "[", Color(0, 0, 255), "Console", Color(30, 30, 30), "]" })
    else
        if player:GetNWBool("buildmode") then
            TAG = '[Build] '
        else
            TAG = ''
        end

        table.Add(parts, { Color(0, 150, 0), TAG, team.GetColor(player:Team()), player:Name() }) --todo: easy chat implement
        --[[
        if player:SteamID() == "STEAM_0:0:593729936" then
            defaultColor = Color(255, 242, 253)
        end
        --]]
    end

    table.Add(parts, { Color(255, 255, 255), ": ", isTeam and Color(0, 255, 0) or defaultColor, text })
    chat.AddText(unpack(parts))
    return true
end
hook.Add("OnPlayerChat", "ChatTags", ChatTags)
--[[]
do
	surface.CreateFont( "good", {
		font = "Roboto thin",
		extended = false,
		size = 300,
		weight = 2,
		blursize = 0,
		scanlines = 0,
		antialias = true, 
		underline = false,
		italic = false,
		symbol = false,
		rotary = false,
		shadow = false,
		additive = false,
		outline = false,
	} )
	surface.CreateFont( "good1", {
		font = "Consolas",
		extended = true,
		size = 300,
		weight = 200,
		blursize = 0,
		scanlines = 0,
		antialias = true, 
		underline = false,
		italic = false,
		symbol = false,
		rotary = false,
		shadow = false,
		additive = false,
		outline = true,
	} )
	surface.CreateFont( "good2", {
		font = "Arial",
		extended = false,
		size = 300,
		weight = 200,
		blursize = 0,
		scanlines = 0,
		antialias = true, 
		underline = false,
		italic = false,
		symbol = true,
		rotary = false,
		shadow = false,
		additive = false,
		outline = false,
	} )
	surface.CreateFont("VNGR_Name", {
		font = "Courier",
		size = 300,
		weight = 1000,
		antialias = true,
		shadow = false,
		outline = false,
	})
	surface.CreateFont("VNGR_Name2", {
		font = "Courier",
		size = 400,
		weight = 700,
		antialias = false,
		shadow = false,
		outline = false,
	})
	surface.CreateFont("VNGR_Status", {
		font = "Default",
		size = 20,
		weight = 600,
		antialias = true,
		shadow = false,
		outline = true,
	})

	local function DrawName( ply )
		local me = LocalPlayer()
		if ( !IsValid( ply ) ) then return end
		if ( ply == me ) then return end
		if ( !ply:Alive() ) then return end
		local level = ply:GetNWInt("vngr_lvl")

		local strDisplayText = "lv." .. level

		local Distance = me:GetPos():DistToSqr( ply:GetPos() )

		local minDistance = 1000
		local maxDistance = 4000000

		if ( Distance < maxDistance and Distance > minDistance ) then
			
			local distanceAlpha = 255
			--if Distance < 250000 then 
			--	distanceAlpha = math.Remap(Distance, minDistance, 250000, 0, 255)
			--end
			
            -- todo: cbtext implemetation
			local targetAlpha = (ply:Crouching() and 12 or 255)
			targetAlpha = math.min(targetAlpha, distanceAlpha)
			
			ply.nameAlpha = math.Approach(ply.nameAlpha or 255, targetAlpha, 255*2*FrameTime()) 
			
			if ply.nameAlpha < 1 then return end
			
			local offset = Vector(0, 0, 85) * ply:GetModelScale()
			local ang = me:EyeAngles()
			local pos = ply:GetPos() + offset + ang:Up()

			ang:RotateAroundAxis( ang:Forward(), 90 )
			ang:RotateAroundAxis( ang:Right(), 90 )
			
			cam.Start3D2D( pos, ang, 0.04 * math.min(1, ply:GetModelScale()) )
				local tc = team.GetColor( ply:Team() )
				tc.a = ply.nameAlpha
				
				local thickness = 4
				for x = -thickness, thickness do
					for y = -thickness, thickness do
						if not (x == 0 and y == 0) then
							draw.DrawText(ply:GetName(), "VNGR_Name", 2 + x, 2 + y, Color(0, 0, 0, 10), TEXT_ALIGN_CENTER)
						end
					end
				end
				
				draw.DrawText(ply:GetName(), "VNGR_Name", 2, 2, tc, TEXT_ALIGN_CENTER)
				
				--[[
				if ply:GetNWBool("buildmode") then
					if ply:IsAdmin() or ply:IsSuperAdmin() then
						draw.DrawText( "**BUILD**", "good1", 2, -30, Color(0,0,200,ply.nameAlpha), TEXT_ALIGN_CENTER )
					else
						draw.DrawText( "**BUILD**", "good1", 2, -30, Color(0,200,0,ply.nameAlpha), TEXT_ALIGN_CENTER )
					end
				elseif ply:HasGodMode() then
					if ply:IsAdmin() or ply:IsSuperAdmin() then
						draw.DrawText( "***GOD***", "good1", 2, -30, Color(0,0,200,ply.nameAlpha), TEXT_ALIGN_CENTER )
					else
						draw.DrawText( "***GOD***", "good1", 2, -30, Color(0,200,0,ply.nameAlpha), TEXT_ALIGN_CENTER )
					end
				end
				
				if ply:SteamID() == "STEAM_0:0:593729936" then
					ply.orbStates = ply.orbStates or {}
					ply.orbitStartTime = ply.orbitStartTime or CurTime()
					
					local glow = Material("sprites/light_glow02_add")
					local numOrbs = 6
					local baseRadius = 50
					local ellipseY = baseRadius * 0.6
					local size = 25
					local delayBetween = 0.1
					local flyDuration = 0.8
					local spinAngle = CurTime() * 50
					
					for i = 1, numOrbs do
						local delay = (i - 1) * delayBetween
						local startTime = ply.orbitStartTime + delay
						
						local angle = math.rad(spinAngle + i * 60)
						local targetX = math.cos(angle) * baseRadius
						local targetY = math.sin(angle) * ellipseY
						
						ply.orbStates[i] = ply.orbStates[i] or { progress = 0 }
						
						if CurTime() >= startTime then
							local timePassed = CurTime() - startTime
							local progress = math.Clamp(timePassed / flyDuration, 0, 1)
							ply.orbStates[i].progress = progress
						end
						
						local progress = ply.orbStates[i].progress or 0
						
						local currentX = Lerp(progress, -1000, targetX)
						local currentY = Lerp(progress, -200, targetY)
						
						local depth = math.sin(angle)
						local size3D = size * (1 + depth * 0.3)
						local alpha = math.Clamp(80 + depth * 100, 50, 255)
						local spriteSpin = (CurTime() * 180 + i * 60) % 360
						
						surface.SetDrawColor(100, 150, 255, alpha * (ply.nameAlpha / 255))
						surface.SetMaterial(glow)
						surface.DrawTexturedRectRotated(currentX, currentY + 20, size3D, size3D, spriteSpin)
					end
				end

			cam.End3D2D()
		end
	end
	hook.Add( "PostPlayerDraw", "DrawName", DrawName )

	hook.Add( "HUDShouldDraw", "RemoveThatShit", function( name ) 
		if ( name == "CHudDamageIndicator" ) then 
		return false 
		end
	end )


	hook.Remove("Tick","tickexample")

end
]]

local lastScreenshotTime = 0
local cooldown = 10 
local HTTP_PORT = 8083 -- dont work
net.Receive("screenshot_rdy", function()
	if net.ReadBool() then
		local ts = net.ReadString()
		hook.Add( "PostRender", "gearbox_screenshot", function()
			img = render.Capture( {
				format = "jpeg",
				quality = 90, 
				h = ScrH(),
				w = ScrW(),
				x = 0,
				y = 0,
			} )
			print(#img)
			local ip = string.Explode(":", "145.249.247.157:27015")[1]
			http.Post(
				string.format("http://%s:%d/upload?ts=%s&sid=%s", ip, HTTP_PORT, ts, LocalPlayer():SteamID64()),
				{i = util.Base64Encode(img)},
				function(b, s, h, c) print(c) end,
				function(e) print(e) end
			)

			hook.Remove( "PostRender", "gearbox_screenshot")
		end )
		timer.Simple(1,function() 
			notification.AddLegacy( "Скрин Загружается! ".. os.date( "%H:%M:%S   |   %d/%m/%Y" , os.time() ), NOTIFY_GENERIC, 10 )
		end)
	else
		local t = net.ReadFloat()
		if t < 0 then
			notification.AddLegacy("Ошибка загрузки скриншота, попробуйте позже", NOTIFY_UNDO, 4 )
			return
		end
		notification.AddLegacy("Подождите до следующего скриншота - "..tostring(math.Round(t,2)).." секунд", NOTIFY_UNDO, 2 )
	end
end)


