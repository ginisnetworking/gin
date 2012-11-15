local sha2 = require "sha2"

local gencoder = { encoders = { }, decoders = { } }

-- new encoder/decoder -------------------------------------------------------

function gencoder:new () 
	local gencoder = { 
		p = { }, -- path followed down the table structures
		i = 1,   -- index where we are reading form the encoded string
		s = ""   -- encoded string
	}
	setmetatable(gencoder, self)
	self.__index = self
	return gencoder    
end

-- encoding -----------------------------------------------------------------

function gencoder:getencoder(o)
    local t = type(o):sub(1, 2) 
    assert (t ~= "us", "enconde: userdata is not supported.")
    assert (t ~= "th", "enconde: userdata is not supported.")
    t = t:sub(1, 1)
    return self.encoders[t], t
end
function gencoder.compose(t, s) 
	return t .. string.len(s) .. ":" .. s
end
function gencoder.encoders:b(o) -- boolean
	self.s = self.s .. gencoder.compose("b", tostring(o and 1 or 0)) 
end
function gencoder.encoders:n(o) -- number
	self.s = self.s .. gencoder.compose("n", tostring(o)) 
end
function gencoder.encoders:s(o) -- string
	self.s = self.s .. gencoder.compose("s", o)
end
function gencoder.encoders:f(o) -- function
	self.s = self.s .. gencoder.compose("f", string.dump(o))
end
function gencoder.encoders:t(o) -- table
    self.s = self.s .. "t"
	table.insert (self.p, o)
	for k, v in pairs(o) do
		self:encoder(k)
		self:encoder(v)
	end
	table.remove(self.p)
	self.s = self.s .. "e"
end
function gencoder:encoder(o)
    for k, v in pairs(self.p) do
		if (o == v) then 
			self.s = self.s .. "t" .. tostring(- (#self.p - k)) .. "e"
			return
		end
    end
    self:getencoder(o)(self, o)
    --local s = self['encoders'][tl](self, o);
    --if (s:len() > 1300) then return s else return sha2.sha512hex(s) end
end
function gencoder:encode(o) 
   self.p, self.s = { }, ""
   self:encoder(o)
   return self.s
end

-- decoding -----------------------------------------------------------------

function gencoder:getdecoder() 
	local t = self.s:sub(self.i, self.i)
	print ("getdecoder: " .. self.s:sub(self.i).. " type:" .. t)
	assert(t, "decode: type not provided") 
	assert(self.decoders[t], "decode: no decoder for type '" .. t .. "'")
	self.i = self.i + 1
	return self.decoders[t], t
end	
function gencoder:getlen()	
    local a, b, len = self.s:find("^([0-9]+):", self.i)
	assert(len, "decode: length not provided")  
	print ("getlen: " .. self.s:sub(self.i).. " len:" .. len)
	self.i = self.i + (b - a) + 1
    return len
end
function gencoder.decoders:b(len) -- boolean
    local val = self.s:sub(self.i, self.i + len - 1)
    print ("boolean: " .. self.s:sub(self.i).. " len:" .. len .. " val: ".. val)
	assert(val, "decode: boolean value not provided")     
	self.i = self.i + len
	if (val == 1) then return true
	else return false end
end
function gencoder.decoders:n(len) -- number 
    local val = self.s:sub(self.i, self.i + len - 1)
    print ("number: " .. self.s:sub(self.i).. " len:" .. len .. " val: ".. val)
	assert(val, "decode: number value not provided")  
	self.i = self.i + len
	return tonumber(val)
end
function gencoder.decoders:s(len) -- string
    local val  = self.s:sub(self.i, self.i + len - 1)
    print ("string: " .. self.s:sub(self.i).. " len:" .. len .. " val: ".. val)
    assert(val, "decode: string value not provided")  
	self.i = self.i + len
	return val
end
function gencoder.decoders:f(len) -- function
    local val = self.s:sub(self.i, self.i + len - 1)
    print ("function: " .. self.s:sub(self.i).. " len:" .. len .. " val: ".. val)
    assert(val, "decode: function value not provided")  
	self.i = self.i + len
	return loadstring(val);
end
function gencoder.decoders:t()
	local o = { } 
	print("table: " .. self.s:sub(self.i).. " next:" .. self.s:sub(self.i, self.i).." stack len: " .. table.maxn(self.p))
	if self.s:sub(self.i, self.i) == "-" then
		local a, b, pos = self.s:find("^([0-9]+)e", self.i + 1)
		assert(pos, "decode: table negative index not supplied")
		print("table: neg index: " .. pos)
		self.i = self.i + (b - a) + 2
		assert (self.p[#self.p - pos], "decode: table negative index supplied does not exist")
		o = self.p[#self.p - pos]
	else
		table.insert(self.p, o)
		while self.s:sub(self.i, self.i) ~= "e" do 
			local k = self:decoder()
			print ("table: k " .. tostring(k))
			local v = self:decoder() 
			print ("table: v " .. tostring(v))
			o[k] = v
		end 
		table.remove(self.p)
		self.i = self.i + 1
	end -- else	
	print("table: rest --" .. self.s:sub(self.i))
	return o
end
function gencoder:decoder()
	local d, t = self:getdecoder()	
	if t == "t" then return d(self) 
	else return d(self, self:getlen()) end
end
function gencoder:decode(s)
    self.s, self.i, self.p = s, 1, {} -- string to decode and where to start
    return self:decoder()
end	


-- help and test


local x = {1 ,2, { "um", 1, "dois", 2 }, true , false }
function x:fun(k, v) self.k = v end

y={}
y["y"]={ true , false }
y["y"][3]=y
y["y"][4]=10.10e-20

local e = gencoder:new();

print (e:encode(y))
--print (e:encode(x))

local s = e:encode(y)
local z = e:decode(s)

print (e:encode(z))

--print (e:encode(e))
--print (e:encode(gencoder))

--[[

local encoder = {}

function encoder:encode (x,...)
   local enctype = ...
   
end

]]