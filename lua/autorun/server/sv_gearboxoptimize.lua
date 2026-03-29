

local Wl = {
    ["76561198079226909"] = true, 
}

hook.Add("CheckPassword", "vngrCheckPassword", function(SteamID64, IP, ServerPass, ClientPass, ClientName)
    if not Wl[SteamID64] then
        RunConsoleCommand('say', ClientName .. " / " .. SteamID64)
        return false, 'Тех работы'
    end
end)

timer.Simple(1, function()
    hook.Remove("CheckPassword", "vngrCheckPassword")
end)


timer.Simple(15, function()
    local line = string.Explode("\n", file.Read("ulx/sbox_limits.txt", "DATA"))
    if not line then return end
    for _, v in ipairs(line) do
        local data = string.Explode(" ", v)
        if data[1] and ConVarExists(data[1]) then
            RunConsoleCommand(data[1], 9999)
        end
    end
end)

RunConsoleCommand('wire_holograms_max', 200)
RunConsoleCommand('sbox_maxfin_2', 9999)



hook.Add("GetFallDamage", "AIBOLNO", function(ply, speed)
    ply:EmitSound("ouch")
end)


local function buildnotify(...)
    local Ar = {...}
    timer.Simple(0.1, function()
        net.Start("BuildN")
        net.WriteTable(Ar)
        net.Broadcast()
    end)
end

local Classes = {
    ["prop_physics"]    = true,
    ["gmod_wire_wheel"] = true,
    ["acf_ammo"]        = true,
    ["gmod_wheel"]      = true,
}

local IndexFalse = {
    [0] = true,
}



local function frezze()
    for _, v in ipairs(ents.GetAll()) do
        local phys = v:GetPhysicsObject()
        if IsValid(phys) then
            phys:EnableMotion(false)
        end
    end
end

local function frezzelist()
    for _, v in ipairs(ents.GetAll()) do
        local ply = v:CPPIGetOwner()
        if IsValid(ply) and ply.whiteList then continue end
        local phys = v:GetPhysicsObject()
        if IsValid(phys) then
            phys:EnableMotion(false)
        end
    end
end

local function e2Stop()
    for _, v in ipairs(ents.FindByClass("gmod_wire_expression2")) do
        v.error = true
        v:PCallHook("destruct")
        v:ResetContext()
        v:PCallHook("construct")
    end
end

local function e2Stoplist()
    for _, v in ipairs(ents.FindByClass("gmod_wire_expression2")) do
        local ply = v:CPPIGetOwner()
        if IsValid(ply) and ply.whiteList then continue end
        v.error = true
        v:PCallHook("destruct")
        v:ResetContext()
        v:PCallHook("construct")
    end
end

local function e2Stopram()
    for _, v in ipairs(ents.FindByClass("gmod_wire_expression2")) do
        if not v.error then
            v.error = true
            v:PCallHook("destruct")
            v:ResetContext()
            v:PCallHook("construct")
            v:Error("Память перегружена, все E2 остановлены.")
        end
    end
end

local function ClearLuaMemory()
    local before = collectgarbage("count")
    MsgC(Color(200, 200, 200), "Текущая Lua сессия: " .. math.Round(before / 1024) .. " MB.\n")
    if before >= 31463 then
        collectgarbage("collect")
        local after = collectgarbage("count")
        local freed = math.Round((before - after) / 1024)
        buildnotify(
            Color(0, 0, 0),   "► ",
            Color(200, 200, 200), "Удалено ",
            Color(255, 255, 255), tostring(freed),
            Color(200, 200, 200), " MB текущей Lua сессии."
        )
    end
end
local function destroued()
    RunConsoleCommand('gmod_admin_cleanup')
end

local function destrouedd()
    for _, v in ipairs(player.GetAll()) do
        if not v.whiteList and IsValid(v) then
            v:ConCommand("gmod_cleanup")
        end
    end
end


util.AddNetworkString("Lag")
util.AddNetworkString("lages")
util.AddNetworkString("BuildN")

