#!/usr/bin/env lua

require 'Coat'

class 'Rect'

has.x = { is = 'rw', isa = 'number', required = true }
has.y = { is = 'rw', isa = 'number', required = true }

function method:getArea ()
    return self.x * self.y
end


require 'Test.More'

plan(8)

if os.getenv "GEN_PNG" and os.execute "dot -V" == 0 then
    local f = io.popen("dot -T png -o 171.png", 'w')
    f:write(require 'Coat.UML'.to_dot())
    f:close()
end

r = Rect{ x = 2, y = 4 }
is( r:type(), 'Rect', "Rect" )
ok( r:isa 'Rect' )
is( r:getArea(), 8, "area" )

r:mock('getArea', function () return 42 end)
is( r:getArea(), 42, "mocked area" )

rr = Rect{ x = 3, y = 3 }
is( rr:getArea(), 9, "not mocked area" )

r:unmock 'getArea'
is( r:getArea(), 8, "area initial" )

error_like([[r = Rect{ x = 2, y = 4 }; r:mock('foo', function () return 42 end)]],
           "Cannot mock non%-existent method foo in class Rect")

error_like([[r = Rect{ x = 2, y = 4 }; r:unmock 'foo']],
           "Cannot unmock non%-existent method foo in class Rect")

