#!/usr/bin/env lua

require("luaportmapper")


print (hello("hello"));

print ("== Getting addresses with UPNP ============\n");
local externalIP, internalIP = upnp_get_igd();
print ("External IP:" .. externalIP);
print ("Internal IP:" .. internalIP);

-- internal port, remote port
print ("== Mapping with UPNP ============\n");
print (upnp_map(10000,12000));

print ("== Getting addresses mapped by IGD ============\n");
print ("Checking port mapping");
local mapcheckrc = upnp_map_check(10000,12000);
print ("upnp_map_check returned " .. mapcheckrc);

print ("== Unmapping with UPNP ============\n");
print (upnp_unmap(10000,12000));

print ("== Getting addresses (once again) mapped by IGD ============\n");
print ("Checking port mapping");
mapcheckrc = upnp_map_check(10000,12000);
print ("upnp_map_check returned " .. mapcheckrc);



print ("== Mapping with NATPMP ==========\n");
print (natpmp_map(10001,12001));

-- print ("== Unmapping with UPNP ============\n");
-- print (upnp_unmap(12000));
