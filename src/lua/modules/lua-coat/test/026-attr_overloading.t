#!/usr/bin/env lua

require 'Coat'

class 'A'
has.x = { is = 'rw', isa = 'number', default = 42 }

class 'B'
extends 'A'
has.x = { '+', default = 43 }

require 'Test.More'

plan(5)

if os.getenv "GEN_PNG" and os.execute "dot -V" == 0 then
    local f = io.popen("dot -T png -o 026.png", 'w')
    f:write(require 'Coat.UML'.to_dot())
    f:close()
end

foo = A.new()
ok( foo:isa 'A', "A" )
is( foo.x, 42 )

foo = B.new()
ok( foo:isa 'B', "B" )
ok( foo:isa 'A' )
is( foo.x, 43 )

