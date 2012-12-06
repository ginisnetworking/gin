
local zmq  = require "zmq"
local zth  = require "zmq.threads"
local sha2 = require "sha2"

math.randomseed(os.time()) -- seed the randomizer 

local ginChild = {}

function ginChild:new(ctx, class, code) 
	local child  = setmetatable({ ["ctx"] = ctx, ["class"] = class, ["code"] = code }, self) -- create new child
	self.__index = self

	child.socket = ctx:socket(zmq.PAIR)
	child.name   = sha2.sha512hex(class .. math.random(1000000)) -- every child is one in a million
	child.socket:bind("inproc://"..child.name) -- child will talk to parent throuhg here
	child.thread = zth.runstring(context, code) 
	child.thread:start()

	return child
end


local ginRoot = { ["children"] = {}, ["modules"] = {
	["in"]  = "ginIn",
	["out"] = "ginOut",
	["enc"] = "ginEnc",
	["dec"] = "ginDec"
}}

function ginRoot:init()

	-- only using inproc, so context has 0 threads
	local ctx = zmq.init(0)

	for class, req in pairs(self.modules) do
		--table.insert(self.children, selfginChild:new(ctx, class, 
		print(	string.format([[ local %s = require "%s" %s:new(...) ]], req))
	end
end


ginRoot:init()


