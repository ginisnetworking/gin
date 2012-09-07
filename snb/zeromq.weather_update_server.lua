--
--  Weather update server
--  Binds PUB socket to tcp://*:5556
--  Publishes random weather updates
--
--  Author: Robert G. Jakabosky <bobby@sharedrealm.com>
--
require"zmq"
local ffi = require "ffi"

--  Prepare our context and publisher
local context = zmq.init(1)
local publisher = context:socket(zmq.PUB)
publisher:bind("tcp://*:5556")
--publisher:bind("ipc://weather.ipc")
ffi.cdef "unsigned int sleep(unsigned int seconds);"

--  Initialize random number generator
math.randomseed(os.time())
while (1) do
    --  Get values that will fool the boss
    local zipcode, temperature, relhumidity
    zipcode     = 10001 --math.random(0, 99999)
    temperature = math.random(-80, 135)
    relhumidity = math.random(10, 60)
    --  ffi.C.sleep(1)
    --  Send message to all subscribers
    publisher:send(string.format("%05d %d %d", zipcode, temperature, relhumidity))
end
publisher:close()
context:term()