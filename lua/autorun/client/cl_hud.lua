local wep = {
	["gmod_tool"] = true,
	["weapon_physgun"] = true,	
	}



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