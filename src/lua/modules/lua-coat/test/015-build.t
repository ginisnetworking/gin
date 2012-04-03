#!/usr/bin/env lua

require 'Coat'

class 'Foo'

has.var = { is = 'rw', isa = 'number', default = 1 }

function method:BUILD ()
    self.var = 2
end

require 'Test.More'

plan(4)

if os.getenv "GEN_PNG" and os.execute "dot -V" == 0 then
    local f = io.popen("dot -T png -o 015.png", 'w')
    f:write(require 'Coat.UML'.to_dot())
    f:close()
end

foo = Foo.new{ var = 4 }
ok( foo:isa 'Foo', "Foo" )
is( foo.var, 2 )

foo = Foo.new()
ok( foo:isa 'Foo', "Foo (default)" )
is( foo.var, 2 )

