#!/usr/bin/env lua

require 'Coat'

class 'Foo'

has.t = { is = 'rw', default = function () return 2 + 2 end }

require 'Test.More'

plan(5)

if os.getenv "GEN_PNG" and os.execute "dot -V" == 0 then
    local f = io.popen("dot -T png -o 012.png", 'w')
    f:write(require 'Coat.UML'.to_dot())
    f:close()
end

foo = Foo.new{ t = 2 }
ok( foo:isa 'Foo', "Foo" )
is( foo.t, 2 )

foo = Foo.new()
ok( foo:isa 'Foo', "Foo (default)" )
val = foo.t
isnt( type(val), 'function' )
is( val, 4 )

