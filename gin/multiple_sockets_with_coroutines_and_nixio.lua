
local nixio = require "nixio", require "nixio.util" 

function get(hostname, port, url)
  local mysock = nixio.connect(hostname, port)
  print(mysock:getpeername()) 
  mysock:writeall("GET " .. url .. " HTTP/1.0\r\n\r\n")
  print(mysock:read(1024)) 
  mysock:close()
end

get("google.com", 80, "/")
