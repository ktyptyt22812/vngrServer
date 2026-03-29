RunConsoleCommand('say','UpdateFile')

util.AddNetworkString("BuildN")

local buildnotify = function(...)
local Ar = {...} 
	timer.Simple(0.1,function() 
	 	net.Start("BuildN")
	 	net.WriteTable(Ar)
	 	net.Broadcast()
	 end)
end

util.AddNetworkString("ded")

local DeadNotify = function(...)
local Ar = {...} 
	timer.Simple(0.1,function() 
	 	net.Start("ded")
	 	net.WriteTable(Ar)
	 	net.Broadcast()
	 end)
end



local buildnotifyOne = function(ply,...)
local Ar = {...} 
	timer.Simple(0.1,function() 
	 	net.Start("BuildN")
	 	net.WriteTable(Ar)
	 	net.Send(ply)
	 end)
end

local buildcommands = {
	['!b'] = 1,
	['!build'] = 1,
	['!и'] = 1,
	['!игшдв'] = 1,
	['!pvp'] = 1,
	['!змз'] = 1,
	['!з'] = 1,
	['!p'] = 1,
	['!И'] = 1,
	['!B'] = 1	
    }








for k,v in pairs(player.GetAll()) do
	v.buildTime = CurTime()
	v.Warns = 0
end

function buildweapons(ply) 
    ply:StripWeapons()
    for k,v in pairs(builderWeapons) do 
        ply:Give(k)
    end
end


hook.Add( "PlayerInitialSpawn", "CustomSpawn", function(ply) 
	ply.buildTime = 1
	ply.build = false
	ply.Warns = 0
end )


local function buildcommand(ply,text)

	if (  buildcommands[text] ) then
		if ply.buildTime == nil then ply.buildTime = CurTime()  end
		if ply.buildTime > CurTime() then  buildnotifyOne(ply,Color(0,0,0),"► ",Color(200,200,200)," Подождите ",Color(255,255,0),tostring(math.Round(ply.buildTime-CurTime())) ,Color(200,200,200)," секунд(ы) для перехода в",ply.build and Color(150,0,0) or Color(0,150,0), (ply.build and " PVP" or " BUILD")) return false  end
		ply.build = !ply.build

		if ply.build then
			buildweapons(ply)
			ply:SetNWInt("buildmode", 1) 
			ply:SetNWInt("OnGod",false)
			ply:GodEnable()
			ply:SetNoTarget(true)
		else
			ply:SetNWInt("buildmode", 0) 
			ply:SetNWInt("OnGod",false)
			ply:SetNoTarget(false)
			ply:GodDisable()
		end

		ply:EmitSound(ply.build and "buildon" or "buildoff")
		ply.buildTime = CurTime() + 30
		ply:SetMoveType(MOVETYPE_WALK)
                --akychLib.vk.vkAddMessage("[GB_Build]► "..ply:Name().." сменил режим на"..(ply.build and " BUILD" or " PVP"))
 		buildnotify(Color(0,0,0),"► ",team.GetColor(ply:Team()),ply:Name(),Color(200,200,200), " cменил режим игры на",ply.build and Color(0,150,0) or Color(150,0,0), (ply.build and " BUILD" or " PVP"))
		return false
	end
end
hook.Add("PlayerSay", "OnSay", buildcommand)




