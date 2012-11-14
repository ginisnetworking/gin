
local gencoder = { encoders = {} }

function gencoder:new () 
	local gencoder = { 
		path     = { }
	}
	setmetatable(gencoder, self)
	self.__index = self
	return gencoder    
end

function gencoder.compose(t, s) 
	return t .. string.len(s) .. ":" .. s
end
function gencoder.encoders:u(x) 
	error "enconde: thread and userdata are not supported." 
end
function gencoder.encoders:t(x) 
	error "enconde: thread and userdata are not supported." 
end
function gencoder.encoders:b(x) 
	return gencoder.compose("b", tostring(x)) 
end
function gencoder.encoders:n(x) 
	return gencoder.compose("n", tostring(x)) 
end
function gencoder.encoders:s(x) 
	return gencoder.compose("s", x)
end
function gencoder.encoders:f(x) 
	return gencoder.compose("f", string.dump(x))
end
function gencoder.encoders:t(x)
	local ret = ""
	table.insert (self.path, x)
	for k, v in pairs(x) do
		ret = ret .. self:encode(k) .. self:encode(v)
	end
	table.remove(self.path)
	return gencoder.compose("t", ret)
end


function gencoder:encode (object)
    local t = type(object)
    local l = string.sub(t, 1, 1)
  
    for k, v in pairs(self.path) do
		if (object==v) then return l .. tostring(-(table.maxn(self.path) - k)) end
    end
    return self['encoders'][l](self, object);
end

function gencoder:decode ()
end


local x = {1 ,2, { "um", 1, "dois", 2 }}
function x:fun(k, v) self.k = v end

y={}
y["y"]={}
y["y"][1]=y

local e = gencoder:new();

print (e:encode(y))
print (e:encode(x))
print (e:encode(e))
--print (e:encode(gencoder))

--[[

local encoder = {}

function encoder:encode (x,...)
   local enctype = ...
   
end

]]