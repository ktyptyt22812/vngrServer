
local EntityCache     = {}
local PlayerCache     = {}
local EntityCache_Set = {}
local PlayerCache_Set = {}

local local_player = nil
local gm_cache = nil
local games_mounted = {}
local gamemode_name = nil
local games_length = 0
local games = {}
local gamemodes_length = 0
local gamemodes = {}
local addons_length = 0
local addons = {}
local playing_demo = false

local tickinterval = nil
local isosx = nil
local islinux = nil
local iswindows = nil
local country = nil
local scrh = nil
local scrw = nil
local isdedicated = nil
local singleplayer = nil
local maxplayers = nil
local maxplayers_string = nil


local function GetConVarNumber(name)
    if name == "maxplayers" then
        if maxplayers then return maxplayers end
        maxplayers = GetConVar("maxplayers"):GetFloat()
        return maxplayers
    end
end

local function GetConVarString(name)
    if name == "maxplayers" then
        if maxplayers_string then return maxplayers_string end
        maxplayers_string = GetConVar("maxplayers"):GetString()
        return maxplayers_string
    end
end


local _IsDedicated = IsDedicated
function IsDedicated()
    if isdedicated ~= nil then return isdedicated end
    isdedicated = _IsDedicated()
    return isdedicated
end

local _SinglePlayer = SinglePlayer
function SinglePlayer()
    if singleplayer ~= nil then return singleplayer end
    singleplayer = _SinglePlayer()
    return singleplayer
end

local _MaxPlayers = MaxPlayers
function MaxPlayers()
    if maxplayers ~= nil then return maxplayers end
    maxplayers = _MaxPlayers()
    return maxplayers
end

local _GetMap = GetMap
function GetMap()
    return _GetMap()
end

local _ScrH = ScrH
function ScrH()
    if scrh then return scrh end
    scrh = _ScrH()
    return scrh
end

local _ScrW = ScrW
function ScrW()
    if scrw then return scrw end
    scrw = _ScrW()
    return scrw
end

function ScreenHeight() return ScrH() end
function ScreenWidth()  return ScrW() end

hook.Add("OnScreenSizeChanged", "CB_InvalidateScreenCache", function()
    scrh = nil
    scrw = nil
end)

local _TickInterval = TickInterval
function TickInterval()
    if tickinterval then return tickinterval end
    tickinterval = _TickInterval()
    return tickinterval
end

local _IsOSX = IsOSX
function IsOSX()
    if isosx ~= nil then return isosx end
    isosx = _IsOSX()
    return isosx
end

local _IsLinux = IsLinux
function IsLinux()
    if islinux ~= nil then return islinux end
    islinux = _IsLinux()
    return islinux
end

local _IsWindows = IsWindows
function IsWindows()
    if iswindows ~= nil then return iswindows end
    iswindows = _IsWindows()
    return iswindows
end

local _GetCountry = GetCountry
function GetCountry()
    if country then return country end
    country = _GetCountry()
    return country
end

local _IsPlayingDemo = IsPlayingDemo
function IsPlayingDemo()
    if playing_demo ~= nil then return playing_demo end
    playing_demo = _IsPlayingDemo()
    return playing_demo
end

local _ActiveGamemode = ActiveGamemode
function ActiveGamemode()
    if gamemode_name then return gamemode_name end
    gamemode_name = _ActiveGamemode()
    return gamemode_name
end

local _IsMounted = IsMounted
function IsMounted(name)
    if games_mounted[name] ~= nil then return games_mounted[name] end
    games_mounted[name] = _IsMounted(name)
    return games_mounted[name]
end

local _GetDXLevel = GetDXLevel
function GetDXLevel()
    return _GetDXLevel()
end

local _SupportsPixelShaders_1_4 = SupportsPixelShaders_1_4
function SupportsPixelShaders_1_4()
    return _SupportsPixelShaders_1_4()
end

