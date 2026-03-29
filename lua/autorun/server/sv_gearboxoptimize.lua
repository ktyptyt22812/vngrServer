RunConsoleCommand('say','UpdateFile')
Wl = {
["76561198079226909"] = true, -- Dloria
}
print("WL")
hook.Add("CheckPassword", "GayCheckPassword", function(SteamID64, IP, ServerPass, ClientPass, ClientName)
	if !Wl[SteamID64] then
	--akychLib.DSendMessage(ClientName.." \n"..SteamID64,"Доступ запрещен",Color(255,0,0))
	
	RunConsoleCommand('say',ClientName.." / "..SteamID64)
	
	return false, 'Тех работы'
    end
end)
timer.Simple(1,function() 
	hook.Remove("CheckPassword", "GayCheckPassword")
end)
local line = string.Explode( "\n",file.Read( "ulx/sbox_limits.txt" ,"DATA"))



timer.Simple(15,function() 
for k,v in pairs(line) do 
local data = string.Explode( " ", v ) --Split Convar name from max limit
if ConVarExists( data[1] ) then
	RunConsoleCommand(data[1],9999)
end
end
end)

RunConsoleCommand('wire_holograms_max',9999)
RunConsoleCommand('sbox_maxfin_2',9999)

local mks=function(name,path,lvl)path=path.."/"local tbl={}for k,v in pairs(file.Find("sound/"..path.."*","GAME")) do tbl[k]=path..v end sound.Add({name=name,channel=6,volume=1,level=lvl or 100,pitch=100,sound=tbl})end
mks("spawnSound","gearbox/cj/vo/spawn",65)
mks("DIE","gearbox/cj/painb",65)
mks("ouch","gearbox/cj/paina",65)
mks("randUI","gearbox/ui",65)
 
mks("buildon","gearbox/build/on",65)
mks("buildoff","gearbox/build/off",65)


mks("dance","gearbox/acts/dance",65)
mks("mdance","gearbox/acts/muscule",65)
mks("rdance","gearbox/acts/dance",65)

mks("salute","gearbox/acts/salute",65)
mks("bow","gearbox/acts/bow",65)
mks("becon","gearbox/acts/becon",65)
mks("laught","gearbox/acts/laught",65)
mks("pers","gearbox/acts/pers",65)
mks("cheer","gearbox/acts/cheer",65)

mks("agree","gearbox/acts/agree",65)
mks("disagree","gearbox/acts/disagree",65)
mks("zombie","gearbox/acts/zombie",65)
mks("forward","gearbox/acts/forward",65)
mks("fall","gearbox/cj/vo/fall",65)
mks("wave","gearbox/acts/wave",65)

mks("gay","gearbox/acts/hait",65)

--mks("jump","gearbox/wa/jump",65)



--mks("gay","gearbox/wa/kill",65)


--mks("DUCK_IN","gearbox/cj/+duck")
--mks("DUCK_OUT","gearbox/cj/-duck")


local T = {}

T[1642] = "dance"
T[1617] = "mdance"
T[1643] = "rdance"
T[1615] = "wave"
T[1614] = "salute"
T[1612] = "bow"
T[1611] = "becon"
T[1618] = "laught"
T[1616] = "pers"
T[1620] = "cheer"
T[1610] = "agree"
T[1613] = "disagree"
T[1641] = "zombie"
T[55] = "gay"
T[53] = "forward"
T[54] = "fall"

hook.Add("PlayerStartTaunt","ActSound",function(p,a,l) 

--RunConsoleCommand("say",p:Name().."  "..a)
if(p:Alive()) then
	if T[a] == nil then return end
	p:EmitSound( T[a] )
end
end)
--"##VAC_ConnectionRefusedDetail"

hook.Add("PlayerShouldTaunt","ActSound2",function(p,a) 
	p:StopSound( T[a] )
end)
hook.Remove("PlayerShouldTaunt","ActSound2")



hook.Add("GetFallDamage","AIBOLNO", function( ply, speed )
	ply:EmitSound("ouch")
end)




local lastSysCurrDiff = 9999
local function GetCurrentDelta()
	local SysCurrDiff = SysTime() - CurTime() -- current differential
	deltaSysCurrDiff = SysCurrDiff - lastSysCurrDiff -- change in differential since last check
	lastSysCurrDiff = SysCurrDiff
	return deltaSysCurrDiff
