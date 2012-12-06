local ev = require 'ev'
local zmq = require "zmq"
local acceptor = require 'handler.acceptor'

-- Info on how to get a systems ip address 
-- http://lua-users.org/lists/lua-l/2011-02/msg00609.html
-- http://stackoverflow.com/questions/2021549/get-ip-address-in-c-language

local GinListener = {}


local function GinListener:new(ctx, id, parent) 
	local object = setmetatable({}, self) -- create new obj
	self.__index = self
	self         = object -- new object is the new self

	assert(ctx,    "[GinListener:new]: context is not valid")
	assert(id,     "[GinListener:new]: id is not valid")
	assert(parent, "[GinListener:new]: parent is not valid")

	self.ctx, self.id, self.parent = ctx, id, parent

	self.binds     = {} -- binds
	self.connsin   = {} -- connections coming in from a bind
    self.connsout  = {} -- connections going out
	self.peersin   = {} -- zeromq peer inproc socks for incomming conns
    self.peersout  = {} -- zeromq peer inproc socks for outgoing conns
   
    assert((self.loop    = ev.Loop.default)       "[GinListener:new]: Unable to create event loop") -- poller for network sockets
	assert((self.zpoller = zmq.poller(64)),       "[GinListener:new]: Unable to create zeromq poller")
	assert((self.socket  = zmq.socket(zmq.PAIR)), "[GinListener:new]: Unable to create self socket")

	local rc = self.socket:bind("inproc://" .. id)

    assert(rc, "[GinListener:new]: Unable to bind self socket")

    self.zpoller:add(self.socket, zmq.POLLIN, function (sock) self:parentreq() end)

	setmetatable(object, self)
    self.__index = self
    return object
end

local function GinListener:parentreq()
	-- read from self socket

	-- process request

    
	self:bind()
	self:unbind()
	self:connect()
	self:disconnect()
	self:stats()

end 

local function GinListener:bind(type, uri, handler) -- can only came from parent
	local bind = {}

	assert(uri and type(uri) == "string", "[GinListener:bind]: uri is not valid")
	assert(handler and type(handler) == "function", "[GinListener:bind]: handler is not valid")

	bind.type, bind.uri, bind.handler = type, uri, handler

	bind.socket = --blablabla

	self.binds[uri] = bind
	return bind
end

local function GinListener:unbind(uri)
	local bind = self.binds[uri]

	table.delete(self.binds, uri)
end

local function GinListener:connect(type, uri, handler) -- can only came from parent
end

local function GinListener:disconnect(connid) -- from parent, need params to identity connection
end

local function GinListener:stats()


local function GinListener:iter()

	-- ev loop
	-- zpoller
	-- sleep?

end

