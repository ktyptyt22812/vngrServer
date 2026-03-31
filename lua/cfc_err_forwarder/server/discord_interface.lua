local CurTime = CurTime

local log = ErrorForwarder.Logger
local Config = ErrorForwarder.Config

local DiscordInterface = {
    queue = {},
    running = false,
    saveFile = "cfc_error_forwarder_queue.json",
}
local DI = DiscordInterface

function DI:new()
    if Config.backup:GetBool() then
        hook.Add( "InitPostEntity", "CFC_ErrForwarder_LoadQueue", function()
            ProtectedCall( function()
                self:loadQueue()
            end )
        end )
    end

end

function DI:saveQueue()
    if #self.queue == 0 then
        if file.Exists( self.saveFile, "DATA" ) then
            file.Delete( self.saveFile, "DATA" )
        end
        return
    end

    log.info( "Saving " .. #self.queue .. " unsent errors to queue file." )
    file.Write( self.saveFile, util.TableToJSON( self.queue ) )
end

function DI:loadQueue()
    local saved = file.Read( self.saveFile, "DATA" )
    if not ( saved and #saved > 0 ) then return end

    local savedQueue = util.JSONToTable( saved )
    if not ( savedQueue and #savedQueue > 0 ) then return end

    log.info( "Loaded " .. #savedQueue .. " items from queue file." )

    for _, item in ipairs( savedQueue ) do
        self:enqueue( item )
    end

    file.Delete( self.saveFile, "DATA" )
end

function DI:sendNext()
    local item = table.remove( self.queue, 1 )
    if not item then
        if Config.backup:GetBool() then
            self:saveQueue()
        end
        self.running = false
        return
    end

    print( "kotSock:", kotSock )
    print( "kotSock.sendT:", kotSock.sendT )

    local success = ProtectedCall( function()
        kotSock.sendT( "SVMessage", {
            isClientside = item.isClientside,
            body = item.body,
            rawData = item.rawData,
        } )
    end )

    print( "sendT success:", success )
    self:sendNext()
end

function DI:enqueue( item )
    table.insert( self.queue, item )

    if not self.running then
        self.running = true
        self:sendNext()
    end
end

function DI:Send( data )
    local isClientside = data.isClientside

    self:enqueue{
        isClientside = isClientside,
        body = ErrorForwarder.Formatter( data ),
        rawData = data,
    }
end
DI:new()
ErrorForwarder.Discord = DI
