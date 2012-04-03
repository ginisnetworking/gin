#!/usr/bin/env lua

require 'Coat.Role'

role 'Breakable'

has.is_broken = { is = 'rw', isa = 'boolean' }

function method:_break ()
    self.is_broken = true
end

class 'Engine'
with 'Breakable'

class 'SpecialEngine'
extends 'Engine'

class 'Car'
has.engine = { is = 'rw', does = 'Breakable' }

require 'Test.More'

plan(6)

if os.getenv "GEN_PNG" and os.execute "dot -V" == 0 then
    local f = io.popen("dot -T png -o 203.png", 'w')
    f:write(require 'Coat.UML'.to_dot())
    f:close()
end

car = Car.new{ engine = Engine.new() }
ok( car:isa 'Car', "Car" )
ok( car.engine:does 'Breakable' )
is( car.engine.is_broken, nil )
car.engine:_break()
ok( car.engine.is_broken )
error_like([[local car = Car.new{ engine = Engine.new() }; car.engine = Car.new()]],
           "Value for attribute 'engine' does not consume role 'Breakable'")
car.engine = SpecialEngine.new()
ok( car.engine:does 'Breakable' )

