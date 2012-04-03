#!/usr/bin/env lua

require 'Coat.Role'

role 'Breakable'

function method._break ()
    _G.seen = "I broke"
end

class 'Engine'
with(Breakable)

class 'Car'
has.engine = { is = 'rw', does = 'Breakable', handles = 'Breakable' }

require 'Test.More'

plan(12)

if os.getenv "GEN_PNG" and os.execute "dot -V" == 0 then
    local f = io.popen("dot -T png -o 133.png", 'w')
    f:write(require 'Coat.UML'.to_dot())
    f:close()
end

_G.seen = ''

car = Car.new{ engine = Engine.new() }
ok( car:isa 'Car', "isa Car" )
ok( car.engine:isa 'Engine' )
ok( car.engine:does 'Breakable' )
ok( car:does 'Breakable', "does Breakable" )
ok( car:can '_break', "can _break" )
car:_break()
is( _G.seen, "I broke" )

error_like([[Car.has.turbo1 = { is = 'rw', handles = 'Unknown' }]],
           "module 'Unknown' not found")

error_like([[Car.has.turbo2 = { is = 'rw', handles = 'Engine' }]],
           "The handles option requires a table or a Role")

error_like([[Car.has.turbo3 = { is = 'rw', does = 'Boostable', handles = 'Breakable' }]],
           "The handles option requires a does option with the same role")

error_like([[Car.has.turbo4 = { is = 'rw', does = 'Breakable', handles = 'Breakable' }]],
           "Duplicate definition of method _break")

class 'Turbo'
error_like([[Turbo.with 'Unknown']],
           "module 'Unknown' not found")

error_like([[Turbo.with 'Engine']],
           "bad argument #1 to with %(string or Role expected%)")
