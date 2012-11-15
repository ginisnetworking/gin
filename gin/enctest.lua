local sha2 = require "sha2"
local encoder = require "encoder"


-- help and test

local x = {1 ,2, { "um", 1, "dois", 2 }, true , false }
function x:fun(k, v) self.k = sha2.sha512hex(v) end

y={}
y["y"]={ true , false }
y["y"][3]=y
y["y"][4]=10.10e-20

local e = encoder:new();

print (e:encode(x))
--print (e:encode(y))
local s = e:encode(x)
local z = e:decode(s)

print (e:encode(z))

--print (e:encode(e))
--print (e:encode(gencoder))

--[[

local encoder = {}

function encoder:encode (x,...)
   local enctype = ...
   
end
    --local s = self['encoders'][tl](self, o);
    --if (s:len() > 1300) then return s else return sha2.sha512hex(s) end
]]


--http://lua-users.org/wiki/SandBoxes
--local sha2     = require "sha2" -- http://code.google.com/p/sha2/
--local lsqlite3 = require('lsqlite3') -- http://lua.sqlite.org/index.cgi/index

-- error handling  https://docs.google.com/viewer?a=v&q=cache:V8NOWJz0bJ4J:www.lua.org/wshop06/Belmonte.pdf+&hl=en&pid=bl&srcid=ADGEEShL8oSiDy0bXozMcUVIO9cZwIp0kMx-wwewAwyNM_1-SkxjQm3Nv_EChC0VMTU8-Nl6UO-bVTkdkVtNYj8VJQodSR7ReT_LGexMU_2kzzs5Ew97IbLLRdT5AYVsXiW2zG6gq3qF&sig=AHIEtbTLLX-KWnd5dHjrqxh9ki0beO6uAw