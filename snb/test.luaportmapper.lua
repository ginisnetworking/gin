#!/usr/bin/env lua

require("luaportmapper")

print (hello("hello"));
-- gateway port to local port
print (natpmp_map(10000,12000));