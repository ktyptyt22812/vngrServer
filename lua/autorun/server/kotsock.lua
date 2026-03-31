-- kotsock
-- Copyright (C) 2021-2026 ktypt, selyodka, kot

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
require( "kot" )

if kotSock.setup then kotSock.setup(12350, 12351) end

module( "kotSock", package.seeall )

receivers = receivers or {}

incoming = function(name, data)
	if not name then return end
	
	local fn = receivers[name]
	
	if not fn then return end
	
	fn(util.JSONToTable(data))
end

hook = function(name, fn)
	receivers[name] = fn
end

sendT = function(name, t)
	rawsend(name, util.TableToJSON(t))
end

local function randomstr()
	return string.format("%08x", math.random(0, 0xFFFFFFFF))..string.format("%08x", math.random(0, 0xFFFFFFFF))
end

sendreceivers = sendreceivers or {}

defaultTimeout = 3

sendRecv = function(name, cb, cbfail, ...)
	sendRecvEx(name, cb, cbfail, defaultTimeout, ...)
end

sendRecvEx = function(name, cb, cbfail, timeout, ...)
	local args = {...}
	local id = randomstr()
	args.recvid = id
	sendT(name, args)
	local function cbex(data)
		if not data.recvid then ErrorNoHaltWithStack("no recvid :(") end
		local id = data.recvid
		timer.Remove(name..id)
		local cb = sendreceivers[name..id]
		if not cb then return end
		data.recvid = nil
		cb(data)
	end
	hook(name, cbex)
	sendreceivers[name..id] = cb
	timer.Create(name..id, timeout, 1, function()
		sendreceivers[name..id] = nil
		args.recvid = nil
		cbfail(unpack(args))
	end)
end
