#!/usr/bin/env lua

require 'Coat'

class 'Engine'

function method._break ()
    _G.seen = "I broke"
end

class 'Car'
has.engine = { is = 'rw', isa = 'Engine', handles = { '_break' } }

require 'Test.More'

plan(5)

if os.getenv "GEN_PNG" and os.execute "dot -V" == 0 then
    local f = io.popen("dot -T png -o 131.png", 'w')
    f:write(require 'Coat.UML'.to_dot())
    f:close()
end

_G.seen = ''

car = Car.new{ engine = Engine.new() }
ok( car:isa 'Car', "isa Car" )
ok( car.engine:isa 'Engine' )
ok( car:can '_break', "can _break" )
car:_break()
is( _G.seen, "I broke" )

function Car.method:run ()
    return true
end
error_like([[Car.has.turbo = { is = 'rw', handles = { 'run' } }]],
           "Duplicate definition of method run")
