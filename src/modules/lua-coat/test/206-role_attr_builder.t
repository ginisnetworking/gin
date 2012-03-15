#!/usr/bin/env lua

require 'Coat.Role'

role 'HasColor'
requires '_build_color'

has.color = { is = 'ro', isa = 'string', lazy = true, builder = '_build_color' }

class 'Red'
with 'HasColor'

function method._build_color ()
    return 'red'
end

class 'Blue'
with 'HasColor'

function method._build_color ()
    return 'blue'
end


require 'Test.More'

plan(4)

if os.getenv "GEN_PNG" and os.execute "dot -V" == 0 then
    local f = io.popen("dot -T png -o 206.png", 'w')
    f:write(require 'Coat.UML'.to_dot())
    f:close()
end

c = Red.new()
ok( c:isa 'Red', "Red" )
is( c.color, 'red' )

c = Blue.new()
ok( c:isa 'Blue', "Blue" )
is( c.color, 'blue' )