local lastSysCurrDiff = 9999

local function GetCurrentDelta()
    local SysCurrDiff = SysTime() - CurTime()
    local delta = SysCurrDiff - lastSysCurrDiff  
    lastSysCurrDiff = SysCurrDiff
    return delta
end

local function sendLags(number)
    net.Start("lages")
    net.WriteFloat(number)
    net.Broadcast()
end

local Resol = {
    [0] = 0,
    [1] = 0.1,
    [2] = 0.37,
    [3] = 1.49,
    [4] = 1.73,
}

local laglevel = 0

local Lag = {
    [0] = function()
        frezzelist()
        ClearLuaMemory()
        buildnotify(
            Color(0, 0, 0),   "► ",
            Color(200, 200, 200), "Обнаружены лаги ",
            Color(255, 255, 255), "0",
            Color(200, 200, 200), " все пропы заморожены."
        )
    end,

    [1] = function()
        frezzelist()
        ClearLuaMemory()
        buildnotify(
            Color(0, 0, 0),   "► ",
            Color(200, 200, 200), "Обнаружены лаги ",
            Color(0, 255, 0),  "1",
            Color(200, 200, 200), " все пропы заморожены, время замедлилось на ",
            Color(0, 200, 0),  "20%."
        )
        if akychLib and akychLib.vk then
            akychLib.vk.vkAddMessage("[GB_lag]► Сервер лагает [Easy]")
        end
    end,

    [2] = function()
        ClearLuaMemory()
        e2Stoplist()
        frezzelist()
        buildnotify(
            Color(0, 0, 0),   "► ",
            Color(200, 200, 200), "Лаги не были устранены ",
            Color(255, 255, 0), "2",
            Color(200, 200, 200), " все пропы заморожены, E2 остановлены, время замедлилось на ",
            Color(200, 200, 0), "40%."
        )
        if akychLib and akychLib.vk then
            akychLib.vk.vkAddMessage("[GB_lag]► Сервер лагает [Medium]")
        end
    end,

    [3] = function()
        ClearLuaMemory()
        destrouedd()
        e2Stopram()
        frezze()
        buildnotify(
            Color(0, 0, 0),   "► ",
            Color(200, 200, 200), "Лаги не были устранены ",
            Color(255, 0, 0),  "3",
            Color(200, 200, 200), " выборочный CleanUP, все пропы заморожены, E2 остановлены, время замедлилось на ",
            Color(200, 0, 0),  "60%."
        )
        if akychLib and akychLib.vk then
            akychLib.vk.vkAddMessage("[GB_lag]► Сервер лагает [Hard]")
        end
    end,

    [4] = function()
        ClearLuaMemory()
        destroued()
        game.SetTimeScale(1)
        buildnotify(
            Color(0, 0, 0),    "► ",
            Color(200, 200, 200), "Кажись серв помирает ",
            Color(255, 0, 255), "4  общий CleanUP"
        )
        if akychLib and akychLib.vk then
            akychLib.vk.vkAddMessage("[GB_lag]► Сервер лагает [Ultra Hard]")
        end
    end,
}

local function unlages()
    timer.Create("vngrUnlag", 4 * laglevel, 1, function()  
        if laglevel < 1 then return end
        laglevel = laglevel - 1

        local g = 255
        if laglevel > 0 then g = math.floor(255 / laglevel) end
        buildnotify(
            Color(0, 0, 0),  "► ",
            Color(200, 200, 200), "Уровень лагов сброшен до ",
            Color(85 * laglevel, g, 0), tostring(laglevel)
        )
        game.SetTimeScale(math.Clamp(1 - (laglevel / 5), 0.4, 1))
        if laglevel >= 1 then
            unlages()
        end
    end)
end



local Testos = CurTime()