hook.Add( "PlayerDeath", "BuildDed", function( ply, wep, killer)--todo: сделать чтобы игроки в билде не могли убивать или дамажить игроков в пвп

	
	if !killer:IsPlayer() then killer = wep:CPPIGetOwner() end
	if ply == killer then return end
	if not ply.Warns then ply.Warns = 0 end
	if killer == nil then return end
	if killer.build then
		killer:Spawn()
		killer.Warns = killer.Warns + 1
		killer.build = !killer.build
		killer:SetNWInt("buildmode", 0) 
		killer:SetNWInt("OnGod",false)
		killer:GodDisable()
		killer:SetMoveType(MOVETYPE_WALK)
		killer.buildTime = CurTime() + 100 * killer.Warns
		buildnotify(Color(0,0,0),"► ",team.GetColor(killer:Team()),killer:Name(),Color(200,200,200), " Убил игрока в режиме билд за что имеет штраф в " ,Color(150,0,0),tostring(math.Round(killer.buildTime-CurTime())),Color(200,200,200)," секунд(ы).","\nИмеет ",Color(200,100,100),tostring(killer.Warns),Color(200,200,200),' нарушения.' )
		akychLib.vk.vkAddMessage("[GB_Warn]► "..killer:Name().." Убил "..ply:Name().." в режиме BUILD")
         return
	end

	if killer.ULXHasGod then 
		killer:Spawn()
		killer:SetPos(Vector(math.random(-1000,1000),math.random(-1000,1000),math.random(-1000,1000)))
		killer.Warns = killer.Warns + 1
		buildnotify(Color(0,0,0),"► ",team.GetColor(killer:Team()),killer:Name(),Color(200,200,200), " Убил игрока в режиме GOD за что был наказан на " ,Color(150,0,0),tostring(90 * killer.Warns),Color(200,200,200)," секунд(ы).","\nИмеет ",Color(200,100,100),tostring(killer.Warns),Color(200,200,200),' нарушения.')
		RunConsoleCommand('ulx','jail',killer:Name(),90 * killer.Warns )
		killer:GodDisable()
		killer:SetNWInt("OnGod",false)
		killer.ULXHasGod = false
                akychLib.vk.vkAddMessage("[GB_Warn]► "..killer:Name().." Убил "..ply:Name().." в режиме GOD")
	end

	if killer:GetMoveType() == MOVETYPE_NOCLIP and !killer:InVehicle() then 
		killer:Spawn()
		killer:SetPos(Vector(math.random(-1000,1000),math.random(-1000,1000),math.random(-1000,1000)))
		killer.Warns = killer.Warns + 1
                akychLib.vk.vkAddMessage("[GB_Warn]► "..killer:Name().." Убил "..ply:Name().." в режиме NOCLIP")
		buildnotify(Color(0,0,0),"► ",team.GetColor(killer:Team()),killer:Name(),Color(200,200,200), " Убил игрока в режиме NOCLIP за что был наказан на " ,Color(150,0,0),tostring(60 * killer.Warns),Color(200,200,200)," секунд(ы).","\nИмеет ",Color(200,100,100),tostring(killer.Warns),Color(200,200,200),' нарушения.')
		RunConsoleCommand('ulx','jail',killer:Name(),60 * killer.Warns )
		return
	end

end)



local Killreason = {
    'убил',
    'завалил',
    'анигилировал',
    'уничтожил',
    'ликвидировал',
}
local KillreasonCount = #Killreason


local Suichidereason = {
    'убился',
    'попрощался с жизнью',
    'сдох',
    'умер',
    'погиб',
}

local Suichidereasoncount = #Suichidereason


KillClasses = {}
KillClasses['prop_physics'] = {
    'раздавил',
    'сбил',
    'размазал',
    'задавил',
}

KillClasses['acf_gun'] = {
    'растрелял',
    'пробил',
    'из пушки убил',
    'обстрелял',
}

KillClasses['gmod_sent_vehicle_fphysics_base'] = {
    'задавил',
    'раздавил',
    'размазал',
    'задавил',
}




SuichideClasses = {}
SuichideClasses['worldspawn'] = {
    'разбился',
    'не отскочил',
    'теперь лепёха',
    'споткнулся',
}
SuichideClasses['trigger_hurt'] = {
    'утонул',
    'захлебнулся',
    'не выплыл из канализации',
    'пустил пузыри',
}



hook.Add( "PlayerDeath", "DeadNitify", function( ply, wep, killer)
		local clas = wep:GetClass()
		if killer != nil then 
			if killer:IsNPC() then
			DeadNotify(killer:GetClass().."["..killer:CPPIGetOwner():Name().."]" ,Killreason[math.random(1,KillreasonCount)],ply:Name())
			return
			end
		end

	if ply and killer:IsPlayer() and not KillClasses[clas] then
		if ply == killer then 
		DeadNotify(killer:Name(),Suichidereason[math.random(1,Suichidereasoncount)])
		return
		end
		DeadNotify(killer:Name(),Killreason[math.random(1,KillreasonCount)],ply:Name())
		return
	end


	if SuichideClasses[clas] then
		local txt = SuichideClasses[clas][math.random(1,4)]
		DeadNotify(ply:Name(),txt)
		return
	end
	if KillClasses[clas] then
		local a = wep:CPPIGetOwner()

		if ply == a then 
			DeadNotify(ply:Name(),Suichidereason[math.random(1,Suichidereasoncount)])
			return
		end
		local txt = KillClasses[clas][math.random(1,4)]
		DeadNotify(a:Name(),txt,ply:Name())
	end
end)





