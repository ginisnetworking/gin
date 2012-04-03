#!/usr/bin/env lua

require 'Test.More'

plan(7)

if not require_ok 'Car' then
    skip_rest "no lib"
    os.exit()
end

if os.getenv "GEN_PNG" and os.execute "dot -V" == 0 then
    local f = io.popen("dot -T png -o Car.png", 'w')
    f:write(require 'Coat.UML'.to_dot())
    f:close()
end

car = Car.new()
ok( car:isa 'Car', "isa" )
ok( car:does 'Breakable', "does" )
is( car.is_broken, nil )
ok( car:can '_break', "can" )
is( car:_break(), "I broke" )
is( car.is_broken, true )
