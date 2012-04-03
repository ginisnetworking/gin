#!/usr/bin/env lua

require 'Coat.Role'

role 'Breakable'

function method._break ()
    _G.seen = "I broke"
end

class 'Engine'
with 'Breakable'

class 'Car'
has.engine = { is = 'rw', does = 'Breakable', handles = Breakable }

require 'Test.More'

plan(8)

if os.getenv "GEN_PNG" and os.execute "dot -V" == 0 then
    local f = io.popen("dot -T png -o 132.png", 'w')
    f:write(require 'Coat.UML'.to_dot())
    f:close()
end

_G.seen = ''

car = Car.new{ engine = Engine.new() }
ok( car:isa 'Car', "isa Car" )
ok( car.engine:isa 'Engine' )
ok( car.engine:does 'Breakable' )
ok( car.engine:does(Breakable) )
ok( car:does 'Breakable', "does Breakable" )
ok( car:can '_break', "can _break" )
car:_break()
is( _G.seen, "I broke" )

error_like([[local engine = Engine.new(); engine:does {}]],
           "bad argument #2 to does %(string or Role expected%)")

