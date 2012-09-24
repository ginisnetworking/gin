-- nixio upnp search and NAT
payload = ""
payload = payload .. "M-SEARCH * HTTP/1.1\r\n"
payload = payload .. "Host:239.255.255.250:1900\r\n"
payload = payload .. "ST:upnp:rootdevice\r\n"
payload = payload .. "Man:\"ssdp:discover\"\r\n"
payload = payload .. "MX:3\r\n\r\n"

print (payload)
local nixio = require "nixio", require "nixio.util" 
local mysock = nixio.connect("239.255.255.250", "1900", "inet", "dgram")      --
mysock:write(payload)
mysock:close()

-- [[
-- reuse sock to get upnp response from gateway
-- HTTP/1.1 200 OK
-- Server: Custom/1.0 UPnP/1.0 Proc/Ver
-- EXT:
-- Location: http://MYGATEWAY:5431/dyndev/uuid:0000e0b8-60a0-00e0-a0a0-4818000808e0
-- Cache-Control:max-age=1800
-- ST:upnp:rootdevice
-- USN:uuid:0000e0b8-60a0-00e0-a0a0-4818000808e0::upnp:rootdevice
-- ]]
