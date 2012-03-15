#!/usr/bin/env lua

require 'Coat.Role'

role 'Breakable'

has.is_broken = { is = 'rw', isa = 'boolean' }

function method:_break ()
    self.is_broken = true
end

class 'Car'
with 'Breakable'

has.engine = { is = 'ro', isa = 'Engine' }

function after:_break ()
    _G.seen = "I broke"
end

require 'Test.More'

plan(5)

if os.getenv "GEN_PNG" and os.execute "dot -V" == 0 then
    local f = io.popen("dot -T png -o 202.png", 'w')
    f:write(require 'Coat.UML'.to_dot())
    f:close()
end

_G.seen = ''

car = Car.new()
ok( car:isa 'Car', "Car" )
ok( car:does 'Breakable' )
is( car.is_broken, nil )
car:_break()
ok( car.is_broken )
is( _G.seen, "I broke" )

