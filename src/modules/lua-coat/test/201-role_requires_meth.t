#!/usr/bin/env lua

require 'Coat.Role'

role 'Breakable'
requires '_break'
excludes 'Repairable'

role 'Repairable'

class 'Car'
with 'Breakable'

function method:_break ()
    return "I broke"
end

class 'SpecialCar'
extends 'Car'

class 'BadCar'
extends 'Car'
with 'Repairable'

class 'FakeCar'
with 'Breakable'


require 'Test.More'

plan(8)

if os.getenv "GEN_PNG" and os.execute "dot -V" == 0 then
    local f = io.popen("dot -T png -o 201.png", 'w')
    f:write(require 'Coat.UML'.to_dot())
    f:close()
end

car = Car.new()
ok( car:isa 'Car', "Car" )
ok( car:does 'Breakable' )
is( car:_break(), "I broke" )

car = SpecialCar.new()
ok( car:isa 'SpecialCar', "SpecialCar" )
ok( car:does 'Breakable' )
is( car:_break(), "I broke" )

error_like([[local car = BadCar.new()]],
           "Role Breakable excludes role Repairable",
           "BadCar")

error_like([[local car = FakeCar.new()]],
           "Role Breakable requires method _break")