local _SupportsVertexShaders_2_0 = SupportsVertexShaders_2_0
function SupportsVertexShaders_2_0()
    return _SupportsVertexShaders_2_0()
end

local _SupportsPixelShaders_2_0 = SupportsPixelShaders_2_0
function SupportsPixelShaders_2_0()
    return _SupportsPixelShaders_2_0()
end

local _SupportsHDR = SupportsHDR
function SupportsHDR()
    return _SupportsHDR()
end

local _isbool = isbool
function isbool(value)
    return _isbool(value)
end


if CLIENT then
    local _LocalPlayer = LocalPlayer
    function LocalPlayer()
        if local_player and local_player:IsValid() then return local_player end
        local_player = _LocalPlayer()
        return local_player
    end
end


local gmod_GetGamemode = gmod.GetGamemode
function gmod.GetGamemode()
    if gm_cache then return gm_cache end
    gm_cache = gmod_GetGamemode()
    return gm_cache
end


local _GetGames = GetGames
function GetGames()
    if games_length > 0 then return games end
    local raw = _GetGames()
    for _, gametab in ipairs(raw) do
        games_length = games_length + 1
        games[games_length] = {
            folder    = gametab.folder,
            depot     = gametab.depot,
            owner     = gametab.owner,
            installed = gametab.installed,
            mounted   = gametab.mounted,
            owned     = gametab.owned,
            title     = gametab.title,
        }
    end
    return games
end

local _GetGamemodes = GetGamemodes
function GetGamemodes()
    if gamemodes_length > 0 then return gamemodes end
    local raw = _GetGamemodes()
    for _, gamemodetab in ipairs(raw) do
        gamemodes_length = gamemodes_length + 1
        gamemodes[gamemodes_length] = {
            name       = gamemodetab.name,
            title      = gamemodetab.title,
            maps       = gamemodetab.maps,
            menusystem = gamemodetab.menusystem,
            workshopid = gamemodetab.workshopid,
        }
    end
    return gamemodes
end

local _GetAddons = GetAddons
function GetAddons()
    if addons_length > 0 then return addons end
    local raw = _GetAddons()
    for _, addontab in ipairs(raw) do
        addons_length = addons_length + 1
        addons[addons_length] = {
            wsid       = addontab.wsid,
            title      = addontab.title,
            size       = addontab.size,
            tags       = addontab.tags,
            file       = addontab.file,
            timeadded  = addontab.timeadded,
            updated    = addontab.updated,
            downloaded = addontab.downloaded,
            mounted    = addontab.mounted,
            models     = addontab.models,
        }
    end
    return addons
end


local util_TraceLine = util.TraceLine

local function QuickTrace(origin, filter)
    local tracedata = {
        start  = origin,
        endpos = origin,
        filter = filter,
    }
    local output = {}
    util_TraceLine(tracedata, output)
    return output
end


local ENTITY = FindMetaTable("Entity")
local PLAYER = FindMetaTable("Player")
local WEAPON = FindMetaTable("Weapon")

local _ENT_IsPlayer  = ENTITY.IsPlayer
local _ENT_IsNPC     = ENTITY.IsNPC
local _ENT_IsWeapon  = ENTITY.IsWeapon
local _ENT_IsVehicle = ENTITY.IsVehicle
local _ENT_IsNextBot = ENTITY.IsNextBot

local _ENT_GetClass = ENTITY.GetClass
function ENTITY:GetClass()
    local t = self:GetTable()
    if t.GetClass_Cache then return t.GetClass_Cache end
    local class = _ENT_GetClass(self)
    t.GetClass_Cache = class
    return class
end

local _ENT_IsWorld = ENTITY.IsWorld
function ENTITY:IsWorld()
    local t = self:GetTable()
    if t.world_validated ~= nil then return t.world_validated end
    t.world_validated = _ENT_IsWorld(self)
    return t.world_validated
end