hook.Add("Think", "antelag", function()
    if Testos >= CurTime() then return end

    local LagLvl = GetCurrentDelta() - (Resol[laglevel] or 0)
    Testos = CurTime() + 0.3

    if LagLvl > 5 then
        Lag[4]()
        sendLags(LagLvl)
        return
    end

    if LagLvl > 0.5 then
        sendLags(LagLvl + laglevel)
        Testos = CurTime() + 0.2 + LagLvl / 7
        laglevel = math.Clamp(laglevel + 1, 0, 4)
        unlages()
        Lag[math.Clamp(laglevel, 1, 4)]()
    end
end)

timer.Create("vngrLagReport", 10, 0, function()  
    sendLags(GetCurrentDelta())
end)



akychLib = akychLib or {}
akychLib.suka = akychLib.suka or {}

akychLib.suka.lagforce = function(vCorner1, vCorner2)
    local tEntities = ents.FindInBox(vCorner1, vCorner2)
    local tPlayers = {}
    local iPlayers = 0
    for i = 1, #tEntities do
        local P = tEntities[i]
        if Classes[P:GetClass()] and IndexFalse[P:GetCollisionGroup()] then
            iPlayers = iPlayers + 1
            tPlayers[iPlayers] = P
        end
    end
    return tPlayers, iPlayers
end

hook.Add("OnEntityCreated", "SoftEntList", function(ent)
    ent.crushTime = 0
    if not Classes[ent:GetClass()] then return end

    timer.Simple(0.1, function()

        if not IsValid(ent) then return end
        if not IsValid(ent:CPPIGetOwner()) then return end
        if ent:CPPIGetOwner().whiteList then return end

        local maxs = ent:LocalToWorld(ent:OBBMaxs() * 0.8)
        local mins = ent:LocalToWorld(ent:OBBMins() * 0.8)
        local Arr, C = akychLib.suka.lagforce(maxs, mins)

        if C > 15 then
            local owner = ent:CPPIGetOwner()
            if IsValid(owner) then
                akychLib.suka.tpAdmin(owner)
                buildnotify(
                    Color(0, 0, 0),   "► ",
                    Color(200, 200, 200), "[" .. ent:EntIndex() .. "][" .. ent:GetClass() .. "] ",
                    team.GetColor(owner:Team()), owner:Name(),
                    Color(200, 200, 200), string.format(" замечены (%s) стакнутых предметов.", C)
                )
                for _, vv in ipairs(Arr) do
                    vv:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
                    local phys = vv:GetPhysicsObject()
                    if IsValid(phys) then
                        phys:EnableMotion(false)
                    end
                end
            end
        end
    end)
end)


local function PlayerHit(ent, inflictor, attacker, amount, dmginfo)
    if not IsValid(ent) then return end
    if inflictor:GetDamageType() ~= 1 then return end

    local timerName = "_" .. ent:EntIndex()
    timer.Create(timerName, 5, 1, function()
        if IsValid(ent) then ent.crushTime = 0 end
    end)

    ent.crushTime = (ent.crushTime or 0) + 0.1

    if ent.crushTime > 10 then
        if timer.Exists(timerName) then timer.Remove(timerName) end
        ent.crushTime = 0

        local owner = ent:CPPIGetOwner()
        if IsValid(owner) then
            akychLib.suka.tpAdmin(owner)
            buildnotify(
                Color(0, 0, 0),   "► ",
                Color(200, 200, 200), "[" .. ent:EntIndex() .. "][" .. ent:GetClass() .. "] ",
                team.GetColor(owner:Team()), owner:Name(),
                Color(200, 200, 200), " заморожен из-за большого количества столкновений."
            )
        end

        local phys = ent:GetPhysicsObject()
        if IsValid(phys) then
            phys:EnableMotion(false)
        end
    end
end

hook.Add("EntityTakeDamage", "PlayerHit", PlayerHit)



timer.Simple(10, function()
    hook.Add("PlayerSpawnedSWEP", "vngrFreezeSWEP", function(ply, ent)
        timer.Simple(0, function()
            if not IsValid(ent) then return end
            local phys = ent:GetPhysicsObject()
            if IsValid(phys) then
                phys:EnableMotion(false)
                ent:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
            end
        end)
    end)
end)