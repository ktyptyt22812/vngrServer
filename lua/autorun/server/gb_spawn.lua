-- gb_spawn
-- Copyright (C) 2018-2026 ktypt, selyodka, akych

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
local function sendNotify( ply,str,notify )
	ply:SendLua(string.format("GAMEMODE:AddNotify('%s',%s, 10)",str,notify)) 
end


local Spawncommand = {
	['!s'] = 1,
	['!ы'] = 1,
	['!S'] = 1,
	['!Ы'] = 1,
	['!spawn'] = 1,	
	['!спавн'] = 1,
	['!rs'] = 2,
	['!кы'] = 2,
	['!rspawn'] = 2,	
	}


hook.Add( "PlayerInitialSpawn", "CustomSpawn", function(ply) 
	ply.CustomSpawnTime = CurTime()
	ply.CustomSpawnDieTime = CurTime()
	ply.HaveCustomSpawn = false
	ply.whiteList = false
end )





hook.Add( "PlayerDeath", "CustomSpawn", function( ply, _, _ )
	if ply.CustomSpawnDieTime == nil then ply.CustomSpawnDieTime = CurTime() end
		if (ply.CustomSpawnDieTime > CurTime())  then 
			ply.CustomSpawn = nil
			ply.HaveCustomSpawn = false
			ply:EmitSound( "gearbox/ui/pane_close.wav", 75, 100, 1, CHAN_AUTO ) 

			sendNotify(ply,"Вы потеряли спавн поинт","NOTIFY_ERROR")
			ply.CustomSpawnTime = CurTime()
			return 
		end
end)


hook.Add( "PlayerSay", "CustomSpawn", function( ply, text, team )
	if (  Spawncommand[text] == 1 ) then
		if ply.CustomSpawnTime == nil then ply.CustomSpawnTime = CurTime() end
		if(ply.CustomSpawnTime > CurTime()) then sendNotify(ply,"Вы сможете поставить спавн поинт через ".. math.Round(ply.CustomSpawnTime-CurTime(),1).." секунд(ы)","NOTIFY_HINT") return false end
		if !ply:Alive() then sendNotify(ply,"Вы мертвы","NOTIFY_ERROR") return false end
		local A = ply:GetPos()
		if !util.IsInWorld( A ) then sendNotify(ply,"Невозможно установить спавн поинт в текстурах","NOTIFY_ERROR") return false end
		if !ply:OnGround() then sendNotify(ply,"Невозможно установить спавн поинт над землей","NOTIFY_ERROR") return false end
	

		ply.HaveCustomSpawn = true
		ply.CustomSpawn = ply:GetPos()
		ply.CustomSpawnTime = CurTime() + 20
		ply:EmitSound( "gearbox/ui/pane_shift.wav", 75, 100, 1, CHAN_AUTO ) 
		sendNotify(ply,"Вы установили спавн поинт","NOTIFY_GENERIC")
		return false

	elseif(  Spawncommand[text] == 2 ) then
		if !ply.HaveCustomSpawn then sendNotify(ply,"У вас не установлен спавн поинт","NOTIFY_ERROR") return false end
		ply.HaveCustomSpawn = false
		ply.CustomSpawnTime = CurTime() + 10
		ply.CustomSpawn = nil
		ply:EmitSound( "gearbox/ui/pane_close.wav", 75, 100, 1, CHAN_AUTO ) 
		sendNotify(ply,"Спавн поинт удален","NOTIFY_GENERIC")
		return false
	end
end )

hook.Add( "PlayerSpawn", "CustomSpawn", function(ply) 
	if  !ply.HaveCustomSpawn then return end
	    ply.CustomSpawnDieTime = CurTime() + 2
		ply:SetPos(ply.CustomSpawn)
 end)








----------------------------------------------------------------------------



local buildnotify = function(...)
local Ar = {...} 
	timer.Simple(0.1,function() 
	 	net.Start("BuildN")
	 	net.WriteTable(Ar)
	 	net.Broadcast()
	 end)
end

local WhiteLsCOmmand = {
	['!w'] = 1,
	['!ц'] = 1,
	}

local NotAscessed = {
	[30] = 1,
	}


hook.Add( "PlayerSay", "WhiteList", function( ply, text ) 
	if (  WhiteLsCOmmand[text] == 1 ) then
		if NotAscessed[ply:Team()] != nil  then ply:SendLua("GAMEMODE:AddNotify(\"Вы не можете отключить систему антилага для себя.\",NOTIFY_GENERIC, 5)")  return end
		if ply.whiteList == nil then ply.whiteList = false end
			ply.whiteList = !ply.whiteList
			buildnotify(Color(0,0,0),"► ",team.GetColor(ply:Team()),ply:Name(),ply.whiteList and Color(200,255,200) or Color(255,200,200) , (ply.whiteList and " включил" or " отключил"),Color(200,200,200)," иммунитет к антилагу.")
	return false
	end
end)



akychLib = akychLib or {}
akychLib.suka = akychLib.suka or {}
local TAdministrate = {}

akychLib.suka.tpAdmin = function(ent)
	for k,v in pairs(TAdministrate) do
		if v.LastTp ==nil then v.LastTp = 1 end
		if v.LastTp < CurTime() then
			local E = ent:GetPos()
			v.LastTp = CurTime()+10
			local Rand = VectorRand(-100,100)
			v:SetPos(E+Vector(Rand.x,Rand.y,0) )
			v:SetEyeAngles((E-v:GetPos()):Angle())
		end
	end
end

local Cmdse = {
	['!a'] = 1,
	['!ф'] = 1,
	}

