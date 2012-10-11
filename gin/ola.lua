
require "lsqlite3";

-- print package.path;
-- print package.loaders[0];

function t(a) if (a) == 0 then return 0 else return a + t(a-1) end end

print( t(100))

--function p (n) print (n) p(n+1) end

--p(1)