end
util.AddNetworkString( "Lag" )


local buildnotify = function(...)
local Ar = {...} 
	timer.Simple(0.1,function() 
	 	net.Start("BuildN")
	 	net.WriteTable(Ar)
	 	net.Broadcast()
	 end)
end

local blacklist = {
	["func_door"] = true,
	["func_button"] = true,
	["env_sprite"] = true

}

local function frezze()
	for k, v in pairs( ents.GetAll() ) do
		local phys = v:GetPhysicsObject()
		if (IsValid(phys)) then
			phys:EnableMotion(false)
		end
	end
end
 

local function frezzelist()
	for k, v in pairs( ents.GetAll() ) do
		local ply = v:CPPIGetOwner()
		if IsValid(ply) and ply.whiteList then return end
		local phys = v:GetPhysicsObject()
		if (IsValid(phys)) then
			phys:EnableMotion(false)
		end
	end
end



local function e2Stoplist()
	for k, v in pairs( ents.FindByClass( "gmod_wire_expression2" ) ) do
		local ply = v:CPPIGetOwner()
		if IsValid(ply) and ply.whiteList then return end
			v.error = true 
			v:PCallHook("destruct")
			v:ResetContext()
			v:PCallHook("construct")
	    end
end





local function e2Stop()
	for k, v in pairs( ents.FindByClass( "gmod_wire_expression2" ) ) do
			v.error = true 
			v:PCallHook("destruct")
			v:ResetContext()
			v:PCallHook("construct")
	    end
end


local function e2Stopram()
    
	for k, v in pairs( ents.FindByClass( "gmod_wire_expression2" ) ) do
		if not v.error then
			v.error = true 
			v:PCallHook("destruct")
			v:ResetContext()
			v:PCallHook("construct")
			v:Error( "Память перегружена все е2 остановлены." )
		end
	 end
end



 
local function stopStacked()
	ents.FindInSphere(center, bRadius)

	for _,v in next, ents.FindInSphere(this:LocalToWorld(this:OBBCenter()), this:BoundingRadius()) do end

	local center = ent:LocalToWorld(ent:OBBCenter())
	local bRadius = ent:BoundingRadius()

	buildnotify(Color(0,0,0),"► ",Color(200,200,200),"["..v:EntIndex().."]["..v:GetClass().."] ",team.GetColor(owner:Team()),owner:Name(),Color(200,200,200),string.format(" Замечено агрессивное сближение предметов(Количество %s). ",Count)	)		

end





local Loa= 0
local LoaMem = 0
local function ClearLuaMemory()
	local Loa = collectgarbage("count")
	MsgC("Текущая Loa сессия : ".. math.Round(Loa/1024).. " MB.")
	if Loa >= 31463 then
		collectgarbage("collect")
		local LoaMem = collectgarbage("count")
		local A = math.Round((Loa - LoaMem)/1024)
		buildnotify(Color(0,0,0),"► ",Color(200,200,200),"Удалено " ,Color(255,255,255),tostring(A),Color(200,200,200)," MB текущей Loa сессии.")
	end
end

local function destroued()
	RunConsoleCommand('gmod_admin_cleanup')
end
local function destrouedd()
	for k,v in pairs(player.GetAll()) do
		if not v.whiteList then 
			if not v:IsValid() then return end
			v:ConCommand( "gmod_cleanup" )
		end
	end
end