hook.Add( "PlayerSay", "Adminitrate", function( ply, text ) 
	if (  Cmdse[text] == 1 ) then
		if not ply:IsAdmin()  then ply:SendLua("GAMEMODE:AddNotify(\"Вы не админ..\",NOTIFY_GENERIC, 5)")  return end
		if ply.administrate== nil then ply.LastTp = CurTime() ply.administrate = false end
			ply.administrate = !ply.administrate
			local ID = ply:EntIndex()
			if ply.administrate then TAdministrate[ID] = ply else TAdministrate[ID] = nil end
			buildnotify(Color(0,0,0),"► ",team.GetColor(ply:Team()),ply:Name(),ply.administrate and Color(200,255,200) or Color(255,200,200) , (ply.administrate and " принял" or " сдал"),Color(200,200,200)," пост Админа.")
	return false
	end
end)


hook.Add( "PlayerDisconnected", "asdasdasd", function(ply) 
	local ID = ply:EntIndex()
	TAdministrate[ID] = nil
end )







local BL = {}
	BL["player_pickup"] = 1
	BL["func_conveyor"] = 1
	BL["info_particle_system"] = 1
	BL["ambient_generic"] = 1
	BL["predicted_viewmodel"] = 1
	BL["env_soundscape"] = 1
	BL["physgun_beam"] = 1
	BL["gmod_hands"] = 1
	BL["shadow_control"] = 1
	BL["func_illusionary"] = 1
	BL["trigger_push"] = 1
	BL["trigger_teleport"] = 1
	BL["env_tonemap_controller"] = 1
	BL["env_citadel_energy_core"] = 1
	BL["trigger_vphysics_motion"] = 1
	BL["trigger_physics_trap"] = 1
	BL["trigger_vphysics_motion"] = 1
	BL["env_sun"] = 1
	BL["env_fog_controller"] = 1
	BL["env_skypaint"] = 1
	BL["water_lod_control"] = 1
	BL["hl2mp_ragdoll"] = 1
	BL["info_player_start"] = 1
	BL["trigger_soundscape"] = 1
	BL["info_teleport_destination"] = 1
	BL["func_door_rotating"] = 1
	BL["manipulate_bone"] = 1
	BL["trigger_multiple"] = 1
	--Вайтлист ентитей которые спавн будет игнорировать

	sound.Add( {
	name = "dieprop",
	channel = CHAN_STATIC,
	volume = .5,
	level = 100,
	pitch = { 80,100, 125 },
	sound = {"gearbox/ui/crack.wav"}
} )
	 





local function Dissolove(ent)
		  					if not ent._dissdeny then
			  					ent:SetName(tostring(v))
			               		ent:EmitSound( "dieprop" )
				                local dis = ents.Create("env_entity_dissolver")
				                dis:SetEntity( "target", ent )
				                dis:SetPos(ent:GetPos())
				                dis:SetKeyValue("target", ent:GetName())
				                dis:SetKeyValue("magnitude", "10")
				                dis:SetKeyValue("dissolvetype", "3")
				                dis:Spawn()
				                dis:Fire("Dissolve", "", 0)
				                dis:Fire("kill", "", 0)
				            else
				            	ent:EmitSound( "dieprop" )
	  							ent:Remove()
				            end
end


local Vec = Vector(448,-10418,-8915) 
local Vec1 = Vector(2624, -7427, -8430) 

local DeletedPropes = {}
function SpawnRemove()
	for k,v in pairs(ents.FindInBox(Vec,Vec1)) do
		if !BL[v:GetClass()] then
	  		if not v:IsPlayer() and not v.toRM then
	  			if not timer.Exists("remove") then 
	  				timer.Create("remove",0.1,0,function()  
	  					local A = #DeletedPropes
	  					if(A <= 0) then timer.Remove( "remove" ) return end
	  					if(A > 50) then 
	  						for i = 1,1+(A*0.2) do
	  							local Propes = table.remove( DeletedPropes )
	  							if Propes:IsValid() then
	  								Dissolove(Propes)
	  							end
	  						end
	  					end
	  					local Propes = table.remove( DeletedPropes, 1 )
	  					if Propes:IsValid() then
	  							Dissolove(Propes)
				        else
				        	for k,v in pairs(DeletedPropes) do
				        		if not v:IsValid() then
				        			table.remove(DeletedPropes,k)
				        		end
				        	end
	  					end
	  				end) 
	  			end
	  			v.toRM = true
	  			table.insert(DeletedPropes,v)
			end
		end
	end
end



local function antidamagePly(ply)
	if !ply:IsValid() then return end
	if ply.build then return end
	if ply.HaveCustomSpawn then return end
	if ply.ULXHasGod then return end


		ply:GodEnable()
		ply:SendLua("GAMEMODE:AddNotify(\"На вас действует SpawnProtect\",NOTIFY_GENERIC, 7)") 
		timer.Create(ply:SteamID(),7,1,function() 
				ply:SendLua("GAMEMODE:AddNotify(\"На вас больше не действует SpawnProtect\",NOTIFY_ERROR, 3)") 
				if ply.build then return end
				if ply.HaveCustomSpawn then return end
				if ply.ULXHasGod then return end
				ply:GodDisable()

		end)



end



hook.Add( "PlayerSpawn", "some_unique_name", antidamagePly)
timer.Create("gayskiesu4ki",1,0,SpawnRemove)
--timer.Create("gayskiesu4ki1",0.2,0,SpawnRemove)

RunConsoleCommand('say',"updateFile")