local _PLY_UniqueID = PLAYER.UniqueID
function PLAYER:UniqueID()
    local t = self:GetTable()
    if t.UniqueID_Cache then return t.UniqueID_Cache end
    local uid = _PLY_UniqueID(self)
    t.UniqueID_Cache = uid
    return uid
end

local _PLY_AccountID = PLAYER.AccountID
function PLAYER:AccountID()
    local t = self:GetTable()
    if t.AccountID_Cache then return t.AccountID_Cache end
    local aid = _PLY_AccountID(self)
    t.AccountID_Cache = aid
    return aid
end

local _PLY_SteamID = PLAYER.SteamID
function PLAYER:SteamID()
    local t = self:GetTable()
    if t.SteamID_Cache then return t.SteamID_Cache end
    local sid = _PLY_SteamID(self)
    t.SteamID_Cache = sid
    return sid
end

local _PLY_SteamID64 = PLAYER.SteamID64
function PLAYER:SteamID64()
    local t = self:GetTable()
    if t.SteamID64_Cache then return t.SteamID64_Cache end
    local sid64 = _PLY_SteamID64(self)
    t.SteamID64_Cache = sid64
    return sid64
end





function PLAYER:MouthMoveAnimation()
    -- stub
end

local _PLY_IsListenServerHost = PLAYER.IsListenServerHost
function PLAYER:IsListenServerHost()
    return _PLY_IsListenServerHost(self)
end

function PLAYER:RenderMe()
    -- stub
end

function PLAYER:PlayerTick()
    -- stub
end



local _player_GetAll = player.GetAll
local _ents_GetAll   = ents.GetAll

local function AddToEntityCache(ent)
    if EntityCache_Set[ent] then return end
    EntityCache_Set[ent] = true
    EntityCache[#EntityCache + 1] = ent

    if _ENT_IsPlayer(ent) then
        if not PlayerCache_Set[ent] then
            PlayerCache_Set[ent] = true
            PlayerCache[#PlayerCache + 1] = ent
        end
    end
end

local function RemoveFromCache(cache, set, ent)
    if not set[ent] then return end
    set[ent] = nil
    for i = 1, #cache do
        if cache[i] == ent then
            table.remove(cache, i)
            return
        end
    end
end

local function InvalidateInternalEntityCache(ent, isPly)
    if isPly then
        RemoveFromCache(PlayerCache, PlayerCache_Set, ent)
    end
    RemoveFromCache(EntityCache, EntityCache_Set, ent)
end


player.GetCount = function()
    return #PlayerCache
end

player.GetAll = function()
    return PlayerCache
end

player.Iterator = function()
    return ipairs(PlayerCache)
end

ents.GetAll = function()
    return EntityCache
end

ents.Iterator = function()
    return ipairs(EntityCache)
end


hook.Add("OnEntityCreated", "CB_AddEntityCache", function(ent)

    timer.Simple(0, function()
        if IsValid(ent) then
            AddToEntityCache(ent)
        end
    end)
end)

hook.Add("EntityRemoved", "CB_InvalidateEntityCache", function(ent)
    InvalidateInternalEntityCache(ent, _ENT_IsPlayer(ent))
end)

hook.Add("PlayerDisconnected", "CB_InvalidatePlayerCache", function(ply)
    InvalidateInternalEntityCache(ply, true)
end)


hook.Add("InitPostEntity", "CB_InitCache", function()
    EntityCache     = {}
    PlayerCache     = {}
    EntityCache_Set = {}
    PlayerCache_Set = {}

    for _, ent in ipairs(_ents_GetAll()) do
        if IsValid(ent) then
            AddToEntityCache(ent)
        end
    end

    for _, ply in ipairs(_player_GetAll()) do
        if IsValid(ply) then
            AddToEntityCache(ply)
        end
    end

    if CLIENT then
        local_player = LocalPlayer()
        scrh = ScrH()
        scrw = ScrW()
    end
    gm_cache = gmod.GetGamemode()
end)