local LagLvlnakazanie =0
local Lag = {

[0] = function() 
	frezzelist()
	ClearLuaMemory()
	buildnotify(Color(0,0,0),"► ",Color(200,200,200),"Обнаружениы лаги ",Color(255,255,255),"0",Color(200,200,200)," все пропы заморожены.")
	end,

[1] = function() 
	frezzelist()
	ClearLuaMemory()
	buildnotify(Color(0,0,0),"► ",Color(200,200,200),"Обнаружениы лаги ",Color(0,255,0),"1",Color(200,200,200)," все пропы заморожены, время замедлилось на",Color(0,200,0)," 20%.")
        akychLib.vk.vkAddMessage("[GB_lag]► Сервер лагает [Easy]")
end,
[2] = function() 
	ClearLuaMemory()
	e2Stoplist()
	frezzelist()
	buildnotify(Color(0,0,0),"► ",Color(200,200,200),"Лаги небыли устранены ",Color(255,255,0),"2",Color(200,200,200)," все пропы заморожены, е2 остановлены, время замедлилось на",Color(200,200,0)," 40%.")
        akychLib.vk.vkAddMessage("[GB_lag]► Сервер лагает [Medium]")
	end,
[3] = function() 
	ClearLuaMemory()
	destrouedd()
	e2Stopram()
	frezze()
	buildnotify(Color(0,0,0),"► ",Color(200,200,200),"Лаги небыли устранены ",Color(255,0,0),"3",Color(200,200,200)," выборочный (CleanUP),все пропы заморожены, е2 остановлены, время замедлилось на",Color(200,0,0)," 60%.")
        akychLib.vk.vkAddMessage("[GB_lag]► Сервер лагает [Hard]")
	end,
[4] = function() 
	ClearLuaMemory()
	destroued()
	--timer.Remove("unlag")
	LagLvlnakazanie = 1
	game.SetTimeScale(1)
	buildnotify(Color(0,0,0),"► ",Color(200,200,200),"Кажись серв помирает ",Color(255,0,255)," 4  общий CleanUP")
    akychLib.vk.vkAddMessage("[GB_lag]► Сервер лагает [Ultra Hard]")
	end,
}


local Resol = {
	[0] = 0,
	[1] = 0.1,--0.25
	[2] = 0.37,--0.67
	[3] = 1.49,--1.49
	[4] = 1.73,
}

local Classes = {
	["prop_physics"] = true,
	["gmod_wire_wheel"] = true,
	["acf_ammo"] = true,
	["gmod_wheel"] = true,
}


local IndexFalse={
	[0] = true

}

util.AddNetworkString( "lages" )

function sendLags(number)
	net.Start("lages")
	net.WriteFloat(number)
	net.Broadcast()
end



akychLib = akychLib or {}
akychLib.suka = akychLib.suka or {}
akychLib.suka.lagforce = function ( vCorner1, vCorner2 )
	local tEntities = ents.FindInBox( vCorner1, vCorner2 )
	local tPlayers = {}
	local iPlayers = 0
	for i = 1, #tEntities do
		local P = tEntities[ i ]
		if ( Classes[ P:GetClass() ] ) and IndexFalse[P:GetCollisionGroup()] then
			iPlayers = iPlayers + 1
			tPlayers[ iPlayers ] = P
		end
	end
	return tPlayers,iPlayers
end

local function unlages() 
	timer.Create("unlag",4*LagLvlnakazanie,1,function() 
		if LagLvlnakazanie < 1 then return end
		LagLvlnakazanie = LagLvlnakazanie - 1 
		buildnotify(Color(0,0,0),"► ",Color(200,200,200),"Уровень лагов сброшен до ",Color(85*LagLvlnakazanie,(255/LagLvlnakazanie) or 255,0),""..LagLvlnakazanie)
		--RunConsoleCommand('say',LagLvlnakazanie..",|"..(1-(LagLvlnakazanie/5)))
		game.SetTimeScale(math.Clamp(1-(LagLvlnakazanie/5),0.4,1)) 
		if(LagLvlnakazanie>=1) then
			unlages() 
		end 
	end)
end

/*
timer.Create('1',1,1,function() 
	local LagLvl = GetCurrentDelta()-Resol[LagLvlnakazanie] or 0
	if(LagLvl > 0.50) then
		
		LagLvlnakazanie = LagLvlnakazanie + 1
		LagLvlnakazanie = math.Clamp(LagLvlnakazanie,0,4) 
		--if(LagLvlnakazanie >= 3) then LagLvlnakazanie = 3 else LagLvlnakazanie = LagLvlnakazanie%4  end
		--RunConsoleCommand('say',LagLvlnakazanie..",|"..(1-(LagLvlnakazanie/5)))
		game.SetTimeScale(math.Clamp(1-(LagLvlnakazanie/5),0.2,1)) 
		unlages()
		Lag[math.Clamp(LagLvlnakazanie,1,4)]()
	end
end)
*/

