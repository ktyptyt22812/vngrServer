include( "logger.lua" )
local log = ErrorForwarder.Logger
local colors = ErrorForwarder.colors

require( "formdata" )
include( "helpers.lua" )
include( "config.lua" )
include( "discord_interface.lua" )
include( "error_forwarder.lua" )
include( "error_intake.lua" )
include( "client_info.lua" )

include( "formatter/nice_stack.lua" )
include( "formatter/get_source_url.lua" )
include( "formatter/text_helpers.lua" )
include( "formatter/formatter.lua" )

log.info( "Loaded!" )
