#!/usr/bin/env lua

require 'Coat'

augment 'Point'

has.color = { is = 'rw', isa = 'number' }

require 'Test.More'

plan(6)

if os.getenv "GEN_PNG" and os.execute "dot -V" == 0 then
    local f = io.popen("dot -T png -o 123.png", 'w')
    f:write(require 'Coat.UML'.to_dot())
    f:close()
end

p = Point{x = 1, y = 2, color = 0xFF00FF}
is( p:type(), 'Point', "new" )
ok( p:isa 'Point' )
is( p.x, 1 )
is( p.y, 2 )
is( p.color, 0xFF00FF )
is( tostring(p), "(1, 2)", "stringify" )

