
local function ImageSig(f)
	local s = f:Read(4)
	return s == "\137PNG" or string.sub(s,1,3) == "\255\216\255" --png or jpg
end
local function GetTickrate()
    return math.Round(1 / engine.TickInterval())
end
local function GetServerLoad()
    local tick = GetTickrate()
    return math.Clamp(1 - (tick / 66), 0, 1) 
end

local function gay()
	local me = LocalPlayer()
	if !me:Alive() then  return end
	local x, y = ScrW(), ScrH()
	local warningback = math.abs(math.sin(CurTime() * 2)) * 255
	local wep = me:GetActiveWeapon()
	local hppos = 40
	--if wep == "Camera" then return end
	surface.SetFont("GB_Hud")
	local armor = me:Armor()
	if armor > 0 then
	local txt = "❖"..armor.." "
	local w,h = surface.GetTextSize(txt)
		hppos = 0

	--DrawBlurRect(120, y - 45, w, h)
	--draw.RoundedBox(0, 120, y - 45, w, h, GearBox.colors["HUD_HealthBackGround"])

	draw.SimpleText( txt, "GB_Hud", 120+w*.5,y - 25, GearBox.colors["HUD_ArmorText"] , 1, 1 )





	end
	local txt = "✙"..((me:HasGodMode() or me:GetNWBool("buildmode")) and "∞" or me:Health()).." "--Color(0,0,0, 40)
	local w,h = surface.GetTextSize(txt)

	if LocalPlayer():Health() <= 15 then 
		draw.RoundedBox( 0, 10, y - 45, w, h, Color(255,0,0,warningback) )
		
	end
	--DrawPolyRow(90+w, y-80+h, w, Color(255, 255, 255, 255), 10, 30)
	--draw.SimpleText( "VNGR", "GB_Hud", 40+w, y - 45+h*.5, GearBox.colors["HUD_HealthText"], 1, 1 )
	--draw.SimpleText( "instance test", "GB_Hud", 300+w, y - 45+h*.5, GearBox.colors["HUD_HealthText"], 1, 1 )
	--draw.SimpleText( txt, "GB_Hud", 10+w*.5, y - 45+h*.5, GearBox.colors["HUD_HealthText"], 1, 1 )
	--##
	--local govnopos = 135
	--DrawBlurRect(5, y - govnopos+hppos, w, h)
	--draw.RoundedBox( 10, 5, y - govnopos+hppos, w, h, GearBox.colors["HUD_HealthBackGround"] )
	--draw.SimpleText( "leo gay", "GB_Hud", 5+w*.5, y - govnopos+h*.5+hppos, GearBox.colors["HUD_HealthText"], 1, 1 )
	--##
	--if me:IsAdmin() or me:IsSuperAdmin() then

		--local names = {}
		--for _, ply in ipairs(player.GetAll()) do
		--	if ply:IsAdmin() or ply:IsSuperAdmin() then
		--		table.insert(names, ply:Nick())
		--	end
		--end
		
		--local adminNames = table.concat(names, ", ")
		--
		--draw.SimpleText(adminNames, "GB_Hud", 970+(-w*.5), y - 105+h*.5+hppos, team.GetColor(me:Team()), 1, 1)
--		
--	end


	if notifyText and CurTime() < notifyExpire then
        draw.SimpleText(
            notifyText,
            "Trebuchet24",
            ScrW() / 2,
            ScrH() * 0.4,
            Color(255, 255, 255),
            TEXT_ALIGN_CENTER,
            TEXT_ALIGN_CENTER
        )
    end
--	if IsValid(wep) and wep:GetPrimaryAmmoType()!=-1 then
--		local clip1 = wep:Clip1()
--		local prim = me:GetAmmoCount(wep:GetPrimaryAmmoType())
--		local sec = me:GetAmmoCount(wep:GetSecondaryAmmoType())
--		if clip1 !=-1 then
--			local txt = " "..clip1..(prim>0 and " / "..prim or "")..(sec>0 and " / "..sec or "").." "
--			local w,h = surface.GetTextSize(txt)
--			DrawBlurRect(x-w, y-40, w, h)

			--draw.RoundedBox( 10, x-w, y-40, w, h, GearBox.colors["HUD_AmmoBackground"] )
--			draw.SimpleText(txt, "GB_Hud", x-w*.5, y - 20, GearBox.colors["HUD_AmmoText"] , 1, 1)
			
			--draw.SimpleText(prim, "GB_Hud", ScrW()-62, ScrH() - 36, Color( 255, 255 ,255), 1, 1)		
--		else
--			local txt = " "..(prim>0 and ""..prim or "")..(sec>0 and ""..sec or "").." "
--			local w,h = surface.GetTextSize(txt)
--			DrawBlurRect(x-w, y-40, w, h)
			--draw.RoundedBox( 10, x-w, y-40, w, h, GearBox.colors["HUD_AmmoBackground"] )
--			draw.SimpleText(txt, "GB_Hud", x-w*.5, y - 20, GearBox.colors["HUD_AmmoText"], 1, 1)
--		end	
--	end
	
	local scrW, scrH = ScrW(), ScrH()
	local x, y = scrW / 2, scrH - 20 

	local w, h = 100, 20 

--	draw.RoundedBox(0, x - 150, y, w, h, Color(0,0,0, 90))
--	DrawBlurRect(x-150, y, w, h)
--	draw.RoundedBox(0, x - (-50), y, w, h, Color(0,0,0, 90))
--	DrawBlurRect(x-(-50), y, w, h)
	--draw.RoundedBox(0, x + 50, y, w, h, GearBox.colors["HUD_HealthBackGround"])
--	if LocalPlayer():IsSpeaking() then
--		mt2 = Material("materials/icon16/bullet_blue.png")
--	else
--		mt2 = Material("materials/icon16/bullet_black.png")
--	end


--	surface.SetMaterial(mt)
--	surface.SetDrawColor(255, 255, 255, 255)
--	surface.DrawTexturedRect(x - 145, y + 3, 14, 14) 
--	surface.SetMaterial(mt2)
--	surface.SetDrawColor(255, 255, 255, 255)
--	surface.DrawTexturedRect(x - 69, y + 3, 14, 14) 
	