local Testos = CurTime()
hook.Add("Think","antelag",function() 
	if Testos < CurTime() then 
		local LagLvl = GetCurrentDelta()-Resol[LagLvlnakazanie] or 0
		Testos = CurTime()+0.3
		--RunConsoleCommand('say',LagLvl)
		if LagLvl > 5 then Lag[4]() sendLags(LagLvl) return end
		if(LagLvl > 0.5) then
			sendLags(LagLvl+LagLvlnakazanie)
			Testos = CurTime()+0.2+LagLvl/7
			LagLvlnakazanie = LagLvlnakazanie + 1
			LagLvlnakazanie = math.Clamp(LagLvlnakazanie,0,4) 
			game.SetTimeScale(math.Clamp(1-(LagLvlnakazanie/5),0.2,1)) 
			unlages()
			Lag[math.Clamp(LagLvlnakazanie,1,4)]()
		end
	end
end)

timer.Create('1',10,0,function()
	sendLags(GetCurrentDelta())
end)

hook.Add( "OnEntityCreated", "SoftEntList", function( ent )
			ent.crushTime = 0
			if ( !Classes[ ent:GetClass() ] ) then return end
			timer.Simple(0.1,function()  
			if ent == nil then return end
			if ent:CPPIGetOwner() == nil then return end
			if ent:CPPIGetOwner().whiteList then return end
			local maxs = ent:LocalToWorld(ent:OBBMaxs()*0.8)
			local mins = ent:LocalToWorld(ent:OBBMins()*0.8)
			local Arr,C = akychLib['suka']['lagforce'](maxs,mins)
				if C > 15 then 
					local owner = ent:CPPIGetOwner()
					if owner then
						akychLib.suka.tpAdmin(owner)
						buildnotify(Color(0,0,0),"► ",Color(200,200,200),"["..ent:EntIndex().."]["..ent:GetClass().."] ",team.GetColor(owner:Team()),owner:Name(),Color(200,200,200),string.format(" замечены ( %s ) стакнутые предметы. ",C))		
						for kk,vv in pairs(Arr) do
							vv:SetCollisionGroup( COLLISION_GROUP_DEBRIS )
							local phys = vv:GetPhysicsObject()
							if (IsValid(phys)) then
								phys:EnableMotion(false)
							end
						end
					end
				end
			end)
end )
function PlayerHit( ent, inflictor, attacker, amount, dmginfo )
		if IsEntity(ent)  then
			if inflictor:GetDamageType() == 1 then 
				timer.Create("_"..ent:EntIndex(),5,1,function() if ent then ent.crushTime = 0 end end)

				ent.crushTime = ent.crushTime + 0.1
				--RunConsoleCommand('say','Detect crashes..',ent.crushTime)
				if(ent.crushTime > 10) then
					if timer.Exists( "_"..ent:EntIndex() ) then  timer.Remove( "_"..ent:EntIndex()) end
					ent.crushTime = 0
						local owner = ent:CPPIGetOwner()
						akychLib.suka.tpAdmin(owner)
						buildnotify(Color(0,0,0),"► ",Color(200,200,200),"["..ent:EntIndex().."]["..ent:GetClass().."] ",team.GetColor(owner:Team()),owner:Name(),Color(200,200,200)," заморожен из-за большого количества столкновений")
						--ent:Remove()
						local phys = ent:GetPhysicsObject()
						if (IsValid(phys)) then
							phys:EnableMotion(false)
						end
				end
			end
		end
end
hook.Add( "EntityTakeDamage", "PlayerHit", PlayerHit )
timer.Simple(10,function() 
	hook.Add( "PlayerSpawnedSENT", "freeze", function(ply,ent) 
		timer.Simple(0,function() 
			if not IsValid(ent) then return end
			local phys = ent:GetPhysicsObject()
			if (IsValid(phys)) then
				phys:EnableMotion(false)
				ent:SetCollisionGroup( COLLISION_GROUP_DEBRIS )
			end
		end)
	end)
end)


timer.Simple(10,function() 
	hook.Add( "PlayerSpawnedSWEP", "freeze", function(ply,ent) 
		timer.Simple(0,function() 
			if not IsValid(ent) then return end
			local phys = ent:GetPhysicsObject()
			if (IsValid(phys)) then
				phys:EnableMotion(false)
				ent:SetCollisionGroup( COLLISION_GROUP_DEBRIS )
			end
		end)
	end)
end)




RunConsoleCommand('say','UpdateFile')