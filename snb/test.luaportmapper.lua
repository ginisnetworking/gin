#!/usr/bin/env lua

require("luaportmapper")

print (hello("hello"));
-- internal port, remote port
print ("== Mapping with UPNP ============\n");
print (upnp_map(10000,12000));
print ("== Mapping with NATPMP ==========\n");
print (natpmp_map(10001,12001));


-- print ("== Unmapping with UPNP ============\n");
-- print (upnp_unmap(12000));