--	draw.SimpleText(":" .. LocalPlayer():Ping() .. "ms", "DermaDefault", x - 100, y + 3, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
	--local level = LocalPlayer().xdefm_Profile.Level
--	local strDisplayText = "lv." .. 0 .. "  xp " .. 0
	--local strDisplayText = "lv." .. level .. "  xp " .. LocalPlayer().xdefm_Profile.Exp
--	draw.SimpleText(strDisplayText, "DermaDefault", x - (-120), y + 3, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
--	local dt = CurTime() - lastHeartbeat
end
local accum = 0
function DrawPolyRow(x, y, width, color, polyWidth, polyHeight)
    polyWidth = polyWidth or 25
    polyHeight = polyHeight or 25
    color = color or Color(215, 30, 0)

    local count = math.ceil(width / 50) + 2
    local offset = accum % 50

    for i = -1, count do
        local baseX = x + i * 50 + offset
        local alpha = 127 - ((baseX - (x + width / 2)) ^ 2) / (width / 2.7)
        surface.SetDrawColor(color.r, color.g, color.b, math.Clamp(alpha, 0, 255))
        draw.NoTexture()
        surface.DrawPoly({
            { x = baseX,              y = y },
            { x = baseX + polyWidth,  y = y },
            { x = baseX,              y = y + polyHeight },
            { x = baseX - polyWidth,  y = y + polyHeight }
        })
    end

    accum = accum + FrameTime() * 160
end
local e2Draws = {
[-1] = function(x,y) end, --no e2
[0] = function(x,y)
	surface.SetDrawColor( 255, 93, 0, 225 )
	surface.DrawTexturedRect( 0, 0, x, y )
end, --std e2
[1] = function(x,y)
	local k = ((CurTime()%1)^3)*10
	for i = 1, 10 do
		surface.SetDrawColor( 220, 0, 255, 15*math.sqrt(i) )
		surface.DrawTexturedRect( -i*k, -i*k, x+i*2*k, y+i*2*k )
	end
	surface.SetDrawColor( 255, 93, 0, 245 )
	surface.DrawTexturedRect( 0, 0, x, y )
	
end, --e2p
[2] = function(x,y)
	local k = ((CurTime()%1)^2)*10
	for i = 1, 8 do
		surface.SetDrawColor( 255, 120, 10, 15*math.sqrt(i) )
		surface.DrawTexturedRectRotated( x/2, y/2, x+i/4, y+i/4, CurTime()+i*k*10 )
	end
	--surface.SetDrawColor( 255, 93, 0, 245 )
	--surface.DrawTexturedRect( 0, 0, x, y )
	
end, --

}

local sfDraws = {
[-1] = function(x,y) end,
[0] = function(x,y)
	surface.SetDrawColor( 70, 127, 255, 225 )
	surface.DrawTexturedRect( 0, 0, x, y )
end,
[1] = function(x,y)
	surface.SetDrawColor( 70, 127, 255, 225 )
	surface.DrawTexturedRect( 0, 0, x, y )
end
}
local loaDraws = {
[0] = function(x,y) end,
[1] = function(x,y)
	
	surface.SetDrawColor( 70, 127, 255, 225 )
	surface.DrawTexturedRect( 0, 0, x, y )
end,
[2] = function(x,y)
    local time = RealTime() 
    local scale = 1 + math.sin(time * 3) * 0.5 
    local animated_w = x * scale
    local animated_h = y * scale
    local offset_x = (animated_w - x) / 2
    local offset_y = (animated_h - y) / 2
    local color_r = 70 + math.sin(time * 2) * 20
    local color_g = 127 + math.cos(time * 2.5) * 20
    local color_b = 255 
    surface.SetDrawColor( color_r, color_g, color_b, 255 )
    surface.DrawTexturedRect( -offset_x, -offset_y, animated_w, animated_h )
end
}

local e2Names = {
[-1] = "",
[0] = "E2",
[1] = "E2P",
[2] = "E2PP",
}

local sfNames = {
[-1] = "",
[0] = "Starfall",
[1] = "Starfall[superuser]",
}
local loaNames = {
[0] = "",
[1] = "loa",
[2] = "loa[superuser]",
}
local function fuckvar(name)
	local var = GetConVar(name)
	if not var then return 0 end --trash
	return var:GetInt()
end

--464*78
--if true then return end
GearBox_CustomMaterials = GearBox_CustomMaterials or {}

if not file.Exists("gearbox_trash", "DATA") then 
	file.CreateDir("gearbox_trash/plyraw")
end

local SIDBlock = SIDBlock or {}
if IsValid( ScoreBoard ) then ScoreBoard:Remove() end
	local Panel, PlayerCard, x, y
	 local OverAlpha = 240
	 local GlobalAlpha = 255

	local function timeToStr( time )
		local tmp = time
		local s = tmp % 60
		tmp = math.floor( tmp / 60 )
		local m = tmp % 60
		tmp = math.floor( tmp / 60 )
		local h = tmp % 24
		tmp = math.floor( tmp / 24 )
		local d = tmp % 7
		local w = math.floor( tmp / 7 )

		return string.format( "%02iw %id %02ih %02im %02is", w, d, h, m, s )
	end
	
	local function CountHolos(ply)
		local acc = 0
		local plyuid = ply:UserID()
		for _, v in pairs(ents.FindByClass("gmod_wire_hologram")) do
			if v:GetNWInt("ownerid") == plyuid then
				acc = acc + 1
			end
		end
		return acc
	end
	
	local function GetXY()
	    return ( 570 ) / 600, ( ScrH()-100  ) / 400
	end
	
	
	local function EndStream(ent)
		if(!ent.E2PAudStreams) then return end
		table.foreach(ent.E2PAudStreams, function(k) 
			if E2SoundParToEnt!=nil then E2SoundParToEnt[ent.E2PAudStreams[k]]=nil end
			ent.E2PAudStreams[k]:Stop()
			ent.E2PAudStreams[k] = nil
		end) 
		ent.E2PAudStreams = {}
	end 

	local function Register()
	 
	    x, y = GetXY() 
	 
	    PlayerCard = vgui.RegisterTable(
	    {
	        Init = function( self )
				
	            self:Dock( TOP )
	            self:SetHeight( 0 )
	            self:DockMargin( 0, 0, 0, 0 )
	            self:DockPadding( 1, 1, 1,1 )
	            self.Color = 0
				self.ToColor = 0
				
				self.Height = 0
				--self.Widthg = 0
				--self.ToWidthg = 580
				

				self.ToHeight =  80

				


	            self.Moving = true
				self.SizeAll = 0 
				
				self.fixed = self:Add( "DPanel" )
				self.fixed:SetSize( 556, 78 )
				self.fixed.Paint = nil
				
				self.Emblem = self.fixed:Add( "DImage" ) --DImage
				self.Emblem:SetText( "" )
				self.Emblem:Dock( FILL )
				
			   -- self.Emblem:SetSize( self.Emblem:GetTall(), self.Emblem:GetWide() )
			    --self.Emblem:SetSize( x*600, 90 )
				self.Emblem:DockMargin( -2, 2, -1, 1 )
				self.Emblem:DockPadding( 1, 1, 1,1 )
				--self.Emblem:SetZPos(-999)
				
				self.Emblem.EmblemOldLink = ""
				self.Emblem.Updatess = function(self,ply) 
					
					local String = ply:GetNWString("emblem")
					if self.Emblem.EmblemOldLink != String then
						local ext = table.remove(string.Explode(".", String))
						local suka = "gearbox_trash/plyraw/"..util.CRC(String).."."..ext
						
						local function refetch()
							file.Delete("gearbox_trash/plyraw/"..util.CRC(self.Emblem.EmblemOldLink))
							--http.Fetch("https://proxy.duckduckgo.com/iu/?u="..String,function(body)
							http.Fetch(""..String,function(body)
							   file.Write(suka, body)
							   GearBox_CustomMaterials[String]=Material("data/"..suka,"nocull")
							   ply.Emblem=GearBox_CustomMaterials[String]
							   self.Emblem:SetMaterial(GearBox_CustomMaterials[String])
							end)
						end
						
						if file.Exists(suka,"DATA") then
							local f = file.Open(suka,"rb","DATA")
							if not f then return end
							if not ImageSig(f) then
								refetch()
								f:Close()
								return
							end
							f:Close()
							
							GearBox_CustomMaterials[String]=Material("data/"..suka,"nocull")
							ply.Emblem=GearBox_CustomMaterials[String]
							self.Emblem:SetMaterial(GearBox_CustomMaterials[String])
						else
							refetch()
						end
						self.Emblem.EmblemOldLink = String

						self.Emblem:SetHTML("<body style='overflow:  hidden;'><img src='"..String.."' border='0' height='76' width='".. x*600-90 .."' style='max-width: '570'></body>")
					end
				end
				onload='GearBox.show()'
				
 
				
				
				self.Button = self:Add( "DButton" )
	            self.Button:SetText( "" )
				self.Button:SetSize( x * 600, 80 )
	            self.Button.Paint = nil
				self.Button.DoClick = function() self:Toggle() end  
				self.Button.DoRightClick = function() self.Player:ShowProfile()  end 
	           	self.Button.OnCursorEntered = function() self.ToColor = 0 self.Coloring = true end
	            self.Button.OnCursorExited = function() self.ToColor = 25 self.Coloring = true end

			   self.NameBut = self:Add( "DLabel" )
			   self.NameBut:SetPos( 95, 2 )
			   self.NameBut:SetText("")
			   self.NameBut.text =  "Loading"
			   self.NameBut:SetSize( 300, 32 )
			   self.NameBut:SetFont("dScoreBoard_Big")
			   self.NameBut.Updatesss = function(x,y,n,c)
				self.NameBut.text = n 
				self.NameBut.xs = x
				self.NameBut.ys = y
				self.NameBut.c = c
			   end
			   self.NameBut.Paint = function(self) 
				  draw.RoundedBoxEx(8,0, 0, self.xs ,self.ys, Color(20,20,20,200),false,false,false,true)	
				  draw.SimpleText( self.text, "dScoreBoard_Big", 4,5, self.c,TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
			   end
				
				self.GroupBut = self:Add( "DLabel" )
				self.GroupBut:SetPos( 95, 33 )
				self.GroupBut:SetText("")
				self.GroupBut.text = "Loading"
				self.GroupBut:SetSize( 300, 32 )
				self.GroupBut:SetFont("dScoreBoard_Big")
				self.GroupBut.Updatessss = function(x,y,n,c)
				 self.GroupBut.text = n 
				 self.GroupBut.xs = x
				 self.GroupBut.ys = y
				 self.GroupBut.c = c
				end
				self.GroupBut.Paint = function(self) 
					if not self.xs then return end
				  draw.RoundedBoxEx(8,0, 1, self.xs ,self.ys, Color(20,20,20,200),false,false,true,true)	
				  draw.SimpleText( self.text, "dScoreBoard_Big", 4,5, self.c,TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
				end
				
				self.SomeLine = self:Add( "DShape" )
				self.SomeLine:SetType( "Rect" )
				self.SomeLine:SetPos( 92, 36 )
				self.SomeLine:SetColor( Color( 255, 255, 255, 200 ) )
				self.SomeLine:SetSize( 50, 2 )
				
				self.AvatarButton = self.fixed:Add( "DButton" )
				self.AvatarButton:Dock(LEFT)
				self.AvatarButton:DockMargin( 3, 2, 0, 0 )
				--self.AvatarButton:DockPadding( 0, 1, 1,1 )
	            --self.AvatarButton:SetPos( 1, 1 )

				self.AvatarButton:SetSize( 82, 78 )
	            self.AvatarButton.DoClick = function() self.Player:ShowProfile() end
	            self.AvatarButton.Paint = nil
	           
	            self.Avatar = self.AvatarButton:Add( "AvatarImage" )
	            self.Avatar:SetMouseInputEnabled( false )
				self.Avatar:SetSize( 76, 76 )  
				self.Avatar:Dock(RIGHT)

				--wire_expression2_soundurl_block
				--немного асинхроности
	timer.Simple(0.5,function() 
				
				self.PingEvent = self:Add( "DLabel" )
				self.PingEvent:SetPos( 10, 85 )
				self.PingEvent:SetSize( 100, 20 )
				self.PingEvent:SetText("")
				self.PingEvent.Ping = self.Ping
				self.PingEvent.Paint = function( self )
					for i = 1, 4 do
						local color = Color(255,255,255,200)
						if self.Ping > 250-i*50 then
							color = Color(180,180,180,200)
						end
						draw.RoundedBox(0, i*4, (4-i)*5, 3, i*5, color)
					end
					draw.SimpleText( "Ping: "..self.Ping, "dScoreBoard_Normal", 25,3, self.c,TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
				end
				
				self.TimeEvent = self:Add( "DLabel" )
				self.TimeEvent:SetPos( 85, 85 )
				self.TimeEvent:SetSize( 180, 20 )
				self.TimeEvent:SetText("")
				self.TimeEvent.TimeS = self.TimeS
				self.TimeEvent.Paint = function( self )
					draw.SimpleText( "⏲ "..self.TimeS, "dScoreBoard_Normal", 25,3, Color(255,255,255,200),TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
				end
				
				self.PropsEvent = self:Add( "DLabel" )
				self.PropsEvent:SetPos( 250, 85 )
				self.PropsEvent:SetSize( 150, 20 )
				self.PropsEvent:SetText("")
				self.PropsEvent.Props = self.Counts.Props
				self.PropsEvent.MaxProps = fuckvar("rep_sbox_maxprops")
				self.PropsEvent.Paint = function( self )
					draw.SimpleText( "Пропов "..self.Props.."/"..self.MaxProps, "dScoreBoard_Normal", 25,3, Color(255,255,255,200),TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
				end
				
				self.VehEvent = self:Add( "DLabel" )
				self.VehEvent:SetPos( 250, 105 )
				self.VehEvent:SetSize( 150, 20 )
				self.VehEvent:SetText("")
				self.VehEvent.Vehs = self.Counts.Vehicles
				self.VehEvent.MaxVehs = fuckvar("rep_sbox_maxvehicles")
				self.VehEvent.Paint = function( self )
					draw.SimpleText( "Машины "..self.Vehs.."/"..self.MaxVehs, "dScoreBoard_Normal", 25,3, Color(255,255,255,200),TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
				end
				
				self.E2Event = self:Add( "DLabel" )
				self.E2Event:SetPos( 250, 125 )
				self.E2Event:SetSize( 150, 20 )
				self.E2Event:SetText("")
				self.E2Event.E2 = self.Counts.E2
				self.E2Event.MaxE2 = fuckvar("rep_sbox_maxwire_expressions")
				self.E2Event.Paint = function( self )
					draw.SimpleText( "E2 "..self.E2.."/"..self.MaxE2, "dScoreBoard_Normal", 25,3, Color(255,255,255,200),TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
				end
				
				self.E2HoloEvent = self:Add( "DLabel" )
				self.E2HoloEvent:SetPos( 250, 145 )
				self.E2HoloEvent:SetSize( 150, 20 )
				self.E2HoloEvent:SetText("")
				self.E2HoloEvent.Holos = self.Counts.Holos
				self.E2HoloEvent.MaxHolos = 500
				self.E2HoloEvent.Paint = function( self )
					draw.SimpleText( "Холки "..self.Holos.."/"..self.MaxHolos, "dScoreBoard_Normal", 25,3, Color(255,255,255,200),TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
				end
				
				
				self.SidBtnEvent = self:Add( "DButton" )
				self.SidBtnEvent:SetPos( 10, 110 )
				self.SidBtnEvent:SetSize( 150, 20 )
				self.SidBtnEvent:SetText("")
				self.SidBtnEvent.SteamID = self.SteamID  
				self.SidBtnEvent.TeamColor = self.TeamColor  
				self.SidBtnEvent.Name = self.Name  
				self.SidBtnEvent.Paint = function( self )
					local color = Color(145,145,145,200)
					if self:IsHovered() then
						color = Color(170,170,170,200)
					end
					draw.RoundedBox(3, 0, 0, 62, 20, color)
					draw.SimpleText( "SteamID", "dScoreBoard_Normal", 4,4, self.c,TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
				end
				self.SidBtnEvent.DoClick = function( got )
					SetClipboardText( self.SteamID ) 
					chat.AddText(Color(0,0,0),"► ",Color(200,200,200),"SteamID игрока ",self.TeamColor,self.Name,Color(200,200,200)," скопирован в буфер обмена ",Color(25,25,25),self.SteamID)
				end
				
				self.SidBtnEvent = self:Add( "DButton" )
				self.SidBtnEvent:SetPos( 75, 110 )
				self.SidBtnEvent:SetSize( 150, 20 )
				self.SidBtnEvent:SetText("")
				self.SidBtnEvent.SteamID = self.SteamID  
				self.SidBtnEvent.TeamColor = self.TeamColor  
				self.SidBtnEvent.Name = self.Name  
				self.SidBtnEvent.Paint = function( self )
					local color = Color(145,145,145,200)
					if self:IsHovered() then
						color = Color(170,170,170,200)
					end
					draw.RoundedBox(3, 0, 0, 77, 20, color)
					draw.SimpleText( "SteamID64", "dScoreBoard_Normal", 4,4, self.c,TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
				end
				self.SidBtnEvent.DoClick = function( got )
					SetClipboardText( self.SteamID64 ) 
					chat.AddText(Color(0,0,0),"► ",Color(200,200,200),"SteamID64 игрока ",self.TeamColor,self.Name,Color(200,200,200)," скопирован в буфер обмена ",Color(25,25,25),self.SteamID)
				end
				
				self.E2Ico = self:Add("Panel")
				self.E2Ico:SetSize( 32, 32 )
				self.E2Ico:SetPos( x * 540, 90 )
				local tx = surface.GetTextureID("expression 2/cog")
				self.E2Ico.Paint = function(pnl, x, y)
					surface.SetTexture(tx)
					local fn = e2Draws[self.e2s]
					if fn then fn(x,y) end
				end
				
				self.SFIco = self:Add("Panel")
				self.SFIco:SetSize( 32, 32 )
				self.SFIco:SetPos( x * 540, 130 )
				local tx2 = surface.GetTextureID("radon/starfall2.png")
				self.SFIco.Paint = function(pnl, x, y)
					surface.SetTexture(tx2)
					local fn = sfDraws[self.sfs]
					if fn then fn(x,y) end
				end
				self.loaIco = self:Add("Panel")
				self.loaIco:SetSize( 32, 32 )
				self.loaIco:SetPos( x * 500, 130 )
				local tx3 = surface.GetTextureID("editor/lua_run.png")
				self.loaIco.Paint = function(pnl, x, y)
					surface.SetTexture(tx3)
					local fn = loaDraws[self.los]
					if fn then fn(x,y) end
				end
				--self.E2Ico:SetImage( "expression 2/cog" )
				--self.E2Ico:SetColor(Color(255, 25, 25, 255))
				--self.E2Ico:SetTooltip("Есть доступ к E2P")
				
				if self.IsLocalPlayer then return end
				--[[
				if self.IsAdmin then
					self.SidBtnEvent = self:Add( "DButton" )
					self.SidBtnEvent:SetPos( 10, 100 )
					self.SidBtnEvent:SetSize( 150, 20 )
					self.SidBtnEvent:SetText("")
					self.SidBtnEvent.SteamID = self.SteamID  
					self.SidBtnEvent.TeamColor = self.TeamColor  
					self.SidBtnEvent.Name = self.Name  
					self.SidBtnEvent.Paint = function( self )
						local color = Color(145,145,145,200)
						if self:IsHovered() then
							color = Color(170,170,170,200)
						end
						draw.RoundedBox(3, 0, 0, 40, 20, color)
						draw.SimpleText( "Goto", "dScoreBoard_Normal", 4,4, self.c,TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
					end
					self.SidBtnEvent.DoClick = function( got )
						LocalPlayer():ConCommand( "ulx goto \""..self.Name.."\"" )
					end
					self.SidBtnEvent = self:Add( "DButton" )
					self.SidBtnEvent:SetPos( 53, 100 )
					self.SidBtnEvent:SetSize( 150, 20 )
					self.SidBtnEvent:SetText("")
					self.SidBtnEvent.SteamID = self.SteamID  
					self.SidBtnEvent.TeamColor = self.TeamColor  
					self.SidBtnEvent.Name = self.Name  
					self.SidBtnEvent.Paint = function( self )
						local color = Color(145,145,145,200)
						if self:IsHovered() then
							color = Color(170,170,170,200)
						end
						draw.RoundedBox(3, 0, 0, 50, 20, color)
						draw.SimpleText( "Bring", "dScoreBoard_Normal", 4,4, self.c,TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
					end
					self.SidBtnEvent.DoClick = function( got )
						LocalPlayer():ConCommand( "ulx bring \""..self.Name.."\"" )
					end
				end
				self.SidBtnEvent = self:Add( "DButton" )
				self.SidBtnEvent:SetPos( 10, 110 )
				self.SidBtnEvent:SetSize( 150, 20 )
				self.SidBtnEvent:SetText("")
				self.SidBtnEvent.SteamID = self.SteamID  
				self.SidBtnEvent.TeamColor = self.TeamColor  
				self.SidBtnEvent.Name = self.Name  
				self.SidBtnEvent.Paint = nil

				self.SidButton = self.SidBtnEvent:Add( "DLabel" )
				self.SidButton:Dock(FILL)
 
				self.SidButton:SetText( self.SteamID  )
				self.SidButton:SetFont("dScoreBoard_Normal")
		

				self.SidBtnEvent.DoClick = function(self)
					SetClipboardText( self.SteamID ) 
					chat.AddText(Color(0,0,0),"► ",Color(200,200,200),"SteamID игрока",self.TeamColor,self.Name,Color(200,200,200),"скопирован в буфер обмена ",Color(25,25,25),self.SteamID)
				end

				self.SidBtnEvent = self:Add( "DButton" )
				self.SidBtnEvent:SetPos( 10, 130 )
				self.SidBtnEvent:SetSize( 150, 20 )
				self.SidBtnEvent:SetText("")
				self.SidBtnEvent.SteamID = self.SteamID  
				self.SidBtnEvent.TeamColor = self.TeamColor  
				self.SidBtnEvent.Name = self.Name  
				self.SidBtnEvent.Paint = nil

				self.SidButton = self.SidBtnEvent:Add( "DLabel" )
				self.SidButton:Dock(FILL)
 
				self.SidButton:SetText( "Entity ID: "..self.Player:EntIndex()  )
				self.SidButton:SetFont("dScoreBoard_Normal")

				self.SidBtnEvent.DoClick = function()
					SetClipboardText( self.Player:EntIndex() ) 
					chat.AddText(Color(0,0,0),"► ",Color(200,200,200),"Че сложно цыферки ввести? ну ок. ID скопирован в буфер.")
				end]]
				

				self.Mute = self:Add( "DImageButton" )
	            self.Mute:SetSize( 32, 32 )
	            --self.Mute:SetPos( x * 525, 84 )
				self.Mute:SetPos( x * 12, 160 )
	            self.Mute:SetImage( "icon32/unmuted.png" )
				self.Mute:SetTooltip( "Отключить микрофон игрока." )
				
				self.Muted = self.Player:IsMuted()
				if(not self.Muted) then
					self.Mute.Paint = function( s, w, h )
						local sc = math.ceil(self.Player:GetVoiceVolumeScale()*32)
						draw.RoundedBox( 0, 0, 0, 32, 32-sc, Color(150,0,0,200))
						draw.RoundedBox( 0, 0, 32-sc, 32, sc, Color(0,0,0,200))
					end
				else
					self.Mute.Paint = function( s, w, h )
						draw.RoundedBox( 0, 0, 0, 32, 32, Color(150,0,0,255))
					end
				end
				self.Mute.PaintOver = function( s, w, h )
					local a = 255 - math.Clamp( CurTime() - ( s.LastTick or 0 ), 0, 3 ) * 255
					if ( a <= 0 ) then return end
					
					draw.RoundedBox( 4, 0, 0, w, h, Color( 0, 0, 0, a * 0.6 ) )
					draw.SimpleText( math.ceil( self.Player:GetVoiceVolumeScale() * 100 ) .. "%", "DermaDefaultBold", w / 2, h / 2, Color( 255, 255, 255, a ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
				end
				
				self.Mute.OnMouseWheeled = function( s, delta )
					--if self.Muted then return end
					self.Player:SetVoiceVolumeScale( math.Clamp( self.Player:GetVoiceVolumeScale() + ( delta / 100 * 5 ), 0, 1) )
					s.LastTick = CurTime()
					return true
				end
				
				self.Mute.DoClick = function( mute )
						self.Muted = not self.Muted
						self.Player:SetMuted( self.Muted )
						mute:SetImage( "icon32/" .. ( not self.Muted and "un" or "" ) .. "muted.png" )
						surface.PlaySound( "buttons/button" .. ( self.Muted and 1 or 9 ) .. ".wav" )
						
					if(not self.Muted) then
						self.Mute.Paint = function( s, w, h )
							local sc = math.ceil(self.Player:GetVoiceVolumeScale()*32)
							draw.RoundedBox( 0, 0, 0, 32, 32-sc, Color(150,0,0,200))
							draw.RoundedBox( 0, 0, 32-sc, 32, sc, Color(0,0,0,200))
						end
					else
						self.Mute.Paint = function( self, w, h )
							draw.RoundedBox( 0, 0, 0, 32, 32, Color(150,0,0,255))
						end
					end
				end
				

				--[[self.HoloDisable = self:Add( "DImageButton" )
				self.HoloDisable:SetSize( 32, 32 )
				self.HoloDisable:SetPos( x * 525, 120 )
				self.HoloDisable:SetImage( "icon16/database.png" )
				self.HoloDisable:SetTooltip( "Отключить холки игрока." )
				self.HoloDisable.Paint = function( self, w, h )
					draw.RoundedBox( 0, 0, 0, 32, 32, Color(0,0,0,200))
				end
			
				self.HoloDisable.DoClick = function( HoloDisabled )
					self.HoloDisabled = not self.HoloDisabled
					HoloDisabled:SetImage( "icon16/" .. ( not self.HoloDisabled and "database.png" or "database_delete.png" ))
					surface.PlaySound( "buttons/button" .. ( self.HoloDisabled and 1 or 9 ) .. ".wav" )
					RunConsoleCommand("wire_holograms_"..(self.HoloDisabled and "block" or "unblock").."_client",self.Player:Name())
					chat.AddText(Color(0,0,0),"► ",Color(200,200,200),"Голограммы игрока",team.GetColor(self.Player:Team()),self.Player:Name(),Color(200,200,200),"были",!self.HoloDisabled and Color(50,200,50) or Color(200,50,50), !self.HoloDisabled and "включены" or "отключены" )
				if(not self.HoloDisabled) then
					self.HoloDisable.Paint = function( self, w, h )
						draw.RoundedBox( 0, 0, 0, 32, 32, Color(0,0,0,200))
					end
				else
					self.HoloDisable.Paint = function( self, w, h )
						draw.RoundedBox( 0, 0, 0, 32, 32, Color(150,0,0,255))
					end
				end

			end
			
			self.BlockUrl = self:Add( "DImageButton" )
			self.BlockUrl:SetSize( 32, 32 )
			self.BlockUrl:SetPos( x * 525, 156 )
			self.BlockUrl:SetImage( "icon16/link.png" )
			self.BlockUrl:SetTooltip( "Отключить sound URL." )
			self.BlockUrl.Paint = function( self, w, h )
				draw.RoundedBox( 0, 0, 0, 32, 32, Color(0,0,0,200))
			end
			self.BlockUrl.DoClick = function( mute )
				self.Block = not self.Block
				self.Player.BlockUrl = self.Block
				mute:SetImage( "icon16/link" .. ( not self.Block and "" or "_break" ) .. ".png" )
				surface.PlaySound( "buttons/button" .. ( self.Block and 1 or 9 ) .. ".wav" )
				chat.AddText(Color(0,0,0),"► ",Color(200,200,200),"Возможность проигрывать URL звуки у игрока",team.GetColor(self.Player:Team()),self.Player:Name(),Color(200,200,200),"были",!self.Block and Color(50,200,50) or Color(200,50,50), !self.Block and "включены" or "отключены" )

			if(not self.Block) then
				self.BlockUrl.Paint = function( self, w, h )
					draw.RoundedBox( 0, 0, 0, 32, 32, Color(0,0,0,200))
				end
			else
				local expression2 = ents.FindByClass("gmod_wire_expression2")
				for k,v in pairs(expression2) do
					local gay = v:CPPIGetOwner()
					if ( gay.BlockUrl ) then
						EndStream(v)
					end
				end
				self.BlockUrl.Paint = function( self, w, h )
					draw.RoundedBox( 0, 0, 0, 32, 32, Color(150,0,0,255))
				end
			end
			end
			--]]
			--[[if(LocalPlayer():GetUserGroup() != "superadmin") then return end
			
			self.Goto = self:Add( "DImageButton" )
			self.Goto:SetSize( 32, 32 )
			self.Goto:SetPos( x * 525 - 36, 84 )
			self.Goto:SetImage( "icon16/control_fastforward_blue.png" )
			self.Goto:SetTooltip( "Goto к игроку." )
			self.Goto.Paint = function( self, w, h )
				draw.RoundedBox( 0, 0, 0, 42, 42, Color(0,0,0,200))
			end
			self.Goto.DoClick = function( got )
				LocalPlayer():ConCommand( "ulx goto \""..self.Name.."\"" )
			end
			
			self.Bring = self:Add( "DImageButton" )
			self.Bring:SetSize( 32, 32 )
			self.Bring:SetPos( x * 525 - 36, 120 )
			self.Bring:SetImage( "icon16/control_rewind_blue.png" )
			self.Bring:SetTooltip( "Bring игрока к себе." )
			self.Bring.Paint = function( self, w, h )
				draw.RoundedBox( 0, 0, 0, 42, 42, Color(0,0,0,200))
			end
			self.Bring.DoClick = function( got )
				LocalPlayer():ConCommand( "ulx bring \""..self.Name.."\"" )
			end
			--]]
			
	end)	

	        end,
	 
	  
		Update = function( self )
				

					local ply = self.Player
					if not IsValid(ply) then return end
                    local ply_team = ply:Team()
				
					self.Counts =
					{
						E2          = ply:GetCount( "wire_expressions" ),
						Props       = ply:GetCount( "props" ),
						Vehicles    = ply:GetCount( "vehicles" ),
						Holos       = CountHolos(ply)
					}
					
					self.Name = ply:Name()
					--self.Rname = ply:GetNWString('RNamed')
					self.Team = team.GetName(ply_team)
					self.TeamColor = team.GetColor(ply_team)	 
					self.TeamName = team.GetName(ply_team)
					self.GroupName = ply:GetUserGroup()
					self:SetZPos( ply_team )
					local me = LocalPlayer()
					self.Health = ply:Health()
					self.IsLocalPlayer = ply == me
					self.IsAdmin = me:CheckGroup("helper")
					
					--self.Frags = ply:Frags()
					--self.Deaths = ply:Deaths()
					self.Ping =  ply:Ping()
					self.god = ply:GetNWBool("ULXHasGod")
					self.build = ply:GetNWBool("buildmode")
					--self.Calor =  self.god==true and Color(50,0,50,150) or self.build==1 and Color(0,50,0,150) or Color(50,50,50,200)
					self.Rejim =  self.god and "GodMode" or self.build==1 and "Build" or ""
					--v pizdu
					self.RejimC =  self.god and Color(255,191,0,255) or self.build and Color(191,0,255,255) or not ply:Alive() and Color(125,125,125,255) or Color(255,255,255,255)
					self.TimeS = timeToStr( ply:GetUTimeTotalTime() )
					
					self.e2s = ply:GetNWInt("e2")
					if self.E2Ico then
						local name = e2Names[self.e2s]
						local adm = ply:GetNWString("e2admin")
						if name then
							self.E2Ico:SetTooltip(name .. "\n" .. (adm and "Выдан " .. adm or ""))
						end
					end
					self.sfs = ply:GetNWInt("sf")
					if self.SFIco then
						local name = sfNames[self.sfs]
						local adm = ply:GetNWString("sfadmin")
						if name then
							self.SFIco:SetTooltip(name .. "\n" .. (adm and "Выдан " .. adm or ""))
						end
					end
					self.los = ply:GetNWInt("LuaEditorAccess")
					if self.loaIco then

						self.loaIco:SetTooltip("loa")

					end
				--	self.zalupas =  ply:GetNWInt("Suka")
					--self.Name =  self.zalupas and ply:Name() or ply:Name() .. " ["..self.Player:GetNWInt("Tamer").." сек] "


					self.Emblem.Updatess(self,ply,RejimC)
					
					self.NameSize = (function() 
						surface.SetFont( "dScoreBoard_Big" ) 
						local x,y = surface.GetTextSize(self.Name) 
						self.NameBut.Updatesss(x+10,y+10,self.Name,self.RejimC) 
						return {x+10,y+10} 
					end)()
					
					surface.SetFont( "dScoreBoard_Big" ) 
					local x,y = surface.GetTextSize(self.TeamName) 
					self.GroupBut.Updatessss(x+10,y+10,self.TeamName,self.TeamColor) 
					self.SomeLine:SetSize(x+13, 2)
					
					if self.PingEvent then
						self.PingEvent.Ping = self.Ping
					end
					if self.TimeEvent then
						self.TimeEvent.TimeS = self.TimeS
					end
					if self.PropsEvent then
						self.PropsEvent.Props = self.Counts.Props
					end
					if self.VehEvent then
						self.VehEvent.Vehs = self.Counts.Vehicles
					end
					if self.E2HoloEvent then
						self.E2HoloEvent.Holos = self.Counts.Holos
					end
					if self.E2Event then
						self.E2Event.E2 = self.Counts.E2
					end
					
					
					--self.TotalTime = sec2str( ply:GetUTimeTotalTime() )
				    -- self.SessionTime = sec2str( ply:GetUTimeSessionTime() )
		
					--self.Hours = math.floor( ply:GetUTimeTotalTime() / 3600 )
					--self.Entitys = self.Counts.E2 + self.Counts.Props + self.Counts.Vehicles

	    end,  
	        Paint = function( self, w, h )
				surface.SetDrawColor( Color(100,100,100,200) )
			  
				surface.DrawOutlinedRect( 1, 1, w - 2, h - 2 )	
	       
	            draw.RoundedBox( 0, 2, 2, w - 4, 76, Color(50,50,50,200) )		
	            draw.RoundedBox( 0, 1, 1, 4, h-2, Color(self.TeamColor.r,self.TeamColor.g,self.TeamColor.b,OverAlpha) )
	        
			--	local Size = self.NameSize
			--	local xs,ys = Size[1] , Size[2]
				
	            

				-- draw.SimpleText( self.Ping,     "ScoreBoard_Small", x * 500, 20, Color( 230, 230, 230 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
			   
				if self.Open or self.Moving then
					draw.RoundedBox( 0, 5, 78, w - 4, h - 80, Color(50,50,50,200) )
					--draw.RoundedBox( 0, 1, 79, w - 3,1, Color(self.TeamColor.r,self.TeamColor.g,self.TeamColor.b,255))
					--draw.RoundedBox( 0, x * 50, 84, xs ,ys+5, Color( 25, 25, 25 , 150 ))	
					--draw.SimpleText( self.Name,     "dScoreBoard_Big", x * 52, 80+20, Color( 230, 230, 230 ),  TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
					--draw.SimpleText( self.Team,     "dScoreBoard_Big", x * 50, 80+50, self.TeamColor , TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
					--draw.SimpleText( self.Rejim ,     "dScoreBoard_Big", x * 50, 80+70, Color(255,255,255) , TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
				
				
					--draw.RoundedBox( 7, (x * 280)-5, 92.5, e2s*Counts.E2, 15, Color( 255, 255-Counts.E2*63, 255-Counts.E2*63,Counts.E2*63 ) )
					--draw.SimpleText( "кнопка" ,     "ScoreBoard_Small", x * 10, 60, Color( 0, 255, 255 ),  TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
					--draw.SimpleText( "Профиль " ,       "ScoreBoard_Small", x * 10, 80, Color( 0, 255, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
					--draw.SimpleText( "EID: " .. self.Index,       "ScoreBoard_Small", x * 10, 100, Color( 0, 255, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
					--draw.SimpleText( "Garry's Mod: "    .. self.GameTame,    "ScoreBoard_Small", x * 150,  100, Ololo2, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
		   
					--draw.SimpleText( "Prop: "       .. Counts.Props,    "ScoreBoard_Small", x * 280, 60, Color( 0, 255, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
					--draw.SimpleText( "Vehicle: "     .. Counts.Vehicles, "ScoreBoard_Small", x * 280, 80, Color( 0, 255, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
					--draw.SimpleText( "E2: " .. Counts.E2,   "ScoreBoard_Small", x * 280, 100, Color( 255, 255,255 ),  TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
				
				end
	 
	        end,
	 
	       
	 
	        Think = function( self )
	            if IsValid( self.Player ) then
	               -- self.Rating = self.Player:GetNWInt( "dScoreBoard_Rating", 0 )
	            else
					self.ToHeight = 0
					--self.ToWidthg = 0 
					self.Moving = true

					--self.IKS = 10
					--self.toIKS = 600
	            end
	 
	            if self.Coloring then
	                self.Color = math.Approach( self.Color, self.ToColor, ( math.abs( self.Color - self.ToColor ) + 0.5 ) * 10 * FrameTime() )
	                if self.Color == self.ToColor then self.Coloring = false end
	            end
	 
	            if self.Moving then
					self.Height = math.Approach( self.Height, self.ToHeight, ( math.abs( self.Height - self.ToHeight ) + 0.5 ) * 10 * FrameTime() )  
					self:SetHeight( self.Height )

					--self.Widthg = math.Approach( self.Widthg, self.ToWidthg, ( math.abs( self.Widthg - self.ToWidthg ) + 0.5 ) * 10 * FrameTime() )  
					--self:SetWidth(self.Widthg+100)
					--print(self.ToWidthg ,self.Widthg)

					if self.Height == self.ToHeight then if self.ToHeight == 0 then  self:Remove() else self.Moving = false end end
	            end
	 
	        end,
		
	        Setup = function( self, ply )
	          --  self.Avatar:SetPlayer( ply, 32 )
	          --	if LocalPlayer() == ply or ply:SteamID() == 'STEAM_0:1:59480590' then self.Mute:Remove() end
			  	self.Avatar:SetPlayer( ply, 78 )
	            self.SteamID = ply:SteamID() ~= "NULL" and ply:SteamID() or "<BOT>"
	            self.SteamID64 = ply:SteamID64() or "<BOT>"
	            self.Index = ply:EntIndex()
				
				--[[local maxprops = GetConVar("rep_sbox_maxprops")
				local maxvehicles = GetConVar("rep_sbox_maxvehicles")
				local maxe2s = GetConVar("rep_sbox_maxwire_expressions")
				
				self.MaxCounts = {
					Props  = maxprops and maxprops:GetInt() or 0,
					Vehicles  = maxvehicles and maxvehicles:GetInt() or 0,
					E2 = maxe2s and maxe2s:GetInt() or 0,
				}]]
	           
	            self.Player = ply
	            self:Update()
	 
	        end,
	 
	        Toggle = function( self )
	 
	            self.Open = not self.Open
				self.ToHeight = self.Open and 200 or 80
				--self.ToWidthg = self.Open and 580 or 480
	            self.Moving = true
	            surface.PlaySound( "garrysmod/content_downloaded.wav" )
	 
	        end
	 
	    }, "DPanel" )
	 
	    Panel = vgui.RegisterTable(
	    {
	        Init = function( self )
	 

				local x,y = GetXY()
				x=x*600
				y=y*400


				

	            self:SetSize( x-7, y)
	            self:SetPos(-ScrW(),y)
				self.Moving = false
				self.IKS = 0
				self.IKSIter = -ScrW()*2
				self.toIKS =  1 
				self.consttoIKS = ScrW()/2 - x*1.1
				self.xt = x
				self.yt =ScrH()/2 - y/2
				


		   

	            
	           
			   
			--gui.OpenURL( "http://examplepage.com/buy/" )   
			   
	            self.Scores = self:Add( "DScrollPanel" )
	            self.Scores:DockMargin( 6, 6, -60, 6 )
	            self.Scores:Dock( FILL )
	 
	            self.Scores:GetVBar().Paint = nil
	 
	            local Up = self.Scores:GetVBar().btnUp
	            Up.Paint = nil

	 
	            local Down = self.Scores:GetVBar().btnDown 
	            Down.Paint = nil

	 
	            local Grip = self.Scores:GetVBar().btnGrip 
	            Grip.Paint = nil
	 
	            self.UpdateTime = 1
	 
	        end,--123
	 
	        Paint = function( self, w, h )
	        	// draw.RoundedBox( 10, 0, 0, w, h, Color( 25, 25, 25, 200 ) ) -- мы зог пишем крива       
       end,
	 
	
	 
	        Update = function( self )
	
	
	            self.Host = GetHostName()
	            self.Count = #player.GetAll() .. " / " .. game.MaxPlayers()
				
	            for _, ply in pairs( player.GetAll() ) do
					--if ply:IsSuperAdmin() then continue end
	                if not IsValid( ply ) then continue end
	                if IsValid( ply.ScoreCard ) then ply.ScoreCard:Update() continue end
	                ply.ScoreCard = vgui.CreateFromTable( PlayerCard, ply.ScoreCard )
	 
	                ply.ScoreCard:Setup( ply )
	                self.Scores:Add( ply.ScoreCard )
	 
	            end
	 
	        end,
	 
			Close = function(self) 
				ScoreBoard.Moving = true
				ScoreBoard.toIKS = -ScrW()
				self.Popup:Remove()
			end,

			Open = function(self) 
				self.Popup = self:Add( "EditablePanel" )
				self.Popup.paint = nil
				self.Popup:MakePopup()
				ScoreBoard.Moving = true
				ScoreBoard.toIKS = ScoreBoard.consttoIKS
				ScoreBoard:Show()
			end,



	        Think = function( self )

				if self.Moving then
					self.IKS = math.Approach( self.IKS, self.toIKS, ( math.abs( self.toIKS - self.IKS  ) + 0.5 ) * 10 * FrameTime() )  
					self:SetPos(self.IKS,self.yt )

					if self.IKS == self.toIKS then 
						if self.toIKS == -ScrW() then 
							self:Hide() 
						else 
							self.Moving = false 
						end 
					end
	            end

	            if RealTime() - self.UpdateTime >= 2 then
	                self.UpdateTime = RealTime()
	                self:Update()
	            end
	  
	        end,
	 
	    }, "EditablePanel" )
	 

		


	end

local loadHistory = {}
local maxPoints = 100
local graphVisible = false
local anim = 0
local tickrate = 33
local lastCpuLoad = 0

net.Receive("ServerPerfData", function()
    local cpu = net.ReadFloat()
    tickrate = net.ReadFloat()

    lastCpuLoad = cpu
    table.insert(loadHistory, cpu / 100) 
    if #loadHistory > maxPoints then
        table.remove(loadHistory, 1)
    end
end)

local function GetTickrate()
    return math.floor(tickrate)
end

local function GetCpuLoad()
    return math.floor(lastCpuLoad)
end
local function init()
    local Moved = false

    hook.Add("ScoreboardShow", "dScoreboard_Show", function()
        if x ~= GetXY() then
            local s = GetXY()
            surface.CreateFont("ScoreBoard_Small",  { font = "Roboto Mono", size = 10, weight = 500, antialiasing = true })
            surface.CreateFont("dScoreBoard_Normal", { font = "Roboto Mono", size = 15, weight = 600, antialiasing = true })
            surface.CreateFont("dScoreBoard_Big",    { font = "Arial", size =  23, weight = 600, antialiasing = true })
            if IsValid(ScoreBoard) then ScoreBoard:Close() end
            Register()
        end
        if not IsValid(ScoreBoard) then ScoreBoard = vgui.CreateFromTable(Panel) end
        ScoreBoard:Open()

        graphVisible = true

        return true
    end)

    hook.Add("ScoreboardHide", "dScoreboard_Hide", function()
        if (IsValid(ScoreBoard)) then 
            ScoreBoard:Close()
        end

        graphVisible = false

        return true
    end)

    RunConsoleCommand("spawnmenu_reload")
end

hook.Add("HUDPaint", "DrawServerGraph", function()
    local w, h = 300, 120
    local x = ScrW() - w - 30
    local targetY = 50
    local hiddenY = -h - 50

    if graphVisible then
        anim = Lerp(0.1, anim, 1)
    else
        anim = Lerp(0.1, anim, 0)
    end
    local y = hiddenY + (targetY - hiddenY) * anim
    if anim < 0.01 then return end


	local strDisplayText = "ver"
	draw.RoundedBox(0, x + 114, y - 12, 75, 15, Color(0,0,0, 90))
    draw.SimpleText(strDisplayText, "Trebuchet18", x + w/2, y - 15, Color(255,255,255), TEXT_ALIGN_CENTER)
	return
end)


Ainitialized = Ainitialized or false

if Ainitialized then init() end

hook.Add("InitPostEntity", "InitScoreboard", function()
	Ainitialized = true
	init()
end )
